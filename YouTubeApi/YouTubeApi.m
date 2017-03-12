//
// Created by Anton Turko on 2/19/16.
// Copyright (c) 2016 Anton Turko. All rights reserved.
//

#import <GTMAppAuth/GTMOAuth2KeychainCompatibility.h>
#import <AppAuth/OIDServiceConfiguration.h>
#import "GTLServiceYouTube.h"
#import "YouTubeApi.h"
#import "OIDAuthorizationService.h"
#import "OIDAuthorizationRequest.h"
#import "AppAuth.h"
#import "GTMAppAuth.h"


#define GoogleApp @"apps.googleusercontent.com"
#define ReversGoogleAppNamespace @"com.googleusercontent.apps"
#define kClientSecret nil
#define kKeychainItemName @"google_auth"

NSString *const kGTLRAuthScopeYouTube = @"https://www.googleapis.com/auth/youtube";

@interface YouTubeApi ()
@property(nonatomic, strong, nullable) id <OIDAuthorizationFlowSession> currentAuthorizationFlow;
@end

@implementation YouTubeApi {

}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.dispatchGroup = dispatch_group_create();
    }

    return self;
}

+ (YouTubeApi *)instance {
    static YouTubeApi *_instance = nil;

    @synchronized (self) {
        if (_instance == nil) {
            _instance = [[self alloc] init];
        }
    }

    return _instance;
}

- (GTLServiceYouTube *)youTubeService {
    static GTLServiceYouTube *service;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service = [[GTLServiceYouTube alloc] init];
        service.shouldFetchNextPages = YES;
        service.retryEnabled = YES;
        service.authorizer = [GTMAppAuthFetcherAuthorization authorizationFromKeychainForName:kKeychainItemName];
    });
    return service;
}

- (void)logout {
    [GTMOAuth2KeychainCompatibility removeAuthFromKeychainForName:kKeychainItemName];
}

- (BOOL)isAuthorized {
    return [self.youTubeService.authorizer canAuthorize];
}

- (void)authenticateWithParent:(UIViewController *)parentViewController withClientId:(NSString *)clientId withCompletion:(void (^)(BOOL))completion {
    NSString *kRedirectURI = [NSString stringWithFormat:@"%@.%@:/oauthredirect", ReversGoogleAppNamespace, clientId];
    OIDServiceConfiguration *configuration = [GTMAppAuthFetcherAuthorization configurationForGoogle];
    OIDAuthorizationRequest *request =
            [[OIDAuthorizationRequest alloc] initWithConfiguration:configuration
                                                          clientId:clientId
                                                      clientSecret:kClientSecret
                                                            scopes:@[kGTLRAuthScopeYouTube]
                                                       redirectURL:[NSURL URLWithString:kRedirectURI]
                                                      responseType:OIDResponseTypeCode
                                              additionalParameters:nil];
    self.currentAuthorizationFlow = [OIDAuthState authStateByPresentingAuthorizationRequest:request
                                                                   presentingViewController:parentViewController
                                                                                   callback:^(OIDAuthState *_Nullable authState, NSError *_Nullable error) {
                if (authState) {
                    GTMAppAuthFetcherAuthorization *authorization = [[GTMAppAuthFetcherAuthorization alloc] initWithAuthState:authState];
                    [GTMAppAuthFetcherAuthorization saveAuthorization:authorization toKeychainForName:kKeychainItemName];
                    self.youTubeService.authorizer = authorization;
                    NSLog(@"Youtube got authorization tokens. Access token: %@",
                            authState.lastTokenResponse.accessToken);
                } else {
                    NSLog(@"Youtube authorization error: %@", [error localizedDescription]);
//                                                                   self.authorization = nil;
                }
                if (completion != nil) {
                    completion(authState != nil);
                }
            }];
}

- (BOOL)resumeAuthorizationFlowWithURL:(NSURL *)url {
    BOOL authorized = [self.currentAuthorizationFlow resumeAuthorizationFlowWithURL:url];
    if (authorized) {
        self.currentAuthorizationFlow = nil;
    }
    return authorized;
}
/*
- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController finishedWithAuth:(GTMOAuth2Authentication *)authResult error:(NSError *)error {
    if (error != nil) {
//        [Utils showAlert:@"Authentication Error" message:error.localizedDescription];
        self.youTubeService.authorizer = nil;
    } else {
        self.youTubeService.authorizer = authResult;
    }
}
*/
@end