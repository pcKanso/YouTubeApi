//
// Created by Anton Turko on 3/4/16.
// Copyright (c) 2016 Anton Turko. All rights reserved.
//

#import <GoogleAPIClient/GTLYouTubeLiveStream.h>
#import <GoogleAPIClient/GTLYouTubeLiveStreamStatus.h>
#import "YouTubeApi+Stream.h"
#import "GTLQueryYouTube.h"
#import "GTLYouTubeLiveStreamListResponse.h"


@implementation YouTubeApi (Stream)

-(void)getStreamStatus:(NSString *)streamId withCompletino:(void (^)(NSString *))completion {
    GTLQueryYouTube *query = [GTLQueryYouTube queryForLiveStreamsListWithPart:@"status"];
    query.identifier = streamId;
    [self.youTubeService executeQuery:query completionHandler:^(GTLServiceTicket *ticket, GTLYouTubeLiveStreamListResponse *streamListResponse, NSError *error) {
        NSString *status = nil;
        if (error == nil) {
            status = ((GTLYouTubeLiveStream *) streamListResponse.items.firstObject).status.streamStatus;
        }
        if (completion != nil) {
            completion(status);
        }
    }];
}
@end