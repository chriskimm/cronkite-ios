#import "EditEntryController.h"
#import "DataManager.h"
#import "Location.h"

@implementation EditEntryController

@synthesize delegate;
@synthesize textField;
@synthesize dateButton;
@synthesize addLocationButton;
@synthesize addPhotoButton;
@synthesize entry = _entry;
@synthesize locationManager;
@synthesize managedObjectContext;

BOOL newEntry = TRUE;

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  if([segue.identifier isEqualToString:@"editDateTime"]) {
    EditDateTimeController *edtc = (EditDateTimeController *)[segue destinationViewController];
    edtc.delegate = self;
    if (self.date) {
      [edtc setDate:self.date];
    } else {
      [edtc setDate:self.entry.date];
    }
  }
}

#pragma mark - Actions
-(IBAction)cancel:(id)sender {
  [self.delegate cancelEdit:self];
}

-(IBAction)done:(id)sender{
  if([self.textField.text length] <= 0) {
    NSLog(@"You have not entered a name for this task %@",self.textField.text);
    return;
  }

  self.entry.text = self.textField.text;
  
  for (id obj in locations) {
    NSDictionary *d = (NSDictionary *)obj;
    NSLog(@"hello: %@", d);
  }
  
  if (newEntry) {
    Item *newEntry = (Item *)[NSEntityDescription insertNewObjectForEntityForName:@"Item" 
                                                  inManagedObjectContext:self.managedObjectContext];
    newEntry.text = self.textField.text;
    if (self.date != nil) {
      newEntry.date = self.date;
    } else {
      newEntry.date = [NSDate date];
    }
    
    [self.delegate editEntryController:self addEntry:self.entry];
  } else {
    self.entry.date = self.date;
    [self.entry setSync_status:[NSNumber numberWithInt:1]];
    [self.delegate editEntryController:self updateEntry:self.entry];
  }
  
  NSError *error;
  if(![managedObjectContext save:&error]){
    NSLog(@"Item ERROR: %@", error);
  }
}

-(IBAction)showActionSheet:(id)sender {
  UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                          delegate:self 
                                                 cancelButtonTitle:@"Cancel" 
                                            destructiveButtonTitle:@"Delete Entry" 
                                                 otherButtonTitles:nil, nil];
  [actionSheet showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
  switch (buttonIndex) {
    case 0: 
      self.entry.delete_status = [NSNumber numberWithInt:1];
      [self.delegate editEntryController:self updateEntry:self.entry];
      break;
  }
}
  
- (void) editDateTimeController:(EditDateTimeController *)edtc upDate:(NSDate *)date
{
  [self setFormattedDate:date];
  [[self navigationController] popViewControllerAnimated:YES];
}

- (CLLocationManager *)locationManager
{
  if (locationManager != nil) {
    return locationManager;    
  }
  locationManager = [[CLLocationManager alloc] init];
  locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
  locationManager.delegate = self;
  return locationManager;
}

- (IBAction)addLocation:(id)sender {
  NSLog(@"add me some location!");

  /*
  CLLocation *loc = [locationManager location];
  if (!loc) {
    return;
  }
  Location *location = (Location *)[NSEntityDescription insertNewObjectForEntityForName:@"Location" inManagedObjectContext:[[DataManager instance] moc]];
  //CLLocationCoordinate2D coordinate = [loc coordinate];

  [location setName:@"test location"];
  [location setLat:@"foolat"];
  [location setLon:@"foolon"];
   */
  NSMutableDictionary *loc = [[NSMutableDictionary alloc] init];
  [loc setObject:@"1234" forKey:@"lat"];
  [loc setObject:@"1234" forKey:@"lon"];
  [locations addObject:loc];

   /*
   CLLocationCoordinate2D coordinate = [location coordinate];
   [event setLatitude:[NSNumber numberWithDouble:coordinate.latitude]];
   [event setLongitude:[NSNumber numberWithDouble:coordinate.longitude]];
   [event setCreationDate:[NSDate date]];
  */
}

// CLLocatinManagerDelegate
- (void)location:(CLLocationManager *)managerdidUpdateToLocation:(CLLocation *)newLocation
  fromLocation:(CLLocation *)oldLocation {
  addLocationButton.enabled = YES;
}

// CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error 
{
  addLocationButton.enabled = NO;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
  [super viewDidLoad];

  locations = [[NSMutableArray alloc] init];
  
  NSDate *date = [NSDate date];
  if (self.entry == NULL) {
    newEntry = TRUE;
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] 
                                    initWithTitle: @"Cancel" 
                                    style:UIBarButtonItemStylePlain
                                    target:self 
                                    action:@selector(cancel:)];
    self.navigationItem.leftBarButtonItem = backButton;
  } else {
    newEntry = FALSE;
    self.textField.text = self.entry.text;
    date = self.entry.date;
  }

  [self setFormattedDate:date];
  [[self locationManager] startUpdatingLocation];
}

- (void)setFormattedDate:(NSDate *)date
{
  self.date = date;
  static NSDateFormatter *dateFormatter = nil;
  if (dateFormatter == nil) {
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd h:mm a"];
  }
  [self.dateButton setTitle:[dateFormatter stringFromDate:date] forState:UIControlStateNormal];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return YES;
}

- (void)viewDidUnload {
  [self setDateButton:nil];
  [self setTextField:nil];
  [self setAddLocationButton:nil];
  [self setAddPhotoButton:nil];
  [self setLocationManager:nil];
  locations = nil;
  [super viewDidUnload];
}
@end
