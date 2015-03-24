/*
 *  Copyright (c) 2015, Parse, LLC. All rights reserved.
 *
 *  You are hereby granted a non-exclusive, worldwide, royalty-free license to use,
 *  copy, modify, and distribute this software in source code or binary form for use
 *  in connection with the web services and APIs provided by Parse.
 *
 *  As with any software that integrates with the Parse platform, your use of
 *  this software is subject to the Parse Terms of Service
 *  [https://www.parse.com/about/terms]. This copyright notice shall be
 *  included in all copies or substantial portions of the software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 *  FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 *  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
 *  IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 *  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 *
 */

#import "PADHomeViewController.h"

#import <Parse/Parse.h>

#import "PADAlertUtilities.h"
#import "PADDeviceActivityUtilities.h"
#import "PADDeviceDetailsViewController.h"
#import "PADEvent.h"
#import "PADInstallation.h"
#import "PADLogInViewController.h"
#import "PADModel.h"
#import "PADProvisionedDeviceCell.h"
#import "PADProvisioningService.h"
#import "PADReachability.h"
#import "PADStoryboardConstants.h"
#import "UIColor+CustomColors.h"

static CGFloat const kCellHeight = 90.0f;

@interface PADHomeViewController () <UICollectionViewDataSource, UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout>

/*!
 @abstract List of user's provisioned devices.
 */
@property (nonatomic, copy) NSArray *provisionedDevices;

/*!
 @abstract The device for which the device details screen is going to be shown.
 */
@property (nonatomic, strong) PADInstallation *selectedInstallation;

@end

@implementation PADHomeViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Anydevice", @"App name");
    NSDictionary *titleAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    [self.navigationController.navigationBar setTitleTextAttributes:titleAttributes];

    [self setupCollectionView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // Present log in flow if a user is not logged in.
    if (![PFUser currentUser]) {
        self.view.hidden = YES;
        [self pushLogInFlow];

    } else {
        self.view.hidden = NO;

        // Update the phone's installation object with current user information.
        [PADProvisioningService updateCurrentPhoneInstallation];
        [self fetchProvisionedDevices];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:PADPresentDeviceDetailsSegue]) {
        PADDeviceDetailsViewController *destinationViewController = segue.destinationViewController;
        destinationViewController.installation = self.selectedInstallation;
    }
}

#pragma mark - Public

- (void)navigateToDeviceDetailsForInstallationId:(NSString *)installationId
                                       withEvent:(PADEvent *)event
{
    for (PADInstallation *installation in self.provisionedDevices) {
        if (![installation.installationId isEqualToString:installationId]) {
            continue;
        }

        self.selectedInstallation = installation;
        self.selectedInstallation.latestEvent = event;
        [self performSegueWithIdentifier:PADPresentDeviceDetailsSegue sender:nil];
        break;
    }
}

#pragma mark - Private

- (void)setupCollectionView {
    NSString *registeredDeviceCellIdentifier = NSStringFromClass([PADProvisionedDeviceCell class]);
    UINib *cellNib = [UINib nibWithNibName:registeredDeviceCellIdentifier bundle:nil];
    [self.provisionedDevicesCollectionView registerNib:cellNib
                            forCellWithReuseIdentifier:registeredDeviceCellIdentifier];

    self.provisionedDevicesCollectionView.dataSource = self;
    self.provisionedDevicesCollectionView.delegate = self;

    self.refreshIndicator = [[UIRefreshControl alloc] init];
    self.refreshIndicator.tintColor = [UIColor navigationBarTintColorDarkGrey];
    [self.refreshIndicator addTarget:self
                              action:@selector(fetchProvisionedDevices)
                    forControlEvents:UIControlEventValueChanged];

    [self.provisionedDevicesCollectionView addSubview:self.refreshIndicator];
    self.provisionedDevicesCollectionView.alwaysBounceVertical = YES;
}

- (void)pushLogInFlow {
    [self performSegueWithIdentifier:PADPresentLoginSegue sender:nil];
}

- (void)fetchProvisionedDevices {
    [self.refreshIndicator beginRefreshing];

    __weak typeof(self) weakSelf = self;
    [PADProvisioningService fetchProvisionedDevicesWithSuccess:^(NSArray *devices) {
        weakSelf.provisionedDevices = devices;
        [weakSelf fetchProvisionedDevicesFinished];
    } failure:^(NSError *error) {
        [weakSelf fetchProvisionedDevicesFinished];
    }];
}

- (void)fetchProvisionedDevicesFinished {
    [self.refreshIndicator endRefreshing];
    self.noDevicesView.hidden = [self.provisionedDevices count] ? YES : NO;
    [self.provisionedDevicesCollectionView reloadData];
}

- (void)logOut {
    self.provisionedDevices = nil;
    [self.provisionedDevicesCollectionView reloadData];
    [PFUser logOut];
    [self pushLogInFlow];
}

#pragma mark - Actions

- (IBAction)logoutButtonTapped:(id)sender {
    NSString *actionSheetMessage = NSLocalizedString(@"Are you sure you would like to log out of your account?",
                                                     @"Confirmation message - logging out");

    [PADAlertUtilities showConfirmationActionSheetWithTitle:nil
                                                    message:actionSheetMessage
                                          actionButtonTitle:NSLocalizedString(@"Log Out", nil)
                                       presentingController:self
                                            completionBlock:^{
         [self logOut];
    }];
}

- (IBAction)prepareForUnwind:(UIStoryboardSegue *)segue {
    // This view controller is the destination for an unwind segue from the Create Account screen.
    // This empty method is required for the unwind segue.
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.provisionedDevices count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = NSStringFromClass([PADProvisionedDeviceCell class]);
    PADProvisionedDeviceCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier
                                                                            forIndexPath:indexPath];

    // Get the device name, model name, and activity state for the device corresponding to this cell.
    PADInstallation *installation = (PADInstallation *)[self.provisionedDevices objectAtIndex:indexPath.item];

    DeviceActivityState activityState = [PADDeviceActivityUtilities activityStateForInstallation:installation];
    BOOL showWarning = (activityState != DeviceActivityStateActive);
    [cell setupWithDeviceName:installation.deviceName
                    modelName:installation.model.boardType
                  showWarning:showWarning];

    PFFile *iconFile = installation.model.icon;
    [iconFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error) {
            [cell setImage:[UIImage imageWithData:data]];
        }
    }];

    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedInstallation = [self.provisionedDevices objectAtIndex:indexPath.item];
    [self performSegueWithIdentifier:PADPresentDeviceDetailsSegue sender:nil];
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(collectionView.frame.size.width, kCellHeight);
}

@end
