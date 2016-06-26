//
//  ImageScrollView.m
//  Catawiki
//
//  Created by Michael Smirnov on 26.06.16.
//  Copyright © 2016 Smirnov. All rights reserved.
//

#import "ImageScrollView.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface ImageScrollView ()

@property (nonatomic) UIImageView *imageView;

@end

@implementation ImageScrollView

- (instancetype)initWithFrame:(CGRect)frame
{
	return [self initWithImage:nil frame:frame];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];

	if (self) {
		[self commonInitWithImage:nil];
	}
	return self;
}

- (instancetype)initWithImage:(UIImage *)image frame:(CGRect)frame
{
	self = [super initWithFrame:frame];

	if (self) {
		[self commonInitWithImage:image];
	}

	return self;
}

- (void)commonInitWithImage:(UIImage *)image
{
	[self setupImageViewWithImage:image];
	[self setupImageScrollView];
	[self updateZoomScale];
}

#pragma mark UIView(UIViewHierarchy)

- (void)didAddSubview:(UIView *)subview
{
	[super didAddSubview:subview];
	[self centerScrollViewContents];
}

#pragma mark UIView(UIViewGeometry)

- (void)setFrame:(CGRect)frame
{
	[super setFrame:frame];
	[self updateZoomScale];
	[self centerScrollViewContents];
}

#pragma mark Setup

- (void)setupImageViewWithImage:(UIImage *)image
{
	self.imageView = [[UIImageView alloc] initWithImage:image];

	[self updateImage:image];

	[self addSubview:self.imageView];
}

- (void)updateImage:(UIImage *)image
{
	self.imageView.transform = CGAffineTransformIdentity;
	self.imageView.image = image;

	self.imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);

	self.contentSize = image.size;

	[self updateZoomScale];
	[self centerScrollViewContents];
}

- (void)setupImageScrollView
{
	self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.showsVerticalScrollIndicator = NO;
	self.showsHorizontalScrollIndicator = NO;
	self.bouncesZoom = YES;
	self.decelerationRate = UIScrollViewDecelerationRateFast;
}

- (void)updateZoomScale
{
	if (self.imageView.image) {
		CGRect scrollViewFrame = self.bounds;

		CGFloat scaleWidth = scrollViewFrame.size.width / self.imageView.image.size.width;
		CGFloat scaleHeight = scrollViewFrame.size.height / self.imageView.image.size.height;
		CGFloat minScale = MIN(scaleWidth, scaleHeight);

		self.minimumZoomScale = minScale;
		self.maximumZoomScale = MAX(minScale, self.maximumZoomScale);

		self.zoomScale = self.minimumZoomScale;

		self.panGestureRecognizer.enabled = NO;
	}
}

#pragma mark -

- (void)centerScrollViewContents
{
	CGFloat horizontalInset = 0;
	CGFloat verticalInset = 0;

	if (self.contentSize.width < CGRectGetWidth(self.bounds)) {
		horizontalInset = (CGRectGetWidth(self.bounds) - self.contentSize.width) * 0.5;
	}

	if (self.contentSize.height < CGRectGetHeight(self.bounds)) {
		verticalInset = (CGRectGetHeight(self.bounds) - self.contentSize.height) * 0.5;
	}

	if (self.window.screen.scale < 2.0) {
		horizontalInset = floor(horizontalInset);
		verticalInset = floor(verticalInset);
	}

	self.contentInset = UIEdgeInsetsMake(verticalInset, horizontalInset, verticalInset, horizontalInset);
}

@end
