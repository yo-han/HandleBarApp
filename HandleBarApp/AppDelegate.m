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
#import "StatusItemView.h"

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

    [self startStopWebserver:@"start"];
    
    Converter *cnv = [[Converter alloc] initWithPaths:[[NSUserDefaults standardUserDefaults] objectForKey:@"MediaPaths"]];
    
    if(!cnv)
        return;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(converterIsRunning:) name:@"updateConvertETA" object:nil];

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
    
    [self updateStatusMenu:nil];
    
    NSString * path;
	path = [[NSBundle mainBundle] bundlePath];
	projectPath = [path stringByAppendingPathComponent:@"Contents/Resources/HandleBar"];
    webserverScriptUrl = [projectPath stringByAppendingPathComponent:@"/web.py"];
    
    /*
     updateStatusTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                         target:self
                                                       selector:@selector(converterIsRunning)
                                                       userInfo:nil
                                                        repeats:YES];
    
    [[NSRunLoop currentRunLoop] addTimer:updateStatusTimer forMode:NSEventTrackingRunLoopMode];*/

}

- (void)updateStatusMenu:(NSString *)eta {
    
    float width = 30.0;
    float height = [[NSStatusBar systemStatusBar] thickness];
    
    if(eta != nil) 
        width = 110.0;
    
    NSRect viewFrame = NSMakeRect(0, 0, width, height);
    
    statusItemView = [[StatusItemView alloc] initWithFrame:viewFrame controller:self];
    statusItemView.statusItem = statusItem;
    [statusItemView setTitle:eta];
    
    [statusItem setView:statusItemView];
        
    [statusMenu update];
}

- (void)converterIsRunning:(NSNotification *)notification {

    NSString *string = [NSString stringWithContentsOfFile:@"/tmp/handleBarEncode.status" encoding:NSUTF8StringEncoding error:NULL];
    
    NSRange textRange = [string rangeOfString:@"ETA "];
    if(textRange.location != NSNotFound) {
        NSRange r = NSMakeRange(textRange.location + 4, 9);
        string = [string substringWithRange:r];
    } else {
        string = nil;
    }
    
    [self updateStatusMenu:string];
}

- (void)startStopWebserver:(NSString *)action {
    
    NSString *cmd = @"/usr/bin/python";
    NSArray *args = [NSArray arrayWithObjects:webserverScriptUrl,action, nil];
    
    [Util executeCommand:cmd args:args notifyStdOut:NO];
}

-(IBAction)openHandleBar:(id)sender {

    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://localhost:8082"]];
}

- (IBAction)displayPreferences:(id)sender {
    
    preferences = [[Preferences alloc] init];
    [preferences showPreferenceWindow];
}

- (IBAction)showLog:(id)sender {
    
    [[NSWorkspace sharedWorkspace] openFile:@"/tmp/handleBarError.log"];
}

- (void)applicationWillTerminate:(NSNotification *)notification {
    
    [self startStopWebserver:@"stop"];
}

@end
