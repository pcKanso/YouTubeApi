//
// Created by Anton Turko on 2/26/16.
// Copyright (c) 2016 Anton Turko. All rights reserved.
//

#import "YouTubeApi+Comments.h"
#import "GTLQueryYouTube.h"
#import "GTLYouTubeLiveChatMessageListResponse.h"
#import "YouTubeMessage.h"
#import "GTLYouTubeLiveChatMessage.h"
#import "GTLYouTubeLiveChatMessageSnippet.h"
#import "GTLYouTubeLiveChatMessageAuthorDetails.h"


@implementation YouTubeApi (Comments)

- (void)getCommetnsList:(NSString *)chatId withCompletion:(void (^)(NSArray *))completion {
//    GTLQueryYouTube *query = [GTLQueryYouTube quer]
    GTLQueryYouTube *query = [GTLQueryYouTube queryForLiveChatMessagesListWithLiveChatId:chatId part:@"id, snippet"];
    [self.youTubeService executeQuery:query completionHandler:^(GTLServiceTicket *ticket, GTLYouTubeLiveChatMessageListResponse *response, NSError *error) {

        if (error == nil) {
            NSMutableArray *array = [NSMutableArray new];
            for (GTLYouTubeLiveChatMessage *message in response.items) {
                YouTubeMessage *youTubeMessage = [YouTubeMessage new];
                youTubeMessage.text = message.snippet.displayMessage;
                youTubeMessage.published = message.snippet.publishedAt.date;
                youTubeMessage.authorName = message.authorDetails.displayName;
                youTubeMessage.profileImageUrl = message.authorDetails.profileImageUrl;
                [array addObject:youTubeMessage];
            }
            completion(array);
        }
    }];
}

@end