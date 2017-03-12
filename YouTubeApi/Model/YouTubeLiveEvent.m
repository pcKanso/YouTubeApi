//
// Created by Anton Turko on 2/19/16.
// Copyright (c) 2016 Anton Turko. All rights reserved.
//

#import <GoogleAPIClient/GTLYouTubeLiveBroadcast.h>
#import <GoogleAPIClient/GTLYouTubeLiveBroadcastSnippet.h>
#import <GoogleAPIClient/GTLYouTubeThumbnailDetails.h>
#import <GoogleAPIClient/GTLYouTubeThumbnail.h>
#import <GoogleAPIClient/GTLYouTubeLiveBroadcastContentDetails.h>
#import "YouTubeLiveEvent.h"

@interface YouTubeLiveEvent ()
@property (nonatomic, strong) GTLYouTubeLiveBroadcast *event;
@end

@implementation YouTubeLiveEvent {

}

- (void)setEvent:(GTLYouTubeLiveBroadcast *)event {
    _event = event;
}

- (NSString *)getIdentifier {
    return self.event.identifier;
}

- (NSString *)getTitle {
    return self.event.snippet.title;
}

- (NSString *) getThumbUrl {
    NSString *url = self.event.snippet.thumbnails.medium.url;
//    if ([url rangeOfString:@"//"].length != 0) {
//        url = [@"http:" stringByAppendingPathComponent:url];
//    }
    return url;
}

- (NSString *)getWatchUri {
    return [@"http://www.youtube.com/watch?v=" stringByAppendingPathComponent:self.getIdentifier];
}

- (NSString *)streamId {
    return self.event.contentDetails.boundStreamId;
}

- (NSString *)startTime {
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    GTLDateTime *date = self.event.snippet.actualStartTime ?: self.event.snippet.scheduledStartTime;
    return [dateFormatter stringFromDate:date.date];
}


@end