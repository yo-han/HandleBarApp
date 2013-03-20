//
//  Movie.m
//  HandleBarApp
//
//  Created by Johan Kuijt on 19-03-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import "Movie.h"
#import "IMDB.h"

@interface Movie()

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *image;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *description;
@property (nonatomic, strong) NSString *rating;
@property (nonatomic, strong) NSString *releaseDate;
@property (nonatomic, strong) NSString *director;
@property (nonatomic, strong) NSString *cast;
@property (nonatomic, strong) NSString *genre;
@property (nonatomic, strong) NSString *imdbId;
@property (nonatomic, strong) NSString *year;

@end

@implementation Movie

@synthesize title, image, name, description, rating, releaseDate, director, cast, genre, imdbId, year;

+ (Movie *)getMovie:(NSString *)movieTitle year:(NSString *)year {
    
    IMDB *imdb = [[IMDB alloc] initWithTitle:movieTitle year:year];
    NSDictionary *movieData = [imdb getMovieData];

    if(movieData == nil)
        return nil;
    
    Movie *movie = [Movie new];
    movie.title = [movieData objectForKey:@"Title"];
    movie.image = [movieData objectForKey:@"Poster"];
    movie.name = [movieData objectForKey:@"Title"];
    movie.description = [movieData objectForKey:@"Plot"];
    movie.rating = [movieData objectForKey:@"Rated"];
    movie.releaseDate = [movieData objectForKey:@"Released"];
    movie.director = [movieData objectForKey:@"Director"];
    movie.cast = [movieData objectForKey:@"Actors"];
    movie.genre = [movieData objectForKey:@"Genre"];
    movie.imdbId = [movieData objectForKey:@"imdbID"];
    movie.year = year;
    
    return movie;
}

-(NSString *)description {
    return [NSString stringWithFormat:@"Movie: %@ (%@)", self.title, self.year];
}

@end
