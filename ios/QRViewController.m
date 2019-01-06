//
//  QRViewController.m
//  RNArenaMedia
//
//  Created by 丁乐 on 2018/12/28.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import "QRViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>


@interface QRViewController () <AVCaptureMetadataOutputObjectsDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property(nonatomic,strong) AVCaptureSession *session;

@property(nonatomic,copy) void(^successCallback)(NSString *);

@property(nonatomic,copy) void(^faildCallback)(NSString *);

@property(nonatomic,weak) UIImageView * sweepImgV;

@property(nonatomic,assign) CGFloat scanViewWidth;

@property(nonatomic,assign)BOOL cameraWorking;

@property(nonatomic, strong) AVCaptureDevice *device;

@property(nonatomic, strong)  AVCaptureDeviceInput *input;

@property(nonatomic, strong)  AVCaptureMetadataOutput *output;
@end

@implementation QRViewController

// 初始化
-(instancetype)initWithCallback:(void(^)(NSString *))successCallback faildCallback:(void(^)(NSString *))faildCallback {
    self = [super init];
    if(self != nil){
        self.successCallback = successCallback;
        self.faildCallback = faildCallback;
        self.view.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    //    初始化界面
    [self setUIAndScan];
    
    
    //    如果是模拟器，弹出页面
    #if TARGET_IPHONE_SIMULATOR
    [self dismissViewControllerAnimated:YES completion:^{
        self.faildCallback(@"请使用真机！");
    }]
    
        return;
    #endif
    //    监听 程序从后台又切入到前台
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationEnter) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    //    检查权限
    [self checkAuth];
}

/**
 检查权限
 */
-(void)checkAuth{
    //    相机权限
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    if(status == AVAuthorizationStatusNotDetermined){
        //    未请求权限 去请求相机权限
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            [self checkAuth];
        }];
        
    }else if(status != AVAuthorizationStatusAuthorized){
        //        拒绝授权 要求跳转
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"进入设置中打开相机权限" preferredStyle:(UIAlertControllerStyleAlert)];
        
        UIAlertAction *sure = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
            //            确定去设置页面
            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if([[UIApplication sharedApplication] canOpenURL:url]) {
                
                [[UIApplication sharedApplication] openURL:url];
            }
        }];
        UIAlertAction *cancle = [UIAlertAction actionWithTitle:@"取消" style:(UIAlertActionStyleCancel) handler:^(UIAlertAction * _Nonnull action) {
            //            取消就弹出页面
            
            [self dismissViewControllerAnimated:true completion:^{
                self.faildCallback(@"用户拒绝摄像头权限");
            }];
        }];
        
        [alertVC addAction:sure];
        [alertVC addAction:cancle];
        [self presentViewController:alertVC animated:YES completion:nil];
    }else{
//      有权限 调用摄像机工作
        [self scaning];
    }
}


/**
 设置UI和开始扫描二维码
 */
-(void)setUIAndScan{
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    CGFloat kMargin = 60;
    CGFloat scanWidth = screenWidth - kMargin * 2;
    CGFloat scanY = (screenHeight - scanWidth ) / 2;
    CGRect scanFrame = CGRectMake(kMargin, scanY, scanWidth, scanWidth);
    self.scanViewWidth = scanWidth;
    
//    遮罩
    UIView *maskView = [[UIView alloc]initWithFrame:(CGRectMake(0, 0, screenWidth, screenHeight))];
    maskView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
    [self.view addSubview:maskView];
    
//  中间镂空
    UIBezierPath *allPath = [UIBezierPath bezierPathWithRect:[UIScreen mainScreen].bounds];
    UIBezierPath *path = [[UIBezierPath bezierPathWithRoundedRect:scanFrame cornerRadius:0] bezierPathByReversingPath];
    [allPath appendPath:path];
    CAShapeLayer *l = [CAShapeLayer new];
    l.path = allPath.CGPath;
    [maskView.layer setMask:l];
    
//    放置网格
    UIView * scanView = [[UIView alloc]initWithFrame:scanFrame];
    [self.view addSubview:scanView];
    scanView.clipsToBounds = YES;
    
    UIImage *sweepImg = [UIImage imageNamed:@"sweep_bg_line"];
    UIImageView *sweepImgV = [[UIImageView alloc]initWithFrame:CGRectMake(0, -scanWidth, scanWidth, scanWidth)];
    sweepImgV.image = sweepImg;
    sweepImgV.contentMode = UIViewContentModeScaleAspectFit;
    [scanView addSubview:sweepImgV];
    self.sweepImgV = sweepImgV;
    [self scanSweepAnimation];
    
//    设置手电筒
    UIButton *flashlightBtn = [[UIButton alloc]initWithFrame:(CGRectMake(0, screenHeight - 60 - 40, screenWidth / 2, 60))];
    [flashlightBtn setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
    flashlightBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    UIImage *close = [UIImage imageNamed:@"media_close"];
    UIImage *open = [UIImage imageNamed:@"media_open"];
    [self setImageAndTitle:flashlightBtn image:close title:@"手电筒"];
    [flashlightBtn setImage:open forState:(UIControlStateSelected)];
    [flashlightBtn addTarget:self action:@selector(flashlightBtnClick:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:flashlightBtn];
    
    //    设置相册按钮
    UIButton *albumBtn = [[UIButton alloc]initWithFrame:(CGRectMake(screenWidth / 2.0, screenHeight - 60 - 40, screenWidth / 2, 60))];
    [albumBtn setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
    albumBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    UIImage *photo = [UIImage imageNamed:@"media_photo"];
    [self setImageAndTitle:albumBtn image:photo title:@"相册"];
    [albumBtn addTarget:self action:@selector(albumBtnClick:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:albumBtn];
    
//    导航栏设置
    self.navigationItem.title = @"二维码/条码";
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:(UIBarMetricsDefault)];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]}; // title颜色

    UIImage *backImage = [[UIImage imageNamed:@"media_back"] imageWithRenderingMode:(UIImageRenderingModeAlwaysOriginal)];
    UIBarButtonItem *leftBar = [[UIBarButtonItem alloc] initWithImage:backImage style:(UIBarButtonItemStyleDone) target:self action:@selector(backBtnClick)];
    self.navigationItem.leftBarButtonItem = leftBar;
}

//  开始扫描
-(void)scaning{
    
    //1、创建会话
    AVCaptureSession *session = [[AVCaptureSession alloc]init];
    self.session = session;
    if ([session canSetSessionPreset:AVCaptureSessionPresetHigh]) {
        
        [session setSessionPreset:AVCaptureSessionPresetHigh];
        
    }
    
    //2、添加输入和输出设备
    if([session canAddInput:self.input]){
        
        [session addInput:self.input];
        
    }
    if([session canAddOutput:self.output]){
        
        [session addOutput:self.output];
    }
    //3、设置这次扫描的数据类型
    self.output.metadataObjectTypes = @[
                                   AVMetadataObjectTypeQRCode,
                                   AVMetadataObjectTypeCode39Code,
                                   AVMetadataObjectTypeCode128Code,
                                   AVMetadataObjectTypeCode39Mod43Code,
                                   AVMetadataObjectTypeEAN13Code,
                                   AVMetadataObjectTypeEAN8Code,
                                   AVMetadataObjectTypeCode93Code
                                   ];
    //4、创建预览层
    AVCaptureVideoPreviewLayer *layer = [AVCaptureVideoPreviewLayer layerWithSession:session];
    layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    layer.frame = self.view.bounds;
    [self.view.layer insertSublayer:layer atIndex:0];
    
//    //5、开始扫描
    [session startRunning];
}


// 网格动画
-(void)scanSweepAnimation{
    self.sweepImgV.frame = CGRectMake(0, -self.scanViewWidth, self.scanViewWidth, self.scanViewWidth);
    self.sweepImgV.alpha = 1;
    [UIView animateWithDuration:1.5 delay:0 options:(UIViewAnimationOptionRepeat | UIViewAnimationOptionCurveEaseIn) animations:^{
        self.sweepImgV.frame = CGRectMake(0, 0, self.scanViewWidth, self.scanViewWidth);
        self.sweepImgV.alpha = 0.3;
    } completion:nil];
}


-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// apph由后台转前台
-(void)applicationEnter{
    [self checkAuth];
    [self scanSweepAnimation];
}

-(void)backBtnClick{
    [self dismissViewControllerAnimated:true completion:^{
        self.faildCallback(@"用户取消扫描");
    }];
}



//  照相机按钮点击事件
-(void)flashlightBtnClick:(UIButton *)btn{
    if (self.device.hasTorch && self.device.isTorchAvailable){
        [btn setSelected:!btn.selected];
        [self.device lockForConfiguration:nil];
        self.device.torchMode = btn.selected ? AVCaptureTorchModeOn : AVCaptureTorchModeOff;
        [self.device unlockForConfiguration];
    }
}

//  相册按钮点击事件
-(void)albumBtnClick:(UIButton *)btn{
    if ([UIImagePickerController isSourceTypeAvailable:(UIImagePickerControllerSourceTypePhotoLibrary)]){
        
        UIImagePickerController *pickVC = [[UIImagePickerController alloc]init];
        pickVC.delegate = self;
        pickVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        pickVC.allowsEditing = NO;
        [self presentViewController:pickVC animated:YES completion:nil];
        
    }
}
//  给图文按钮设置文字和图片
-(void)setImageAndTitle:(UIButton *)btn image:(UIImage *)img title:(NSString *)title {
    [btn setTitle:title forState:(UIControlStateNormal)];
    [btn setImage:img forState:(UIControlStateNormal)];
    
    CGFloat imageWith = btn.imageView.bounds.size.width;
    CGFloat imageHeight = btn.imageView.bounds.size.height;
    
    CGFloat labelWidth = btn.titleLabel.intrinsicContentSize.width;
    CGFloat labelHeight = btn.titleLabel.intrinsicContentSize.height;
    
    btn.titleEdgeInsets = UIEdgeInsetsMake(0, -imageWith, -imageHeight-4, 0);
    btn.imageEdgeInsets = UIEdgeInsetsMake(-labelHeight - 4, 0, 0, -labelWidth);
}


#pragma mark - 二维码扫描结果代理函数
- (void)captureOutput:(AVCaptureOutput *)output didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    
    if(metadataObjects != nil && metadataObjects.count ){
        
        
        AVMetadataMachineReadableCodeObject *metadataObject = [metadataObjects lastObject];
        
        NSString *result = metadataObject.stringValue;
        
        [self dismissViewControllerAnimated:true completion:^{
            [self.session stopRunning];
            self.successCallback(result);
        }];
    }
}

#pragma mark - 图片选择代理方法
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    NSData * imageData = UIImagePNGRepresentation(image);
    CIImage *ciImage = [[CIImage alloc]initWithData:imageData];
    
    CIDetector * detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy:CIDetectorAccuracyLow}];
    NSArray *features = [detector featuresInImage:ciImage];
    
    CIQRCodeFeature *result = [features firstObject];
    NSString *messageString = [result messageString];
    
    if (messageString != nil) {
        
        [self dismissViewControllerAnimated:YES completion:^{
            
            self.successCallback(messageString);
        }];
        
    }else{
                
        [self tip:@"二维码图片解析失败，请换一张试试"];
    }
}


-(void)tip:(NSString *)msg{
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    UILabel *label = [[UILabel alloc]init];
    label.text = msg;
    label.font = [UIFont systemFontOfSize:16];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.layer.cornerRadius = 4;
    label.layer.masksToBounds = YES;
    [label sizeToFit];
    label.backgroundColor = [UIColor darkGrayColor];
    
    CGFloat labelWidth = label.bounds.size.width + 20;
    CGFloat labelHeight = label.bounds.size.height + 20;
    
    label.frame = CGRectMake((screenWidth - labelWidth ) / 2, screenHeight / 2, labelWidth, labelHeight);
    [self.view addSubview:label];
    
    [UIView animateWithDuration:0.8 delay:3 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        label.alpha = 0;
    } completion:^(BOOL finished) {
        [label removeFromSuperview];
    }];
    
}


-(AVCaptureDevice *)device{
    if (_device == nil) {
        
        _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        
    }
    return _device;
    
}

-(AVCaptureDeviceInput *)input{
    
    if (_input == nil) {
        _input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    }
    
    return  _input;
    
}

-(AVCaptureMetadataOutput *)output{
    
    if (_output == nil) {
        
        _output = [[AVCaptureMetadataOutput alloc]init];
        
        [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        [_output setRectOfInterest:CGRectMake(0.1, 0, 0.9, 1)];
    }
    
    return  _output;
}

@end
