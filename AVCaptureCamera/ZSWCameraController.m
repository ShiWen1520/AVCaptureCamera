//
//  ZSWCameraController.m
//  AVCaptureCamera
//
//  Created by ZSW on 2018/11/7.
//  Copyright © 2018年 ZSW. All rights reserved.
//

#import "ZSWCameraController.h"
#import <AVFoundation/AVFoundation.h>
#import "ZSWCameraTool.h"
#import "ZSWPhotoController.h"
#import "ZSWMotionManager.h"
#import <CoreMotion/CoreMotion.h>

@interface ZSWCameraController ()<AVCapturePhotoCaptureDelegate,ZSWCameraToolDelegate>

/* 捕获设备，通常是前置摄像头、后置摄像头、麦克风 */
@property (nonatomic, strong) AVCaptureDevice *device;
/* 输入设备，使用AVCaptureDevice来初始化 */
@property (nonatomic, strong) AVCaptureDeviceInput *input;
/* 输出图片 */
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 1000000  //iOS10.0以后的属性
@property (nonatomic, strong) AVCapturePhotoOutput *photoOutput;
#else
@property (nonatomic, strong) AVCaptureStillImageOutput *imageOutput;
#endif
/* 可以把输入输出结合在一起，并开始启动捕获设备(摄像头) */
@property (nonatomic, strong) AVCaptureSession *session;
/* 图像预览层，实时显示捕获的图像 */
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
/* 闪光灯 */
@property (nonatomic, assign) AVCaptureFlashMode mode;
/* 前后置摄像头 */
@property (nonatomic, assign) AVCaptureDevicePosition position;
/* cameraTool */
@property (nonatomic, strong) ZSWCameraTool *cameraTool;
/* 最小缩放值 */
@property (nonatomic, assign) CGFloat minZoomFactor;
/* 最大缩放值 */
@property (nonatomic, assign) CGFloat maxZoomFactor;
/* 聚焦框 */
@property (nonatomic, strong) UIView *focusView;

/* 获取屏幕方向 */
@property (nonatomic, assign) UIDeviceOrientation orientation;
/* 陀螺仪管理 */
@property (nonatomic, strong) ZSWMotionManager *motionManager;


@end


@implementation ZSWCameraController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    if(_session && !_session.running) {
        [_session startRunning];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupCamera];
    [self setupPinchGesture];

//    [self startMotionManager];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 初始化相机属性
- (void)setupCamera {
    
    //连接输入与会话
    if([self.session canAddInput:self.input]) {
        [self.session addInput:self.input];
    }

    //连接输出与会话
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 1000000  //iOS10.0
    if([self.session canAddOutput:self.photoOutput]) {
        [self.session addOutput:self.photoOutput];
    }
#else
    if([self.session canAddOutput:self.imageOutput]) {
        [self.session addOutput:self.imageOutput];
    }
#endif
    
    //预览画面
    self.previewLayer.frame = self.view.bounds;
    [self.view.layer insertSublayer:self.previewLayer atIndex:0];
    
    //相机工具
    [self.view addSubview:self.cameraTool];
    
    //对焦框
    [self.view addSubview:self.focusView];
    
    //开始取景
    [self.session startRunning];
    
    NSError *error = nil;
    if([self.device lockForConfiguration:&error]) {
        //自动白平衡：使用AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance自动持续白平衡
        if([self.device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance]) {
            [self.device setWhiteBalanceMode:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance];
        }
        [self.device unlockForConfiguration];
    }else {
        NSLog(@"%@",error);
    }
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 1000000  //iOS10.0以后的方法
#pragma mark - AVCapturePhotoCaptureDelegate 拍摄后的代理方法，得到拍摄的图片
//iOS11用到的代理方法
- (void)captureOutput:(AVCapturePhotoOutput *)output didFinishProcessingPhoto:(AVCapturePhoto *)photo error:(NSError *)error  API_AVAILABLE(ios(11.0)){
    //停止取景
    [self.session stopRunning];

    NSData *imageData = nil;
    if (@available(iOS 11.0, *)) {
        imageData = [photo fileDataRepresentation];
    } else {
        // Fallback on earlier versions
    }
    UIImage *image = [UIImage imageWithData:imageData];
    self.cameraTool.image = image;
    
    //开启陀螺仪监测设备方向，motionManager必须设置为全局强引用属性，否则无法开启陀螺仪监测；
    [self.motionManager startMotionManager:^(NSInteger orientation) {
        self.orientation = orientation;
        NSLog(@"设备方向：%ld",orientation);
    }];
}

//iOS10用到的代理方法
- (void)captureOutput:(AVCapturePhotoOutput *)output didFinishProcessingPhotoSampleBuffer:(nullable CMSampleBufferRef)photoSampleBuffer previewPhotoSampleBuffer:(nullable CMSampleBufferRef)previewPhotoSampleBuffer resolvedSettings:(AVCaptureResolvedPhotoSettings *)resolvedSettings bracketSettings:(nullable AVCaptureBracketedStillImageSettings *)bracketSettings error:(nullable NSError *)error {
    //停止取景
    [self.session stopRunning];
    
    NSData *imageData = [AVCapturePhotoOutput JPEGPhotoDataRepresentationForJPEGSampleBuffer:photoSampleBuffer previewPhotoSampleBuffer:previewPhotoSampleBuffer];
    UIImage *image = [UIImage imageWithData:imageData];
    self.cameraTool.image = image;
    
    //开启陀螺仪监测设备方向，motionManager必须设置为全局强引用属性，否则无法开启陀螺仪监测；
    [self.motionManager startMotionManager:^(NSInteger orientation) {
        self.orientation = orientation;
        NSLog(@"设备方向：%ld",orientation);
    }];
}
#endif

#pragma mark - ZSWCameraToolDelegate
- (void)startCamera {
    NSLog(@"拍摄");
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 1000000  //iOS10.0
    AVCapturePhotoSettings *photoSetting = nil; //必须设置成局部变量，否则每次拍摄使用全局变量会奔溃
    if (@available(iOS 11.0, *)) {
        photoSetting = [AVCapturePhotoSettings photoSettingsWithFormat:@{AVVideoCodecKey:AVVideoCodecTypeJPEG}];
    } else {
        // Fallback on earlier versions
        photoSetting = [AVCapturePhotoSettings photoSettingsWithFormat:@{AVVideoCodecKey:AVVideoCodecJPEG}];
    }
    
    //设置闪光灯开关
    [photoSetting setFlashMode:self.mode];
    
    [self.photoOutput capturePhotoWithSettings:photoSetting delegate:self];
#else
    
    AVCaptureConnection *connect = [self.imageOutput connectionWithMediaType:AVMediaTypeVideo];
    if(!connect) {
        NSLog(@"拍摄失败");
        return;
    }
    
    NSError *error = nil;
    if([self.device lockForConfiguration:&error]) {
        //自动闪光灯
        if([self.device isFlashModeSupported:AVCaptureFlashModeAuto]) {
            [self.device setFlashMode:AVCaptureFlashModeAuto];
        }
        [self.device unlockForConfiguration];
    }else {
        NSLog(@"%@",error);
    }
    
    [self.imageOutput captureStillImageAsynchronouslyFromConnection:connect completionHandler:^(CMSampleBufferRef  _Nullable imageDataSampleBuffer, NSError * _Nullable error) {
        //停止取景
        [self.session stopRunning];
        
        NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        UIImage *image = [UIImage imageWithData:imageData];
        self.cameraTool.image = image;
        
        //开启陀螺仪监测设备方向，motionManager必须设置为全局强引用属性，否则无法开启陀螺仪监测；
        [self.motionManager startMotionManager:^(NSInteger orientation) {
            self.orientation = orientation;
            NSLog(@"设备方向：%ld",orientation);
        }];
        
    }];
    
#endif
    
}

- (void)lightFlash {
    NSLog(@"闪光灯设置");
    if(self.mode == AVCaptureFlashModeOn) {
        self.mode = AVCaptureFlashModeOff;
    }else {
        self.mode = AVCaptureFlashModeOn;
    }
}

- (void)switchCameraPosition {
    NSLog(@"镜头设置");
    
    if(self.position == AVCaptureDevicePositionFront) {
        self.position = AVCaptureDevicePositionBack;
    }else {
        self.position = AVCaptureDevicePositionFront;
    }
    
    [self transformCameraAnimationWithPosition:self.position];

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 1000000  //iOS10.0
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:self.position];
    if(device) {
        self.device = device;
    }
#else
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for(AVCaptureDevice *device in devices) {
        if(device.position == self.position) {
            self.device = device;
        }
    }
#endif
    
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    [self.session beginConfiguration];
    [self.session removeInput:self.input];
    if([self.session canAddInput:input]) {
        [self.session addInput:input];
        self.input = input;
        [self.session commitConfiguration];
    }
    
}

- (void)reshoot {
    NSLog(@"重拍");
    [self.session startRunning];
}

- (void)completionShootWithPhoto:(UIImage *)photo {
    NSLog(@"完成");
    //保存到手机本地相册
    UIImageWriteToSavedPhotosAlbum(photo, nil, nil, nil);
    
    ZSWPhotoController *vc = [ZSWPhotoController new];
    vc.photo = photo;
    vc.orientation = self.orientation;
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - method
//设置动画翻转效果
- (void)transformCameraAnimationWithPosition:(AVCaptureDevicePosition)position {
    
    CATransition *animation = [CATransition animation];
    animation.duration = .5f;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = @"oglFlip";
    
    if(position == AVCaptureDevicePositionFront) {
        animation.subtype = kCATransitionFromLeft;  //翻转方向
    }else {
        animation.subtype = kCATransitionFromRight;  //翻转方向
    }
    
    [self.previewLayer addAnimation:animation forKey:nil];
    
}

#pragma mark - 焦距设置
//增加捏合手势
- (void)setupPinchGesture {
    
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(zoomChangePinchGesture:)];
    [self.view addGestureRecognizer:pinch];
    
    //防止和UITouch方法冲突
    pinch.cancelsTouchesInView = YES;
    
}

//捏合手势方法：处理拍摄画面焦距 这是一种处理缩放系数的方法：修改AVCaptureDevice的缩放系数videoZoomFactor；
//还有第二种：修改AVCaptureConnection的缩放系数videoScaleAndCropFactor，看了下代码，相比第一种代码量更多，所以这里只实现第一种方法，有兴趣的同学可以去操作一下第二种方法.
- (void)zoomChangePinchGesture:(UIPinchGestureRecognizer *)gesture {
    if(gesture.state == UIGestureRecognizerStateBegan || gesture.state == UIGestureRecognizerStateChanged) {
        CGFloat currentZoomFactor = self.device.videoZoomFactor * gesture.scale;
        if(currentZoomFactor < self.maxZoomFactor && currentZoomFactor > self.minZoomFactor) {
            NSError *error = nil;
            if([self.device lockForConfiguration:&error]) {
                self.device.videoZoomFactor = currentZoomFactor;
                [self.device unlockForConfiguration];
            }else {
                NSLog(@"could not lock device : %@",error);
            }
        }
    }
}

//最小缩放值
- (CGFloat)minZoomFactor {
    CGFloat minZoomFactor = 1.0;
    if (@available(iOS 11.0, *)) {
        minZoomFactor = self.device.minAvailableVideoZoomFactor;
    } else {
        // Fallback on earlier versions
    }
    return minZoomFactor;
}

//最大缩放值
- (CGFloat)maxZoomFactor {
    CGFloat maxZoomFactor = self.device.activeFormat.videoMaxZoomFactor;
    if (@available(iOS 11.0, *)) {
        maxZoomFactor = self.device.maxAvailableVideoZoomFactor;
    } else {
        // Fallback on earlier versions
    }
    
    if(maxZoomFactor > 6.0) {
        maxZoomFactor = 6.0;
    }
    return maxZoomFactor;
}

#pragma mark - 对焦和曝光设置
//点击屏幕方法，处理对焦和曝光:必须使用touchesEnded，用touchesBegan会和UIPinchGestureRecognizer手势冲突，且UIPinchGestureRecognizer要设置cancelsTouchesInView为YES
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    
    CGPoint point = [[touches anyObject] locationInView:self.view];
    NSLog(@"point:%@",[NSValue valueWithCGPoint:point]);
    
    NSError *error = nil;
    if([self.device lockForConfiguration:&error]) {
        //对焦模式和对焦点
        if([self.device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
            [self.device setFocusPointOfInterest:point];
            [self.device setFocusMode:AVCaptureFocusModeAutoFocus];
        }
        //曝光模式和曝光点
        if ([self.device isExposureModeSupported:AVCaptureExposureModeAutoExpose ]) {
            [self.device setExposurePointOfInterest:point];
            [self.device setExposureMode:AVCaptureExposureModeAutoExpose];
        }
        [self.device unlockForConfiguration];
        
        //设置对焦框动画
        self.focusView.hidden = NO;
        self.focusView.center = point;
        
        [UIView animateWithDuration:0.3 animations:^{
            self.focusView.transform = CGAffineTransformMakeScale(1.25, 1.25);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.5 animations:^{
                self.focusView.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                self.focusView.hidden = YES;
            }];
        }];
        
    }else {
        NSLog(@"%@",error);
    }
}

#pragma mark - lazy
- (AVCaptureDevice *)device {
    if(!_device) {
        _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    }
    return _device;
}

- (AVCaptureDeviceInput *)input {
    if(!_input) {
        _input = [[AVCaptureDeviceInput alloc] initWithDevice:self.device error:nil];
    }
    return _input;
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 1000000  //iOS10.0
- (AVCapturePhotoOutput *)photoOutput {
    if(!_photoOutput) {
        _photoOutput = [[AVCapturePhotoOutput alloc] init];
    }
    return _photoOutput;
}
#else
- (AVCaptureStillImageOutput *)imageOutput {
    if(!_imageOutput) {
        _imageOutput = [[AVCaptureStillImageOutput alloc] init];
    }
    return _imageOutput;
}
#endif

- (AVCaptureSession *)session {
    if(!_session) {
        _session = [[AVCaptureSession alloc] init];
        _session.sessionPreset = AVCaptureSessionPresetPhoto; //画质
    }
    return _session;
}

- (AVCaptureVideoPreviewLayer *)previewLayer {
    if(!_previewLayer) {
        _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    }
    return _previewLayer;
}

- (ZSWCameraTool *)cameraTool {
    if(!_cameraTool) {
        _cameraTool = [[ZSWCameraTool alloc] initWithFrame:self.view.bounds];
        _cameraTool.delegate = self;
    }
    return _cameraTool;
}

- (UIView *)focusView {
    if(!_focusView) {
        _focusView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
        _focusView.backgroundColor = [UIColor redColor];
        _focusView.hidden = YES;
    }
    return _focusView;
}

- (ZSWMotionManager *)motionManager {
    if(!_motionManager) {
        _motionManager = [[ZSWMotionManager alloc] init];
    }
    return _motionManager;
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
