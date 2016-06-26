//
//  ImageViewController.m
//  Catawiki
//
//  Created by Michael Smirnov on 26.06.16.
//  Copyright © 2016 Smirnov. All rights reserved.
//

#import "GalleryImage.h"
#import "ImageScrollView.h"
#import "ImageViewController.h"
#import <SDWebImage/SDWebImageManager.h>

@interface ImageViewController () <UIScrollViewDelegate>

- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

@property (nonatomic, readonly) ImageScrollView *imageScrollView;
@property (nonatomic) id<GalleryImage> image;
@property (nonatomic) UITapGestureRecognizer *doubleTapGestureRecognizer;

@end

@implementation ImageViewController

- (void)dealloc
{
	_imageScrollView.delegate = nil;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	return [self initWithImage:nil];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];

	if (self) {
		[self commonInitWithImage:nil];
	}

	return self;
}

- (instancetype)initWithImage:(id<GalleryImage>)image
{
	self = [super initWithNibName:nil bundle:nil];

	if (self) {
		[self commonInitWithImage:image];
	}

	return self;
}

- (void)commonInitWithImage:(id<GalleryImage>)image
{
	_image = image;

	_imageScrollView = [[ImageScrollView alloc] initWithFrame:CGRectZero];
	_imageScrollView.delegate = self;

	[self setupGestureRecognizer];

	if ([[SDWebImageManager sharedManager] cachedImageExistsForURL:image.fullImageURL]) {
		UIImage *fullImage;
		NSString *key = [[SDWebImageManager sharedManager] cacheKeyForURL:image.fullImageURL];
		fullImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:key];

		[_imageScrollView updateImage:fullImage];
        
        return;
	}
	else if ([[SDWebImageManager sharedManager] cachedImageExistsForURL:image.thumbnailURL]) {
		UIImage *thumbnail;
		NSString *key = [[SDWebImageManager sharedManager] cacheKeyForURL:image.thumbnailURL];
		thumbnail = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:key];

		[_imageScrollView updateImage:thumbnail];
	}
	[[SDWebImageManager sharedManager]
	    downloadImageWithURL:image.fullImageURL
			 options:SDWebImageRetryFailed
			progress:nil
		       completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished,
				   NSURL *imageURL) {

			       [self.imageScrollView updateImage:image];
		       }];
}

- (void)viewDidLoad
{
	[super viewDidLoad];

	self.imageScrollView.frame = self.view.bounds;
	[self.view addSubview:self.imageScrollView];

	[self.view addGestureRecognizer:self.doubleTapGestureRecognizer];
}

- (void)viewWillLayoutSubviews
{
	[super viewWillLayoutSubviews];

	self.imageScrollView.frame = self.view.bounds;
}

- (void)updateImage:(UIImage *)image
{
	[self.imageScrollView updateImage:image];
}

#pragma mark UIGestureRecognizer

- (void)setupGestureRecognizer
{
	self.doubleTapGestureRecognizer =
	    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didDoubleTapWithGestureRecognizer:)];
	self.doubleTapGestureRecognizer.numberOfTapsRequired = 2;
}

- (void)didDoubleTapWithGestureRecognizer:(UITapGestureRecognizer *)recognizer
{
	CGPoint pointInView = [recognizer locationInView:self.imageScrollView.imageView];

	CGFloat newZoomScale = self.imageScrollView.maximumZoomScale;

	if (self.imageScrollView.zoomScale >= self.imageScrollView.maximumZoomScale ||
	    ABS(self.imageScrollView.zoomScale - self.imageScrollView.maximumZoomScale) <= 0.01) {
		newZoomScale = self.imageScrollView.minimumZoomScale;
	}

	CGSize scrollViewSize = self.imageScrollView.bounds.size;

	CGFloat width = scrollViewSize.width / newZoomScale;
	CGFloat height = scrollViewSize.height / newZoomScale;
	CGFloat originX = pointInView.x - (width / 2.0);
	CGFloat originY = pointInView.y - (height / 2.0);

	CGRect rectToZoomTo = CGRectMake(originX, originY, width, height);

	[self.imageScrollView zoomToRect:rectToZoomTo animated:YES];
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
	return self.imageScrollView.imageView;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
{
	scrollView.panGestureRecognizer.enabled = YES;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
	// There is a bug, especially prevalent on iPhone 6 Plus, that causes zooming to render all other
	// gesture
	// recognizers ineffective.
	// This bug is fixed by disabling the pan gesture recognizer of the scroll view when it is not needed.
	if (scrollView.zoomScale == scrollView.minimumZoomScale) {
		scrollView.panGestureRecognizer.enabled = NO;
	}
}

@end
