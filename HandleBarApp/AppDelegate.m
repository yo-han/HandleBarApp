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
    StartAtLoginController *loginController = [[StartAtLoginController alloc] initWithIdentifier:@"com.mustacherious.HandleBarHelperApp"];
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"HandleBarAutoStart"]) {
        [loginController setStartAtLogin: YES];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HandleBarAutoStart"];
    }
    
    NSString *appSupportPath = [self applicationSupportFolder];
    NSString *handleBarDir = [projectPath stringByDeletingLastPathComponent];
    NSString *configLinkFile = [NSString stringWithFormat:@"%@/configPath",handleBarDir];
    NSString *dbFilePath = [appSupportPath stringByAppendingPathComponent:@"handleBar.db"];
    
    NSString *dirMediaDone = [NSString stringWithFormat:@"%@/media/done",appSupportPath];
    NSString *dirMediaFailed = [NSString stringWithFormat:@"%@/media/failed",appSupportPath];
    
    [self createDir:appSupportPath];
    [self createDir:dirMediaDone];
    [self createDir:dirMediaFailed];
    
    bool b = [[NSFileManager defaultManager] fileExistsAtPath:dbFilePath];

    if(b == NO) {
        
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        
        NSString *defaultDBPath = [NSString stringWithFormat:@"%@/handleBar.db",handleBarDir];
        NSString *defaultConfigPath = [NSString stringWithFormat:@"%@/config.ini",handleBarDir];
        NSString *configFilePath = [appSupportPath stringByAppendingPathComponent:@"config.ini"];
        
        [fileManager copyItemAtPath:defaultDBPath toPath:dbFilePath error:NULL];
        [fileManager copyItemAtPath:defaultConfigPath toPath:configFilePath error:NULL];
    }

    if([[NSFileManager defaultManager] fileExistsAtPath:configLinkFile] == NO) {
                
        [appSupportPath writeToFile:configLinkFile atomically:YES encoding:NSUTF8StringEncoding error:NULL];
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
    return [basePath
            stringByAppendingPathComponent:@"HandleBarApp"];
}

-(void)awakeFromNib{
    
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [statusItem setMenu:statusMenu];
    [statusItem setTitle:@"Status"];
    [statusItem setHighlightMode:YES];   
    
    NSString * path;
	path = [[NSBundle mainBundle] bundlePath];
	projectPath = [path stringByAppendingPathComponent:@"Contents/Resources/HandleBar/run.py"];
    
    projectScriptUrl = [NSString stringWithContentsOfFile:projectPath	encoding:NSUTF8StringEncoding error:nil];

	// Handle basic error case:
	if (projectScriptUrl == nil) {
        NSLog(@"No python file found in: %@", projectScriptUrl);
		exit(-1);
	}
    
    [self startAll];
    
    [NSTimer scheduledTimerWithTimeInterval:1
                                     target:self
                                   selector:@selector(converterIsRunning)
                                   userInfo:nil
                                    repeats:YES];
}

- (void)converterIsRunning {
    
    NSString *convertPid = [NSString stringWithFormat:@"%@/../../../../convert-daemon.pid",[projectPath stringByDeletingLastPathComponent]];
    NSString *pidConverter = [NSString stringWithContentsOfFile:convertPid	encoding:NSUTF8StringEncoding error:nil];
    
    if(pidConverter == nil) {
        [running setTitle:@"Not running"];
        [startStop setTitle:@"Start"];
        [startStop setTag:0];
    } else {
        [running setTitle:@"Running"];
        [startStop setTitle:@"Stop"];
        [startStop setTag:1];
    }
}

- (void)startAll {

    PyObject* evalModule;
    PyObject* evalDict;
    PyObject* evalVal;
    char* retString;
    
    PyRun_SimpleString([projectScriptUrl UTF8String]);
    
    evalModule = PyImport_AddModule( (char*)"__main__" );
    evalDict = PyModule_GetDict( evalModule );
    evalVal = PyDict_GetItemString( evalDict, "currentHost" );
    
    if( evalVal == NULL ) {
        PyErr_Print();
        //exit( 1 );
        
    } else {
        
        retString = PyString_AsString( evalVal );
        handleBarViewUrl = [NSString stringWithFormat:@"%s", retString];
    }
}

- (void)startAgain {
    
    PyRun_SimpleString([projectScriptUrl UTF8String]);
}

- (void)stopAllProccesses {
    
    NSString *pidServer = [NSString stringWithContentsOfFile:@"/tmp/handleBarServer.pid" encoding:NSUTF8StringEncoding error:nil];
    NSString *pidConverter = [NSString stringWithContentsOfFile:@"/tmp/convert-daemon.pid" encoding:NSUTF8StringEncoding error:nil];

    kill( [pidServer intValue], SIGKILL );
    kill( [pidConverter intValue], SIGKILL );
    
    [[NSFileManager defaultManager] removeItemAtPath:@"/tmp/convert-daemon.pid" error:nil];
}

- (IBAction)startStop:(id)sender {
    
    NSMenuItem *s = (NSMenuItem *) sender;
    if(s.tag == 0) {
        
        [self startAgain];
        
    } else {
        
        [self stopAllProccesses];
    }
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

- (void)applicationWillTerminate:(NSNotification *)notification {
    
    [self stopAllProccesses];
}

@end
