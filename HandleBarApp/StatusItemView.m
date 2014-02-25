//
//  StatusItemView.m
//  HandleBarApp
//
//  Created by Johan Kuijt on 27-04-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import "StatusItemView.h"
#import "AppDelegate.h"

@implementation StatusItemView

@synthesize image, title, statusItem;

- (id)initWithFrame:(NSRect)frame controller:(AppDelegate *)ctrlr
{
    if (self = [super initWithFrame:frame]) {
        
        statusItem = nil;
        title = @"";
        
        image= [NSImage imageNamed:@"handleBarIcon.png"];
        [image setSize:CGSizeMake(19, 19)];
        
        controller = ctrlr; // deliberately weak reference.
    }
    
    return self;
}


- (void)dealloc
{
    controller = nil;
    statusItem = nil;
    title = nil;
    image = nil;
}

- (void)drawRect:(NSRect)rect {
    
    @autoreleasepool {
        // Draw background if appropriate.
        if (clicked) {
            [[NSColor selectedMenuItemColor] set];
            NSRectFill(rect);
        }

        NSString *text = title;
        
        NSColor *textColor = [NSColor controlTextColor];
        if (clicked) {
            textColor = [NSColor selectedMenuItemTextColor];
        }
        
        NSFont *msgFont = [NSFont menuBarFontOfSize:12.0];
        NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
        [paraStyle setParagraphStyle:[NSParagraphStyle defaultParagraphStyle]];
        [paraStyle setAlignment:NSCenterTextAlignment];
        [paraStyle setLineBreakMode:NSLineBreakByTruncatingTail];
        NSMutableDictionary *msgAttrs = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                         msgFont, NSFontAttributeName,
                                         textColor, NSForegroundColorAttributeName,
                                         paraStyle, NSParagraphStyleAttributeName,
                                         nil];
        
        NSSize msgSize = [text sizeWithAttributes:msgAttrs];
        NSRect msgRect = NSMakeRect(0, 0, msgSize.width, msgSize.height);
        NSRect imgRect = NSMakeRect(2, 4, 19, 15);
        
        msgRect.origin.x = ([self frame].size.width - msgSize.width) - 5;
        msgRect.origin.y = 4;
        
        [text drawInRect:msgRect withAttributes:msgAttrs];
        [image drawInRect:imgRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0f];
    }
}


- (void)mouseDown:(NSEvent *)event
{
    clicked = !clicked;

    [[statusItem menu] setDelegate:(id) self];
    [statusItem popUpStatusItemMenu:[statusItem menu]];
    //[self setNeedsDisplay:YES];
}

- (void)rightMouseDown:(NSEvent *)event {
    // Treat right-click just like left-click
    [self mouseDown:event];
}

- (void)menuWillOpen:(NSMenu *)menu {
    clicked = YES;
    [self setNeedsDisplay:YES];
}

- (void)menuDidClose:(NSMenu *)menu {
    
    clicked = NO;
    [[statusItem menu] setDelegate:nil];
    [self setNeedsDisplay:YES];
}

@end
