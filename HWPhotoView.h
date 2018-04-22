//
//  HWPhotoView.h
//  Coding
//
//  Created by 黄文海 on 2018/4/17.
//  Copyright © 2018年 huang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HWPhoto;
@class HWPhotoView;

@protocol HWPhotoViewDelegate <NSObject>
- (void)photoViewImageFinishLoad:(HWPhotoView *)photoView;
- (void)photoViewSingleTap:(HWPhotoView *)photoView;
@end

@interface HWPhotoView : UIScrollView
@property(nonatomic, strong)HWPhoto* photo;
@property(nonatomic, assign)NSInteger index;
@property(nonatomic, strong)id<HWPhotoViewDelegate> photoViewDelegate;
@end
