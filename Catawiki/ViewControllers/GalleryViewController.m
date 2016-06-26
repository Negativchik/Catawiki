//
//  GalleryViewController.m
//  Catawiki
//
//  Created by Michael Smirnov on 25.06.16.
//  Copyright © 2016 Smirnov. All rights reserved.
//

#import "DynamicCollectionViewFlowLayout.h"
#import "FlickrSearchEngine.h"
#import "GalleryImageCollectionViewCell.h"
#import "GalleryViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>

static CGFloat const kCellSpacing = 4.0;
static NSUInteger const kPerPageCount = 31;

@interface GalleryViewController () <UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) NSMutableArray<GalleryImage *> *images;
@property (nonatomic) NSUInteger totalCount;
@property (nonatomic, strong) FlickrSearchEngine *searchEngine;
@property (nonatomic) BOOL loading;

@end

@implementation GalleryViewController

static NSString *const reuseIdentifier = @"ImageCell";

- (FlickrSearchEngine *)searchEngine
{
	if (_searchEngine == nil) {
		_searchEngine = [[FlickrSearchEngine alloc] init];
	}
	return _searchEngine;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	[self reload];
}

- (void)reload
{
	self.loading = YES;
	[self.searchEngine
	    searchForImagesWithSearchString:@"catawiki"
				       page:1
				    perPage:kPerPageCount
			  completionHandler:^(NSArray<GalleryImage *> *images, NSUInteger total, NSError *error) {
				  self.loading = NO;
				  if (error) {
					  return;
				  }
				  self.images = [images mutableCopy];
				  self.totalCount = total;
				  [self.collectionView reloadData];
				  [(DynamicCollectionViewFlowLayout *)self.collectionViewLayout resetLayout];
			  }];
}

- (void)loadMore
{
	if (self.totalCount <= self.images.count || self.loading) {
		return;
	}
	self.loading = YES;
	NSUInteger currentPage = self.images.count / kPerPageCount;
	[self.searchEngine
	    searchForImagesWithSearchString:@"cat"
				       page:++currentPage
				    perPage:kPerPageCount
			  completionHandler:^(NSArray<GalleryImage *> *images, NSUInteger total, NSError *error) {
				  if (error) {
					  return;
				  }
				  if (self.totalCount != total) {
					  // TODO: Handle this situation
				  }

				  [self.images addObjectsFromArray:images];
				  self.totalCount = total;
				  [self.collectionView reloadData];
				  [(DynamicCollectionViewFlowLayout *)self.collectionViewLayout resetLayout];
				  self.loading = NO;
			  }];
}

#pragma mark <UIScrollViewDelegate>

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	NSLog(@"%@", NSStringFromCGPoint(self.collectionView.contentOffset));
	CGSize screenSize = [UIScreen mainScreen].bounds.size;
	if (self.collectionView.contentOffset.y > self.collectionView.contentSize.height - 3 * screenSize.height) {
		[self loadMore];
	}
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
	return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	return self.images.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
		  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	GalleryImageCollectionViewCell *cell =
	    (GalleryImageCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier
											forIndexPath:indexPath];

	cell.backgroundColor = [UIColor colorWithRed:(CGFloat)(arc4random() % 255) / 255
					       green:(CGFloat)(arc4random() % 255) / 255
						blue:(CGFloat)(arc4random() % 255) / 255
					       alpha:1.0];
	cell.layer.zPosition = indexPath.row / 3;

	GalleryImage *image = [self.images objectAtIndex:indexPath.row];
	[cell.imageView
	    sd_setImageWithURL:image.thumbnailURL
	      placeholderImage:nil
		     completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
			     [UIView animateWithDuration:0.2
					      animations:^{
						      cell.imageView.alpha = 1.0;
					      }];
		     }];

	return cell;
}

#pragma mark <UICollectionViewDelegate>

#pragma mark <UICollectionViewDelegateFlowLayout>

- (CGSize)collectionView:(UICollectionView *)collectionView
		  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
	GalleryImage *image = self.images[indexPath.row];
	CGSize size = image.thumbnailSize;
	CGFloat ar = size.height / size.width;

	NSUInteger row = indexPath.item / 3;

	if (row == self.images.count / 3 && self.images.count % 3 != 0) {
		CGFloat w = floor(([UIScreen mainScreen].bounds.size.width - 3 * kCellSpacing) / 2);
		CGFloat h = floor(ar * w);
		return CGSizeMake(w, h);
	}
	CGSize size1 = [(GalleryImage *)self.images[row * 3] thumbnailSize];
	CGSize size2 = [(GalleryImage *)self.images[row * 3 + 1] thumbnailSize];
	CGSize size3 = [(GalleryImage *)self.images[row * 3 + 2] thumbnailSize];

	CGFloat ar1 = size1.height / size1.width;
	CGFloat ar2 = size2.height / size2.width;
	CGFloat ar3 = size3.height / size3.width;

	CGFloat h = ([UIScreen mainScreen].bounds.size.width - 4 * kCellSpacing) * ar1 * ar2 * ar3 /
		    (ar2 * ar3 + ar1 * ar3 + ar1 * ar2);

	return CGSizeMake(floor(h / ar), floor(h));
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
				      layout:(UICollectionViewLayout *)collectionViewLayout
    minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
	return kCellSpacing;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
				 layout:(UICollectionViewLayout *)collectionViewLayout
    minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
	return kCellSpacing;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
			layout:(UICollectionViewLayout *)collectionViewLayout
	insetForSectionAtIndex:(NSInteger)section
{
	return UIEdgeInsetsMake(kCellSpacing, kCellSpacing, kCellSpacing, kCellSpacing);
}

@end
