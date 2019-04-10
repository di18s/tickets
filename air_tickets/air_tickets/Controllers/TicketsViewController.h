//
//  TicketsViewController.h
//  air_tickets
//
//  Created by Дмитрий on 05/04/2019.
//  Copyright © 2019 Dmitry. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TicketsViewController : UITableViewController
@property (nonatomic, strong) NSString *code;
@property (nonatomic, strong) NSString *price;
@property (nonatomic, strong) NSMutableArray *ticketsFromMap;


- (instancetype)initWithTickets:(NSArray *)tickets;
- (instancetype)initFavoriteTicketsController;
- (instancetype)initFavoriteTicketsFromMapController;
@end
