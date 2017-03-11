//
// Created by Anton Turko on 2/19/16.
// Copyright (c) 2016 Anton Turko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GTLServiceYouTube.h"

#define WEAK_SELF __weak typeof (self) weakSelf = self
#define STRONG_WEAK_SELF __strong typeof(weakSelf) self = weakSelf


@interface YouTubeApi : NSObject
@property (nonatomic, strong) dispatch_group_t dispatchGroup;

+ (YouTubeApi *)instance;
- (BOOL)isAuthorized;

- (void)authenticateWithParent:(UIViewController *)parentViewConotroller withClientId:(NSString *)clientId withCompletion:(void (^)(BOOL))completion;
-(BOOL) resumeAuthorizationFlowWithURL:(NSURL *) url;
- (GTLServiceYouTube *)youTubeService;
@end