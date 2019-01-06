
#import "RNArenaMedia.h"
#import "QRViewController.h"

@implementation RNArenaMedia

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}
RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(scanQRCode:(NSDictionary *)data success:(RCTPromiseResolveBlock)success faild:(RCTPromiseRejectBlock)faild){
    
    QRViewController *qrVC = [[QRViewController alloc]initWithCallback:^(NSString * _Nonnull result) {
        success(result);
    } faildCallback:^(NSString * _Nonnull error) {
        faild(error,error,nil);
    }];
    
    UINavigationController * naVC = [[UINavigationController alloc]initWithRootViewController:qrVC];
    
    [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:naVC animated:YES completion:nil];
}


@end
  
