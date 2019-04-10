//
//  TicketTableViewCell.m
//  air_tickets
//
//  Created by Дмитрий on 05/04/2019.
//  Copyright © 2019 Dmitry. All rights reserved.
//

#import "TicketTableViewCell.h"
#import "Ticket.h"

@implementation TicketTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.layer.shadowColor = [[[UIColor blackColor] colorWithAlphaComponent:0.2] CGColor];
        self.contentView.layer.shadowOffset = CGSizeMake(1.0, 1.0);
        self.contentView.layer.shadowRadius = 10.0;
        self.contentView.layer.shadowOpacity = 1.0;
        self.contentView.layer.cornerRadius = 6.0;
        self.contentView.backgroundColor = [UIColor whiteColor];
        
        _priceLabel = [[UILabel alloc] initWithFrame:self.bounds];
        _priceLabel.font = [UIFont systemFontOfSize:24.0 weight:UIFontWeightBold];
        [self.contentView addSubview:_priceLabel];
        
        _airlineLogoView = [[UIImageView alloc] initWithFrame:self.bounds];
        _airlineLogoView.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:_airlineLogoView];
        
        _placesLabel = [[UILabel alloc] initWithFrame:self.bounds];
        _placesLabel.font = [UIFont systemFontOfSize:15.0 weight:UIFontWeightLight];
        _placesLabel.textColor = [UIColor darkGrayColor];
        [self.contentView addSubview:_placesLabel];
        
        _dateLabel = [[UILabel alloc] initWithFrame:self.bounds];
        _dateLabel.font = [UIFont systemFontOfSize:15.0 weight:UIFontWeightRegular];
        [self.contentView addSubview:_dateLabel];
        
        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.contentView.frame = CGRectMake(10.0, 10.0, [UIScreen mainScreen].bounds.size.width - 20.0, self.frame.size.height - 20.0);
    _priceLabel.frame = CGRectMake(10.0, 10.0, self.contentView.frame.size.width - 110.0, 40.0);
    _airlineLogoView.frame = CGRectMake(CGRectGetMaxX(_priceLabel.frame) + 10.0, 10.0, 80.0, 80.0);
    _placesLabel.frame = CGRectMake(10.0, CGRectGetMaxY(_priceLabel.frame) + 16.0, 260.0, 20.0);
    _dateLabel.frame = CGRectMake(10.0, CGRectGetMaxY(_placesLabel.frame) + 8.0, self.contentView.frame.size.width - 20.0, 20.0);
}

- (void)setTicket:(Ticket *)ticket {
    if (ticket) {
        _priceLabel.text = [NSString stringWithFormat:@"%@ руб", ticket.price];
        _placesLabel.text = [NSString stringWithFormat:@"%@ - %@", ticket.from, ticket.to];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"dd MMMM yyyy hh:mm";
        _dateLabel.text = [formatter stringFromDate:ticket.departure];
        NSURL *logoURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://pics.avs.io/200/200/%@.png", ticket.airline]];
        [_airlineLogoView yy_setImageWithURL:logoURL options:YYWebImageOptionSetImageWithFadeAnimation];
    }
}
-(void)setFavoriteTicket:(FavoriteTicket *)favoriteTicket{
    if (favoriteTicket) {
        _priceLabel.text = [NSString stringWithFormat:@"%lld руб", favoriteTicket.price];
        _placesLabel.text = [NSString stringWithFormat:@"%@ - %@", favoriteTicket.from, favoriteTicket.to];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"dd MMMM yyyy hh:mm";
        _dateLabel.text = [formatter stringFromDate:favoriteTicket.departure];
        NSURL *logoURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://pics.avs.io/200/200/%@.png", favoriteTicket.airline]];
        [_airlineLogoView yy_setImageWithURL:logoURL options:YYWebImageOptionSetImageWithFadeAnimation];
    }
}

@end

