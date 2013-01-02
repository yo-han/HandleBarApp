//
//  PrefIndexViewController.h
//  HandleBarApp
//
//  Created by Johan Kuijt on 30-12-12.
//  Copyright (c) 2012 Mustacherious. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <ServiceManagement/ServiceManagement.h>

#import "MASPreferencesViewController.h"
#import "StartAtLoginController.h"

@interface PrefIndexViewController : NSViewController <MASPreferencesViewController> {
    
    IBOutlet NSButton *loginCheck;
}

- (IBAction)checkChanged:(id)sender;

@end
