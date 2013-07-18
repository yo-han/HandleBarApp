//
//  Converter.m
//  HandleBarApp
//
//  Created by Johan Kuijt on 11-03-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import "Converter.h"
#import "Util.h"
#import "iTunes.h"
#import "MetaData.h"

#import "NSOperationQueue+CWSharedQueue.h"
#import "NSFileManager+Directories.h"
#import "SCEvents.h"
#import "SCEvent.h"

@interface Converter()

@property(strong) dispatch_queue_t convertQueue;
@property(strong) NSFileManager *fm;
@property(strong) NSString *appSupportPath;
@property(strong) NSMutableSet *convertedFiles;
@property(strong) NSMutableArray *queuedVideoFiles;

- (NSString *)fileTypePredicateString;
- (NSMutableArray *)findVideoFiles:(NSString *)path array:(NSMutableArray *)videosFiles;
- (NSString *)getAudioTracks:(NSString *)sourcePath;
- (NSString *) convert:(NSString *) videoPath directory:(NSString *)directory;
- (void)setMetaData:(NSString *)mediaFile;

@end

@implementation Converter

@synthesize fm, appSupportPath, convertedFiles, queuedVideoFiles;
@synthesize convertQueue=_convertQueue;

- (id) initWithPaths:(NSArray *)paths {
    
    self = [super init];
	if (self)
	{
        fm = [NSFileManager defaultManager];
        appSupportPath = [fm applicationSupportFolder];
        convertedFiles = [NSMutableSet set];
        queuedVideoFiles = [NSMutableArray array];
        
        [self setupEventListener:paths];
       
        _convertQueue = dispatch_queue_create("hb.convert.queue", NULL);
	}
    
	return self;
}

- (void)setupEventListener:(NSArray *)searchPaths
{
	if (_events) return;
	
    _events = [[SCEvents alloc] init];
    
    [_events setDelegate:self];
    
    NSMutableArray *paths = [NSMutableArray arrayWithArray:[self arrayWithPaths:searchPaths]];
    
	[_events startWatchingPaths:paths];
}

- (void)pathWatcher:(SCEvents *)pathWatcher eventOccurred:(SCEvent *)event
{    
    NSURL *directoryURL = [NSURL URLWithString:event._eventPath];
    NSArray *keys = [NSArray arrayWithObject:NSURLIsDirectoryKey];
    NSMutableArray *videoFiles = [NSMutableArray array];

    // If the file is removed or the URL is just missing stop the execution.
    if(directoryURL == nil)
        return;
    
    NSDirectoryEnumerator *enumerator = [fm enumeratorAtURL:directoryURL includingPropertiesForKeys:keys options:0 errorHandler:^(NSURL *url, NSError *error) { return YES; }];
    
    for (NSURL *url in enumerator) {
        
        NSError *error;
        NSNumber *isDirectory = nil;
        NSNumber *isHidden = nil;
        
        [url getResourceValue:&isHidden forKey:NSURLIsHiddenKey error:&error];
        
        if (![url getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:&error]) {
            NSLog(@"error while scanning dir");
        }
        
        if ([isDirectory boolValue]) {
            
            videoFiles = [self findVideoFiles:[NSString stringWithFormat:@"%@/",[url path]] array:videoFiles];
        }
    }
    
    NSLog(@"Check for not-converted video files event fired by: %@", event._eventPath);
    
    // Add files from the directory root which are not in a directory to. Could be manually
    // added files there.
    videoFiles = [self findVideoFiles:event._eventPath array:videoFiles];

    self.queuedVideoFiles = [self arrayUnique:videoFiles queue:self.queuedVideoFiles];
    
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    [info setObject:self.queuedVideoFiles forKey:@"queue"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateQueueMenu" object:nil userInfo:info];
    
    __block NSString *mediaFile;
    
    @autoreleasepool
    {
        dispatch_async(self.convertQueue, ^{
            
            if([self.queuedVideoFiles count] != 0) {
                
                NSString *videoPath = [self.queuedVideoFiles objectAtIndex:0];
                
                mediaFile = [self convert:videoPath directory:[directoryURL description]];
                
                [self.queuedVideoFiles removeObjectAtIndex:0];
                [convertedFiles addObject:videoPath];
                
                NSMutableDictionary *info = [NSMutableDictionary dictionary];
                [info setObject:@"" forKey:@"eta"];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"updateConvertETA" object:nil userInfo:info];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self setMetaData:mediaFile];
                });
            }
        });
    }
    
    if([self.queuedVideoFiles count] == 0) {
        
        NSLog(@"Clean up the 'allready converted files' list");
        [convertedFiles removeAllObjects];
    }
}

- (void)setMetaData:(NSString *)mediaFile {
    
    if(mediaFile == nil)
        return;
    
    MetaData *md = [MetaData new];
     
    BOOL metaDataIsSet = [md setMetadataInVideo:mediaFile];
    
    if(metaDataIsSet == NO) {
        
        NSString *failedPath = [appSupportPath stringByAppendingPathComponent:@"/media/failed"];
        [fm copyFileToNewPath:mediaFile dir:failedPath];
    }
}

- (NSString *) convert:(NSString *) videoPath directory:(NSString *)directory {
    
    if([convertedFiles containsObject:videoPath]) {
        
        NSLog(@"Converted already: %@",  videoPath);
        return nil;
        
    } else {
        NSLog(@"Not converted yet, let's go: %@",  videoPath);
    }
    
    NSString *currentPath = [[NSBundle mainBundle] bundlePath];
    NSString *cmd = [currentPath stringByAppendingPathComponent:@"Contents/Resources/HandBrakeCLI"];
    
    NSString *failedPath = [appSupportPath stringByAppendingPathComponent:@"/media/failed"];
    NSString *debugRemovePath = [appSupportPath stringByAppendingPathComponent:@"/media/done"];
    NSString *convertedDir = [appSupportPath stringByAppendingPathComponent:@"/media/converted"];
    
    NSString *convertPath = [convertedDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.m4v", [[videoPath lastPathComponent] stringByDeletingPathExtension]]];

    NSString *audioTracks = [self getAudioTracks:videoPath];
    NSString *preset = [[NSUserDefaults standardUserDefaults] objectForKey:@"HandBrakePreset"];
    NSString *language = [[NSUserDefaults standardUserDefaults] objectForKey:@"HandBrakeLanguage"];
        
    NSArray *args = [NSArray arrayWithObjects:@"-i", videoPath, @"-o", convertPath, @"--audio", audioTracks, @"--preset", preset, @"--native-language", language, @"--native-dub", nil];
    
    [Util executeCommand:cmd args:args notifyStdOut:YES];

    if([fm fileExistsAtPath:convertPath]) {
        
        if([Util inDebugMode]) {
            
            // Move original file to debug dir
            
            [fm copyFileToNewPath:videoPath dir:debugRemovePath];
            
        } else {
            
            // Move orignal file to the trash bin
            [Util trashWithPath:videoPath];
        }
        
        // Remove all files left behind
        NSArray *pathComponents = [[videoPath stringByReplacingOccurrencesOfString:directory withString:@""] pathComponents];
        if(pathComponents.count > 2) {

            NSString *dir = [directory stringByAppendingPathComponent:[pathComponents objectAtIndex:1]];
            NSArray *filesFound = [self findVideoFiles:dir array:[NSMutableArray array]];
            
            if([filesFound count] == 0)
                [Util trashWithPath:dir];
        }

        return convertPath;
        
    } else {
        
        // Move original to failed dir if m4v isn't found
        [fm copyFileToNewPath:videoPath dir:failedPath];
    }
    
    return nil;
}

- (NSString *)getAudioTracks:(NSString *)sourcePath {
    
    NSString *currentPath = [[NSBundle mainBundle] bundlePath];
    NSString *cmd = [currentPath stringByAppendingPathComponent:@"Contents/Resources/ffmpeg"];
    
    NSDictionary *response = [Util executeBashCommand:[NSString stringWithFormat:@"%@ -i %@ 2>&1 >/dev/null | grep -c 'Audio'", cmd, sourcePath]];

    int trackCount = (int) [[response objectForKey:@"response"] integerValue];

    NSMutableArray *tracks = [NSMutableArray new];
    
    for(int i = 1; i <= trackCount; i++) {
        [tracks addObject:[NSNumber numberWithInt:i]];
    }
    
    return [tracks componentsJoinedByString:@","];
}

- (NSMutableArray *) findVideoFiles:(NSString *)path array:(NSMutableArray *)videosFiles {
    
    NSArray *dirFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
    NSArray *files = [dirFiles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:[self fileTypePredicateString]]];
    
    for(NSString *file in files) {
        
        NSString *f = [NSString stringWithFormat:@"%@/%@",path, file];
        [videosFiles addObject:f];
    }
    
    return videosFiles;
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

- (NSArray *)arrayWithPaths:(NSArray *)paths {
    
    NSMutableArray *pathList = [NSMutableArray new];
    
    for(NSDictionary *path in paths) {
        [pathList addObject:[path objectForKey:@"path"]];
    }
    
    return pathList;
}

- (NSMutableArray *)arrayUnique:(NSArray *)array queue:(NSMutableArray *)queue {
    
    NSMutableSet* existingNames = [NSMutableSet set];
    NSMutableArray* filteredArray = [NSMutableArray array];
    
    [queue addObjectsFromArray:array];
    
    for (NSString* path in queue) {
        
        NSRange textRange = [path rangeOfString:@"_UNPACK_"];
        if(textRange.location != NSNotFound)
            continue;
        
        if (![existingNames containsObject:path]) {
            [existingNames addObject:path];
            [filteredArray addObject:path];
        }
    }
    
    return filteredArray;
}

@end
