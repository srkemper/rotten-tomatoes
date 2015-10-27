//
//  MovieDetailsViewController.m
//  Pods
//
//  Created by Sean Kemper on 10/20/15.
//
//

#import "MovieDetailsViewController.h"
#import "UIImageView+AFNetworking.h"

@interface MovieDetailsViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *movieDetailsScrollView;
@property (weak, nonatomic) IBOutlet UIImageView *movieDetailsImage;
@property (weak, nonatomic) IBOutlet UILabel *synopsisLabel;

- (NSURL*)convertThumbnailToHighRes:(NSString*)thumbnail;
@end

@implementation MovieDetailsViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [self.navigationItem setTitle:self.movie[@"title"]];
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
//    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
//                             forBarMetrics:UIBarMetricsDefault];
//    self.navigationController.navigationBar.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.9];
    
    NSURL *imageUrl = [self convertThumbnailToHighRes:self.movie[@"posters"][@"thumbnail"]];
    [self.movieDetailsImage setImageWithURL:imageUrl];
    self.synopsisLabel.text = [NSString stringWithFormat:@"%@ (%@) - %@\n\n%@", self.movie[@"title"], self.movie[@"year"], self.movie[@"mpaa_rating"], self.movie[@"synopsis"]];
    [self.synopsisLabel sizeToFit];
    self.movieDetailsScrollView.contentSize = CGSizeMake(self.movieDetailsScrollView.contentSize.width, self.synopsisLabel.frame.size.height + 25);
    [self.view bringSubviewToFront:self.movieDetailsScrollView];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSURL*)convertThumbnailToHighRes:(NSString*)thumbnail {
    NSRange range = [thumbnail rangeOfString:@".*cloudfront.net/"
                                             options:NSRegularExpressionSearch];
    NSString *newUrlString = [thumbnail stringByReplacingCharactersInRange:range
                                                                        withString:@"https://content6.flixster.com/"];
    return [NSURL URLWithString:newUrlString];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
