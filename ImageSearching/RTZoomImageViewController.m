//
//  RTZoomImageViewController.m
//  ImageSearching
//
//  Created by lvwang on 15/2/6.
//  Copyright (c) 2015年 MA. All rights reserved.
//

#import "RTZoomImageViewController.h"
#import "MRZoomScrollView.h"
#import "SDWebImageManager.h"
#import "UIImageView+WebCache.h"
@interface RTZoomImageViewController (){
    MRZoomScrollView *_zoomScrollView;
}

@end

@implementation RTZoomImageViewController

-(void)loadView{
    CGRect rect = [UIScreen mainScreen].bounds;
//    self.view = [[UIView alloc] initWithFrame:CGRectMake(0.0, 64.0, rect.size.width, rect.size.height-64.0)];
    self.view = [[UIView alloc]initWithFrame:rect];
    self.view.backgroundColor = [UIColor blackColor];
    
    
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    CGRect rect = [UIScreen mainScreen].bounds;
    
    _zoomScrollView = [[MRZoomScrollView alloc]init];
    _zoomScrollView.frame = CGRectMake(0.0, 64.0, rect.size.width, rect.size.height-64.0);
    [_zoomScrollView.imageView  sd_setImageWithURL:self.imageURL placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    UIImage *image = _zoomScrollView.imageView.image;
    float radio = image.size.width/image.size.height;
    _zoomScrollView.imageView.frame = CGRectMake(_zoomScrollView.imageView.frame.origin.x,
                                                 _zoomScrollView.imageView.frame.origin.y,
                                                 _zoomScrollView.imageView.frame.size.width,
                                                 _zoomScrollView.imageView.frame.size.width/radio);
    
    [self.view addSubview:_zoomScrollView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
