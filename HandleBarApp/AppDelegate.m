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
    
    NSString *pidConverter = [NSString stringWithContentsOfFile:@"/tmp/convert-daemon.pid"	encoding:NSUTF8StringEncoding error:nil];
    
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

    NSString *pidServer = [NSString stringWithContentsOfFile:@"/tmp/handleBarServer.pid"	encoding:NSUTF8StringEncoding error:nil];
    NSString *pidConverter = [NSString stringWithContentsOfFile:@"/tmp/convert-daemon.pid"	encoding:NSUTF8StringEncoding error:nil];
    
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

- (void)applicationWillTerminate:(NSNotification *)notification {
    
    [self stopAllProccesses];
}

@end
