//
// Created by Anton Turko on 3/12/17.
// Copyright (c) 2017 Walls. All rights reserved.
//

#import <GoogleAPIClient/GTLQueryYouTube.h>
#import "YouTubeApi+Channel.h"
#import "GTLYouTubeChannelListResponse.h"
#import "GTLYouTubeChannel.h"
#import "GTLYouTubeChannelStatus.h"


@implementation YouTubeApi (Channel)
- (void)checkIsLiveStreamingEnabled:(void(^)(BOOL))completion {
    GTLQueryYouTube *query = [GTLQueryYouTube queryForChannelsListWithPart:@"status"];
    [self.youTubeService executeQuery:query completionHandler:^(GTLServiceTicket *ticket, GTLYouTubeChannelListResponse *response, NSError *error) {
        for(GTLYouTubeChannel *channel in response.items) {
            if (completion != nil) {
                completion(channel.status.longUploadsStatus != nil);
                break;
            }
        }
    }];
}

@end