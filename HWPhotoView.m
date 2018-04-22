//
//  HWPhotoView.m
//  Coding
//
//  Created by 黄文海 on 2018/4/17.
//  Copyright © 2018年 huang. All rights reserved.
//
#define kColorTableBG [UIColor colorWithHexString:@"0xFFFFFF"]

#import "HWPhotoView.h"
#import "HWPhoto.h"
#import <SDWebImage/UIImageView+WebCache.h>


@interface HWPhotoView()<UIScrollViewDelegate>
@property(nonatomic, strong)UIImageView* imageView;
@property(nonatomic, assign)BOOL isDoubleTouch;
@end

@implementation HWPhotoView
- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        _imageView = [[UIImageView alloc] init];
        [self addSubview:_imageView];
        
        self.delegate = self;
        
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        tap.delaysTouchesBegan = true;
        tap.numberOfTapsRequired = 1;
        [self addGestureRecognizer:tap];
        
        UITapGestureRecognizer* doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
        doubleTap.numberOfTapsRequired = 2;
        [self addGestureRecognizer:doubleTap];
        
        [tap requireGestureRecognizerToFail:doubleTap];
        
    }
    return self;
}

- (void)setPhoto:(HWPhoto *)photo {
    _photo = photo;
    [self showImage];
}

- (void)showImage {
    [self setImage];
    [self adjustImageView];
}

- (void)adjustImageView {
    
    if (self.imageView.image == NULL) return;
    
    CGFloat width = CGRectGetWidth(self.frame);
    CGFloat height = CGRectGetHeight(self.frame);
    
    CGFloat minScale = width / self.imageView.image.size.width;
    self.minimumZoomScale = MIN(1.0, minScale);
    
    CGFloat maxScale = 2.0;
    if ([UIScreen instancesRespondToSelector:@selector(scale)]) {
        maxScale = maxScale / [[UIScreen mainScreen] scale];
    }
    self.maximumZoomScale = maxScale;
    self.zoomScale = minScale;
    
    self.imageView.frame = CGRectMake(0, MAX(0, (height - self.imageView.image.size.height * minScale)/2), width, self.imageView.image.size.height * minScale);
    self.contentSize = CGSizeMake(width, 0);
}

- (void)setImage {
    
    if (_photo.image) {
        self.imageView.image = _photo.image;
    } else {
        self.imageView.image = _photo.placeholder;
        __weak typeof(self) weakSelf = self;
        [self.imageView sd_setImageWithURL:_photo.url completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            weakSelf.photo.image = image;
        }];
    }
}

- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    
    if (self.isDoubleTouch) {
        
        CGFloat insetY = (CGRectGetHeight(self.bounds) - CGRectGetHeight(_imageView.frame))/2;
        insetY = MAX(insetY, 0.0);
        if (ABS(_imageView.frame.origin.y - insetY) > 0.5) {
            [UIView animateWithDuration:0.2 animations:^{
                CGRect frame = _imageView.frame;
                frame.origin.y = insetY;
                _imageView.frame = frame;
            }];
        }
        self.isDoubleTouch = false;
    }
    
   
}

- (void)handleSingleTap:(UITapGestureRecognizer *)tap {
    if ([self.photoViewDelegate respondsToSelector:@selector(photoViewSingleTap:)]) {
        [self.photoViewDelegate photoViewSingleTap:self];
    }
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)tap {
    
    _isDoubleTouch = true;
    if (self.zoomScale == self.maximumZoomScale) {
        [self setZoomScale:self.minimumZoomScale animated:true];
    } else {
        CGPoint point = [tap locationInView:self];
        CGFloat scale = self.maximumZoomScale / self.zoomScale;
        CGRect rectTozoom = CGRectMake(point.x * scale, point.y * scale, 1, 1);
        [self zoomToRect:rectTozoom animated:YES];
    }
}

@end
