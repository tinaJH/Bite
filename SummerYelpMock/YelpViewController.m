//
//  ViewController.m
//  SummerYelpMock
//
//  Created by Jinhua Xiong on 8/26/17.
//  Copyright © 2017 Jinhua Xiong. All rights reserved.
//

#import "YelpViewController.h"
#import "YelpDataModel.h"
#import "YelpNetworking.h"

#import "YelpTableViewCell.h"

@import CoreLocation;

@interface YelpViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic) UITableView *tableView;
@property (nonatomic, copy) NSArray <YelpDataModel *>*dataModels;
@property (nonatomic) UISearchBar *searchBar;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    CLLocation *loc
    = [[CLLocation alloc] initWithLatitude:37.3263625 longitude:-122.027210];

    [[YelpNetworking sharedInstance] fetchRestaurantsBasedOnLocation:loc term:@"restaurant" completionBlock:^(NSArray<YelpDataModel *> *dataModelArray) {
        self.dataModels = dataModelArray;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"settings"] style:UIBarButtonItemStylePlain target:self action:@selector(didTapSettings)];
    
    //     Setup search bar
    self.searchBar = [[UISearchBar alloc] init];
    self.searchBar.delegate = self;
    self.searchBar.tintColor = [UIColor lightGrayColor];
    self.navigationItem.titleView = self.searchBar;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"YelpTableViewCell" bundle:nil] forCellReuseIdentifier:@"YelpTableViewCell"];


}


#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

#pragma mark - UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    YelpTableViewCell *cell =  [tableView dequeueReusableCellWithIdentifier:@"YelpTableViewCell"];
    
    [cell updateBasedOnDataModel:self.dataModels[indexPath.row]];
    return cell;

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataModels count];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UISearchBarDelegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    [self.view endEditing:YES];
    CLLocation *loc = [[CLLocation alloc] initWithLatitude:37.3263625 longitude:-122.027210];
    
    // the following code the key that we can finally make our table be able to search based on user’s input
    
    [[YelpNetworking sharedInstance] fetchRestaurantsBasedOnLocation:loc term:searchBar.text completionBlock:^(NSArray<YelpDataModel *> *dataModelArray) {
        self.dataModels = dataModelArray;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }];
}

// Reset search bar state after cancel button clicked
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    [self.view endEditing:YES];
}
     

@end
