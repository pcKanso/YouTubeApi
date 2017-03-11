//
// Created by Anton Turko on 3/4/16.
// Copyright (c) 2016 Anton Turko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YouTubeApi.h"

@interface YouTubeApi (Stream)
-(void)getStreamStatus:(NSString *)streamId withCompletino:(void(^)(BOOL))completion;
@end