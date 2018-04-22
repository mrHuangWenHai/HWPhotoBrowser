//
//  HWPhotoBrowser.m
//  Coding
//
//  Created by 黄文海 on 2018/4/17.
//  Copyright © 2018年 huang. All rights reserved.
//

#import "HWPhotoBrowser.h"
#import "PhotoBrowserHeader.h"
#import "HWPhotoView.h"
#import "HWPhotoToolbar.h"
#import "MBProgressHUD.h"

@interface HWPhotoBrowser()<HWPhotoViewDelegate>
@property(nonatomic, strong)UIView* view;
@property(nonatomic, strong)NSMutableSet* visiablePhotosViewSet;
@property(nonatomic, strong)NSMutableSet* hidePhotosViewSet;
@property(nonatomic, assign)NSUInteger pageCount;
@property(nonatomic, strong)NSMutableArray* visiblePageArray;
@property(nonatomic, assign)NSInteger realIndex;
@property(nonatomic, strong)HWPhotoToolbar* photoToolView;
@end

@implementation HWPhotoBrowser

- (UIScrollView*)photoScrollView {
    if (!_photoScrollView) {
        CGRect frame = self.view.frame;
        frame.size.width += kPadding;
        _photoScrollView = [[UIScrollView alloc] initWithFrame:frame];
        _photoScrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _photoScrollView.pagingEnabled = true;
        _photoScrollView.showsVerticalScrollIndicator = NO;
        _photoScrollView.showsHorizontalScrollIndicator = NO;
        _photoScrollView.backgroundColor = [UIColor clearColor];
    }
    return _photoScrollView;
}

- (UIView*)view {
    if (!_view) {
        _view = [[UIView alloc] initWithFrame:kScreen_Bounds];
        _view.backgroundColor = [UIColor blackColor];
        _view.userInteractionEnabled = true;
    }
    return _view;
}

- (HWPhotoView*)dequeueReusablePhotoView {
    HWPhotoView* photoView = [self.hidePhotosViewSet anyObject];
    if (photoView) {
        [self.hidePhotosViewSet removeObject:photoView];
    }
    return photoView;
}

- (HWPhotoView*)getPhotoViewAtIndex:(NSInteger)index {
    
    if (index >= self.photos.count) return nil;
    for (HWPhotoView* photoView in self.visiblePageArray) {
        if (photoView.index == index) {
            return photoView;
        }
    }
    return nil;
}

- (void)loadImageViewAtIndex:(NSInteger)index {
    
    if (index < 0 || index >= self.photos.count) return;
    
    for (HWPhotoView* photoView in self.visiblePageArray) {
        if (photoView.index == index) {
            return ;
        }
    }
    
    HWPhotoView* photoView = [self dequeueReusablePhotoView];
    if (photoView == NULL) {
        photoView = [[HWPhotoView alloc] init];
        photoView.photoViewDelegate = self;
        [self.visiblePageArray addObject:photoView];
    }
    
    if (index < self.courentIndex) {
        photoView.frame = CGRectMake((CGRectGetWidth(self.view.frame) + kPadding) * (self.realIndex-1), 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
        [self.photoScrollView addSubview:photoView];
    } else {
        photoView.frame = CGRectMake((CGRectGetWidth(self.view.frame) + kPadding) * (self.realIndex + 1), 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
        [self.photoScrollView addSubview:photoView];
    }
    
    photoView.index = index;
    photoView.photo = self.photos[index];
}

- (UIView*)photoToolView {
    
    if (!_photoToolView) {
        CGFloat barHeight = 49;
        CGFloat barY = self.view.frame.size.height - barHeight;
        _photoToolView = [[HWPhotoToolbar alloc] initWithFrame:CGRectMake(0, barY, self.view.frame.size.width, barHeight)];
        __weak typeof(self) weakSelf = self;
        _photoToolView.saveImageBlock = ^(BOOL isSuccess) {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:weakSelf.view animated:true];
            hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"success"]];
            hud.mode = MBProgressHUDModeCustomView;
            hud.removeFromSuperViewOnHide = YES;
            if (isSuccess) {
                hud.label.text = @"存储成功";
            } else {
                hud.label.text = @"存储成功";
            }
            [hud hideAnimated:true afterDelay:0.7];
        };
    }
    return _photoToolView;
}

- (void)adjustPhotoViewWithDirection:(BOOL)forward {
    if (forward) {
        if (self.courentIndex > 0) {
            NSInteger lastIndex = self.courentIndex - 1;
            if (lastIndex > 0) {
                HWPhotoView* photoView = [self getPhotoViewAtIndex:lastIndex];
                if (!photoView) {
                    photoView = [[HWPhotoView alloc] init];
                    photoView.photoViewDelegate = self;
                    photoView.index = lastIndex;
                    photoView.photo = self.photos[lastIndex];
                    [self.photoScrollView addSubview:photoView];
                    [self.visiblePageArray addObject:photoView];
                }
                photoView.frame = CGRectMake((CGRectGetWidth(self.view.frame) + kPadding), 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
                self.photoScrollView.contentOffset = CGPointMake((CGRectGetWidth(self.view.frame) + kPadding), 0);
                HWPhotoView* currentPhotoView = [self getPhotoViewAtIndex:self.courentIndex];
                currentPhotoView.frame = CGRectMake((CGRectGetWidth(self.view.frame) + kPadding)*2, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
                
                HWPhotoView* nextPhotoView = [self getPhotoViewAtIndex:self.courentIndex + 1];
                if (nextPhotoView) {
                    [nextPhotoView removeFromSuperview];
                    [self.hidePhotosViewSet addObject:nextPhotoView];
                }
                self.realIndex = 1;
                
            } else {
                self.realIndex--;
            }
            self.courentIndex = lastIndex;
            self.photoToolView.currentpage = self.courentIndex;
        }
    } else {
        
        if (self.courentIndex < self.pageCount - 1 && self.courentIndex > 0) {
            NSInteger nextIndex = self.courentIndex + 1;
            HWPhotoView* photoView = [self getPhotoViewAtIndex:nextIndex];
            if (!photoView) {
                
                photoView = [[HWPhotoView alloc] init];
                photoView.photoViewDelegate = self;
                photoView.index = nextIndex;
                photoView.photo = self.photos[nextIndex];
                [self.photoScrollView addSubview:photoView];
                [self.visiblePageArray addObject:photoView];
            }
            
            photoView.frame = CGRectMake((CGRectGetWidth(self.view.frame) + kPadding), 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
            self.photoScrollView.contentOffset = CGPointMake((CGRectGetWidth(self.view.frame) + kPadding), 0);
            HWPhotoView* currentPhotoView = [self getPhotoViewAtIndex:self.courentIndex];
            currentPhotoView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
            
            HWPhotoView* nextPhotoView = [self getPhotoViewAtIndex:self.courentIndex - 1];
            if (nextPhotoView) {
                [nextPhotoView removeFromSuperview];
                [self.hidePhotosViewSet addObject:nextPhotoView];
            }
            self.courentIndex = nextIndex;
            _photoToolView.currentpage = self.courentIndex;
            self.realIndex = 1;
        } else {
            self.realIndex += 1;
            self.courentIndex += 1;
            _photoToolView.currentpage = self.courentIndex;
        }
    }
}

- (void)showImageView {
    
    CGRect visibleRect = _photoScrollView.bounds;
    if (visibleRect.origin.x < 0) return;
    
    if (self.photoScrollView.contentOffset.x == 0 && self.realIndex != 0) {
        [self adjustPhotoViewWithDirection:true];
        return;
    }
    
    if (self.photoScrollView.contentOffset.x == CGRectGetWidth(visibleRect) && self.realIndex != 1) {
        if (self.realIndex == 0) {
            [self adjustPhotoViewWithDirection:false];
        } else {
            [self adjustPhotoViewWithDirection:true];
        }
        return ;
    }

    if (self.photoScrollView.contentOffset.x == 2 * CGRectGetWidth(visibleRect) && self.realIndex != 2) {
        [self adjustPhotoViewWithDirection:false];
        return;
    }
    NSInteger firstIndex = (int)floor((CGRectGetMinX(visibleRect) - 1) / CGRectGetWidth(visibleRect));
    NSInteger lastIndex = (int)floor((CGRectGetMaxX(visibleRect) + 1) / CGRectGetWidth(visibleRect));
    
    if (firstIndex < self.realIndex) {
        [self loadImageViewAtIndex:self.courentIndex - 1];
    }
    
    if (self.realIndex < lastIndex) {
        [self loadImageViewAtIndex:self.courentIndex + 1];
    }
}

- (void)show {
    
    [kKeyWindow endEditing:true];
    
    {

        if (!_visiablePhotosViewSet) {
            _visiablePhotosViewSet = [NSMutableSet set];
        }

        if (!_hidePhotosViewSet) {
            _hidePhotosViewSet = [NSMutableSet set];
        }

        if (!_visiblePageArray) {
            _visiblePageArray = [[NSMutableArray alloc] initWithCapacity:3];
        }

        CGRect frame = self.view.frame;
        _pageCount = self.photos.count / 3 >= 1 ? 3 : self.photos.count % 3;
        self.photoScrollView.contentSize = CGSizeMake((frame.size.width + kPadding) * _pageCount , 0);
        self.photoScrollView.delegate = self;

        [self.view addSubview:self.photoScrollView];
        [self.view addSubview:self.photoToolView];
        if (_pageCount == 3) {
            HWPhotoView* photoView = [self dequeueReusablePhotoView];
            if (photoView == NULL) {
                photoView = [[HWPhotoView alloc] init];
                photoView.photoViewDelegate = self;
                [self.visiblePageArray addObject:photoView];
            }
            if (self.courentIndex == 0) {
                photoView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
                self.photoScrollView.contentOffset = CGPointMake(0, 0);
                self.realIndex = 0;
            } else if (self.photos.count - 1 == self.courentIndex) {
                photoView.frame = CGRectMake((frame.size.width + kPadding)*2, 0, frame.size.width, frame.size.height);
                self.realIndex = 2;
                self.photoScrollView.contentOffset = CGPointMake((frame.size.width + kPadding)*2, 0);
            } else {
                photoView.frame = CGRectMake((frame.size.width + kPadding), 0, frame.size.width, frame.size.height);
                self.realIndex = 1;
                self.photoScrollView.contentOffset = CGPointMake(frame.size.width + kPadding, 0);
            }
            photoView.index = self.courentIndex;
            photoView.photo = self.photos[self.courentIndex];
            [self.photoScrollView addSubview:photoView];
        } else {
            for (int i = 0; i < self.photos.count; i++) {
                HWPhotoView* photoView = [self dequeueReusablePhotoView];
                if (photoView == NULL) {
                    photoView = [[HWPhotoView alloc] init];
                    photoView.photoViewDelegate = self;
                    [self.visiblePageArray addObject:photoView];
                }
                photoView.frame = CGRectMake((frame.size.width + kPadding) * i, 0, frame.size.width, frame.size.height);
                photoView.photo = self.photos[i];
                photoView.index = i;
                [self.photoScrollView addSubview:photoView];
            }
            self.photoScrollView.contentOffset = CGPointMake((frame.size.width + kPadding) * self.courentIndex, 0);
        }
        self.photoToolView.photoArray = self.photos;
        self.photoToolView.currentpage = self.courentIndex;
    }
    
    [kKeyWindow addSubview:self.view];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSLog(@"%f %f",self.photoScrollView.contentOffset.x, CGRectGetWidth(self.photoScrollView.frame));
    if (self.pageCount == 3) {
        [self showImageView];
    } else {
        if (self.pageCount == 1) return;
        NSInteger des = self.photoScrollView.contentOffset.x / CGRectGetWidth(self.photoScrollView.frame);
        NSLog(@"%f %f",self.photoScrollView.contentOffset.x, CGRectGetWidth(self.photoScrollView.frame));
        NSLog(@"%ld",des);
        self.photoToolView.currentpage = des;
    }
}

- (void)photoViewSingleTap:(HWPhotoView *)photoView {
    [self.view removeFromSuperview];
    [self.visiblePageArray enumerateObjectsUsingBlock:^(UIView* photoView, NSUInteger idx, BOOL * _Nonnull stop) {
        [photoView removeFromSuperview];
    }];
}
@end
