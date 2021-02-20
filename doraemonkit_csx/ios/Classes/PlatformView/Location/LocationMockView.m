//
//  LocationMockView.m
//  doraemonkit_csx
//
//  Created by 曹世鑫 on 2021/2/19.
//

#import "LocationMockView.h"
#import "LocationAnnotation.h"
#import <CoreGraphics/CoreGraphics.h>
#import <MapKit/MapKit.h>
#import "ReactiveObjC.h"
#import "Masonry.h"
#import "MockerView.h"

@interface LocationMockView ()<MKMapViewDelegate,CLLocationManagerDelegate>
@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) CLLocationManager *lcManager;
@property (nonatomic, strong) UILabel *showLabel;
@end


@implementation LocationMockView {
    CGRect _frame;
    int64_t _viewId;
    id _args;
}

- (id)initWithFrame:(CGRect)frame viewId:(int64_t)viewId args:(id)args {
    if (self = [super init]) {
        _frame = frame;
        _viewId = viewId;
        _args = args;
    }
    return self;
}

- (UIView *)view {
    MockerView *mockView = [[MockerView alloc]init];
    [self.mapView addSubview:mockView];
    [mockView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
    }];
    
    UIImageView *localImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"doraemon_location"]];
    localImage.backgroundColor = [UIColor orangeColor];
    [self.mapView addSubview:localImage];
    [localImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.mapView.mas_centerY);
        make.centerX.equalTo(self.mapView);
        make.size.mas_equalTo(CGSizeMake(1.5, 20));
    }];
    UIImageView *downImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"doraemon_mock_filter_down"]];
    downImage.backgroundColor = [UIColor orangeColor];
    downImage.layer.cornerRadius = 6;
    downImage.clipsToBounds = true;
    [self.mapView addSubview:downImage];
    [downImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(localImage.mas_top);
        make.centerX.equalTo(localImage);
        make.size.mas_equalTo(CGSizeMake(12, 12));
    }];
    [self.mapView addSubview:self.showLabel];
    [self.showLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(downImage);
        make.bottom.equalTo(downImage.mas_top);
    }];
    
    return self.mapView;
}

//如果没有获得定位授权，获取定位授权请求
- (void)requestUserLocationAuthor{
    if ([CLLocationManager locationServicesEnabled]) {
        if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedWhenInUse) {
            [self.lcManager requestWhenInUseAuthorization];
        }
        [self.lcManager startUpdatingLocation]; // 开始更新位置
    }
}

/** 获取到新的位置信息时调用*/
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    CLLocation *location = locations[0];
    NSLog(@"location at %f %f",location.coordinate.longitude,location.coordinate.latitude);
    
//       CLLocationCoordinate2D centerCoordinate;
//       centerCoordinate.latitude = location.coordinate.latitude;
//       centerCoordinate.longitude = location.coordinate.longitude;
//       MKCoordinateRegion region;
//       region.center = centerCoordinate;
//       region.span = self.mapView.region.span;
//       [self.mapView setRegion:region animated:TRUE];
}
/** 不能获取位置信息时调用*/
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSLog(@"location failure");
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    NSLog(@"did at %f %f",self.showLabel.center.x,self.showLabel.center.y);
    CLLocationCoordinate2D touchMapCoordinate =
        [self.mapView convertPoint:self.showLabel.center toCoordinateFromView:self.mapView];
    _showLabel.text = [NSString stringWithFormat:@"%f %f",touchMapCoordinate.longitude, touchMapCoordinate.latitude];
}

#pragma lazy
- (CLLocationManager *)lcManager {
    if (!_lcManager) {
        _lcManager = [[CLLocationManager alloc]init];
        // 设置代理
        _lcManager.delegate = self;
        // 设置定位距离过滤参数 (当本次定位和上次定位之间的距离大于或等于这个值时，调用代理方法)
        _lcManager.distanceFilter = 100;
        // 设置定位精度(精度越高越耗电)
        _lcManager.desiredAccuracy = kCLLocationAccuracyBest;
    }
    return _lcManager;
}
- (UILabel *)showLabel {
    if (!_showLabel) {
        _showLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _showLabel.text = @"";
        _showLabel.textColor = [UIColor orangeColor];
        _showLabel.backgroundColor = [UIColor colorWithWhite:1 alpha:0.3];
        _showLabel.font = [UIFont systemFontOfSize:12];
    }
    return _showLabel;
}
- (MKMapView *)mapView {
    if (!_mapView) {
        _mapView = [[MKMapView alloc] initWithFrame:_frame];
        _mapView.mapType = MKMapTypeStandard;
    //    mapView.showsUserLocation=YES;
        _mapView.delegate = self;
        [_mapView setZoomEnabled:YES];
        [_mapView setScrollEnabled:YES];
        CLLocationCoordinate2D centerCoordinate;
        centerCoordinate.latitude = 39.9;
        centerCoordinate.longitude = 116.4;
        MKCoordinateSpan span;
        span.latitudeDelta = 0.05;
        span.longitudeDelta = 0.05;
        MKCoordinateRegion region;
        region.center = centerCoordinate;
        region.span = span;
        //设置地图模式
        [_mapView setRegion:region animated:true];
        [_mapView setMapType:MKMapTypeStandard];
    }
    return _mapView;
}
@end
