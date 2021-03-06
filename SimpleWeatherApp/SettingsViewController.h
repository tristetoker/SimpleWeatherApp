//
//  SettingsViewController.h
//  SimpleWeatherApp
//
//  Created by Muresan, Dan-Sorin on 3/7/17.
//  Copyright © 2017 Muresan, Dan-Sorin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDataUtil.h"

@interface SettingsViewController : UIViewController

@property (strong, nonatomic) IBOutlet UISegmentedControl *unitOfMeasurementSelectionControl;
@property (strong, nonatomic) IBOutlet UISwitch *autoDetectLocationEnabledSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *animationsEnabledSwitch;
@property (strong, nonatomic) IBOutlet UITextField *customLocationTextField;
@property (nonatomic, readonly) WeatherSettings *weatherSettings;
@property (strong, nonatomic) IBOutlet UISegmentedControl *numberOfDaysInForecastSelectionControl;
@property (strong, nonatomic) IBOutlet UIButton *customLocationFromMapButton;
@property (strong, nonatomic) IBOutlet UIButton *customConstraintsTestPageButton;
@property (strong, nonatomic) IBOutlet UIButton *testPostRequestsButton;
@property (strong, nonatomic) IBOutlet UIButton *testBluetoothButton;

@end
