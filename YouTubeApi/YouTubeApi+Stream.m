//
// Created by Anton Turko on 3/4/16.
// Copyright (c) 2016 Anton Turko. All rights reserved.
//

#import <GoogleAPIClientForREST/GTLRYouTube.h>
#import "YouTubeApi+Stream.h"


@implementation YouTubeApi (Stream)

-(void)getStreamStatus:(NSString *)streamId withCompletino:(void (^)(NSString *))completion {
    GTLRYouTubeQuery_LiveStreamsList *query = [GTLRYouTubeQuery_LiveStreamsList queryWithPart:@"status"];
    query.identifier = streamId;
    [self.youTubeService executeQuery:query completionHandler:^(GTLRServiceTicket *ticket, GTLRYouTube_LiveStreamListResponse *streamListResponse, NSError *error) {
        NSString *status = nil;
        if (error == nil) {
            status = ((GTLRYouTube_LiveStream *) streamListResponse.items.firstObject).status.streamStatus;
        }
        if (completion != nil) {
            completion(status);
        }
    }];
}
@end