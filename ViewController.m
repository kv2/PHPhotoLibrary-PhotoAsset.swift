//
//  ViewController.m
//  
//
//  
//  
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "Yourtargetname-Swift.h"//important!

@interface ViewController () 


@end


@implementation ViewController


- (void)viewDidLoad {

   

}


#pragma mark - save video 


- (IBAction)buttonSaveVideoDidTouchup:(UIButton *)sender{
    
    
    NSURL *videoURL = [[NSURL alloc] initFileURLWithPath:PATH_TO_VIDEO];
    
    
    [PHPhotoLibrary saveVideo:videoURL albumName:@"my album" completion:^(PHAsset * asset) {
        DLog(@"success");
        DLog(@"asset%lu",(unsigned long)asset.pixelWidth);
        
        
    }];
    
    
}



@end
