//
//  PrefConfigViewController.m
//  HandleBarApp
//
//  Created by Johan Kuijt on 30-12-12.
//  Copyright (c) 2012 Mustacherious. All rights reserved.
//

#import "PrefConfigViewController.h"

@interface PrefConfigViewController ()

@end

@implementation PrefConfigViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

-(NSString *)identifier{
    return @"Config";
}

-(NSImage *)toolbarItemImage{
    return [NSImage imageNamed:NSImageNamePreferencesGeneral];
}

-(NSString *)toolbarItemLabel{
    return @"Config";
}

@end
