//
//  SettingsViewController.m
//  SimpleWeatherApp
//
//  Created by Muresan, Dan-Sorin on 3/7/17.
//  Copyright © 2017 Muresan, Dan-Sorin. All rights reserved.
//

#import "SettingsViewController.h"
#import "LocationSelectorViewController.h"

@interface SettingsViewController ()

@property (nonatomic, readonly) AppDataUtil *appDataUtil;
@property (nonatomic, readonly) LocationSelectorViewController *locationSelectorViewController;

@end

@implementation SettingsViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        _appDataUtil = [[AppDataUtil alloc] init];
        _locationSelectorViewController = [[LocationSelectorViewController alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"Settings";
    
    // add events for controls
    [_unitOfMeasurementSelectionControl addTarget:self action:@selector(onUnitOfMeasurementSettingSelected) forControlEvents:UIControlEventValueChanged];
    [_autoDetectLocationEnabledSwitch addTarget:self action:@selector(onAutoDetectLocationSettingSwitched) forControlEvents:UIControlEventValueChanged];
    [_animationsEnabledSwitch addTarget:self action:@selector(onAnimtationsSettingSwitched) forControlEvents:UIControlEventValueChanged];
    [_customLocationTextField addTarget:self action:@selector(onCustomLocationTextFieldClick) forControlEvents:UIControlEventTouchDown];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadCurrentSettings];
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _customLocationTextField.text = [_appDataUtil loadLocation].cityName;
}

-(void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self saveCurrentSettings];
}

-(void) loadCurrentSettings
{
    _weatherSettings = [_appDataUtil loadWeatherOptions];
    [_autoDetectLocationEnabledSwitch setOn:_weatherSettings.autoDetectLocationEnabled];
    [_autoDetectLocationEnabledSwitch isOn] ? [_customLocationTextField setEnabled:NO] : [_customLocationTextField setEnabled:YES];
    [_animationsEnabledSwitch setOn:_weatherSettings.animationsEnabled];
    [_unitOfMeasurementSelectionControl setSelectedSegmentIndex:_weatherSettings.unitOfMeasurement];
}

-(void) saveCurrentSettings
{
    [_appDataUtil saveWeatherOptions: _weatherSettings];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) onUnitOfMeasurementSettingSelected
{
    _weatherSettings.unitOfMeasurement = [_unitOfMeasurementSelectionControl selectedSegmentIndex];
}

-(void) onAutoDetectLocationSettingSwitched
{
    _weatherSettings.autoDetectLocationEnabled = [_autoDetectLocationEnabledSwitch isOn];
    
    if (_weatherSettings.autoDetectLocationEnabled)
    {
        [_customLocationTextField setEnabled:NO];
    }
    else
    {
        [_customLocationTextField setEnabled:YES];
    }
}

-(void) onCustomLocationTextFieldClick
{
    if (_weatherSettings.autoDetectLocationEnabled)
    {
        return;
    }
    
    [self presentViewController:_locationSelectorViewController animated:YES completion:^{
        
    }];
}

-(void) onAnimtationsSettingSwitched
{
    _weatherSettings.animationsEnabled = [_animationsEnabledSwitch isOn];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end