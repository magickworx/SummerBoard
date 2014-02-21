/*****************************************************************************
 *
 * FILE:	RootViewController.m
 * DESCRIPTION:	SummerBoard: Application Root View Controller
 * DATE:	Mon, Aug 19 2013
 * UPDATED:	Fri, Feb 21 2014
 * AUTHOR:	Kouichi ABE (WALL) / 阿部康一
 * E-MAIL:	kouichi@MagickWorX.COM
 * URL:		http://www.iPhone.MagickWorX.COM/
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
 * $Id: RootViewController.m,v 1.3 2013/08/19 05:29:25 kouichi Exp $
 *
 *****************************************************************************/

#import "RootViewController.h"
#import "CollectionView.h"

@interface RootViewController ()
@property (nonatomic,strong) CollectionView *	collectionView;
@end

@implementation RootViewController

-(id)init
{
  self = [super init];
  if (self != nil) {
    self.title	= NSLocalizedString(@"SummerBoard", @"");
  }
  return self;
}

-(void)dealloc
{
  if ([_collectionView superview]) { [_collectionView removeFromSuperview]; }
}

-(void)didReceiveMemoryWarning
{
  /*
   * Invoke super's implementation to do the Right Thing,
   * but also release the input controller since we can do that.
   * In practice this is unlikely to be used in this application,
   * and it would be of little benefit,
   * but the principle is the important thing.
   */
  [super didReceiveMemoryWarning];
}

-(void)loadView
{
  [super loadView];

  CollectionView *	collectionView;
  collectionView = [[CollectionView alloc] initWithFrame:self.view.bounds];
  [self.view addSubview:collectionView];
  self.collectionView = collectionView;
}

-(void)viewDidLoad
{
  [super viewDidLoad];
}

@end
