//
//  MJCaptureAssetView.h
//  MacCapture
//
//  Created by mengjianjun on 15/8/22.
//  Copyright (c) 2015年 jacky.115.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MJCaptureSlideView.h"
#import "MJMosaicView.h"


@interface MJCaptureAssetView : NSView{
    NSTrackingArea *trackingArea_;
//    BOOL isEditing_;
    
//    NSPoint firstMouseDonwPoint_;
//    NSPoint lastMousePoint_;
    
    NSMutableArray *brushPoint_;
    NSMutableArray *slideArrayView_;
    
    MJCaptureSlideView *currentAddingView_;
    
    //add by liuchipeng 2016.1.26{
    NSRect firstPointCircle;
    NSRect lastPointCircle;
    NSRect re[2];
    BOOL isCanDragFirstPoint;
    BOOL isCanDragLastPoint;
    //}
    
    //add by aries{
    MJMosaicView* mosaicView_;
    ///}
}
@property NSPoint firstMouseDonwPoint;
@property NSPoint lastMousePoint;
@property BOOL isEditing_;
@property BOOL isRedraw;
@property BOOL isDragging;

@property (assign) BOOL isPointInfirst;
- (void) resetSlideFocusNone;

//add by aries{
- (void) beginMosaic:(NSImage*)bgImg foreground:(NSImage*) forImg;
- (void) beginChangeMosaic:(int)sliderValue;
- (MJMosaicView*) getMosaicView;
///}

#pragma mark undo manager
- (void)AddCaptureSlideView:(MJCaptureSlideView*)slideView;
- (void)RemoveCaptureSlideView:(MJCaptureSlideView*)slideView;
- (void)hideSlideArrayView;
- (void)showSlideArrayView;
//add by aries
- (void) AddMosaicView:(MJMosaicView*) mosaicView;
- (void) RemoveMosaicView:(MJMosaicView*) mosaicView;

@end
