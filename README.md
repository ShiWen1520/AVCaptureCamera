# AVCaptureCamera
自定义相机实现

使用**AVFoundation**框架里的**AVCaptureSession、AVCaptureDevice、AVCaptureDeviceInput、AVCapturePhotoOutput/AVCaptureStillImageOutput、AVCaptureVideoPreviewLayer、AVCaptureFlashMode、AVCaptureDevicePosition、AVCapturePhotoSettings**这些类实现了一个基本的相机拍摄功能。下面简单的介绍一下这些类的作用：
- **AVCaptureDevice**：捕获设备，通常是前置摄像头、后置摄像头、麦克风；
- **AVCaptureDeviceInput**：输入设备，使用AVCaptureDevice来初始化；
- **AVCapturePhotoOutput**：输出图片，iOS10及以上的属性；
- **AVCaptureStillImageOutpu**t：输出图片，iOS10以下的属性，在iOS10已经废弃；
- **AVCaptureSession**：可以把输入输出结合在一起，并开始启动捕获设备(摄像头)；
- **AVCaptureVideoPreviewLayer**：图像预览层，实时显示捕获的图像；
- **AVCaptureFlashMode**：设置闪光灯；
- **AVCaptureDevicePosition**：设置前后置摄像头 。
>基于这些类，根据网上的一些资料，自己码了一个demo，有兴趣的童鞋可以到我的[github](https://github.com/ShiWen1520/AVCaptureCamera)上clone下来看看；demo兼容了iOS10及以上和iOS10以下的实现方法，相关的实现在demo已有注释。喜欢的童鞋可以给个star或者在👇点个👍，也是对我最大的鼓励，希望我们一起共同成长！

####补充
突然想起来有些在demo里无法直观体现的注意事项没说，现在补充一下，使用到相机功能，肯定要得到iPhone手机的权限许可啦，在info.plist文件里添加**Privacy - Camera Usage Description**，相关描述随意填写，我填了简单的“**请求使用相机**”，这样就可以使用相机拍摄了。demo里又实现了将拍摄的图片保存到手机本地相册的功能，所以，还要添加**Privacy - Photo Library Usage Description**，注意，这个属性是iOS10及以上的，如果你开发的版本支持iOS10以下的，还要添加**Privacy - Photo Library Additions Usage Description**，嘿嘿，我不说，你是不是不知道😋，反正我是才知道😆！

还有一个要说一下，拍照得到的图片，实现了横屏拍摄，竖屏自适应显示的功能，和微信里的拍照差不多的实现（当然没有微信里那么屌啦😆，只是简单的实现了一下）！
由于我没有开启设备的横屏功能，所以使用系统的UIInterfaceOrientation和[[UIDevice currentDevice] orientation]或者屏幕方向改变的通知，获取屏幕方向都是固定的，值并不会改变，郁闷😣；最后我的实现方案是：使用陀螺仪的设备感应来获取设备的方向，实现了该功能，很开森😊！（学到老、活到老🤔）

最后一句，demo写的比较简略，自定义相机的页面简单的放了几个按钮，相关优化后期补充，不喜欢的童鞋不要喷我，我害怕😨...
好了，补充完毕！！！记得记得点赞啊，谢谢！
