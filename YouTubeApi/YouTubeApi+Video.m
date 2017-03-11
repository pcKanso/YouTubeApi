//
// Created by Anton Turko on 3/2/16.
// Copyright (c) 2016 Anton Turko. All rights reserved.
//

#import <GoogleAPIClient/GTLYouTubeVideo.h>
#import <GoogleAPIClient/GTLYouTubeVideoLiveStreamingDetails.h>
#import "YouTubeApi+Video.h"
#import "GTLQueryYouTube.h"
#import "GTLYouTubeVideoListResponse.h"
#import "GTLYouTubeVideoStatus.h"
#import "GTLYouTubeVideoSnippet.h"


@implementation YouTubeApi (Video)

- (void)getCountViewers:(NSString *)videoId withCompletion:(void (^)(BOOL, NSNumber *))completion {
    GTLQueryYouTube *query = [GTLQueryYouTube queryForVideosListWithPart:@"liveStreamingDetails, status"];
    query.identifier = videoId;
    [self.youTubeService executeQuery:query completionHandler:^(GTLServiceTicket *ticket, GTLYouTubeVideoListResponse *list, NSError *error) {
        NSNumber *viewerCount = nil;
        if (error == nil) {
            viewerCount = ((GTLYouTubeVideo*)list.items.firstObject).liveStreamingDetails.concurrentViewers ?: @0;
        }
        completion(viewerCount != nil, viewerCount);
    }];
}

- (void)uploadVideoWith:(NSString *)title videoUrl:(NSURL *)videoUrl withPrivacyStatus:(NSString *)privacyStatus withCompletion:(void (^)(BOOL))completion {
    GTLYouTubeVideoStatus *status = [GTLYouTubeVideoStatus object];
    status.privacyStatus = privacyStatus;

    GTLYouTubeVideoSnippet *snippet = [GTLYouTubeVideoSnippet object];
    snippet.title = title;
    GTLYouTubeVideo *video = [GTLYouTubeVideo object];
    video.status = status;
    video.snippet = snippet;

    NSError *fileError;
    if (![videoUrl checkPromisedItemIsReachableAndReturnError:&fileError]) {
        completion(NO);
        return;
    }

    // Get a file handle for the upload data.
    NSString *mimeType = @"video/mp4";
    GTLUploadParameters *uploadParameters = [GTLUploadParameters uploadParametersWithFileURL:videoUrl MIMEType:mimeType];
    uploadParameters.uploadLocationURL = nil;

    GTLQueryYouTube *query = [GTLQueryYouTube queryForVideosInsertWithObject:video part:@"snippet,status"
                                                            uploadParameters:uploadParameters];

    GTLServiceYouTube *service = self.youTubeService;
    [service executeQuery:query completionHandler:^(GTLServiceTicket *callbackTicket, GTLYouTubeVideo *uploadedVideo, NSError *callbackError) {
        if (completion != nil) {
            completion(callbackError == nil);
        }
    }];
}

@end