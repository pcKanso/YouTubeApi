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
-(void)getStreamStatus:(NSString *)streamId withCompletino:(void(^)(BOOL))completion {
    GTLQueryYouTube *query = [GTLQueryYouTube queryForLiveStreamsListWithPart:@"status"];
    query.identifier = streamId;
    [self.youTubeService executeQuery:query completionHandler:^(GTLServiceTicket *ticket, GTLYouTubeLiveStreamListResponse *streamListResponse, NSError *error) {
        BOOL isActive = error == nil;
        if (isActive) {
            isActive = [((GTLYouTubeLiveStream *) streamListResponse.items.firstObject).status.streamStatus isEqualToString:@"active"];
        }
        completion(isActive);
    }];
}
@end