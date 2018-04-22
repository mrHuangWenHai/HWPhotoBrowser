//
//  HWPhotoToolbar.m
//  Coding
//
//  Created by 黄文海 on 2018/4/18.
//  Copyright © 2018年 huang. All rights reserved.
//

#import "HWPhotoToolbar.h"
#import "HWPhoto.h"
#import <Photos/Photos.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface HWPhotoToolbar()
@property(nonatomic, strong)UILabel* label;
@property(nonatomic, strong)UIImageView* imageView;
@property(nonatomic, strong)UIButton* saveButton;
@end

@implementation HWPhotoToolbar

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        _label = [[UILabel alloc] init];
        _label.font = [UIFont boldSystemFontOfSize:20];
        _label.textColor = [UIColor whiteColor];
        _label.textAlignment = NSTextAlignmentCenter;
        _label.frame = self.bounds;
        _label.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self addSubview:_label];
        
        _saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_saveButton setImage:[UIImage imageNamed:@"save_icon.png"] forState:UIControlStateNormal];
        [_saveButton setImage:[UIImage imageNamed:@"save_icon_highlighted.png"] forState:UIControlStateHighlighted];
        [_saveButton addTarget:self action:@selector(saveImage) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_saveButton];
    }
    return self;
}

- (void)layoutSubviews {
    CGFloat width = CGRectGetWidth(self.frame);
    CGFloat height = CGRectGetHeight(self.frame);
    _saveButton.frame = CGRectMake(20, 0, height, height);
}

- (void)setCurrentpage:(NSUInteger)currentpage {
    _currentpage = currentpage;
    self.label.text = [NSString stringWithFormat:@"%lu / %lu",currentpage + 1,(unsigned long)self.photoArray.count];
}

- (void)saveImage {
    NSLog(@"%ld",self.currentpage);
    HWPhoto* photo = self.photoArray[self.currentpage];
    NSString *dataP = [SDWebImageManager.sharedManager.imageCache defaultCachePathForKey:photo.url.absoluteString];
    NSData *imageD = [NSData dataWithContentsOfFile:dataP];
    
    __weak typeof(self) weakSelf = self;
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        [[PHAssetCreationRequest creationRequestForAsset] addResourceWithType:PHAssetResourceTypePhoto data:imageD options:nil];
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                weakSelf.saveImageBlock(false);
            } else {
                weakSelf.saveImageBlock(true);
            }

        });
    }];



    
}

@end
