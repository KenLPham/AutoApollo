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

- (id)openURL:(NSURL *)url sender:(NSString *)sender {
	
    // -- v1.0.0 - Added amp support --
    if ([url.host isEqualToString:@"www.reddit.com"] ||
        [url.host isEqualToString:@"reddit.com"] ||
        [url.host isEqualToString:@"m.reddit.com"] ||
        [url.host isEqualToString:@"old.reddit.com"] ||
        [url.host containsString:@".reddit.com"] ||
        [url.path containsString:@"amp.reddit.com"]) {
        
        if ([url.path isEqualToString:@"/"] || [url.path isEqualToString:@""]) {
            return [NSURL URLWithString:@"apollo://"];
        } else {
            return [NSURL URLWithString:[NSString stringWithFormat:@"apollo://reddit.com%@/?%@", url.path, url.query]];
        }
    }

    return nil;
}

@end
