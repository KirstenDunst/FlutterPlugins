//
//  LocationAnnotation.h
//  doraemonkit_csx
//
//  Created by 曹世鑫 on 2021/2/19.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LocationAnnotation : NSObject<MKAnnotation>

/* 必须创建的属性 */
@property (nonatomic) CLLocationCoordinate2D coordinate;
/* 可选的属性 */
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
/* 自定义的属性 */
@property (nonatomic, strong) UIImage *icon;


@end

NS_ASSUME_NONNULL_END
