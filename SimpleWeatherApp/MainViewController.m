//
//  MainViewController.m
//  SimpleWeatherApp
//
//  Created by Muresan, Dan-Sorin on 3/6/17.
//  Copyright © 2017 Muresan, Dan-Sorin. All rights reserved.
//

#import "MainViewController.h"
#import "CurrentWeatherDto.h"
#import "DailyForecastCollectionViewCell.h"
#import "WeatherForecastDto.h"

@interface MainViewController ()

@property (nonatomic, readonly) AppDataUtil *appDataUtil;
@property (nonatomic) WeatherSettings *weatherSettings;
@property (nonatomic, strong) NSMutableArray<CurrentWeatherDto *> *forecastDataArray;

@end

@implementation MainViewController {
    CLLocation *lastKnownLocation;
    CLLocationCoordinate2D lastKnownLocationCoordinates;
}

const double defaultLatitude = 46.7667;
const double defaultLongitude = 23.6;
const long defaultCityId = 2172797;

- (instancetype)init
{
    self = [super init];
    if (self) {
        _appDataUtil = [[AppDataUtil alloc] init];
        _weatherManager = [[WeatherManager alloc] init];
        locationManager = [[CLLocationManager alloc] init];
        _settingsViewController = [[SettingsViewController alloc] init];
        
        locationManager.delegate = self;
        locationManager.distanceFilter = kCLDistanceFilterNone;
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
        
        // initialize with a default before the callback gets invoked
        lastKnownLocation = [[CLLocation alloc] initWithLatitude:defaultLatitude longitude:defaultLongitude];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
   
    self.title = @"Forecast";
    
    UINib *cellNib = [UINib nibWithNibName:@"DailyForecastCollectionViewCell" bundle:[NSBundle mainBundle]];
    [_dailyForecastCollectionView registerNib:cellNib forCellWithReuseIdentifier:@"idViewCell"];
    
    // MOCK DATA FOR FORECAST
    /*
    CurrentWeatherDto* weather1 = [[CurrentWeatherDto alloc] init];
    weather1.temperature = 24;
    weather1.weatherDescription = @"sunny";
    weather1.cityName = @"Some City 1";
    
    CurrentWeatherDto* weather2 = [[CurrentWeatherDto alloc] init];
    weather2.temperature = 20;
    weather2.weatherDescription = @"cloudy";
    weather2.cityName = @"Some City 2";
    
    CurrentWeatherDto* weather3 = [[CurrentWeatherDto alloc] init];
    weather3.temperature = 18;
    weather3.weatherDescription = @"rainy";
    weather3.cityName = @"Some City 3";
    
    CurrentWeatherDto* weather4 = [[CurrentWeatherDto alloc] init];
    weather4.temperature = 32;
    weather4.weatherDescription = @"sunny";
    weather4.cityName = @"Some City 4";
    
    _forecastDataArray = [[NSArray alloc] initWithObjects:weather1, weather2, weather3, weather4, nil];
    */
    
    _forecastDataArray = [[NSMutableArray alloc] init];
    
    /*
    UIImageView *background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sunny_background"]];
    [background setFrame:self.view.bounds];
    [self.view addSubview:background];
    [self.view sendSubviewToBack:background];
    [background setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    */
     
    // set nav bar buttons (right)
    UIImage *btnImg = [UIImage imageNamed:@"settings_icon"];
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [btn setImage:btnImg forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(settingsButtonClick) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem  = [[UIBarButtonItem alloc] initWithCustomView: btn];
    
    // left nav bar btn
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshButtonClick)];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    _weatherSettings = [_appDataUtil loadWeatherOptions];
    _weatherSettings.selectedLocation = [_appDataUtil loadLocation];
    [self requestAndStartLocationUpdates];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_forecastDataArray count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //NSString *cellData = [data objectAtIndex:indexPath.row];
    DailyForecastCollectionViewCell *cell = (DailyForecastCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"idViewCell" forIndexPath:indexPath];
    
    CurrentWeatherDto *currentWeather = [_forecastDataArray objectAtIndex:indexPath.row];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"MMM dd"];
    [cell.dayLabel setText:[format stringFromDate:currentWeather.date]];
    [cell.temperatureLabel setText: [NSString stringWithFormat: @"%.1f%@", currentWeather.temperature, @"\u00B0"]];
    [cell.descriptionLabel setText: currentWeather.weatherDescription];
    
    // update weather image
    [_weatherManager getImageForWeather:currentWeather :^(NSData *imageData) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [cell.weatherIcon setImage:[UIImage imageWithData:imageData]];
        });
    }];

    return cell;
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(nonnull NSArray<CLLocation *> *)locations
{
    // get last determined location
    CLLocation *newLocation = (CLLocation *)locations[locations.count - 1];
    
    if (lastKnownLocation != nil && ([lastKnownLocation coordinate].latitude == [newLocation coordinate].latitude) && ([lastKnownLocation coordinate].longitude == [newLocation coordinate].longitude))
    {
        return;
    }
    
    [self startSpinner];
    
    // finish updating location until user request an update again
    [locationManager stopUpdatingLocation];
    NSLog(@"fetching location...%@", locations.description);
    
    // TODO: CONSIDER AUTO-LOCATION FOR ACTUALLY FETCHING WEATHER INSTEAD OF JUST MANUALLY SET LOCATIONS
    long locationId = defaultCityId;
    if (_weatherSettings.autoDetectLocationEnabled)
    {
        lastKnownLocation = (CLLocation *)locations[locations.count - 1];
        lastKnownLocationCoordinates = [lastKnownLocation coordinate];
        CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
        [geoCoder reverseGeocodeLocation:lastKnownLocation completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
            [_locationLabel setText:[NSString stringWithFormat:@"%@, %@", placemarks[placemarks.count - 1].locality, placemarks[placemarks.count - 1].country]];
        }];
    }
    else
    {
        if (_weatherSettings.selectedLocation != nil)
        {
            locationId = _weatherSettings.selectedLocation.cityId;
        }
    }
    
    dispatch_queue_t queue = dispatch_get_main_queue();
    
    // begin fetching weather for location
    [_weatherManager getWeatherDataByLocationId:locationId : _weatherSettings.unitOfMeasurement : ^(CurrentWeatherDto *currentWeatherModel){
        
        currentWeatherModel.cityName = _weatherSettings.selectedLocation.cityName;
        
        // update weather image
        [_weatherManager getImageForWeather:currentWeatherModel :^(NSData *imageData) {
            dispatch_async(queue, ^{
                [_weatherStatusIcon setImage:[UIImage imageWithData:imageData]];
                [self animateWeatherIcon];
            });
        }];
        
        // update rest of UI elements
        dispatch_async(queue, ^{
            [self updateUiFromWeatherModel:currentWeatherModel];
        });
    }];
    
    // begin fetching weather for daily forecast
    [_weatherManager getWeatherForecastDataByLocationId:locationId :_weatherSettings.unitOfMeasurement :^(WeatherForecastDto * weatherForecast) {
        
        // clear out old data
        [_forecastDataArray removeAllObjects];
        
        for (CurrentWeatherDto *forecastItem in weatherForecast.weatherForecastList)
        {
            [_forecastDataArray addObject:forecastItem];
        }
        
        dispatch_async(queue, ^{
            [_dailyForecastCollectionView reloadData];
        });
    }];
    
    [self stopSpinner: NO];
}

-(void) updateUiFromWeatherModel: (CurrentWeatherDto *) weatherModel
{
    [_temperatureLabel setText: [NSString stringWithFormat:@"%.1f%@", weatherModel.temperature, @"\u00B0"]];
    [_descriptionLabel setText: [NSString stringWithFormat:@"%@", weatherModel.weatherDescription]];
    [_tempUnitLabel setText:[self getTempUnit:_weatherSettings.unitOfMeasurement]];
    [_locationLabel setText:weatherModel.cityName];
    
    // update last sync time
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"MMM dd, yyyy HH:mm"];
    [_lastUpdateLabel setText:[format stringFromDate:[NSDate date]]];
    
    NSLog(@"refreshed...");
}

-(void) animateWeatherIcon
{
    if (!_weatherSettings.animationsEnabled)
    {
        return;
    }
    
    // zoom in
    [UIView animateWithDuration:2.0f animations:^{
        _weatherStatusIcon.transform = CGAffineTransformMakeScale(3, 3);
    } completion:^(BOOL finished){}];
    
    // zoom out
    [UIView animateWithDuration:1.7f animations:^{
        _weatherStatusIcon.transform = CGAffineTransformMakeScale(1, 1);
    } completion:^(BOOL finished){}];

}

-(NSString *) getTempUnit: (UnitOfMeasurement) unitOfMeasurement
{
    switch (unitOfMeasurement) {
        case Metric:
            return @"Celsius";
            
        case Imperial:
            return @"Fahrenheit";
            
        default:
            return @"Kelvin";
    }
}

-(void) startSpinner
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [_loadingSpinner setHidden:NO];
        [_loadingSpinner startAnimating];
    });
}

-(void) stopSpinner: (BOOL)withDelay
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [_loadingSpinner stopAnimating];
        [_loadingSpinner setHidden:YES];
    });
}

-(void) settingsButtonClick
{
    [self.navigationController pushViewController:self.settingsViewController animated:YES];
}

-(void) refreshButtonClick
{
    NSLog(@"refreshing...");
    [self requestAndStartLocationUpdates];
}

-(void) requestAndStartLocationUpdates
{
    lastKnownLocation = nil;
    NSLog(@"loading...");
    if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [locationManager requestWhenInUseAuthorization];
    }
    
    [locationManager startUpdatingLocation];
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
