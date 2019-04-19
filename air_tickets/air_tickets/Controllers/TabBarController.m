//
//  TabBarController.m
//  air_tickets
//
//  Created by Дмитрий on 05/04/2019.
//  Copyright © 2019 Dmitry. All rights reserved.
//

#import "TabBarController.h"
#import "MainViewController.h"
#import "MapViewController.h"
#import "TicketsViewController.h"

@implementation TabBarController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.viewControllers = [self createViewControllers];
        self.tabBar.tintColor = [UIColor blackColor];
        //self.tabBar.backgroundImage = [UIImage imageNamed:@"air"];
       // self.tabBar.selectionIndicatorImage = [UIImage imageNamed:@"favorite"];
    }
    return self;
}

- (NSArray<UIViewController*>*)createViewControllers {
    NSMutableArray<UIViewController*> *controllers = [NSMutableArray new];
    
    MainViewController *main = [[MainViewController alloc] init];
    main.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Search", @"")
                                                    image:[UIImage imageNamed:@"search"]
                                            selectedImage:[UIImage imageNamed:@"search_selected"]];
    UINavigationController *mainNav = [[UINavigationController alloc] initWithRootViewController:main];
    mainNav.navigationBar.prefersLargeTitles = true;
    [controllers addObject:mainNav];
    
    MapViewController *map = [[MapViewController alloc] init];
    map.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Map price", @"")
                                                   image:[UIImage imageNamed:@"map"]
                                           selectedImage:[UIImage imageNamed:@"map_selected"]];
    UINavigationController *mapNav = [[UINavigationController alloc] initWithRootViewController:map];
    [controllers addObject:mapNav];
    
    TicketsViewController *ticket = [[TicketsViewController alloc] initFavoriteTicketsController];
    ticket.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Favorite", @"")
                                                      image:[UIImage imageNamed:@"favorite"]
                                              selectedImage:[UIImage imageNamed:@"favorite_selected"]];
    UINavigationController *ticketNav = [[UINavigationController alloc] initWithRootViewController:ticket];
    
    [controllers addObject:ticketNav];
    
    return controllers;
}

@end

