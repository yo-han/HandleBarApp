//
//  Util.h
//  HandleBarApp
//
//  Created by Johan Kuijt on 10-03-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Util : NSObject

+ (BOOL)inDebugMode;
+ (NSDictionary *)executeCommand:(NSString *)cmd args:(NSArray *)arguments notifyStdOut:(BOOL)notifyStdOut;
+ (NSDictionary *)executeBashCommand:(NSString *)cmd;
+ (BOOL)trashWithPath:(NSString *)path;
+ (NSDictionary *)getConfigFile;
+ (void) logEncodingStatus:(NSString *)output;

@end
