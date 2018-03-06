//
//  MJCaptureView.h
//  MacCapture
//
//  Created by 115Browser on 8/16/15.
//  Copyright (c) 2015 jacky.115.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MJCaptureModel.h"
#import "MJCaptureSelectRangeView.h"
#import "MJCaptureToolBarView.h"
#import "MJCaptureAssetView.h"
#import "MJCaptureInfoView.h"
#import "MJMosaicView.h"
#import "MJMosaicUtil.h"

@interface MJScreenShotImageView : NSImageView{
    
    BOOL  isSaving_;
}
@property (assign) BOOL isSaving_;

@end

@interface MJCaptureView : NSView <MJCaptureImageDelegate>{
    NSTrackingArea *trackingArea_;
    MJCaptureModel *captureModel_;
    
    MJScreenShotImageView *screenShotImageView_;
    MJCaptureSelectRangeView *selectRangeView_;
//    MJCaptureToolBarView *toolbarView_;
//    MJCaptureAssetView   *assetView_;
//    MJSlideShapeView     *slideShapeView_;
   
    MJCaptureInfoView *pointInfoView_;
    MJCaptureZoomInfoView *zoomInfoView_;
    
    NSPoint  firstMouseDonwPoint_;
    NSPoint  lastMousePoint_;
    NSMutableArray *arrayPoint_;
    
    NSRect   oldRangeRect_;
    
    NSMutableArray *prunedWindowList_;
    
    //is prepare to capture screen,may be mouse enter/ move / down/ drag,but not uped
    BOOL  isPreCapture_;
    //is already capture screen, must mouse uped
    BOOL  isCapture_;
    
    //is already begin edit
    BOOL  isEdit_;
//    MJCToolBarFunType funType_;
    int nLineWidth_;
    NSColor*  brushColor_;
    int nFontSize_;
    
    BOOL isAfterClean;
    
    MJMosaicView* mosaicView_;
}
@property (assign) BOOL isPreCapture_;
@property (assign) BOOL isCapture_;
@property (assign) BOOL isEdit_;
@property (assign) int nLineWidth_;
@property (assign) MJCToolBarFunType funType_;
@property (retain) NSColor* brushColor_;
@property (assign) int nFontSize_;
@property (assign) NSRect   oldRangeRect_;
@property (retain) MJSlideShapeView *slideShapeView;
@property (retain) MJCaptureAssetView   *assetView;
@property (retain) MJCaptureToolBarView *toolbarView;
@property (assign) MJCaptureSelectRangeView *selectRangeView_;
@property (retain) MJMosaicView* mosaicView_;

- (NSImage*)getScreenShotImage;

- (void)CleanOpationAndReStart;

- (void)ReCalculateViewFrameChangeSize:(BOOL)change event:(NSEvent*)event;
- (void)HideZoomInfoVew;

- (void)BeginEdit;
- (void)changeMosaic:(int)sliderValue;

- (void)CaptureMousePointOfWindowFrame:(NSRect)frameRect;
- (void)CaptureSetPrunedWindowList:(NSMutableArray*)array;

#pragma mark slideShapeView operation
- (BOOL)isHiddenSlideShapeView;
- (void)showSlideShapeView:(MJCaptureSlideView*)view;
- (void)hideSlideShapeView;
- (void)upSelectSlideViewRect;
- (void)makeSelectSlideTextViewFocus;
- (void)makeTextViewFocus;

- (void)upSelectSlideViewColor;
- (void)upSelectSlideViewFontSize;

#pragma mark Get Image From MJCaptureAssetView
//如果不是save，则放到剪切板中
- (void)CreatSaveImage:(BOOL)isSave;
    
@end
