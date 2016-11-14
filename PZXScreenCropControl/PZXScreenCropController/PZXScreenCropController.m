//
//  PZXScreenCropController.m
//  PZXScreenCropControl
//
//  Created by pzx on 16/11/9.
//  Copyright © 2016年 pzx. All rights reserved.
//

#import "PZXScreenCropController.h"

#define DefualWidthAndHeight 1.0f//设置一个默认宽高比


//在方法内在定义一个私有UIimage的扩展，用于方便调整image。

@interface UIImage (PZXImageCrop_Addition)

-(UIImage *)PZXCropImageWithRect:(CGRect )rect;//切割图片rect方法

-(UIImage *)PZXFixOrientation;//修正图片方向方法，百度的，不用这个方法图片也许被切割后会方向错乱

-(UIImage *)PZXCropRoundImageWithRect:(CGRect )rect;//切割图片rect方法


@end

@implementation UIImage (PZXImageCrop_Addition)
-(UIImage *)PZXCropRoundImageWithRect:(CGRect)rect{
    
    //rect要乘以图片放大scale的倍数，不然放大了只能截取滴滴嘎嘎

    rect.origin.x = 0;
    rect.origin.y = 0;
    rect.size.width *= self.scale;
    rect.size.height *= self.scale;
    //x,y不能小0
    if (rect.origin.x < 0) {
        
        rect.origin.x = 0;
        
    }
    if (rect.origin.y < 0) {
        
        rect.origin.y = 0;
        
    }
    //如果rect的宽高超过了image本身的宽高会接到空白的东西，要给他删去。
    CGFloat cgWidth = CGImageGetWidth(self.CGImage);
    CGFloat cgHeight = CGImageGetHeight(self.CGImage);//取到图片的宽高
    
    if (CGRectGetMaxX(rect)>cgWidth) {
        
        rect.size.width = cgWidth-rect.origin.x;
    }
    if (CGRectGetMaxY(rect)>cgHeight) {
        
        rect.size.height = cgHeight-rect.origin.y;
    }
    
    //开位图上下文
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    //创建圆形路径
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:rect];
    //设置为裁剪区域
    [path addClip];
    //绘制图片
    [self drawAtPoint:CGPointZero];
    UIImage *resultImage= UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultImage;


}
-(UIImage *)PZXCropImageWithRect:(CGRect)rect{
    
    //rect要乘以图片放大scale的倍数，不然放大了只能截取滴滴嘎嘎
    rect.origin.x = rect.origin.x * self.scale;
    rect.origin.y *= self.scale;
    rect.size.width *= self.scale;
    rect.size.height *= self.scale;
    //x,y不能小0
    if (rect.origin.x < 0) {
        
        rect.origin.x = 0;
        
    }
    if (rect.origin.y < 0) {
        
        rect.origin.y = 0;
        
    }
    //如果rect的宽高超过了image本身的宽高会接到空白的东西，要给他删去。
    CGFloat cgWidth = CGImageGetWidth(self.CGImage);
    CGFloat cgHeight = CGImageGetHeight(self.CGImage);//取到图片的宽高
    
    if (CGRectGetMaxX(rect)>cgWidth) {
        
        rect.size.width = cgWidth-rect.origin.x;
    }
    if (CGRectGetMaxY(rect)>cgHeight) {
        
        rect.size.height = cgHeight-rect.origin.y;
    }
    
    //网上的截图3部曲
    CGImageRef imageRef = CGImageCreateWithImageInRect(self.CGImage, rect);//截取图片和rect

    UIImage *resultImage=[UIImage imageWithCGImage:imageRef];//截取后的image

    CGImageRelease(imageRef);

    //修正回原scale和方向
    resultImage = [UIImage imageWithCGImage:resultImage.CGImage scale:self.scale orientation:self.imageOrientation];

    return resultImage;
}

-(UIImage *)PZXFixOrientation{//网路上的修正截图后方向错乱的方法。
    
    if (self.imageOrientation == UIImageOrientationUp) return self;
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    UIImageOrientation io = self.imageOrientation;
    if (io == UIImageOrientationDown || io == UIImageOrientationDownMirrored) {
        transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
        transform = CGAffineTransformRotate(transform, M_PI);
    }else if (io == UIImageOrientationLeft || io == UIImageOrientationLeftMirrored) {
        transform = CGAffineTransformTranslate(transform, self.size.width, 0);
        transform = CGAffineTransformRotate(transform, M_PI_2);
    }else if (io == UIImageOrientationRight || io == UIImageOrientationRightMirrored) {
        transform = CGAffineTransformTranslate(transform, 0, self.size.height);
        transform = CGAffineTransformRotate(transform, -M_PI_2);
        
    }
    
    if (io == UIImageOrientationUpMirrored || io == UIImageOrientationDownMirrored) {
        transform = CGAffineTransformTranslate(transform, self.size.width, 0);
        transform = CGAffineTransformScale(transform, -1, 1);
    }else if (io == UIImageOrientationLeftMirrored || io == UIImageOrientationRightMirrored) {
        transform = CGAffineTransformTranslate(transform, self.size.height, 0);
        transform = CGAffineTransformScale(transform, -1, 1);
        
    }
    
    CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
                                             CGImageGetBitsPerComponent(self.CGImage), 0,
                                             CGImageGetColorSpace(self.CGImage),
                                             CGImageGetBitmapInfo(self.CGImage));
    CGContextConcatCTM(ctx, transform);
    
    if (io == UIImageOrientationLeft || io == UIImageOrientationLeftMirrored || io == UIImageOrientationRight || io == UIImageOrientationRightMirrored) {
        CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage);
    }else{
        CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage);
    }
    
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;

}

@end

//controller的实现

@interface PZXScreenCropController ()<UIScrollViewDelegate>



@property(nonatomic,strong) UIScrollView *scrollView;//底层放大缩小的scrollView
@property(nonatomic,strong) UIView *overlayView; //中心截取区域的View

@property(nonatomic,strong) UIImageView *imageView;//放图片的

@property(nonatomic,strong) UIWindow *actionWindow;//不用push和模态，用window来展示

//顶部和底部的view。
@property(nonatomic,strong) UIView *topBlackView;
@property(nonatomic,strong) UIView *bottomBlackView;

//
@property(nonatomic,strong) UIView *buttonBackgroundView;
@property(nonatomic,strong) UIButton *cancelButton;
@property(nonatomic,strong) UIButton *confirmButton;
@property(nonatomic,strong) CAShapeLayer *overLayer;
@property(nonatomic,strong) CAShapeLayer *line;


@end


@implementation PZXScreenCropController
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.widthAndHeight = DefualWidthAndHeight;
    }
    return self;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    //设置frame,这里需要设置下，这样其会在最下层
    self.scrollView.frame = self.view.bounds;
//    self.overlayView.layer.borderColor = [UIColor colorWithWhite:0.966 alpha:1.000].CGColor;
    
    //绘制上下两块灰色区域
    self.topBlackView = [self quicklyCreatView];
    self.bottomBlackView = [self quicklyCreatView];
    [self.view addSubview:self.topBlackView];
    [self.view addSubview:self.bottomBlackView];
    
    //绘制底部按钮的背景View
    UIView *buttonBackgroundView = [[UIView alloc]init];
    buttonBackgroundView.userInteractionEnabled = NO;
    buttonBackgroundView.backgroundColor = [UIColor darkGrayColor];
    buttonBackgroundView.layer.opacity = 0.8f;
    self.buttonBackgroundView = buttonBackgroundView;
    [self.view addSubview:self.buttonBackgroundView];
    
    //绘制button
    self.cancelButton = [self quicklyCreatViewButtonWithTitle:@"取消" WithAction:@selector(cancelButtonPressed:)];
    self.confirmButton = [self quicklyCreatViewButtonWithTitle:@"确定" WithAction:@selector(confirmButtonPressed:)];
    [self.view addSubview:self.cancelButton];
    [self.view addSubview:self.confirmButton];
    
    
    //双击事件
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    [self.scrollView addGestureRecognizer:doubleTap];



}


#pragma mark - 快捷创建方法，节省代码量
- (UIView*)quicklyCreatView
{
    UIView *view = [[UIView alloc]init];
    view.userInteractionEnabled = NO;
    view.backgroundColor =  [UIColor colorWithWhite:0.25 alpha:0.25];
//    view.layer.opacity = 0.25f;
    return view;
}

- (UIButton *)quicklyCreatViewButtonWithTitle:(NSString*)title WithAction:(SEL)action
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:title forState:UIControlStateNormal];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    button.exclusiveTouch = YES;
    return button;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)appearWithAnimation:(BOOL)animation{
    
    UIWindow *window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    window.opaque = YES;
    window.windowLevel = UIWindowLevelStatusBar+1.0f;
    window.rootViewController = self;
    [window makeKeyAndVisible];
    self.actionWindow = window;
    
    if (animation) {
        self.actionWindow.layer.opacity = .01f;
        [UIView animateWithDuration:0.35f animations:^{
            self.actionWindow.layer.opacity = 1.0f;
        }];
    }


}

- (void)disappear
{
    //退出
    [UIView animateWithDuration:0.35f animations:^{
        self.actionWindow.layer.opacity = 0.01f;
    } completion:^(BOOL finished) {
        [self.actionWindow removeFromSuperview];
        [self.actionWindow resignKeyWindow];
        self.actionWindow = nil;
    }];
}
-(void)cancelButtonPressed:(UIButton *)sender{
    
    [self disappear];
    if (self.delegate &&  [self.delegate respondsToSelector:@selector(cancelCropOpration)]) {
        
        [self.delegate cancelCropOpration];
        
    }

}
-(void)confirmButtonPressed:(UIButton *)sender{

    if (!self.imageView.image) {
        return;
    }
    //不稳定状态不操作，以免出现未知bug
    if (self.scrollView.tracking||self.scrollView.dragging||self.scrollView.decelerating||self.scrollView.zoomBouncing||self.scrollView.zooming){
        return;
    }
    //根据区域来截图
    // convertPoint将像素point由point所在视图转换到目标视图view中，返回在目标视图view中的像素值
    CGPoint startPoint = [self.overlayView convertPoint:CGPointZero toView:self.imageView];//截图起始点
    CGPoint endPoint = [self.overlayView convertPoint:CGPointMake(CGRectGetMaxX(self.overlayView.bounds), CGRectGetMaxY(self.overlayView.bounds)) toView:self.imageView];//截图终点
    
    //这里获取的是实际宽高度和zoomScale为1的frame宽度的比例
    CGFloat wRatio = self.imageView.image.size.width/(self.imageView.frame.size.width/self.scrollView.zoomScale);
    CGFloat hRatio = self.imageView.image.size.height/(self.imageView.frame.size.height/self.scrollView.zoomScale);
    CGRect cropRect = CGRectMake(startPoint.x*wRatio, startPoint.y*hRatio, (endPoint.x-startPoint.x)*wRatio, (endPoint.y-startPoint.y)*hRatio);//根据比例和起始点终点计算出rect，密码线
    
    [self disappear];

    UIImage *cropImage = [self.imageView.image PZXCropImageWithRect:cropRect];//计算出后通过image的方法截图。
    
    if (_isRound == YES) {//如果是圆形则在将图片剪切成圆形
        
        cropImage =  [cropImage PZXCropRoundImageWithRect:CGRectMake(0, 0, cropImage.size.width, cropImage.size.height)];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(photoCropFinishWithCropImage:OriginalImage:)]){
        [self.delegate photoCropFinishWithCropImage:cropImage OriginalImage:self.originalImage];
    }

}

#pragma mark - 双击放大缩小
- (void)handleDoubleTap:(UITapGestureRecognizer *)tap {
    CGPoint touchPoint = [tap locationInView:self.scrollView];
    if (self.scrollView.zoomScale == self.scrollView.minimumZoomScale) { //除去最小的时候双击最大，其他时候都还原成最小
        //这个方法rect宽高随便设置默认就是maxZoom，测试得到的结果
        [self.scrollView zoomToRect:CGRectMake(touchPoint.x, touchPoint.y, 0, 0) animated:YES];
        
    } else {
        [self.scrollView setZoomScale:self.scrollView.minimumZoomScale animated:YES]; //还原
        
    }
}

#pragma mark - getter or setter

-(void)setOriginalImage:(UIImage *)originalImage{
    if ([originalImage isEqual:_originalImage]) {
        return;
    }
    self.imageView.image = [originalImage PZXFixOrientation];
    //重绘
    if (self.isViewLoaded) {
        [self.view setNeedsLayout];
    }
}

-(void)setWidthAndHeight:(CGFloat)widthAndHeight{

    if (widthAndHeight <= 0) {
        widthAndHeight = DefualWidthAndHeight;
    }
    if (widthAndHeight == _widthAndHeight) {
        return;
    }
    _widthAndHeight = widthAndHeight;
    //重绘
    if (self.isViewLoaded) {
        [self.view setNeedsLayout];
    }
}

-(UIView *)overlayView
{
    if (!_overlayView) {
        _overlayView = [[UIView alloc]init];
//        _overlayView.layer.borderColor = [UIColor whiteColor].CGColor;
//        _overlayView.layer.borderWidth = 1.0f;
        _overlayView.userInteractionEnabled = NO;
        [self.view addSubview:_overlayView];
    }
    return _overlayView;
}
-(UIScrollView *)scrollView
{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc]init];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.exclusiveTouch = YES; //防止被触摸的时候还去触摸其他按钮，当然其防不住减速时候的弹跳黑框等特殊的，在onConfirm里面处理了
        _scrollView.delegate = self;
        [self.view addSubview:_scrollView];
    }
    return _scrollView;
}
-(UIImageView *)imageView{
    
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        //                _imageView.backgroundColor = [UIColor yellowColor];
        [self.scrollView addSubview:_imageView];
    }
    return _imageView;

}

- (BOOL)isBaseOnWidthOfOverlayView
{
    //这里最好不要用＝＝判断，因为是CGFloat类型
    if (self.overlayView.frame.size.width < self.view.bounds.size.width) {
        return NO;
    }
    return YES;
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    //构建界面写在这个生命周期的原因，每次旋转屏幕也会走一次。达到适配转屏。
    [self initializeUserInterface];//构建界面

    
}
-(void)initializeUserInterface{
    [self.view sendSubviewToBack:self.scrollView];
    
    //底部按钮背景View
#define kButtonViewHeight 50
    self.buttonBackgroundView.frame = CGRectMake(0, CGRectGetHeight(self.view.bounds)-kButtonViewHeight, CGRectGetWidth(self.view.bounds),kButtonViewHeight);
    //底部俩按钮
#define kButtonWidth 50
    self.cancelButton.frame = CGRectMake(15, CGRectGetMinY(self.buttonBackgroundView.frame), kButtonWidth, kButtonViewHeight);
    self.confirmButton.frame = CGRectMake(CGRectGetWidth(self.buttonBackgroundView.frame)-kButtonWidth-15, CGRectGetMinY(self.buttonBackgroundView.frame), kButtonWidth, kButtonViewHeight);
    
    //重置下
    self.scrollView.minimumZoomScale = 1.0f;
    self.scrollView.maximumZoomScale = self.scrollView.minimumZoomScale;
    self.scrollView.zoomScale = self.scrollView.minimumZoomScale;
    self.scrollView.frame = self.view.bounds;
    
    //overlayView
    //根据宽度找高度
    CGFloat width = self.view.bounds.size.width;
    CGFloat height = width/self.widthAndHeight;
    BOOL isBaseOnWidth = YES;
    if (height>self.view.bounds.size.height) {
        //超过屏幕了那就只能是，高度定死，宽度修正
        height = self.view.bounds.size.height;
        width = height*self.widthAndHeight;
        isBaseOnWidth = NO;
    }
    self.overlayView.frame = CGRectMake(0, 0, width, height);
    self.overlayView.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2);
    
    if (_isRound == YES) {//如果是圆形则显示圆形的截图框（用layer的path画出）
        
        [self RoundCrop];

        
    }else{
        _overlayView.layer.borderColor = [UIColor whiteColor].CGColor;
        _overlayView.layer.borderWidth = 1.0f;
    
    }

    //上下黑色覆盖View
    if (isBaseOnWidth) {
        //上和下
        self.topBlackView.frame = CGRectMake(0, 0, width, CGRectGetMinY(self.overlayView.frame));
        self.bottomBlackView.frame = CGRectMake(0, CGRectGetMaxY(self.overlayView.frame), width, CGRectGetHeight(self.view.bounds)-CGRectGetMaxY(self.overlayView.frame));
    }else{
        //左和右
        self.topBlackView.frame = CGRectMake(0, 0, CGRectGetMinX(self.overlayView.frame), height);
        self.bottomBlackView.frame = CGRectMake(CGRectGetMaxX(self.overlayView.frame),0, CGRectGetWidth(self.view.bounds)-CGRectGetMaxX(self.overlayView.frame), height);
    }

    
    //imageView的frame和scrollView的内容
    [self adjustImageViewFrameAndScrollViewContent];

}

#pragma mark - 调整scrollView和imageView
- (void)adjustImageViewFrameAndScrollViewContent
{
    CGRect frame = self.scrollView.frame;
    if (self.imageView.image) {
        CGSize imageSize = self.imageView.image.size;
        CGRect imageFrame = CGRectMake(0, 0, imageSize.width, imageSize.height);
        
        if (frame.size.width<=frame.size.height) {
            //说白了就是竖屏时候
            CGFloat ratio = frame.size.width/imageFrame.size.width;
            imageFrame.size.height = imageFrame.size.height*ratio;
            imageFrame.size.width = frame.size.width;
        }else{
            CGFloat ratio = frame.size.height/imageFrame.size.height;
            imageFrame.size.width = imageFrame.size.width*ratio;
            imageFrame.size.height = frame.size.height;
        }
        
        self.scrollView.contentSize = frame.size;
        
        BOOL isBaseOnWidth = [self isBaseOnWidthOfOverlayView];
        if (isBaseOnWidth) {
            //核心方法，这个就是最核心的，之前我们scollview不能滑到边界因为没设置他的inset额外的滑动地方，代俊希望你看到这个
            self.scrollView.contentInset = UIEdgeInsetsMake(CGRectGetMinY(self.overlayView.frame), 0, CGRectGetHeight(self.view.bounds)-CGRectGetMaxY(self.overlayView.frame), 0);
        }else{
            self.scrollView.contentInset = UIEdgeInsetsMake(0, CGRectGetMinX(self.overlayView.frame), 0, CGRectGetWidth(self.view.bounds)-CGRectGetMaxX(self.overlayView.frame));
        }
        
        self.imageView.frame = imageFrame;
        
        //初始化,让其不会有黑框出现
        CGFloat minScale = self.overlayView.frame.size.height/imageFrame.size.height;
        CGFloat minScale2 = self.overlayView.frame.size.width/imageFrame.size.width;
        minScale = minScale>minScale2?minScale:minScale2;//最小倍数，用三目运算符节省代码量。
        
        self.scrollView.minimumZoomScale = minScale;
        self.scrollView.maximumZoomScale = self.scrollView.minimumZoomScale*3<2.0f?2.0f:self.scrollView.minimumZoomScale*3;//最大倍数不超过2。多用三目运算符。
        self.scrollView.zoomScale = self.scrollView.minimumZoomScale;
        
        //调整下让其居中
        if (isBaseOnWidth) {
            CGFloat offsetY = (self.scrollView.bounds.size.height > self.scrollView.contentSize.height)?
            (self.scrollView.bounds.size.height - self.scrollView.contentSize.height) * 0.5 : 0.0;
            self.scrollView.contentOffset = CGPointMake(0, -offsetY);
        }else{
            CGFloat offsetX = (self.scrollView.bounds.size.width > self.scrollView.contentSize.width)?
            (self.scrollView.bounds.size.width - self.scrollView.contentSize.width) * 0.5 : 0.0;
            self.scrollView.contentOffset = CGPointMake(-offsetX,0);
        }
    }else{//没得图片的情况
        frame.origin = CGPointZero;
        self.imageView.frame = frame;
        //重置内容大小
        self.scrollView.contentSize = self.imageView.frame.size;
        self.scrollView.minimumZoomScale = 1.0f;
        self.scrollView.maximumZoomScale = self.scrollView.minimumZoomScale; //取消缩放功能
        self.scrollView.zoomScale = self.scrollView.minimumZoomScale;
    }
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}
#pragma roundCropFunc
-(void)RoundCrop{
    
    //一开始要删除一次，不然每次旋转屏幕会多添加一个layer。而且一开始也会颜色深一点
    [self.overLayer removeFromSuperlayer];
    
    self.overlayView.backgroundColor = [UIColor clearColor];
    //layer
    //创建正方形path
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, self.overlayView.frame.size.width, self.overlayView.frame.size.height) cornerRadius:0];
    //里面圆的path
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, self.overlayView.frame.size.width, self.overlayView.frame.size.height)];
    //把圆形paht加入path
    [path appendPath:circlePath];
    //path用rule
    [path setUsesEvenOddFillRule:YES];
    
    //镂空layer
    _overLayer = [CAShapeLayer layer];
    _overLayer.fillColor = [UIColor colorWithWhite:0.25 alpha:0.25].CGColor;
    _overLayer.fillRule = kCAFillRuleEvenOdd;
    _overLayer.frame = CGRectMake(0, 0,  self.overlayView.frame.size.width,  self.overlayView.frame.size.height);
    _overLayer.path = path.CGPath;
    
    
    
    //线的layer（直接用镂空的划线会有外面矩形和里面圆形的2个，所以单独用一个layer画圆形的）
    _line = [CAShapeLayer layer];
    _line.frame = _overLayer.frame;
    _line.fillColor = [UIColor clearColor].CGColor;
    _line.strokeColor = [UIColor whiteColor].CGColor;
    _line.lineWidth = 2.0;
    _line.path = circlePath.CGPath;
    [_overLayer addSublayer:_line];
    
    [self.overlayView.layer addSublayer:_overLayer];

}

@end
