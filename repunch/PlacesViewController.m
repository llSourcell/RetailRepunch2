//
//  PlacesViewController.m
//  repunch
//
//  Created by CambioLabs on 3/22/13.
//  Copyright (c) 2013 CambioLabs. All rights reserved.
//

#import "PlacesViewController.h"
#import "PlaceDetailViewController.h"
#import "GlobalToolbar.h"
#import "SettingsNavigationController.h"
#import "UIViewController+animateView.h"
#import "Retailer.h"
#import "AppDelegate.h"

@interface PlacesViewController ()

@end

@implementation PlacesViewController

@synthesize placesData, placesTableView, snc, pdvc, searchvc, delegate, isSearch, location, my_related_places, place, placeRewardsTable, placeRewardData;

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.title = NSLocalizedString(@"My Places", @"My Places");
        [self.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"ico-tab-places-selected"] withFinishedUnselectedImage:[UIImage imageNamed:@"ico-tab-places"]];
        isSearch = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIToolbar *gtb;
    if (!isSearch) {
        gtb = [[GlobalToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 46)];
        [(GlobalToolbar *)gtb setDelegate:self];
    } else {
        
        UIImage *closeImage = [UIImage imageNamed:@"btn_x-orange"];
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [closeButton setFrame:CGRectMake(0, 0, closeImage.size.width, closeImage.size.height)];
        [closeButton setImage:closeImage forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(closeSearch) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *closeButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:closeButton] autorelease];
        
        UILabel *searchTitle = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 140, 46)] autorelease];
        [searchTitle setText:@"Search"];
        [searchTitle setFont:[UIFont boldSystemFontOfSize:20]];
        [searchTitle setTextColor:[UIColor whiteColor]];
        [searchTitle setBackgroundColor:[UIColor clearColor]];
        [searchTitle setShadowOffset:CGSizeMake(0, -1)];
        [searchTitle setShadowColor:[UIColor blackColor]];
        [searchTitle sizeToFit];
        
        UIBarButtonItem *searchTitleItem = [[[UIBarButtonItem alloc] initWithCustomView:searchTitle] autorelease];
        
        gtb = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 46)];
        [gtb setBackgroundImage:[UIImage imageNamed:@"bkg_header"] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
        
        UIBarButtonItem *flex = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
        UIBarButtonItem *flex2 = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
        
        [gtb setItems:[NSArray arrayWithObjects:closeButtonItem, flex, searchTitleItem, flex2, nil]];
        
        if ([CLLocationManager locationServicesEnabled]) {
            [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error){
                self.location = geoPoint;
                [self setDistances];
                [self sortPlaces];
            }];
        }
    }
    [self.view addSubview:gtb];
    
    placesTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, gtb.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - gtb.frame.size.height - (isSearch ? 0 : 49)) style:UITableViewStylePlain];
    [placesTableView setDataSource:self];
    [placesTableView setDelegate:self];
    [self.view addSubview:placesTableView];
    

    placesData = [[NSMutableArray alloc] initWithCapacity:0];
    
    
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[[UIView alloc] init] autorelease];
    
    return view;
}

- (void)loadPlacesForSearch
{
    PFUser *pfuser = [PFUser currentUser];
    PFQuery *query = [PFQuery queryWithClassName:@"Retailer"];
    
    NSMutableArray *searchPlaces = [[NSMutableArray alloc] initWithCapacity:0];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        
        NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
        for (PFObject *place in objects){
            Retailer *newPlace = [[Retailer alloc] initWithEntity:[NSEntityDescription entityForName:@"Retailer" inManagedObjectContext:localContext] insertIntoManagedObjectContext:localContext];
            [newPlace setFromParse:place];
            [newPlace setUser:nil];

            // set num punches from parse which is in the user object
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"retailer_id = %@",[place objectForKey:@"retailer_id"]];
            NSArray *userplaces = [my_related_places filteredArrayUsingPredicate:predicate];
            
            NSNumber *punches = [NSNumber numberWithInt:0];
            if ([userplaces count] > 0) {
                NSDictionary *userplace = [userplaces objectAtIndex:0];
                punches = [userplace objectForKey:@"num_punches"];
            }
            [newPlace setNum_punches:(punches != nil ? punches : [NSNumber numberWithInt:0])];
            
            // set distanct from current location
            if (self.location != nil) {
                PFGeoPoint *pfgp = [PFGeoPoint geoPointWithLatitude:[newPlace.latitude doubleValue] longitude:[newPlace.longitude doubleValue]];
                
                [newPlace setDistance:[NSNumber numberWithDouble:[self.location distanceInMilesTo:pfgp]]];
            }

            [searchPlaces addObject:newPlace];
        }
        
        placesData = searchPlaces;
        [self sortPlaces];
    }];
}

- (void)setDistances
{
    if (self.location != nil) {
        for (Retailer *newPlace in placesData){
            PFGeoPoint *pfgp = [PFGeoPoint geoPointWithLatitude:[newPlace.latitude doubleValue] longitude:[newPlace.longitude doubleValue]];
            
            [newPlace setDistance:[NSNumber numberWithDouble:[self.location distanceInMilesTo:pfgp]]];
        }
    }
}

- (void)loadPlaces
{
    
    PFUser *pfuser = [PFUser currentUser];
    User *localUser = [User MR_findFirstByAttribute:@"username" withValue:[pfuser username]];
    placesData = [(NSMutableArray *)[localUser.my_places allObjects] retain];
    
    //Retailer *thisPlace = [placesData objectAtIndex:0];
    //NSString *retailer = thisPlace.retailer_id;
    
    //NSUserDefaults *memorial_day = [NSUserDefaults standardUserDefaults];
    //[memorial_day setObject:retailer forKey:@"memorial_day"];
    
    // For testing only -- BROKEN
//    if ([placesData count] == 0 && [[pfuser objectForKey:@"my_places"] count] == 0) {
//        [self fillPlacesDefault:YES];
//    }
    
    [[[pfuser relationforKey:@"my_places"] query] findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if (error) {
            NSLog(@"place count error: %@",error);
        } else {
            my_related_places = [[NSArray alloc] initWithArray:objects];
            
            // local and parse are out of sync so get parse and overwrite local
            if ([placesData count] != [my_related_places count]){
                [self fillPlacesDefault:NO];
            } else {
                [self sortPlaces];
            }
        }
    }];
}

/******************
 
 - Get user places from parse
 - For testing, add all places to new user with no places with defaultplaces = YES
 - defaultplaces = YES is BROKEN
 
 *****************/
- (void)fillPlacesDefault:(BOOL)defaultplaces
{
    PFUser *pfuser = [PFUser currentUser];
    User *localUser = [User MR_findFirstByAttribute:@"username" withValue:[pfuser username]];
    PFQuery *query = [PFQuery queryWithClassName:@"Retailer"];
    
    if (!defaultplaces) {
        [query whereKey:@"retailer_id" containedIn:[my_related_places valueForKey:@"retailer_id"]];
        NSLog(@"Heya %@", query);
    }
    
//    NSMutableArray *my_places = [[NSMutableArray alloc] initWithCapacity:0];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
        
        // punches only get set for default places, i.e. filler
        int punches = 0;
        for (PFObject *place in objects){
            Retailer *newPlace = [Retailer MR_findFirstByAttribute:@"retailer_id" withValue:[place objectForKey:@"retailer_id"]];
            if (newPlace == nil) {
                newPlace = [Retailer MR_createInContext:localContext];
            }
            
            [newPlace setFromParse:place];
            NSLog(@"The place is %@", newPlace); 
            [newPlace setUser:localUser];
            if (defaultplaces) {
                [newPlace setNum_punches:[NSNumber numberWithInt:punches]];
            } else {
                // set num punches from parse which is in the user object
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"retailer_id = %@",[place objectForKey:@"retailer_id"]];
                NSDictionary *userplace = [[my_related_places filteredArrayUsingPredicate:predicate] objectAtIndex:0];
                [newPlace setNum_punches:[userplace objectForKey:@"num_punches"]];
            }
            [localContext MR_saveToPersistentStoreAndWait];
            
//            [my_places addObject:[NSDictionary dictionaryWithObjectsAndKeys:[place objectForKey:@"Id"], @"retailer_id", [NSNumber numberWithInt:punches], @"num_punches", nil]];
            
            punches += 5;
        }
        
        // if user places, it came from parse in the first place, so don't resave
        if (defaultplaces) {
//            [pfuser setObject:my_places forKey:@"my_places_temp"];
//            [pfuser save];
        }
        
        placesData = [(NSMutableArray *)[localUser.my_places allObjects] retain];
        [self sortPlaces];
    }];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
    
    [self sortPlaces];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (isSearch) {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate makeTabBarHidden:YES];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (isSearch) {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate makeTabBarHidden:NO];
    }
}

- (void)sortPlaces
{
    if (isSearch && self.location != nil) {
        placesData = [(NSMutableArray *)[placesData sortedArrayUsingDescriptors:[NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:@"distance" ascending:YES] autorelease]]] retain];
    } else if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"sort"] isEqualToString:@"Number of Rewards"]) {
        // sort by number of rewards descending
        placesData = [(NSMutableArray *)[placesData sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2){
            int count1 = [[obj1 valueForKey:@"rewards"] count];
            int count2 = [[obj2 valueForKey:@"rewards"] count];
            
            if(count1 > count2){
                return (NSComparisonResult)NSOrderedDescending;
            } else if(count2 > count1){
                return (NSComparisonResult)NSOrderedAscending;
            }
            
            return NSOrderedSame;
        }] retain];
    } else if([[[NSUserDefaults standardUserDefaults] stringForKey:@"sort"] isEqualToString:@"Number of Punches"]){
        // sort by punches descending
        placesData = [(NSMutableArray *)[placesData sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2){
            int count1 = [[obj1 num_punches] integerValue];
            int count2 = [[obj2 num_punches] integerValue];
            
            if(count1 > count2){
                return (NSComparisonResult)NSOrderedDescending;
            } else if(count2 > count1){
                return (NSComparisonResult)NSOrderedAscending;
            }
            
            return NSOrderedSame;
        }] retain];
    } else {
        // sort by name ascending
        placesData = [(NSMutableArray *)[placesData sortedArrayUsingDescriptors:[NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES] autorelease]]] retain];
    }
    
    [self.placesTableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of rows in the section.
    if (tableView == self.placesTableView)
    {
        
        return 1;
        
    }
    
    else if(tableView == self.placeRewardsTable)
    {
        return [placeRewardData count];
        
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [placesData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.placesTableView)
    {
    static NSString *CellIdentifier = @"Cell";
        NSUserDefaults *test = [NSUserDefaults standardUserDefaults];
        // saving an NSString
        [test setObject:placesData forKey:@"placesData"];
        // saving an NSInteger
    
    Retailer *thisPlace = [placesData objectAtIndex:indexPath.row];
    PFUser *pfuser = [PFUser currentUser];
    User *localUser = [User MR_findFirstByAttribute:@"username" withValue:[pfuser username]];
    
#define PLACEIMAGEVIEW_TAG 1
#define PLACENAMELABEL_TAG 2
#define PLACEADDRESSLABEL_TAG 3
#define PLACECROSSSTREETLABEL_TAG 8        
#define PLACECITYLABEL_TAG 10
#define PLACESTATELABEL_TAG 11
#define PLACEPOSTALCODELABEL_TAG 12

    
    UIImageView *placeImageView, *placePunchesImageView = nil, *placeRewardImageView;
    UILabel *placeNameLabel, *placeAddressLabel, *placePunchesLabel, *placeRewardLabel, *placeCrossstreetLabel, *placeDistanceLabel, *placeCityLabel, *placeStateLabel, *placePostalcodeLabel;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        cell.userInteractionEnabled = NO;

    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.userInteractionEnabled = NO;

        //IMAGE
        UIView *placeDetails = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 110)] autorelease];
        placeImageView = [[[UIImageView alloc] init] autorelease];
        placeImageView.tag = PLACEIMAGEVIEW_TAG;
        placeImageView.userInteractionEnabled = NO; 
        [placeImageView setFrame:CGRectMake(11, 10, 90, 90)];
        [placeDetails addSubview:placeImageView];
        
        
        //NAME
        placeNameLabel = [[[UILabel alloc] initWithFrame:CGRectMake(110, 10, 200, 18)] autorelease];
        placeNameLabel.tag = PLACENAMELABEL_TAG;
        placeNameLabel.font = [UIFont boldSystemFontOfSize:15.0];
        [placeDetails addSubview:placeNameLabel];
        
        //ADDRESS
        placeAddressLabel = [[[UILabel alloc] init] autorelease];
        placeAddressLabel.tag = PLACEADDRESSLABEL_TAG;
        placeAddressLabel.font = [UIFont systemFontOfSize:12];
        placeAddressLabel.textColor = [UIColor colorWithRed:50/255.f green:50/255.f blue:50/255.f alpha:1];
        [placeAddressLabel setFrame:CGRectMake(110, placeNameLabel.frame.origin.y + placeNameLabel.frame.size.height, 200, 14)];
        [placeDetails addSubview:placeAddressLabel];
        
        //CROSS STREET
        placeCrossstreetLabel = [[[UILabel alloc] init] autorelease];
        placeCrossstreetLabel.tag = PLACECROSSSTREETLABEL_TAG;
        placeCrossstreetLabel.font = [UIFont systemFontOfSize:12];
        placeCrossstreetLabel.textColor = [UIColor colorWithRed:50/255.f green:50/255.f blue:50/255.f alpha:1];
        placeCrossstreetLabel.frame = CGRectMake(110, placeAddressLabel.frame.origin.y + placeAddressLabel.frame.size.height + 2, 200, 14);
        [placeDetails addSubview:placeCrossstreetLabel];
        
        //CITY 
        placeCityLabel = [[[UILabel alloc] init] autorelease];
        placeCityLabel.tag = PLACECITYLABEL_TAG;
        placeCityLabel.font = [UIFont systemFontOfSize:12];
        placeCityLabel.textColor = [UIColor colorWithRed:50/255.f green:50/255.f blue:50/255.f alpha:1];
        [placeCityLabel setFrame:CGRectMake(110, placeCrossstreetLabel.frame.origin.y + placeCrossstreetLabel.frame.size.height, 200, 14)];
        [placeDetails addSubview:placeCityLabel];
        
        //STATE
        placeStateLabel = [[[UILabel alloc] init] autorelease];
        placeStateLabel.tag = PLACESTATELABEL_TAG;
        placeStateLabel.font = [UIFont systemFontOfSize:12];
        placeStateLabel.textColor = [UIColor colorWithRed:50/255.f green:50/255.f blue:50/255.f alpha:1];
        [placeStateLabel setFrame:CGRectMake(110+55, placeCityLabel.frame.origin.y + placeCityLabel.frame.size.height-14, 200, 14)];
        [placeDetails addSubview:placeStateLabel];
        
        //POSTAL CODE
        placePostalcodeLabel = [[[UILabel alloc] init] autorelease];
        placePostalcodeLabel.tag = PLACEPOSTALCODELABEL_TAG;
        placePostalcodeLabel.font = [UIFont systemFontOfSize:12];
        placePostalcodeLabel.textColor = [UIColor colorWithRed:50/255.f green:50/255.f blue:50/255.f alpha:1];
        [placePostalcodeLabel setFrame:CGRectMake(110+75, placeStateLabel.frame.origin.y + placeStateLabel.frame.size.height-14, 200, 14)];
        [placeDetails addSubview:placePostalcodeLabel];
        
        
        
        
        
             
        [cell.contentView addSubview:placeDetails];
        
        [cell setBackgroundView:[[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bkg_place-list-gradient"]] autorelease]];
    }
        
    else
        
    {
        placeImageView = (UIImageView *)[cell.contentView viewWithTag:PLACEIMAGEVIEW_TAG];
        placeNameLabel = (UILabel *)[cell.contentView viewWithTag:PLACENAMELABEL_TAG];
        placeAddressLabel = (UILabel *)[cell.contentView viewWithTag:PLACEADDRESSLABEL_TAG];
        placeCrossstreetLabel = (UILabel *)[cell.contentView viewWithTag:PLACECROSSSTREETLABEL_TAG];
        placeCityLabel = (UILabel *)[cell.contentView viewWithTag:PLACECITYLABEL_TAG];
        placeStateLabel = (UILabel *)[cell.contentView viewWithTag:PLACESTATELABEL_TAG];
        placePostalcodeLabel = (UILabel *)[cell.contentView viewWithTag:PLACEPOSTALCODELABEL_TAG];


    }
    

    
    [placeImageView setImage:[UIImage imageWithData:[[placesData objectAtIndex:indexPath.row] image_url]]];
        
        NSLog(@" This is it %@",[placesData objectAtIndex:0 ]);
        
   

        //REWARDS TABLE
        self.place = [placesData objectAtIndex:indexPath.row];
        
        placeRewardData = [[NSMutableArray alloc] initWithArray:[[self.place rewards] allObjects]];
        [placeRewardData sortUsingDescriptors:[NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:@"required" ascending:YES] autorelease]]];
        
        placeRewardsTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 150 + 1, self.view.frame.size.width, self.view.frame.size.height - 150- 1 - 49) style:UITableViewStylePlain];
        [placeRewardsTable setDataSource:self];
        [placeRewardsTable setDelegate:self];
        //    [placeRewardsTable setBackgroundColor:[UIColor colorWithRed:1 green:0 blue:0 alpha:.5]];
        
        [self.view addSubview:placeRewardsTable];
        


        
    
    [placeNameLabel setText:[thisPlace name]];
    
    [placeAddressLabel setText:[thisPlace valueForKey:@"address"]];
    [placeCrossstreetLabel setText:[thisPlace valueForKey:@"cross_street"]];
        
        NSString *city = [thisPlace valueForKey:@"city"];
        NSString *comma = @",";
        
    NSString *combined = [NSString stringWithFormat:@"%@%@", city, comma];

    [placeCityLabel setText:combined];
    [placeStateLabel setText:[thisPlace valueForKey:@"state"]];
    [placePostalcodeLabel setText:[thisPlace valueForKey:@"postal_code"]];
        



    
    NSNumberFormatter *formatter = [[[NSNumberFormatter alloc] init] autorelease];
    [formatter setMaximumFractionDigits:1];
    [formatter setMinimumFractionDigits:0];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [formatter setLocale:[NSLocale currentLocale]];
    
    

    return cell;
    }
    
    else if(tableView == self.placeRewardsTable)
    {

        static NSString *CellIdentifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil)
        {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        }
        
        
        // Configure the cell...
        //reward name
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        cell.textLabel.text = [[placeRewardData objectAtIndex:indexPath.row] name];
        int required = [[[placeRewardData objectAtIndex:indexPath.row] required] integerValue];
        //reward punches
        cell.detailTextLabel.text = [NSString stringWithFormat:(required == 1 ? @"%@ Punch" :  @"%@ Punches"),[[placeRewardData objectAtIndex:indexPath.row] required]];
        [cell.detailTextLabel setBackgroundColor:[UIColor clearColor]];
        [cell setBackgroundView:[[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bkg_reward-list-gradient"]] autorelease]];
        
        // if required punches are greater than what we have, disable selection
        if ([[[placeRewardData objectAtIndex:indexPath.row] required] integerValue] > [self.place.num_punches integerValue]) {
            cell.userInteractionEnabled = NO;
            cell.textLabel.enabled = NO;
            cell.detailTextLabel.enabled = NO;
        }
        
        
        return cell;
        
    }
    
}


#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.placesTableView)
    {
        return 113;
    }
    else if  (tableView == self.placeRewardsTable)
    {
        return 80;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    if (tableView == self.placesTableView)
    {
        pdvc = [[PlaceDetailViewController alloc] init];
        [pdvc setPlace:[placesData objectAtIndex:indexPath.row]];
        [pdvc setDelegate:self];
        [pdvc.view setFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height)];
        [self.view addSubview:pdvc.view];
        [self animateView:pdvc.view up:YES distance:self.view.frame.size.height completion:nil];
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    
    else if  (tableView == self.placeRewardsTable)
    {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        //open a new view
        // rdvc = [[RewardDetailViewController alloc] init];
        // [rdvc setReward:[placeRewardData objectAtIndex:indexPath.row]];
        // [rdvc.view setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        
        // [self.view addSubview:rdvc.view];
        
        //removed
        
        
    }
}

#pragma mark - Global Toolbar Delegate

- (void) openSettings
{
    snc = [[SettingsNavigationController alloc] init];
    [snc setDelegate:self];
    [snc.navigationBar setBackgroundImage:[UIImage imageNamed:@"bkg_header"] forBarMetrics:UIBarMetricsDefault];
    [snc.view setFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:snc.view];
    [self animateView:snc.view up:YES distance:self.view.frame.size.height completion:nil];
}

- (void) closeSettings
{
    [self viewWillAppear:NO];
    [self animateView:snc.view
                   up:NO
             distance:self.view.frame.size.height
           completion:^(BOOL finished){
               [snc.view removeFromSuperview];
           }];
}

- (void) openSearch
{
    searchvc = [[PlacesViewController alloc] init];
    [searchvc setIsSearch:YES];
    [searchvc setDelegate:self];
    [searchvc.view setFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:searchvc.view];
    [self animateView:searchvc.view up:YES distance:self.view.frame.size.height completion:nil];
    [searchvc loadPlacesForSearch];
}

- (void) closeSearch
{
    if (delegate != nil) {
        [(PlacesViewController *)delegate closeSearch];
    } else {
        
        PFUser *pfuser = [PFUser currentUser];
        User *localUser = [User MR_findFirstByAttribute:@"username" withValue:[pfuser username]];
        placesData = [(NSMutableArray *)[localUser.my_places allObjects] retain];
        
        [self viewWillAppear:NO];
        [self animateView:searchvc.view up:NO distance:self.view.frame.size.height completion:^(BOOL finished){
            [searchvc.view removeFromSuperview];
            
            NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
            NSArray *searchPlaces = [Retailer MR_findByAttribute:@"user" withValue:nil];
            for (Retailer *place in searchPlaces){
                [place MR_deleteEntity];
            }
            [localContext MR_saveToPersistentStoreAndWait];
        }];
    }
}

#pragma mark - Place Detail Delegate

- (void)closePlaceDetail
{
    [self viewWillAppear:NO];
    [self animateView:pdvc.view
                   up:NO
             distance:self.view.frame.size.height
           completion:^(BOOL finished){
               [pdvc.view removeFromSuperview];
           }];
}

@end
