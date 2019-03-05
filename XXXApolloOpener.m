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
    if ([url.host isEqualToString:@"www.reddit.com"] ||
        [url.host isEqualToString:@"reddit.com"] ||
        [url.host isEqualToString:@"m.reddit.com"] ||
        [url.host isEqualToString:@"old.reddit.com"] ||
        [url.host containsString:@".reddit.com"]) {
        
        if ([url.path isEqualToString:@"/"] || [url.path isEqualToString:@""]) {
            return [NSURL URLWithString:@"apollo://"];
        } else {
            return [NSURL URLWithString:[NSString stringWithFormat:@"apollo://reddit.com%@/?%@", url.path, url.query]];
        }
    } else if ([url.path containsString:@"amp.reddit.com"]) { // -- v1.0.1 - Actually added amp support --
        NSString *path = [url.path stringByRemovingPercentEncoding];
        NSString *ampUrl = [path stringByReplacingOccurrencesOfString:@"amp/s/amp." withString:@"apollo://"];
        return [NSURL URLWithString:ampUrl];
    }

    // -- v1.0.1 - Made it so other links actuall opened
    NSString *decoded = [url.absoluteString stringByRemovingPercentEncoding];
    NSString *trimmed = [decoded stringByReplacingOccurrencesOfString:@"http://opener.hbang.ws/_opener_app_link_hax_?original=" withString:@""];
    NSString *converted = [trimmed stringByReplacingOccurrencesOfString:@" " withString:@""];
    return [NSURL URLWithString:converted];
}

@end
