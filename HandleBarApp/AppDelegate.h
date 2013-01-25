//
//  AppDelegate.h
//  HandleBarApp
//
//  Created by Johan Kuijt on 29-12-12.
//  Copyright (c) 2012 Mustacherious. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <ServiceManagement/ServiceManagement.h>

#import "NSFileManager+DirectoryLocations.h"

#import "MASPreferencesWindowController.h"
#import "PrefIndexViewController.h"
#import "PrefConfigViewController.h"
#import "StartAtLoginController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, NSMenuDelegate> {
    
    IBOutlet NSMenu *statusMenu;
    IBOutlet NSMenuItem * startStop;
    IBOutlet NSMenuItem * running;
    IBOutlet NSButton *loginCheck;
    
    NSStatusItem * statusItem;
    NSTimer *updateStatusTimer;
    
    NSString * projectPath;
    NSString * convertScriptUrl;
    NSString * handleBarViewUrl;
    NSString * webserverScriptUrl;
    
    int viewPid;
}

@property (assign) IBOutlet NSWindow *window;
@property (strong) NSWindowController *preferencesWindow;

-(IBAction)openHandleBar:(id)sender;

@end
