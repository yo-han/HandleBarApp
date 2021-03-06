//
//  MetaData.h
//  HandleBarApp
//
//  Created by Johan Kuijt on 15-03-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Downloader.h"

@interface MetaData : NSObject <DownloaderDelegate>

@property (nonatomic, strong) id delegate;

- (BOOL)setMetadataInVideo:(NSString *)sourcePath;

@end
