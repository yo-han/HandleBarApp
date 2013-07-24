//
//  IMDB.m
//  Traktable
//
//  Created by Johan Kuijt on 13-02-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import "IMDB.h"

#define kIMDBSpecificSearch @"t"
#define kIMDBFuzzySearch @"s"
#define kIMDBIdSearch @"i"

@interface IMDB()

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *year;

- (NSDictionary *)callAPI:(NSString *)type;

@end

@implementation IMDB

@synthesize title=_title;
@synthesize year=_year;

- (id) initWithTitle:(NSString *)title year:(NSString *)year {

    self = [super init];
	if (self)
	{
        _title = title;
        _year = year;
    }
    
    return self;
}

- (NSDictionary *)callAPI:(NSString *)type {

    NSString *requestUrl = [NSString stringWithFormat:@"http://www.omdbapi.com/?%@=%@&y=%@&plot=full", type, [self.title stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding], self.year];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:requestUrl]];
    [request setHTTPMethod: @"GET"];
    
    NSURLResponse *response = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];

    if(data == nil)
        return nil;
    
    NSError *errorJSON;
    NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&errorJSON];

    if([[responseDict objectForKey:@"Response"] isEqualToString:@"False"])
        return nil;
    
    return responseDict;
}

- (NSDictionary *) doFuzzySearch {
    
    NSDictionary *fuzzyData;
    NSArray *list;
    
    fuzzyData = [self callAPI:kIMDBFuzzySearch];
    list = [fuzzyData objectForKey:@"Search"];
    
    if(fuzzyData == nil || list == nil)
        return nil;
    
    if([list count] == 0)
        return nil;
    
    NSArray *movies = [list filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(Type == %@)", @"movie"]];
    
    if([movies count] == 0)
        return nil;
    
    return [movies objectAtIndex:0];
}

- (NSDictionary * )getMovieData {
    
    NSDictionary *data;
    data = [self callAPI:kIMDBSpecificSearch];
    
    if(data != nil) {
        return data;
    } else {
        
        NSDictionary *fuzzyData = [self doFuzzySearch];
        _title = [fuzzyData objectForKey:@"imdbID"];
        
        data = [self callAPI:kIMDBIdSearch];
    }
    
    return data;
}

@end
