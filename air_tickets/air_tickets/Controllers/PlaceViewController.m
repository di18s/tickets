//
//  PlaceViewController.m
//  air_tickets
//
//  Created by Дмитрий on 05/04/2019.
//  Copyright © 2019 Dmitry. All rights reserved.
//

#import "PlaceViewController.h"
#import "DataManager.h"

#define CellIdentifier @"CellIdentifier"

@interface PlaceViewController () <UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating>

@property (nonatomic) PlaceType placeType;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UISegmentedControl *segmentedControl;
@property (nonatomic, strong) NSArray *items;

@property (nonatomic, strong) UISearchController *searchVC;
@property (nonatomic, strong) NSArray *serachItems;

@end

@implementation PlaceViewController

- (instancetype)initWithType:(PlaceType)type {
    self = [super init];
    if (self) {
        _placeType = type;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.hidesSearchBarWhenScrolling = false;
    
    self.title = @"Поиск";
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    _searchVC = [[UISearchController alloc] initWithSearchResultsController:nil];
    _searchVC.dimsBackgroundDuringPresentation = false;
    _searchVC.searchResultsUpdater = self;
    _serachItems = [NSArray new];
    
    self.navigationItem.searchController = _searchVC;
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [_tableView setDataSource:self];
    [_tableView setDelegate:self];
    [self.view addSubview:_tableView];
    
    _segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"Города", @"Аэропорты"]];
    [_segmentedControl setTintColor:[UIColor blackColor]];
    [_segmentedControl addTarget:self action:@selector(changeSource) forControlEvents:UIControlEventValueChanged];
    [_segmentedControl setSelectedSegmentIndex:0];
    
    [self.navigationItem setTitleView:_segmentedControl];
    
    
    [self changeSource];
}

- (void)changeSource {
    switch (_segmentedControl.selectedSegmentIndex) {
        case 0:
            _items = [[DataManager sharedInstance] cities];
            break;
        case 1:
            _items = [[DataManager sharedInstance] airports];
            break;
        default:
            break;
    }
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_searchVC.isActive && [_serachItems count] > 0) {
        return [_serachItems count];
    }
    return [_items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if (_segmentedControl.selectedSegmentIndex == 0) {
        // Cities
        City *city = (_searchVC.isActive && [_serachItems count] > 0) ? [_serachItems objectAtIndex:indexPath.row] : [_items objectAtIndex:indexPath.row];
        [cell.textLabel setText:city.name];
        [cell.detailTextLabel setText:city.code];
    } else if (_segmentedControl.selectedSegmentIndex == 1) {
        // Airports
        Airport *airport = (_searchVC.isActive && [_serachItems count] > 0) ? [_serachItems objectAtIndex:indexPath.row] : [_items objectAtIndex:indexPath.row];
        [cell.textLabel setText:airport.name];
        [cell.detailTextLabel setText:airport.code];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_segmentedControl.selectedSegmentIndex == 0) {
        // Cities
        City *city = (_searchVC.isActive && [_serachItems count] > 0) ? [_serachItems objectAtIndex:indexPath.row] : [_items objectAtIndex:indexPath.row];
        [self.delegate selectPlace:city withType:_placeType andDataType:DataSourceTypeCity];
    } else if (_segmentedControl.selectedSegmentIndex == 1) {
        // Airports
        Airport *airport = (_searchVC.isActive && [_serachItems count] > 0) ? [_serachItems objectAtIndex:indexPath.row] : [_items objectAtIndex:indexPath.row];
        [self.delegate selectPlace:airport withType:_placeType andDataType:DataSourceTypeAirport];
    }
    [self.navigationController popViewControllerAnimated:true];
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    if (searchController.searchBar.text) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.name CONTAINS[cd]%@", searchController.searchBar.text];
        _serachItems = [_items filteredArrayUsingPredicate:predicate];
        [_tableView reloadData];
    }
}

@end

