//
//  PrefIndexViewController.m
//  HandleBarApp
//
//  Created by Johan Kuijt on 30-12-12.
//  Copyright (c) 2012 Mustacherious. All rights reserved.
//

#import "PrefIndexViewController.h"

@interface PrefIndexViewController ()

@end

@implementation PrefIndexViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    
    return self;
}

- (void) viewWillAppear {
    
    StartAtLoginController *loginController = [[StartAtLoginController alloc] initWithIdentifier:@"com.mustacherious.HandleBarHelperApp"];
    
    if (![loginController startAtLogin])
        [loginCheck setState:0];
}

-(NSString *)identifier{
    return @"General";
}

-(NSImage *)toolbarItemImage{
    return [NSImage imageNamed:NSImageNamePreferencesGeneral];
}

-(NSString *)toolbarItemLabel{
    return @"General";
}

- (IBAction)checkChanged:(id)sender {
    
    StartAtLoginController *loginController = [[StartAtLoginController alloc] initWithIdentifier:@"com.mustacherious.HandleBarHelperApp"];

    if ([loginCheck state]) {
        if (![loginController startAtLogin])
            [loginController setStartAtLogin: YES];
        
    } else {
        if ([loginController startAtLogin])
            [loginController setStartAtLogin:NO];
            
    }

}

@end