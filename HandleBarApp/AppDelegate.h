//
//  AppDelegate.h
//  HandleBarApp
//
//  Created by Johan Kuijt on 29-12-12.
//  Copyright (c) 2012 Mustacherious. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate> {
    
    IBOutlet NSMenu *statusMenu;
    IBOutlet NSMenuItem * startStop;
    IBOutlet NSMenuItem * running;
    
    NSStatusItem * statusItem;
    
    NSString * projectPath;
    NSString * projectScriptUrl;
    NSString * handleBarViewUrl;
}

@property (assign) IBOutlet NSWindow *window;

-(IBAction)openHandleBar:(id)sender;

@end
