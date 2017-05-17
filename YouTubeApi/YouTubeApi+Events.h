//
// Created by Anton Turko on 2/26/16.
// Copyright (c) 2016 Anton Turko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YouTubeApi.h"
#include "YouTubeLiveEvent.h"

enum EventTime {
    UPCOMING,
    PAST,
    LIVE,
    ALL
};

@interface YouTubeApi (Events)
- (void)createEvent:(NSString *)eventName withDescription:(NSString *)description withDate:(NSDate *)startTime withPrivacySettings:(NSString *)privacySettings withBitrate:(NSString *)bitrate withCompletion:(void (^)(YouTubeLiveEvent *, NSError *))completion;
- (void)startEvent:(NSString *)broadcastId withCompletion:(void(^)(BOOL))completion;
- (void)prepareEvent:(NSString *)broadcastId withCompletion:(void(^)(BOOL))completion;
- (void)endEvent:(NSString *)broadcastId withCompletion:(void(^)(BOOL))completion;
- (void)getEventListWithTime:(enum EventTime)time withCompletion:(void (^)(NSArray *))completion;
- (void)setThumbnails:(NSData *)image forVideoId:(NSString *)videoId withMimeType:(NSString *)mimeType withCompletion:(void (^)(BOOL))completion;
- (void)deleteEventWithId:(NSString *)eventID withCompletion:(void(^)(BOOL))completion;
@end