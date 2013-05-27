//
//  InboxDetailViewController.m
//  repunch
//
//  Created by CambioLabs on 4/24/13.
//  Copyright (c) 2013 CambioLabs. All rights reserved.
//

#import "InboxDetailViewController.h"

@interface InboxDetailViewController ()

@end

@implementation InboxDetailViewController

@synthesize message;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // TODO: set based on type?
    //self.navigationItem.title = [message retailer_name];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, self.view.frame.size.width - 30, 15)];
    
    NSDateFormatter *df = [[[NSDateFormatter alloc] init] autorelease];
    [df setDateFormat:@"MMM dd"];
    
    [dateLabel setText:[df stringFromDate:[message sent_time]]];
    [self.view addSubview:dateLabel];
    
    UIView *dateBorder = [[UIView alloc] initWithFrame:CGRectMake(15, dateLabel.frame.origin.y + dateLabel.frame.size.height + 15, self.view.frame.size.width - 30, 1)];
    [dateBorder setBackgroundColor:[UIColor grayColor]];
    [self.view addSubview:dateBorder];
    
    UITextView *messageView = [[UITextView alloc] initWithFrame:CGRectMake(15, dateBorder.frame.origin.y + dateBorder.frame.size.height + 15, self.view.frame.size.width - 30, self.view.frame.size.height - 49 - 44 - dateBorder.frame.origin.y - dateBorder.frame.size.height - 30)];
    [messageView setEditable:NO];
    [messageView setContentInset:UIEdgeInsetsMake(-11, -8, 0, 0)];
    [messageView setContentMode:UIViewContentModeScaleAspectFill];
    [messageView setFont:[UIFont systemFontOfSize:17]];
    [messageView setText:[message body]];
    [self.view addSubview:messageView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
