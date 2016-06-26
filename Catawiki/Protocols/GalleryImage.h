//
//  GalleryImage.h
//  Catawiki
//
//  Created by Michael Smirnov on 26.06.16.
//  Copyright © 2016 Smirnov. All rights reserved.
//

@import UIKit;

@protocol GalleryImage <NSObject>

@property (nonatomic, readonly, nullable) NSURL *thumbnailURL;
@property (nonatomic, readonly) CGSize thumbnailSize;
@property (nonatomic, readonly, nullable) NSURL *fullImageURL;
@property (nonatomic, readonly) CGSize fullImageSize;

@end
