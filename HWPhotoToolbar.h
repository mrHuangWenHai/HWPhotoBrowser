//
//  HWPhotoToolbar.h
//  Coding
//
//  Created by 黄文海 on 2018/4/18.
//  Copyright © 2018年 huang. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^SaveImageBlock)(BOOL isSuccess);
@interface HWPhotoToolbar : UIView
@property(nonatomic, copy)NSArray* photoArray;
@property(nonatomic, assign)NSUInteger currentpage;
@property(nonatomic, copy)SaveImageBlock saveImageBlock;
@end
