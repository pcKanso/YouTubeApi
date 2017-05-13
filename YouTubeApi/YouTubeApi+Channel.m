//
// Created by Anton Turko on 3/12/17.
// Copyright (c) 2017 Walls. All rights reserved.
//

#import "YouTubeApi+Channel.h"
#import "GTLRYouTube.h"


@implementation YouTubeApi (Channel)
- (void)checkIsLiveStreamingEnabled:(void(^)(BOOL))completion {
    GTLRYouTubeQuery_ChannelsList *query = [GTLRYouTubeQuery_ChannelsList queryWithPart:@"id, status"];
    query.mine = YES;
    [self.youTubeService executeQuery:query completionHandler:^(GTLRServiceTicket *ticket, GTLRYouTube_ChannelListResponse *response, NSError *error) {
        GTLRYouTube_Channel *channel = response.items.firstObject;
        if (completion != nil) {
            completion(channel != nil && channel.status.longUploadsStatus != nil && [channel.status.longUploadsStatus isEqualToString:@"allowed"]);
        }
    }];
}

@end