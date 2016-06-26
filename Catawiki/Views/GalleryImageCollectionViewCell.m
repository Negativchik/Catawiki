//
//  GalleryImageCollectionViewCell.m
//  Catawiki
//
//  Created by Michael Smirnov on 26.06.16.
//  Copyright © 2016 Smirnov. All rights reserved.
//

#import "GalleryImageCollectionViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation GalleryImageCollectionViewCell

- (void)prepareForReuse
{
	[super prepareForReuse];
	[self.imageView sd_cancelCurrentImageLoad];
}

@end
