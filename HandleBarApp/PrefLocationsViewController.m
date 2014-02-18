//
//  PrefLocationsViewController.m
//  HandleBarApp
//
//  Created by Johan Kuijt on 05-03-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import "PrefLocationsViewController.h"
#import "FileSelect.h"
#import "AppDelegate.h"

#define UserDefaultKeysByTab [NSArray arrayWithObjects: @"MediaPaths",@"ReSubSearchPaths",nil]

@interface PrefLocationsViewController ()

@property(nonatomic) int activeTab;

@end

@implementation PrefLocationsViewController

@synthesize convertController = _convertController;
@synthesize subtitlesController = _subtitlesController;
@synthesize activeTab = _activeTab;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _activeTab = 0;
    }
    
    return self;
}

-(NSString *)identifier{
    return @"Locations";
}

-(NSImage *)toolbarItemImage{
    return [NSImage imageNamed:NSImageNamePreferencesGeneral];
}

-(NSString *)toolbarItemLabel{
    return @"Locations";
}

#pragma mark -- NSTableView delegate methods

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row {
    
    //NSLog(@"row %d",row);
    
    if(self.activeTab == 0) {
        [_convertController setSelectionIndex:row];
    } else {
        [_subtitlesController setSelectionIndex:row];
    }
    
    return YES;
}

#pragma mark -- NSTabView delegate methods

- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem {
    
    _activeTab = (int) [[tabViewItem identifier] integerValue];
}

#pragma mark -- File select

- (IBAction)selectFile:(id)sender {
 
    FileSelect *fs = [[FileSelect alloc] init];
    fs.delegate = self;
    
    [fs openDialog];
}

- (void)didSelectFile:(NSURL *)fileName {

    NSString *udKey = [UserDefaultKeysByTab objectAtIndex:(int) self.activeTab];
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSMutableArray *paths = [NSMutableArray arrayWithArray:[ud objectForKey:udKey]];

    NSString *path = [fileName relativePath];

    [paths addObject:[NSMutableDictionary dictionaryWithObject:path forKey:@"path"]];
    [ud setObject:paths forKey:udKey];
    
    [(AppDelegate *)[[NSApplication sharedApplication] delegate] reloadConverter];
}

@end

