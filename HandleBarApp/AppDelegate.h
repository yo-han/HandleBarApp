//
//  AppDelegate.h
//  HandleBarApp
//
//  Created by Johan Kuijt on 29-12-12.
//  Copyright (c) 2012 Mustacherious. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <ServiceManagement/ServiceManagement.h>

@class Preferences;

@interface AppDelegate : NSObject <NSApplicationDelegate, NSMenuDelegate> {
    
    IBOutlet NSMenu *statusMenu;
    IBOutlet NSMenuItem * startStop;
    IBOutlet NSMenuItem * running;
    IBOutlet NSButton *loginCheck;
    
    NSStatusItem * statusItem;
    NSTimer *updateStatusTimer;
    NSTimer *reSubTimer;
    
    NSString * projectPath;
    NSString * configFilePath;
    NSString * convertScriptUrl;
    NSString * handleBarViewUrl;
    NSString * webserverScriptUrl;
    NSString * reSubScriptUrl;
    
    int viewPid;
}

@property (assign) IBOutlet NSWindow *window;
@property (strong) Preferences *preferences;

-(IBAction)openHandleBar:(id)sender;
- (IBAction)showLog:(id)sender;

@end
