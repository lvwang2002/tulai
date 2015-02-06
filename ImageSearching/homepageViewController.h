//
//  homepageViewController.h
//  ImageSearching
//
//  Created by lvwang on 15/2/5.
//  Copyright (c) 2015年 MA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface homepageViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end
