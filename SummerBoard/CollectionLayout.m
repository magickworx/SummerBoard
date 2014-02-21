/*****************************************************************************
 *
 * FILE:	CollectionLayout.m
 * DESCRIPTION:	SummerBoard: UICollectionViewFlowLayout Subclass
 * DATE:	Tue, Aug 20 2013
 * UPDATED:	Fri, Feb 21 2014
 * AUTHOR:	Kouichi ABE (WALL) / 阿部康一
 * E-MAIL:	kouichi@MagickWorX.COM
 * URL:		http://www.MagickWorX.COM/
 * COPYRIGHT:	(c) 2013-2014 阿部康一／Kouichi ABE (WALL), All rights reserved.
 * LICENSE:
 *
 *  Copyright (c) 2013-2014 Kouichi ABE (WALL) <kouichi@MagickWorX.COM>,
 *  All rights reserved.
 *
 *  Redistribution and use in source and binary forms, with or without
 *  modification, are permitted provided that the following conditions
 *  are met:
 *
 *   1. Redistributions of source code must retain the above copyright
 *      notice, this list of conditions and the following disclaimer.
 *
 *   2. Redistributions in binary form must reproduce the above copyright
 *      notice, this list of conditions and the following disclaimer in the
 *      documentation and/or other materials provided with the distribution.
 *
 *   THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
 *   ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 *   THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 *   PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE
 *   LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 *   CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 *   SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 *   INTERRUPTION)  HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 *   CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 *   ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
 *   THE POSSIBILITY OF SUCH DAMAGE.
 *
 * $Id: CollectionView.m,v 1.2 2013/01/22 15:23:51 kouichi Exp $
 *
 *****************************************************************************/

@import QuartzCore;

#import <objc/runtime.h>
#import "CollectionLayout.h"
#import "CollectionCell.h"

static NSString * const	kCollectionViewKeyPath = @"collectionView";

#ifndef	CGGEOMETRY_EXTENSIONS
#define	CGGEOMETRY_EXTENSIONS	1
CG_INLINE CGPoint
CGPointAdd(CGPoint point1, CGPoint point2) {
  return CGPointMake(point1.x + point2.x, point1.y + point2.y);
}
#endif	// CGGEOMETRY_EXTENSIONS

static NSString * const	kScrollingDirectionKey = @"ScrollingDirectionKey";

typedef NS_ENUM(NSInteger, kScrollingDirection) {
  kScrollingDirectionUnknown = 0,
  kScrollingDirectionUp,
  kScrollingDirectionDown,
  kScrollingDirectionLeft,
  kScrollingDirectionRight
};

#define	kFramePerSecond	60.0f

// カテゴリに独自のメンバ変数を持つ
@interface CADisplayLink (Extension_userInfo)
@property (nonatomic,copy) NSDictionary *	userInfo;
@end

// カテゴリに独自のメンバ変数を持つ実装方法
@implementation CADisplayLink (Extension_userInfo)
-(void)setUserInfo:(NSDictionary *)userInfo
{
  objc_setAssociatedObject(self, "userInfo", userInfo, OBJC_ASSOCIATION_COPY);
}

-(NSDictionary *)userInfo
{
  return objc_getAssociatedObject(self, "userInfo");
}
@end


@interface CollectionLayout () <UIGestureRecognizerDelegate>
@property (nonatomic,strong) CADisplayLink *	displayLink;
@property (nonatomic,assign) CGFloat		scrollingSpeed;
@property (nonatomic,assign) UIEdgeInsets	scrollingTriggerEdgeInsets;
@property (nonatomic,strong) NSIndexPath *	selectedIndexPath;
@property (nonatomic,strong) NSIndexPath *	fromIndexPath;
@property (nonatomic,strong) NSIndexPath *	toIndexPath;
@property (nonatomic,strong) UIImageView *	mockView;
@property (nonatomic,assign) CGPoint		mockViewCenter;
@property (nonatomic,assign) CGPoint		panTranslation;
@property (nonatomic,strong) UILongPressGestureRecognizer *	longPressGestureRecognizer;
@property (nonatomic,strong) UITapGestureRecognizer *	tapGestureRecognizer;
@property (nonatomic,strong) UIPanGestureRecognizer *	panGestureRecognizer;
@property (nonatomic,getter=isEditing) BOOL	editing;
@end

@implementation CollectionLayout

-(id)init
{
  self = [super init];
  if (self) {
    _scrollingSpeed = 300.0f;
    _scrollingTriggerEdgeInsets = UIEdgeInsetsMake(50.0f, 50.0f, 50.0f, 50.0f);

    _editing = NO;

    /*
     * XXX:
     * init 段階では collectionView が設定されていない。
     * そのため、KVC で新規設定を監視する。
     */
    [self addObserver:self
	  forKeyPath:kCollectionViewKeyPath
	  options:NSKeyValueObservingOptionNew
	  context:nil];
  }
  return self;
}

-(void)dealloc
{
  [self invalidateScrollTimer];

  [self removeObserver:self forKeyPath:kCollectionViewKeyPath];
}

#pragma mark UICollectionViewLayout override
/*
 * The collection view calls -prepareLayout once at its first layout
 * as the first message to the layout instance.
 * The collection view calls -prepareLayout again after layout is invalidated
 * and before requerying the layout information.
 * Subclasses should always call super if they override.
 */
-(void)prepareLayout
{
  [super prepareLayout];
}

#if	0
#pragma mark UICollectionViewLayout override
/*
 * Subclasses must override this method and use it to return the width and
 * height of the collection view’s content. These values represent the width
 * and height of all the content, not just the content that is currently
 * visible. The collection view uses this information to configure its own
 * content size to facilitate scrolling.
 */
-(CGSize)collectionViewContentSize
{
  return [self collectionView].frame.size;
}
#endif

-(void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes
{
  switch (layoutAttributes.representedElementCategory) {
    case UICollectionElementCategoryCell:
      if ([layoutAttributes.indexPath isEqual:self.selectedIndexPath]) {
	layoutAttributes.hidden = YES;
      }
      break;
    case UICollectionElementCategorySupplementaryView:
      break;
    case UICollectionElementCategoryDecorationView:
      break;
  }
}

#pragma mark UICollectionViewLayout override
// return an array layout attributes instances for all the views in the given rect
-(NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
  NSArray * layoutAttributes = [super layoutAttributesForElementsInRect:rect];

  for (UICollectionViewLayoutAttributes * attrs in layoutAttributes) {
    [self applyLayoutAttributes:attrs];
  }

  return layoutAttributes;
}

#pragma mark UICollectionViewLayout override
-(UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
  UICollectionViewLayoutAttributes *	layoutAttributes = [super layoutAttributesForItemAtIndexPath:indexPath];

  [self applyLayoutAttributes:layoutAttributes];

  return layoutAttributes;
}

/*****************************************************************************/

#pragma mark Key-Value Observing methods
-(void)observeValueForKeyPath:(NSString *)keyPath
	ofObject:(id)object
	change:(NSDictionary *)change
	context:(void *)context
{
  if ([keyPath isEqualToString:kCollectionViewKeyPath]) {
    if (self.collectionView != nil) {
      [self addGestureRecognizers];
    }
    else {
      [self invalidateScrollTimer];
    }
  }
}

/*****************************************************************************/

-(void)invalidateScrollTimer
{
  if (!self.displayLink.isPaused) {
    [self.displayLink invalidate];
  }
  self.displayLink = nil;
}

-(void)setupScrollTimerInDirection:(kScrollingDirection)direction
{
  if (!self.displayLink.isPaused) {
    kScrollingDirection	oldDirection = [self.displayLink.userInfo[kScrollingDirectionKey] integerValue];
    if (direction == oldDirection) {
      return;
    }
  }

  [self invalidateScrollTimer];

  self.displayLink = [CADisplayLink displayLinkWithTarget:self
				    selector:@selector(handleScroll:)];
  self.displayLink.userInfo = @{ kScrollingDirectionKey : @(direction) };

  [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop]
		    forMode:NSRunLoopCommonModes];
}

#pragma mark CADisplayLink action
-(void)handleScroll:(CADisplayLink *)displayLink
{
  kScrollingDirection	direction = (kScrollingDirection)[displayLink.userInfo[kScrollingDirectionKey] integerValue];
  if (direction == kScrollingDirectionUnknown) {
    return;
  }

  CGSize  frameSize	= self.collectionView.bounds.size;
  CGSize  contentSize	= self.collectionView.contentSize;
  CGPoint contentOffset	= self.collectionView.contentOffset;
  CGFloat distance	= self.scrollingSpeed / kFramePerSecond;
  CGPoint translation	= CGPointZero;

  switch (direction) {
    case kScrollingDirectionUp: {
	distance = -distance;
	CGFloat	minY = 0.0f;
	if ((contentOffset.y + distance) <= minY) {
	  distance = -contentOffset.y;
	}
	translation = CGPointMake(0.0f, distance);
      }
      break;
    case kScrollingDirectionDown: {
	CGFloat	maxY = MAX(contentSize.height, frameSize.height) - frameSize.height;
	if ((contentOffset.y + distance) >= maxY) {
	  distance = maxY - contentOffset.y;
	}
	translation = CGPointMake(0.0f, distance);
      }
      break;
    case kScrollingDirectionLeft: {
	distance = -distance;
	CGFloat	minX = 0.0f;
	if ((contentOffset.x + distance) <= minX) {
	  distance = -contentOffset.x;
	}
	translation = CGPointMake(distance, 0.0f);
      }
      break;
    case kScrollingDirectionRight: {
	CGFloat	maxX = MAX(contentSize.width, frameSize.width) - frameSize.width;
	if ((contentOffset.x + distance) >= maxX) {
	  distance = maxX - contentOffset.x;
	}
	translation = CGPointMake(distance, 0.0f);
      }
      break;
    default:
      break;
  }

  self.mockViewCenter  = CGPointAdd(self.mockViewCenter, translation);
  self.mockView.center = CGPointAdd(self.mockViewCenter, self.panTranslation);
  self.collectionView.contentOffset = CGPointAdd(contentOffset, translation);
}

-(void)validateScrollTimer
{
  CGRect  bounds     = self.collectionView.bounds;
  CGPoint viewCenter = self.mockView.center;

  switch (self.scrollDirection) {
    case UICollectionViewScrollDirectionVertical:
      if (viewCenter.y < (CGRectGetMinY(bounds) + self.scrollingTriggerEdgeInsets.top)) {
	[self setupScrollTimerInDirection:kScrollingDirectionUp];
      }
      else if (viewCenter.y > (CGRectGetMaxY(bounds) - self.scrollingTriggerEdgeInsets.bottom)) {
	[self setupScrollTimerInDirection:kScrollingDirectionDown];
      }
      else {
	[self invalidateScrollTimer];
      }
      break;
    case UICollectionViewScrollDirectionHorizontal:
      if (viewCenter.x < (CGRectGetMinX(bounds) + self.scrollingTriggerEdgeInsets.left)) {
	[self setupScrollTimerInDirection:kScrollingDirectionLeft];
      }
      else if (viewCenter.x > (CGRectGetMaxX(bounds) - self.scrollingTriggerEdgeInsets.right)) {
	[self setupScrollTimerInDirection:kScrollingDirectionRight];
      }
      else {
	[self invalidateScrollTimer];
      }
      break;
  }
}

/*****************************************************************************/

-(void)prepareForMovingItemAtPoint:(CGPoint)point
{
  NSIndexPath * indexPath = [self.collectionView indexPathForItemAtPoint:point];
  self.selectedIndexPath  = indexPath;
  self.toIndexPath	  = indexPath;
  self.fromIndexPath	  = indexPath;

  CollectionCell * cell = (CollectionCell *)[self.collectionView cellForItemAtIndexPath:indexPath];

  // ドラッグ時のダミー画像を作成
  UIImageView * imageView;
  imageView = [[UIImageView alloc] initWithImage:[cell rasterizedImage]];
  imageView.frame = cell.frame;
  imageView.alpha = 0.0f;
  [self.collectionView addSubview:imageView];
  self.mockView	  = imageView;

  self.mockViewCenter = self.mockView.center;

  __block typeof(self) weakSelf = self;
  void (^animationsBlock)(void) = ^{
    weakSelf.mockView.transform = CGAffineTransformMakeScale(1.1f, 1.1f);
    imageView.alpha = 1.0f;
  };
  void (^completionBlock)(BOOL) = ^(BOOL finished) {
  };
  [UIView animateWithDuration:0.3f
	  delay:0.0f
	  options:UIViewAnimationOptionBeginFromCurrentState
	  animations:animationsBlock
	  completion:completionBlock];
}

-(void)moveItem
{
  NSIndexPath * newIndexPath = [self.collectionView indexPathForItemAtPoint:self.mockView.center];
  self.toIndexPath   = newIndexPath;
  self.fromIndexPath = self.selectedIndexPath;

  if ((newIndexPath == nil) || [newIndexPath isEqual:self.fromIndexPath]) {
    return;
  }

  self.selectedIndexPath = newIndexPath;

  if (_moveHandler) {
    _moveHandler(self.fromIndexPath, self.toIndexPath);
  }
}

-(void)finishMovingItem
{
  UICollectionViewLayoutAttributes *	layoutAttributes = [self layoutAttributesForItemAtIndexPath:self.selectedIndexPath];

  if (_endHandler) {
    NSIndexPath * indexPath = self.toIndexPath;
    if (indexPath != nil) {
      _endHandler(indexPath);
    }
  }

  __block typeof(self) weakSelf = self;
  void (^animationsBlock)(void) = ^{
    weakSelf.mockView.transform	= CGAffineTransformMakeScale(1.0f, 1.0f);
    weakSelf.mockView.center	= layoutAttributes.center;
  };
  void (^completionBlock)(BOOL) = ^(BOOL finished) {
    weakSelf.selectedIndexPath	= nil;
    weakSelf.fromIndexPath	= nil;
    weakSelf.toIndexPath	= nil;
    weakSelf.mockViewCenter	= CGPointZero;

    [weakSelf.mockView removeFromSuperview];
    weakSelf.mockView = nil;

    [weakSelf invalidateLayout];
  };
  [UIView animateWithDuration:0.3f
	  delay:0.0f
	  options:UIViewAnimationOptionBeginFromCurrentState
	  animations:animationsBlock
	  completion:completionBlock];
}

/*****************************************************************************/

-(void)addGestureRecognizers
{
  NSArray *	recognizers = [self.collectionView gestureRecognizers];

  UILongPressGestureRecognizer *	longPressGestureRecognizer;
  longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc]
				initWithTarget:self
				action:@selector(handleLongPress:)];
  [longPressGestureRecognizer setDelegate:self];
  for (UIGestureRecognizer * recognizer in recognizers) {
    if ([recognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
    }
    [recognizer requireGestureRecognizerToFail:longPressGestureRecognizer];
  }
  [self.collectionView addGestureRecognizer:longPressGestureRecognizer];
  self.longPressGestureRecognizer = longPressGestureRecognizer;


  UITapGestureRecognizer *	tapGestureRecognizer;
  tapGestureRecognizer = [[UITapGestureRecognizer alloc]
			  initWithTarget:self
			  action:@selector(handleTapGesture:)];
  [tapGestureRecognizer setNumberOfTapsRequired:1];
  [tapGestureRecognizer setDelegate:self];
  for (UIGestureRecognizer * recognizer in recognizers) {
    if ([recognizer isKindOfClass:[UITapGestureRecognizer class]]) {
      [recognizer requireGestureRecognizerToFail:tapGestureRecognizer];
    }
  }
  [self.collectionView addGestureRecognizer:tapGestureRecognizer];
  self.tapGestureRecognizer = tapGestureRecognizer;


  UIPanGestureRecognizer *	panGestureRecognizer;
  panGestureRecognizer = [[UIPanGestureRecognizer alloc]
				initWithTarget:self
				action:@selector(handlePanGesture:)];
  [panGestureRecognizer setDelegate:self];
  [self.collectionView addGestureRecognizer:panGestureRecognizer];
  self.panGestureRecognizer = panGestureRecognizer;
}

#pragma mark UILongPressGestureRecognizer handler
-(void)handleLongPress:(UILongPressGestureRecognizer *)gesture
{
  UIGestureRecognizerState	 state = [gesture state];

  if (_holdHandler) {
    _holdHandler(state);
  }

  switch (state) {
    case UIGestureRecognizerStateBegan:
      self.editing = YES;
      break;
    case UIGestureRecognizerStateCancelled:
      self.editing = NO;
      break;
    default:
      break;
  }
}

#pragma mark UITapGestureRecognizer handler
-(void)handleTapGesture:(UITapGestureRecognizer *)gesture
{
  if (self.isEditing) {
    self.editing = NO;

    // XXX: 即座に UICollectionView のタップにイベントを戻すための仕掛け
    CGPoint point = [gesture locationInView:self.collectionView];
    NSIndexPath * indexPath = [self.collectionView indexPathForItemAtPoint:point];
    if ([self.collectionView.delegate respondsToSelector:@selector(collectionView:didSelectItemAtIndexPath:)]) {
      [self.collectionView.delegate collectionView:self.collectionView
				    didSelectItemAtIndexPath:indexPath];
    }
  }
}

#pragma mark UIPanGestureRecognizer handler
-(void)handlePanGesture:(UIPanGestureRecognizer *)gesture
{
  CGPoint	point;

  switch (gesture.state) {
    case UIGestureRecognizerStateBegan:
      point = [gesture locationInView:self.collectionView];
      [self prepareForMovingItemAtPoint:point];
      [self invalidateLayout];
      break;

    case UIGestureRecognizerStateChanged:
      point = [gesture translationInView:self.collectionView];
      self.panTranslation  = point;
      self.mockView.center = CGPointAdd(self.mockViewCenter, point);

      [self moveItem];
      [self validateScrollTimer];
      break;

    case UIGestureRecognizerStateEnded:
    case UIGestureRecognizerStateCancelled:
      [self moveItem];
      [self invalidateScrollTimer];
      [self finishMovingItem];
      break;
    default:
      break;
  }
}

#pragma mark UIGestureRecognizerDelegate
-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
  if ([self.tapGestureRecognizer isEqual:gestureRecognizer]) {
    return self.isEditing;
  }
  if ([self.panGestureRecognizer isEqual:gestureRecognizer]) {
    return self.isEditing;
  }
  return YES;
}

#pragma mark UIGestureRecognizerDelegate
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
	shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
  if ([self.longPressGestureRecognizer isEqual:gestureRecognizer]) {
    return [self.panGestureRecognizer isEqual:otherGestureRecognizer];
  }
  if ([self.panGestureRecognizer isEqual:gestureRecognizer]) {
    return [self.longPressGestureRecognizer isEqual:otherGestureRecognizer];
  }
  return NO;
}

@end
