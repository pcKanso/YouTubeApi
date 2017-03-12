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
    GTLQueryYouTube *query = [GTLQueryYouTube queryForChannelsListWithPart:@"id, status"];
    query.mine = YES;
    [self.youTubeService executeQuery:query completionHandler:^(GTLServiceTicket *ticket, GTLYouTubeChannelListResponse *response, NSError *error) {
        GTLYouTubeChannel *channel = response.items.firstObject;
        if (completion != nil) {
            completion(channel != nil && channel.status.longUploadsStatus != nil && [channel.status.longUploadsStatus isEqualToString:@"allowed"]);
        }
    }];
}

@end