# PZXScreenCropControl
<div><div><font color="#3366ff">一款自由截图的控件，系统截图只支持正方形，经过修改可以支持各种矩形，和圆形，各种比例椭圆的截图。</font></div>

### 使用方法：
```
PZXScreenCropController *vc = [[PZXScreenCropController alloc]init];
vc.originalImage = image;
vc.isRound = YES;//是否截图圆形
vc.widthAndHeight = 800/600.f;//宽高比
vc.delegate = self;
[vc appearWithAnimation:YES];
```

</div><div><br></div><div><br></div><div><font color="#808080">感谢：封装时一位胖子的帮助</font></div><div><br></div></div>
## 效果图:
![image](https://github.com/PZXforXcode/PZXScreenCropControl/blob/master/PZXScreenCropControl/show.gif) 
