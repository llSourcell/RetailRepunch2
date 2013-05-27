//
//  AppDelegate.m
//  repunch
//
//  Created by CambioLabs on 3/22/13.
//  Copyright (c) 2013 CambioLabs. All rights reserved.
//

#import "AppDelegate.h"

#import <Parse/Parse.h>

#import "PlacesNavigationViewController.h"
#import "PlacesViewController.h"
#import "PunchViewController.h"
#import "InboxNavigationController.h"
#import "InboxViewController.h"
#import "BumpClient.h"
#import <FacebookSDK/FBSessionTokenCachingStrategy.h>
#import "Retailer.h"
#import "Reward.h"
#import "RetailerPunch.h"

@implementation AppDelegate

@synthesize session, lvc, fbUser, localUser, placesvc, audioPlayer;

- (void)dealloc
{
    [_window release];
    [_tabBarController release];
    [lvc release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    
    [MagicalRecord setupCoreDataStackWithStoreNamed:@"repunch_local.sqlite"];
    
    
    [Parse setApplicationId:@"I7lzrryH0UERXmIzyv4rbf6wzucn0v6WUfyPUmn2"
                  clientKey:@"C8iOnNliJ08XEGvG3j3S3RHazTLEfd18lLsuDIky"];
    

   
    // Register for push notifications
    [application registerForRemoteNotificationTypes:
     UIRemoteNotificationTypeBadge |
     UIRemoteNotificationTypeAlert |
     UIRemoteNotificationTypeSound];

    
    [PFFacebookUtils initializeFacebook];
    
//    PFQuery *query = [PFUser query];
//    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
//        if (!error) {
//            NSLog(@"Users: %@",objects);
//        } else {
//            NSLog(@"parse users error: %@",error);
//        }
//    }];
    
    placesvc = [[[PlacesViewController alloc] init] autorelease];
    
    PunchViewController *punchvc = [[[PunchViewController alloc] init] autorelease];
    InboxViewController *inboxvc = [[[InboxViewController alloc] initWithStyle:UITableViewStylePlain] autorelease];
    InboxNavigationController *inboxfinal = [[[InboxNavigationController alloc] initWithRootViewController:inboxvc] autorelease];
    RetailerPunch *punch = [[[RetailerPunch alloc] init] autorelease];
    
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Alphabetical Order", [NSNumber numberWithBool:YES], nil] forKeys:[NSArray arrayWithObjects:@"sort", @"notification", nil]]];
    
    self.tabBarController = [[[UITabBarController alloc] init] autorelease];
    self.tabBarController.viewControllers = @[placesvc, punch, inboxfinal];
    
    //[self bumpAction];
    ///Pull user settings
    PFObject *rs = [PFObject objectWithClassName:@"RetailerSettings"];
    NSString *free_punches = [rs objectForKey:@"free_punches"];
    NSString *one_time = [rs objectForKey:@"one_time"];
    NSString *seperate_times = [rs objectForKey:@"seperate_times"];
    //////////
    
    
    //employee punch count
    PFObject *employee = [PFObject objectWithClassName:@"Employee"];
    NSString *punches = [employee objectForKey:@"punches"];
    

    

    
    if ([PFUser currentUser]) // Check if user is cached
    {
        [placesvc loadPlaces];
        self.window.rootViewController = self.tabBarController;
    } else {
        lvc = [[LandingViewController alloc] init];
        self.window.rootViewController = lvc;
    }

    [self.window makeKeyAndVisible];
    return YES;
}

- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)newDeviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
   // NSString *my_id = [[PFUser currentUser] objectForKey:@"retailer_id"];
   // NSLog(@"yo its me %@", my_id);
    
    
    NSData *test = newDeviceToken;
    NSUserDefaults *testy = [NSUserDefaults standardUserDefaults];
    [testy setObject:test forKey:@"device_token"];
    
    /*
    
    PFUser *pfuser = [PFUser currentUser];
    User *localUser = [User MR_findFirstByAttribute:@"username" withValue:[pfuser username]];
    NSMutableArray *placesData = [(NSMutableArray *)[localUser.my_places allObjects] retain];
    Retailer *thisPlace = [placesData objectAtIndex:0];
    
    
    NSLog(@"yo haha %@", thisPlace);
    NSString *retailer = thisPlace.retailer_id;
    //NSString *combined = [NSString stringWithFormat:@"%@%@, @]
    NSLog(@"yo BITCH %@", retailer);
    
    

    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:newDeviceToken];
    [currentInstallation setObject:retailer forKey:@"retailer_id"];

    [currentInstallation saveInBackground];
    */
     
}

- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [PFPush handlePush:userInfo];
    NSLog(@"this is it %@", userInfo);
    
    
    NSString *name = [userInfo objectForKey:@"name"];
    NSString *title = [userInfo objectForKey:@"title"];
    NSString *description = [userInfo objectForKey:@"description"];
    
    NSUserDefaults *test = [NSUserDefaults standardUserDefaults];
    [test setObject:name forKey:@"name"];
    [test setObject:title forKey:@"title"];
    [test setObject:description forKey:@"description"];

    
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex ==1)
    {
     //   [audioPlayer stop];
    }
}

- (void)sessionDidOpen
{
    self.window.rootViewController = self.tabBarController;
    
    [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user, NSError *error) {
         if (!error) {
             self.fbUser = user;
         } else {
             NSLog(@"requestForMe error: %@",error);
         }
     }];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [FBSession.activeSession handleDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [self.session close];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [PFFacebookUtils handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [PFFacebookUtils handleOpenURL:url];
}

// Helper method to wrap logic for handling app links.
- (void)handleAppLink:(FBAccessTokenData *)appLinkToken {
    // Initialize a new blank session instance...
    FBSession *appLinkSession = [[FBSession alloc] initWithAppID:nil
                                                     permissions:nil
                                                 defaultAudience:FBSessionDefaultAudienceNone
                                                 urlSchemeSuffix:nil
                                              tokenCacheStrategy:[FBSessionTokenCachingStrategy nullCacheInstance] ];
    [FBSession setActiveSession:appLinkSession];
    // ... and open it from the App Link's Token.
    [appLinkSession openFromAccessTokenData:appLinkToken
                          completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                              // Forward any errors to the FBLoginView delegate.
                              if (error) {
                                  NSLog(@"open access token error: %@",error);
                              }
                          }];
}

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
}
*/

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed
{
}
*/

-(void)makeTabBarHidden:(BOOL)hide {
	// Custom code to hide TabBar
	if ( [self.tabBarController.view.subviews count] < 2 ) {
		return;
	}
	
	UIView *contentView;
	
	if ( [[self.tabBarController.view.subviews objectAtIndex:0] isKindOfClass:[UITabBar class]] ) {
		contentView = [self.tabBarController.view.subviews objectAtIndex:1];
	} else {
		contentView = [self.tabBarController.view.subviews objectAtIndex:0];
	}
	
	if (hide) {
		contentView.frame = self.tabBarController.view.bounds;
	}
	else {
		contentView.frame = CGRectMake(self.tabBarController.view.bounds.origin.x,
									   self.tabBarController.view.bounds.origin.y,
									   self.tabBarController.view.bounds.size.width,
									   self.tabBarController.view.bounds.size.height - self.tabBarController.tabBar.frame.size.height);
	}
	
	self.tabBarController.tabBar.hidden = hide;
}

@end
