//
// Created by Anton Turko on 2/19/16.
// Copyright (c) 2016 Anton Turko. All rights reserved.
//

#import "YouTubeLiveEvent.h"
#import "GTLRYouTube.h"

@interface YouTubeLiveEvent ()
@property (nonatomic, strong) GTLRYouTube_LiveBroadcast *event;
@end

@implementation YouTubeLiveEvent {

}

- (void)setEvent:(GTLRYouTube_LiveBroadcast *)event {
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
    GTLRDateTime *date = self.event.snippet.actualStartTime ?: self.event.snippet.scheduledStartTime;
    return [dateFormatter stringFromDate:date.date];
}

- (NSString *)liveChatId {
    return self.event.snippet.liveChatId;
}

@end