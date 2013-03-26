//
//  Movie.h
//  HandleBarApp
//
//  Created by Johan Kuijt on 19-03-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Movie : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *image;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *plot;
@property (nonatomic, strong) NSString *rating;
@property (nonatomic, strong) NSString *releaseDate;
@property (nonatomic, strong) NSString *director;
@property (nonatomic, strong) NSString *cast;
@property (nonatomic, strong) NSString *genre;
@property (nonatomic, strong) NSString *imdbId;
@property (nonatomic, strong) NSString *year;
@property (nonatomic, strong) NSString *artworkPath;
@property (nonatomic, strong) NSString *sourcePath;
@property (nonatomic, strong) NSNumber *hd;

+ (Movie *)getMovie:(NSString *)movieTitle year:(NSString *)year;

- (NSString *)getMetaStringWith:(Movie *)movie;

@end
