//
//  ViewController.m
//  RottenTomatoes
//
//  Created by Sean Kemper on 10/20/15.
//  Copyright © 2015 Sean Kemper. All rights reserved.
//

#import "MoviesViewController.h"
#import "MoviesTableViewCell.h"
#import "UIImageView+AFNetworking.h"
#import "MovieDetailsViewController.h"
#import "Reachability.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import "MBProgressHUD.h"

@interface MoviesViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *movies;
@property (strong, nonatomic) NSMutableArray *filteredMovies;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UIView *networkingErrorView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic) BOOL networkError;

@end

@implementation MoviesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(onRefresh) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.searchBar.delegate = self;
    
    self.title = @"Movies";
    [self fetchMovies:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if ([searchText length] == 0) {
        self.filteredMovies = self.movies;
        [self.tableView reloadData];
    } else {
        self.filteredMovies = [[NSMutableArray alloc] init];
        for (NSDictionary *movie in self.movies) {
            if ([movie[@"title"] rangeOfString:searchText options:NSCaseInsensitiveSearch].location != NSNotFound) {
                NSLog(@"%@ contains %@", movie[@"title"], searchText);
                [self.filteredMovies addObject:movie];
            }
        }
        [self.tableView reloadData];
    }
}

- (void) onRefresh {
    [self fetchMovies:YES];
    self.searchBar.text = @"";
}

- (void)fetchMovies:(BOOL)endRefreshing {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSString *urlString = @"https://gist.githubusercontent.com/timothy1ee/d1778ca5b944ed974db0/raw/489d812c7ceeec0ac15ab77bf7c47849f2d1eb2b/gistfile1.json";
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    configuration.timeoutIntervalForRequest = 5;
    NSURLSession *session =
    [NSURLSession sessionWithConfiguration:configuration
                                  delegate:nil
                             delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:^(NSData * _Nullable data,
                                                                NSURLResponse * _Nullable response,
                                                                NSError * _Nullable error) {
                                                if (!error) {
                                                    self.networkError = NO;
                                                    NSError *jsonError = nil;
                                                    NSDictionary *responseDictionary =
                                                    [NSJSONSerialization JSONObjectWithData:data
                                                                                    options:kNilOptions
                                                                                      error:&jsonError];
                                                    NSLog(@"Response: %@", responseDictionary);
                                                    self.movies = responseDictionary[@"movies"];
                                                    self.filteredMovies = self.movies;
                                                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                                                    if (endRefreshing) {
                                                        [self.refreshControl endRefreshing];
                                                    }
                                                    [self.tableView reloadData];
                                                } else {
                                                    self.networkError = YES;
                                                    [self.tableView reloadData];
                                                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                                                    if (endRefreshing) {
                                                        [self.refreshControl endRefreshing];
                                                    }
                                                    NSLog(@"An error occurred: %@", error.description);
                                                }
                                            }];
    [task resume];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.networkError) {
        self.tableView.rowHeight = 60;
        return 1;
    }
    self.tableView.rowHeight = 130;
    return self.filteredMovies.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.networkError) {
        UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"networkError"];
        return cell;
    } else {
        MoviesTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"movieCell"];
        cell.titleLabel.text = self.filteredMovies[indexPath.row][@"title"];
        cell.synopsisLabel.text = [NSString stringWithFormat:@"%@ - %@", self.filteredMovies[indexPath.row][@"mpaa_rating"], self.filteredMovies[indexPath.row][@"synopsis"] ];
        NSURL *imageUrl = [NSURL URLWithString:self.filteredMovies[indexPath.row][@"posters"][@"thumbnail"]];
        //    NSLog(@"low res imageUrl for %@: %@", cell.titleLabel.text, imageUrl);
        //    [cell.posterImageView setImageWithURL:imageUrl];
        imageUrl = [self convertThumbnailToHighRes:self.filteredMovies[indexPath.row][@"posters"][@"thumbnail"]];
        //    NSLog(@"high res imageUrl for %@: %@", cell.titleLabel.text, imageUrl);
        [cell.posterImageView setImageWithURL:imageUrl];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    MovieDetailsViewController *vc = [[MovieDetailsViewController alloc] init];
    vc.movie = self.filteredMovies[indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
}

- (NSURL*)convertThumbnailToHighRes:(NSString*)thumbnail {
    NSRange range = [thumbnail rangeOfString:@".*cloudfront.net/"
                                     options:NSRegularExpressionSearch];
    NSString *newUrlString = [thumbnail stringByReplacingCharactersInRange:range
                                                                withString:@"https://content6.flixster.com/"];
    return [NSURL URLWithString:newUrlString];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
