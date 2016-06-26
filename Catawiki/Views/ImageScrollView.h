//
//  ImageScrollView.h
//  Catawiki
//
//  Created by Michael Smirnov on 26.06.16.
//  Copyright © 2016 Smirnov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageScrollView : UIScrollView

@property (nonatomic, readonly) UIImageView *imageView;

- (void)centerScrollViewContents;
- (void)updateImage:(UIImage *)image;

@end
