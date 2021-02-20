//
//  MockerView.h
//  doraemonkit_csx
//
//  Created by 曹世鑫 on 2021/2/20.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^EditEnsure)(NSString *enterStr);
typedef void(^SwitchTapBlock)(bool isOn);

@interface MockerView : UIView

//开关是否打开（可读可设置）
@property (nonatomic, assign) bool isOn;

//编辑器确认的结果返回，可能为空
@property (nonatomic, copy)EditEnsure editEnsure;

//触发按钮的时候的回调
- (void)switchTap:(SwitchTapBlock)switchTapBlock;

@end

NS_ASSUME_NONNULL_END
