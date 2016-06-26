//
//  GalleryImage.m
//  Catawiki
//
//  Created by Michael Smirnov on 25.06.16.
//  Copyright © 2016 Smirnov. All rights reserved.
//

#import "FlickrImage.h"

@implementation FlickrImage

- (instancetype)initWithThumbnailString:(NSString *)thumbnailString
			  thumbnailSize:(CGSize)thumbnailSize
			 fullImageStrin:(NSString *)fullImageString
			  fullImageSize:(CGSize)fullImageSize
{
	self = [super init];
	if (self) {
		_thumbnailURL = [NSURL URLWithString:thumbnailString];
		_thumbnailSize = thumbnailSize;
		_fullImageURL = [NSURL URLWithString:fullImageString];
		_fullImageSize = fullImageSize;
	}
	return self;
}

@end
