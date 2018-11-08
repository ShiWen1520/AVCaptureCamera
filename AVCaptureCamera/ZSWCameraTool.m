//
//  ZSWCameraTool.m
//  AVCaptureCamera
//
//  Created by ZSW on 2018/11/7.
//  Copyright © 2018年 ZSW. All rights reserved.
//

#import "ZSWCameraTool.h"

@interface ZSWCameraTool ()

/* 拍摄按钮 */
@property (nonatomic, strong) UIButton *startBtn;
/* 闪光灯按钮 */
@property (nonatomic, strong) UIButton *flashBtn;
/* 切换镜头按钮 */
@property (nonatomic, strong) UIButton *switchBtn;
/* 遮罩 */
@property (nonatomic, strong) UIView *coverView;

@end

@implementation ZSWCameraTool

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        
        [self setupBtn];
        [self setupCoverView];
        
    }
    return self;
}

- (void)setupBtn {
    //拍摄按钮
    self.startBtn.frame = CGRectMake((self.frame.size.width - 80) / 2, self.frame.size.height - 100, 80, 80);
    [self addSubview:self.startBtn];
    
    //闪光灯按钮
    self.flashBtn.frame = CGRectMake(self.frame.size.width - 95, (self.frame.size.height - 80) / 2 - 90, 80, 80);
    [self addSubview:self.flashBtn];
    
    //切换镜头按钮
    self.switchBtn.frame = CGRectMake(self.frame.size.width - 95, (self.frame.size.height - 80) / 2, 80, 80);
    [self addSubview:self.switchBtn];
}

- (void)setupCoverView {
    
    self.coverView.frame = self.bounds;
    [self addSubview:self.coverView];
    
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    closeBtn.frame = CGRectMake((self.frame.size.width - 160)/3, self.frame.size.height - 100, 80, 80);
    [closeBtn setTitle:@"重拍" forState:UIControlStateNormal];
    [closeBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(closeAction) forControlEvents:UIControlEventTouchUpInside];
    [self.coverView addSubview:closeBtn];
    
    UIButton *completionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    completionBtn.frame = CGRectMake((self.frame.size.width - 160)/3 * 2 + 80, self.frame.size.height - 100, 80, 80);
    [completionBtn setTitle:@"完成" forState:UIControlStateNormal];
    [completionBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [completionBtn addTarget:self action:@selector(completionAction) forControlEvents:UIControlEventTouchUpInside];
    [self.coverView addSubview:completionBtn];
    
}

#pragma mark - set
- (void)setImage:(UIImage *)image {
    _image = image;
    if(image) {
        self.coverView.hidden = NO;
        self.startBtn.hidden = self.flashBtn.hidden = self.switchBtn.hidden = YES;
    }
}

#pragma mark -btn action
//拍摄
- (void)startCamera {
    if([self.delegate respondsToSelector:@selector(startCamera)]) {
        [self.delegate startCamera];
    }
}

//闪光灯
- (void)lightFlash:(UIButton *)sender {
    sender.selected = !sender.selected;
    if([self.delegate respondsToSelector:@selector(lightFlash)]) {
        [self.delegate lightFlash];
    }
}

//切换镜头
- (void)switchPosition:(UIButton *)sender {
    sender.selected = !sender.selected;
    if([self.delegate respondsToSelector:@selector(switchCameraPosition)]) {
        [self.delegate switchCameraPosition];
    }
}

//重拍
- (void)closeAction {
    self.coverView.hidden = YES;
    self.startBtn.hidden = self.flashBtn.hidden = self.switchBtn.hidden = NO;
    if([self.delegate respondsToSelector:@selector(reshoot)]) {
        [self.delegate reshoot];
    }
}

//完成
- (void)completionAction {
    self.coverView.hidden = YES;
    self.startBtn.hidden = self.flashBtn.hidden = self.switchBtn.hidden = NO;
    if([self.delegate respondsToSelector:@selector(completionShootWithPhoto:)]) {
        [self.delegate completionShootWithPhoto:self.image];
    }
}

#pragma mark - lazy
- (UIButton *)startBtn {
    if(!_startBtn) {
        _startBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_startBtn setTitle:@"拍摄" forState:UIControlStateNormal];
        [_startBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [_startBtn addTarget:self action:@selector(startCamera) forControlEvents:UIControlEventTouchUpInside];
    }
    return _startBtn;
}

- (UIButton *)flashBtn {
    if(!_flashBtn) {
        _flashBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_flashBtn setTitle:@"开灯" forState:UIControlStateNormal];
        [_flashBtn setTitle:@"关灯" forState:UIControlStateSelected];
        [_flashBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [_flashBtn addTarget:self action:@selector(lightFlash:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _flashBtn;
}

- (UIButton *)switchBtn {
    if(!_switchBtn) {
        _switchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_switchBtn setTitle:@"前置" forState:UIControlStateNormal];
        [_switchBtn setTitle:@"后置" forState:UIControlStateSelected];
        [_switchBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [_switchBtn addTarget:self action:@selector(switchPosition:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _switchBtn;
}

- (UIView *)coverView {
    if(!_coverView) {
        _coverView = [UIView new];
        _coverView.hidden = YES;
    }
    return _coverView;
}


@end
