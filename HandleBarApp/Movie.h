//
//  Movie.h
//  HandleBarApp
//
//  Created by Johan Kuijt on 19-03-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Movie : NSObject

+ (Movie *)getMovie:(NSString *)movieTitle year:(NSString *)year;

@end
