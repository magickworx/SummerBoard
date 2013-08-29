/*****************************************************************************
 *
 * FILE:	CollectionView.m
 * DESCRIPTION:	SummerBoard: Collection View Class
 * DATE:	Mon, Aug 19 2013
 * UPDATED:	Thu, Aug 29 2013
 * AUTHOR:	Kouichi ABE (WALL) / 阿部康一
 * E-MAIL:	kouichi@MagickWorX.COM
 * URL:		http://www.MagickWorX.COM/
 * COPYRIGHT:	(c) 2013 阿部康一／Kouichi ABE (WALL), All rights reserved.
 * LICENSE:
 *
 *  Copyright (c) 2013 Kouichi ABE (WALL) <kouichi@MagickWorX.COM>,
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

#import <QuartzCore/QuartzCore.h>
#import "CollectionView.h"
#import "CollectionCell.h"
#import "CollectionLayout.h"

@interface CollectionView () <UICollectionViewDelegate,UICollectionViewDataSource>
{
@private
  UICollectionView *	_collectionView;
  NSMutableArray *	_collectionData;

  BOOL	_editing;
}
@property (nonatomic,retain) UICollectionView *	collectionView;
@property (nonatomic,retain) NSMutableArray *	collectionData;
@property (nonatomic,getter=isEditing) BOOL	editing;
@end

@implementation CollectionView

-(id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    __block typeof(self) weakSelf = self;

    self.autoresizesSubviews	= YES;
    self.autoresizingMask	= UIViewAutoresizingFlexibleLeftMargin
				| UIViewAutoresizingFlexibleRightMargin
				| UIViewAutoresizingFlexibleTopMargin
				| UIViewAutoresizingFlexibleBottomMargin;

    CollectionLayout *	layout;
    layout = [CollectionLayout new];
#if	0
    layout.minimumLineSpacing = 24.0f;
    layout.minimumInteritemSpacing = 16.0f;
#endif
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.sectionInset = UIEdgeInsetsMake(8.0f, 8.0f, 8.0f, 8.0f);
    layout.itemSize = CGSizeMake(64.0f, 64.0f);
    // 画面の長押し
    layout.holdHandler = ^(UIGestureRecognizerState state) {
      if (state == UIGestureRecognizerStateBegan) {
	weakSelf.editing = YES;
      }
    };
    // ドラッグでセルを移動中
    layout.moveHandler = ^(NSIndexPath * fromIndexPath, NSIndexPath * toIndexPath) {
      [weakSelf.collectionData exchangeObjectAtIndex:fromIndexPath.item
			       withObjectAtIndex:toIndexPath.item];
      void (^updatesBlock)(void) = ^{
#if	0
	[weakSelf.collectionView deleteItemsAtIndexPaths:@[fromIndexPath]];
	[weakSelf.collectionView insertItemsAtIndexPaths:@[toIndexPath]];
#else
	[weakSelf.collectionView moveItemAtIndexPath:fromIndexPath toIndexPath:toIndexPath];
	[weakSelf.collectionView moveItemAtIndexPath:toIndexPath toIndexPath:fromIndexPath];
#endif
      };
      void (^completionBlock)(BOOL) = ^(BOOL finished) {
      };
      [weakSelf.collectionView performBatchUpdates:updatesBlock
			       completion:completionBlock];
    };
    // ドラッグ完了時に移動先のデータを再読み込み
    layout.endHandler = ^(NSIndexPath * toIndexPath) {
      [weakSelf.collectionView reloadItemsAtIndexPaths:@[toIndexPath]];
    };

    UICollectionView *	collectionView;
    collectionView = [[UICollectionView alloc]
		      initWithFrame:self.bounds
		      collectionViewLayout:layout];
    [layout release];
    [collectionView registerClass:[CollectionCell class]
		    forCellWithReuseIdentifier:collectionCellIdentifier];
    self.backgroundColor		= [UIColor blackColor];
    collectionView.delegate		= self;
    collectionView.dataSource		= self;
    collectionView.scrollEnabled	= YES;
    [self addSubview:collectionView];
    self.collectionView = collectionView;
    [collectionView release];

    _collectionData = [NSMutableArray new];
    for (NSInteger n = 1; n <= 31; n++) {
      [_collectionData addObject:[NSNumber numberWithInteger:n]];
    }
#if	0
    [self addGestureRecognizers];
#endif
  }
  return self;
}

-(void)dealloc
{
  [_collectionView release];
  [_collectionData release];
  [super dealloc];
}

-(void)realodData
{
  [self.collectionView reloadData];
}

/*****************************************************************************/

-(void)setEditing:(BOOL)editing
{
  _editing = editing;

  NSArray *	cells = [self.collectionView visibleCells];
  for (CollectionCell * cell in cells) {
    cell.vibrated = editing;
  }
}

/*****************************************************************************/

#pragma mark UICollectionViewDataSource
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
  return 1;
}

#pragma mark UICollectionViewDataSource
-(NSInteger)collectionView:(UICollectionView *)collectionView
	numberOfItemsInSection:(NSInteger)section
{
  return self.collectionData.count;
}

#pragma mark UICollectionViewDataSource
/*
 * The cell that is returned must be retrieved from a call to
 * -dequeueReusableCellWithReuseIdentifier:forIndexPath:
 */
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
	cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
  __block typeof(self) weakSelf = self;

  CollectionCell *	cell;
  cell = (CollectionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:collectionCellIdentifier forIndexPath:indexPath];

  NSNumber *	nval	= [self.collectionData objectAtIndex:[indexPath row]];
  cell.label.text	= [nval stringValue];
  cell.vibrated		= self.isEditing;
  cell.deleteHandler	= ^(CollectionCell * targetCell) {
    [weakSelf removeCell:targetCell];
  };

  return cell;
}


#pragma mark UICollectionViewDelegate
-(void)collectionView:(UICollectionView *)collectionView
	didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
  if (self.isEditing) {
    self.editing = NO;
    return;
  }

  // XXX: 実際の処理はここより先に実装する
  CollectionCell * cell = (CollectionCell *)[collectionView cellForItemAtIndexPath:indexPath];
  UIAlertView *	alertView;
  alertView = [[UIAlertView alloc]
		initWithTitle:nil
		message:[NSString stringWithFormat:@"%@",cell.label.text]
		delegate:nil
		cancelButtonTitle:NSLocalizedString(@"Close", @"Close")
		otherButtonTitles:nil];
  [alertView show];
  [alertView release];
}

#if	0
#pragma mark UICollectionViewDelegateFlowLayout
-(CGSize)collectionView:(UICollectionView *)collectionView
	layout:(UICollectionViewLayout *)collectionViewLayout
	sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
}
#endif

/*****************************************************************************/

-(void)removeCell:(CollectionCell *)cell
{
  cell.vibrated = NO;

  __block typeof(self) weakSelf = self;

  void (^updatesBlock)(void) = ^{
    NSIndexPath * indexPath = [weakSelf.collectionView indexPathForCell:cell];
    [weakSelf.collectionData removeObjectAtIndex:[indexPath row]];
    [weakSelf.collectionView deleteItemsAtIndexPaths:@[indexPath]];
  };
  void (^completionBlock)(BOOL) = ^(BOOL finished) {
  };
  [self.collectionView performBatchUpdates:updatesBlock
		       completion:completionBlock];
}

/*****************************************************************************/

#if	0
-(void)addGestureRecognizers
{
  NSArray *	recognizers = [self.collectionView gestureRecognizers];

  UITapGestureRecognizer *	doubleTapGestureRecognizer;
  doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc]
				initWithTarget:self
				action:@selector(handleDoubleTap:)];
  [doubleTapGestureRecognizer setNumberOfTapsRequired:2];

  for (UIGestureRecognizer * recognizer in recognizers) {
    if ([recognizer isKindOfClass:[UITapGestureRecognizer class]]) {
      [recognizer requireGestureRecognizerToFail:doubleTapGestureRecognizer];
    }
  }

  [self addGestureRecognizer:doubleTapGestureRecognizer];
  [doubleTapGestureRecognizer release];
}

#pragma mark UITapGestureRecognizer handler
-(void)handleDoubleTap:(UITapGestureRecognizer *)gesture
{
  CGPoint	point = [gesture locationInView:self.collectionView];
  NSIndexPath *	indexPath = [self.collectionView indexPathForItemAtPoint:point];
  CollectionCell * cell = (CollectionCell *)[self.collectionView cellForItemAtIndexPath:indexPath];

  // XXX: cell に対するダブルタップの処理はここで実装する
#if	DEBUG
  NSLog(@"DEBUG[dubleTap] %@",cell.label.text);
#endif	// DEBUG
}
#endif

@end
