//
//  ComposeViewController.h
//  repunch
//
//  Created by CambioLabs on 5/14/13.
//  Copyright (c) 2013 CambioLabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reward.h"
#import "Retailer.h"

@interface ComposeViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextViewDelegate>
{
    UITableView *composeTableView;
    NSString *composeType;
    NSString *subject;
    NSString *recipient;
    Reward *reward;
    Retailer *place;
    
    UITextView *messageTextView;
    NSString *messagePlaceholderText;
}

@property (nonatomic, retain) UITableView *composeTableView;
@property (nonatomic, retain) NSString *composeType;
@property (nonatomic, retain) NSString *subject;
@property (nonatomic, retain) NSString *recipient;
@property (nonatomic, retain) Reward *reward;
@property (nonatomic, retain) Retailer *place;
@property (nonatomic, retain) UITextView *messageTextView;
@property (nonatomic, retain) NSString *messagePlaceholderText;

@end
