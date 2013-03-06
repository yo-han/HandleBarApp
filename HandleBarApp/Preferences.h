//
//  Preferences.h
//  HandleBarApp
//
//  Created by Johan Kuijt on 06-03-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Preferences : NSObject

@property (strong) NSWindowController *preferencesWindow;

- (void)showPreferenceWindow;

@end
