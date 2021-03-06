//
//  AppDataUtil.m
//  SimpleWeatherApp
//
//  Created by Muresan, Dan-Sorin on 3/7/17.
//  Copyright © 2017 Muresan, Dan-Sorin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDataUtil.h"

@implementation AppDataUtil : NSObject

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

+ (AppDataUtil *)singleSharedInstance
{
    static AppDataUtil *_sharedInstance = nil;
    static dispatch_once_t onceSecuredPredicate;
    dispatch_once(&onceSecuredPredicate, ^{
        _sharedInstance = [[self alloc] init];
    });
    
    return _sharedInstance;
}

- (void)saveWeatherOptions:(WeatherSettings *)weatherSettings
{
    [[NSUserDefaults standardUserDefaults] setBool:weatherSettings.autoDetectLocationEnabled forKey:@"autoDetectLocationEnabledKey"];
    [[NSUserDefaults standardUserDefaults] setBool:weatherSettings.animationsEnabled forKey:@"animationsEnabledKey"];
    [[NSUserDefaults standardUserDefaults] setInteger:weatherSettings.unitOfMeasurement forKey:@"unitOfMeasurementKey"];
    [[NSUserDefaults standardUserDefaults] setInteger:weatherSettings.numberOfDaysInForecast forKey:@"numberOfDaysInForecast"];
}

- (WeatherSettings *)loadWeatherOptions
{
    WeatherSettings *weatherSettings = [[WeatherSettings alloc] init];
    weatherSettings.animationsEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"animationsEnabledKey"];
    weatherSettings.autoDetectLocationEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"autoDetectLocationEnabledKey"];
    weatherSettings.unitOfMeasurement = (UnitOfMeasurement)[[NSUserDefaults standardUserDefaults] integerForKey:@"unitOfMeasurementKey"];
    weatherSettings.numberOfDaysInForecast = [[NSUserDefaults standardUserDefaults] integerForKey:@"numberOfDaysInForecast"];
    
    return weatherSettings;
}

- (void)saveLocation:(LocationDto *)location
{
    [[NSUserDefaults standardUserDefaults] setInteger: location.cityId forKey:@"cityIdKey"];
    [[NSUserDefaults standardUserDefaults] setObject:location.cityName forKey:@"cityNameKey"];
    [[NSUserDefaults standardUserDefaults] setDouble:location.latitude forKey:@"latitude"];
    [[NSUserDefaults standardUserDefaults] setDouble:location.longitude forKey:@"longitude"];
}

- (LocationDto *)loadLocation
{
    LocationDto *locationModel = [[LocationDto alloc] init];
    locationModel.cityId = [[NSUserDefaults standardUserDefaults] integerForKey:@"cityIdKey"];
    locationModel.cityName = [[NSUserDefaults standardUserDefaults] stringForKey:@"cityNameKey"];
    locationModel.latitude = [[NSUserDefaults standardUserDefaults] doubleForKey:@"latitude"];
    locationModel.longitude = [[NSUserDefaults standardUserDefaults] doubleForKey:@"longitude"];
    
    return locationModel;
}

- (void) saveWeatherDto: (CurrentWeatherDto *)weatherDto {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:weatherDto];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"currentWeatherDto"];
}

- (CurrentWeatherDto *) loadWeatherDto {
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"currentWeatherDto"];
    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}

- (void) saveWeatherArray:(NSDictionary *)weatherDictionary
{
    NSMutableArray *weatherArray = [NSMutableArray arrayWithCapacity:weatherDictionary.count];
    for (id key in weatherDictionary)
    {
        CurrentWeatherDto *currentItemWeather = (CurrentWeatherDto *)[weatherDictionary objectForKey:key];
        NSData *encodedWeatherObject = [NSKeyedArchiver archivedDataWithRootObject:currentItemWeather];
        [weatherArray addObject:encodedWeatherObject];
    }

    [[NSUserDefaults standardUserDefaults] setObject:weatherArray forKey:@"weatherArray"];
}

- (NSArray *)loadWeatherArray
{
    NSArray *arr = [[NSUserDefaults standardUserDefaults] objectForKey:@"weatherArray"];
    NSMutableArray *weatherArr = [NSMutableArray arrayWithCapacity:arr.count];

    for (NSData *dataItem in arr)
    {
        CurrentWeatherDto *decodedItem = [NSKeyedUnarchiver unarchiveObjectWithData:dataItem];
        [weatherArr addObject:decodedItem];
    }

    return weatherArr;
}

@end
