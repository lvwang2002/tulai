//
//  PhotoGridViewController.m
//  ImageSearching
//
//  Created by Yuliang Ma on 4/5/14.
//  Copyright (c) 2014 MA. All rights reserved.
//

#import "PhotoGridViewController.h"
#import "CVCell.h"
#import "UIImageView+AFNetworking.h"
#import "RTHTMLParser.h"
#import "SDWebImageManager.h"
#import "UIImageView+WebCache.h"
#import "RTPhotoGridViewController.h"
#import "RTZoomImageViewController.h"
#import "MRZoomScrollView.h"
@interface PhotoGridViewController (){
        RTHTMLParser *_htmlParser;
}

@end

@implementation PhotoGridViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    // Initialize recipe image array
    
    [self.collectionView registerClass:[CVCell class] forCellWithReuseIdentifier:@"cvCell"];
    
    // Configure layout
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [self.collectionView setCollectionViewLayout:flowLayout];
    self.collectionView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_loadHTMLFinished) name:RTLoadHTMLFinished object:nil];
    
    NSDictionary *info = [_imagePages objectAtIndex:self.imagePageIndex];
    self.title = [info valueForKey:@"title"];
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(_refresh)];
    self.navigationItem.rightBarButtonItem = rightButton;
    
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RTLoadHTMLFinished object:nil];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    //如果传进来的字典没有数,图片则启动下载程序,下载成功后,需要保存字典.
    NSMutableDictionary *info = [[self.imagePages objectAtIndex:self.imagePageIndex] mutableCopy];
    NSArray *images = [info valueForKey:@"images"];
    if (!images) {
        //如果为空,开始下载.
        RTHTMLParser *htmlParser = [[RTHTMLParser alloc] init];
        _htmlParser = htmlParser;
        [htmlParser searchWithURL:[info valueForKey:@"url"] completionHandler:^(NSArray *hrefArray, NSArray *imgArray,NSString *title, NSError *error){
            
            self.urlArray = imgArray;
            [info setValue:imgArray forKey:@"images"];
            
            if (title) {
                [info setValue:title forKey:@"title"];
                self.title = title;
            }
            
            [self.imagePages replaceObjectAtIndex:self.imagePageIndex withObject:info];
            [[NSUserDefaults standardUserDefaults] setObject:self.imagePages forKey:@"imagePages"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            
            
            
            [self.collectionView reloadData];
            [self.collectionView flashScrollIndicators];
        }];
    }else{
        self.urlArray = [images copy];
        [self.collectionView reloadData];
    }
    
}

-(void)_refresh{
    
    NSMutableDictionary *info = [[self.imagePages objectAtIndex:self.imagePageIndex] mutableCopy];

    
    RTHTMLParser *htmlParser = [[RTHTMLParser alloc] init];
    _htmlParser = htmlParser;
    [htmlParser searchWithURL:[info valueForKey:@"url"] completionHandler:^(NSArray *hrefArray, NSArray *imgArray,NSString *title, NSError *error){
        
        self.urlArray = imgArray;
        [info setValue:imgArray forKey:@"images"];
        
        if (title) {
            [info setValue:title forKey:@"title"];
            self.title = title;
        }
        
        [self.imagePages replaceObjectAtIndex:self.imagePageIndex withObject:info];
        [[NSUserDefaults standardUserDefaults] setObject:self.imagePages forKey:@"imagePages"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        
        
        
        [self.collectionView reloadData];
        [self.collectionView flashScrollIndicators];
    }];


}

#pragma mark- 消息处理方法
-(void)_loadHTMLFinished{
    _htmlParser =  nil;
    
    
}

#pragma mark - collection代理
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.urlArray.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"cvCell";
    
    CVCell *cell = (CVCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
//    [cell.photoImageView setImageWithURL:[NSURL URLWithString:self.urlArray[indexPath.row]] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    [cell.photoImageView sd_setImageWithURL:self.urlArray[indexPath.row] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    
    return cell;
}

#pragma mark – UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize retval = CGSizeMake(100, 100);
    return retval;
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(10, 0, 0, 0);
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
//    [[[UIAlertView alloc] initWithTitle:nil message:self.urlArray[indexPath.row] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
    RTZoomImageViewController *zoomImageViewController = [[RTZoomImageViewController alloc] init];
    zoomImageViewController.imageURL = self.urlArray[indexPath.row];
    [self.navigationController pushViewController:zoomImageViewController animated:YES];
}


@end