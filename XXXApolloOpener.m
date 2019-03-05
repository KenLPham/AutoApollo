#import "XXXApolloOpener.h"

@implementation XXXApolloOpener

- (instancetype)init {
    self = [super init];

    if (self) {
        self.name = @"Auto Apollo";
        self.identifier = @"com.kayfam.autoapollo";
    }

    return self;
}

- (id) openURL:(NSURL *)url sender:(NSString *)sender {
    // issue: amp is being a bitch
    if ([url.path containsString:@"amp.reddit.com"]) {
        NSString *path = [url.path stringByRemovingPercentEncoding];
        NSString *ampUrl = [path stringByReplacingOccurrencesOfString:@"amp/s/amp." withString:@"apollo://"];
        return [NSURL URLWithString:ampUrl];
    } else if ([url.host isEqualToString:@"www.reddit.com"] ||
        [url.host isEqualToString:@"reddit.com"] ||
        [url.host isEqualToString:@"m.reddit.com"] ||
        [url.host isEqualToString:@"old.reddit.com"] ||
        [url.host containsString:@".reddit.com"]) {
        
        if ([url.path isEqualToString:@"/"] || [url.path isEqualToString:@""]) {
            return [NSURL URLWithString:@"apollo://"];
        } else {
            return [NSURL URLWithString:[NSString stringWithFormat:@"apollo://reddit.com%@/?%@", url.path, url.query]];
        }
    // -- v1.0.3 - Should fix opening links in safari when openning browsers, should still support phone calls
    } else if ([url.scheme isEqualToString:@"http"] || [url.scheme isEqualToString:@"https"]) {
        if ([url.host isEqualToString:@"opener.hbang.ws"]) {
            NSString *decoded = [url.query stringByRemovingPercentEncoding];
            NSString *trimmed = [decoded stringByReplacingOccurrencesOfString:@"original=" withString:@""];
            NSString *converted = [trimmed stringByReplacingOccurrencesOfString:@" " withString:@""];
            return [NSURL URLWithString:converted];
        } else if ([url.host isEqualToString:@"youtu.be"]) { // -- v1.0.3 - fix youtube opening in safari --
            NSString *videoId = [url.path stringByRemovingPercentEncoding];
            return [NSURL URLWithString:[NSString stringWithFormat:@"youtube://%@", videoId]];
        } else return nil; // Stops urls from opening in Safari
    } else {
        NSString *decoded = [url.absoluteString stringByRemovingPercentEncoding];
        NSString *converted = [decoded stringByReplacingOccurrencesOfString:@" " withString:@""];
        return [NSURL URLWithString:converted];
    }
}

@end
