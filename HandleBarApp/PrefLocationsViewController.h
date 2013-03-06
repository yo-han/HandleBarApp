//
//  PrefLocationsViewController.h
//  HandleBarApp
//
//  Created by Johan Kuijt on 05-03-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MASPreferencesViewController.h"

@interface PrefLocationsViewController : NSViewController <MASPreferencesViewController,NSTableViewDelegate,NSTabViewDelegate>

@property (weak) IBOutlet NSArrayController *convertController;
@property (weak) IBOutlet NSArrayController *subtitlesController;

- (IBAction)selectFile:(id)sender;

@end
