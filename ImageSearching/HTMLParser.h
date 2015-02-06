//
//  HTMLParser.h
//  ImageSearching
//
//  Created by Yuliang Ma on 4/4/14.
//  Copyright (c) 2014 MA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HTMLParser : NSObject
@property (nonatomic, strong) NSMutableArray *hrefArray;
@property (nonatomic, strong) NSMutableArray *imgArray;
@property (nonatomic, copy) NSString *baseURL;
@property (nonatomic, copy) NSString *startsWith;
// First array is array of links (href)
// Second array is array of image links (img)
- (void)searchWithURL: (NSString *)urlString completionHandler: (void (^)(NSArray *, NSArray *,NSString *, NSError*))handler;
- (void)processHTMLString: (NSString *)html;
- (NSString *)fullPathFromURL: (NSString *)urlString;
@end

