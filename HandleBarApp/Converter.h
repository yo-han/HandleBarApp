//
//  Converter.h
//  HandleBarApp
//
//  Created by Johan Kuijt on 11-03-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCEventListenerProtocol.h"

@interface Converter : NSObject <SCEventListenerProtocol>
{
	SCEvents *_events;
}

- (id) initWithPaths:(NSArray *)paths;

@end
