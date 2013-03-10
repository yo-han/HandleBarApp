//
//  PrefConfigViewController.h
//  HandleBarApp
//
//  Created by Johan Kuijt on 30-12-12.
//  Copyright (c) 2012 Mustacherious. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MASPreferencesViewController.h"

@interface PrefConfigViewController : NSViewController <MASPreferencesViewController>

@property (weak) IBOutlet NSArrayController *languageController;
@property (weak) IBOutlet NSArrayController *presetController;

@end
