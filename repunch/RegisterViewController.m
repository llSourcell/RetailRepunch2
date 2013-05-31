//
//  RegisterViewController.m
//  repunch
//
//  Created by CambioLabs on 5/2/13.
//  Copyright (c) 2013 CambioLabs. All rights reserved.
//

#import "RegisterViewController.h"
#import "AppDelegate.h"
#import "UIViewController+animateView.h"
#import "CustomButton.h"
#import <Parse/Parse.h>

@interface RegisterViewController ()

@end

@implementation RegisterViewController

@synthesize scrollview, activeField, usernameTextField, passwordTextField;
@synthesize password2TextField, emailTextField, birthdayTextField, genderTextField;
@synthesize datePicker, dateDoneView, genderPicker, genderDoneView, genderOptions;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"splash"]]];
    [self registerForKeyboardNotifications];
    
    scrollView = [[[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)] autorelease];    
    [self.view addSubview:scrollView];
    
    UIImageView *logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"repunch"]];
    [logoImageView setCenter:CGPointMake(self.view.frame.size.width / 2, 40)];
    [scrollView addSubview:logoImageView];
    
 
   
    
  
    
    usernameTextField = [[CustomTextField alloc] initWithFrame:CGRectMake(32.5, logoImageView.frame.origin.y + logoImageView.frame.size.height + 15, 255, 40)];
    [usernameTextField setPlaceholder:@"Username*"];
    [usernameTextField setDelegate:self];
    [usernameTextField setReturnKeyType:UIReturnKeyNext];
    [scrollView addSubview:usernameTextField];

    passwordTextField = [[CustomTextField alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 127.5, usernameTextField.frame.origin.y + usernameTextField.frame.size.height + 10, 255, 40)];
    [passwordTextField setPlaceholder:@"Password*"];
    [passwordTextField setDelegate:self];
    [passwordTextField setSecureTextEntry:YES];
    [passwordTextField setReturnKeyType:UIReturnKeyNext];
    [scrollView addSubview:passwordTextField];
    
    password2TextField = [[CustomTextField alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 127.5, passwordTextField.frame.origin.y + passwordTextField.frame.size.height + 10, 255, 40)];
    [password2TextField setPlaceholder:@"Password (again)*"];
    [password2TextField setDelegate:self];
    [password2TextField setSecureTextEntry:YES];
    [password2TextField setReturnKeyType:UIReturnKeyNext];
    [scrollView addSubview:password2TextField];
    
    emailTextField = [[CustomTextField alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 127.5, password2TextField.frame.origin.y + password2TextField.frame.size.height + 10, 255, 40)];
    [emailTextField setPlaceholder:@"Retailer Pin*"];
    [emailTextField setDelegate:self];
    [emailTextField setKeyboardType:UIKeyboardTypeEmailAddress];
    [emailTextField setReturnKeyType:UIReturnKeyNext];
    [scrollView addSubview:emailTextField];
    
    first_name = [[CustomTextField alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 127.5, emailTextField.frame.origin.y + emailTextField.frame.size.height + 10, 255, 40)];
    [first_name setPlaceholder:@"First Name*"];
    [first_name setDelegate:self];
    [first_name setKeyboardType:UIKeyboardTypeEmailAddress];
    [first_name setReturnKeyType:UIReturnKeyNext];
    [scrollView addSubview:first_name];
    
    last_name = [[CustomTextField alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 127.5, first_name.frame.origin.y + first_name.frame.size.height + 10, 255, 40)];
    [last_name setPlaceholder:@"Last Name*"];
    [last_name setDelegate:self];
    [last_name setKeyboardType:UIKeyboardTypeEmailAddress];
    [last_name setReturnKeyType:UIReturnKeyNext];
    [scrollView addSubview:last_name];
    
    email = [[CustomTextField alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 127.5, last_name.frame.origin.y + last_name.frame.size.height + 10, 255, 40)];
    [email setPlaceholder:@"Email*"];
    [email setDelegate:self];
    [email setKeyboardType:UIKeyboardTypeEmailAddress];
    [email setReturnKeyType:UIReturnKeyNext];
    [scrollView addSubview:email];
    
  
    
    UIImage *registerImage = [UIImage imageNamed:@"btn-register"];
    UIButton *registerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [registerButton addTarget:self action:@selector(registerUser) forControlEvents:UIControlEventTouchUpInside];
    [registerButton setFrame:CGRectMake(self.view.frame.size.width / 2 - registerImage.size.width / 2, email.frame.origin.y + email.frame.size.height +15 , registerImage.size.width, registerImage.size.height)];
    [registerButton setImage:registerImage forState:UIControlStateNormal];
    [scrollView addSubview:registerButton];
    
    CustomButton *cancelButton = [CustomButton buttonWithType:UIButtonTypeCustom];
    [cancelButton setFrame:CGRectMake(self.view.frame.size.width / 2 - 30, registerButton.frame.origin.y + registerButton.frame.size.height + 15, 60, 20)];
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelButton.titleLabel setFont:[UIFont systemFontOfSize:13]];
    [cancelButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [cancelButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:cancelButton];
    
    [scrollView setContentSize:CGSizeMake(self.view.frame.size.width, cancelButton.frame.origin.y + cancelButton.frame.size.height + 20)];
}



- (void)cancel
{
    AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    LandingViewController *landingVC = [[LandingViewController alloc] init];
    ad.lvc = landingVC;
    ad.window.rootViewController = ad.lvc;
}

- (void)registerUser
{
//    [self.view endEditing:YES];
    
    if (![self validateForm]) {
        return;
    }
    
    PFUser *newUser = [PFUser user];
    newUser.username = usernameTextField.text;
    newUser.password = passwordTextField.text;
    newUser.email = email.text;


    
   // [newUser setObject:emailTextField.text forKey:@"retailer_id"];
    
    //check
    PFQuery *retailer_settings = [PFQuery queryWithClassName:@"RetailerSettings"];
    [retailer_settings whereKey:@"retailer_pin" equalTo:emailTextField.text];
    NSArray* settings_array = [retailer_settings findObjects];
    
    if([settings_array count] == 0)
    {
        NSLog(@"Retailer doesn't exist");
        UIAlertView *av = [[[UIAlertView alloc] initWithTitle:@"Retailer Error" message:@"ID Does Not Exist" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] autorelease];
        [av show];
    }
    else
    {
        //Retailer Exists
        NSLog(@"Retailer exists!");
        
        //Set is_employee to true
        [newUser setObject:[NSNumber numberWithBool:YES] forKey:@"is_employee"];
        
        //TODO. not sent....
        [newUser setObject:first_name.text forKey:@"first_name"];
        [newUser setObject:last_name.text forKey:@"last_name"];
        
        PFObject *retailer_settings_new = [settings_array objectAtIndex:0];
       
        PFObject *retailer_pointer = [retailer_settings_new objectForKey:@"retailer"];
        NSLog(@"whats here: %@", retailer_pointer);
        
        [retailer_pointer fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error)
         {
             
             NSLog(@"test %@", retailer_pointer);
             UIActivityIndicatorView *activityIndicator;
             activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
             activityIndicator.frame = CGRectMake(0.0, 0.0, 40.0, 40.0);
             activityIndicator.center = self.view.center;
             [self.view addSubview: activityIndicator];
             
             [activityIndicator startAnimating];


             
             
             //Create employee row
             PFObject *employee = [PFObject objectWithClassName:@"Employee"];
             [employee setObject:[NSNumber numberWithInt:0] forKey:@"all_time_punches"];
             [employee setObject:[NSNumber numberWithBool:YES] forKey:@"authorized"];
             NSString *retailer_id = [object objectForKey:@"retailer_id"];
             
             //temp storage
             NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
             [prefs setObject:retailer_id forKey:@"sign_up_id"];
             NSLog(@"got it %@", retailer_id);
             
             
             [employee setObject:object forKey:@"retailer"];
             [employee saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
             {
                 if(!error)
                 {
                     NSLog(@"yay!!");
                     
                     
                  
                     
                     //Link it
                     [newUser setObject:employee forKey:@"employee"];
                     [newUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
                     {
                         [activityIndicator stopAnimating];
                         //dismiss and switch view with placesviewcontroller as first view
                         AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                         [appDelegate.window setRootViewController:appDelegate.tabBarController];
                     }];
                 }
                 else
                 {
                     
                 }
             }];

             
         }];
        
        
        
        
    
    
        //Sign up 
    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
        if (!error) {
            NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
            User *localUser = [User MR_findFirstByAttribute:@"username" withValue:newUser.username];
            if (localUser == nil) {
                localUser = [User MR_createInContext:localContext];
            }
            [localUser setFromParse:newUser];
            [localContext MR_saveToPersistentStoreAndWait];            
            

        //    [appDelegate.placesvc loadPlaces];
        } else {
            // check error, alert user
            NSLog(@"signup error:%@",error);
            
            if (error.code == 202) {
                // Username taken
                UIAlertView *av = [[[UIAlertView alloc] initWithTitle:@"Registration Error" message:@"Username already taken" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] autorelease];
                [av show];
            }
        }
    }];
        
    }
}

//

- (BOOL)validateForm
{
    NSMutableString *errMsg = [NSMutableString stringWithString:@""];
    
    if (usernameTextField.text.length <= 0) {
        [errMsg appendString:@"Username is required.\n"];
    }
    
  
    
    if (passwordTextField.text.length <= 0)
    {
        [errMsg appendString:@"Password is required.\n"];
    }
    if (![passwordTextField.text isEqualToString:password2TextField.text])
    {
        
        UIAlertView *av = [[[UIAlertView alloc] initWithTitle:@"Registration Error" message:@"Password fields don't match.\n" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] autorelease];
        [av show];
        return NO;
    }
    
    if (emailTextField.text.length <= 0) {
        [errMsg appendString:@"Retailer ID is required.\n"];
    } else if (![self validateEmail:emailTextField.text]) {

        return YES;
    }
    
    if (errMsg.length > 0) {
        UIAlertView *av = [[[UIAlertView alloc] initWithTitle:@"Registration Error" message:errMsg delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] autorelease];
        [av show];  
        return NO;
    }
    
    return YES; 

}

- (BOOL) validateEmail: (NSString *) candidate {
    NSString *emailRegex =
    @"(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"
    @"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
    @"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"
    @"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"
    @"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
    @"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
    @"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES[c] %@", emailRegex];
    
    return [emailTest evaluateWithObject:candidate];
}

#pragma mark - Keyboard adjustments

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    scrollView.contentInset = contentInsets;
    scrollView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your application might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    if (!CGRectContainsPoint(aRect, activeField.frame.origin) ) {
        CGPoint scrollPoint = CGPointMake(0.0, activeField.frame.origin.y-kbSize.height);
        [scrollView setContentOffset:scrollPoint animated:YES];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    scrollView.contentInset = contentInsets;
    scrollView.scrollIndicatorInsets = contentInsets;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextField Delegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    activeField = nil;
    
    if (textField == birthdayTextField) {
        [self animateView:datePicker up:NO distance:datePicker.frame.size.height completion:^(BOOL finished){
            [datePicker removeFromSuperview];
        }];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == usernameTextField) {
        [passwordTextField becomeFirstResponder];
    } else if (textField == passwordTextField) {
        [password2TextField becomeFirstResponder];
    } else if (textField == password2TextField) {
        [emailTextField becomeFirstResponder];
    } else if (textField == emailTextField) {
        [birthdayTextField becomeFirstResponder];
    } else if (textField == birthdayTextField) {
        [genderTextField becomeFirstResponder];
    } else if (textField == genderTextField) {
        [genderTextField resignFirstResponder];
    }
    
    return YES;
}




@end
