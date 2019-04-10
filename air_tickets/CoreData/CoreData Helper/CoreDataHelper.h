//
//  CoreDataHelper.h
//  Tickets
//
//  Created by Дмитрий on 03/04/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "DataManager.h"
#import "FavoriteTicket+CoreDataClass.h"
#import "Ticket.h"


NS_ASSUME_NONNULL_BEGIN

@interface CoreDataHelper : NSObject
+ (instancetype)sharedInstance;

- (BOOL)isFavorite:(Ticket *)ticket;
- (NSMutableArray *)favorites;
- (NSMutableArray *)favoritesFromMap;
- (void)addToFavorite:(Ticket *)ticket;
- (void)addToFavoriteFromMap:(Ticket *)ticket;
- (void)removeFromFavorite:(Ticket *)ticket;

-(void)removeAll;
@end

NS_ASSUME_NONNULL_END
