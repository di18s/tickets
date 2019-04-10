//
//  Ticket.m
//  air_tickets
//
//  Created by Дмитрий on 05/04/2019.
//  Copyright © 2019 Dmitry. All rights reserved.
//

#import "Ticket.h"

@implementation Ticket

- (instancetype)initWithDictionary:(NSDictionary*)dictionary {
    self = [super self];
    if (self) {
        _airline = [dictionary valueForKey:@"airline"];
        _expires = dateWithString([dictionary valueForKey:@"expires_at"]);
        _departure = dateWithString([dictionary valueForKey:@"departure_at"]);
        _returnDate = dateWithString([dictionary valueForKey:@"return_at"]);
        _flightNumber = [dictionary valueForKey:@"flight_number"];
        _price = [dictionary valueForKey:@"price"];
        //_filterNum = 1;
    }
    return self;
}

NSDate *dateWithString(NSString *dateString) {
    if (!dateString) { return nil; }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSString *correctStringDate = [dateString stringByReplacingOccurrencesOfString:@"T" withString:@""];
    correctStringDate = [correctStringDate stringByReplacingOccurrencesOfString:@"Z" withString:@""];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    return [dateFormatter dateFromString:correctStringDate];
}

@end
