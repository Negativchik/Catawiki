//
//  DynamicCollectionViewFlowLayout.h
//  Catawiki
//
//  Created by Michael Smirnov on 25.06.16.
//  Copyright © 2016 Smirnov. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kScrollResistanceFactorDefault 1200.0f;

@interface DynamicCollectionViewFlowLayout : UICollectionViewFlowLayout

@property (nonatomic, strong) UIDynamicAnimator *dynamicAnimator;
@property (nonatomic, assign) CGFloat scrollResistanceFactor;

@end
