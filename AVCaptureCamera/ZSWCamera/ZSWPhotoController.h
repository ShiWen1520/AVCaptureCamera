//
//  ZSWPhotoController.h
//  AVCaptureCamera
//
//  Created by ZSW on 2018/11/7.
//  Copyright © 2018年 ZSW. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZSWPhotoController : UIViewController

/* photo */
@property (nonatomic, strong) UIImage *photo;
/* 设备方向 */
@property (nonatomic, assign) UIDeviceOrientation orientation;

@end
