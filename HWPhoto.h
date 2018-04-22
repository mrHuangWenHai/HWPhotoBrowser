//
//  HWPhoto.h
//  Coding
//
//  Created by 黄文海 on 2018/4/17.
//  Copyright © 2018年 huang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface HWPhoto : NSObject
@property(nonatomic, strong)NSURL* url;
@property(nonatomic, strong)UIImage* image;
@property(nonatomic, strong)UIImage* placeholder;
@end
