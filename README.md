# PZXScreenCropControl
一款自由截图的控件，系统截图只支持正方形，经过修改可以支持各种矩形，暂不支持圆形和其他形状，准备更新其他形状的功能。

使用方法：
        PZXScreenCropController *vc = [[PZXScreenCropController alloc]init];
        vc.originalImage = image;
        vc.widthAndHeight = 1000.f/600.f;
        vc.delegate = self;
        [vc appearWithAnimation:YES];
![image](https://github.com/PZXforXcode/PZXScreenCropControl/blob/master/PZXScreenCropControl/show.gif)
