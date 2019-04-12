#import "Headers/LSApplicationWorkspace.h"
#import "Headers/_LSAppLinkPlugIn.h"
#import "Extra/NSString+AutoApollo.h"

// #import "Headers/FBS.h"

%hook LSApplicationWorkspace

- (id)URLOverrideForNewsURL:(id)arg1 {
	NSLog(@"[AutoApollo] URLOverrideForNewsURL");

	return %orig;
}

- (id) URLOverrideForURL:(NSURL*)url {
	NSLog(@"[AutoApollo] URLOverrideForURL %@", url);

	if ([url.host isEqualToString:@"www.reddit.com"] ||
		[url.host isEqualToString:@"reddit.com"] ||
		[url.host isEqualToString:@"m.reddit.com"] ||
		[url.host isEqualToString:@"old.reddit.com"] ||
		[url.host containsString:@".reddit.com"]) {
		NSLog(@"[AutoApollo] Reddit link, redirecting..");

		if ([url.path isEqualToString:@"/"] || [url.path isEqualToString:@""]) {
			return [NSURL URLWithString:@"apollo://"];
		}

		NSURLComponents *apolloUrl = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:YES];
		apolloUrl.scheme = @"apollo";

		return apolloUrl.URL;
	} else if ([url.path containsString:@"amp.reddit.com"]) {
		NSLog(@"[AutoApollo] AMP Reddit link, redirecting..");
		//https://www.google.com/amp/s/amp.reddit.com/r/jailbreak/comments/amce97/discussion_ios_jailbreak_and_tweak_developer/
		NSString *trimmed = [url.path stringByReplacingOccurrencesOfString:@"/amp/s/amp." withString:@"apollo://"];
		return [NSURL URLWithString:trimmed];
	} else if ([url.host isEqualToString:@"reddit.app.link"]) {
		NSDictionary *decoded = [[url query] queryDictionary];
		NSLog(@"[AutoApollo] App Link: %@", [decoded objectForKey:@"base_url"]);

		NSString *base = [decoded objectForKey:@"base_url"];
		NSString *link = [base isEqualToString:@"/"] ? @"apollo://" : [NSString stringWithFormat:@"apollo://reddit.com%@", base];
		return [NSURL URLWithString:link];
	}

	return %orig;
}

- (id) applicationsAvailableForOpeningURL:(id)arg1 {
	NSLog(@"[AutoApollo] applicationsAvailableForOpeningURL");
	return %orig([self URLOverrideForURL:arg1]);
}

- (bool) openURL:(id)arg1 {
	NSLog(@"[AutoApollo] openURL");
	return %orig([self URLOverrideForURL:arg1]);
}

- (bool) openURL:(id)arg1 withOptions:(id)arg2 {
	NSLog(@"[AutoApollo] openURL:withOptions");
	return %orig([self URLOverrideForURL:arg1], arg2);
}

- (bool) openURL:(id)arg1 withOptions:(id)arg2 error:(id*)arg3 {
	NSLog(@"[AutoApollo] openURL:withOptions:error");
	return %orig([self URLOverrideForURL:arg1], arg2, arg3);
}

// Safari

- (void) _sf_openURL:(id)arg1 inApplication:(id)arg2 withOptions:(id)arg3 completionHandler:(id)arg4 {
	NSLog(@"[AutoApollo] _sf_openURL:inApplication");
	%orig([self URLOverrideForURL:arg1], arg2, arg3, arg4);
}

- (void) _sf_openURL:(id)arg1 withOptions:(id)arg2 completionHandler:(id)arg3 {
	NSLog(@"[AutoApollo] _sf_openURL:withOptions");
	%orig([self URLOverrideForURL:arg1], arg2, arg3);
}
%end

// (For App Links) Not working
// %hook FBSystemService

// - (void) activateApplication:(NSString*)bundleId requestID:(unsigned int)requestID options:(FBSOpenApplicationOptions*)options source:(FBSProcessHandle*)source originalSource:(FBSProcessHandle*)originalSource withResult:(id)resultBlock {
// 	NSMutableDictionary<NSString*, id> *realOptions = (NSMutableDictionary*)options.dictionary;
// 	NSString *sourceBundleIdentifier = [source respondsToSelector:@selector(bundleIdentifier)] ? ((FBSProcessHandle*)source).bundleIdentifier : ((BSAuditToken *)source).bundleID;
// 	LSAppLink *appLink = realOptions[@"__AppLink4LS"] ?: realOptions[@"__AppLink"];
// 	NSURL *originalURL = appLink.URL ?: realOptions[@"__PayloadURL"];
// 	// LSAppLinkOpenStrategy openStrategy = LSAppLinkOpenStrategyUnknown;

// 	NSLog(@"[AutoApollo] FBSystemService activateApplication url:%@ source_bundle:%@", [originalURL absoluteString], sourceBundleIdentifier);
// 	%orig;
// }
// %end

// this looks complicated af
// https://github.com/hbang/libopener/blob/master/client/AppLink.x

// %hook _LSAppLinkPlugIn
// + (BOOL) canHandleURLComponents:(NSURLComponents *)urlComponents {
// 	return %orig;
// }

// - (void) getAppLinksWithCompletionHandler:(id)arg1 {
// 	NSURL *appUrl = self.URLComponents.URL;
// 	NSLog(@"[AutoApollo] AppLink %@", [appUrl absoluteString]);

// 	// NSLog(@"[AutoApollo] AppLink");

// //+ (id)_appLinkWithURL:(id)arg1 applicationProxy:(id)arg2 plugIn:(id)arg3;
// 	// LSAppLink *appLink = [%c(LSAppLink) _appLinkWithURL:appUrl]

// 	%orig;
// }
// %end

%ctor {
	@autoreleasepool {
		NSArray *args = [[NSClassFromString(@"NSProcessInfo") processInfo] arguments];
		NSUInteger count = args.count;
		if (count != 0) {
			NSString *executablePath = args[0];
			if (executablePath) {
				NSString *processName = [executablePath lastPathComponent];
				
				BOOL isSpringBoard = [processName isEqualToString:@"SpringBoard"];
				BOOL isApplication = [executablePath rangeOfString:@"/Application/"].location != NSNotFound || [executablePath rangeOfString:@"/Applications/"].location != NSNotFound;

				if (isSpringBoard || isApplication) {
					NSLog(@"[AutoApollo] Injecting into %@", processName);
					%init;
				}
			}
		}
	}
}
