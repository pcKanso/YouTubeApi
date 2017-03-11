//
// Created by Anton Turko on 2/26/16.
// Copyright (c) 2016 Anton Turko. All rights reserved.
//

#import <GoogleAPIClient/GTLYouTubeLiveBroadcastStatus.h>
#import <GoogleAPIClient/GTLYouTubeLiveStreamSnippet.h>
#import "YouTubeApi+Events.h"
#import "GTLYouTubeLiveBroadcastSnippet.h"
#import "GTLYouTubeLiveBroadcastContentDetails.h"
#import "GTLQueryYouTube.h"
#import "GTLYouTubeMonitorStreamInfo.h"
#import "GTLYouTubeLiveBroadcastListResponse.h"
#import "GTLYouTubeLiveBroadcast.h"
#import "GTLYouTubeIngestionInfo.h"
#import "GTLYouTubeLiveStreamListResponse.h"
#import "GTLYouTubeLiveStream.h"
#import "GTLYouTubeCdnSettings.h"

@implementation YouTubeApi (Events)

- (void)createEvent:(NSString *)eventName withDate:(NSDate *)startTime withPrivacySettings:(NSString *)privacySettings
        withBitrate:(NSString *)bitrate withCompletion:(void (^)(YouTubeLiveEvent *, BOOL))completion {
    if (completion == nil) {
        NSLog(@"completion is nil at create YouTube event");
        return;
    }
    GTLYouTubeLiveBroadcastSnippet *snippet = [GTLYouTubeLiveBroadcastSnippet new];
    snippet.title = eventName;
    snippet.scheduledStartTime = [GTLDateTime dateTimeWithDate:startTime timeZone:[NSTimeZone localTimeZone]];
    GTLYouTubeLiveBroadcastContentDetails *details = [GTLYouTubeLiveBroadcastContentDetails new];
    GTLYouTubeMonitorStreamInfo *monitorStreamInfo = [GTLYouTubeMonitorStreamInfo new];
    monitorStreamInfo.enableMonitorStream = @NO;
    details.monitorStream = monitorStreamInfo;
    GTLYouTubeLiveBroadcastStatus *status = [GTLYouTubeLiveBroadcastStatus new];
    status.privacyStatus = privacySettings;
    GTLYouTubeLiveBroadcast *broadcast = [GTLYouTubeLiveBroadcast new];
    broadcast.kind = @"youtube#liveBroadcast";
    broadcast.snippet = snippet;
    broadcast.status = status;
    broadcast.contentDetails = details;
    GTLQueryYouTube *query = [GTLQueryYouTube queryForLiveBroadcastsInsertWithObject:broadcast part:@"snippet,status,contentDetails"];
    WEAK_SELF;
    [self.youTubeService executeQuery:query completionHandler:^(GTLServiceTicket *ticket, GTLYouTubeLiveBroadcast *liveBroadcast, NSError *error) {
        if (error != nil) {
            completion(nil, NO);
            return;
        }
        STRONG_WEAK_SELF;
        GTLYouTubeLiveStreamSnippet *streamSnippet = [GTLYouTubeLiveStreamSnippet new];
        streamSnippet.title = eventName;
        GTLYouTubeCdnSettings *cdn = [GTLYouTubeCdnSettings new];
        cdn.format = bitrate;
        cdn.ingestionType = @"rtmp";
        GTLYouTubeLiveStream *stream = [GTLYouTubeLiveStream new];
        stream.kind = @"youtube#liveStream";
        stream.snippet = streamSnippet;
        stream.cdn = cdn;
        GTLQueryYouTube *streamQuery = [GTLQueryYouTube queryForLiveStreamsInsertWithObject:stream part:@"snippet,cdn"];
        [self.youTubeService executeQuery:streamQuery completionHandler:^(GTLServiceTicket *streamTicket, GTLYouTubeLiveStream *liveStream, NSError *streamError) {
            if (streamError != nil) {
                completion(nil, NO);
                return;
            }
            GTLQueryYouTube *bindQuery = [GTLQueryYouTube queryForLiveBroadcastsBindWithIdentifier:liveBroadcast.identifier
                                                                                              part:@"id,contentDetails"];
            bindQuery.streamId = liveStream.identifier;
            [self.youTubeService executeQuery:bindQuery completionHandler:^(GTLServiceTicket *bindTicket, id object, NSError *bindError) {
                YouTubeLiveEvent *event = [YouTubeLiveEvent new];
                [self fillYouTubeEventWith:liveBroadcast liveEvent:event stream:liveStream];
                completion(event, bindError == nil);
            }];
        }];
    }];
}

- (void)startEvent:(NSString *)broadcastId withCompletion:(void(^)(BOOL))completion {
    [self changeBroadcast:broadcastId withStatus:@"live" withCompletion:completion];
}

- (void)prepareEvent:(NSString *)broadcastId withCompletion:(void(^)(BOOL))completion {
    [self changeBroadcast:broadcastId withStatus:@"testing" withCompletion:completion];
}

- (void)endEvent:(NSString *)broadcastId withCompletion:(void(^)(BOOL))completion {
    [self changeBroadcast:broadcastId withStatus:@"complete" withCompletion:completion];
}

- (void)getEventListWithCompletion:(void(^)(NSArray *))completion {
    GTLQueryYouTube *query = [GTLQueryYouTube queryForLiveBroadcastsListWithPart:@"id,snippet,contentDetails,status"];
    query.broadcastStatus = @"upcoming";
    [self.youTubeService executeQuery:query completionHandler:^(GTLServiceTicket *ticket, GTLYouTubeLiveBroadcastListResponse *object, NSError *error) {
        if (completion == nil) {
            return;
        }
        if (error != nil) {
            completion(nil);
            return;
        }
        NSMutableArray *events = [NSMutableArray new];
        for (GTLYouTubeLiveBroadcast *broadcast in object.items) {
            YouTubeLiveEvent *liveEvent = [YouTubeLiveEvent new];
            NSString *streamId = broadcast.contentDetails.boundStreamId;
            if (streamId != nil) {
                dispatch_group_enter(self.dispatchGroup);
                [self getLiveStream:streamId withCompletion:^(GTLYouTubeLiveStream *stream) {
                    [self fillYouTubeEventWith:broadcast liveEvent:liveEvent stream:stream];
                    dispatch_group_leave(self.dispatchGroup);
                }];
            }
            [events addObject:liveEvent];
        }
        dispatch_group_notify(self.dispatchGroup, dispatch_get_main_queue(), ^{
            completion(events);
        });
    }];
}

- (void)fillYouTubeEventWith:(GTLYouTubeLiveBroadcast *)broadcast liveEvent:(YouTubeLiveEvent *)liveEvent stream:(GTLYouTubeLiveStream *)stream {
    if (stream != nil) {
        [liveEvent setEvent:broadcast];
        GTLYouTubeIngestionInfo *ingestionInfo = stream.cdn.ingestionInfo;
        NSString *streamName = ingestionInfo.streamName;
        liveEvent.rtmpServerUrl = ingestionInfo.ingestionAddress;
        liveEvent.streamName = streamName;
        liveEvent.backupIngestionAddress = [NSString stringWithFormat:@"%@/%@", ingestionInfo.ingestionAddress, streamName];
    }
}

- (void)changeBroadcast:(NSString *)broadcastId withStatus:(NSString *)status withCompletion:(void (^)(BOOL))completion {
    GTLQueryYouTube *query = [GTLQueryYouTube queryForLiveBroadcastsTransitionWithBroadcastStatus:status identifier:broadcastId part:@"status"];
    [self.youTubeService executeQuery:query completionHandler:^(GTLServiceTicket *ticket, id object, NSError *error) {
        if (completion != nil) {
            completion(error == nil);
        } else {
            NSLog(@"Change broadcast status error %@", error);
        }
    }];
}

- (void)getLiveStream:(NSString *)streamId withCompletion:(void(^)(GTLYouTubeLiveStream *))completion {
    GTLQueryYouTube *query = [GTLQueryYouTube queryForLiveStreamsListWithPart:@"cdn,status"];
    query.identifier = streamId;
    [self.youTubeService executeQuery:query completionHandler:^(GTLServiceTicket *ticket, GTLYouTubeLiveStreamListResponse *stream, NSError *error) {
        if (completion == nil) {
            return;
        }
        completion(stream != nil ? stream.items.firstObject : nil);
    }];
}

@end