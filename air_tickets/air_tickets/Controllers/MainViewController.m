//
//  MainViewController.m
//  air_tickets
//
//  Created by Дмитрий on 05/04/2019.
//  Copyright © 2019 Dmitry. All rights reserved.
//

#import "MainViewController.h"
#import "DataManager.h"
#import "PlaceViewController.h"
#import "APIManager.h"
#import "TicketsViewController.h"

@interface MainViewController () <PlaceViewControllerDelegate>

@property (nonatomic, strong) UIButton *departureButton;
@property (nonatomic, strong) UIButton *arrivalButton;
@property (nonatomic) SearchRequest searchRequest;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    
    [self setTitle:@"Поиск"];
    
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(50, 200, self.view.bounds.size.width - 100, 150)];
    [container setBackgroundColor:[UIColor whiteColor]];
    [container.layer setCornerRadius:4];
    [self.view addSubview:container];
    
    _departureButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, container.bounds.size.width - 20, 50)];
    [_departureButton setTitle:@"Откуда" forState:UIControlStateNormal];
    [_departureButton.layer setCornerRadius:4];
    [_departureButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_departureButton setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    [_departureButton addTarget:self action:@selector(departureButtonTap) forControlEvents:UIControlEventTouchUpInside];
    [container addSubview:_departureButton];
    
    _arrivalButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 70, container.bounds.size.width - 20, 50)];
    [_arrivalButton setTitle:@"Куда" forState:UIControlStateNormal];
    [_arrivalButton.layer setCornerRadius:4];
    [_arrivalButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_arrivalButton setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    [_arrivalButton addTarget:self action:@selector(arrivalButtonTap) forControlEvents:UIControlEventTouchUpInside];
    [container addSubview:_arrivalButton];
    
    UIButton *searchButton = [[UIButton alloc] initWithFrame:CGRectMake(50, 400, self.view.bounds.size.width - 100, 50)];
    [searchButton setBackgroundColor:[UIColor blackColor]];
    [searchButton setTitle:@"Найти" forState:UIControlStateNormal];
    [searchButton.layer setCornerRadius:4];
    [searchButton addTarget:self action:@selector(searchButtonTap) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:searchButton];
    
    [[DataManager sharedInstance] loadData];
    [[APIManager sharedInstance] cityForCurrentIP:^(City *city) {
        [self setPlace:city withType:PlaceTypeDeparture andDataType:DataSourceTypeCity forButton:self.departureButton];
    }];
}

- (void)searchButtonTap {
    [[APIManager sharedInstance] ticketsWithRequest:_searchRequest witnCompletion:^(NSArray *tickets) {
        TicketsViewController *vc = [[TicketsViewController alloc] initWithTickets:tickets];
        [UIView transitionFromView:self.view toView:vc.view duration:0.6 options:UIViewAnimationOptionTransitionCrossDissolve completion:nil];
        [self.navigationController pushViewController:vc animated:true];
        
    }];
}

- (void)departureButtonTap {
    PlaceViewController *vc = [[PlaceViewController alloc] initWithType:PlaceTypeDeparture];
    [vc setDelegate:self];
    [UIView transitionFromView:self.view toView:vc.view duration:0.6 options:UIViewAnimationOptionTransitionCurlUp completion:nil];
    [self.navigationController pushViewController:vc animated:true];
}

- (void)arrivalButtonTap {
    PlaceViewController *vc = [[PlaceViewController alloc] initWithType:PlaceTypeArrival];
    [vc setDelegate:self];
    
    [UIView transitionFromView:self.view toView:vc.view duration:0.9 options:UIViewAnimationOptionTransitionCurlUp completion:nil];
    [self.navigationController pushViewController:vc animated:true];
}

- (void)setPlace:(id)place withType:(PlaceType)placeType andDataType:(DataSourceType)dataType forButton:(UIButton*)button {
    NSString *name = @"";
    NSString *iata = @"";
    
    if (dataType == DataSourceTypeCity) {
        City *city = place;
        name = city.name;
        iata = city.code;
    } else if ( dataType == DataSourceTypeAirport ) {
        Airport *airport = place;
        name = airport.name;
        iata = airport.cityCode;
    }
    
    if (placeType == PlaceTypeDeparture) {
        // Отправление
        _searchRequest.origin = iata;
    } else {
        // Прибытие
        _searchRequest.destination = iata;
    }
    
    [button setTitle:name forState:UIControlStateNormal];
}

- (void)selectPlace:(id)place withType:(PlaceType)placeType andDataType:(DataSourceType)dataType {
    [self setPlace:place withType:place andDataType:dataType forButton:(placeType == PlaceTypeDeparture) ? _departureButton : _arrivalButton];
}

@end

