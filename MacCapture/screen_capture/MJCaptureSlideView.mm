//
//  MJCaptureSlideView.m
//  MacCapture
//
//  Created by mengjianjun on 15/8/22.
//  Copyright (c) 2015年 jacky.115.com. All rights reserved.
//

#import "MJCaptureSlideView.h"
#import "MJCaptureView.h"
#import "MJCaptureWindow.h"
#import "MJCaptureAssetView.h"
#import "MJCaptureModel.h"
#import "MJCaptureView.h"


@implementation MJCaptureSlideTextView
@synthesize isMouseDoubleClick_;
//add by liuchipeng
@synthesize textStr;
@synthesize slideView;
//}
- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        isMouseDoubleClick_ = YES;
    }
    return self;
}

#pragma mark key action
- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent{
    return YES;
}
- (BOOL) acceptsFirstResponder{
    return YES;
}
//- (BOOL)becomeFirstResponder{
//    return YES;
//}
//- (BOOL)resignFirstResponder{
//    return NO;
//}

- (void) resignResponderDelay{
    NSView *view = self;
    while (![view isKindOfClass:[MJCaptureSlideView class]]) {
        view = [view superview];
    }
    if ([[view superview] isKindOfClass:[MJCaptureAssetView class]]) {
        [(MJCaptureAssetView*)[view superview] resetSlideFocusNone];
        if ([[self string] length] == 0) {
            
        }else{
            [view setNeedsDisplay:YES];
        }
        //[view mouseDown:[NSApp currentEvent]];
    }
    //[self setFocusRingType:NSFocusRingTypeDefault];
}

- (void)keyDown:(NSEvent *)theEvent{
    //NSLog(@"MJCaptureSlideView: %@", theEvent);
  
    if (theEvent.keyCode == 53) {
//        [NSApp stopModal];
//        [NSApp endSheet:(MJCaptureWindow*)[self window]];
//        [[self window] close];
//        [super keyDown:theEvent];
//        [self performSelector:@selector(resignResponderDelay) withObject:nil afterDelay:0.2];
    }
    else{
        [super keyDown:theEvent];
    }
}
- (void)keyUp:(NSEvent *)theEvent{
    if (theEvent.keyCode == 53) {
//        [NSApp stopModal];
//        [NSApp endSheet:(MJCaptureWindow*)[self window]];
//        [[self window] close];
        //[self setFocusRingType:NSFocusRingTypeNone];
        [self performSelector:@selector(resignResponderDelay) withObject:nil afterDelay:0.01];
    }
}
- (void)mousDownDelay{
    NSView *view = self;
    while (![view isKindOfClass:[MJCaptureSlideView class]]) {
        view = [view superview];
    }
    NSView *viewCature = view;
    while (![viewCature isKindOfClass:[MJCaptureView class]]) {
        viewCature = [viewCature superview];
    }
  [(MJCaptureView*)viewCature hideSlideShapeView];
  [(MJCaptureSlideView*)view reDrawToolbarView];
    if (isMouseDoubleClick_) {
        [(MJCaptureSlideView*)view setIsHasForcus_:YES];
        [(MJCaptureSlideView*)view setIsMouseDown_:YES];
        [(MJCaptureSlideView*)view setIsPointOnPath_:YES];
        [(MJCaptureSlideView*)view setNeedsDisplay:YES];
        [[self window] makeFirstResponder:self];
    }else{
        [(MJCaptureSlideView*)view setIsHasForcus_:NO];
        [(MJCaptureSlideView*)view setIsMouseDown_:YES];
        [(MJCaptureSlideView*)view setIsPointOnPath_:NO];
        [(MJCaptureView*)viewCature showSlideShapeView:((MJCaptureSlideView*)view)];
    }
    isMouseDoubleClick_ = NO;
}
- (void)mouseDown:(NSEvent *)theEvent{
    NSView *view = self;
    while (![view isKindOfClass:[MJCaptureSlideView class]]) {
        view = [view superview];
    }
    if (((MJCaptureSlideView*)view).isHasForcus_){
//        [[self window] makeFirstResponder:[[self superview] superview]];
        [super mouseDown:theEvent];
        return;
    }
    
    [self resignResponderDelay];
    if (theEvent.clickCount >= 2) {
        //[[self window] makeFirstResponder:[[self superview] superview]];
        //[super mouseDown:theEvent];
        isMouseDoubleClick_ = YES;
        //return;
    }
    //[(MJCaptureSlideView*)view setIsMouseDown_:YES];//[ setIsPointOnPath_:YES];
  [MJCaptureSlideTextView cancelPreviousPerformRequestsWithTarget:self];
  [(MJCaptureSlideView*)view setIsMouseDown_:YES];
    [self performSelector:@selector(mousDownDelay) withObject:nil afterDelay:0.1];
}

//add by liuchipeng{
-(void)interpretKeyEvents:(NSArray *)eventArray{
    [super interpretKeyEvents:eventArray];
    if (slideView && [slideView respondsToSelector:@selector(reCaculateTextSize)]) {
        [slideView reCaculateTextSize];
    }
}
//}
@end

@implementation NSBezierPath (BezierPathQuartzUtilities)
// This method works only in OS X v10.2 and later.
- (CGPathRef)quartzPath
{
    int i, numElements;
    
    // Need to begin a path here.
    CGPathRef           immutablePath = NULL;
    
    // Then draw the path elements.
    numElements = [self elementCount];
    if (numElements > 0)
    {
        CGMutablePathRef    path = CGPathCreateMutable();
        NSPoint             points[3];
        BOOL                didClosePath = YES;
        
        for (i = 0; i < numElements; i++)
        {
            switch ([self elementAtIndex:i associatedPoints:points])
            {
                case NSMoveToBezierPathElement:
                    CGPathMoveToPoint(path, NULL, points[0].x, points[0].y);
                    break;
                    
                case NSLineToBezierPathElement:
                    CGPathAddLineToPoint(path, NULL, points[0].x, points[0].y);
                    didClosePath = NO;
                    break;
                    
                case NSCurveToBezierPathElement:
                    CGPathAddCurveToPoint(path, NULL, points[0].x, points[0].y,
                                          points[1].x, points[1].y,
                                          points[2].x, points[2].y);
                    didClosePath = NO;
                    break;
                    
                case NSClosePathBezierPathElement:
                    CGPathCloseSubpath(path);
                    didClosePath = YES;
                    break;
            }
        }
        
        // Be sure the path is closed or Quartz may not do valid hit detection.
        if (!didClosePath)
            CGPathCloseSubpath(path);
        
        immutablePath = CGPathCreateCopy(path);
        CGPathRelease(path);
    }
    
    return immutablePath;
}

// Note, this method works only in OS X v10.4 and later.
- (BOOL)pathContainsPoint:(NSPoint)point forMode:(CGPathDrawingMode)mode lineWidth:(int)width
{
    CGPathRef       path = [self quartzPath]; // Custom method to create a CGPath
    //CGContextRef    cgContext = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
    CGContextRef    cgContext = MyCreateBitmapContext(10000, 10000);
    CGPoint         cgPoint;
    BOOL            containsPoint = NO;
    
    cgPoint.x = point.x;
    cgPoint.y = point.y;
    
    // Save the graphics state before doing the hit detection.
    CGContextSaveGState(cgContext);
    
    CGContextAddPath(cgContext, path);
    CGContextSetLineWidth(cgContext, width);
    containsPoint = CGContextPathContainsPoint(cgContext, cgPoint, mode);
    
    CGContextRestoreGState(cgContext);
    releaseMyContextData(cgContext);
    
    return containsPoint;
}
@end

@implementation MJCaptureSlideView

@synthesize funType_, nLineWidth_, nFontSize_, brushPath_, firstTrianglePoint_, secondTrianglePoint_, isPointOnPath_, isHasForcus_, isMouseDown_;

- (void)makeForcusLater{
    [[self window] makeFirstResponder:_slideTextView];
}
- (id)initWithFrame:(NSRect)frame withType:(MJCToolBarFunType)type
{
    self = [super initWithFrame:frame];
    if (self) {
        funType_ = type;
        nLineWidth_ = 5;
        nFontSize_ = 16;
        
        isPointOnPath_ = NO;
        brushPath_ = [[NSBezierPath alloc] init];
        _brushColor  = [[NSColor redColor] retain];
        isHasForcus_ = YES;
        isMouseDown_ = NO;
        
        firstTrianglePoint_ = NSZeroPoint;
        secondTrianglePoint_ = NSZeroPoint;
        
        if (funType_ == MJCToolBarFunText) {
            scrollView_ = [[NSScrollView alloc] initWithFrame:NSInsetRect([self bounds], 2, 3)];
            NSSize contentSize = [scrollView_ contentSize];
            [scrollView_ setBorderType:NSNoBorder];
            [scrollView_ setHasVerticalScroller:YES];
            [scrollView_ setHasHorizontalScroller:NO];
            [scrollView_ setAutohidesScrollers:YES];
            [scrollView_ setAutoresizingMask:NSViewWidthSizable |
             NSViewHeightSizable];
            [scrollView_ setDrawsBackground:NO];
            
            _slideTextView = [[MJCaptureSlideTextView alloc] initWithFrame:NSMakeRect(0, 0, contentSize.width, contentSize.height)];
            [_slideTextView setFont:[NSFont systemFontOfSize:nFontSize_]];
            //        [slideTextView_ setStringValue:@"21312"];
            [_slideTextView setEditable:YES];
            //        [slideTextView_ setBordered:NO];
            [_slideTextView setBackgroundColor:[NSColor clearColor]];
            [_slideTextView setFocusRingType:NSFocusRingTypeDefault];
            [_slideTextView setAlignment:NSLeftTextAlignment];
            [_slideTextView setTextColor:_brushColor];
            [_slideTextView sizeToFit];
            [_slideTextView setMinSize:NSMakeSize(0.0, contentSize.height)];
            [_slideTextView setMaxSize:NSMakeSize(3000, 3000)];
            [_slideTextView setVerticallyResizable:YES];
            [_slideTextView setHorizontallyResizable:NO];
            [_slideTextView setAutoresizingMask:NSViewWidthSizable];
            [[_slideTextView textContainer] setContainerSize:NSMakeSize(contentSize.width, 3000)];
            [[_slideTextView textContainer] setWidthTracksTextView:YES];
            [_slideTextView setDelegate:self];
            [_slideTextView setWantsLayer:YES];
            [scrollView_ setWantsLayer:YES];
            [self setWantsLayer:YES];
            
            //            add by liuchipeng{
            _slideTextView.slideView = self;
            //            }
            [scrollView_ setDocumentView:_slideTextView];
            [self addSubview:scrollView_];
            //            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChangeCustom:) name:NSTextDidEndEditingNotification object:nil];
            [scrollView_ setHidden:NO];
            
            //注：这里一定要延迟执行，因为初始化该slideView是在AssetView中的鼠标事件的down中(还未up，表示其鼠标流程或者焦点流程还在AssetView中)
            [self performSelector:@selector(makeForcusLater) withObject:nil afterDelay:0.1];
            
            
            //ps:注意，如果没有经过awakeFromNib的话，还需要加上acceptsFirstResponder才能让mouseMoved起作用
            //        [self addTrackingRect:self.bounds owner:self userData:nil assumeInside:YES];
            NSTrackingAreaOptions options = (NSTrackingActiveAlways | NSTrackingInVisibleRect |
                                             NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved);
            trackingArea_ = [[NSTrackingArea alloc] initWithRect:[self bounds]
                                                         options:options
                                                           owner:self
                                                        userInfo:nil];
            [self addTrackingArea:trackingArea_];
        }
        
        leftTopPoint_ = NSMakePoint(frame.origin.x, frame.origin.y+frame.size.height);
    }
    return self;
}

- (void)dealloc{
    if (funType_ == MJCToolBarFunText) {
        [_slideTextView release];
        [scrollView_ release];
    }
    [brushPath_ release];
    [_brushColor release];
    [trackingArea_ release];
    
    [super dealloc];
}

- (void)makeSelectSlideTextViewFocus{
    [[self window] makeFirstResponder:_slideTextView];
    _slideTextView.isMouseDoubleClick_ = YES;
    self.isHasForcus_ = YES;
    [_slideTextView setSelectedRange:NSMakeRange([[_slideTextView string] length], 0)];
//    [_slideTextView selectAll:nil];
    leftTopPoint_ = NSMakePoint(self.frame.origin.x, self.frame.origin.y+self.frame.size.height);
    
    [self setNeedsDisplay:YES];
}

- (void)reCaculateTextSize{
    [scrollView_ setHasVerticalScroller:NO];
    [scrollView_ setAutohidesScrollers:NO];
    [(MJCaptureView*)([[self superview] superview]) hideSlideShapeView];
    NSDictionary* attributesDictionary = @{
                                           NSFontAttributeName:
                                               [NSFont systemFontOfSize:nFontSize_]
                                           };
    NSString *strText = [_slideTextView string];
    NSRect trect = [strText boundingRectWithSize:NSMakeSize(3000, 3000) options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:attributesDictionary];
    trect.size.width += nFontSize_;
    NSRect newRect = [self frame];
    newRect.size.width = 4+trect.size.width;
    newRect.size.height = 6+trect.size.height;
    newRect.origin.x = leftTopPoint_.x;
    newRect.origin.y = leftTopPoint_.y - newRect.size.height;
    [self setFrame:newRect];
    [_slideTextView setMinSize:NSMakeSize(newRect.size.width, 3000)];
    [_slideTextView setMaxSize:NSMakeSize(newRect.size.width, 3000)];
    [[_slideTextView textContainer] setContainerSize:NSMakeSize(newRect.size.width, 3000)];
    
//    NSLog(@"newRect:%@", NSStringFromRect(newRect));
    [scrollView_ setFrame:NSInsetRect([self bounds], 2, 2)];
    [_slideTextView setFrame:NSMakeRect(0, 0, [scrollView_ contentSize].width, [scrollView_ contentSize].height)];
    
    NSPoint startPoint = [_slideTextView convertPoint:_slideTextView.frame.origin toView:self];
    float startX = startPoint.x;
    NSLog(@"startX:%f", startX);
}
- (void)upSelectSlideViewFontSize{
    leftTopPoint_ = NSMakePoint(self.frame.origin.x, self.frame.origin.y+self.frame.size.height);
    [self reCaculateTextSize];
    
    [_slideTextView selectAll:nil];
    [_slideTextView setFont:[NSFont systemFontOfSize:nFontSize_]];
    
    if (![(MJCaptureView*)([[self superview] superview]) isHiddenSlideShapeView]) {
        [(MJCaptureView*)([[self superview] superview]) showSlideShapeView:self];
    }
    [[self window] makeFirstResponder:_slideTextView];
    [_slideTextView setDelegate:nil];
    NSString *oldString = [NSString stringWithString:[_slideTextView string]];
    //NSLog(@"slideTextView_1:%@", oldString);
    [_slideTextView setString:@""];
    //NSLog(@"slideTextView_2:%@", oldString);
    [_slideTextView setString:oldString];
    [_slideTextView setDelegate:self];
}
- (void)textDidChange:(NSNotification *)notification{
    if ([[notification object] isEqual:_slideTextView]) {
        [self reCaculateTextSize];
    }
}
- (void)textDidChangeCustom:(NSNotification *)notification{
//    NSLog(@"%@", notification);
    //    NSLog(@"%@", NSStringFromRect([[slideTextView_ layoutManager] usedRectForTextContainer:[slideTextView_ textContainer]]));
    
    if ([[notification object] isEqual:_slideTextView]) {
        //        NSRect containerRect = [[slideTextView_ layoutManager] usedRectForTextContainer:[slideTextView_ textContainer]];
    }
}

- (NSBezierPath *)getPath:(NSRect)dirtyRect {
    NSBezierPath *path = [NSBezierPath bezierPath];
    dirtyRect = NSInsetRect(dirtyRect, nLineWidth_/2.0, nLineWidth_/2.0);
    switch (funType_) {
        case MJCToolBarFunRectangle:{
            path = [NSBezierPath bezierPathWithRect:dirtyRect];
            [path setLineWidth:nLineWidth_];
        }
            break;
        case MJCToolBarFunCircle:{
            path = [NSBezierPath bezierPathWithOvalInRect:dirtyRect];
            [path setLineWidth:nLineWidth_];
        }
            break;
        case MJCToolBarFunTriangleArrow:
            break;
        case MJCToolBarFunBrush:{
        }
            break;
        case MJCToolBarFunText:
            break;
            
        default:
            break;
    }
    return path;
}
- (void)drawRect:(NSRect)dirtyRect {
    //[super drawRect:dirtyRect];
    
    // Drawing code here.
//    [[NSColor blueColor] set];
//    [[NSBezierPath bezierPathWithRect:dirtyRect] fill];
//    return;
    
    [_brushColor set];
    //NSLog(@"MJCaptureSlideView drawRect:  %@,  nLineWidth:%d", NSStringFromRect(dirtyRect), nLineWidth_);
    //    return;
    
    NSBezierPath *path = [NSBezierPath bezierPath];
    switch (funType_) {
        case MJCToolBarFunRectangle:{
            path = [self getPath:dirtyRect];
            [path stroke];
        }
            break;
        case MJCToolBarFunCircle:{
            path = [self getPath:dirtyRect];
            [path stroke];
        }
            break;
        case MJCToolBarFunTriangleArrow:{
            CGContextRef context = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
            drawTriangleArrow(context, NSPointToCGPoint(firstTrianglePoint_), NSPointToCGPoint(secondTrianglePoint_), nLineWidth_);
        }
            break;
        case MJCToolBarFunBrush:{
            [brushPath_ setLineWidth:nLineWidth_];
            [brushPath_ setLineCapStyle:NSRoundLineCapStyle];
            [brushPath_ setLineJoinStyle:NSMiterLineJoinStyle];
            [brushPath_ stroke];
        }
            break;
        case MJCToolBarFunText:
            if (isMouseDown_ || isHasForcus_){
                //if ([[[self window] firstResponder] isEqualTo:slideTextView_] || [[[self window] firstResponder] isEqualTo:self]) {
                [[NSColor colorWithCalibratedRed:0.800 green:0.800 blue:0.800 alpha:1] set];
                dirtyRect = NSInsetRect(dirtyRect, nLineWidth_/2.0, nLineWidth_/2.0);
                path = [NSBezierPath bezierPathWithRoundedRect:dirtyRect xRadius:0 yRadius:0];
                CGFloat patten[2] = {4,4};
                [path setLineDash:patten count:2 phase:1];
                [path setLineWidth:2];
                [path stroke];
            }
            return;
            break;
            
        default:
            break;
    }
}

- (void)setFrame:(NSRect)frame{
    [super setFrame:frame];
    
}

- (void)mouseDown:(NSEvent*)theEvent {
    NSLog(@"MJCaptureSlideView mouseDown...");
    //    [super mouseDown:theEvent];
    if (funType_ == MJCToolBarFunText && isMouseDown_ && isHasForcus_) {
        return;
    }
    NSPoint pt = theEvent.locationInWindow;
    _firstMouseDonwPoint = [self convertPoint:pt fromView:nil];
    
    [(MJCaptureAssetView*)[self superview] resetSlideFocusNone];
    isHasForcus_ = YES;
    isPointOnPath_ = NO;
    isMouseDown_ = NO;
    
    NSRect rr = NSInsetRect([self bounds], 0, 0);
    NSBezierPath *path = [self getPath:rr];
    
    
    switch (funType_) {
        case MJCToolBarFunRectangle:{
            if ([path pathContainsPoint:_firstMouseDonwPoint forMode:kCGPathStroke lineWidth:nLineWidth_]) {
                isPointOnPath_ = YES;
            }
        }
            break;
        case MJCToolBarFunCircle:{
            if ([path pathContainsPoint:_firstMouseDonwPoint forMode:kCGPathStroke lineWidth:nLineWidth_]) {
                isPointOnPath_ = YES;
            }
        }
            break;
        case MJCToolBarFunTriangleArrow:{
            [path moveToPoint:firstTrianglePoint_];
            [path lineToPoint:secondTrianglePoint_];
            [path setLineWidth:nLineWidth_];
            if ([path pathContainsPoint:_firstMouseDonwPoint forMode:kCGPathStroke lineWidth:nLineWidth_]) {
                isPointOnPath_ = YES;
            }
        }
            break;
        case MJCToolBarFunBrush:{
            if ([brushPath_ pathContainsPoint:_firstMouseDonwPoint forMode:kCGPathStroke lineWidth:nLineWidth_]) {
                isPointOnPath_ = YES;
            }
        }
            break;
        case MJCToolBarFunText:
            isPointOnPath_ = YES;
            break;
            
        default:
            break;
    }
    if (isPointOnPath_) {
        isMouseDown_ = YES;
        isPointOnPath_ = YES;
        
        NSLog(@"MJCaptureSlideView mouseDown showSlideShapeView");
        [(MJCaptureView*)([[self superview] superview]) showSlideShapeView:self];
        
        MJCaptureView* mjview = (MJCaptureView*)[[self superview] superview];
        [mjview.toolbarView ResetLingWidthType:nLineWidth_];
        [self reDrawToolbarView];
    }else{
        [(MJCaptureView*)([[self superview] superview]) hideSlideShapeView];
        [super mouseDown:theEvent];
    }
    
    [self setNeedsDisplay:YES];
}
- (void)mouseUp:(NSEvent *)theEvent{
    if (funType_ == MJCToolBarFunText && (isMouseDown_ || isHasForcus_)) {
        return;
    }
    NSLog(@"MJCaptureSlideView mouseUp...");
    if([[self superview] isKindOfClass:[MJCaptureAssetView class]]){
        MJCaptureAssetView* father = (MJCaptureAssetView*)[self superview];
        if([father getMosaicView] != nil && [father getMosaicView].isHidden==FALSE && !isPointOnPath_){
            [[father getMosaicView] mouseUp:theEvent];
            return;
        }
    }
    //    [super mouseUp:theEvent];
    if (!isPointOnPath_) {
        [super mouseUp:theEvent];
    }
    isPointOnPath_ = NO;
    _lastMousePoint = [self convertPoint:theEvent.locationInWindow fromView:nil];
    [self setNeedsDisplay:YES];
}
- (void)mouseEntered:(NSEvent*)theEvent {
    [super mouseEntered:theEvent];
}

- (void)mouseExited:(NSEvent*)theEvent {
    [super mouseExited:theEvent];
}

- (void)mouseMoved:(NSEvent *)theEvent{
    //[super mouseMoved:theEvent];
    
}
- (void)mouseDragged:(NSEvent *)theEvent{
    ///add by aries{
    if([[self superview] isKindOfClass:[MJCaptureAssetView class]]){
        MJCaptureAssetView* father = (MJCaptureAssetView*)[self superview];
        if([father getMosaicView] != nil && [father getMosaicView].isHidden==FALSE && !isPointOnPath_){
            [[father getMosaicView] mouseDragged:theEvent];
            return;
        }
    }
    ///}
    //    [super mouseDragged:theEvent];
    
    if (!isPointOnPath_) {
        [super mouseDragged:theEvent];
    }else{

    }
}

#pragma mark attribute change
- (void)setBrushColor:(NSColor *)brushColor{
    [_brushColor release];
    _brushColor = [brushColor retain];
    if (funType_ == MJCToolBarFunText && _slideTextView) {
        [_slideTextView setTextColor:brushColor];
    }
}
//add by liuchipeng 2016.1.26{
- (BOOL)isPointOnPath{
    return isPointOnPath_;
}

-(void)reDrawToolbarView{
    MJCaptureView *mjview = (MJCaptureView*)([[self superview] superview]);
    
    switch (funType_) {
        case MJCToolBarFunRectangle:{
            [mjview setFunType_:MJCToolBarFunRectangle];
            [mjview.toolbarView ResetButtonType:MJCToolBarFunRectangle];
        }
            break;
        case MJCToolBarFunCircle:{
            [mjview setFunType_:MJCToolBarFunCircle];
            [mjview.toolbarView ResetButtonType:MJCToolBarFunCircle];
        }
            break;
        case MJCToolBarFunTriangleArrow:{
            [mjview setFunType_:MJCToolBarFunTriangleArrow];
            [mjview.toolbarView ResetButtonType:MJCToolBarFunTriangleArrow];
        }
            break;
        case MJCToolBarFunBrush:{
            [mjview setFunType_:MJCToolBarFunBrush];
            [mjview.toolbarView ResetButtonType:MJCToolBarFunBrush];
        }
            break;
        case MJCToolBarFunText:{
            [mjview setFunType_:MJCToolBarFunText];
            [mjview.toolbarView ResetButtonType:MJCToolBarFunText];
        }
            break;
            
        default:
            break;
    }
}
//}
@end



#pragma mark attribute change
@implementation MJSlideShapeView//元素选中框

@synthesize nLineWidth_, nSpace_;
- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        nSpace_ = 10;
        //add by liuchipeng 2016.1.21{
        ArrowSlideView_ =[self getArrowSlideView];
        _crossArrow = NO;
        nLineWidth_ = 5;
        firstBeginDrag_ = NO;
        
        
        NSTrackingAreaOptions options = (NSTrackingActiveAlways | NSTrackingInVisibleRect |
                                         NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved);
        trackingArea_ = [[NSTrackingArea alloc] initWithRect:[self bounds]
                                                     options:options
                                                       owner:self
                                                    userInfo:nil];
        [self addTrackingArea:trackingArea_];
        //}
    }
    return self;
}

- (void) dealloc{
    
    [super dealloc];
}
- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    int nSpanValue_ = nLineWidth_*2;
    
    /*--------------------------------------------------------------------------*/
    
    MJCaptureSlideView* view = [self getArrowSlideView];
    if ((view.funType_!=MJCToolBarFunTriangleArrow)) {
        NSRect insetRect = NSInsetRect(dirtyRect, nSpanValue_/2.0, nSpanValue_/2.0);
        [[(MJCaptureView*)[self superview] brushColor_] set];
        NSBezierPath *path = [NSBezierPath bezierPathWithRect:insetRect];
        CGFloat patten[2] = {4,4};
        [path setLineDash:patten count:2 phase:1];
        [path setLineWidth:2];
        [path stroke];
        NSPoint start = insetRect.origin;
        NSSize size = NSMakeSize(insetRect.size.width-2, insetRect.size.height-2);
        start.x-=nSpanValue_/2.0-1;
        start.y-=nSpanValue_/2.0-1;
        
        focusre[0] = NSMakeRect(start.x, start.y, nSpanValue_, nSpanValue_);
        focusre[1] = NSMakeRect(start.x+size.width/2, start.y,nSpanValue_,nSpanValue_);
        focusre[2] = NSMakeRect(start.x+size.width, start.y, nSpanValue_, nSpanValue_);
        start.y+=size.height/2;
        focusre[3] = NSMakeRect(start.x, start.y, nSpanValue_, nSpanValue_);
        focusre[4] = NSMakeRect(start.x+size.width, start.y, nSpanValue_, nSpanValue_);
        start.y+=size.height/2;
        focusre[5] = NSMakeRect(start.x, start.y, nSpanValue_, nSpanValue_);
        focusre[6] = NSMakeRect(start.x+size.width/2, start.y, nSpanValue_, nSpanValue_);
        focusre[7] = NSMakeRect(start.x+size.width, start.y, nSpanValue_, nSpanValue_);
        focusre[8] = NSMakeRect(start.x+size.width/2, start.y+20, nSpanValue_, nSpanValue_);
    }else {
        NSRect insetRect = NSInsetRect(dirtyRect, nSpanValue_/2.0, nSpanValue_/2.0);
        MJCaptureAssetView* aview = (MJCaptureAssetView*)[ArrowSlideView_ superview];
        if(!aview.isDragging){
            [[(MJCaptureView*)[self superview] brushColor_] set];
        }else{
            [[NSColor clearColor] set];
        }
        NSBezierPath *path = [NSBezierPath bezierPathWithRect:insetRect];
        CGFloat patten[2] = {4,4};
        [path setLineDash:patten count:2 phase:1];
        [path setLineWidth:2];
        [path stroke];
        
        ArrowSlideView_ = [self getArrowSlideView];
        NSPoint first = [self convertPoint:ArrowSlideView_.firstTrianglePoint_ fromView:ArrowSlideView_] ;
        NSPoint last = [self convertPoint:ArrowSlideView_.secondTrianglePoint_ fromView:ArrowSlideView_] ;
        
        if (aview.isDragging) {
            first = [self convertPoint:aview.firstMouseDonwPoint fromView:aview] ;
            last = [self convertPoint:aview.lastMousePoint fromView:aview] ;
        }
        
        first.x-=nLineWidth_/1.7;
        first.y-=nLineWidth_/1.7;
        last.x-=nLineWidth_/1.4;
        last.y-=nLineWidth_/1.4;
        focusre[0] = NSMakeRect(first.x, first.y, nSpanValue_, nSpanValue_);
        focusre[1] = NSMakeRect(last.x, last.y, nSpanValue_, nSpanValue_);
        for (int i = 2; i<9; i++) {
            focusre[i] = NSMakeRect(0, 0, 0, 0);
        }
        
    }
    /*--------------------------------------------------------------------------*/
    
    MJCaptureAssetView* aview = (MJCaptureAssetView*)[ArrowSlideView_ superview];
    MJCaptureSlideView* sview = [self getFocusSlideView];
    if(sview && ![aview isDragging]&&(sview.funType_ != MJCToolBarFunText)&&(sview.funType_ != MJCToolBarFunBrush)){
        NSBezierPath *pathCircle = [NSBezierPath bezierPath];
        [[NSColor whiteColor] set];
        for(int j=0;j<8;++j)
        {
            pathCircle = [NSBezierPath bezierPathWithOvalInRect:focusre[j]];
            [pathCircle fill];
        }
        [[NSColor blueColor] set];
        for(int j=0;j<8;++j)
        {
            pathCircle = [NSBezierPath bezierPathWithOvalInRect:focusre[j]];
            [pathCircle setLineWidth:2];
            [pathCircle stroke];
        }
    }
    else {
        return;
    }
}

//add by liuchipeng 2016.1.21{
- (MJCMouseState)getMouseActionType:(NSPoint)pt{
    int nSpanValue_ = nSpace_;
    NSRect insetRect = NSInsetRect([self bounds], nSpanValue_/2.0, nSpanValue_/2.0);
    NSPoint start = insetRect.origin;
    NSSize size = NSMakeSize(insetRect.size.width, insetRect.size.height);
    start.x-=nSpanValue_/2.0;
    start.y-=nSpanValue_/2.0;
    NSRect re[8];
    
    /*------------------------------------------------------------------*/
    if (ArrowSlideView_.funType_!=MJCToolBarFunTriangleArrow) {
        re[MJCMouseLeftBotton] = NSMakeRect(0, 0, nSpanValue_, nSpanValue_);
        re[MJCMouseBottomMid] = NSMakeRect(nSpanValue_, 0,[self bounds].size.width-nSpanValue_*2,nSpanValue_);
        re[MJCMouseRightBotton] = NSMakeRect([self bounds].size.width-nSpanValue_, 0, nSpanValue_, nSpanValue_);
        start.y+=size.height/2;
        re[MJCMouseLeftMid] = NSMakeRect(0, nSpanValue_, nSpanValue_, [self bounds].size.height-nSpanValue_*2);
        re[MJCMouseRightMid] = NSMakeRect([self bounds].size.width-nSpanValue_, nSpanValue_, nSpanValue_, [self bounds].size.height-nSpanValue_*2);
        start.y+=size.height/2;
        re[MJCMouseLeftTop] = NSMakeRect(0, [self bounds].size.height-nSpanValue_, nSpanValue_, nSpanValue_);
        re[MJCMouseTopMid] = NSMakeRect(nSpanValue_, [self bounds].size.height-nSpanValue_, [self bounds].size.width-nSpanValue_*2, nSpanValue_);
        re[MJCMouseRightTop] = NSMakeRect([self bounds].size.width-nSpanValue_, [self bounds].size.height-nSpanValue_, nSpanValue_, nSpanValue_);
        
    }else{
        NSPoint first = ArrowSlideView_.firstTrianglePoint_;
        first.x-=2;
        first.y-=2;
        NSPoint last = ArrowSlideView_.secondTrianglePoint_;
        last.x-=2;
        last.y-=2;
        re[0] = NSMakeRect(first.x, first.y, nSpanValue_, nSpanValue_);
        re[1] = NSMakeRect(last.x, last.y, nSpanValue_, nSpanValue_);
        for(int i=2;i<8;i++){
            re[i] = NSMakeRect(0, 0, 0, 0);
        }
    }
    NSPoint tempPoint = [self convertPoint:pt fromView:nil];
    MJCMouseState state = MJCMouseInCropMove;
    BOOL isDraggeChangeSize = NO;
    ArrowSlideView_ = [self getArrowSlideView];
    for (int i = 0; i < 8; i++) {
        if (NSPointInRect(tempPoint, re[i])) {
            state = (MJCMouseState)i;
            isDraggeChangeSize = YES;
            break;
        }
    }
    MJCaptureSlideView *sview = [self getFocusSlideView];
    if (sview.funType_==MJCToolBarFunBrush || sview.funType_ == MJCToolBarFunText) {
        isDraggeChangeSize = NO;
    }
    if (!isDraggeChangeSize) {
        state = MJCMouseInCropMove;
    }
    return state;
    /*------------------------------------------------------------------*/
}

- (void)setCursorForState:(MJCMouseState)state{
    
    NSCursor *cursor;
    NSImage *image;
    switch (state) {
        case MJCMouseLeftBotton:
            image = [NSImage imageNamed:@"mj_capture_cursor1"];
            cursor = [[NSCursor alloc] initWithImage:image hotSpot:NSMakePoint([image size].width/2, [image size].height/2)];
            [[self enclosingScrollView] setDocumentCursor:cursor];
            [cursor autorelease];
            break;
        case MJCMouseLeftMid:
            image = [NSImage imageNamed:@"mj_capture_cursor4"];
            cursor = [[NSCursor alloc] initWithImage:image hotSpot:NSMakePoint([image size].width/2, [image size].height/2)];
            [[self enclosingScrollView] setDocumentCursor:cursor];
            [cursor autorelease];
            break;
        case MJCMouseLeftTop:
            image = [NSImage imageNamed:@"mj_capture_cursor2"];
            cursor = [[NSCursor alloc] initWithImage:image hotSpot:NSMakePoint([image size].width/2, [image size].height/2)];
            [[self enclosingScrollView] setDocumentCursor:cursor];
            [cursor autorelease];
            break;
        case MJCMouseTopMid:
            image = [NSImage imageNamed:@"mj_capture_cursor3"];
            cursor = [[NSCursor alloc] initWithImage:image hotSpot:NSMakePoint([image size].width/2, [image size].height/2)];
            [[self enclosingScrollView] setDocumentCursor:cursor];
            [cursor autorelease];
            break;
        case MJCMouseRightTop:
            image = [NSImage imageNamed:@"mj_capture_cursor1"];
            cursor = [[NSCursor alloc] initWithImage:image hotSpot:NSMakePoint([image size].width/2, [image size].height/2)];
            [[self enclosingScrollView] setDocumentCursor:cursor];
            [cursor autorelease];
            break;
        case MJCMouseRightMid:
            image = [NSImage imageNamed:@"mj_capture_cursor4"];
            cursor = [[NSCursor alloc] initWithImage:image hotSpot:NSMakePoint([image size].width/2, [image size].height/2)];
            [[self enclosingScrollView] setDocumentCursor:cursor];
            [cursor autorelease];
            break;
        case MJCMouseRightBotton:
            image = [NSImage imageNamed:@"mj_capture_cursor2"];
            cursor = [[NSCursor alloc] initWithImage:image hotSpot:NSMakePoint([image size].width/2, [image size].height/2)];
            [[self enclosingScrollView] setDocumentCursor:cursor];
            [cursor autorelease];
            break;
        case MJCMouseBottomMid:
            image = [NSImage imageNamed:@"mj_capture_cursor3"];
            cursor = [[NSCursor alloc] initWithImage:image hotSpot:NSMakePoint([image size].width/2, [image size].height/2)];
            [[self enclosingScrollView] setDocumentCursor:cursor];
            [cursor autorelease];
            break;
        case MJCMouseInCropMove:
            if (((MJCaptureView*)[self superview]).isEdit_) {
                //                [[self enclosingScrollView] setDocumentCursor:[NSCursor crosshairCursor]];
                [[self enclosingScrollView] setDocumentCursor:[NSCursor openHandCursor]];
            }else{
                
                [[self enclosingScrollView] setDocumentCursor:[NSCursor openHandCursor]];
            }
            break;
        default:
            [[self enclosingScrollView] setDocumentCursor:[NSCursor arrowCursor]];
            break;
    }
}
- (void)mouseDraggeMoveView:(NSPoint)pt isChangeSize:(BOOL)change event:(NSEvent*)event{
    NSRect oldRect = slideShapeOldFrameRect_;
    oldRect.origin.x += (pt.x-firstMouseDonwPoint_.x);
    oldRect.origin.y += (pt.y-firstMouseDonwPoint_.y);
    oldRect = NSIntegralRect(oldRect);
    NSRect screenRect = [[NSScreen mainScreen] frame];
    if (oldRect.origin.x < 0) {
        oldRect.origin.x = 0;
    }
    if (oldRect.origin.y < 0) {
        oldRect.origin.y = 0;
    }
    if (oldRect.origin.x+oldRect.size.width>screenRect.size.width) {
        oldRect.origin.x = screenRect.size.width-oldRect.size.width;
    }
    if (oldRect.origin.y+oldRect.size.height>screenRect.size.height) {
        oldRect.origin.y = screenRect.size.height-oldRect.size.height;
    }
    
    [self setFrame:oldRect];
    
}
- (void)mouseDraggeFromChangeFrame:(NSPoint)pt isChangeSize:(BOOL)change event:(NSEvent*)event{
    NSRect oldRect = slideShapeOldFrameRect_;
    int nSpanValue_ = nSpace_;
    switch (mouseDragAction_) {
        case MJCMouseLeftBotton:
        {
            oldRect.origin.x += (pt.x-firstMouseDonwPoint_.x);
            oldRect.size.width -= (pt.x-firstMouseDonwPoint_.x);
            if (oldRect.size.width < 0) {
                oldRect.origin.x += oldRect.size.width - nSpanValue_;
                oldRect.size.width = -oldRect.size.width;
            }
            
            oldRect.origin.y += (pt.y-firstMouseDonwPoint_.y);
            oldRect.size.height -= (pt.y-firstMouseDonwPoint_.y);
            if (oldRect.size.height < 0) {
                oldRect.origin.y += oldRect.size.height - nSpanValue_;
                oldRect.size.height = -oldRect.size.height;
            }
        }
            break;
        case MJCMouseLeftMid:
        {
            
            oldRect.origin.x += (pt.x-firstMouseDonwPoint_.x);
            oldRect.size.width -= (pt.x-firstMouseDonwPoint_.x);
            if (oldRect.size.width < 0) {
                oldRect.origin.x += oldRect.size.width - nSpanValue_;
                oldRect.size.width = -oldRect.size.width;
            }
        }
            break;
        case MJCMouseLeftTop:
        {
            oldRect.origin.x += (pt.x-firstMouseDonwPoint_.x);
            oldRect.size.width -= (pt.x-firstMouseDonwPoint_.x);
            if (oldRect.size.width < 0) {
                oldRect.origin.x += oldRect.size.width - nSpanValue_;
                oldRect.size.width = -oldRect.size.width;
            }
            
            oldRect.size.height += (pt.y-firstMouseDonwPoint_.y);
            if (oldRect.size.height < 0) {
                oldRect.origin.y += oldRect.size.height + nSpanValue_;
                oldRect.size.height = -oldRect.size.height;
            }
        }
            break;
        case MJCMouseTopMid:
        {
            oldRect.size.height += (pt.y-firstMouseDonwPoint_.y);
            if (oldRect.size.height < 0) {
                oldRect.origin.y += oldRect.size.height + nSpanValue_;
                oldRect.size.height = -oldRect.size.height;
            }
        }
            break;
        case MJCMouseRightTop:
        {
            oldRect.size.width += (pt.x-firstMouseDonwPoint_.x);
            if (oldRect.size.width < 0) {
                oldRect.origin.x += oldRect.size.width + nSpanValue_;
                oldRect.size.width = -oldRect.size.width;
            }
            oldRect.size.height += (pt.y-firstMouseDonwPoint_.y);
            if (oldRect.size.height < 0) {
                oldRect.origin.y += oldRect.size.height + nSpanValue_;
                oldRect.size.height = -oldRect.size.height;
            }
        }
            break;
        case MJCMouseRightMid:
        {
            oldRect.size.width += (pt.x-firstMouseDonwPoint_.x);
            if (oldRect.size.width < 0) {
                oldRect.origin.x += oldRect.size.width + nSpanValue_;
                oldRect.size.width = -oldRect.size.width;
            }
        }
            break;
        case MJCMouseRightBotton:
        {
            oldRect.size.width += (pt.x-firstMouseDonwPoint_.x);
            if (oldRect.size.width < 0) {
                oldRect.origin.x += oldRect.size.width + nSpanValue_;
                oldRect.size.width = -oldRect.size.width;
            }
            oldRect.origin.y += (pt.y-firstMouseDonwPoint_.y);
            oldRect.size.height -= (pt.y-firstMouseDonwPoint_.y);
            if (oldRect.size.height < 0) {
                oldRect.origin.y += oldRect.size.height - nSpanValue_;
                oldRect.size.height = -oldRect.size.height;
            }
        }
            break;
        case MJCMouseBottomMid:
        {
            oldRect.origin.y += (pt.y-firstMouseDonwPoint_.y);
            oldRect.size.height -= (pt.y-firstMouseDonwPoint_.y);
            if (oldRect.size.height < 0) {
                oldRect.origin.y += oldRect.size.height - nSpanValue_;
                oldRect.size.height = -oldRect.size.height;
            }
        }
            break;
        case MJCMouseInCropMove:
        {
            [self mouseDraggeMoveView:pt isChangeSize:change event:event];
            return;
        }
            break;
            
        default:
            break;
    }
    oldRect = NSIntegralRect(oldRect);
    [self setFrame:oldRect];
}
//}
//add by liuchipeng 2016.1.24{
//获取slideshapeview所属的slidView
-(MJCaptureSlideView*)getFocusSlideView{
    MJCaptureSlideView* newView = nil;
    MJCaptureView* captureView = (MJCaptureView*)[self superview];
    while (![captureView isKindOfClass:[MJCaptureView class]]) {
        captureView = (MJCaptureView*)[captureView superview];
    }
    MJCaptureAssetView* assetView = [captureView assetView];
    NSUInteger subviewsCount = [assetView.subviews count];
    for (int i=0; i<subviewsCount; i++) {
        NSView* viewAt = [assetView.subviews objectAtIndex:i];
        if([viewAt isKindOfClass:[MJCaptureSlideView class]]){
            MJCaptureSlideView* view = (MJCaptureSlideView*)viewAt;
            if (view.funType_ == MJCToolBarFunText) {
                if (view.isMouseDown_) {
                    newView = view;
                }
            }else{
                if (view.isMouseDown_&&view.isHasForcus_) {
                    newView = view;
                }
            }
        }
    }
    
    return newView;
}
-(MJCaptureSlideView*)getArrowSlideView{
    MJCaptureSlideView* newView = nil;
    MJCaptureAssetView* assetView = [(MJCaptureView*)self.superview assetView];
    NSUInteger subviewsCount = [assetView.subviews count];
    for (int i=0; i<subviewsCount; i++) {
        NSView* viewAt = [assetView.subviews objectAtIndex:i];
        if([viewAt isKindOfClass:[MJCaptureSlideView class]]){
            MJCaptureSlideView* view = [assetView.subviews objectAtIndex:i];
            if (view.isMouseDown_&&view.isHasForcus_&&view.funType_==MJCToolBarFunTriangleArrow) {
                newView = view;
            }
        }
    }
    
    return newView;
}
-(MJCaptureSlideView*)getLastSlideView{
    MJCaptureSlideView* newView = nil;
    MJCaptureAssetView* assetView = [(MJCaptureView*)self.superview assetView];
    newView = [[assetView subviews] lastObject];
    return newView;
}


//}
- (void)mouseDown:(NSEvent*)theEvent {
    firstMouseDonwPoint_ = theEvent.locationInWindow;
    ArrowSlideView_ = [self getArrowSlideView];
    /*-------------------------------------------------------------------*/
    MJCaptureAssetView* view = (MJCaptureAssetView*)[(MJCaptureView*)[self superview] assetView];
    NSPoint tempPoint = [self convertPoint:firstMouseDonwPoint_ fromView:nil];
    if (NSPointInRect(tempPoint, focusre[0])) {
        view.isPointInfirst = YES;
    }else{
        view.isPointInfirst = NO;
    }
    /*-------------------------------------------------------------------*/
    if (theEvent.clickCount >= 2) {
        [(MJCaptureView*)[self superview] upSelectSlideViewRect];
        [self setHidden:YES];
        [(MJCaptureView*)[self superview] makeSelectSlideTextViewFocus];
        return;
    }
    
    //add by liuchipeng 2016.1.21{
    slideShapeOldFrameRect_ = [self frame];
    state_ = [self getMouseActionType:firstMouseDonwPoint_];
    [self setCursorForState:state_];
    //}
    
}

- (void)mouseUp:(NSEvent *)theEvent{
    if (((MJCaptureSlideView *)[self getFocusSlideView]).funType_ == MJCToolBarFunText
        && ((MJCaptureSlideView *)[self getFocusSlideView]).isHasForcus_) {
        return;
    }
    MJCaptureAssetView* view = (MJCaptureAssetView*)[(MJCaptureView*)[self superview] assetView];
    view.isPointInfirst = NO;
    [view setIsEditing_:NO];
    _crossArrow = NO;
    NSPoint pt = theEvent.locationInWindow;
    [(MJCaptureView*)[self superview] upSelectSlideViewRect];
    
    //add by liuchipeng 2015.1.21 {
    BOOL change = (state_ == MJCMouseInCropMove) ? NO : YES;
    if (change) {
        /*-----------------------------------------------------------------*/
        MJCaptureSlideView *sview = [self getFocusSlideView];
        if (sview.funType_==MJCToolBarFunTriangleArrow) {
            
            [view mouseUp:theEvent];
            view.isPointInfirst = NO;
            [ArrowSlideView_ removeFromSuperview];
            MJCaptureSlideView *newView = [self getLastSlideView];
            newView.isMouseDown_ = YES;
            newView.isHasForcus_ = YES;
            [(MJCaptureView*)[self superview] showSlideShapeView:newView];
        }
        /*-----------------------------------------------------------------*/
    }else{//拖动后更新箭头前后2点坐标
        ArrowSlideView_ = [self getArrowSlideView];
        MJCaptureAssetView* view = (MJCaptureAssetView*)[(MJCaptureView*)[self superview] assetView];
        view.firstMouseDonwPoint = [view convertPoint:[ArrowSlideView_ firstTrianglePoint_] fromView:ArrowSlideView_];
        view.lastMousePoint = [view convertPoint:[ArrowSlideView_ secondTrianglePoint_] fromView:ArrowSlideView_];
    }
    firstBeginDrag_ = NO;
    state_ = [self getMouseActionType:pt];
    [self setCursorForState:state_];
    
    MJCaptureSlideView* sview = [self getFocusSlideView];
  [(MJCaptureView*)[self superview] showSlideShapeView:sview];
  [(MJCaptureView*)[self superview] setFunType_:sview.funType_];
  
    //}
}

- (void)mouseDragged:(NSEvent *)theEvent{
    if (((MJCaptureSlideView *)[self getFocusSlideView]).funType_ == MJCToolBarFunText
        && ((MJCaptureSlideView *)[self getFocusSlideView]).isHasForcus_) {
        return;
    }
    
    [(MJCaptureView*)[self superview] upSelectSlideViewRect];
    
    //add by liuchipeng 2016.1.21{
    [super mouseDragged:theEvent];
    NSPoint pt = theEvent.locationInWindow;
    
    if (((MJCaptureView*)[self superview]).isCapture_) {
        if (firstBeginDrag_) {
            BOOL change = (state_ == MJCMouseInCropMove) ? NO : YES;
            [self mouseDraggeFromChangeFrame:pt isChangeSize:(BOOL)change event:theEvent];
            if(change){
                /*-----------------------------------------------------------------*/
                MJCaptureAssetView* view = (MJCaptureAssetView*)[[self getFocusSlideView] superview];
                [view setIsEditing_:YES];
                [ArrowSlideView_ setHidden:YES];
                [view mouseDragged:theEvent];
                /*-----------------------------------------------------------------*/
            }
        }else{
            firstBeginDrag_ = YES;
            mouseDragAction_ = [self getMouseActionType:pt];
            BOOL change = (state_ == MJCMouseInCropMove) ? NO : YES;
            [self mouseDraggeFromChangeFrame:pt isChangeSize:(BOOL)change event:theEvent];
        }
        [self setCursorForState:state_];
        
        
    }
    
    //}
    
    
}
//add by liuchipeng 2016.1.21{
- (void)mouseMoved:(NSEvent *)theEvent{
    [super mouseMoved:theEvent];
    NSPoint pt = theEvent.locationInWindow;
    MJCMouseState state = [self getMouseActionType:pt];
    [self setCursorForState:state];
}
#pragma mark key action
- (BOOL) acceptsFirstResponder{
  return YES;
}
- (BOOL)becomeFirstResponder{
  return YES;
}
- (BOOL)resignFirstResponder{
  return YES;
}
-(void)keyDown:(NSEvent *)theEvent{
    if (theEvent.keyCode==53) {
        [self setHidden:YES];
        [self setNeedsDisplay:YES];
    }
  
  NSRect newRect = self.frame;
  if(theEvent.keyCode==123 ||
     theEvent.keyCode==125 ||
     theEvent.keyCode==124 ||
     theEvent.keyCode==126){
    if(theEvent.keyCode==124){
      newRect.origin.x += 1;
      [self setFrame:newRect];
    }
    if(theEvent.keyCode==123){
      newRect.origin.x -= 1;
      [self setFrame:newRect];
    }
    if(theEvent.keyCode==125){
      newRect.origin.y -= 1;
      [self setFrame:newRect];
    }
    if(theEvent.keyCode==126){
      newRect.origin.y += 1;
      [self setFrame:newRect];
    }
    newRect = NSIntegralRect(newRect);
    [self setFrame:newRect];
    [(MJCaptureView*)[self superview] upSelectSlideViewRect];
  }
}

-(void)reDrawFocusPoint:(NSRect)rect{
    float x = rect.origin.x;
    float y = rect.origin.y;
    focusre[0].origin = NSMakePoint(x, y);
    
    x += rect.size.width;
    y += rect.size.height;
    focusre[1].origin = NSMakePoint(x, y);
    
    //  更新assetView的firstMouseDonwPoint、lastMousePoint
    ArrowSlideView_ = [self getArrowSlideView];
    MJCaptureAssetView* view = (MJCaptureAssetView*)[(MJCaptureView*)[self superview] assetView];
    view.firstMouseDonwPoint = [view convertPoint:[ArrowSlideView_ firstTrianglePoint_] fromView:ArrowSlideView_];
    view.lastMousePoint = [view convertPoint:[ArrowSlideView_ secondTrianglePoint_] fromView:ArrowSlideView_];
    
    [self setNeedsDisplay:YES];
    
}

//}

@end

