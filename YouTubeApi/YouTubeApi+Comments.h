//
// Created by Anton Turko on 2/26/16.
// Copyright (c) 2016 Anton Turko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YouTubeApi.h"

@interface YouTubeApi (Comments)
- (void)getCommentsList:(NSString *)chatId withPageToken:(NSString *)pageToken withCompletion:(void(^)(NSArray *, NSString *, NSNumber *))completion;
@end