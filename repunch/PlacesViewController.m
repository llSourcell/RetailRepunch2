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

@synthesize placesData, placesTableView, snc, pdvc, searchvc, delegate, isSearch, location, my_related_places, place, placeRewardsTable, placeRewardData, retailer_place;

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
    if (!isSearch)
    {
        gtb = [[GlobalToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 46)];
        [(GlobalToolbar *)gtb setDelegate:self];
    }
    
    else
        
    {
        
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
    //Get the Retailer ID
    PFUser *pfuser = [PFUser currentUser];
    NSLog(@"Yay %@", pfuser);
    
    //need to get row of employee data from pointer...
    
    
    PFObject *retailer_pointer = [pfuser objectForKey:@"employee"];
    NSLog(@"whats here: %@", retailer_pointer);
    
    [retailer_pointer fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error)
     {
         NSString *retailer = [object objectForKey:@"all_time_punches"];
         NSLog(@"RYWD %@", retailer);
     }];
    
    //attempted new way
    /*
    PFObject *employee = [PFObject objectWithClassName:@"Employee"];
    NSLog(@"the new %@", employee);

    PFQuery *user_query = [PFUser query];
    NSLog(@"the new %@", user_query);

    [user_query whereKey:@"employee" equalTo:employee];
    NSArray *new = [user_query findObjects];
    NSLog(@"the new %@", new);
    */

    
    
    
    //old way
    PFRelation *employee_relation = [pfuser relationforKey:@"employee"];
    NSLog(@"Yay %@", employee_relation);
    PFQuery *employee_class = [employee_relation query];
    NSLog(@"Yay %@", employee_class);
    NSArray *employee_data = [employee_class findObjects];
    NSLog(@"Yay %@", employee_data);

   
    

    
    if([employee_data count] != 0)
    {
    PFObject *test = [employee_data objectAtIndex:0];
    NSString *retailer_id = [test objectForKey:@"retailer_id"];
    NSLog(@"YO %@",retailer_id);
        
    //Query for retailer data using retailer ID
    PFQuery *query = [PFQuery queryWithClassName:@"Retailer"];
    [query whereKey:@"retailer_id" equalTo:retailer_id];
        
        
    NSArray *place_array = [query findObjects];
    retailer_place = [place_array objectAtIndex:0];
    NSLog(@"the obj %@", retailer_place);
    
        
    }
    else
    {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *signup_retailer_id = [prefs stringForKey:@"sign_up_id"];
        NSLog(@"YO %@", signup_retailer_id);
        
        
        //Query for retailer data using retailer ID
        PFQuery *query = [PFQuery queryWithClassName:@"Retailer"];
        [query whereKey:@"retailer_id" equalTo:signup_retailer_id];
        
        
        NSArray *place_array = [query findObjects];
        retailer_place = [place_array objectAtIndex:0];
        NSLog(@"the obj %@", retailer_place);
        
       
    }
    
   

}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
    
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
        return 1;
        
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  
    if (tableView == self.placesTableView)
    {
        
        return 3;
        
    }
    
    else if(tableView == self.placeRewardsTable)
    {
        NSLog(@"The count %i", [placeRewardData count]);
        return [placeRewardData count];
        
    }
    
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
if(indexPath.row == 0)
{
    [self loadPlaces];


    static NSString *CellIdentifier = @"Cell";
        NSUserDefaults *test = [NSUserDefaults standardUserDefaults];
        // saving an NSString
        [test setObject:placesData forKey:@"placesData"];
        // saving an NSInteger
    
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
    UILabel *placeNameLabel, *placeAddressLabel, *placePunchesLabel, *placeRewardLabel, *placeCrossstreetLabel, *placeDistanceLabel, *placeCityLabel, *placeStateLabel, *placePostalcodeLabel, *neighborhoodLabel;
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
        placeCrossstreetLabel.frame = CGRectMake(110, 57 + 14, 200, 14);
        [placeDetails addSubview:placeCrossstreetLabel];
        
        
        //origin is 64, height is 14
        
       // NSLog(@"cross street origin y %f", placeCrossstreetLabel.frame.origin.y);
      // NSLog(@"cross street height %f", placeCrossstreetLabel.frame.size.height);

        
        //CITY 
        placeCityLabel = [[[UILabel alloc] init] autorelease];
        placeCityLabel.tag = PLACECITYLABEL_TAG;
        placeCityLabel.font = [UIFont systemFontOfSize:12];
        placeCityLabel.textColor = [UIColor colorWithRed:50/255.f green:50/255.f blue:50/255.f alpha:1];
        [placeCityLabel setFrame:CGRectMake(110, 64 + 14-35, 200, 14)];
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
        
        neighborhoodLabel = [[[UILabel alloc] init] autorelease];
        neighborhoodLabel.font = [UIFont systemFontOfSize:12];
        neighborhoodLabel.textColor = [UIColor colorWithRed:50/255.f green:50/255.f blue:50/255.f alpha:1];
        [neighborhoodLabel setFrame:CGRectMake(110, placePostalcodeLabel.frame.origin.y + placePostalcodeLabel.frame.size.height, 200, 14)];
        [placeDetails addSubview:neighborhoodLabel];
        
        
      
        
        
        
        
        
             
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
    

        PFFile *image_file  = [retailer_place objectForKey:@"image"];
        NSData * image_data = [image_file getData];

        NSLog(@"Yo its da file %@", image_data);

    [placeImageView setImage:[UIImage imageWithData:image_data]];
      

   
        
        

        NSString *name = [retailer_place objectForKey:@"name"];
        NSString *address = [retailer_place objectForKey:@"street_address"];
        NSString *cross_street = [retailer_place objectForKey:@"cross_streets"];
        NSString *city = [retailer_place objectForKey:@"city"];
        NSString *state = [retailer_place objectForKey:@"state"];
        NSString *postal_code = [retailer_place objectForKey:@"postal_code"];
        NSString *neighborhood = [retailer_place objectForKey:@"neighborhood"];


    
    [placeNameLabel setText:name];
    
    [placeAddressLabel setText:address];
    [placeCrossstreetLabel setText:cross_street];
        
        NSString *city_toconcat = city;
        NSString *comma = @",";
        
    NSString *combined = [NSString stringWithFormat:@"%@%@", city_toconcat, comma];

    [placeCityLabel setText:combined];
    [placeStateLabel setText:state];
    [placePostalcodeLabel setText:postal_code];
        
    [neighborhoodLabel setText:neighborhood];


    
    NSNumberFormatter *formatter = [[[NSNumberFormatter alloc] init] autorelease];
    [formatter setMaximumFractionDigits:1];
    [formatter setMinimumFractionDigits:0];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [formatter setLocale:[NSLocale currentLocale]];
    
    

    return cell;
}
else if (indexPath.row > 0)
{
    //get data array
    if(indexPath.row ==1)
    {
    NSSet *set = [retailer_place objectForKey:@"rewards"];
    NSLog(@"a set %@", set);
    placeRewardData = [[NSMutableArray alloc] initWithArray:[set allObjects]];
    [placeRewardData sortUsingDescriptors:[NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:@"required" ascending:YES] autorelease]]];
    }
    
    //get specific data
    PFObject *test = [placeRewardData objectAtIndex:indexPath.row-1];
    NSString *title = [test objectForKey:@"title"];
    NSString *pun = [test objectForKey:@"num_punches"];
    NSInteger i = [pun integerValue];
    NSString *punches = [NSString stringWithFormat:@"%d", i];
    NSString *desc = [test objectForKey:@"description"];
    NSString *punch_concat = @" Punches ";
    
    NSString *punch_combined;
    if(desc == NULL)
    {
        NSLog(@"its null");
        punch_combined = [NSString stringWithFormat:@"%@%@", punches, punch_concat];
    }
    else
    {
        NSLog(@"its not null");
        punch_combined = [NSString stringWithFormat:@"%@%@\n%@", punches, punch_concat,desc];
    }
  
    NSLog(@"test %@", title);
    NSLog(@"test %@", punches);

    
    
    //cell init
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    //
    
    //cell description
    UIFont *myFont = [UIFont fontWithName:@"Arial" size:12];
    UIFont *myFont2 = [UIFont fontWithName:@"Arial" size:16];

    cell.detailTextLabel.numberOfLines = 0;
    cell.textLabel.font = myFont2;
    cell.textLabel.text = title;
    cell.detailTextLabel.font = myFont;
    cell.detailTextLabel.text = punch_combined;
    NSLog(@"Yo its data %@", placeRewardData);
    //
    cell.selectionStyle = UITableViewCellSeparatorStyleNone;
    
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

    }
    
    else if  (tableView == self.placeRewardsTable)
    {

        
        
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

@end
