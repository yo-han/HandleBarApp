//
//  AppDelegate.m
//  HandleBarHelperApp
//
//  Created by Johan Kuijt on 30-12-12.
//  Copyright (c) 2012 Mustacherious. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationWillFinishLaunching:(NSNotification *)aNotification
{
    NSString *appPath = [[[[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent] stringByDeletingLastPathComponent] stringByDeletingLastPathComponent] stringByDeletingLastPathComponent];
    // This string takes you from MyGreat.App/Contents/Library/LoginItems/MyHelper.app to MyGreat.App This is an obnoxious but dynamic way to do this since that specific Subpath is required
    NSString *binaryPath = [[NSBundle bundleWithPath:appPath] executablePath]; // This gets the binary executable within your main application
    [[NSWorkspace sharedWorkspace] launchApplication:binaryPath];
    [NSApp terminate:nil];
}

@end
