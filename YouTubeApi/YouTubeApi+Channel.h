//
// Created by Anton Turko on 3/12/17.
// Copyright (c) 2017 Walls. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YouTubeApi.h"

@interface YouTubeApi (Channel)
- (void)checkIsLiveStreamingEnabled:(void(^)(BOOL))completion;
@end