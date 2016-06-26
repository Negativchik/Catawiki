//
//  FlickrSearchEngine.m
//  Catawiki
//
//  Created by Michael Smirnov on 25.06.16.
//  Copyright © 2016 Smirnov. All rights reserved.
//

#import "FlickrSearchEngine.h"
#import "GalleryImage.h"
#import <AFNetworking/AFNetworking.h>
//#import "AFNetworking.h"

@interface FlickrSearchEngine ()

@property (nonatomic, strong) NSOperationQueue *parseQueue;
@property (nonatomic, strong) NSURLSessionDataTask *currentDataTask;
@property (nonatomic, strong) AFHTTPSessionManager *manager;

@end

@implementation FlickrSearchEngine

- (instancetype)init
{
	self = [super init];
	if (self) {
		_parseQueue = [[NSOperationQueue alloc] init];
		_parseQueue.maxConcurrentOperationCount = 1;
        _manager = [AFHTTPSessionManager manager];
	}
	return self;
}

- (void)searchForImagesWithSearchString:(NSString *)searchString
				   page:(NSUInteger)pageNumber
				perPage:(NSUInteger)perPageNumber
		      completionHandler:
			  (void (^)(NSArray<GalleryImage *> *images, NSUInteger total, NSError *error))handler
{
	if (_currentDataTask != nil) {
		[self.currentDataTask cancel];
		_currentDataTask = nil;
	}
	NSDictionary *parameters = @{
		@"method" : @"flickr.photos.search",
		@"api_key" : @"46ca4e6eeacd8cc305db2ec3258a2298",
		@"tags" : searchString,
		@"media" : @"photo",
		@"format" : @"json",
		@"page" : [NSString stringWithFormat:@"%lu", (unsigned long)pageNumber],
		@"per_page" : [NSString stringWithFormat:@"%lu", (unsigned long)perPageNumber],
		@"privacy_filter" : @"1",
		@"extras" : @"url_s, url_o",
		@"nojsoncallback" : @"1"
	};
	NSURLSessionDataTask *dataTask = [self.manager GET:@"https://api.flickr.com/services/rest"
	    parameters:parameters
	    progress:nil
	    success:^(NSURLSessionTask *task, id responseObject) {
		    NSLog(@"JSON: %@", responseObject);
		    if ([responseObject isKindOfClass:[NSDictionary class]]) {
			    NSDictionary *responseDict = responseObject;
			    [self parseResponse:responseDict completionHandler:handler];
		    }
		    else if (handler) {
			    NSError *error =
				[NSError errorWithDomain:@"com.catawiki.unknownResponse" code:-1000 userInfo:nil];
			    handler(nil, 0, error);
		    }
            self.currentDataTask = nil;
	    }
	    failure:^(NSURLSessionTask *operation, NSError *error) {
		    NSLog(@"Error: %@", error);
		    NSLog(@"%@", [operation originalRequest]);
		    handler(nil, 0, error);
            self.currentDataTask = nil;
	    }];
	self.currentDataTask = dataTask;
}

- (void)parseResponse:(NSDictionary *)dictionary
    completionHandler:(void (^)(NSArray<GalleryImage *> *images, NSUInteger total, NSError *error))handler
{
	NSBlockOperation *blockOperation = [[NSBlockOperation alloc] init];
	__weak NSBlockOperation *weakOperation = blockOperation;
	[blockOperation addExecutionBlock:^{
		NSMutableArray<GalleryImage *> *images = [NSMutableArray arrayWithCapacity:0];
		NSUInteger total = 0;

		NSDictionary *photos = dictionary[@"photos"];
		total = [(NSString *)photos[@"total"] integerValue];
		NSArray *photoArray = (NSArray *)photos[@"photo"];
		for (NSDictionary *photo in photoArray) {
			NSString *thumbnailURLString = (NSString *)photo[@"url_s"];
			NSUInteger thumbnailH = [(NSString *)photo[@"height_s"] integerValue];
			NSUInteger thumbnailW = [(NSString *)photo[@"width_s"] integerValue];

			NSString *imageURLString = (NSString *)photo[@"url_o"];
			NSUInteger imageH = [(NSString *)photo[@"height_o"] integerValue];
			NSUInteger imageW = [(NSString *)photo[@"width_o"] integerValue];

			GalleryImage *image =
			    [[GalleryImage alloc] initWithThumbnailString:thumbnailURLString
							    thumbnailSize:CGSizeMake(thumbnailW, thumbnailH)
							   fullImageStrin:imageURLString
							    fullImageSize:CGSizeMake(imageH, imageW)];
			[images addObject:image];

			if (weakOperation.isCancelled) {
				return;
			}
		}

		if (handler) {
			dispatch_async(dispatch_get_main_queue(), ^{
				handler([images copy], total, nil);
			});
		}
	}];
	[self.parseQueue addOperation:blockOperation];
}

- (void)cancel
{
	[self.currentDataTask cancel];
	[self.parseQueue cancelAllOperations];
}

@end
