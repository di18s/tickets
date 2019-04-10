//
//  TicketTableViewCell.h
//  air_tickets
//
//  Created by Дмитрий on 05/04/2019.
//  Copyright © 2019 Dmitry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <YYWebImage/YYWebImage.h>
#import "Ticket.h"
#import "FavoriteTicket+CoreDataClass.h"

@interface TicketTableViewCell : UITableViewCell

@property (nonatomic, strong) UIImageView *airlineLogoView;
@property (nonatomic, strong) UILabel *priceLabel;
@property (nonatomic, strong) UILabel *placesLabel;
@property (nonatomic, strong) UILabel *dateLabel;

@property (nonatomic, strong) Ticket *ticket;
@property (nonatomic, strong) FavoriteTicket *favoriteTicket;



@end
