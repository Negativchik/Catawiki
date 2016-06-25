//
//  DynamicCollectionViewFlowLayout.m
//  Catawiki
//
//  Created by Michael Smirnov on 25.06.16.
//  Copyright © 2016 Smirnov. All rights reserved.
//

#import "DynamicCollectionViewFlowLayout.h"

@interface DynamicCollectionViewFlowLayout ()

@property (nonatomic, assign) CGFloat latestDelta;
@property (nonatomic, strong) NSMutableSet *visibleIndexPathsSet;

@end

@implementation DynamicCollectionViewFlowLayout

#pragma mark Initialization

- (instancetype)init
{
	self = [super init];
	if (self) {
		[self commonInit];
	}
	return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
	self = [super initWithCoder:coder];
	if (self) {
		[self commonInit];
	}
	return self;
}

- (void)commonInit
{
	self.minimumInteritemSpacing = 10;
	self.minimumLineSpacing = 10;
	self.itemSize = CGSizeMake(110, 110);
	self.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);

	self.dynamicAnimator = [[UIDynamicAnimator alloc] initWithCollectionViewLayout:self];
	_visibleIndexPathsSet = [NSMutableSet set];
}

#pragma mark -

- (void)prepareLayout
{
	[super prepareLayout];

	// Need to overflow our actual visible rect slightly to avoid flickering.
	CGRect visibleRect = CGRectInset(
	    (CGRect){.origin = self.collectionView.bounds.origin, .size = self.collectionView.frame.size}, -100, -100);

	NSArray *itemsInVisibleRectArray = [super layoutAttributesForElementsInRect:visibleRect];

	NSSet *itemsIndexPathsInVisibleRectSet =
	    [NSSet setWithArray:[itemsInVisibleRectArray valueForKey:@"indexPath"]];

	// Step 1: Remove any behaviours that are no longer visible.
	NSArray *noLongerVisibleBehaviours = [self.dynamicAnimator.behaviors
	    filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(UIAttachmentBehavior *behaviour,
									      NSDictionary *bindings) {
	      return [itemsIndexPathsInVisibleRectSet
			 containsObject:[(UICollectionViewLayoutAttributes *)[[behaviour items] firstObject]
					    indexPath]] == NO;
	    }]];

	[noLongerVisibleBehaviours enumerateObjectsUsingBlock:^(id obj, NSUInteger index, BOOL *stop) {
	  [self.dynamicAnimator removeBehavior:obj];
	  [self.visibleIndexPathsSet
	      removeObject:[(UICollectionViewLayoutAttributes *)[[obj items] firstObject] indexPath]];
	}];

	// Step 2: Add any newly visible behaviours.
	// A "newly visible" item is one that is in the itemsInVisibleRect(Set|Array)
	// but not in the visibleIndexPathsSet
	NSArray *newlyVisibleItems = [itemsInVisibleRectArray
	    filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(UICollectionViewLayoutAttributes *item,
									      NSDictionary *bindings) {
	      return [self.visibleIndexPathsSet containsObject:item.indexPath] == NO;
	    }]];

	CGPoint touchLocation = [self.collectionView.panGestureRecognizer locationInView:self.collectionView];

	[newlyVisibleItems
	    enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes *item, NSUInteger idx, BOOL *stop) {
	      CGPoint center = item.center;
	      UIAttachmentBehavior *springBehaviour =
		  [[UIAttachmentBehavior alloc] initWithItem:item attachedToAnchor:center];

	      springBehaviour.length = 1.0f;
	      springBehaviour.damping = 0.8f;
	      springBehaviour.frequency = 1.0f;

	      // If our touchLocation is not (0,0), we'll need to adjust our item's center
	      // "in flight"
	      if (!CGPointEqualToPoint(CGPointZero, touchLocation)) {
		      if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
			      CGFloat distanceFromTouch = fabs(touchLocation.y - springBehaviour.anchorPoint.y);

			      CGFloat scrollResistance;
			      if (self.scrollResistanceFactor)
				      scrollResistance = distanceFromTouch / self.scrollResistanceFactor;
			      else
				      scrollResistance = distanceFromTouch / kScrollResistanceFactorDefault;

			      if (self.latestDelta < 0)
				      center.y += MAX(self.latestDelta, self.latestDelta * scrollResistance);
			      else
				      center.y += MIN(self.latestDelta, self.latestDelta * scrollResistance);

			      item.center = center;
		      }
		      else {
			      CGFloat distanceFromTouch = fabs(touchLocation.x - springBehaviour.anchorPoint.x);

			      CGFloat scrollResistance;
			      if (self.scrollResistanceFactor)
				      scrollResistance = distanceFromTouch / self.scrollResistanceFactor;
			      else
				      scrollResistance = distanceFromTouch / kScrollResistanceFactorDefault;

			      if (self.latestDelta < 0)
				      center.x += MAX(self.latestDelta, self.latestDelta * scrollResistance);
			      else
				      center.x += MIN(self.latestDelta, self.latestDelta * scrollResistance);

			      item.center = center;
		      }
	      }

	      [self.dynamicAnimator addBehavior:springBehaviour];
	      if (item.representedElementCategory == UICollectionElementCategoryCell) {
		      [self.visibleIndexPathsSet addObject:item.indexPath];
	      }
	    }];
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect { return [self.dynamicAnimator itemsInRect:rect]; }

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
	UICollectionViewLayoutAttributes *dynamicLayoutAttributes =
	    [self.dynamicAnimator layoutAttributesForCellAtIndexPath:indexPath];
	return (dynamicLayoutAttributes) ? dynamicLayoutAttributes
					 : [super layoutAttributesForItemAtIndexPath:indexPath];
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
	UIScrollView *scrollView = self.collectionView;

	CGFloat delta;
	if (self.scrollDirection == UICollectionViewScrollDirectionVertical)
		delta = newBounds.origin.y - scrollView.bounds.origin.y;
	else
		delta = newBounds.origin.x - scrollView.bounds.origin.x;

	self.latestDelta = delta;

	CGPoint touchLocation = [self.collectionView.panGestureRecognizer locationInView:self.collectionView];

	[self.dynamicAnimator.behaviors
	    enumerateObjectsUsingBlock:^(UIAttachmentBehavior *springBehaviour, NSUInteger idx, BOOL *stop) {
	      if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
		      CGFloat distanceFromTouch = fabs(touchLocation.y - springBehaviour.anchorPoint.y);

		      CGFloat scrollResistance;
		      if (self.scrollResistanceFactor)
			      scrollResistance = distanceFromTouch / self.scrollResistanceFactor;
		      else
			      scrollResistance = distanceFromTouch / kScrollResistanceFactorDefault;

		      UICollectionViewLayoutAttributes *item =
			  (UICollectionViewLayoutAttributes *)[springBehaviour.items firstObject];
		      CGPoint center = item.center;
		      if (delta < 0)
			      center.y += MAX(delta, delta * scrollResistance);
		      else
			      center.y += MIN(delta, delta * scrollResistance);

		      item.center = center;

		      [self.dynamicAnimator updateItemUsingCurrentState:item];
	      }
	      else {
		      CGFloat distanceFromTouch = fabs(touchLocation.x - springBehaviour.anchorPoint.x);

		      CGFloat scrollResistance;
		      if (self.scrollResistanceFactor)
			      scrollResistance = distanceFromTouch / self.scrollResistanceFactor;
		      else
			      scrollResistance = distanceFromTouch / kScrollResistanceFactorDefault;

		      UICollectionViewLayoutAttributes *item =
			  (UICollectionViewLayoutAttributes *)[springBehaviour.items firstObject];
		      CGPoint center = item.center;
		      if (delta < 0)
			      center.x += MAX(delta, delta * scrollResistance);
		      else
			      center.x += MIN(delta, delta * scrollResistance);

		      item.center = center;

		      [self.dynamicAnimator updateItemUsingCurrentState:item];
	      }
	    }];

	return NO;
}

- (void)prepareForCollectionViewUpdates:(NSArray *)updateItems
{
	[super prepareForCollectionViewUpdates:updateItems];

	[updateItems enumerateObjectsUsingBlock:^(UICollectionViewUpdateItem *updateItem, NSUInteger idx, BOOL *stop) {
	  if (updateItem.updateAction == UICollectionUpdateActionInsert) {
		  if ([self.dynamicAnimator layoutAttributesForCellAtIndexPath:updateItem.indexPathAfterUpdate]) {
			  return;
		  }

		  UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes
		      layoutAttributesForCellWithIndexPath:updateItem.indexPathAfterUpdate];

		  // attributes.frame = CGRectMake(10, updateItem.indexPathAfterUpdate.item
		  // * 310, 300, 44); // or some other initial frame

		  UIAttachmentBehavior *springBehaviour =
		      [[UIAttachmentBehavior alloc] initWithItem:attributes attachedToAnchor:attributes.center];

		  springBehaviour.length = 1.0f;
		  springBehaviour.damping = 0.8f;
		  springBehaviour.frequency = 1.0f;
		  [self.dynamicAnimator addBehavior:springBehaviour];
	  }
	}];
}

@end
