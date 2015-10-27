//
//  MovieDetailsViewController.h
//  Pods
//
//  Created by Sean Kemper on 10/20/15.
//
//

#import <UIKit/UIKit.h>

@interface MovieDetailsViewController : UIViewController
//add property for the movie so we can set movie from array
@property (strong, nonatomic) NSDictionary *movie;
//add scroll view at full size of screen. add label with setToFit? sizeToFit?
@end
