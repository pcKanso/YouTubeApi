//
// Created by Anton Turko on 2/26/16.
// Copyright (c) 2016 Anton Turko. All rights reserved.
//

#import <GoogleAPIClientForREST/GTLRYouTube.h>
#import "YouTubeApi+Comments.h"
#import "YouTubeComment.h"


@implementation YouTubeApi (Comments)


- (void)getCommentsList:(NSString *)chatId withPageToken:(NSString *)pageToken withCompletion:(void(^)(NSArray *, NSString *, NSNumber *))completion {
    GTLRYouTubeQuery_LiveChatMessagesList *query = [GTLRYouTubeQuery_LiveChatMessagesList queryWithLiveChatId:chatId part:@"id, snippet, authorDetails"];
    if (pageToken != nil) {
        query.pageToken = pageToken;
    }
    [self.youTubeService executeQuery:query completionHandler:^(GTLRServiceTicket *ticket, GTLRYouTube_LiveChatMessageListResponse *response, NSError *error) {
        if (completion == nil) {
            return;
        }
        if (error == nil) {
            NSMutableArray *array = [NSMutableArray new];
            for (GTLRYouTube_LiveChatMessage *message in response.items) {
                YouTubeComment *youTubeMessage = [YouTubeComment new];
                youTubeMessage.text = message.snippet.displayMessage;
                youTubeMessage.published = message.snippet.publishedAt.date;
                youTubeMessage.authorName = message.authorDetails.displayName;
                youTubeMessage.profileImageUrl = message.authorDetails.profileImageUrl;
                [array addObject:youTubeMessage];
            }
            completion(array, response.nextPageToken, response.pollingIntervalMillis);
        } else {
            completion(nil, nil, nil);
        }
    }];
}


@end