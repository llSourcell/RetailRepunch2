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

@interface RetailerPunch ()

@end

@implementation RetailerPunch
@synthesize addPunch, minusPunch, amount, submit, myInt, phone, doneButton, place;

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


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [phone setReturnKeyType:UIReturnKeyDone];
    phone.delegate = self;
    [phone setKeyboardType:UIKeyboardTypeNumberPad];
    
    phone.borderStyle = UITextBorderStyleRoundedRect;

    CGRect frameRect = phone.frame;
    frameRect.size.height = 500;
    phone.frame = frameRect;
    
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardDidShowNotification object:nil];
    
   
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
    
    
    
    //Do REST Call to Server
    //1. FOR The user account with the specified 5 digit code
    
    PFUser *pfuser = [PFUser currentUser];
    User *localUser = [User MR_findFirstByAttribute:@"username" withValue:[pfuser username]];
    NSMutableArray* placesData = [(NSMutableArray *)[localUser.my_places allObjects] retain];


    Retailer *test =  [placesData objectAtIndex:0];
  
    NSLog(@"testing bitch %@", test.name);
    NSLog(@"testing bitch %@", test.retailer_id);

    
        // if user places, it came from parse in the first place, so don't resave
        
    
        
    

    
    NSString *retailer_id = self.place.retailer_id;
    NSString *retailer_name = self.place.name;

    
    //1. Store 5 digit code
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSString* key_code = phone.text;
    [defaults setObject:key_code forKey:@"phonetext"];
    NSString* code = [defaults objectForKey:@"phonetext"];
    //NSString* code = @"12346";

    
    //2. set num punches to a string, then dictionary for json sending
    NSString *num_punches = [NSString stringWithFormat:@"%d", myInt];
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:num_punches, @"num_punches", test.retailer_id, @"retailer_id", test.name, @"retailer_name", code, @"punch_code" ,nil];
    
    //3. Find user who has 5-digit code
    PFQuery *query = [PFUser query];
    [query whereKey:@"punch_code" equalTo:code];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error)
    {
        if (!object)
        {
            NSLog(@"The getFirstObject request failed.");
            [activityView stopAnimating];
            
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle: @"Failure!"
                                  message: @"Five digit code not found"
                                  delegate: nil
                                  cancelButtonTitle:nil
                                  otherButtonTitles:@"OK",nil];
            
            [alert show];
        }
        else
        {
                
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
    }];



       

    
       
    
   

}






//Call this method

- (void)keyboardWillShow:(NSNotification *)note {
    
    
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

-(IBAction)addPunch:(id)sender;
{
    NSLog(@"plus clicked");
    
    myInt++;
    NSString *string = [NSString stringWithFormat:@"%d", myInt];
    [amount setText:string];
}

-(IBAction)minusPunch:(id)sender;
{
    if(myInt != 0)
    {
        NSLog(@"minus clicked");
        NSLog(@"plus clicked");
        myInt--;
        NSString *string = [NSString stringWithFormat:@"%d", myInt];
        [amount setText:string];
    }
    
    
}





@end
