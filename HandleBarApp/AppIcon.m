//
//  AppIcon.m
//  HandleBarApp
//
//  Created by Johan Kuijt on 19-07-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import "AppIcon.h"
#import <Quartz/Quartz.h>

@implementation AppIcon

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)drawRect:(NSRect)rect
{
    NSRect bounds = [self bounds];
    
    //draw the icon
    NSImage* icon = [NSImage imageNamed:@"HandleBar-DockIcon"];
    [icon setSize:bounds.size];
    [icon drawAtPoint:NSZeroPoint fromRect:NSZeroRect operation:NSCompositeCopy fraction:1.0];
    
    NSTextField *text = [[NSTextField alloc] initWithFrame:CGRectMake(0, 65, bounds.size.width, 34)];
    text.backgroundColor = [NSColor colorWithCalibratedWhite:0.9 alpha:0.8];
    text.alignment = NSCenterTextAlignment;
    text.font = [NSFont fontWithName:@"Courier" size:24.0];
    [text setStringValue:@"12:30:10"];

    [self addSubview:text];
}

@end
