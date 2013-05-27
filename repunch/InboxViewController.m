//
//  InboxViewController.m
//  repunch
//
//  Created by CambioLabs on 3/22/13.
//  Copyright (c) 2013 CambioLabs. All rights reserved.
//

#import <Parse/Parse.h>
#import "User.h"
#import "Message.h"
#import "InboxViewController.h"
#import "InboxDetailViewController.h"

@interface InboxViewController ()

@end

@implementation InboxViewController

int x = 2;

@synthesize inboxData, name, title, description;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    NSUserDefaults *test = [NSUserDefaults standardUserDefaults];
    name = [test stringForKey:@"name"];
    description = [test stringForKey:@"description"];
    title = [test stringForKey:@"title"];
    NSLog(@"Here they are %@", name);
    NSLog(@"Here they are %@", description);
    NSLog(@"Here they are %@", title);


   // self.navigationItem.title = @"Rewards";
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    UIToolbar * gtb = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 45)];
    [gtb setBackgroundImage:[UIImage imageNamed:@"bkg_header"] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    [self.view addSubview:gtb];
 
    
    UIImage *inboxBackImage = [UIImage imageNamed:@"btn-back-inbox"];
    UIImage *barBackBtnImg = [inboxBackImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 15, 0, 5)];
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:barBackBtnImg forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    //pull rewards from user
    
    
//    inboxData = [[NSMutableArray alloc] initWithObjects:
//                 [NSDictionary dictionaryWithObjectsAndKeys:@"Temple Coffee House",@"subject",@"Message body.",@"body",@"Dec 10",@"date",nil],
//                 [NSDictionary dictionaryWithObjectsAndKeys:@"Chocolate Fish Coffee",@"subject",@"Message body dos.",@"body",@"Dec 11",@"date",nil],
//                 [NSDictionary dictionaryWithObjectsAndKeys:@"Naked Lounge",@"subject",@"Message body trois.",@"body",@"Dec 12",@"date",nil], nil];
    
    [self loadMessages];
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    // retrieve reward_name, reward_amount
    
 //   NSLog(@"You got it mang %@", userInfo);
  //  NSString *reward = [userInfo objectForKey:@"reward_name"];
  //  NSString *reward_amount = [userInfo objectForKey:@"reward_amount"];
   // PFObject *stored_reward = [PFObject objectWithClassName:@"temp_rewards" dictionary:userInfo];
    
    
}

- (void)loadMessages
{
    PFUser *pfuser = [PFUser currentUser];
    User *localUser = [User MR_findFirstByAttribute:@"username" withValue:[pfuser username]];
    
    PFRelation *inbox = [pfuser objectForKey:@"inbox"];
    [[inbox query] findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
            
        // if message count doesn't match, load from parse
        if ([inboxData count] != [objects count]){
            
            // TODO: update messages, need a unique id (try objectId, a parse default field). For now, just empty message table and dump from parse
            [Message MR_truncateAllInContext:localContext];
            for (PFObject *message in objects){
                
                Message *newMessage = [Message MR_createInContext:localContext];
                [newMessage setFromParse:message];
                [newMessage setUser:localUser];
                [localContext MR_saveToPersistentStoreAndWait];
                
            }
        }        
        
        inboxData = [(NSMutableArray *)[localUser.messages allObjects] retain];
        [self.tableView reloadData];
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return x;
    
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    
    // Configure the cell...
  //  cell.textLabel.text = [[inboxData objectAtIndex:indexPath.row] valueForKey:@"subject"];
    if(indexPath.row ==1)
    {
        
      
        
        
        
        cell.textLabel.text = name;
        NSLog(@"the name %@", name);
        cell.detailTextLabel.text = title;
        return cell;
    }
     
    return cell;
     
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"button pressed: %d",buttonIndex);
    
    //left
    if (buttonIndex == 0)
    {
        
    }
    else if (buttonIndex == 1)
    {
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [inboxData removeObjectAtIndex:indexPath.row];
        
//        PFObject *message = nil;
//        [[[PFUser currentUser] objectForKey:@"inbox"] removeObject:message];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}


/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    
    }

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row ==1)
    {
      NSLog(@"you clicked");
        
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Redeem"
                              message: @"You redeemed an award!"
                              delegate: self
                              cancelButtonTitle:nil
                              otherButtonTitles:@"OK",nil];
        
        
        [alert show];
        
        x--;
        [tableView beginUpdates];
        
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:tableView.indexPathForSelectedRow] withRowAnimation:UITableViewRowAnimationFade];
        name = nil;
        title = nil;
        [tableView endUpdates];
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
