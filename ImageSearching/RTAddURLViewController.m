//
//  RTAddURLViewController.m
//  ImageSearching
//
//  Created by lvwang on 15/2/6.
//  Copyright (c) 2015年 MA. All rights reserved.
//

#import "RTAddURLViewController.h"

@interface RTAddURLViewController ()

@end

@implementation RTAddURLViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(_done)];
    self.navigationItem.rightBarButtonItem = rightButton;
    
}

-(void)_done{
    NSURL *url = [self smartURLForString:self.urlTextFiled.text];
    if (!url) {
        UIAlertView *alertView= [[UIAlertView alloc] initWithTitle:@"输入错误" message:@"网址错误,请重新输入." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确认", nil];
        [alertView show];
    }else{
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        NSMutableArray *imagePages = [[userDefault valueForKey:@"imagePages"] mutableCopy];
        [imagePages addObject:@{
                                @"url":url.absoluteString
                                }];
        [userDefault setValue:imagePages forKey:@"imagePages"];
        [userDefault synchronize];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark- textField代理方法
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self _done];
    
    return YES;
};


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSURL *)smartURLForString:(NSString *)str
{
    NSURL *     result;
    NSString *  trimmedStr;
    NSRange     schemeMarkerRange;
    NSString *  scheme;
    
    assert(str != nil);
    
    result = nil;
    
    trimmedStr = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ( (trimmedStr != nil) && (trimmedStr.length != 0) ) {
        schemeMarkerRange = [trimmedStr rangeOfString:@"://"];
        
        if (schemeMarkerRange.location == NSNotFound) {
            result = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", trimmedStr]];
        } else {
            scheme = [trimmedStr substringWithRange:NSMakeRange(0, schemeMarkerRange.location)];
            assert(scheme != nil);
            
            if ( ([scheme compare:@"http"  options:NSCaseInsensitiveSearch] == NSOrderedSame)
                || ([scheme compare:@"https" options:NSCaseInsensitiveSearch] == NSOrderedSame) ) {
                result = [NSURL URLWithString:trimmedStr];
            } else {
                // It looks like this is some unsupported URL scheme.
            }
        }
    }
    
    return result;
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
