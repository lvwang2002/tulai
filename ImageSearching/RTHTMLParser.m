//
//  RTHTMLParser.m
//  ImageSearching
//
//  Created by lvwang on 15/2/4.
//  Copyright (c) 2015年 MA. All rights reserved.
//

#import "RTHTMLParser.h"
#import "MBProgressHUD.h"
@implementation RTHTMLParser{
    void(^_handler)(NSArray *, NSArray *,NSString * ,NSError*);
    NSMutableSet *_pageUrls;
    NSString *_baseUrl;
    NSMutableArray *_webViewInfos;
    NSMutableSet *_loadedUrls;
    NSDate *_loadFinTime;
    MBProgressHUD *_hud;
    UIView *_view;
}
-(instancetype)init{
    self = [super init];
    if (self) {
        _pageUrls = [[NSMutableSet alloc]init];
        _webViewInfos = [[NSMutableArray alloc] init];
        _loadedUrls = [[NSMutableSet alloc] init];
        _loadFinTime = [NSDate date];
    }
    return self;
}

- (void)searchWithURL: (NSString *)urlString completionHandler: (void (^)(NSArray *, NSArray *,NSString *,NSError*))handler {
    _handler = handler;
    NSURL *url = [NSURL URLWithString:urlString];
    NSArray *pathComponents = [urlString pathComponents];
    if (pathComponents.count > 1) self.baseURL = [NSString stringWithFormat:@"%@//%@", pathComponents[0], pathComponents[1]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];

    CGRect rect = [UIScreen mainScreen].bounds;
    UIView *view = [[UIView alloc] initWithFrame:rect];
//    view.alpha = 0.5;
    view.backgroundColor = [UIColor clearColor];
    _view = view;
    
    UIWebView *webView= [[UIWebView alloc]initWithFrame:CGRectMake(10.0,10.0,rect.size.width-20.0,rect.size.height-20.0)];
    webView.delegate = self;
    webView.userInteractionEnabled = NO;
//    [request setValue:@"Safari/537.1" forHTTPHeaderField: @"UserAgent"];

    [webView loadRequest:request];
    _baseUrl = urlString;
    
    [[UIApplication sharedApplication].keyWindow addSubview:_view];
    [_view addSubview:webView];
    
    _hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    _hud.labelText = @"正在分析网页...";
    
    [self performSelector:@selector(_checkWebView) withObject:self afterDelay:1];
    NSMutableDictionary *info = [@{@"webView":webView,
                           @"lastChangeTime":[NSDate date]
                           } mutableCopy];
    [_webViewInfos addObject:info];
    
    [_loadedUrls addObject:urlString];
    [_pageUrls addObject:urlString];
}

#pragma mark - 监控WebView超市
-(void)_checkWebView{
    //超过5秒删掉
    NSMutableArray *removes = [[NSMutableArray alloc] init];
    for (NSMutableDictionary *info in _webViewInfos) {
        NSDate *lastChangeTime = [info valueForKey:@"lastChangeTime"];
        if ([[NSDate date] timeIntervalSinceDate:lastChangeTime]>=5.0) {
            UIWebView *webView = [info valueForKey:@"webView"];
            [webView removeFromSuperview];
            [removes addObject:info];
        }
    }
    
    [_webViewInfos removeObjectsInArray:removes];
    
    NSArray *pageUrls = [_pageUrls allObjects];
    for (NSString *urlString in pageUrls) {
        if (![_loadedUrls containsObject:urlString]) {
            if (_webViewInfos.count<2) {
                //如果不包括则是新的url,可以下载.
                NSURL *url = [NSURL URLWithString:urlString];
                NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
                CGRect rect = [UIScreen mainScreen].bounds;
                UIWebView *webView= [[UIWebView alloc]initWithFrame:CGRectMake(10.0,10.0,rect.size.width-20.0,rect.size.height-20.0)];
                webView.userInteractionEnabled = NO;
                webView.delegate = self;
                [webView loadRequest:request];
                [_view addSubview:webView];
                
                NSMutableDictionary *info = [@{@"webView":webView,
                                               @"lastChangeTime":[NSDate date]
                                               } mutableCopy];
                [_webViewInfos addObject:info];
                webView.userInteractionEnabled = NO;

                [_loadedUrls addObject:urlString];
            }
        }
    }
    
    if ([[NSDate date] timeIntervalSinceDate:_loadFinTime]>20.0) {
        //如果10s都没有反馈,发个消息,告诉上层,结束了.
        _hud.labelText = @"网页分析完成";
        [_view removeFromSuperview];
        [_hud hide:YES afterDelay:1.5];

        _handler = nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:RTLoadHTMLFinished object:self];
        
    }else{
        [self performSelector:@selector(_checkWebView) withObject:self afterDelay:1];
    }

}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    return YES;
}

-(void)webViewDidStartLoad:(UIWebView *)webView{
    NSLog(@"start load");
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{

    
}

-(void)webViewDidFinishLoad:(UIWebView *)webView{
    _loadFinTime = [NSDate date];
    for (NSMutableDictionary *webInfo in _webViewInfos) {
        if ([webInfo valueForKey:@"webView"] == webView) {
            //如果两者相等
            [webInfo setObject:[NSDate date] forKey:@"lastChangeTime"];
        }
    }
    
    NSString *lJs = @"document.documentElement.innerHTML";
    NSString *lHtml1 = [webView stringByEvaluatingJavaScriptFromString:lJs];
    NSLog(@"html:%@",lHtml1);
    [self processHTMLString:lHtml1];
    NSLog(@"images:%@",self.imgArray);
    NSLog(@"my urls:%@",_pageUrls);
    
    
    NSString *pattern = @"继续访问艾泽拉斯国家地理";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray *array = [regex matchesInString:lHtml1 options:0 range:NSMakeRange(0, lHtml1.length)];
    if (array.count) {
        if (_loadedUrls.count>2) {
           [_loadedUrls removeObject:[_loadedUrls anyObject]];
           [_loadedUrls removeObject:[_loadedUrls anyObject]];
        }else{
           [_loadedUrls removeAllObjects];
        }
        
    }
    
    NSString *title;
    pattern = @"::.*?::";
    regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    array = [regex matchesInString:lHtml1 options:0 range:NSMakeRange(0, lHtml1.length)];
    
    if (array.count) {
        for (NSTextCheckingResult *match in array) {
            NSRange stringRange = NSMakeRange(match.range.location, match.range.length);
            NSString *matchString = [lHtml1 substringWithRange:stringRange];
            title = matchString;
        }
    }
    
    if (self.imgArray.count>0) {
        if (_handler) {
            NSSet *imageSet = [[NSSet alloc]initWithArray:self.imgArray];
            _handler([self.hrefArray copy], [imageSet allObjects],title, nil);
//            _handler = nil;
        }
    }
}

- (void)processHTMLString: (NSString *)html {
    // Find href links
    NSError *error = NULL;
//    NSString *pattern = @"<a\\s+(?:[^>]*?\\s+)?href=\"([^\"]*)\""; //@"<(a|link)\\s+(?:[^>]*?\\s+)?href=\"([^\"]*)\"";
    
    NSString *pattern = @"/read.php?.*?\"";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray *array = [regex matchesInString:html options:0 range:NSMakeRange(0, html.length)];
    for (NSTextCheckingResult *match in array) {
        NSRange stringRang = NSMakeRange(match.range.location, match.range.length-1);
        NSString *matchString = [html substringWithRange:stringRang];
//        NSArray *components = [matchString componentsSeparatedByString:@"href=\""];
//        if(components.count < 2) continue;
//        NSString *temp = components[1];
//        NSString *urlString = [temp substringToIndex:temp.length-1];
//        if (![urlString hasPrefix:@"#"] &&
//            ![urlString hasPrefix:@"javascript:"] &&
//            ![urlString hasPrefix:@"mailto:"] &&
//            ![urlString hasPrefix:@"irc://"] &&
//            ![urlString hasSuffix:@".css"] &&
//            urlString.length > 1) {
//            urlString = [self fullPathFromURL:urlString]; // deal with relative path
//            //NSLog(@"%@", urlString);
//            [self.hrefArray addObject:urlString];
//        }
        if ([self containedString:@"pid" withSourceString:matchString] ||
            [self containedString:@"<" withSourceString:matchString] ||
            [self containedString:@"topid" withSourceString:matchString] ||
            [self containedString:@"rand" withSourceString:matchString] ||
            [self containedString:@"[" withSourceString:matchString] ||
            [self containedString:@"url" withSourceString:matchString]) {
            //包括这两个不认为是合格的pid
            
            
        }else{
            //
            NSString *fullUrl = [NSString stringWithFormat:@"%@%@", @"http://bbs.ngacn.cc",matchString];
            fullUrl = [fullUrl stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
            [self.hrefArray addObject:fullUrl];
            [_pageUrls addObject:fullUrl];
        }
        
    }
    //NSLog(@"%lu urls found", (unsigned long)array.count);
    
    // Find img urls
//    pattern = @"http://img.*?[pjg][npi][gf] | ";
    pattern = @"mon_.*?[pjg][pni][gf]";
    regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    array = [regex matchesInString:html options:0 range:NSMakeRange(0, html.length)];
    for (NSTextCheckingResult *match in array) {
//        NSString *matchString = [html substringWithRange:match.range];
//        matchString = [matchString stringByReplacingOccurrencesOfString:@"'" withString:@"\""]; // to cover both <img src=' and <img src="
//        NSArray *components = [matchString componentsSeparatedByString:@"src=\""];
//        if(components.count < 2) continue;
//        NSString *temp = components[1];
//        components = [temp componentsSeparatedByString:@"\""];
//        if(components.count < 2) continue;
        NSRange range = [match range];

        NSString *urlString = [html substringWithRange:range];
        if (urlString.length < 2) continue; // dump if it is too short
//        urlString = [self fullPathFromURL:urlString]; // deal with relative path
        urlString = [NSString stringWithFormat:@"http://img.nga.178.com/attachments/%@",urlString];
        //NSLog(@"---  %@", urlString);
        [self.imgArray addObject:urlString];
    }
}
-(BOOL)containedString:(NSString *)string withSourceString:(NSString *)sourceString{
    NSRange theRange =[sourceString rangeOfString:string];
    if (theRange.length>0) {
        return YES;
    }else{
        return NO;
    }
    
}
-(void)dealloc{
    
    
}
@end
