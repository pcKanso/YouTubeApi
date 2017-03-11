//
// Created by Anton Turko on 2/26/16.
// Copyright (c) 2016 Anton Turko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YouTubeApi.h"
#include "YouTubeLiveEvent.h"

@interface YouTubeApi (Events)
- (void)createEvent:(NSString *)eventName withDate:(NSDate *)startTime withPrivacySettings:(NSString *)privacySettings withBitrate:(NSString *)bitrate withCompletion:(void (^)(YouTubeLiveEvent *, BOOL))completion;
- (void)startEvent:(NSString *)broadcastId withCompletion:(void(^)(BOOL))completion;
- (void)prepareEvent:(NSString *)broadcastId withCompletion:(void(^)(BOOL))completion;
- (void)endEvent:(NSString *)broadcastId withCompletion:(void(^)(BOOL))completion;
- (void)getEventListWithCompletion:(void(^)(NSArray *))completion;
@end