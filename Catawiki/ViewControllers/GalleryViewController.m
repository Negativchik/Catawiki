//
//  GalleryViewController.m
//  Catawiki
//
//  Created by Michael Smirnov on 25.06.16.
//  Copyright © 2016 Smirnov. All rights reserved.
//

#import "DynamicCollectionViewFlowLayout.h"
#import "GalleryViewController.h"

static CGFloat const kCellSpacing = 4.0;

@interface GalleryViewController () <UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) NSMutableArray *sizes;

@end

@implementation GalleryViewController

static NSString *const reuseIdentifier = @"ImageCell";

- (void)viewDidLoad
{
	[super viewDidLoad];

	_sizes = [NSMutableArray arrayWithCapacity:1000];
	for (int i = 0; i < 1000; i++) {
		CGFloat w = ((arc4random() % 250 + 250) / 2) * 2;
		CGFloat h = ((arc4random() % 250 + 250) / 2) * 2;
		[_sizes addObject:[NSValue valueWithCGSize:CGSizeMake(w, h)]];
	}
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
	return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	return 1000;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
		  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	UICollectionViewCell *cell =
	    [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];

	cell.backgroundColor = [UIColor colorWithRed:(CGFloat)(arc4random() % 255) / 255
					       green:(CGFloat)(arc4random() % 255) / 255
						blue:(CGFloat)(arc4random() % 255) / 255
					       alpha:1.0];

	cell.layer.zPosition = indexPath.row / 3;
	cell.layer.cornerRadius = 2.0;
	cell.layer.borderColor = [UIColor whiteColor].CGColor;
	cell.layer.borderWidth = 1.0;

	return cell;
}

#pragma mark <UICollectionViewDelegate>

#pragma mark <UICollectionViewDelegateFlowLayout>

- (CGSize)collectionView:(UICollectionView *)collectionView
		  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
	CGSize size = [(NSValue *)[_sizes objectAtIndex:indexPath.item] CGSizeValue];
	CGFloat ar = size.height / size.width;

	NSUInteger row = indexPath.item / 3;

	if (row == _sizes.count / 3 && _sizes.count % 3 != 0) {
        CGFloat w = floor(([UIScreen mainScreen].bounds.size.width - 3 * kCellSpacing) / 2);
        CGFloat h = floor(ar * w);
        return CGSizeMake(w, h);
	}
	CGSize size1 = [(NSValue *)[_sizes objectAtIndex:row * 3] CGSizeValue];
	CGSize size2 = [(NSValue *)[_sizes objectAtIndex:row * 3 + 1] CGSizeValue];
	CGSize size3 = [(NSValue *)[_sizes objectAtIndex:row * 3 + 2] CGSizeValue];

	CGFloat ar1 = size1.height / size1.width;
	CGFloat ar2 = size2.height / size2.width;
	CGFloat ar3 = size3.height / size3.width;

	CGFloat h =
	    ([UIScreen mainScreen].bounds.size.width - 4 * kCellSpacing) * ar1 * ar2 * ar3 / (ar2 * ar3 + ar1 * ar3 + ar1 * ar2);

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

#pragma mark -

@end
