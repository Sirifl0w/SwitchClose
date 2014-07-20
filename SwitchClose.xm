//
//  SwitchClose.xm
//  SwitchClose
//
//  Created by Sirifl0w on 18.07.2014.
//  Copyright (c) 2014 Sirifl0w. All rights reserved.
//

#import <UIKit/UIKit.h>

#define SWITCHCLOSE_PREFS @"var/mobile/Library/Preferences/com.sirifl0w.switchclose.plist"

@interface SBAppSliderController : UIViewController 
{}
@property(readonly, nonatomic) NSArray *applicationList;
- (void)_quitAppAtIndex:(unsigned int)arg1;
@end

@interface SBUIController : NSObject

+ (id)sharedInstance;
- (void)dismissSwitcherAnimated:(BOOL)arg1;

@end

static BOOL SCEnabled = YES;

%hook SBAppSliderController

- (void)_quitAppAtIndex:(unsigned int)arg1 {

	%orig();

	if (([[self applicationList] count] == 1) && SCEnabled) {
		[NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(_dismissAppSwitcher) userInfo:nil repeats:NO];
	}
}

%new

- (void)_dismissAppSwitcher {

[[%c(SBUIController) sharedInstance] dismissSwitcherAnimated:YES];

}

%end

static void loadPrefs() {

NSDictionary *prefs = [[NSDictionary alloc] initWithContentsOfFile:SWITCHCLOSE_PREFS];
SCEnabled = [prefs objectForKey:@"SC_Enabled"] == nil ? YES : [[prefs objectForKey:@"SC_Enabled"] boolValue];
[prefs release];

}

%ctor {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    %init;
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, CFSTR("com.sirifl0w.switchclose.settingschanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);
    loadPrefs();
    [pool drain];
}
