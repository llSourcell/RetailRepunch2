//
//  RetailerPunch.m
//  repunch
//
//  Created by Jason Ravel on 5/21/13.
//  Copyright (c) 2013 CambioLabs. All rights reserved.
//

#import "RetailerPunch.h"
#import "PlacesViewController.h"
#import "User.h"
#import "SettingsNavigationController.h"

@interface RetailerPunch ()

@end

@implementation RetailerPunch
@synthesize addPunch, minusPunch, amount, submit, myInt, phone, doneButton, place, settings, keyboard_counter;

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.title = NSLocalizedString(@"Punch", @"Punch");
        [self.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"ico-tab-punch-selected"] withFinishedUnselectedImage:[UIImage imageNamed:@"ico-tab-punch"]];
    }
    return self;
}

- (void) viewDidAppear:(BOOL)animated
{
    keyboard_counter = 1;

}


- (void)viewDidLoad
{
    [super viewDidLoad];
    myInt = 1;
    // Do any additional setup after loading the view from its nib.
    [phone setReturnKeyType:UIReturnKeyDone];
    phone.delegate = self;
    [phone setKeyboardType:UIKeyboardTypeNumberPad];
    
    phone.borderStyle = UITextBorderStyleRoundedRect;

    CGRect frameRect = phone.frame;
    frameRect.size.height = 500;
    phone.frame = frameRect;
    
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardDidShowNotification object:nil];
    
    //dismiss keyboard
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
                    
    [self.view addGestureRecognizer:tap];
   
}
-(void) dismissKeyboard
{
    [phone resignFirstResponder];
}

- (void) viewDidDisappear:(BOOL)animated
{
    keyboard_counter = keyboard_counter - 1;
    [doneButton removeFromSuperview];
    [doneButton release];
    [phone resignFirstResponder];

}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
   // [doneButton addTarget:self action:@selector(test) forControlEvents:UIControlEventTouchUpInside];

    
}




- (void) doneButton:(UIButton *) done
{
 
    [phone resignFirstResponder];
    
    UIActivityIndicatorView *activityView=[[UIActivityIndicatorView alloc]     initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    activityView.center=self.view.center;
    

    [activityView startAnimating];

    
    [self.view addSubview:activityView];
    
    

    

    //get retailer_id and retailer_name
    NSString *final_id;
    NSString *final_name;
    
    PFUser *pfuser = [PFUser currentUser];
    NSLog(@"Yay %@", pfuser);
    PFRelation *employee_relation = [pfuser relationforKey:@"employee"];
    PFQuery *employee_class = [employee_relation query];
    NSArray *employee_data = [employee_class findObjects];
    if([employee_data count] != 0)
    {
        PFObject *test = [employee_data objectAtIndex:0];
        NSString *retailer_id = [test objectForKey:@"retailer_id"];
        NSLog(@"YO %@",retailer_id);
        final_id = retailer_id;
        PFQuery *query2 = [PFQuery queryWithClassName:@"Retailer"];
        [query2 whereKey:@"retailer_id" equalTo:retailer_id];
        NSArray *place_array = [query2 findObjects];
        PFObject *retailer_place = [place_array objectAtIndex:0];
        final_name = [retailer_place objectForKey:@"name"];
        
        
    }
    else
    {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *signup_retailer_id = [prefs stringForKey:@"sign_up_id"];
        NSLog(@"YO %@", signup_retailer_id);
        final_id = signup_retailer_id;
        PFQuery *query2 = [PFQuery queryWithClassName:@"Retailer"];
        [query2 whereKey:@"retailer_id" equalTo:signup_retailer_id];
        NSArray *place_array = [query2 findObjects];
        PFObject *retailer_place = [place_array objectAtIndex:0];
        final_name  = [retailer_place objectForKey:@"name"];
        
    }

    
    //1. Store 5 digit code
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSString* key_code = phone.text;
    [defaults setObject:key_code forKey:@"phonetext"];
    NSString* code = [defaults objectForKey:@"phonetext"];
    //NSString* code = @"12346";

    
    //2. set num punches to a string, then dictionary for json sending
    NSString *num_punches = [NSString stringWithFormat:@"%d", myInt];
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:num_punches, @"num_punches", final_id, @"retailer_id", final_name, @"retailer_name", code, @"punch_code" ,nil];
    NSLog(@"retailer_id: %@", final_id);
    NSLog(@"retailer_name: %@", final_name);
    
        
                
            //once the user is found...
            //Call the Cloud function, send num punches to send a push notification to the user
            [PFCloud callFunctionInBackground:@"punch"
                               withParameters:dictionary
                                        block:^(NSString *result, NSError *error) {
                                            if (!error) {
                                                NSLog(@"Hello world!");
                                            }
                                        }];
            
                        
            [activityView stopAnimating];
            
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle: @"Success!"
                                  message: @"Your Punches Have Been Sent."
                                  delegate: nil
                                  cancelButtonTitle:nil
                                  otherButtonTitles:@"OK",nil];
            
            [alert show];

            
            
            /*
            //create the channel 'num_punches'
            PFInstallation *currentInstallation = [PFInstallation currentInstallation];
            [currentInstallation addUniqueObject:@"num_punches" forKey:@"channels"];
            [currentInstallation saveInBackground];
            
            //push number of punches to channel 'num_punches'
            PFPush *push = [[PFPush alloc] init];
            [push setChannel:@"num_punches"];
            [push setMessage:num_punches];
            [push sendPushInBackground];
            NSLog(@"Success!!!!!");
            */
        
  



       

    
    
    
   

}






//Call this method

- (void)keyboardWillShow:(NSNotification *)note {
    
    if(keyboard_counter ==1)
    {
    doneButton  = [[UIButton alloc] initWithFrame:CGRectMake(0, 163, 106, 53)];
    doneButton.adjustsImageWhenHighlighted = NO;
    [doneButton setImage:[UIImage imageNamed:@"done.png"] forState:UIControlStateNormal];
    [doneButton addTarget:self action:@selector(doneButton:) forControlEvents:UIControlEventTouchUpInside];
    UIWindow* tempWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:1];
    UIView* keyboard;
    for(int i=0; i<[tempWindow.subviews count]; i++) {
        keyboard = [tempWindow.subviews objectAtIndex:i];
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 3.2) {
            if([[keyboard description] hasPrefix:@"<UIPeripheralHost"] == YES)
                [keyboard addSubview:doneButton];
        }
        else {
            if([[keyboard description] hasPrefix:@"<UIKeyboard"] == YES)
                [keyboard addSubview:doneButton];
        }
    }
    }
    
}


-(IBAction)addPunch:(id)sender;
{
    NSLog(@"plus clicked");
    if(myInt <5)
    {
    myInt++;
    NSString *string = [NSString stringWithFormat:@"%d", myInt];
    [amount setText:string];
    }
}

-(IBAction)settings_pressed:(id)sender
{
    NSLog(@"pressed");
    /*
    SettingsNavigationController *snc = [[SettingsNavigationController alloc] init];
    //[snc setDelegate:self];
    [snc.navigationBar setBackgroundImage:[UIImage imageNamed:@"bkg_header"] forBarMetrics:UIBarMetricsDefault];
    [snc.view setFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:snc.view];
   // [self animateView:snc.view up:YES distance:self.view.frame.size.height completion:nil];
     */
}


-(IBAction)minusPunch:(id)sender;
{
    if(myInt != 1)
    {
        NSLog(@"minus clicked");
        NSLog(@"plus clicked");
        myInt--;
        NSString *string = [NSString stringWithFormat:@"%d", myInt];
        [amount setText:string];
    }
    
    
}





@end
