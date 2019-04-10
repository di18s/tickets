//
//  APIManager.h
//  air_tickets
//
//  Created by Дмитрий on 05/04/2019.
//  Copyright © 2019 Dmitry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "City.h"
#import "PlaceViewController.h"

@interface APIManager : NSObject

- (void)cityForCurrentIP:(void (^)(City *city))completion;
+ (instancetype)sharedInstance;
- (void)ticketsWithRequest:(SearchRequest)request witnCompletion:(void (^)(NSArray *tickets))completion;
- (void)mapPricesFor:(City*)origin withCompletion:(void (^)(NSArray *prices))completion;

@end
