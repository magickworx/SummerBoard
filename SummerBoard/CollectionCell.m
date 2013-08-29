/*****************************************************************************
 *
 * FILE:	CollectionCell.m
 * DESCRIPTION:	SummerBoard: UICollectionViewCell Subclass
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
#import "CollectionCell.h"

NSString * const	collectionCellIdentifier = @"CollectionCellIdentifier";

@interface CollectionCell ()
{
@private
  UIView *	_view;
  UIButton *	_button;
}
@property (nonatomic,retain) UIView *			view;
@property (nonatomic,retain) UIButton *			button;
@property (nonatomic,retain,readwrite) UILabel *	label;
@end

@implementation CollectionCell

-(id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    self.backgroundColor	= [UIColor clearColor];
    self.autoresizesSubviews	= YES;
    self.autoresizingMask	= UIViewAutoresizingFlexibleLeftMargin
				| UIViewAutoresizingFlexibleRightMargin
				| UIViewAutoresizingFlexibleTopMargin
				| UIViewAutoresizingFlexibleBottomMargin
				| UIViewAutoresizingFlexibleWidth
				| UIViewAutoresizingFlexibleHeight;
    CGFloat	x = 4.0f;
    CGFloat	y = 4.0f;
    CGFloat	w = frame.size.width  - x * 2.0f;
    CGFloat	h = frame.size.height - y * 2.0f;

    UIView *	view;
    view = [[UIView alloc] initWithFrame:CGRectMake(x, y, w, h)];
    view.backgroundColor	= [UIColor orangeColor];
    view.autoresizingMask	= UIViewAutoresizingFlexibleLeftMargin
				| UIViewAutoresizingFlexibleRightMargin
				| UIViewAutoresizingFlexibleTopMargin
				| UIViewAutoresizingFlexibleBottomMargin;
    [self.contentView addSubview:view];
    self.view = view;
    [view release];


    UILabel *	label;
    label = [[UILabel alloc] initWithFrame:self.view.bounds];
    label.font	= [UIFont boldSystemFontOfSize:20.0f];
    label.textAlignment	= NSTextAlignmentCenter;
    label.backgroundColor	= [UIColor clearColor];
    [self.view addSubview:label];
    self.label = label;
    [label release];

    w = 24.0f;
    h = 24.0f;
    x = frame.size.width - w + 4.0f;
    y = -4.0f;
    self.button = [self closeButtonWithFrame:CGRectMake(x, y, w, h)];
    self.button.hidden = YES;
    [self.contentView addSubview:self.button];

    _vibrated = NO;

    CALayer *	layer = [self.view layer];
    layer.borderColor	= [UIColor lightGrayColor].CGColor;
    layer.borderWidth	= 2.0f;
    layer.cornerRadius	= 10.0f;
    layer.masksToBounds	= YES;
  }
  return self;
}

-(void)dealloc
{
  [_deleteHandler release];
  [_view release];
  [_button release];
  [_label release];
  [super dealloc];
}

-(void)prepareForReuse
{
  [super prepareForReuse];

  self.label.text = nil;
  self.vibrated	= NO;
}

/*****************************************************************************/

static CGFloat
DegreesToRadians(CGFloat degrees)
{
  return degrees * M_PI / 180.0f;
}

static CGFloat
RadianasToDegrees(CGFloat radians)
{
  return radians * 180.0f / M_PI;
}

// UIView を揺らす
#define	kVibrateAnimationKey	@"VibrateAnimationKey"
-(void)setVibrated:(BOOL)vibrated
{
  if (_vibrated == vibrated) {
    return;
  }

  if (vibrated) {
    self.button.hidden	= NO;

    CABasicAnimation *	animation;
    animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    animation.duration	= 0.1;
    animation.fromValue	= [NSNumber numberWithFloat:DegreesToRadians(2.0f)];
    animation.toValue	= [NSNumber numberWithFloat:DegreesToRadians(-2.0f)];
    animation.repeatCount	= 1e100f;
    animation.autoreverses	= YES;
    [self.layer addAnimation:animation forKey:kVibrateAnimationKey];
  }
  else {
    self.button.hidden	= YES;
    [self.layer removeAnimationForKey:kVibrateAnimationKey];
  }

  _vibrated = vibrated;
}


/*****************************************************************************/

-(UIButton *)closeButtonWithFrame:(CGRect)frame
{
  UIButton *	button	= [UIButton buttonWithType:UIButtonTypeCustom];

  CGSize	size	= frame.size;
  CGFloat	width	= size.width;
  CGFloat	height	= size.height;
  BOOL		opaque	= NO;
  CGFloat	scale	= 0.0f;

  UIGraphicsBeginImageContextWithOptions(size, opaque, scale);
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextClearRect(context, CGRectMake(0.0f, 0.0f, width, height));
  // 描画の中心点
  CGFloat cx = width  * 0.5f;
  CGFloat cy = height * 0.5f;

  // 円の半径
  CGFloat radius = width > height ? height * 0.5f : height * 0.5f;
  radius -= 4.0f;
  // 円の描画領域
  CGRect rectEllipse = CGRectMake(cx - radius, cy - radius, radius * 2.0f, radius * 2.0f);

  //円を描画
  CGContextSetRGBFillColor(context, 1.0f, 0.0f, 0.0f, 1.0f);
  CGContextFillEllipseInRect(context, rectEllipse);

  // ×を描画
  CGContextSetRGBStrokeColor(context, 1.0f, 1.0f, 1.0f, 1.0f);
  CGContextSetLineWidth(context, 2.0f);
  CGFloat lineLength  = radius / 2.5f;
  CGContextMoveToPoint(context, cx-lineLength, cy-lineLength);
  CGContextAddLineToPoint(context, cx+lineLength, cy+lineLength);
  CGContextDrawPath(context, kCGPathFillStroke);

  CGContextMoveToPoint(context, cx+lineLength, cy-lineLength);
  CGContextAddLineToPoint(context, cx-lineLength, cy+lineLength);
  CGContextDrawPath(context, kCGPathFillStroke);

  // 影を落とす
  CGContextSetShadow(context, CGSizeMake(3.0f, 3.0f), 2.0f);
  CGContextStrokeEllipseInRect(context, rectEllipse);


  // 影付き赤丸×ボタン画像を生成
  UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();

  [button setImage:image forState:UIControlStateNormal];
  [button setFrame:frame];
  [button addTarget:self
	  action:@selector(buttonAction:)
	  forControlEvents:UIControlEventTouchUpInside];

  return button;
}

#pragma mark UIButton action
-(void)buttonAction:(id)sender
{
  if (_deleteHandler) {
    _deleteHandler(self);
  }
}

/******************************************************************************/

// ドラッグ時に表示する画像を動的に作成
-(UIImage *)rasterizedImage
{
  CGSize	size	= self.view.bounds.size;
  BOOL		opaque	= NO;	// NO   : 透過, YES : 不透過
  CGFloat	scale	= 0.0f;	// 0.0f : 自動調整, 2.0f : Retina 1.0f, : 標準
  CALayer *	layer	= self.view.layer;
  UIGraphicsBeginImageContextWithOptions(size, opaque, scale);
  [layer renderInContext:UIGraphicsGetCurrentContext()];
  UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();

  return image;
}

@end
