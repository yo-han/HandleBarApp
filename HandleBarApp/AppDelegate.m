//
//  AppDelegate.m
//  HandleBarApp
//
//  Created by Johan Kuijt on 29-12-12.
//  Copyright (c) 2012 Mustacherious. All rights reserved.
//

#import "AppDelegate.h"
#import <Python/Python.h>
#import "NSFileManager+Directories.h"

#import "StartAtLoginController.h"
#import "Converter.h"
#import "Util.h"
#import "Preferences.h"

#import "MetaData.h"

@implementation AppDelegate

@synthesize preferences;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self redirectConsoleLog];
    
    StartAtLoginController *loginController = [[StartAtLoginController alloc] initWithIdentifier:@"com.mustacherious.HandleBarHelperApp"];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"HandleBarAutoStart"]) {
        [loginController setStartAtLogin: YES];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HandleBarAutoStart"];
    }
    
    NSFileManager *fm = [NSFileManager defaultManager];
    
    NSString *appSupportPath = [fm applicationSupportFolder];
    NSString *handleBarDir = [projectPath stringByDeletingLastPathComponent];
    NSString *configLinkFile = [NSString stringWithFormat:@"%@/configPath",handleBarDir];
    NSString *dbFilePath = [appSupportPath stringByAppendingPathComponent:@"handleBar.db"];
    
    configFilePath = [appSupportPath stringByAppendingPathComponent:@"config.plist"];
    
    [fm getOrCreatePath:appSupportPath];
    [fm getOrCreatePath:[NSString stringWithFormat:@"%@/media/done",appSupportPath]];
    [fm getOrCreatePath:[NSString stringWithFormat:@"%@/media/failed",appSupportPath]];
    [fm getOrCreatePath:[NSString stringWithFormat:@"%@/media/converted",appSupportPath]];
    [fm getOrCreatePath:[NSString stringWithFormat:@"%@/media/subtitles",appSupportPath]];
    [fm getOrCreatePath:[NSString stringWithFormat:@"%@/media/images",appSupportPath]];
    
    bool b = [fm fileExistsAtPath:dbFilePath];

    if(b == NO) {
        
        NSError *err;
        
        NSString *defaultDBPath = [NSString stringWithFormat:@"%@/app/default/handleBar.db",projectPath];
        NSString *defaultConfigPath = [NSString stringWithFormat:@"%@/app/default/config.plist",projectPath];

        [fm copyItemAtPath:defaultDBPath toPath:dbFilePath error:&err];
        [fm copyItemAtPath:defaultConfigPath toPath:configFilePath error:&err];
        
        NSLog(@"%@",err);
    }

    if([fm fileExistsAtPath:configLinkFile] == NO) {
       
        [appSupportPath writeToFile:configLinkFile atomically:YES encoding:NSUTF8StringEncoding error:NULL];
    }
    
    // Add config file to userDefaults
    [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithContentsOfFile:configFilePath]];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(defaultsChanged:) name:NSUserDefaultsDidChangeNotification object:nil];
    
    //[self startStopConverter:@"start"];
    //[self startStopWebserver:@"start"];
    //[self startReSub];
    
    [[Converter alloc] initWithPaths:[[NSUserDefaults standardUserDefaults] objectForKey:@"MediaPaths"]];
}

- (void)defaultsChanged:(NSNotification *)notification {
    
    // Get the user defaults
    NSUserDefaults *defaults = (NSUserDefaults *)[notification object];
    NSDictionary *configFile = [NSDictionary dictionaryWithContentsOfFile:configFilePath];
    NSMutableDictionary *config = [NSMutableDictionary dictionaryWithDictionary:[configFile copy]];
    
    for(id key in configFile) {
        if([defaults objectForKey:key]) {
            [config setObject:[defaults objectForKey:key] forKey:key];
        }
    }
    
    [config writeToFile:configFilePath atomically:YES];
}

- (void) redirectConsoleLog
{
    NSString *currentPath = [[NSBundle mainBundle] bundlePath];
    
    if ([currentPath rangeOfString:@"Debug"].location == NSNotFound) {
        
        NSString *logPath = @"/tmp/handleBarApp.log";
        freopen([logPath fileSystemRepresentation],"a+",stderr);
    }
}

-(void)awakeFromNib{
    
    NSImage *icon = [NSImage imageNamed:@"handleBarIcon.png"];
    [icon setSize:CGSizeMake(24, 12)];
    
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [statusItem setMenu:statusMenu];
    [statusItem setImage:icon];
    [statusItem setHighlightMode:YES];   
    
    NSString * path;
	path = [[NSBundle mainBundle] bundlePath];
	projectPath = [path stringByAppendingPathComponent:@"Contents/Resources/HandleBar"];
    convertScriptUrl = [projectPath stringByAppendingPathComponent:@"/convert.py"];
    webserverScriptUrl = [projectPath stringByAppendingPathComponent:@"/web.py"];
    reSubScriptUrl = [projectPath stringByAppendingPathComponent:@"/reSub.py"];

	// Handle basic error case:
	if (convertScriptUrl == nil) {
        NSLog(@"No python file found in: %@", convertScriptUrl);
		exit(-1);
	}
}

- (void)converterIsRunning {
    
    NSString *pidConverter = [NSString stringWithContentsOfFile:@"/tmp/convert-daemon.pid"	encoding:NSUTF8StringEncoding error:nil];
    
    if(pidConverter == nil) {
        [running setTitle:@"Not running"];
        [startStop setTitle:@"Start"];
        [startStop setTag:0];
    } else {
        [running setTitle:@"Idle"];
        [startStop setTitle:@"Stop"];
        [startStop setTag:1];
    }
    
    NSString *convertStatus = [NSString stringWithContentsOfFile:@"/tmp/handleBarCurrentStatus"	encoding:NSUTF8StringEncoding error:nil];
    
    if(convertStatus != nil)
        [running setTitle:convertStatus];
    
    [statusMenu update];
}

- (void)startStopWebserver:(NSString *)action {
    
    NSString *cmd = @"/usr/bin/python";
    NSArray *args = [NSArray arrayWithObjects:webserverScriptUrl,action, nil];
    
    [Util executeCommand:cmd args:args];
}

- (void)startStopConverter:(NSString *)action {
    
    NSString *cmd = @"/usr/bin/python";
    NSArray *args = [NSArray arrayWithObjects:convertScriptUrl,action, nil];
    
    [Util executeCommand:cmd args:args];
    
    if([action isEqual: @"start"]) {
        
        updateStatusTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                          target:self
                                                        selector:@selector(converterIsRunning)
                                                        userInfo:nil
                                                         repeats:YES];
        
        [[NSRunLoop currentRunLoop] addTimer:updateStatusTimer forMode:NSEventTrackingRunLoopMode];
        
    } else {
        
        [updateStatusTimer invalidate];
    }
}

- (IBAction)startStop:(id)sender {
    
    NSMenuItem *s = (NSMenuItem *) sender;
    if(s.tag == 0) {
        
        [self startStopConverter:@"start"];
        
    } else {
        
        [self startStopConverter:@"stop"];
    }
}

- (void)startResubTimer {
    
    [NSTimer scheduledTimerWithTimeInterval:3600
                                     target:self
                                   selector:@selector(startReSub)
                                   userInfo:nil
                                    repeats:YES];
}

- (void)startReSub {

    NSString *cmd = @"/usr/bin/python";
    NSArray *args = [NSArray arrayWithObjects:reSubScriptUrl, nil];
    
    [Util executeCommand:cmd args:args];
    
    [self startResubTimer];
}

-(IBAction)openHandleBar:(id)sender {
       
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:handleBarViewUrl]];
}

- (IBAction)displayPreferences:(id)sender {
    
    preferences = [[Preferences alloc] init];
    [preferences showPreferenceWindow];
}

- (IBAction)showLog:(id)sender {
    
    [[NSWorkspace sharedWorkspace] openFile:@"/tmp/handleBarError.log"];
}

- (void)applicationWillTerminate:(NSNotification *)notification {
    
    [self startStopConverter:@"stop"];
    [self startStopWebserver:@"stop"];
}

@end
