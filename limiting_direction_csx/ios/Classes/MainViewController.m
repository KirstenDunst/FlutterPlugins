//
//  MainViewController.m
//  Runner
//
//  Created by 曹世鑫 on 2020/12/28.
//

#import "MainViewController.h"

@interface MainViewController ()
@property (nonatomic, assign)UIInterfaceOrientationMask supportedOrientations;
@end

@implementation MainViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.supportedOrientations = UIInterfaceOrientationMaskAll;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(supportedOrientationsChanged:) name:@"LimitingDirectionCsxPlugin" object:nil];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LimitingDirectionCsxPlugin" object:nil];
}

- (void)supportedOrientationsChanged:(NSNotification *)sender {
    NSDictionary *temp = [sender userInfo];
    int param = 5;
    if ([temp.allKeys containsObject:@"orientationMask"]) {
        param = [temp[@"orientationMask"] intValue];
    }
    self.supportedOrientations = [OrientationUtil getOrientationMaskWithIndex:param];
}

- (UIInterfaceOrientationMask )supportedInterfaceOrientations {
    return self.supportedOrientations;
}
- (BOOL)shouldAutorotate {
    return true;
}
@end


@implementation OrientationUtil
    //转化工具
+ (UIInterfaceOrientationMask) getOrientationMaskWithIndex:(int)index {
    UIInterfaceOrientationMask mask = UIInterfaceOrientationMaskAll;
    switch (index) {
        case 0:
            mask = UIInterfaceOrientationMaskPortrait;
            break;
        case 1:
            mask = UIInterfaceOrientationMaskLandscapeLeft;
            break;
        case 2:
            mask = UIInterfaceOrientationMaskLandscapeRight;
            break;
        case 3:
            mask = UIInterfaceOrientationMaskPortraitUpsideDown;
            break;
        case 4:
            mask = UIInterfaceOrientationMaskLandscape;
            break;
        case 5:
            mask = UIInterfaceOrientationMaskAll;
            break;
        case 6:
            mask = UIInterfaceOrientationMaskAllButUpsideDown;
            break;
            
        default:
            mask = UIInterfaceOrientationMaskAll;
            break;
    }
    return mask;
}
   
@end
