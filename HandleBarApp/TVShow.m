//
//  TVShow.m
//  HandleBarApp
//
//  Created by Johan Kuijt on 19-03-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import "TVShow.h"
#import "iTVdb.h"
#import "Util.h"

@implementation TVShow

@synthesize title, image, name, season, episode, episodeId, plot, rating, releaseDate, network, cast, genre, imdbId, year, artworkPath, sourcePath, hd;

+ (TVShow *)getShow:(NSDictionary *)showData {
    
    NSDictionary *config = [Util getConfigFile];
    NSString *showName = [showData objectForKey:@"series"];
    
    [[TVDbClient sharedInstance] setApiKey:[config objectForKey:@"tvdbApiKey"]];
    NSMutableArray *shows = [TVDbShow findByName:showName];
    
    if([shows count] == 0)
        return nil;
    
    TVDbShow *showResult = [shows objectAtIndex:0];
    showResult = [TVDbShow findById:showResult.showId];
    
    TVDbEpisode *episode = [TVDbEpisode findByShowId:showResult.showId seasonNumber:[showData objectForKey:@"season"] episodeNumber:[showData objectForKey:@"episodeNumber"]];
    
    if(episode.title == nil)
        return nil;
    
    TVShow *show = [TVShow new];
    show.title = showResult.title;
    show.image = showResult.poster;
    show.name = episode.title;
    show.season = [episode.seasonNumber description];
    show.episode = [episode.episodeNumber description];
    show.episodeId = [episode.episodeId description];
    show.plot = episode.description;
    show.rating = showResult.contentRating;
    show.releaseDate = [episode.premiereDate description];
    show.network = showResult.network;
    show.cast = [showResult.actors componentsJoinedByString:@","];
    show.genre = [showResult.genre componentsJoinedByString:@","];
    show.imdbId = showResult.imdbId;
    show.artworkPath = @"";
    show.sourcePath = @"";
    show.hd = [NSNumber numberWithBool:NO];

    return show;
}

- (NSString *)getMetaStringWith:(TVShow *)show; {
     
    NSString *originalFilename = [show.sourcePath lastPathComponent];
    NSString *tags = @"{Artwork: %@}{HD Video:%@}{TV Show:%@}{Name:%@}{TV Episode #:%@}{TV Season:%@}{TV Episode ID:%@}{TV Network:%@}{Cast:%@}{Genre:%@}{Release Date:%@}{Description:%@}{Long Description:%@}{Rating:%@}{Encoded By:imdbId:%@}{Media Kind:TV Show}{Comments:Original filename %@}";
    
    NSString *tagged = [NSString stringWithFormat:tags, show.artworkPath, show.hd, show.title, show.name, show.episode, show.season, show.episodeId, show.network, show.cast, show.genre, show.releaseDate, show.plot, show.plot, show.rating, show.imdbId, originalFilename];

    return tagged;
}

-(NSString *)description {
    return [NSString stringWithFormat:@"TV Show: %@ S%@E%@ - %@)", self.title, self.season, self.episode, self.name];
}

@end
