//
//  Airport.m
//  air_tickets
//
//  Created by Дмитрий on 05/04/2019.
//  Copyright © 2019 Dmitry. All rights reserved.
//

#import "Airport.h"

@implementation Airport

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    _name = [dictionary valueForKey:@"name"];
    _timezone = [dictionary valueForKey:@"time_zone"];
    _translations = [dictionary valueForKey:@"name_translations"];
    _countryCode = [dictionary valueForKey:@"country_code"];
    _code = [dictionary valueForKey:@"code"];
    _cityCode = [dictionary valueForKey:@"city_code"];
    _flightable = [dictionary valueForKey:@"flightable"];
    
    NSDictionary *coords = [dictionary valueForKey:@"coordinates"];
    if (coords && ![coords isEqual:[NSNull null]]) {
        NSNumber *lon = [coords valueForKey:@"lon"];
        NSNumber *lat = [coords valueForKey:@"lat"];
        if (![lon isEqual:[NSNull null]] && ![lat isEqual:[NSNull null]]) {
            _coodinate = CLLocationCoordinate2DMake([lat doubleValue], [lon doubleValue]);
        }
    }
    
    return self;
}

@end
