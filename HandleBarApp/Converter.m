//
//  Converter.m
//  HandleBarApp
//
//  Created by Johan Kuijt on 11-03-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import "Converter.h"

@interface Converter()

@property (atomic, copy) NSMutableArray *videoFiles;

@end

@implementation Converter

@synthesize videoFiles = _videoFiles;

- (id) initWithPaths:(NSArray *)paths {
    
    self = [super init];
	if (self)
	{
		VDKQueue *vdk = [[VDKQueue alloc] init];
        _videoFiles = [NSMutableArray new];
        
        for(NSDictionary *path in paths) {
            [vdk addPath:[path objectForKey:@"path"]];
        }
        
        vdk.delegate = self;
	}
	return self;
}

-(void) VDKQueue:(VDKQueue *)queue receivedNotification:(NSString*)noteName forPath:(NSString*)fpath {
    
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSURL *directoryURL = [NSURL URLWithString:fpath];
    NSArray *keys = [NSArray arrayWithObject:NSURLIsDirectoryKey];

    NSDirectoryEnumerator *enumerator = [fileManager enumeratorAtURL:directoryURL includingPropertiesForKeys:keys options:0 errorHandler:^(NSURL *url, NSError *error) { return YES; }];

    for (NSURL *url in enumerator) {
     
        NSError *error;
        NSNumber *isDirectory = nil;
        NSNumber *isHidden = nil;
             
        [url getResourceValue:&isHidden forKey:NSURLIsHiddenKey error:&error];

        if (![url getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:&error]) {
             NSLog(@"error while scanning dir");
        }
         
        if ([isDirectory boolValue]) {

             NSArray *dirFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[url path] error:nil];
             NSArray *files = [dirFiles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:[self fileTypePredicateString]]];

            for(NSString *file in files) {

                NSString *f = [NSString stringWithFormat:@"%@/%@",[url path], file];
                [_videoFiles addObject:f];
            }
        }
    }
    
    _videoFiles = [NSMutableArray arrayWithArray:[self.videoFiles valueForKeyPath:@"@distinctUnionOfObjects.self"]];
    NSLog(@"%@",self.videoFiles);
}

- (NSString *)fileTypePredicateString {
    
    NSArray *fileTypesConfig = [[NSUserDefaults standardUserDefaults] objectForKey:@"FileTypes"];
    NSMutableArray *fileTypes = [[NSMutableArray alloc] init];
    
    for(NSDictionary *fileType in fileTypesConfig) {
        
        NSString *predicate = [NSString stringWithFormat:@"(self ENDSWITH '%@')", [[fileType objectForKey:@"file"] stringByReplacingOccurrencesOfString:@"*" withString:@""]];
        [fileTypes addObject:predicate];
    }
    
    return [fileTypes componentsJoinedByString:@" OR "];       
}

@end
