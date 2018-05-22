//
// Created by Anton Turko on 2/26/16.
// Copyright (c) 2016 Anton Turko. All rights reserved.
//

#import <GoogleAPIClientForREST/GTLRYouTube.h>
#import "YouTubeApi+Events.h"

@implementation YouTubeApi (Events)

- (void)createEvent:(NSString *)eventName withDescription:(NSString *)description withDate:(NSDate *)startTime withPrivacySettings:(NSString *)privacySettings
        withBitrate:(NSString *)bitrate withCompletion:(void (^)(YouTubeLiveEvent *, NSError *))completion {
    if (completion == nil) {
        NSLog(@"completion is nil at create YouTube event");
        return;
    }
    GTLRYouTube_LiveBroadcastSnippet *snippet = [self createSnippet:eventName withDescription:description startTime:startTime];
    GTLRYouTube_LiveBroadcastContentDetails *details = [self createBroadcastDetails];
    GTLRYouTube_LiveBroadcastStatus *status = [self createBroadcastStatusWith:privacySettings];
    GTLRYouTube_LiveBroadcast *broadcast = [self createBroadCastWith:snippet details:details status:status];
    GTLRYouTubeQuery_LiveBroadcastsInsert *query = [GTLRYouTubeQuery_LiveBroadcastsInsert queryWithObject:broadcast part:@"snippet,status,contentDetails"];
    WEAK_SELF;
    [self.youTubeService executeQuery:query completionHandler:^(GTLRServiceTicket *ticket, GTLRYouTube_LiveBroadcast *liveBroadcast, NSError *error) {
        if (error != nil) {
            completion(nil, error);
            return;
        }
        STRONG_WEAK_SELF;
        GTLRYouTube_LiveStreamSnippet *streamSnippet = [self createStreamSnippet:eventName withDescription:description];
        GTLRYouTube_CdnSettings *cdn = [self createStreamCDNSettings:bitrate];
        GTLRYouTube_LiveStream *stream = [self createStream:streamSnippet cdn:cdn];
        GTLRYouTubeQuery_LiveStreamsInsert *streamQuery = [GTLRYouTubeQuery_LiveStreamsInsert queryWithObject:stream part:@"snippet,cdn"];
        [self.youTubeService executeQuery:streamQuery completionHandler:^(GTLRServiceTicket *streamTicket, GTLRYouTube_LiveStream *liveStream, NSError *streamError) {
            if (streamError != nil) {
                completion(nil, streamError);
                return;
            }
            GTLRYouTubeQuery_LiveBroadcastsBind *bindQuery = [self CreateBind:liveBroadcast withStream:liveStream];
            [self.youTubeService executeQuery:bindQuery completionHandler:^(GTLRServiceTicket *bindTicket, GTLRYouTube_LiveBroadcast *bindBroadcast, NSError *bindError) {
                YouTubeLiveEvent *event = [YouTubeLiveEvent new];
                [self fillYouTubeEventWith:bindBroadcast liveEvent:event stream:liveStream];
                completion(event, bindError);
            }];
        }];
    }];
}

- (GTLRYouTubeQuery_LiveBroadcastsBind *)CreateBind:(GTLRYouTube_LiveBroadcast *)liveBroadcast withStream:(GTLRYouTube_LiveStream *)liveStream {
    GTLRYouTubeQuery_LiveBroadcastsBind *bindQuery = [GTLRYouTubeQuery_LiveBroadcastsBind queryWithIdentifier:liveBroadcast.identifier
                                                                                                         part:@"id,contentDetails, snippet"];
    bindQuery.streamId = liveStream.identifier;
    return bindQuery;
}

- (GTLRYouTube_LiveStream *)createStream:(GTLRYouTube_LiveStreamSnippet *)streamSnippet cdn:(GTLRYouTube_CdnSettings *)cdn {
    GTLRYouTube_LiveStream *stream = [GTLRYouTube_LiveStream new];
    stream.kind = @"youtube#liveStream";
    stream.snippet = streamSnippet;
    stream.cdn = cdn;
    return stream;
}

- (GTLRYouTube_CdnSettings *)createStreamCDNSettings:(NSString *)bitrate {
    GTLRYouTube_CdnSettings *cdn = [GTLRYouTube_CdnSettings new];
//    cdn.format = bitrate;
    cdn.ingestionType = @"rtmp";
    cdn.resolution = kGTLRYouTube_CdnSettings_Resolution_X720p;
    cdn.frameRate = kGTLRYouTube_CdnSettings_FrameRate_X30fps;
    return cdn;
}

- (GTLRYouTube_LiveStreamSnippet *)createStreamSnippet:(NSString *)eventName withDescription:(NSString *)description {
    GTLRYouTube_LiveStreamSnippet *streamSnippet = [GTLRYouTube_LiveStreamSnippet new];
    streamSnippet.title = eventName;
    streamSnippet.descriptionProperty = description;
    return streamSnippet;
}

- (GTLRYouTube_LiveBroadcast *)createBroadCastWith:(GTLRYouTube_LiveBroadcastSnippet *)snippet details:(GTLRYouTube_LiveBroadcastContentDetails *)details status:(GTLRYouTube_LiveBroadcastStatus *)status {
    GTLRYouTube_LiveBroadcast *broadcast = [GTLRYouTube_LiveBroadcast new];
    broadcast.kind = @"youtube#liveBroadcast";
    broadcast.snippet = snippet;
    broadcast.status = status;
    broadcast.contentDetails = details;
    return broadcast;
}

- (GTLRYouTube_LiveBroadcastStatus *)createBroadcastStatusWith:(NSString *)privacySettings {
    GTLRYouTube_LiveBroadcastStatus *status = [GTLRYouTube_LiveBroadcastStatus new];
    status.privacyStatus = privacySettings;
    return status;
}

- (GTLRYouTube_LiveBroadcastContentDetails *)createBroadcastDetails {
    GTLRYouTube_LiveBroadcastContentDetails *details = [GTLRYouTube_LiveBroadcastContentDetails new];
    GTLRYouTube_MonitorStreamInfo *monitorStreamInfo = [GTLRYouTube_MonitorStreamInfo new];
    monitorStreamInfo.enableMonitorStream = @NO;
    details.monitorStream = monitorStreamInfo;
    return details;
}

- (GTLRYouTube_LiveBroadcastSnippet *)createSnippet:(NSString *)eventName withDescription:(NSString *)description startTime:(NSDate *)startTime {
    GTLRYouTube_LiveBroadcastSnippet *snippet = [GTLRYouTube_LiveBroadcastSnippet new];
    snippet.title = eventName;
    snippet.descriptionProperty = description;
    snippet.scheduledStartTime = [GTLRDateTime dateTimeWithDate:startTime];//TODO: maybe need set time zone
    return snippet;
}

- (void)startEvent:(NSString *)broadcastId withCompletion:(void (^)(BOOL))completion {
    [self changeBroadcast:broadcastId withStatus:@"live" withCompletion:completion];
}

- (void)prepareEvent:(NSString *)broadcastId withCompletion:(void (^)(BOOL))completion {
    [self changeBroadcast:broadcastId withStatus:@"testing" withCompletion:completion];
}

- (void)endEvent:(NSString *)broadcastId withCompletion:(void (^)(BOOL))completion {
    [self changeBroadcast:broadcastId withStatus:@"complete" withCompletion:completion];
}

- (void)getEventListWithTime:(enum EventTime)time withLimit:(NSUInteger)limit withPageToken:(NSString *)pageToken withCompletion:(void (^)(NSArray *, NSString *))completion {
    NSDictionary *mapping = @{
            @(UPCOMING): @"upcoming",
            @(PAST): @"completed",
            @(LIVE): @"active",
            @(ALL): @"all"
    };
    GTLRYouTubeQuery_LiveBroadcastsList *query = [GTLRYouTubeQuery_LiveBroadcastsList queryWithPart:@"id,contentDetails,snippet"];
    query.broadcastStatus = mapping[@(time)];
    query.maxResults = limit;
    query.pageToken = pageToken;
    WEAK_SELF;
    [self.youTubeService executeQuery:query completionHandler:^(GTLRServiceTicket *ticket, GTLRYouTube_LiveBroadcastListResponse *object, NSError *error) {
        if (completion == nil) {
            return;
        }
        if (error != nil) {
            completion(nil, nil);
            return;
        }
        STRONG_WEAK_SELF;
        NSMutableArray *events = [self mappingEvents:object];
        dispatch_group_notify(self.dispatchGroup, dispatch_get_main_queue(), ^{
            completion(events, object.nextPageToken);
        });
    }];
}

- (NSMutableArray *)mappingEvents:(GTLRYouTube_LiveBroadcastListResponse *)object {
    NSMutableArray *events = [NSMutableArray new];
    for (GTLRYouTube_LiveBroadcast *broadcast in object.items) {
        YouTubeLiveEvent *liveEvent = [YouTubeLiveEvent new];
        NSString *streamId = broadcast.contentDetails.boundStreamId;
        if (streamId != nil) {
            dispatch_group_enter(self.dispatchGroup);
            [self getLiveStream:streamId withCompletion:^(GTLRYouTube_LiveStream *stream) {
                [self fillYouTubeEventWith:broadcast liveEvent:liveEvent stream:stream];
                dispatch_group_leave(self.dispatchGroup);
            }];
        }
        [events addObject:liveEvent];
    }
    return events;
}

- (void)fillYouTubeEventWith:(GTLRYouTube_LiveBroadcast *)broadcast liveEvent:(YouTubeLiveEvent *)liveEvent stream:(GTLRYouTube_LiveStream *)stream {
    if (stream != nil) {
        [liveEvent setEvent:broadcast];
        GTLRYouTube_IngestionInfo *ingestionInfo = stream.cdn.ingestionInfo;
        NSString *streamName = ingestionInfo.streamName;
        liveEvent.rtmpServerUrl = ingestionInfo.ingestionAddress;
        liveEvent.streamName = streamName;
        liveEvent.resolution = stream.cdn.resolution;
        liveEvent.backupIngestionAddress = [NSString stringWithFormat:@"%@/%@", ingestionInfo.ingestionAddress, streamName];
    }
}

- (void)changeBroadcast:(NSString *)broadcastId withStatus:(NSString *)status withCompletion:(void (^)(BOOL))completion {
    GTLRYouTubeQuery_LiveBroadcastsTransition *query = [GTLRYouTubeQuery_LiveBroadcastsTransition queryWithBroadcastStatus:status identifier:broadcastId part:@"status"];
    [self.youTubeService executeQuery:query completionHandler:^(GTLRServiceTicket *ticket, id object, NSError *error) {
        if (completion != nil) {
            NSLog(@"Change broadcast status error %@", error);
            completion(error == nil);
        } else {
            NSLog(@"Change broadcast status error %@", error);
        }
    }];
}

- (void)getLiveStream:(NSString *)streamId withCompletion:(void (^)(GTLRYouTube_LiveStream *))completion {
    GTLRYouTubeQuery_LiveStreamsList *query = [GTLRYouTubeQuery_LiveStreamsList queryWithPart:@"cdn,status"];
    query.identifier = streamId;
    [self.youTubeService executeQuery:query completionHandler:^(GTLRServiceTicket *ticket, GTLRYouTube_LiveStreamListResponse *stream, NSError *error) {
        if (completion == nil) {
            return;
        }
        completion(stream != nil ? stream.items.firstObject : nil);
    }];
}

- (void)setThumbnails:(NSData *)image forVideoId:(NSString *)videoId withMimeType:(NSString *)mimeType withCompletion:(void (^)(BOOL))completion {
    GTLRUploadParameters *uploadParameters = [GTLRUploadParameters uploadParametersWithData:image MIMEType:mimeType];
    GTLRYouTubeQuery_ThumbnailsSet *queryYouTube = [GTLRYouTubeQuery_ThumbnailsSet queryWithVideoId:videoId uploadParameters:uploadParameters];
    [self.youTubeService executeQuery:queryYouTube completionHandler:^(GTLRServiceTicket *ticket, id object, NSError *error) {
        if (completion != nil) {
            completion(error == nil);
        }
    }];
}

- (void)deleteEventWithId:(NSString *)eventID withCompletion:(void (^)(BOOL))completion {
    GTLRYouTubeQuery_LiveBroadcastsDelete *queryYouTube = [GTLRYouTubeQuery_LiveBroadcastsDelete queryWithIdentifier:eventID];
    [self.youTubeService executeQuery:queryYouTube completionHandler:^(GTLRServiceTicket *ticket, id object, NSError *error) {
        if (completion != nil) {
            completion(error == nil);
        }
    }];
}


@end
