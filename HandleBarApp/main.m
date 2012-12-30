//
//  main.m
//  HandleBarApp
//
//  Created by Johan Kuijt on 29-12-12.
//  Copyright (c) 2012 Mustacherious. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Python/Python.h>

int main(int argc, char *argv[])
{
    Py_Initialize();
    
    PyImport_AddModule("lib");
    PyImport_AddModule("app");
    
    NSString *f = @"NSFile = '";
    NSString *path = [[NSBundle mainBundle] bundlePath];
	path = [path stringByAppendingPathComponent:@"Contents/Resources/HandleBar/view.py'"];
    NSString *py = [f stringByAppendingString:path];
    
    PyRun_SimpleString([py UTF8String]);
       
    return NSApplicationMain(argc, (const char **)argv);
}
