//
//  GalleryViewController.h
//  Catawiki
//
//  Created by Michael Smirnov on 25.06.16.
//  Copyright © 2016 Smirnov. All rights reserved.
//

#import "GalleryImage.h"
#import <UIKit/UIKit.h>

@protocol GalleryDataSource <NSObject>

- (NSUInteger)numberOfItems;
- (GalleryImage *)imageForItemNumber:(NSUInteger)itemNumber;

@end

@protocol GalleryDelegate <NSObject>

@property (nonatomic) NSUInteger pageSize;
- (void)getMoreImages;

@end

@interface GalleryViewController : UICollectionViewController

@property (nonatomic, strong) id<GalleryDataSource> galleryDataSource;
@property (nonatomic, strong) id<GalleryDelegate> galleryDelegate;

@end
