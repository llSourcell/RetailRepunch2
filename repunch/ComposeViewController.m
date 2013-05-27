//
//  ComposeViewController.m
//  repunch
//
//  Created by CambioLabs on 5/14/13.
//  Copyright (c) 2013 CambioLabs. All rights reserved.
//

#import "ComposeViewController.h"
#import "Message.h"

@interface ComposeViewController ()

@end

@implementation ComposeViewController

@synthesize composeTableView, composeType, subject, recipient, reward, place, messageTextView, messagePlaceholderText;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    UIToolbar *composeToolbar = [[[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 46)] autorelease];
    [composeToolbar setBackgroundImage:[UIImage imageNamed:@"bkg_header"] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    
    UIImage *closeImage = [UIImage imageNamed:@"btn_x-orange"];
    UIButton *closeComposeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeComposeButton setImage:closeImage forState:UIControlStateNormal];
    [closeComposeButton setFrame:CGRectMake(0, 0, closeImage.size.width, closeImage.size.height)];
    [closeComposeButton addTarget:self action:@selector(closeCompose) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *closeComposeButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:closeComposeButton] autorelease];
    
    UILabel *composeTitleLabel = [[[UILabel alloc] initWithFrame:CGRectMake(closeComposeButton.frame.size.width, 0, composeToolbar.frame.size.width - closeComposeButton.frame.size.width - 25, composeToolbar.frame.size.height)] autorelease];
    [composeTitleLabel setFont:[UIFont boldSystemFontOfSize:16]];
    [composeTitleLabel setBackgroundColor:[UIColor clearColor]];
    [composeTitleLabel setTextColor:[UIColor whiteColor]];
    
    if ([composeType isEqualToString:@"gift"] || [composeType isEqualToString:@"feedback"]) {
        [composeTitleLabel setText:[[reward place] name]];
    } else {
        [composeTitleLabel setText:@""];
    }
    [composeTitleLabel sizeToFit];
    
    UIBarButtonItem *composeTitleItem = [[[UIBarButtonItem alloc] initWithCustomView:composeTitleLabel] autorelease];
    
    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [sendButton setFrame:CGRectMake(0, 0, 60, 30)];
    [sendButton setTitle:@"Send" forState:UIControlStateNormal];
    [sendButton addTarget:self action:@selector(sendMessage) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *sendItem = [[[UIBarButtonItem alloc] initWithCustomView:sendButton] autorelease];
    
    UIBarButtonItem *flex = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
    UIBarButtonItem *flex2 = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
    
    [composeToolbar setItems:[NSArray arrayWithObjects:closeComposeButtonItem, flex, composeTitleItem, flex2, sendItem, nil]];
    [self.view addSubview:composeToolbar];
    
    composeTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, composeToolbar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - composeToolbar.frame.size.height)];
    [composeTableView setDataSource:self];
    [composeTableView setDelegate:self];
    [self.view addSubview:composeTableView];
    
    messageTextView = [[UITextView alloc] init];
    [messageTextView setEditable:YES];
    [messageTextView setFont:[UIFont systemFontOfSize:15]];
    [messageTextView setDelegate:self];
    
    [self registerForKeyboardNotifications];
    
    if ([composeType isEqualToString:@"gift"]) {
        place = reward.place;
    }

}

- (void)sendMessage
{
    PFObject *message = [PFObject objectWithClassName:@"Message"];
    [message setObject:place.retailer_id forKey:@"retailer_id"];
    [message setObject:place.name forKey:@"retailer_name"];
    [message setObject:composeType forKey:@"type"];
    [message setObject:self.subject forKey:@"subject"];
    [message setObject:messageTextView.text forKey:@"body"];
    [message setObject:[NSNumber numberWithBool:NO] forKey:@"is_read"];
    
    NSDateFormatter *df = [[[NSDateFormatter alloc] init] autorelease];
    [df setDateFormat:@"yyyyMMdd'T'HHmmss'Z'"];
    
    [message setObject:[df stringFromDate:[NSDate date]] forKey:@"sent_time"];
    
    if ([composeType isEqualToString:@"gift"]) {
        // TODO: set the other stuff for gift: which user's inbox, reward, gifter's name, gifter's username
        
        return;
    } else if([composeType isEqualToString:@"feedback"]) {
        
    }
    
    [message saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
        if (error) {
            NSLog(@"Message send error: %@",error);
        } else {
        
            if ([composeType isEqualToString:@"gift"]) {
                // TODO: close back to reward detail
                // TODO: remove punches
            } else if ([composeType isEqualToString:@"feedback"]) {
                [messageTextView resignFirstResponder];
                // TODO: animate this view in and out
                [self.view removeFromSuperview];
            }
            
        }
    }];
}

- (void)closeCompose
{
    [self.view removeFromSuperview];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([composeType isEqualToString:@"gift"]) {
        return 3;
    } else if ([composeType isEqualToString:@"feedback"]) {
        return 2;
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([composeType isEqualToString:@"gift"] && indexPath.row == 2) {
        return self.view.frame.size.height - 44*3;
    } else if ([composeType isEqualToString:@"feedback"] && indexPath.row == 1) {
        return self.view.frame.size.height - 44*2;
    }
    
    return tableView.rowHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    UILabel *subjectLabel = [[[UILabel alloc] init] autorelease];
    [subjectLabel setFont:[UIFont systemFontOfSize:15]];
    [subjectLabel setTextColor:[UIColor colorWithRed:.35 green:.35 blue:.35 alpha:1]];
    [subjectLabel setFrame:CGRectMake(10, 0, cell.frame.size.width - 20, cell.frame.size.height)];

    [messageTextView setFrame:CGRectMake(0, 1, cell.frame.size.width, self.view.frame.size.height - cell.frame.origin.y)];
    [messageTextView setTextColor:[UIColor lightGrayColor]];
    
    // Configure the cell...
    if ([composeType isEqualToString:@"gift"]) {
        switch (indexPath.row) {
            case 0:{
                self.subject = [NSString stringWithFormat:@"Gift for %@",@""];
                [subjectLabel setText:[NSString stringWithFormat:@"Subject: %@",self.subject]];
                [cell addSubview:subjectLabel];
                break;
            }
            case 1:{
                UILabel *giftLabel = [[[UILabel alloc] init] autorelease];
                [giftLabel setText:[NSString stringWithFormat:@"Gift: %@",reward.name]];
                [giftLabel setFont:[UIFont systemFontOfSize:15]];
                [giftLabel setFrame:CGRectMake(10, 0, cell.frame.size.width - 20, cell.frame.size.height)];
                
                [cell addSubview:giftLabel];
                break;
            }
            case 2:{
                messagePlaceholderText = @"Add a personal message!";
                [messageTextView setText:messagePlaceholderText];
                [cell addSubview:messageTextView];
                break;
            }
        }
    } else if ([composeType isEqualToString:@"feedback"]) {
        switch (indexPath.row) {
            case 0: {
                self.subject = [NSString stringWithFormat:@"Feedback for %@",place.name];
                [subjectLabel setText:[NSString stringWithFormat:@"Subject: %@",self.subject]];
                [cell addSubview:subjectLabel];
                break;
            }
            case 1: {
                messagePlaceholderText = @"How can we improve?";
                [messageTextView setText:messagePlaceholderText];
                [cell addSubview:messageTextView];
                break;
            }
            default:
                break;
        }
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
    composeTableView.contentInset = contentInsets;
    composeTableView.scrollIndicatorInsets = contentInsets;
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    composeTableView.contentInset = contentInsets;
    composeTableView.scrollIndicatorInsets = contentInsets;
}

#pragma mark - UITextView delegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:messagePlaceholderText]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor]; //optional
    }
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]) {
        textView.text = messagePlaceholderText;
        textView.textColor = [UIColor lightTextColor]; //optional
    }
    [textView resignFirstResponder];
}

@end
