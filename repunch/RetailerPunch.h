//
//  RetailerPunch.h
//  repunch
//
//  Created by Jason Ravel on 5/21/13.
//  Copyright (c) 2013 CambioLabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RetailPunchViewController.h"
#import "Retailer.h"


@interface RetailerPunch : UIViewController <UITextFieldDelegate>
{
    IBOutlet UIButton *addPunch;
    IBOutlet UIButton *minusPunch;
    IBOutlet UILabel *amount;
    IBOutlet UIButton *submit;
    RetailPunchViewController *retailpunchviewcontroller;
    IBOutlet UITextField *phone;
     UIButton *doneButton;
    Retailer *place;

    
    
}
@property (nonatomic, retain) UIButton *submit;
@property (nonatomic, retain) UIButton *addPunch;
@property (nonatomic, retain) UIButton *minusPunch;
@property (weak, nonatomic) IBOutlet UILabel *amount;
@property (nonatomic, readwrite) int myInt;

@property (nonatomic, retain) UITextField *phone;

@property (nonatomic, retain) UIButton *doneButton;

@property (nonatomic, retain) Retailer *place;



-(IBAction)addPunch:(id)sender;

-(IBAction)minusPunch:(id)sender;

-(IBAction)submit:(id)sender;

-(IBAction)phone_pressed:(id)sender;








@end
