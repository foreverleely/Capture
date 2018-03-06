//
//  MJCaptureSelectRangeView.h
//  MacCapture
//
//  Created by 115Browser on 8/17/15.
//  Copyright (c) 2015 jacky.115.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#pragma mark mouse constant
/*
 _______________
 |               |
 |    2--3--4    |
 |    |     |    |
 |9   1  8  5    |
 |    |     |    |
 |    0--7--6    |
 |_______________|
 
 最外框的矩形为FunSuperView
 1、2、3、4、5、6、7所围起来的是crop高亮的矩形
 */

typedef enum MJCMouseState{
    MJCMouseLeftBotton,       //0
    MJCMouseLeftMid,          //1
    MJCMouseLeftTop,          //2
    MJCMouseTopMid,           //3
    MJCMouseRightTop,         //4
    MJCMouseRightMid,         //5
    MJCMouseRightBotton,      //6
    MJCMouseBottomMid,        //7
    
    MJCMouseInCropMove,       //8
    MJCMouseOutCropRotation   //9
}MJCMouseState;

@interface MJCaptureSelectRangeView : NSView{
    NSTrackingArea *trackingArea_;
    int nSpanValue_;
    
    NSRect  oldFrameRect_;
    NSPoint firstMouseDonwPoint_;
    NSPoint lastMousePoint_;
    
    //for drag action
    BOOL firstBeginDrag_;
    MJCMouseState mouseDragAction_;
    
    MJCMouseState state_;
}
@property (assign) int nSpanValue_;

- (NSImage *)GetCaptureCursorImage;

@end
