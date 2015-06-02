//
//  SwitchClose.xm
//  SwitchClose
//
//  Created by Sirifl0w on 18.07.2014.
//  Copyright (c) 2014 Sirifl0w. All rights reserved.
//

#import <UIKit/UIKit.h>

#define SWITCHCLOSE_PREFS @"var/mobile/Library/Preferences/com.sirifl0w.switchclose.plist"
#define REDUCEMOTION_PREFS @"var/mobile/Library/Preferences/com.apple.Accessibility.plist"

@interface SBAppSwitcherController
-(void)_quitAppWithDisplayItem:(id)arg1;
// custom methods
- (void)_dismissAppSwitcher;
@end

@interface SBUIController
+ (id)sharedInstance;
- (void)dismissSwitcherAnimated:(BOOL)arg1;
@end

static BOOL SCEnabled = YES;
static BOOL RMEnabled = nil;
static NSDictionary *SCPrefs;
static NSDictionary *RMPrefs;

static void loadPrefs() {

	SCPrefs = [[NSDictionary alloc] initWithContentsOfFile:SWITCHCLOSE_PREFS];
	SCEnabled = [SCPrefs objectForKey:@"SC_Enabled"] == nil ? YES : [[SCPrefs objectForKey:@"SC_Enabled"] boolValue];
	[SCPrefs release];

	RMPrefs = [[NSDictionary alloc] initWithContentsOfFile:REDUCEMOTION_PREFS];
	RMEnabled = [RMPrefs objectForKey:@"ReduceMotionEnabled"] == nil ? YES : [[RMPrefs objectForKey:@"ReduceMotionEnabled"] boolValue];
	[RMPrefs release];

}

%hook SBAppSwitcherController

-(void)_quitAppWithDisplayItem:(id)arg1 {

	%orig();
	loadPrefs();

	NSMutableArray *appList = MSHookIvar<NSMutableArray *>(self, "_appList_use_block_accessor");
	NSUInteger appCount = appList.count;

	if ((appCount == 1) && SCEnabled) {
		if (RMEnabled) {
			[NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(_dismissAppSwitcher) userInfo:nil repeats:NO];
		} else {
			[NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(_dismissAppSwitcher) userInfo:nil repeats:NO];
		}
	}
}

%new
- (void)_dismissAppSwitcher {
	[[%c(SBUIController) sharedInstance] dismissSwitcherAnimated:YES];
}
%end

%ctor {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    %init;
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, CFSTR("com.sirifl0w.switchclose.settingschanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);
    loadPrefs();
    [pool drain];
}
