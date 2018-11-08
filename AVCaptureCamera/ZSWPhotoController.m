//
//  ZSWPhotoController.m
//  AVCaptureCamera
//
//  Created by ZSW on 2018/11/7.
//  Copyright © 2018年 ZSW. All rights reserved.
//

#import "ZSWPhotoController.h"

@interface ZSWPhotoController ()

@end

@implementation ZSWPhotoController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //横屏拍摄的时候，旋转图片
    UIImage *image = [UIImage imageWithCGImage:self.photo.CGImage scale:1.0 orientation:UIImageOrientationUp];
    
    UIImageView *photo = [UIImageView new];
    photo.frame = self.view.bounds;
    photo.image = image;
    [self.view addSubview:photo];
    
    //将横屏拍摄的图片旋转至竖屏，并调整imageview的尺寸
    CGFloat width = self.view.frame.size.width;
    
    CGFloat height = image.size.height * width / image.size.width;
    CGRect frame = photo.frame;
    frame.size.height = height;
    photo.frame = frame;
    photo.center = self.view.center;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)resetImage {
    
    
    
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
