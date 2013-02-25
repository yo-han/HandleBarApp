//
//  AppDelegate.m
//  HandleBarApp
//
//  Created by Johan Kuijt on 29-12-12.
//  Copyright (c) 2012 Mustacherious. All rights reserved.
//

#import "AppDelegate.h"
#import <Python/Python.h>

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self redirectConsoleLogToDocumentFolder];
    
    StartAtLoginController *loginController = [[StartAtLoginController alloc] initWithIdentifier:@"com.mustacherious.HandleBarHelperApp"];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"HandleBarAutoStart"]) {
        [loginController setStartAtLogin: YES];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HandleBarAutoStart"];
    }
    
    NSString *appSupportPath = [self applicationSupportFolder];
    NSString *handleBarDir = [projectPath stringByDeletingLastPathComponent];
    NSString *configLinkFile = [NSString stringWithFormat:@"%@/configPath",handleBarDir];
    NSString *dbFilePath = [appSupportPath stringByAppendingPathComponent:@"handleBar.db"];
    NSString *configFilePath = [appSupportPath stringByAppendingPathComponent:@"config.ini"];
    
    NSString *dirMediaDone = [NSString stringWithFormat:@"%@/media/done",appSupportPath];
    NSString *dirMediaFailed = [NSString stringWithFormat:@"%@/media/failed",appSupportPath];
    NSString *dirMediaConverted = [NSString stringWithFormat:@"%@/media/converted",appSupportPath];
    NSString *dirMediaSubtitles = [NSString stringWithFormat:@"%@/media/subtitles",appSupportPath];
    NSString *dirMediaImages = [NSString stringWithFormat:@"%@/media/images",appSupportPath];
    
    [self createDir:appSupportPath];
    [self createDir:dirMediaDone];
    [self createDir:dirMediaFailed];
    [self createDir:dirMediaConverted];
    [self createDir:dirMediaSubtitles];
    [self createDir:dirMediaImages];
    
    bool b = [[NSFileManager defaultManager] fileExistsAtPath:dbFilePath];

    if(b == NO) {
        
        NSError *err;
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        
        NSString *defaultDBPath = [NSString stringWithFormat:@"%@/app/default/handleBar.db",handleBarDir];
        NSString *defaultConfigPath = [NSString stringWithFormat:@"%@/app/default/config.ini",handleBarDir];
                
        [fileManager copyItemAtPath:defaultDBPath toPath:dbFilePath error:&err];
        [fileManager copyItemAtPath:defaultConfigPath toPath:configFilePath error:&err];
        
        NSLog(@"%@",err);
    }

    if([[NSFileManager defaultManager] fileExistsAtPath:configLinkFile] == NO) {
       
        [appSupportPath writeToFile:configLinkFile atomically:YES encoding:NSUTF8StringEncoding error:NULL];
    }
    
    [self startStopConverter:@"start"];
    [self startStopWebserver:@"start"];
    [self startReSub];
}

- (void) redirectConsoleLogToDocumentFolder
{
    NSString *currentPath = [[NSBundle mainBundle] bundlePath];
    
    if ([currentPath rangeOfString:@"Debug"].location == NSNotFound) {
        
        NSString *logPath = @"/tmp/handleBarApp.log";
        freopen([logPath fileSystemRepresentation],"a+",stderr);
    }
}

- (void)createDir:(NSString *)dir {
    
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    
    if(![fileManager fileExistsAtPath:dir])
        if(![fileManager createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:NULL])
            NSLog(@"Error: Create folder failed %@", dir);
}

- (NSString *)applicationSupportFolder {
    
    NSArray *paths =
    NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory,
                                        NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:
                                                0] : NSTemporaryDirectory();
    NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
    
    return [basePath
            stringByAppendingPathComponent:appName];
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
    
    [self executeCommand:cmd args:args];
}

- (void)startStopConverter:(NSString *)action {
    
    NSString *cmd = @"/usr/bin/python";
    NSArray *args = [NSArray arrayWithObjects:convertScriptUrl,action, nil];
    
    [self executeCommand:cmd args:args];
    
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
    
    [self executeCommand:cmd args:args];
    
    [self startResubTimer];
}

-(IBAction)openHandleBar:(id)sender {
       
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:handleBarViewUrl]];
}

- (IBAction)displayPreferences:(id)sender {
    if(_preferencesWindow == nil){
        NSViewController *prefIndexViewController = [[PrefIndexViewController alloc] initWithNibName:@"PrefIndexViewController" bundle:[NSBundle mainBundle]];
        NSViewController *prefConfigViewController = [[PrefConfigViewController alloc] initWithNibName:@"PrefConfigViewController" bundle:[NSBundle mainBundle]];
        NSArray *views = [NSArray arrayWithObjects:prefIndexViewController, prefConfigViewController, nil];
        NSString *title = NSLocalizedString(@"Preferences", @"Common title for Preferences window");
        _preferencesWindow = [[MASPreferencesWindowController alloc] initWithViewControllers:views title:title];
    }
    [self.preferencesWindow showWindow:self];
    [self.preferencesWindow.window setLevel: NSStatusWindowLevel];
}

-(int)executeCommand:(NSString *)cmd args:(NSArray *)arguments {
    
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath: cmd];
    [task setArguments: arguments];
    
    NSPipe *pipe = [NSPipe pipe];
    [task setStandardOutput: pipe];
    
    NSFileHandle *file = [pipe fileHandleForReading];
    
    [task launch];

    NSData *data = [file readDataToEndOfFile];
    
    NSString *string = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    
    //NSLog(@"%@", arguments);
    NSLog(@"%@",string);
    NSLog(@"%d", task.processIdentifier);
    
    return task.processIdentifier;
}

- (IBAction)showLog:(id)sender {
    
    [[NSWorkspace sharedWorkspace] openFile:@"/tmp/handleBarError.log"];
}

- (void)applicationWillTerminate:(NSNotification *)notification {
    
    [self startStopConverter:@"stop"];
    [self startStopWebserver:@"stop"];
}

@end
