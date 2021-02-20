//
//  MockerView.m
//  doraemonkit_csx
//
//  Created by 曹世鑫 on 2021/2/20.
//

#import "MockerView.h"
#import "ReactiveObjC.h"
#import "Masonry.h"

@interface MockerView ()
@property (nonatomic, strong)UILabel *titleLabel;
@property (nonatomic, strong)UISwitch *switchBtn;
@property (nonatomic, strong)UITextField *enterTextField;
@property (nonatomic, strong)UIButton *ensureBtn;
@property (nonatomic, copy)SwitchTapBlock tapBlock;

@end

@implementation MockerView

- (instancetype)init {
    if ([super init]) {
        [self createView];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        [self createView];
    }
    return self;
}
- (void)switchTap:(SwitchTapBlock)switchTapBlock {
    self.tapBlock = switchTapBlock;
}

- (void)createView {
    self.backgroundColor = [UIColor clearColor];
    UIView *topBgView = [[UIView alloc]initWithFrame:CGRectZero];
    topBgView.backgroundColor = [UIColor whiteColor];
    [self addSubview:topBgView];
    [topBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(50);
        make.top.mas_equalTo(10);
        make.left.right.mas_equalTo(0);
    }];
    [topBgView addSubview:self.switchBtn];
    [self.switchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-10);
        make.centerY.equalTo(topBgView);
        make.height.mas_offset(40);
        make.width.mas_equalTo(60);
    }];
    [topBgView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10);
        make.centerY.height.equalTo(self.switchBtn);
        make.right.right.equalTo(self.switchBtn.mas_left).offset(-10);
    }];
    
    
    UIView *bottomBgView = [[UIView alloc]initWithFrame:CGRectZero];
    bottomBgView.backgroundColor = [UIColor whiteColor];
    [self addSubview:bottomBgView];
    [bottomBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(50);
        make.top.equalTo(topBgView.mas_bottom).offset(10);
        make.left.right.mas_equalTo(0);
    }];
    [bottomBgView addSubview:self.ensureBtn];
    [self.ensureBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-10);
        make.centerY.equalTo(bottomBgView);
        make.height.mas_offset(40);
        make.width.mas_equalTo(40);
    }];
    [bottomBgView addSubview:self.enterTextField];
    [self.enterTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10);
        make.centerY.height.equalTo(self.ensureBtn);
        make.right.right.equalTo(self.ensureBtn.mas_left).offset(-10);
    }];
}

#pragma lazy
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.text = @"打开模拟开关";
        _titleLabel.font = [UIFont systemFontOfSize:15];
    }
    return _titleLabel;
}
- (UISwitch *)switchBtn {
    if (!_switchBtn) {
        _switchBtn = [[UISwitch alloc]init];
        __weak typeof(self) weakSelf = self;
        [[_switchBtn rac_signalForControlEvents:UIControlEventValueChanged] subscribeNext:^(__kindof UIControl * _Nullable x) {
            if (weakSelf.tapBlock) {
                weakSelf.tapBlock(weakSelf.switchBtn.isOn);
            }
        }];
    }
    return _switchBtn;
}
- (UITextField *)enterTextField {
    if (!_enterTextField) {
        _enterTextField = [[UITextField alloc]initWithFrame:CGRectZero];
        _enterTextField.placeholder = @"请输入经纬度:(示例116.2317 39.5427)";
        _enterTextField.font = [UIFont systemFontOfSize:15];
    }
    return _enterTextField;
}
- (UIButton *)ensureBtn {
    if (!_ensureBtn) {
        _ensureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_ensureBtn setImage:[UIImage imageNamed:@"doraemon_search"] forState:UIControlStateNormal];
        [_ensureBtn setImage:[UIImage imageNamed:@"doraemon_search_highlight"] forState:UIControlStateHighlighted];
        __weak typeof(self) weakSelf = self;
        [[_ensureBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            if (weakSelf.editEnsure) {
                weakSelf.editEnsure(weakSelf.enterTextField.text);
            }
        }];
    }
    return _ensureBtn;
}


@end
