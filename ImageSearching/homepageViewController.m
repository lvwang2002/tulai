//
//  homepageViewController.m
//  ImageSearching
//
//  Created by lvwang on 15/2/5.
//  Copyright (c) 2015年 MA. All rights reserved.
//

#import "homepageViewController.h"
#import "RTPhotoGridViewController.h"
#import "RTAddURLViewController.h"
@interface homepageViewController ()

@end

@implementation homepageViewController{
    NSMutableArray *_imagePages;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.title = @"首页";
    //1.读取记录的信息.
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSArray *imagePages = [userDefault valueForKey:@"imagePages"];
    if (!imagePages) {
        //如果没有值,第一次进入,创建个{
        NSMutableArray *infos = [[NSMutableArray alloc] init];
        {
            NSDictionary *info = @{
                                   @"url":@"http://bbs.ngacn.cc/read.php?tid=7672362",
                                   @"title":@"被人说长的丑，太委屈了，要自爆虾"
                                   };
            [infos addObject:info];
        }
        
        {
            NSDictionary *info = @{
                                   @"url":@"http://bbs.ngacn.cc/read.php?tid=7834007&_ff=-7",
                                   @"title":@"[干死你！]约旦国王亲自驾战机空袭ISIS"
                                   };
            [infos addObject:info];
        }
        
        {
            NSDictionary *info = @{
                                   @"url":@"http://bbs.ngacn.cc/read.php?tid=7834316&_ff=-7",
                                   @"title":@"[你们什么都懂] 要不要和一个自己不是很喜欢但是很爱我的人结婚，结了婚的各位救救我吧"
                                   };
            [infos addObject:info];
            
        }
        imagePages = [infos copy];
        [userDefault setValue:imagePages forKey:@"imagePages"];
        [userDefault synchronize];
    }
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(_addURL)];
    self.navigationItem.rightBarButtonItem = rightButton;
    _imagePages = [imagePages mutableCopy];
//    [self.tableView reloadData];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSArray *imagePages = [userDefault valueForKey:@"imagePages"];
    
    _imagePages = [imagePages mutableCopy];
    [self.tableView reloadData];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)_addURL{
    RTAddURLViewController *addURLViewController = [[RTAddURLViewController alloc] initWithNibName:@"RTAddURLViewController" bundle:nil];
    [self.navigationController pushViewController:addURLViewController animated:YES];
}

#pragma mark - tableView的回调
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_imagePages count];
}


-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
//    cell.imageView.image=[UIImage imageNamed:_mateArray[indexPath.row]];
//    cell.textLabel.text=_mateArr[indexPath.row];
//    LogBlue(@"%@",_mateArr[indexPath.row]);
    NSDictionary *info = [_imagePages objectAtIndex:indexPath.row];
    NSString *title = [info valueForKey:@"title"];
    if (title) {
        cell.textLabel.text = title;
    }else{
        cell.textLabel.text = @"请点击解析.";
    }
    
    cell.textLabel.font = [UIFont systemFontOfSize:14.0];
    cell.textLabel.numberOfLines = 2;
    cell.accessoryType  = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
//    UITextField *matefd=(UITextField*)[contentView viewWithTag:8];
//    matefd.text=_mateArr[indexPath.row];
//    [matefd.inputView removeFromSuperview];
//    [matefd resignFirstResponder];
    PhotoGridViewController  *photoVC = [[PhotoGridViewController alloc] init];
    photoVC.imagePages = _imagePages;
    photoVC.imagePageIndex = indexPath.row;
    
    [self.navigationController pushViewController:photoVC animated:YES];
    
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_imagePages removeObjectAtIndex:indexPath.row];
        [[NSUserDefaults standardUserDefaults] setObject:_imagePages forKey:@"imagePages"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
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
