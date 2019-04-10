//
//  DataManager.m
//  air_tickets
//
//  Created by Дмитрий on 05/04/2019.
//  Copyright © 2019 Dmitry. All rights reserved.
//

#import "DataManager.h"

@interface DataManager()

@property (nonatomic, strong) NSMutableArray *countriesArray;
@property (nonatomic, strong) NSMutableArray *citiesArray;
@property (nonatomic, strong) NSMutableArray *airportsArray;

@end

@implementation DataManager

+ (instancetype)sharedInstance {
    static DataManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[DataManager alloc] init];
    });
    return instance;
}

- (void)loadData {
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0), ^{
        NSArray *countriesJsonArray = [self arrayFromFileName:@"countries" ofType:@"json"];
        self.countriesArray = [self createObjectsFromArray:countriesJsonArray withType:DataSourceTypeCountry];
        
        NSArray *citiesJsonArray = [self arrayFromFileName:@"cities" ofType:@"json"];
        self.citiesArray = [self createObjectsFromArray:citiesJsonArray withType:DataSourceTypeCity];
        
        NSArray *airportsJsonArray = [self arrayFromFileName:@"airports" ofType:@"json"];
        self.airportsArray = [self createObjectsFromArray:airportsJsonArray withType:DataSourceTypeAirport];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kDataManagerLoadDataDidComplete object:nil];
        });
        NSLog(@"Complete");
    });
}

- (NSMutableArray *)createObjectsFromArray:(NSArray *)array withType:(DataSourceType)type {
    NSMutableArray *results = [NSMutableArray new];
    
    for (NSDictionary *json in array) {
        if (type == DataSourceTypeCountry) {
            Country *country = [[Country alloc] initWithDictionary:json];
            [results addObject:country];
        }
        else if (type == DataSourceTypeCity) {
            City *city = [[City alloc] initWithDictionary:json];
            [results addObject:city];
        }
        else if (type == DataSourceTypeAirport) {
            Airport *air = [[Airport alloc] initWithDictionary:json];
            [results addObject:air];
        }
    }
    
    return results;
}

- (City*)cityForLocation:(CLLocation*)location {
    for (City *city in _citiesArray) {
        if (ceilf(city.coordinate.latitude) == ceilf(location.coordinate.latitude) && ceilf(city.coordinate.longitude) == ceilf(location.coordinate.longitude)) {
            return city;
        }
    }
    return nil;
}

- (NSArray *)arrayFromFileName:(NSString*)fileName ofType:(NSString*)type {
    NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:type];
    NSData *data = [NSData dataWithContentsOfFile:path];
    return [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
}

- (NSArray*)countries {
    return _countriesArray;
}

- (NSArray*)cities {
    return _citiesArray;
}

- (NSArray*)airports {
    return _citiesArray;
}

- (City*)cityForIATA:(NSString*)iata {
    if (iata) {
        for (City *city in _citiesArray) {
            if ([city.code isEqualToString:iata]) {
                return city;
            }
        }
    }
    return nil;
}

@end
