//
//  QRViewController.h
//  RNArenaMedia
//
//  Created by 丁乐 on 2018/12/28.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QRViewController : UIViewController

-(instancetype)initWithCallback:(void(^)(NSString *))successCallback faildCallback:(void(^)(NSString *))faildCallback;

@end

NS_ASSUME_NONNULL_END
