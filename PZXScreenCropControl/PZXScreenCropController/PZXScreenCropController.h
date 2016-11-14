//
//  PZXScreenCropController.h
//  PZXScreenCropControl
//
//  Created by pzx on 16/11/9.
//  Copyright © 2016年 pzx. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PZXScreenCropControllerDelegate <NSObject>

-(void)photoCropFinishWithCropImage:(UIImage *)cropImage OriginalImage:(UIImage *)originalImage;//完成截图的代理
@optional
-(void)cancelCropOpration;//取消操作的代理,可以不要。


@end

@interface PZXScreenCropController : UIViewController

//原始图片
@property (strong,nonatomic)UIImage *originalImage;

@property (retain,nonatomic)id<PZXScreenCropControllerDelegate> delegate;

@property(nonatomic,assign) CGFloat widthAndHeight; //截取比例，宽高比

@property(nonatomic,assign)BOOL isRound; //是否是圆形截图 默认是NO

- (void)appearWithAnimation:(BOOL)animation;//出现方法



@end
