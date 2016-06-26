//
//  FlickrSearchEngine.h
//  Catawiki
//
//  Created by Michael Smirnov on 25.06.16.
//  Copyright © 2016 Smirnov. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GalleryImage;

@interface FlickrSearchEngine : NSObject

- (void)searchForImagesWithSearchString:(NSString *)searchString
				   page:(NSUInteger)pageNumber
				perPage:(NSUInteger)perPageNumber
		      completionHandler:
			  (void (^)(NSArray<GalleryImage *> *images, NSUInteger total, NSError *error))handler;

@end
