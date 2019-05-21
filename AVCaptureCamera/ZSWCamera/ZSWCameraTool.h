//
//  ZSWCameraTool.h
//  AVCaptureCamera
//
//  Created by ZSW on 2018/11/7.
//  Copyright © 2018年 ZSW. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ZSWCameraToolDelegate <NSObject>
//开始拍摄
- (void)startCamera;
//闪光灯设置
- (void)lightFlash;
//镜头设置
- (void)switchCameraPosition;
//重新拍摄
- (void)reshoot;
//完成
- (void)completionShootWithPhoto:(UIImage *)photo;

@end

@interface ZSWCameraTool : UIView

/* delegate */
@property (nonatomic, weak) id <ZSWCameraToolDelegate> delegate;
/* image */
@property (nonatomic, strong) UIImage *image;

@end
