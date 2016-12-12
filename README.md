# PZXScreenCropControl
<div><div><font color="#3366ff">一款自由截图的控件，系统截图只支持正方形，经过修改可以支持各种矩形，和圆形，各种比例椭圆的截图。</font></div><div><font color="#ff0000">使用方法：</font></div><div><br></div><div>&nbsp; &nbsp;
PZXScreenCropController *vc = [[PZXScreenCropController alloc]init];</div><div>&nbsp; &nbsp; &nbsp; &nbsp; vc.originalImage = image;</div><div>&nbsp; &nbsp; &nbsp; &nbsp; vc.isRound = YES;<font color="#00ff00">//是否截图圆形</font></div><div>&nbsp; &nbsp; &nbsp; &nbsp; vc.widthAndHeight = 800/600.f;<font color="#00ff00">//宽高比</font></div><div>&nbsp; &nbsp; &nbsp; &nbsp; vc.delegate = self;</div><div>&nbsp; &nbsp; &nbsp; &nbsp; [vc appearWithAnimation:YES];
</div><div><br></div><div><br></div><div><font color="#808080">感谢：封装时一位胖子的帮助</font></div><div><br></div></div>

![image](https://github.com/PZXforXcode/PZXScreenCropControl/blob/master/PZXScreenCropControl/show.gif) 
