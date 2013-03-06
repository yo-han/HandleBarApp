//
//  Preferences.m
//  HandleBarApp
//
//  Created by Johan Kuijt on 06-03-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import "Preferences.h"
#import "MASPreferencesWindowController.h"
#import "PrefIndexViewController.h"
#import "PrefConfigViewController.h"
#import "PrefLocationsViewController.h"

@interface Preferences()

@end

@implementation Preferences

- (void)showPreferenceWindow {
    
    if(_preferencesWindow == nil){
        
        NSViewController *prefIndexViewController = [[PrefIndexViewController alloc] initWithNibName:@"PrefIndexViewController" bundle:[NSBundle mainBundle]];
        NSViewController *prefConfigViewController = [[PrefConfigViewController alloc] initWithNibName:@"PrefConfigViewController" bundle:[NSBundle mainBundle]];
        NSViewController *prefLocationsViewController = [[PrefLocationsViewController alloc] initWithNibName:@"PrefLocationsViewController" bundle:[NSBundle mainBundle]];
        
        NSArray *views = [NSArray arrayWithObjects:prefIndexViewController, prefConfigViewController, prefLocationsViewController, nil];
        NSString *title = NSLocalizedString(@"Preferences", @"Common title for Preferences window");
        
        _preferencesWindow = [[MASPreferencesWindowController alloc] initWithViewControllers:views title:title];
    }
    
    [self.preferencesWindow showWindow:self];
    [self.preferencesWindow.window setLevel: NSModalPanelWindowLevel];
    
}
@end
