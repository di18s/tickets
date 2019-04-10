//
//  MapViewController.m
//  air_tickets
//
//  Created by Дмитрий on 05/04/2019.
//  Copyright © 2019 Dmitry. All rights reserved.
//

#import "MapViewController.h"
#import <MapKit/MapKit.h>
#import "LocationService.h"
#import "City.h"
#import "DataManager.h"
#import <CoreLocation/CoreLocation.h>
#import "ApiManager.h"
#import "MapPrice.h"
#import "TicketsViewController.h"
#import "CoreDataHelper.h"
#import "Ticket.h"

@interface MapViewController () <MKMapViewDelegate>

@property (nonatomic, strong) LocationService *service;
@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) City *origin;
@property (nonatomic, strong) NSArray *prices;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    CGRect frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    
    _mapView = [[MKMapView alloc] initWithFrame:frame];
    _mapView.showsUserLocation = true;
    [self.view addSubview:_mapView];
    [self.mapView setDelegate:self];
    
    [[DataManager sharedInstance] loadData];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(dataLoadedSuccessfully) name:kDataManagerLoadDataDidComplete object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateCurrentLocation:) name:kLocationServiceDidUpdateCurrentLocation object:nil];
}

- (void)dataLoadedSuccessfully {
    _service = [[LocationService alloc] init];
}

- (void)updateCurrentLocation:(NSNotification*)notification {
    CLLocation *currentLocation = notification.object;
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(currentLocation.coordinate, 1000000, 1000000);
    [_mapView setRegion:region];
    
    if (currentLocation) {
        _origin = [[DataManager sharedInstance]cityForLocation:currentLocation];
        if (_origin) {
            [[APIManager sharedInstance] mapPricesFor:_origin withCompletion:^(NSArray *prices) {
                [self setPrices:prices];
            }];
        }
    }
}
-(void)setPrices:(NSArray *)prices {
    [_mapView removeAnnotations:_mapView.annotations];
    
    for (MapPrice *price in prices) {
        dispatch_async(dispatch_get_main_queue(), ^{
            MKPointAnnotation *anntotaion = [[MKPointAnnotation alloc] init];
            anntotaion.title = [NSString stringWithFormat:@"%@ (%@)", price.destination.name, price.destination.code];
            anntotaion.subtitle =  [NSString stringWithFormat:@"%ld руб", (long)price.value];
            anntotaion.coordinate = price.destination.coordinate;
            [self.mapView addAnnotation:anntotaion];
        });
    }
}
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    MKAnnotationView *annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"loc"];
    annotationView.canShowCallout = YES;
    annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    
    return annotationView;
}
- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view{
    NSLog(@"Annotation clicked didselect");
    TicketsViewController * ticketsVC = [[TicketsViewController alloc] initFavoriteTicketsFromMapController];
    Ticket *ticket = [[Ticket alloc] init];
    ticket.price = [NSNumber numberWithInteger:view.annotation.subtitle.integerValue];
    ticket.to = view.annotation.title;
    ticket.from = [NSString stringWithFormat:@"%@ (%@)", self.origin.name, self.origin.code];
    ticket.filterNum = 1;
    [ticketsVC.ticketsFromMap addObject:ticket];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Действия с билетом" message:@"Что необходимо сделать с выбранным билетом?" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *favoriteAction;
    if ([[CoreDataHelper sharedInstance] isFavorite: ticket]) {
        favoriteAction = [UIAlertAction actionWithTitle:@"Удалить из избранного" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [[CoreDataHelper sharedInstance] removeFromFavorite:ticket];
        }];
    } else {
        favoriteAction = [UIAlertAction actionWithTitle:@"Добавить в избранное" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[CoreDataHelper sharedInstance] addToFavoriteFromMap:ticket];
        }];
    }
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Закрыть" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:favoriteAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)selectAnnotation:(id <MKAnnotation>)annotation animated:(BOOL)animated{
    NSLog(@"Annotation clicked select");
    animated = YES;
    TicketsViewController * ticketsVC = [[TicketsViewController alloc] initFavoriteTicketsController];
    Ticket *ticket = [[Ticket alloc] init];
    ticket.price = [NSNumber numberWithInteger:annotation.subtitle.integerValue];
    ticket.to = annotation.title;
    ticket.from = [NSString stringWithFormat:@"%@ - %@", self.origin.name, self.origin.code];
    [ticketsVC.ticketsFromMap addObject:ticket];
    [[CoreDataHelper sharedInstance] addToFavorite:ticket];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Внимание" message:@"Билет успешно добавлен" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Ок" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)deselectAnnotation:(nullable id <MKAnnotation>)annotation animated:(BOOL)animated{
    NSLog(@"Annotation clicked deselect");
}
@end

