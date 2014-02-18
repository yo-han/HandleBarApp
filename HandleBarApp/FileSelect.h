//
//  FileSelect.h
//  HandleBarApp
//
//  Created by Johan Kuijt on 06-03-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileSelect : NSObject

@property (nonatomic, strong) id delegate;

- (void)openDialog;

@end

@protocol FileSelectDelegate

-(void)didSelectFile:(NSURL *)fileName;

@end
