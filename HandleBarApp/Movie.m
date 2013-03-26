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

@end

@implementation Movie

@synthesize title, image, name, plot, rating, releaseDate, director, cast, genre, imdbId, year, artworkPath, sourcePath, hd;

+ (Movie *)getMovie:(NSString *)movieTitle year:(NSString *)year {
    
    IMDB *imdb = [[IMDB alloc] initWithTitle:movieTitle year:year];
    NSDictionary *movieData = [imdb getMovieData];

    if(movieData == nil)
        return nil;

    Movie *movie = [Movie new];
    movie.title = [movieData objectForKey:@"Title"];
    movie.image = [movieData objectForKey:@"Poster"];
    movie.name = [movieData objectForKey:@"Title"];
    movie.plot = [movieData objectForKey:@"Plot"];
    movie.rating = [movieData objectForKey:@"Rated"];
    movie.releaseDate = [movieData objectForKey:@"Released"];
    movie.director = [movieData objectForKey:@"Director"];
    movie.cast = [movieData objectForKey:@"Actors"];
    movie.genre = [movieData objectForKey:@"Genre"];
    movie.imdbId = [movieData objectForKey:@"imdbID"];
    movie.year = year;
    movie.artworkPath = @"";
    movie.sourcePath = @"";
    movie.hd = [NSNumber numberWithBool:NO];
    
    return movie;
}

- (NSString *)getMetaStringWith:(Movie *)movie; {
    
    NSString *originalFilename = [movie.sourcePath lastPathComponent];    
    NSString *tags = @"{Artwork: %@}{HD Video:%@}{Name:%@}{Director:%@}{Cast:%@}{Genre:%@}{Release Date:%@}{Description:%@}{Long Description:%@}{Rating:%@}{Encoded By:imdbId:%@}{Media Kind:Movie}{Comments:Original filename %@}";

    NSString *tagged = [NSString stringWithFormat:tags, movie.artworkPath, movie.hd, movie.name, movie.director, movie.cast, movie.genre, movie.releaseDate, movie.plot, movie.plot, movie.rating, movie.imdbId, originalFilename];

    return tagged;
}

-(NSString *)description {
    return [NSString stringWithFormat:@"Movie: %@ (%@)", self.title, self.year];
}

@end
