//
//  ViewController.m
//  PZXScreenCropControl
//
//  Created by pzx on 16/11/8.
//  Copyright © 2016年 pzx. All rights reserved.
//

#import "ViewController.h"
#import "PZXScreenCropController.h"
@interface ViewController ()<PZXScreenCropControllerDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>
@property (strong, nonatomic) IBOutlet UIImageView *imageView;

@property (strong, nonatomic)UIImagePickerController *picker;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _imageView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;


}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)buttonPressed:(UIButton *)sender {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"选择图片方式" message:@"made by pzx" preferredStyle:UIAlertControllerStyleActionSheet];

    _picker = [[UIImagePickerController alloc]init];
    _picker.navigationBar.tintColor = [UIColor cyanColor];
    _picker.delegate = self;
//    _picker.allowsEditing = YES;
    UIAlertAction *photos = [UIAlertAction actionWithTitle:@"图库" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        _picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:_picker animated:YES completion:nil];
        
    }];
    
    UIAlertAction *takePhotos = [UIAlertAction actionWithTitle:@"照相" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
            _picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        }else{
            
        }
        
        [self presentViewController:_picker animated:YES completion:nil];
        
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
 
    
    [alert addAction:photos];
    [alert addAction:takePhotos];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}


-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
    NSString *mediaType=[info objectForKey:UIImagePickerControllerMediaType];
    if([mediaType isEqualToString:@"public.image"]){
        UIImage *image=[info objectForKey: UIImagePickerControllerOriginalImage];
        
        if(picker.sourceType == UIImagePickerControllerSourceTypeCamera){
            
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
        }
        
        PZXScreenCropController *vc = [[PZXScreenCropController alloc]init];
        vc.originalImage = image;
        vc.isRound = YES;//是否截图圆形
        vc.widthAndHeight = 800/600.f;//宽高比
        vc.delegate = self;
        [vc appearWithAnimation:YES];


    }


//    [picker.navigationController pushViewController:vc animated:YES];
//    [picker presentViewController:vc animated:YES completion:nil];

}

#pragma mark - PZXScreenCropControllerDelegate
-(void)photoCropFinishWithCropImage:(UIImage *)cropImage OriginalImage:(UIImage *)originalImage{

    _imageView.image = cropImage;
    [_picker dismissViewControllerAnimated:YES completion:nil];
    
}
-(void)cancelCropOpration{
    
    if (_picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        [_picker dismissViewControllerAnimated:YES completion:nil];

    }

}
@end
