//
//  CoreDataHelper.m
//  Tickets
//
//  Created by Дмитрий on 03/04/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

#import "CoreDataHelper.h"

@interface CoreDataHelper ()
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSPersistentContainer *persistentContainer;
@end


@implementation CoreDataHelper

+ (instancetype)sharedInstance
{
    static CoreDataHelper *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[CoreDataHelper alloc] init];
        [instance setup];
    });
    return instance;
}
- (void)setup {
    self.persistentContainer = [[NSPersistentContainer alloc] initWithName:@"Tickets"];
    [self.persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *desc, NSError *error) {
        if (error != nil) {
            NSLog(@"Ошибка инита БД");
            abort();
        }
        self.managedObjectContext = self.persistentContainer.viewContext;
    }];
}

- (void)save {
    NSError *error;
    [_managedObjectContext save: &error];
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
    }
}

- (FavoriteTicket *)favoriteFromTicket:(Ticket *)ticket {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"FavoriteTicket"];
    request.predicate = [NSPredicate predicateWithFormat:@"price == %ld AND airline == %@ AND from == %@ AND to == %@ AND departure == %@ AND expires == %@ AND flightNumber == %ld", (long)ticket.price.integerValue, ticket.airline, ticket.from, ticket.to, ticket.departure, ticket.expires, (long)ticket.flightNumber.integerValue];
    return [[_managedObjectContext executeFetchRequest:request error:nil] firstObject];
}


- (BOOL)isFavorite:(Ticket *)ticket {
    return [self favoriteFromTicket:ticket] != nil;
}

- (void)addToFavorite:(Ticket *)ticket {
    FavoriteTicket *favorite = [NSEntityDescription insertNewObjectForEntityForName:@"FavoriteTicket" inManagedObjectContext:_managedObjectContext];
    favorite.price = ticket.price.intValue;
    favorite.airline = ticket.airline;
    favorite.departure = ticket.departure;
    favorite.expires = ticket.expires;
    favorite.flightNumber = ticket.flightNumber.intValue;
    favorite.returnDate = ticket.returnDate;
    favorite.from = ticket.from;
    favorite.to = ticket.to;
    favorite.filterNum = ticket.filterNum;
    favorite.created = [NSDate date];
    [self save];
}
- (void)addToFavoriteFromMap:(Ticket *)ticket {
    FavoriteTicket *favorite = [NSEntityDescription insertNewObjectForEntityForName:@"FavoriteTicket" inManagedObjectContext:_managedObjectContext];
    favorite.price = ticket.price.intValue;
    favorite.airline = ticket.airline;
    favorite.departure = ticket.departure;
    favorite.expires = ticket.expires;
    favorite.flightNumber = ticket.flightNumber.intValue;
    favorite.returnDate = ticket.returnDate;
    favorite.from = ticket.from;
    favorite.to = ticket.to;
    favorite.filterNum = ticket.filterNum;
    favorite.createdFromMap = [NSDate date];
    [self save];
}

- (void)removeFromFavorite:(Ticket *)ticket {
    FavoriteTicket *favorite = [self favoriteFromTicket:ticket];
    if (favorite) {
        [_managedObjectContext deleteObject:favorite];
        [self save];
    }
}
-(void)removeAll{
    for (NSManagedObject* i in self.favorites) {
        [_managedObjectContext deleteObject:i];
    }
    for (NSManagedObject* i in self.favoritesFromMap) {
        [_managedObjectContext deleteObject:i];
    }
    [self save];
}
- (NSMutableArray *)favorites {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"FavoriteTicket"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"created" ascending:NO]];
    
    NSMutableArray* filter = [[NSMutableArray alloc] initWithArray:[[_managedObjectContext executeFetchRequest:request error:nil]filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"filterNum == %i", 0]]];
    
    return filter;
}
- (NSMutableArray *)favoritesFromMap {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"FavoriteTicket"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"createdFromMap" ascending:NO]];
    
    NSMutableArray* filter1 = [[NSMutableArray alloc] initWithArray:[[_managedObjectContext executeFetchRequest:request error:nil]filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"filterNum == %i", 1]]];
    return filter1;
}



@end
