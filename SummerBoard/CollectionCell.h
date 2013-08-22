/*****************************************************************************
 *
 * FILE:	CollectionCell.h
 * DESCRIPTION:	SummerBoard: UICollectionViewCell Subclass
 * DATE:	Mon, Aug 19 2013
 * UPDATED:	Tue, Aug 20 2013
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
 * $Id: CollectionView.h,v 1.1 2013/01/15 19:37:50 kouichi Exp $
 *
 *****************************************************************************/

extern NSString * const	collectionCellIdentifier;

@class	CollectionCell;

typedef void (^CollectionCellDeleteHandler)(CollectionCell * cell);

@interface CollectionCell : UICollectionViewCell
{
@private
  CollectionCellDeleteHandler	_deleteHandler;

  UILabel *	_label;

  BOOL		_vibrated;
}
@property (nonatomic,copy)  CollectionCellDeleteHandler	deleteHandler;
@property (nonatomic,retain,readonly) UILabel *	label;
@property (nonatomic,getter=isVibrated) BOOL	vibrated;

-(UIImage *)rasterizedImage;

@end
