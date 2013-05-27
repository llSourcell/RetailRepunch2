//
//  RetailPunchViewController.h
//  repunch
//
//  Created by Jason Ravel on 5/21/13.
//  Copyright (c) 2013 CambioLabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "Reward.h"
#import "Retailer.h"

@interface RetailPunchViewController : UIViewController
{
    UIImageView *bumpDiagram;
    Reward *reward;
    UILabel *rewardBumpLabel;
}

@property (nonatomic, retain) UIImageView *bumpDiagram;
@property (nonatomic, retain) Reward *reward;
@property (nonatomic, readwrite) int num_punches;



@end
