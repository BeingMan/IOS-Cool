//
//  WeatherViewController.m
//  Final
//
//  Created by ybc on 2019/6/10.
//  Copyright © 2019 ybc. All rights reserved.
//

#import "WeatherViewController.h"
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "TLCityPickerController.h"
#define APIKey @"7c01017f33dd81165a99a4f44cbe7a84"
@interface WeatherViewController ()<AMapSearchDelegate,CLLocationManagerDelegate,MKMapViewDelegate,TLCityPickerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *cityPicker;
- (IBAction)pickCity:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *weather;
@property (weak, nonatomic) IBOutlet UILabel *temp;
@property (weak, nonatomic) IBOutlet UILabel *windd;
@property (weak, nonatomic) IBOutlet UILabel *windp;
@property (weak, nonatomic) IBOutlet UILabel *hum;

@property (weak, nonatomic) IBOutlet UILabel *time1;
@property (weak, nonatomic) IBOutlet UILabel *mw1;
@property (weak, nonatomic) IBOutlet UILabel *mp1;
@property (weak, nonatomic) IBOutlet UILabel *ew1;
@property (weak, nonatomic) IBOutlet UILabel *ep1;
@property (weak, nonatomic) IBOutlet UILabel *day1;
@property (weak, nonatomic) IBOutlet UILabel *eve1;

@property (weak, nonatomic) IBOutlet UILabel *time2;
@property (weak, nonatomic) IBOutlet UILabel *mw2;
@property (weak, nonatomic) IBOutlet UILabel *mp2;
@property (weak, nonatomic) IBOutlet UILabel *ew2;
@property (weak, nonatomic) IBOutlet UILabel *ep2;
@property (weak, nonatomic) IBOutlet UILabel *day2;
@property (weak, nonatomic) IBOutlet UILabel *eve2;

@property (weak, nonatomic) IBOutlet UILabel *time3;
@property (weak, nonatomic) IBOutlet UILabel *mw3;
@property (weak, nonatomic) IBOutlet UILabel *mp3;
@property (weak, nonatomic) IBOutlet UILabel *ew3;
@property (weak, nonatomic) IBOutlet UILabel *ep3;
@property (weak, nonatomic) IBOutlet UILabel *day3;
@property (weak, nonatomic) IBOutlet UILabel *eve3;

@property (nonatomic,strong)AMapSearchAPI *search;
@property (nonatomic,strong)AMapSearchAPI *search1;
@property (nonatomic,strong)AMapSearchAPI *Geosearch;
@property (nonatomic,strong)MKMapView *mapView;
@property (nonatomic,assign)float latitude;
@property (nonatomic,assign)float longitude;
@property (nonatomic,strong)NSString *currentCity;
@end

@implementation WeatherViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}
- (void)setWeatherWithCityname:(NSString *)cityName{
    [AMapServices sharedServices].apiKey = APIKey;
    self.search = [[AMapSearchAPI alloc] init];
    self.search.delegate = self;
    AMapWeatherSearchRequest *request = [[AMapWeatherSearchRequest alloc] init];
    request.city = cityName;
    request.type = AMapWeatherTypeLive;
    [self.search AMapWeatherSearch:request];
    
    self.search1 = [[AMapSearchAPI alloc] init];
    self.search1.delegate = self;
    AMapWeatherSearchRequest *request1 = [[AMapWeatherSearchRequest alloc] init];
    request1.city = cityName;
    request1.type = AMapWeatherTypeForecast;
    [self.search1 AMapWeatherSearch:request1];
}
- (void)onWeatherSearchDone:(AMapWeatherSearchRequest *)request response:(AMapWeatherSearchResponse *)response
{
    if(request.type == AMapWeatherTypeLive){
        if (response.lives.count == 0) {
            return ;
        }
        AMapLocalWeatherLive *live = (AMapLocalWeatherLive *)response.lives[0];
        
        self.weather.text =live.weather;
        self.temp.text = [live.temperature stringByAppendingString:@"℃"];
        self.windd.text = [live.windDirection stringByAppendingString:@"风"];
        self.windp.text = [live.windPower stringByAppendingString:@"级"];
        self.hum.text = [@"湿度 " stringByAppendingString:[live.humidity stringByAppendingString:@"%"]];
    }else if(request.type == AMapWeatherTypeForecast){
        if (response.forecasts.count == 0) {
            return ;
        }
        NSArray<AMapLocalDayWeatherForecast *> *live = response.forecasts[0].casts;
        
        self.time1.text = live[0].date;
        self.mw1.text = [live[0].dayTemp stringByAppendingString:@"℃"];
        self.mp1.text = live[0].dayWeather;
        self.ew1.text = [live[0].nightTemp stringByAppendingString:@"℃"];
        self.ep1.text = live[0].nightWeather;
        self.day1.text = @"早上";
        self.eve1.text = @"晚上";
        
        self.time2.text = live[1].date;
        self.mw2.text = [live[1].dayTemp stringByAppendingString:@"℃"];
        self.mp2.text = live[1].dayWeather;
        self.ew2.text = [live[1].nightTemp stringByAppendingString:@"℃"];
        self.ep2.text = live[1].nightWeather;
        self.day2.text = @"早上";
        self.eve2.text = @"晚上";
        
        self.time3.text = live[2].date;
        self.mw3.text = [live[2].dayTemp stringByAppendingString:@"℃"];
        self.mp3.text = live[2].dayWeather;
        self.ew3.text = [live[2].nightTemp stringByAppendingString:@"℃"];
        self.ep3.text = live[2].nightWeather;
        self.day3.text = @"早上";
        self.eve3.text = @"晚上";
    }
}

#pragma mark - TLCityPickerDelegate
- (void) cityPickerController:(TLCityPickerController *)cityPickerViewController didSelectCity:(TLCity *)city
{
    [self.cityPicker setTitle:city.cityName forState:UIControlStateNormal];
    [self setWeatherWithCityname:city.cityName];
    [cityPickerViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void) cityPickerControllerDidCancel:(TLCityPickerController *)cityPickerViewController
{
    [cityPickerViewController dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)pickCity:(id)sender {
    TLCityPickerController *cityPickerVC = [[TLCityPickerController alloc] init];
    [cityPickerVC setDelegate:self];
    
    cityPickerVC.locationCityID = @"600010000";
    cityPickerVC.hotCitys = @[@"100010000", @"200010000", @"300210000", @"600010000", @"300110000"];
    
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:cityPickerVC] animated:YES completion:^{
        
    }];
}
@end
