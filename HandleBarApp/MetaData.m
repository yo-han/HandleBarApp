//
//  MetaData.m
//  HandleBarApp
//
//  Created by Johan Kuijt on 15-03-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import "MetaData.h"
#import "Util.h"

@implementation MetaData

- (void)setMetadataInVideo:(NSString *)sourcePath {

    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSString *scriptPath = [path stringByAppendingPathComponent:@"Contents/Resources/HandleBar/guess.py"];
    
    NSString *cmd = @"/usr/bin/python";
    NSArray *args = [NSArray arrayWithObjects:scriptPath, sourcePath, nil];
    
    NSDictionary *resp = [Util executeCommand:cmd args:args];
    NSString *json = [resp objectForKey:@"response"];
    
    NSDictionary *video = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding] options:nil error:nil];
    
    NSLog(@"%@", [video objectForKey:@"type"]);
    
    return;
}

@end
