//
// Created by Anton Turko on 3/14/16.
// Copyright (c) 2016 Anton Turko. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface YouTubeComment : NSObject
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSDate *published;
@property (nonatomic, strong) NSString *authorName;
@property (nonatomic, strong) NSString *profileImageUrl;
@end