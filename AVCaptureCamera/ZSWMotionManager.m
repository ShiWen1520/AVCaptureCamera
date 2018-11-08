//
//  ZSWMotionManager.m
//  AVCaptureCamera
//
//  Created by ZSW on 2018/11/8.
//  Copyright © 2018年 ZSW. All rights reserved.
//

#import "ZSWMotionManager.h"
#import <CoreMotion/CoreMotion.h>

@interface ZSWMotionManager ()

/* motionManager */
@property (nonatomic, strong) CMMotionManager *motionManager;
/* block */
@property (nonatomic, copy) MotionDeviceOrientation motionDeviceOrientation;

@end

@implementation ZSWMotionManager

- (void)startMotionManager:(MotionDeviceOrientation)motionDeviceOrientation {
    self.motionDeviceOrientation = motionDeviceOrientation;
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    //开启陀螺仪监测设备方向，motionManager必须设置为全局强引用属性，否则无法开启陀螺仪监测；
    self.motionManager.deviceMotionUpdateInterval = 0.1;
    if(self.motionManager.deviceMotionAvailable) {
        __weak __typeof(self) weak_self = self;
        //实时更新陀螺仪设备感应
        [self.motionManager startDeviceMotionUpdates];
        //实时更新陀螺仪设备感应方法
        [self.motionManager startDeviceMotionUpdatesToQueue:queue withHandler:^(CMDeviceMotion * _Nullable motion, NSError * _Nullable error) {
            //回到主线程，获取设备方向
            [weak_self performSelectorOnMainThread:@selector(handleDeviceMotion:) withObject:motion waitUntilDone:YES];
        }];
    }
}

- (void)handleDeviceMotion:(CMDeviceMotion *)deviceMotion {
    
    double x = deviceMotion.gravity.x;
    double y = deviceMotion.gravity.y;
    if(fabs(y) >= fabs(x)) {
        if(y >= 0) {
            self.motionDeviceOrientation(2);  //UIDeviceOrientationPortraitUpsideDown
        }else {
            self.motionDeviceOrientation(1);  //UIDeviceOrientationPortrait
        }
    }else {
        if(x >= 0) {
            self.motionDeviceOrientation(4);  //UIDeviceOrientationLandscapeRight
        }else {
            self.motionDeviceOrientation(3);  //UIDeviceOrientationLandscapeLeft
        }
    }
    
    //停止陀螺仪设备感应
    [self.motionManager stopDeviceMotionUpdates];
    
}

#pragma mark - lazy
- (CMMotionManager *)motionManager {
    if(!_motionManager) {
        _motionManager = [[CMMotionManager alloc] init];
    }
    return _motionManager;
}

@end
