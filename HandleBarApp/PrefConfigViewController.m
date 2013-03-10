//
//  PrefConfigViewController.m
//  HandleBarApp
//
//  Created by Johan Kuijt on 30-12-12.
//  Copyright (c) 2012 Mustacherious. All rights reserved.
//

#import "PrefConfigViewController.h"

#define ATVPresets [NSArray arrayWithObjects: @"AppleTV 2",@"AppleTV 3",nil]

@interface PrefConfigViewController ()

@property(nonatomic, strong) NSArray *languages;

@end

@implementation PrefConfigViewController

@synthesize languageController = _languageController;
@synthesize presetController = _presetController;
@synthesize languages = _languages;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"languages" ofType:@"plist"];
        _languages = [NSArray arrayWithContentsOfFile:plistPath];
    }
    
    return self;
}

- (void)viewWillAppear {
        
    [_languageController setContent:self.languages];
    [_presetController setContent:ATVPresets];
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

-(IBAction)changeLanguage:(id)sender {
    
    NSInteger *index = [sender indexOfSelectedItem];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    if([sender tag] == 1) {
        [ud setObject:[[self.languages objectAtIndex:index] objectForKey:@"iso3"] forKey:@"HandBrakeLanguage"];
    } else if([sender tag] == 2) {
        [ud setObject:[[self.languages objectAtIndex:index] objectForKey:@"description"] forKey:@"SubtitleLanguage"];
        [ud setObject:[[self.languages objectAtIndex:index] objectForKey:@"iso2"] forKey:@"SubtitleLanguageISO"];
    }
    
}

@end
