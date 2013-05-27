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
    [emailTextField setPlaceholder:@"Retailer ID*"];
    [emailTextField setDelegate:self];
    [emailTextField setKeyboardType:UIKeyboardTypeEmailAddress];
    [emailTextField setReturnKeyType:UIReturnKeyNext];
    [scrollView addSubview:emailTextField];
    
    birthdayTextField = [[CustomTextField alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 127.5, emailTextField.frame.origin.y + emailTextField.frame.size.height + 10, 255, 40)];
    [birthdayTextField setPlaceholder:@"Birthday"];
    [birthdayTextField setDelegate:self];
    
    datePicker = [[UIDatePicker alloc] init];
    [datePicker setCenter:CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height + datePicker.frame.size.height / 2)];
    [datePicker setDatePickerMode:UIDatePickerModeDate];
    
    dateDoneView = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
//    [dateDoneView setBackgroundImage:[UIImage imageNamed:@"bkg_header"] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                target:self
                                                                                action:@selector(onDateSelection)];
//    [doneButton setBackgroundImage:[UIImage imageNamed:@"btn-done"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    [dateDoneView setItems:[NSArray arrayWithObject:doneButton]];
    
  
    
    genderOptions = [[NSArray alloc] initWithObjects:@"Not Specified",@"Male",@"Female", nil];
    
    genderPicker = [[UIPickerView alloc] init];
    [genderPicker setDelegate:self];
    [genderPicker setDataSource:self];
    [genderPicker setShowsSelectionIndicator:YES];
    
    genderDoneView = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    UIBarButtonItem *doneButton2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                target:self
                                                                                action:@selector(onGenderSelection)];
    [genderDoneView setItems:[NSArray arrayWithObject:doneButton2]];
    
    [genderTextField setInputView:genderPicker];
    [genderTextField setInputAccessoryView:genderDoneView];
    [scrollView addSubview:genderTextField];
    
    UIImage *registerImage = [UIImage imageNamed:@"btn-register"];
    UIButton *registerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [registerButton addTarget:self action:@selector(registerUser) forControlEvents:UIControlEventTouchUpInside];
    [registerButton setFrame:CGRectMake(self.view.frame.size.width / 2 - registerImage.size.width / 2, genderTextField.frame.origin.y + genderTextField.frame.size.height + 270, registerImage.size.width, registerImage.size.height)];
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

- (void)onDateSelection
{
    if ([birthdayTextField isFirstResponder]) {
        NSDateFormatter *df = [[[NSDateFormatter alloc] init] autorelease];
        [df setDateFormat:@"MM/dd/yyyy"];
        birthdayTextField.text = [NSString stringWithFormat:@"%@", [df stringFromDate:datePicker.date]];
        [birthdayTextField resignFirstResponder];
    }
}

- (void)onGenderSelection
{
    if ([genderTextField isFirstResponder]) {
        [genderTextField setText:[genderOptions objectAtIndex:[genderPicker selectedRowInComponent:0]]];
        [genderTextField resignFirstResponder];
    }
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
    [newUser setObject:emailTextField.text forKey:@"retailer_id"];
   // [newUser setObject:birthdayTextField.text forKey:@"birth_date"];
    //[newUser setObject:[genderTextField.text lowercaseString] forKey:@"gender"];
    
    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
        if (!error) {
            NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
            User *localUser = [User MR_findFirstByAttribute:@"username" withValue:newUser.username];
            if (localUser == nil) {
                localUser = [User MR_createInContext:localContext];
            }
            [localUser setFromParse:newUser];
            [localContext MR_saveToPersistentStoreAndWait];            
            
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [appDelegate.window setRootViewController:appDelegate.tabBarController];
            [appDelegate.placesvc loadPlaces];
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

//

- (BOOL)validateForm
{
    NSMutableString *errMsg = [NSMutableString stringWithString:@""];
    
    if (usernameTextField.text.length <= 0) {
        [errMsg appendString:@"Username is required.\n"];
    }
    
  
    
    if (passwordTextField.text.length <= 0) {
        [errMsg appendString:@"Password is required.\n"];
    } else if (![passwordTextField.text isEqualToString:password2TextField.text]) {
        [errMsg appendString:@"Password fields don't match.\n"];
    }
    
    if (emailTextField.text.length <= 0) {
        [errMsg appendString:@"Retailer ID is required.\n"];
    } else if (![self validateEmail:emailTextField.text]) {
        //level of retailer_id auth
       // PFObject *rs = [PFObject objectWithClassName:@"Retailer"];
     //   NSString *the_id = [rs objectForKey:@"retailer_id"];
        //if(emailTextField.text == the_id)
     //   { [errMsg appendString:@"Valid Retailer ID is required.\n"]; return NO; }
        return YES;
        //[errMsg appendString:@"Invalid email address.\n"];
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

#pragma mark - UIPickerView Delegate/Datasource

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [genderOptions objectAtIndex:row];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [genderOptions count];
}

#pragma mark - Facebook

- (void)fbLogin
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    // The permissions requested from the user
    NSArray *permissionsArray = @[ @"user_about_me", @"email", @"user_relationships", @"user_birthday", @"user_location"];
    
    // Login PFUser using Facebook
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        if (!user) {
            if (!error) {
                NSLog(@"Uh oh. The user cancelled the Facebook login.");
            } else {
                NSLog(@"Uh oh. An error occurred: %@", error);
            }
        } else if (user.isNew) {
            NSLog(@"User with facebook signed up and logged in!");
            if (error) {
                NSLog(@"signup error: %@",error);
            }
            
            [self setUserFromFacebook];
            [appDelegate.window setRootViewController:appDelegate.tabBarController];
        } else {
            NSLog(@"User with facebook logged in!");
            if (error) {
                NSLog(@"login error: %@",error);
            }
            
            [self setUserFromFacebook];
            [appDelegate.window setRootViewController:appDelegate.tabBarController];
        }
    }];
}

- (void)setUserFromFacebook
{
    // Create request for user's Facebook data
    FBRequest *request = [FBRequest requestForMe];
    
    // Send request to Facebook
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            // result is a dictionary with the user's Facebook data
            NSDictionary *userData = (NSDictionary *)result;
            
            PFUser *user = [PFUser currentUser];
            user.username = [userData objectForKey:@"id"];
            user.email = [userData objectForKey:@"email"];
            [user setObject:[userData objectForKey:@"gender"] forKey:@"gender"];
            [user setObject:[userData objectForKey:@"birthday"] forKey:@"birth_date"];
            [user setObject:[userData objectForKey:@"first_name"] forKey:@"first_name"];
            [user setObject:[userData objectForKey:@"last_name"] forKey:@"last_name"];
            
            NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
            User *localUser = [User MR_findFirstByAttribute:@"username" withValue:user.username];
            if (localUser == nil) {
                localUser = [User MR_createInContext:localContext];
            }
            [localUser setFromParse:user];
            [localContext MR_saveToPersistentStoreAndWait];
            
            //            PFQuery *existinguserquery = [PFUser query];
            //            [existinguserquery whereKey:@"username" equalTo:user.username];
            //            NSArray *existingusers = [existinguserquery findObjects];
            //            if ([existingusers count] > 0) {
            //                // if user exists, then link 'em
            //                PFUser *existinguser = [existingusers objectAtIndex:0];
            //                if (![PFFacebookUtils isLinkedWithUser:existinguser]) {
            //                    [PFFacebookUtils linkUser:existinguser permissions:@[ @"user_about_me", @"email", @"user_relationships", @"user_birthday", @"user_location"] block:^(BOOL succeeded, NSError *error){
            //                        NSLog(@"%@",error);
            //                    }];
            //                    NSLog(@"%@",[PFUser currentUser]);
            //                }
            //            }
            
            NSError *error = nil;
            [user save:&error];
            if (error != nil) {
                NSLog(@"PFUser save error - fb callback: %@",[error description]);
            }
            
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [appDelegate.placesvc loadPlaces];
        } else {
            NSLog(@"fb error: %@",error);
        }
    }];
}

@end
