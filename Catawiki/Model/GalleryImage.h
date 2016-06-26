//
//  GalleryImage.h
//  Catawiki
//
//  Created by Michael Smirnov on 25.06.16.
//  Copyright © 2016 Smirnov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GalleryImage : NSObject

@property (nonatomic, strong) NSURL *thumbnailURL;
@property (nonatomic) CGSize thumbnailSize;
@property (nonatomic, strong) NSURL *fullImageURL;
@property (nonatomic) CGSize fullImageSize;

- (instancetype)initWithThumbnailString:(NSString *)thumbnailString
			  thumbnailSize:(CGSize)thumbnailSize
			 fullImageStrin:(NSString *)fullImageString
			  fullImageSize:(CGSize)fullImageSize;

@end
