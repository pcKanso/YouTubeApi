//
// Created by Anton Turko on 2/19/16.
// Copyright (c) 2016 Anton Turko. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GTLYouTubeLiveBroadcast;
@class GTLYouTubeLiveStream;


@interface YouTubeLiveEvent : NSObject
@property(nonatomic, strong) NSString *streamName;
@property(nonatomic, strong) NSString *rtmpServerUrl;
@property(nonatomic, strong) NSString *backupIngestionAddress;
@property(nonatomic, strong) NSString *resolution;

-(void)setEvent:(GTLYouTubeLiveBroadcast *)event;
- (NSString *)getIdentifier;
- (NSString *)getTitle;
- (NSString *)getThumbUrl;
- (NSString *)getWatchUri;
- (NSString *)streamId;
- (NSString *)startTime;
@end