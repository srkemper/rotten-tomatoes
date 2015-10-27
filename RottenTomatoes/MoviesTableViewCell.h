//
//  MoviesTableViewCell.h
//  RottenTomatoes
//
//  Created by Sean Kemper on 10/20/15.
//  Copyright © 2015 Sean Kemper. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MoviesTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *synopsisLabel;
@property (weak, nonatomic) IBOutlet UIImageView *posterImageView;

@end
