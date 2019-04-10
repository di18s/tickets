//
//  TicketsViewController.m
//  air_tickets
//
//  Created by Дмитрий on 05/04/2019.
//  Copyright © 2019 Dmitry. All rights reserved.
//

#import "TicketsViewController.h"
#import "TicketTableViewCell.h"
#import "CoreDataHelper.h"

#define TicketCellReuseIdentifier @"TicketCellIdentifier"


@interface TicketsViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) NSMutableArray *tickets;
@property (nonatomic, strong) UISegmentedControl* segmentedControl;

@end

@implementation TicketsViewController{
    BOOL isFavorites;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (isFavorites) {
        self.navigationController.navigationBar.prefersLargeTitles = YES;
        _tickets = [[CoreDataHelper sharedInstance] favorites];
        _ticketsFromMap = [[CoreDataHelper sharedInstance] favoritesFromMap];
        [self.tableView reloadData];
    }
}

- (instancetype)initWithTickets:(NSMutableArray *)tickets {
    self = [super init];
    if (self) {
        _tickets = tickets;
        self.title = @"Билеты";
    }
    return self;
}

- (instancetype)initFavoriteTicketsController {
    self = [super init];
    if (self) {
        isFavorites = YES;
        self.tickets = [NSMutableArray new];
        self.title = @"Избранное";
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.navigationItem setTitleView:_segmentedControl];
        [self.tableView registerClass:[TicketTableViewCell class] forCellReuseIdentifier:TicketCellReuseIdentifier];
        UIBarButtonItem *item=[[UIBarButtonItem alloc]
                               initWithTitle:@"Очистить"   style:UIBarButtonItemStylePlain
                               target:self  action:@selector(removeAllFavorites)];
        self.navigationItem.rightBarButtonItem = item;
    }
    return self;
}

- (instancetype)initFavoriteTicketsFromMapController {
    self = [super init];
    if (self) {
        isFavorites = YES;
        self.ticketsFromMap = [NSMutableArray new];
        
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerClass:[TicketTableViewCell class] forCellReuseIdentifier:TicketCellReuseIdentifier];
    [self.tableView setDataSource: self];
    [self.tableView setDelegate: self];
    
    _segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"Из поиска", @"Из карт"]];
    [_segmentedControl setTintColor:[UIColor blackColor]];
    [_segmentedControl addTarget:self action:@selector(changeSource) forControlEvents:UIControlEventValueChanged];
    [_segmentedControl setSelectedSegmentIndex:0];
    
}

-(void)removeAllFavorites{
    [[CoreDataHelper sharedInstance] removeAll];
    [self.tickets removeAllObjects];
    [self.ticketsFromMap removeAllObjects];
    [self.tableView reloadData];
}
- (void)changeSource {
    switch (_segmentedControl.selectedSegmentIndex) {
        case 0:
            [self.tableView reloadData];
            break;
        case 1:
            [self.tableView reloadData];
            break;
        default:
            break;
    }
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (self.segmentedControl.selectedSegmentIndex) {
        case 0:
            return _tickets.count;
            break;
        case 1:
            if (self.ticketsFromMap.count == 0) {
                self.segmentedControl.selectedSegmentIndex = 0;
                
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Внимание" message:@"Билетов из карт пока нет." preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Закрыть" style:UIAlertActionStyleCancel handler:nil];
                [alertController addAction:cancelAction];
                [self presentViewController:alertController animated:YES completion:nil];
                
                return self.tickets.count;
            }
            return self.ticketsFromMap.count;
            break;
        default:
            return 0;
            break;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath  {
    TicketTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TicketCellReuseIdentifier forIndexPath: indexPath];
    if (isFavorites && self.segmentedControl.selectedSegmentIndex == 0) {
        [cell setFavoriteTicket:[_tickets objectAtIndex:indexPath.row]];
    }
    if (isFavorites && self.segmentedControl.selectedSegmentIndex == 1) {
        [cell setFavoriteTicket:[self.ticketsFromMap objectAtIndex:indexPath.row]];
    }
    if (!isFavorites) {
        [cell setTicket:[_tickets objectAtIndex:indexPath.row]];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 140.0;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (isFavorites) return;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Действия с билетом" message:@"Что необходимо сделать с выбранным билетом?" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *favoriteAction;
    if ([[CoreDataHelper sharedInstance] isFavorite: [_tickets objectAtIndex:indexPath.row]]) {
        favoriteAction = [UIAlertAction actionWithTitle:@"Удалить из избранного" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [[CoreDataHelper sharedInstance] removeFromFavorite:[self.tickets objectAtIndex:indexPath.row]];
            
        }];
    } else {
        favoriteAction = [UIAlertAction actionWithTitle:@"Добавить в избранное" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[CoreDataHelper sharedInstance] addToFavorite:[self.tickets objectAtIndex:indexPath.row]];
        }];
    }
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Закрыть" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:favoriteAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.segmentedControl.selectedSegmentIndex == 0 && editingStyle == UITableViewCellEditingStyleDelete && [[CoreDataHelper sharedInstance] isFavorite: [self.tickets objectAtIndex:indexPath.row]]) {
        [[CoreDataHelper sharedInstance] removeFromFavorite:[self.tickets objectAtIndex:indexPath.row]];
        [self.tickets removeObjectAtIndex:indexPath.row];
        
    }
    if (self.segmentedControl.selectedSegmentIndex == 1 && editingStyle == UITableViewCellEditingStyleDelete) {
        [[CoreDataHelper sharedInstance] removeFromFavorite:[self.ticketsFromMap objectAtIndex:indexPath.row]];
        [self.ticketsFromMap removeObjectAtIndex:indexPath.row];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    cell.layer.transform = CATransform3DMakeRotation((90*3.14/180), 0, 1, 0);
    [UIView animateWithDuration:0.6 delay:0.4 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        cell.layer.transform = CATransform3DIdentity;
    } completion:nil];
}
@end

