//
//  SnipView.h
//  Snip
//
//  Created by rz on 15/1/31.
//  Copyright (c) 2015年 isee15. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MJCaptureModel.h"

@class MJSlideShapeView;
@class MJCaptureAssetView;
@class MJCaptureToolBarView;
@class MJMosaicView;

@interface SnipView : NSView
@property (strong)NSImage *image;
@property NSRect drawingRect;

@property(nonatomic, strong) NSTrackingArea *trackingArea;
@property (strong)NSScreen *screen;
///add new
@property int nLineWidth;
@property MJCToolBarFunType funType;
@property (strong)NSColor* brushColor;
@property int nFontSize;

@property (strong)MJSlideShapeView *slideShapeView;
@property (strong)MJCaptureAssetView   *assetView;
@property (strong)MJCaptureToolBarView *toolbarView;
@property (strong)MJMosaicView* mosaicView_;

@property BOOL isAfterClean;

- (void)cleanOpationAndReStart;
///
- (void)setupTrackingArea:(NSRect)rect;

- (void)setZoomAndPointViewHide:(BOOL)isHidde;

- (void)ReSetZoomInfoView:(NSEvent*)event;

#pragma mark slideShapeView operation
- (void)setToolbarhidde:(BOOL)isHidde;
- (BOOL)isHiddenSlideShapeView;
//- (void)showSlideShapeView:(MJCaptureSlideView*)view;
- (void)hideSlideShapeView;
- (void)upSelectSlideViewRect;
- (void)makeSelectSlideTextViewFocus;
- (void)makeTextViewFocus;

- (void)upSelectSlideViewColor;
- (void)upSelectSlideViewFontSize;

- (void)BeginEdit;

- (void)changeMosaic:(int)sliderValue;

- (void)setzoomInfoView:(BOOL)isHidde;

- (void)setpointInfoView:(BOOL)isHidde;

- (void)CreatSaveImage:(BOOL)isSave;

- (BOOL)isToolbarViewHidden;
@end
