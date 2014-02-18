//
//  FileSelect.m
//  HandleBarApp
//
//  Created by Johan Kuijt on 06-03-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import "FileSelect.h"

@interface FileSelect()

-(void)didSelectFile:(NSURL *)fileName;

@end

@implementation FileSelect

@synthesize delegate=_delegate;

- (void)openDialog {
 
    int i; // Loop counter.
    
    // Create the File Open Dialog class.
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    
    // Enable the selection of files in the dialog.
    [openDlg setCanChooseFiles:NO];
    [openDlg setAllowsMultipleSelection:NO];
    
    // Enable the selection of directories in the dialog.
    [openDlg setCanChooseDirectories:YES];
    
    // Display the dialog.  If the OK button was pressed,
    // process the files.
    if ( [openDlg runModal] == NSOKButton )
    {
        // Get an array containing the full filenames of all
        // files and directories selected.
        NSArray* files = [openDlg URLs];

        // Loop through all the files and process them.
        for( i = 0; i < [files count]; i++ )
        {
            NSString *s = [NSString stringWithFormat:@"%@", [files objectAtIndex:i]];
            NSURL *fileName = [NSURL URLWithString:s];
            
            [self didSelectFile:fileName];
        }
    }

}

-(void)didSelectFile:(NSURL *)fileName {

    if(_delegate && [_delegate respondsToSelector:@selector(didSelectFile:)]) {
        [_delegate didSelectFile:fileName];
    }
}

@end
