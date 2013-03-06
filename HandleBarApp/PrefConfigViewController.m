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

@synthesize languageController = _languageController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    
    return self;
}

- (void)viewWillAppear {
    
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"languages" ofType:@"plist"];
    [_languageController setContent:[NSArray arrayWithContentsOfFile:plistPath]];
    
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
