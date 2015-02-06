//
//  RTPhotoGridViewController.m
//  ImageSearching
//
//  Created by lvwang on 15/2/5.
//  Copyright (c) 2015年 MA. All rights reserved.
//

#import "RTPhotoGridViewController.h"
#import "RTHTMLParser.h"
@interface RTPhotoGridViewController ()

@end

@implementation RTPhotoGridViewController{
    RTHTMLParser *_htmlParser;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    //如果传进来的字典没有数,图片则启动下载程序,下载成功后,需要保存字典.
//    NSMutableDictionary *info = [[self.imagePages objectAtIndex:self.imagePageIndex] mutableCopy];
//    NSArray *images = [info valueForKey:@"images"];
//    if (!images) {
//        //如果为空,开始下载.
//        RTHTMLParser *htmlParser = [[RTHTMLParser alloc] init];
//        _htmlParser = htmlParser;
//        [htmlParser searchWithURL:[info valueForKey:@"url"] completionHandler:^(NSArray *hrefArray, NSArray *imgArray, NSString *title,NSError *error){
//            
//            self.urlArray = imgArray;
//            [info setValue:imgArray forKey:@"images"];
//            [self.imagePages replaceObjectAtIndex:self.imagePageIndex withObject:info];
//            [[NSUserDefaults standardUserDefaults] setObject:self.imagePages forKey:@"imagePages"];
//            [[NSUserDefaults standardUserDefaults] synchronize];
//            
//            
//            [self.collectionView reloadData];
//            [self.collectionView flashScrollIndicators];
//        }];
//    }else{
//        self.urlArray = [images copy];
//        [self.collectionView reloadData];
//    }
    
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
