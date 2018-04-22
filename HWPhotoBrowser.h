//
//  HWPhotoBrowser.h
//  Coding
//
//  Created by 黄文海 on 2018/4/17.
//  Copyright © 2018年 huang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface HWPhotoBrowser : NSObject <UIScrollViewDelegate>
@property(nonatomic, copy)NSArray* photos;
@property(nonatomic, assign)NSInteger courentIndex;
@property(nonatomic, strong)UIScrollView* photoScrollView;
- (void)show;
@end
