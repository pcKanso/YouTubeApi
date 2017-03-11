//
// Created by Anton Turko on 3/2/16.
// Copyright (c) 2016 Anton Turko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YouTubeApi.h"

@interface YouTubeApi (Video)
-(void)getCountViewers:(NSString *)videoId withCompletion:(void (^)(BOOL, NSNumber *))completion;

- (void)uploadVideoWith:(NSString *)title videoUrl:(NSURL *)videoUrl withPrivacyStatus:(NSString *)privacyStatus withCompletion:(void (^)(BOOL))completion;
@end