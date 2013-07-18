//
//  StatusItem.h
//  HandleBarApp
//
//  Created by Johan Kuijt on 27-04-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AppDelegate;

@interface StatusItemView : NSView {
    
    __weak AppDelegate *controller;
    
    NSStatusItem *statusItem;
    NSString *title;
    NSImage *image;
    
    BOOL clicked;
}

@property (retain, nonatomic) NSStatusItem *statusItem;
@property (retain, nonatomic) NSString *title;
@property (retain, nonatomic) NSImage *image;

- (id)initWithFrame:(NSRect)frame controller:(AppDelegate *)ctrlr;

@end
