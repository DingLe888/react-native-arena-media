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


@interface QRViewController ()

@property(nonatomic,strong) AVCaptureSession *session;

@property(nonatomic,copy) void(^successCallback)(NSString *);
@property(nonatomic,copy) void(^faildCallback)(NSString *);


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

-(void)viewDidAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //    如果是模拟器，弹出页面
    #if TARGET_IPHONE_SIMULATOR
        self.faildCallback(@"请使用真机！");
        [self dismissViewControllerAnimated:YES completion:nil];
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
            [self dismissViewControllerAnimated:true completion:nil];
        }];
        
        [alertVC addAction:sure];
        [alertVC addAction:cancle];
        [self presentViewController:alertVC animated:YES completion:nil];
    }else{
//      有权限初始化界面等
        [self setUIAndScan];
    }
}


/**
 设置UI和开始扫描二维码
 */
-(void)setUIAndScan{
    [self setupMaskView];
}

// 整体遮罩设置
-(void)setupMaskView{
    
    
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"media" ofType:@"bundle"];
    NSBundle * imgBundle = [NSBundle bundleWithPath:bundlePath];

    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    CGFloat kMargin = 35;
    CGFloat kBorderW = 140;
    CGFloat scanViewW = screenWidth - kMargin * 2;
    CGFloat scanViewH = screenWidth - kMargin * 2;
    
    UIView *maskView = [[UIView alloc]initWithFrame:(CGRectMake(-(screenHeight - screenWidth) / 2, 0, screenHeight, screenHeight))];
    maskView.layer.borderWidth = (screenHeight - scanViewW) / 2;
    maskView.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6].CGColor;
    [self.view addSubview:maskView];
    
    self.navigationItem.title = @"二维码/条码";
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:(UIBarMetricsDefault)];
    
    NSString *imgPath= [imgBundle pathForResource:@"back@2x" ofType:@"png"];
    UIImage *backImage = [UIImage imageWithContentsOfFile:imgPath];
    UIBarButtonItem *leftBar = [[UIBarButtonItem alloc] initWithImage:backImage style:(UIBarButtonItemStyleDone) target:self action:@selector(backBtnClick)];
    
    self.navigationItem.leftBarButtonItem = leftBar;
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// apph由后台转前台
-(void)applicationEnter{
    [self checkAuth];
}

-(void)backBtnClick{
    [self dismissViewControllerAnimated:true completion:nil];
}

@end
