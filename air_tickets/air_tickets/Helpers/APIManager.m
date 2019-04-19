//
//  APIManager.m
//  air_tickets
//
//  Created by Дмитрий on 05/04/2019.
//  Copyright © 2019 Dmitry. All rights reserved.
//

#import "APIManager.h"
#import "DataManager.h"
#import "PlaceViewController.h"
#import "Ticket.h"
#import "MapPrice.h"

#define API_TOKEN @"e31e621dc03d3d219fb575b9d269f62c"
#define API_URL_CHEAP @"https://api.travelpayouts.com/v1/prices/cheap"
#define API_URL_IP_ADDRESS @"https://api.ipify.org/?format=json"
#define API_URL_CITY_FROM_IP @"https://www.travelpayouts.com/whereami?ip="
#define API_URL_MAP_PRICE @"https://map.aviasales.ru/prices.json?origin_iata="

@implementation APIManager

+ (instancetype)sharedInstance {
    static APIManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[APIManager alloc] init];
    });
    return instance;
}

- (void)cityForCurrentIP:(void (^)(City *))completion {
    [self iPAddressWithCompletion:^(NSString *ipAddress) {
        NSString *url = [NSString stringWithFormat:@"%@%@", API_URL_CITY_FROM_IP, ipAddress];
        [self load:url withCompletion:^(id  _Nullable result) {
            NSDictionary *json = result;
            NSString *iata = [json objectForKey:@"iata"];
            if (iata) {
                City *city = [[DataManager sharedInstance] cityForIATA:iata];
                if (city) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(city);
                    });
                }
            }
        }];
    }];
}



- (void)mapPricesFor:(City*)origin withCompletion:(void (^)(NSArray *prices))completion {
    static BOOL isLoading;
    if (isLoading) {
        return;
    }
    isLoading = true;
    [self load:[NSString stringWithFormat:@"%@%@", API_URL_MAP_PRICE, origin.code] withCompletion:^(id  _Nullable result) {
        NSArray *array = result;
        NSMutableArray *prices = [NSMutableArray new];
        if (array) {
            for (NSDictionary *mapPriceDictionary in array) {
                MapPrice *price = [[MapPrice alloc]initWithDictionary:mapPriceDictionary withOrigin:origin];
                [prices addObject:price];
            }
            isLoading = false;
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(prices);
            });
        }
    }];
}

- (void)iPAddressWithCompletion:(void(^)(NSString *ipAddress))completion {
    [self load:API_URL_IP_ADDRESS withCompletion:^(id  _Nullable result) {
        NSDictionary *json = result;
        completion([json valueForKey:@"ip"]);
    }];
}

- (void)ticketsWithRequest:(SearchRequest)request witnCompletion:(void (^)(NSArray *tickets))completion {
    NSString *urlString = [NSString stringWithFormat:@"%@?%@&token=%@", API_URL_CHEAP, SeacrchRequestQuery(request), API_TOKEN];
    [self load:urlString withCompletion:^(id  _Nullable result) {
        NSDictionary *respose = result;
        if (respose) {
            NSDictionary *json = [[respose valueForKey:@"data"] valueForKey:request.destination];
            NSMutableArray *array = [NSMutableArray new];
            for (NSString *key in json) {
                NSDictionary *value = [json valueForKey: key];
                Ticket *ticket = [[Ticket alloc] initWithDictionary:value];
                ticket.from = request.origin;
                ticket.to = request.destination;
                ticket.filterNum = 0;
                [array addObject:ticket];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(array);
            });
        }
    }];
}

NSString *SeacrchRequestQuery(SearchRequest request) {
    NSString *result = [NSString stringWithFormat:@"origin=%@&destination=%@", request.origin, request.destination];
    if (request.departDate && request.returnDate) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM";
//        result = [NSString stringWithFormat:@"%@&depart_date=%@&return_date=%@", result, [dateFormatter stringFromDate:[NSDate new]], [dateFormatter stringFromDate:[NSDate new]]];
        
        result = [NSString stringWithFormat:@"%@&depart_date=%@&return_date=%@", result, [dateFormatter stringFromDate:request.departDate], [dateFormatter stringFromDate:request.returnDate]];

        
    }
    return result;
}

- (void)load:(NSString*)urlString withCompletion:(void (^)(id _Nullable result))completion {
    //создаем сессию
    NSURLSession *session = [NSURLSession sharedSession];
    //создаем задачу для сессии
    NSURLSessionTask *task = [session dataTaskWithURL:[NSURL URLWithString:urlString]
                                    completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                        //преобразуем данные полученные с сервера в джейсон
                                        id serializtion = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                                        //и потом будем работать с этими данными из комплишена
                                        completion(serializtion);
                                    }];
    [task resume];
}

@end

