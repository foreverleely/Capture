//
//  MJCaptureSlideView.h
//  MacCapture
//
//  Created by mengjianjun on 15/8/22.
//  Copyright (c) 2015年 jacky.115.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MJCaptureModel.h"
@class MJCaptureSlideView;



@interface MJCaptureSlideTextView : NSTextView{
    BOOL isMouseDoubleClick_;
}
@property (assign) BOOL isMouseDoubleClick_;
//add by liuchipeng{
@property (assign) NSString *textStr;
@property (assign) MJCaptureSlideView *slideView;
//}

@end

@interface MJCaptureSlideView : NSView<NSTextViewDelegate>{
    NSTrackingArea *trackingArea_;
  
    MJCToolBarFunType funType_;
    int nLineWidth_;
    
    //only for brush
    NSBezierPath *brushPath_;
  
    NSScrollView* scrollView_;
    NSPoint  leftTopPoint_;
    int  nFontSize_;
    //
    BOOL isHasForcus_;
    //用来判断鼠标点击是否落在区域内，落在的话则向super传递鼠标事件(mouseDown\mouseUp)
    BOOL isPointOnPath_;
    //用来判断鼠标点击是否落在区域内,如果落在的话，则激化选中，并使其可拖动
    BOOL isMouseDown_;
    
    
}
@property (assign) MJCToolBarFunType funType_;
@property (assign) int nLineWidth_;
@property (assign) int nFontSize_;
@property (retain) NSBezierPath *brushPath_;
@property (assign) NSPoint firstTrianglePoint_;
@property (assign) NSPoint secondTrianglePoint_;
@property (assign) BOOL isPointOnPath_;
@property (assign) BOOL isHasForcus_;
@property (assign) BOOL isMouseDown_;
/*-------------------------------------------*/
@property (retain) MJCaptureSlideTextView *slideTextView;
@property (assign) NSPoint firstMouseDonwPoint;
@property (assign) NSPoint lastMousePoint;
@property (retain, nonatomic) NSColor* brushColor;
/*-------------------------------------------*/

- (id)initWithFrame:(NSRect)frame withType:(MJCToolBarFunType)type;

- (void)setBrushColor:(NSColor *)brushColor;

- (void)makeSelectSlideTextViewFocus;
- (void)upSelectSlideViewFontSize;


- (MJCaptureSlideTextView *)slideTextView;
- (void)reCaculateTextSize;
- (BOOL)isPointOnPath;
-(void)reDrawToolbarView;
@end

@interface MJSlideShapeView : NSView{
    NSTrackingArea *trackingArea_;
    
    NSPoint firstMouseDonwPoint_;
    NSPoint lastMousePoint_;
    int nLineWidth_;
    int nSpace_;
    //add by liuchipeng 2016.1.21{
    MJCaptureSlideView* ArrowSlideView_;
    NSRect slideShapeOldFrameRect_;
    MJCMouseState state_;
    MJCMouseState mouseDragAction_;
    BOOL firstBeginDrag_;
    NSRect focusre[9];
    //}
}
@property (assign) int nLineWidth_;
@property (assign) int nSpace_;
@property (assign) BOOL crossArrow;
-(MJCaptureSlideView*)getArrowSlideView;
-(void)reDrawFocusPoint:(NSRect)rect;


@end



