//
//  Python_Pyhton.h
//  HandleBarApp
//
//  Created by Johan Kuijt on 14-03-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

// Some python tests

@interface Python ()

/*
Py_SetProgramName("/usr/bin/python");
Py_Initialize();

PyImport_AddModule("lib");
PyImport_AddModule("app");
PyImport_AddModule("lib.enzyme");

NSString *path = [[NSBundle mainBundle] bundlePath];
NSString *scriptPath = [path stringByAppendingPathComponent:@"Contents/Resources/HandleBar/util.py"];

char* script_path = (char*)[scriptPath UTF8String];

FILE *mainFile = fopen(script_path, "r");
int result = PyRun_SimpleFile(mainFile, "util.py");

NSString *s = [NSString stringWithFormat:@"countAudioTracks('%@')", sourcePath];
PyRun_SimpleString([s UTF8String]); */

@end
