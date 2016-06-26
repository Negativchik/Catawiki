//
//  ImageViewController.h
//  Catawiki
//
//  Created by Michael Smirnov on 26.06.16.
//  Copyright © 2016 Smirnov. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class GalleryImage;

@interface ImageViewController : UIViewController

- (instancetype)initWithImage:(nullable id<GalleryImage>)image NS_DESIGNATED_INITIALIZER;

@property (nonatomic, readonly) UITapGestureRecognizer *doubleTapGestureRecognizer;

@end

NS_ASSUME_NONNULL_END