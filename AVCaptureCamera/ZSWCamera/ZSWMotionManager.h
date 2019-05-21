//
//  ZSWMotionManager.h
//  AVCaptureCamera
//
//  Created by ZSW on 2018/11/8.
//  Copyright © 2018年 ZSW. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^MotionDeviceOrientation)(NSInteger orientation);

@interface ZSWMotionManager : NSObject

/**
开始陀螺仪监测

@param motionDeviceOrientation 陀螺仪监测设备方向回调，获取到设备的方向

**/
- (void)startMotionManager:(MotionDeviceOrientation)motionDeviceOrientation;

@end
