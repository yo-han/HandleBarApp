//
//  MetaData.h
//  HandleBarApp
//
//  Created by Johan Kuijt on 15-03-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MetaData : NSObject <NSURLDownloadDelegate>

- (BOOL)setMetadataInVideo:(NSString *)sourcePath;

@end
