//
//  AppDelegate.m
//  iPodClassiciOS6
//

#import "AppDelegate.h"
#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.viewController = [[ViewController alloc] init];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    
    // Enable Remote Control Events for headphones & background audio control
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    return YES;
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
    if (event.type == UIEventTypeRemoteControl) {
        MusicLibraryManager *manager = [MusicLibraryManager sharedManager];
        switch (event.subtype) {
            case UIEventSubtypeRemoteControlTogglePlayPause:
            case UIEventSubtypeRemoteControlPlay:
            case UIEventSubtypeRemoteControlPause:
                [manager togglePlayPause];
                break;
            case UIEventSubtypeRemoteControlNextTrack:
                [manager nextTrack];
                break;
            case UIEventSubtypeRemoteControlPreviousTrack:
                [manager previousTrack];
                break;
            default:
                break;
        }
    }
}

@end
