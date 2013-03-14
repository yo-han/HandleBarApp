//
//  Util.m
//  HandleBarApp
//
//  Created by Johan Kuijt on 10-03-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import "Util.h"

@implementation Util

+ (BOOL)inDebugMode {
    
    return (BOOL) [[NSUserDefaults standardUserDefaults] boolForKey:@"Debug"];
}

+ (NSDictionary *)executeCommand:(NSString *)cmd args:(NSArray *)arguments {
    
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath: cmd];
    [task setArguments: arguments];
    
    NSPipe *pipe = [NSPipe pipe];
    [task setStandardOutput: pipe];
    
    NSFileHandle *file = [pipe fileHandleForReading];
    
    [task launch];
    
    NSData *data = [file readDataToEndOfFile];
    NSString *string = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    
    NSDictionary *response = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithInt:task.processIdentifier], string, nil] forKeys:[NSArray arrayWithObjects:@"pid", @"response", nil]];
    
    return response;
}

+ (NSDictionary *)executeBashCommand:(NSString *)cmd {
    
    NSTask *task = [[NSTask alloc] init];
    
    // Setup the task
    [task setLaunchPath:@"/bin/bash"];
    NSArray	*args = [NSArray arrayWithObjects:@"-l",
    				 @"-c",
    				 cmd,
    				 nil];
    [task setArguments: args];
    
    // Set the output pipe.
    NSPipe *outPipe = [[NSPipe alloc] init];
    [task setStandardOutput:outPipe];
    
    NSFileHandle *file = [outPipe fileHandleForReading];
    
    [task launch];
        
    NSData *data = [file readDataToEndOfFile];
    NSString *string = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    
    NSDictionary *response = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithInt:task.processIdentifier], string, nil] forKeys:[NSArray arrayWithObjects:@"pid", @"response", nil]];
    
    return response;
}

+ (BOOL)trashWithPath:(NSString *)path {
    
    NSWorkspace *ws = [NSWorkspace sharedWorkspace];
    
    if(![ws performFileOperation:NSWorkspaceRecycleOperation
                          source:[path stringByDeletingLastPathComponent] destination:@""
                           files:[NSArray arrayWithObject:[path lastPathComponent]] tag:0]){
        
        return NO;
    }
    else
        return YES;
}

@end
