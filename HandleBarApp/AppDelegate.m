//
//  AppDelegate.m
//  HandleBarApp
//
//  Created by Johan Kuijt on 29-12-12.
//  Copyright (c) 2012 Mustacherious. All rights reserved.
//

#import "AppDelegate.h"
#import "NSFileManager+Directories.h"
#import "Converter.h"
#import "Util.h"
#import "Preferences.h"
#import "StatusItemView.h"

#import "MetaData.h"
#import "AppIcon.h"

@implementation AppDelegate

@synthesize preferences;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self redirectConsoleLog];
  
    NSFileManager *fm = [NSFileManager defaultManager];
    
    NSString *appSupportPath = [fm applicationSupportFolder];
    NSString *configLinkFile = [NSString stringWithFormat:@"%@/configPath",projectPath];
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
        
        NSString *defaultDBPath = [NSString stringWithFormat:@"%@/handleBar.db",projectPath];
        NSString *defaultConfigPath = [NSString stringWithFormat:@"%@/config.plist",projectPath];

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
    
    cnv = [[Converter alloc] initWithPaths:[[NSUserDefaults standardUserDefaults] objectForKey:@"MediaPaths"]];
    
    if(!cnv) {
        NSLog(@"Converter failed to load");
        return;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(converterIsRunning:) name:@"updateConvertETA" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateQueueMenu:) name:@"updateQueueMenu" object:nil];
    
    NSLog(@"Loaded and ready to go.");
}

- (void)reloadConverter {
    
    [cnv stopEventListener];
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithContentsOfFile:configFilePath]];
    cnv = [[Converter alloc] initWithPaths:[[NSUserDefaults standardUserDefaults] objectForKey:@"MediaPaths"]];
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

-(void)awakeFromNib {
    
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [statusItem setMenu:statusMenu];
    
    statusItemViewSmall = [[StatusItemView alloc] initWithFrame:NSMakeRect(0, 0, 30.0, [[NSStatusBar systemStatusBar] thickness]) controller:self];
    statusItemViewLarge = [[StatusItemView alloc] initWithFrame:NSMakeRect(0, 0, 110.0, [[NSStatusBar systemStatusBar] thickness]) controller:self];
    
    [self updateStatusMenu:nil];
    
    NSString * path;
	path = [[NSBundle mainBundle] bundlePath];
	projectPath = [path stringByAppendingPathComponent:@"Contents/Resources"];
}

- (void)updateStatusMenu:(NSString *)eta {
    
    BOOL large = NO;
    if(eta != nil) 
        large = YES;
    
    @autoreleasepool {
              
        statusItemView = (large) ? statusItemViewLarge : statusItemViewSmall;
        
        statusItemView.statusItem = statusItem;
        [statusItemView setTitle:eta];
        
        [statusItem setView:statusItemView];
        [statusMenu update];
    }
}

- (void)converterIsRunning:(NSNotification *)notification {

    @autoreleasepool {
        
        NSDictionary *dict = notification.userInfo;
        NSString *etaString = [dict objectForKey:@"eta"];
        NSString *string = nil;
  
        NSRange textRange = [etaString rangeOfString:@"ETA "];
        if(textRange.location != NSNotFound) {
           
            NSRange r = NSMakeRange(textRange.location + 4, etaString.length - (textRange.location + 6));
            
            string = [etaString substringWithRange:r];
            
            if([string isEqualToString:@"00h00m00s"])
                string = nil;
        }
        
        [self updateStatusMenu:string];
    }
}

- (void)updateQueueMenu:(NSNotification *)notification {
    
    NSDictionary *dict = notification.userInfo;
    NSArray *queue = [dict objectForKey:@"queue"];
    
    [queueMenu removeAllItems];
    
    if([queue count] > 0) {
        for(NSString *path in queue) {
            [queueMenu addItemWithTitle:path action:nil keyEquivalent:@""];
        }
    } else {
        [queueMenu addItemWithTitle:@"empty" action:nil keyEquivalent:@""];
    }
}

- (IBAction)displayPreferences:(id)sender {
    
    preferences = [[Preferences alloc] init];
    [preferences showPreferenceWindow];
}

- (IBAction)showLog:(id)sender {
    
    [[NSWorkspace sharedWorkspace] openFile:@"/tmp/handleBarError.log"];
}

- (void)applicationWillTerminate:(NSNotification *)notification {
    
    // Do some terminator stuff
}

@end
