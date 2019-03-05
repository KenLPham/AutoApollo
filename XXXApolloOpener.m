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

// youtube doesn't open into app (fix: check for youtube link and change then to youtube://[ID])
// youtu.be/
- (id) openURL:(NSURL *)url sender:(NSString *)sender {
    if ([url.host isEqualToString:@"www.reddit.com"] ||
        [url.host isEqualToString:@"reddit.com"] ||
        [url.host isEqualToString:@"m.reddit.com"] ||
        [url.host isEqualToString:@"old.reddit.com"] ||
        [url.host containsString:@".reddit.com"] ||
        [url.path containsString:@"amp.reddit.com"]) {
        
        if ([url.path isEqualToString:@"/"] || [url.path isEqualToString:@""]) {
            return [NSURL URLWithString:@"apollo://"];
        } else if ([url.path containsString:@"amp.reddit.com"]) { // -- v1.0.2 - OK now AMP is supported --
            NSString *path = [url.path stringByRemovingPercentEncoding];
            NSString *ampUrl = [path stringByReplacingOccurrencesOfString:@"/amp/s/amp." withString:@"apollo://"];
            return [NSURL URLWithString:ampUrl];
        } else {
            // narwhal://open-url/%@
            return [NSURL URLWithString:[NSString stringWithFormat:@"apollo://reddit.com%@/?%@", url.path, url.query]];
        }
    }

    if ([url.host isEqualToString:@"opener.hbang.ws"]) {
        NSString *decoded = [url.query stringByRemovingPercentEncoding];
        NSString *trimmed = [decoded stringByReplacingOccurrencesOfString:@"original=" withString:@""];
        NSString *converted = [trimmed stringByReplacingOccurrencesOfString:@" " withString:@""];
        return [NSURL URLWithString:converted];
    }
    return url;
}

@end
