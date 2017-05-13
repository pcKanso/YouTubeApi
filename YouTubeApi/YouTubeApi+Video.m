//
// Created by Anton Turko on 3/2/16.
// Copyright (c) 2016 Anton Turko. All rights reserved.
//

#import "YouTubeApi+Video.h"
#import "GTLRYouTube.h"


@implementation YouTubeApi (Video)

- (void)getCountViewers:(NSString *)videoId withCompletion:(void (^)(BOOL, NSNumber *))completion {
    GTLRYouTubeQuery_VideosList *query = [GTLRYouTubeQuery_VideosList queryWithPart:@"liveStreamingDetails, status"];
    query.identifier = videoId;
    [self.youTubeService executeQuery:query completionHandler:^(GTLRServiceTicket *ticket, GTLRYouTube_VideoListResponse *list, NSError *error) {
        NSNumber *viewerCount = nil;
        if (error == nil) {
            viewerCount = ((GTLRYouTube_Video*)list.items.firstObject).liveStreamingDetails.concurrentViewers ?: @0;
        }
        completion(viewerCount != nil, viewerCount);
    }];
}

- (void)uploadVideoWith:(NSString *)title videoUrl:(NSURL *)videoUrl withPrivacyStatus:(NSString *)privacyStatus withCompletion:(void (^)(BOOL))completion {
    GTLRYouTube_VideoStatus *status = [GTLRYouTube_VideoStatus object];
    status.privacyStatus = privacyStatus;

    GTLRYouTube_VideoSnippet *snippet = [GTLRYouTube_VideoSnippet object];
    snippet.title = title;
    GTLRYouTube_Video *video = [GTLRYouTube_Video object];
    video.status = status;
    video.snippet = snippet;

    NSError *fileError;
    if (![videoUrl checkPromisedItemIsReachableAndReturnError:&fileError]) {
        completion(NO);
        return;
    }

    // Get a file handle for the upload data.
    NSString *mimeType = @"video/mp4";
    GTLRUploadParameters *uploadParameters = [GTLRUploadParameters uploadParametersWithFileURL:videoUrl MIMEType:mimeType];
    uploadParameters.uploadLocationURL = nil;

    GTLRYouTubeQuery_VideosInsert *query = [GTLRYouTubeQuery_VideosInsert queryWithObject:video part:@"snippet,status"
                                                            uploadParameters:uploadParameters];

    GTLRYouTubeService *service = self.youTubeService;
    [service executeQuery:query completionHandler:^(GTLRServiceTicket *callbackTicket, GTLRYouTube_Video *uploadedVideo, NSError *callbackError) {
        if (completion != nil) {
            completion(callbackError == nil);
        }
    }];
}

@end