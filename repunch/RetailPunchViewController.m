//
//  RewardDetailViewController.m
//  repunch
//
//  Created by CambioLabs on 4/2/13.
//  Copyright (c) 2013 CambioLabs. All rights reserved.
//

#import "RetailPunchViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "BumpClient.h"

@interface RetailPunchViewController()

@end

@implementation RetailPunchViewController

@synthesize bumpDiagram, reward, num_punches;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    
    
}


- (void)viewDidAppear:(BOOL)animated
{
    
    [self.view setBackgroundColor:[UIColor colorWithRed:150/255.f green:150/255.f blue:150/255.f alpha:.8]];
    
    UIView *contentView = [[[UIView alloc] initWithFrame:CGRectMake(10, 10, self.view.frame.size.width - 20, self.view.frame.size.height - 20)] autorelease];
    [contentView setBackgroundColor:[UIColor whiteColor]];
    [contentView.layer setCornerRadius:6];
    [self.view addSubview:contentView];
    
    UIView *contentViewHeader = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, contentView.frame.size.width, 60)] autorelease];
    [contentViewHeader setBackgroundColor:[UIColor colorWithRed:244/255.f green:244/255.f blue:244/255.f alpha:1]];
    [contentViewHeader.layer setCornerRadius:6];
    [contentView addSubview:contentViewHeader];
    
    UILabel *rewardRequirementLabel = [[[UILabel alloc] initWithFrame:CGRectMake(15, 18, 200, 24)] autorelease];
    NSString *stringnum = [NSString stringWithFormat:@"%d", num_punches];
    
    [rewardRequirementLabel setText:stringnum];
    
    [rewardRequirementLabel setFont:[UIFont systemFontOfSize:18]];
    [rewardRequirementLabel setNumberOfLines:0];
    [rewardRequirementLabel sizeToFit];
    [rewardRequirementLabel setBackgroundColor:[UIColor clearColor]];
    [contentViewHeader addSubview:rewardRequirementLabel];
    
    UIImage *closeRewardImage = [UIImage imageNamed:@"btn_x-gray"];
    UIButton *closeRewardDetailButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeRewardDetailButton setImage:closeRewardImage forState:UIControlStateNormal];
    [closeRewardDetailButton setFrame:CGRectMake(contentViewHeader.frame.size.width - closeRewardImage.size.width - 15, 12, closeRewardImage.size.width, closeRewardImage.size.height)];
    [closeRewardDetailButton addTarget:self action:@selector(closeRewardDetail) forControlEvents:UIControlEventTouchUpInside];
    [contentViewHeader addSubview:closeRewardDetailButton];
    
    UIView *contentViewHeaderBorder = [[[UIView alloc] initWithFrame:CGRectMake(0, contentViewHeader.frame.size.height-6, contentView.frame.size.width, 1)] autorelease];
    [contentViewHeaderBorder setBackgroundColor:[UIColor colorWithRed:231/255.f green:231/255.f blue:231/255.f alpha:1]];
    [contentView addSubview:contentViewHeaderBorder];
    
    UIScrollView *mainContentView = [[[UIScrollView alloc] initWithFrame:CGRectMake(0, contentViewHeaderBorder.frame.origin.y + 1, contentView.frame.size.width, contentView.frame.size.height - contentViewHeaderBorder.frame.origin.y - 1)] autorelease];
    [mainContentView.layer setCornerRadius:6];
    [mainContentView setBackgroundColor:[UIColor whiteColor]];
    [contentView addSubview:mainContentView];
    
    UILabel *rewardNameLabel = [[[UILabel alloc] initWithFrame:CGRectMake(10, 10, mainContentView.frame.size.width - 20, 25)] autorelease];
    [rewardNameLabel setFont:[UIFont boldSystemFontOfSize:18]];
    [rewardNameLabel setText:[self.reward name]];
    [rewardNameLabel setNumberOfLines:0];
    [rewardNameLabel sizeToFit];
    [mainContentView addSubview:rewardNameLabel];
    
    UILabel *rewardDetailsLabel = [[[UILabel alloc] initWithFrame:CGRectMake(10, rewardNameLabel.frame.origin.y + rewardNameLabel.frame.size.height, mainContentView.frame.size.width - 20, 50)] autorelease];
    [rewardDetailsLabel setFont:[UIFont italicSystemFontOfSize:12]];
    [rewardDetailsLabel setTextColor:[UIColor colorWithRed:50/255.f green:50/255.f blue:50/255.f alpha:1]];
    [rewardDetailsLabel setText:[self.reward reward_description]];
    [rewardDetailsLabel setNumberOfLines:0];
    [rewardDetailsLabel sizeToFit];
    [mainContentView addSubview:rewardDetailsLabel];
    
    UILabel *placePunchesLabel = [[[UILabel alloc] init] autorelease];
    placePunchesLabel.font = [UIFont boldSystemFontOfSize:14];
    [mainContentView addSubview:placePunchesLabel];
    
    UIImageView *placePunchesImageView = [[[UIImageView alloc] init] autorelease];
    [mainContentView addSubview:placePunchesImageView];
    
    UIImage *punchImage = [UIImage imageNamed:([self.reward.place.num_punches integerValue] == 0 ? @"ico_starburst-gray" : @"ico_starburst-orange")];
    [placePunchesImageView setImage:punchImage];
    [placePunchesImageView setFrame:CGRectMake(10, rewardDetailsLabel.frame.origin.y + rewardDetailsLabel.frame.size.height + 10, punchImage.size.width, punchImage.size.height)];
    
    [placePunchesLabel setText:[NSString stringWithFormat:(num_punches == 1 ? @"%d Punch" :  @"%d Punches"),num_punches]];
    [placePunchesLabel setFrame:CGRectMake(placePunchesImageView.frame.origin.x + placePunchesImageView.frame.size.width + 2, placePunchesImageView.frame.origin.y + placePunchesImageView.frame.size.height / 2 - 9, 150, 18)];
    [placePunchesLabel sizeToFit];
    
    UIImage *bump1 = [UIImage imageNamed:@"bump_diagram"];
    float imgFactor = bump1.size.height / bump1.size.width;
    
    bumpDiagram = [[UIImageView alloc] initWithFrame:CGRectMake(10, placePunchesImageView.frame.origin.y + placePunchesImageView.frame.size.height, mainContentView.frame.size.width - 20, (mainContentView.frame.size.width - 20) * imgFactor)];
    [bumpDiagram setContentMode:UIViewContentModeScaleAspectFit];
    [bumpDiagram setAnimationImages:[NSArray arrayWithObjects:[UIImage imageNamed:@"bump_diagram2"], bump1, nil]];
    [bumpDiagram setAnimationDuration:4.0];
    [bumpDiagram setContentMode:UIViewContentModeScaleAspectFill];
    [mainContentView addSubview:bumpDiagram];
    
    rewardBumpLabel = [[[UILabel alloc] initWithFrame:CGRectMake(10, bumpDiagram.frame.origin.y + bumpDiagram.frame.size.height, mainContentView.frame.size.width - 20, 18)] autorelease];
    [rewardBumpLabel setFont:[UIFont boldSystemFontOfSize:14]];
    [rewardBumpLabel setTextAlignment:NSTextAlignmentCenter];
    [rewardBumpLabel setText:@"Bump to Punch"];
    [mainContentView addSubview:rewardBumpLabel];
    
    UILabel *rewardBumpInstructions = [[[UILabel alloc] initWithFrame:CGRectMake(10, rewardBumpLabel.frame.origin.y + rewardBumpLabel.frame.size.height, mainContentView.frame.size.width - 20, 36)] autorelease];
    [rewardBumpInstructions setFont:[UIFont systemFontOfSize:12]];
    [rewardBumpInstructions setTextColor:[UIColor colorWithRed:100/255.f green:100/255.f blue:100/255.f alpha:1]];
    [rewardBumpInstructions setText:@"To give a punch, just bump the customer's phone with yours."];
    [rewardBumpInstructions setNumberOfLines:0];
    [rewardBumpInstructions setTextAlignment:NSTextAlignmentCenter];
    //    [rewardBumpInstructions sizeToFit];
    [mainContentView addSubview:rewardBumpInstructions];
    
    [bumpDiagram startAnimating];
    
    
    
    // Probably not necessary
    [[BumpClient sharedClient] setBumpEventBlock:^(bump_event event) {
        switch(event) {
            case BUMP_EVENT_BUMP:
                NSLog(@"Bump detected.");
                PFObject *test = [PFObject objectWithClassName:@"Retailer"];
                NSString *retailer_id = [test objectForKey:@"Id"];
                
                
                
                
                
                //import num_punches
                
                
                //middle
                [[BumpClient sharedClient] setChannelConfirmedBlock:^(BumpChannelID channel) {
                    NSLog(@"Channel with %@ confirmed.", [[BumpClient sharedClient] userIDForChannel:channel]);
                    [[BumpClient sharedClient] sendData:[[NSString stringWithFormat:retailer_id] dataUsingEncoding:NSUTF8StringEncoding]
                                              toChannel:channel];
                    [[BumpClient sharedClient] sendData:[[NSString stringWithFormat:num_punches] dataUsingEncoding:NSUTF8StringEncoding]
                                              toChannel:channel];
                }];
                break;
            case BUMP_EVENT_NO_MATCH:
                NSLog(@"No match.");
                break;
        }
    }];
    
    
    
    
}


- (void)closeRewardDetail
{
    [self.view removeFromSuperview];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end