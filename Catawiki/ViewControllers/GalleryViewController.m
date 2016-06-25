//
//  GalleryViewController.m
//  Catawiki
//
//  Created by Michael Smirnov on 25.06.16.
//  Copyright © 2016 Smirnov. All rights reserved.
//

#import "DynamicCollectionViewFlowLayout.h"
#import "GalleryViewController.h"

@interface GalleryViewController () <UICollectionViewDelegateFlowLayout>

@end

@implementation GalleryViewController

static NSString *const reuseIdentifier = @"ImageCell";

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView { return 1; }

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	return 1000;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
		  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	UICollectionViewCell *cell =
	    [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];

	// Configure the cell

	cell.backgroundColor = [UIColor colorWithRed:(CGFloat)(arc4random() % 255) / 255
					       green:(CGFloat)(arc4random() % 255) / 255
						blue:(CGFloat)(arc4random() % 255) / 255
					       alpha:1.0];

	return cell;
}

#pragma mark <UICollectionViewDelegate>

#pragma mark <UICollectionViewDelegateFlowLayout> 



#pragma mark -

@end
