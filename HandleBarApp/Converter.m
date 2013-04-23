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

- (NSString *)fileTypePredicateString;
- (NSMutableArray *)findVideoFiles:(NSString *)path array:(NSMutableArray *)videosFiles;
- (NSString *)getAudioTracks:(NSString *)sourcePath;
- (NSString *) convert:(NSArray *) videos directory:(NSString *)directory;
- (void)setMetaData:(NSString *)mediaFile;
- (void)copyToItunes:(NSString *)sourcePath;

@end

@implementation Converter

@synthesize fm, appSupportPath;
@synthesize convertQueue=_convertQueue;

- (id) initWithPaths:(NSArray *)paths {
    
    self = [super init];
	if (self)
	{
        fm = [NSFileManager defaultManager];
        appSupportPath = [fm applicationSupportFolder];
        
        [self setupEventListener:paths];
       
        _convertQueue = dispatch_queue_create("hb.convert.queue", NULL);
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(copyToItunes:) name:@"HBMetaDataIsSet" object:nil];
	}
    
	return self;
}

- (void)setupEventListener:(NSArray *)searchPaths
{
	if (_events) return;
	
    _events = [[SCEvents alloc] init];
    
    [_events setDelegate:self];
    
    NSMutableArray *paths = [NSMutableArray arrayWithArray:[self arrayWithPaths:searchPaths]];
    //NSMutableArray *excludePaths = [NSMutableArray arrayWithObject:[NSHomeDirectory() stringByAppendingPathComponent:@"Downloads/tmp"]];
    
	//[_events setExcludedPaths:excludePaths];
	[_events startWatchingPaths:paths];
    
	// Display a description of the stream
	//NSLog(@"%@", [_events streamDescription]);
}

/**
 * This is the only method to be implemented to conform to the SCEventListenerProtocol.
 * As this is only an example the event received is simply printed to the console.
 *
 * @param pathwatcher The SCEvents instance that received the event
 * @param event       The actual event
 */
- (void)pathWatcher:(SCEvents *)pathWatcher eventOccurred:(SCEvent *)event
{
    
    NSURL *directoryURL = [NSURL URLWithString:event._eventPath];
    NSArray *keys = [NSArray arrayWithObject:NSURLIsDirectoryKey];
    NSMutableArray *videoFiles = [NSMutableArray array];
    NSArray *filteredVideoFiles = [NSArray array];
    
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
    
    if([videoFiles count] == 0)
        videoFiles = [self findVideoFiles:event._eventPath array:videoFiles];
    
    filteredVideoFiles = [self arrayUnique:videoFiles];
    
    __block NSString *mediaFile;
    
    dispatch_async(self.convertQueue, ^{
        
        mediaFile = [self convert:filteredVideoFiles directory:[directoryURL description]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setMetaData:mediaFile];
        });
    });
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

- (NSString *) convert:(NSArray *) videos directory:(NSString *)directory {
    
    if([videos count] == 0)
        return nil;
    
    NSString *currentPath = [[NSBundle mainBundle] bundlePath];
    NSString *cmd = [currentPath stringByAppendingPathComponent:@"Contents/Resources/HandBrakeCLI"];
    
    NSString *failedPath = [appSupportPath stringByAppendingPathComponent:@"/media/failed"];
    NSString *debugRemovePath = [appSupportPath stringByAppendingPathComponent:@"/media/done"];
    NSString *convertedDir = [appSupportPath stringByAppendingPathComponent:@"/media/converted"];
    
    NSString *videoPath = [videos objectAtIndex:0];
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
            [Util trashWithPath:dir];
        }

        return convertPath;
        
    } else {
        
        // Move original to failed dir if m4v isn't found
        [fm copyFileToNewPath:videoPath dir:failedPath];
    }
    
    return nil;
}

- (void)copyToItunes:(NSNotification *)notification {
    
    if ([[notification name] isEqualToString:@"HBMetaDataIsSet"])
    {
        NSDictionary *userInfo = [notification userInfo];
        NSString *path = [userInfo objectForKey:@"sourcePath"];
        
        iTunesApplication *iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
        iTunesTrack * track = [iTunes add:[NSArray arrayWithObject:[NSURL fileURLWithPath:path]] to:nil];
        
        NSLog(@"Added %@ to track: %@",path,track);
        
        if(![Util inDebugMode]) {
            NSLog(@"Remove copy in coverted dir");
            [Util trashWithPath:path];
        }
    }
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

- (NSArray *)arrayUnique:(NSArray *)array {
    
    NSMutableSet* existingNames = [NSMutableSet set];
    NSMutableArray* filteredArray = [NSMutableArray array];
    for (NSString* path in array) {
        if (![existingNames containsObject:path]) {
            [existingNames addObject:path];
            [filteredArray addObject:path];
        }
    }
    
    return filteredArray;
}

@end
