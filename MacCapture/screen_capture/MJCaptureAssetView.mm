//
//  MJCaptureAssetView.m
//  MacCapture
//
//  Created by mengjianjun on 15/8/22.
//  Copyright (c) 2015年 jacky.115.com. All rights reserved.
//

#import "MJCaptureAssetView.h"
#import "MJCaptureView.h"

@implementation MJCaptureAssetView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _isRedraw = NO;
        _isPointInfirst = NO;
        isCanDragLastPoint = NO;
        isCanDragFirstPoint = NO;
        self.isEditing_ = NO;
        _isDragging = NO;
        brushPoint_ = [[NSMutableArray alloc] init];
        slideArrayView_ = [[NSMutableArray alloc] init];
        
        //ps:注意，如果没有经过awakeFromNib的话，还需要加上acceptsFirstResponder才能让mouseMoved起作用
        //        [self addTrackingRect:self.bounds owner:self userData:nil assumeInside:YES];
        NSTrackingAreaOptions options = (NSTrackingActiveAlways | NSTrackingInVisibleRect |
                                         NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved);
        trackingArea_ = [[NSTrackingArea alloc] initWithRect:[self bounds]
                                                     options:options
                                                       owner:self
                                                    userInfo:nil];
        [self addTrackingArea:trackingArea_];
        
        mosaicView_ = nil;
    }
    return self;
}

- (void)dealloc{
    [slideArrayView_ release];
    [brushPoint_ release];
    [trackingArea_ release];
    
    for (int i = (int)[[self subviews] count] - 1; i >= 0; i--) {
        MJCaptureSlideView *slideView = [[self subviews] objectAtIndex:i];
        [slideView removeFromSuperview];
        [slideView release];
    }
    
    [super dealloc];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    if (self.isEditing_) {
        [((MJCaptureView*)[self superview]).brushColor_ set];
        switch (((MJCaptureView*)[self superview]).funType_) {
            case MJCToolBarFunRectangle:
            case MJCToolBarFunCircle:
                break;
            case MJCToolBarFunTriangleArrow:
            {
              if (_firstMouseDonwPoint.x == _lastMousePoint.x
                  && _firstMouseDonwPoint.y == _lastMousePoint.y){
                return;
              }
              if (((MJCaptureView*)[self superview]).funType_ == MJCToolBarFunTriangleArrow &&
                  fabs(_firstMouseDonwPoint.x-_lastMousePoint.x) < ((MJCaptureView*)[self superview]).nLineWidth_*2 &&
                  fabs(_firstMouseDonwPoint.y-_lastMousePoint.y) < ((MJCaptureView*)[self superview]).nLineWidth_*2){
                return;
              }
                CGContextRef context = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
                drawTriangleArrow(context, NSPointToCGPoint(_firstMouseDonwPoint), NSPointToCGPoint(_lastMousePoint), ((MJCaptureView*)[self superview]).nLineWidth_);
            }
                break;
            case MJCToolBarFunText:
            {
                
            }
                break;
            case MJCToolBarFunBrush:
            {
                NSBezierPath *brushPath = [NSBezierPath bezierPath];
                for (int i = 0; i < (int)[brushPoint_ count]; i++) {
                    if (i == 0) {
                        [brushPath moveToPoint:NSPointFromString([brushPoint_ objectAtIndex:i])];
                    }else{
                        [brushPath lineToPoint:NSPointFromString([brushPoint_ objectAtIndex:i])];
                    }
                }
                [brushPath setLineWidth:((MJCaptureView*)[self superview]).nLineWidth_];
                [brushPath setLineCapStyle:NSRoundLineCapStyle];
                [brushPath setLineJoinStyle:NSMiterLineJoinStyle];
                [brushPath stroke];
            }
                break;
                
            default:
                break;
        }
    }
}

- (void)resetSlideFocusNone{
    [self.window makeFirstResponder:self];
    NSArray *array = [self subviews];
    for (int i = (int)[array count] - 1; i >= 0; i--){
        NSView* viewAt = [array objectAtIndex:i];
        if([viewAt isKindOfClass:[MJCaptureSlideView class]]){
            MJCaptureSlideView *view = [array objectAtIndex:i];
            view.isMouseDown_ = NO;
            [view slideTextView].isMouseDoubleClick_ = NO;
            view.isHasForcus_ = NO;
            view.isMouseDown_ = NO;
            view.isPointOnPath_ = NO;
            if (view.funType_ == MJCToolBarFunText) {
                if ([[view.slideTextView string] length] == 0) {
                    [self RemoveCaptureSlideView:(MJCaptureSlideView*)view];
                }else{
                    [view setNeedsDisplay:YES];
                }
                [view.slideTextView setSelectedRange:NSMakeRange([[view.slideTextView string] length], 0)];
            }
        }
    }
}

- (void)mouseDown:(NSEvent*)theEvent {
  [self resetSlideFocusNone];
  
  
  ///add by aries
  if(((MJCaptureView*)[self superview]).funType_ == MJCToolBarFunMosaic){
    if(mosaicView_){
      [mosaicView_ mouseDown:theEvent];
    }
    return;
  }
  ///}
  
  [brushPoint_ removeAllObjects];
    [[self enclosingScrollView] setDocumentCursor:[NSCursor crosshairCursor]];
    self.isEditing_ = YES;
    NSPoint pt = theEvent.locationInWindow;
    _firstMouseDonwPoint = _lastMousePoint = [self convertPoint:pt fromView:nil];
  
    if (!NSPointInRect(_firstMouseDonwPoint, [self bounds]))
    [[self window] makeFirstResponder:self];
    //aries test
    switch (((MJCaptureView*)[self superview]).funType_) {
        case MJCToolBarFunRectangle:
        case MJCToolBarFunCircle:{
            if (!currentAddingView_) {
                currentAddingView_ = [[MJCaptureSlideView alloc] initWithFrame:NSZeroRect withType:((MJCaptureView*)[self superview]).funType_];
                [self addSubview:currentAddingView_];
                [currentAddingView_.brushPath_ moveToPoint:[currentAddingView_ convertPoint:_firstMouseDonwPoint fromView:self]];
                [currentAddingView_ setBrushColor:((MJCaptureView*)[self superview]).brushColor_];
                currentAddingView_.nLineWidth_ = ((MJCaptureView*)[self superview]).nLineWidth_;
            }
        }
            break;
        case MJCToolBarFunBrush:{
            [brushPoint_ removeAllObjects];
            [brushPoint_ addObject:NSStringFromPoint(_firstMouseDonwPoint)];
        }
            break;
        case MJCToolBarFunTriangleArrow:
            break;
        case MJCToolBarFunText:{
            NSRect rect = NSZeroRect;
            rect.origin = _firstMouseDonwPoint;
            rect.size = NSMakeSize(40, 26);
            MJCaptureSlideView *slideView = [[MJCaptureSlideView alloc] initWithFrame:rect withType:((MJCaptureView*)[self superview]).funType_];
            [slideView setBrushColor:((MJCaptureView*)[self superview]).brushColor_];
            slideView.nLineWidth_ = ((MJCaptureView*)[self superview]).nLineWidth_;
            slideView.nFontSize_ = ((MJCaptureView*)[self superview]).nFontSize_;
            [slideView upSelectSlideViewFontSize];
            
            [self AddCaptureSlideView:slideView];
        }
            break;
      default:
        self.isEditing_ = NO;
        [brushPoint_ removeAllObjects];
            break;
    }
}
- (void)mouseUp:(NSEvent *)theEvent{
    ///add by aries
    if(((MJCaptureView*)[self superview]).funType_ == MJCToolBarFunMosaic){
        if(mosaicView_){
            [mosaicView_ mouseUp:theEvent];
        }
        return;
    }
    ///}
    //[super mouseUp:theEvent];  //modify by aries
    
    _isDragging = NO;
    if(!_isPointInfirst){
        _lastMousePoint = [self convertPoint:theEvent.locationInWindow fromView:nil];
    }
    self.isEditing_ = NO;
    [self setNeedsDisplay:YES];
    
    switch (((MJCaptureView*)[self superview]).funType_) {
        case MJCToolBarFunRectangle:
        case MJCToolBarFunCircle:
        case MJCToolBarFunTriangleArrow:{
            NSRect rect = NSZeroRect;
            rect.origin.x = MIN(_firstMouseDonwPoint.x, _lastMousePoint.x);
            rect.origin.y = MIN(_firstMouseDonwPoint.y, _lastMousePoint.y);
            rect.size.width = fabs(_firstMouseDonwPoint.x-_lastMousePoint.x);
            rect.size.height = fabs(_firstMouseDonwPoint.y-_lastMousePoint.y);
            
            MJCaptureSlideView *slideView = [[MJCaptureSlideView alloc] initWithFrame:rect withType:((MJCaptureView*)[self superview]).funType_];
            slideView.nLineWidth_ = ((MJCaptureView*)[self superview]).nLineWidth_;
            [slideView setBrushColor:((MJCaptureView*)[self superview]).brushColor_];
            
            rect.origin.x -= slideView.nLineWidth_/2.0;
            rect.origin.y -= slideView.nLineWidth_/2.0;
            rect.size.width += slideView.nLineWidth_;
            rect.size.height += slideView.nLineWidth_;
            rect = NSIntegralRect(rect);
            [slideView setFrame:rect];
            slideView.brushPath_ = currentAddingView_.brushPath_;
            
            if (((MJCaptureView*)[self superview]).funType_ != MJCToolBarFunTriangleArrow &&
              (rect.size.width < slideView.nLineWidth_*1.5 || rect.size.height < slideView.nLineWidth_*1.5)) {
                if (currentAddingView_) {
                    [currentAddingView_.brushPath_ lineToPoint:[currentAddingView_ convertPoint:_lastMousePoint fromView:self]];
                    [currentAddingView_ removeFromSuperview];
                    [currentAddingView_ release];
                    currentAddingView_ = nil;
                }
                return;
            }
          if (((MJCaptureView*)[self superview]).funType_ == MJCToolBarFunTriangleArrow &&
              //(rect.size.width < slideView.nLineWidth_*1.2 || rect.size.height < slideView.nLineWidth_*1.2) &&
              fabs(_firstMouseDonwPoint.x-_lastMousePoint.x) < slideView.nLineWidth_*2 &&
              fabs(_firstMouseDonwPoint.y-_lastMousePoint.y) < slideView.nLineWidth_*2){
            return;
          }
            
            [self AddCaptureSlideView:slideView];
            
            if (((MJCaptureView*)[self superview]).funType_ == MJCToolBarFunTriangleArrow) {
                if (rect.size.width < getTriangleArrowWidth()) {
                    rect.origin.x -= (getTriangleArrowWidth()-rect.size.width)/2.0;
                    rect.size.width = getTriangleArrowWidth();
                }
                if (rect.size.height < getTriangleArrowWidth()) {
                    rect.origin.y -= (getTriangleArrowWidth()-rect.size.height)/2.0;
                    rect.size.height = getTriangleArrowWidth();
                }
                rect = NSIntegralRect(rect);
                [slideView setFrame:rect];
                
                slideView.firstTrianglePoint_ = NSMakePoint(_firstMouseDonwPoint.x-rect.origin.x, _firstMouseDonwPoint.y-rect.origin.y);
                slideView.secondTrianglePoint_ = NSMakePoint(_lastMousePoint.x-rect.origin.x, _lastMousePoint.y-rect.origin.y);
            }
            
            if (currentAddingView_) {
                [currentAddingView_.brushPath_ lineToPoint:[currentAddingView_ convertPoint:_lastMousePoint fromView:self]];
                [currentAddingView_ removeFromSuperview];
                [currentAddingView_ release];
                currentAddingView_ = nil;
            }
        }
            break;
        case MJCToolBarFunBrush:{
            [brushPoint_ addObject:NSStringFromPoint(_lastMousePoint)];
            [self setNeedsDisplay:YES];
            
            NSRect rect = NSZeroRect;
            MJCaptureSlideView *slideView = [[MJCaptureSlideView alloc] initWithFrame:rect withType:((MJCaptureView*)[self superview]).funType_];
            slideView.nLineWidth_ = ((MJCaptureView*)[self superview]).nLineWidth_;
            [slideView setBrushColor:((MJCaptureView*)[self superview]).brushColor_];
            
            NSBezierPath *tempPath = [NSBezierPath bezierPath];
            for (int i = 0; i < (int)[brushPoint_ count]; i++) {
                NSPoint point = NSPointFromString([brushPoint_ objectAtIndex:i]);
                if (i == 0) {
                    [tempPath moveToPoint:point];
                }else{
                    [tempPath lineToPoint:point];
                }
            }
            rect = [tempPath bounds];
            rect.origin.x -= slideView.nLineWidth_/2.0;
            rect.origin.y -= slideView.nLineWidth_/2.0;
            rect.size.width += slideView.nLineWidth_;
            rect.size.height += slideView.nLineWidth_;
            rect = NSIntegralRect(rect);
            [slideView setFrame:rect];
            for (int i = 0; i < (int)[brushPoint_ count]; i++) {
                NSPoint point = NSPointFromString([brushPoint_ objectAtIndex:i]);
                point.x -= rect.origin.x;
                point.y -= rect.origin.y;
                if (i == 0) {
                    [slideView.brushPath_ moveToPoint:point];
                }else{
                    [slideView.brushPath_ lineToPoint:point];
                }
            }
            if ((_lastMousePoint.x == _firstMouseDonwPoint.x) && (_lastMousePoint.y == _firstMouseDonwPoint.y)) {
                return;
            }
            
            [self AddCaptureSlideView:slideView];
        }
            break;
        case MJCToolBarFunText:
            break;
        default:
            break;
    }
    
}
- (void)mouseEntered:(NSEvent*)theEvent {
    ///add by aries
    if(((MJCaptureView*)[self superview]).funType_ == MJCToolBarFunMosaic){
        if(mosaicView_){
            [mosaicView_ mouseEntered:theEvent];
        }
        return;
    }
    ///}
    //[super mouseEntered:theEvent];  //modify by aries
    
    [[self enclosingScrollView] setDocumentCursor:[NSCursor crosshairCursor]];
}

- (void)mouseExited:(NSEvent*)theEvent {
    ///add by aries
    if(((MJCaptureView*)[self superview]).funType_ == MJCToolBarFunMosaic){
        if(mosaicView_){
            [mosaicView_ mouseExited:theEvent];
        }
        return;
    }
    ///}
    //[super mouseExited:theEvent];
    [[self enclosingScrollView] setDocumentCursor:[NSCursor arrowCursor]];
}

- (void)mouseMoved:(NSEvent *)theEvent{
    ///add by aries
    if(((MJCaptureView*)[self superview]).funType_ == MJCToolBarFunMosaic){
        if(mosaicView_){
            [mosaicView_ mouseMoved:theEvent];
        }
        return;
    }
    ///}
    //[super mouseMoved:theEvent];
    //NSLog(@"MJCaptureAssetView: %@", @"mouseMoved");
    [[self enclosingScrollView] setDocumentCursor:[NSCursor arrowCursor]];
    
}

- (void)mouseDragged:(NSEvent *)theEvent{
    ///add by aries{
    if(((MJCaptureView*)[self superview]).funType_ == MJCToolBarFunMosaic){
        if(mosaicView_){
            [mosaicView_ mouseDragged:theEvent];
        }
        return;
    }
    ///}
    
    NSPoint pt = theEvent.locationInWindow;
    _isDragging = YES;
    if(!_isPointInfirst){
    _lastMousePoint = [self convertPoint:pt fromView:nil];
    }else{
        _firstMouseDonwPoint =[self convertPoint:pt fromView:nil];
    }
    switch (((MJCaptureView*)[self superview]).funType_) {
        case MJCToolBarFunRectangle:
        case MJCToolBarFunCircle:
        case MJCToolBarFunText:{
            NSRect rect = NSZeroRect;
            rect.origin.x = MIN(_firstMouseDonwPoint.x, _lastMousePoint.x);
            rect.origin.y = MIN(_firstMouseDonwPoint.y, _lastMousePoint.y);
            rect.size.width = fabs(_firstMouseDonwPoint.x-_lastMousePoint.x);
            rect.size.height = fabs(_firstMouseDonwPoint.y-_lastMousePoint.y);
            
            rect.origin.x -= ((MJCaptureView*)[self superview]).nLineWidth_/2.0;
            rect.origin.y -= ((MJCaptureView*)[self superview]).nLineWidth_/2.0;
            rect.size.width += ((MJCaptureView*)[self superview]).nLineWidth_;
            rect.size.height += ((MJCaptureView*)[self superview]).nLineWidth_;
            rect = NSIntegralRect(rect);
            
            //aries test
            //
            [currentAddingView_ setFrame:rect];
        }
            break;
        case MJCToolBarFunBrush:{
            //            NSRect rect = NSZeroRect;
            //            [currentAddingView_.brushPath_ lineToPoint:[currentAddingView_ convertPoint:lastMousePoint_ fromView:self]];
            //            rect = [currentAddingView_.brushPath_ bounds];
            //            rect = NSIntegralRect(rect);
            //            [currentAddingView_ setFrame:rect];
            
            [brushPoint_ addObject:NSStringFromPoint(_lastMousePoint)];
            [self setNeedsDisplay:YES];
        }
            break;
        case MJCToolBarFunTriangleArrow:{
//            MJCaptureSlideView *slideView = [self getFocusSlideView];
            [self setNeedsDisplay:YES];
        }
            break;
            
        default:
            break;
    }
}

///add by aries{
- (void) beginMosaic:(NSImage*)bgImg foreground:(NSImage*) forImg
{
    CGFloat mosaicLineWidth = ((MJCaptureView*)[self superview]).nLineWidth_;
    mosaicLineWidth *= 3;
    
    mosaicView_ = [[MJMosaicView alloc] initWithFrame:NSMakeRect(0, 0, [self frame].size.width, [self frame].size.height) backgroundImg:bgImg forgroundImg:forImg lineWidth:mosaicLineWidth];
    [self AddMosaicView:mosaicView_];
}

- (void) beginChangeMosaic:(int)sliderValue
{
    if(mosaicView_){
        //NSImage* bgImg = [MJMosaicUtil transToMosaicImage:image blockLevel:10];
        [mosaicView_ changeMosaic:sliderValue];
    }
}

- (MJMosaicView*) getMosaicView
{
    return mosaicView_;
}
///}

#pragma mark undo manager
- (void)AddCaptureSlideView:(MJCaptureSlideView*)slideView{
    [[[[self window] undoManager] prepareWithInvocationTarget:self] RemoveCaptureSlideView:slideView];
    [slideArrayView_ addObject:slideView];
    [self addSubview:slideView];
    [((MJCaptureView*)[self superview]) hideSlideShapeView];
}
- (void)RemoveCaptureSlideView:(MJCaptureSlideView*)slideView{
    [[[[self window] undoManager] prepareWithInvocationTarget:self] AddCaptureSlideView:slideView];
    [slideArrayView_ removeObject:slideView];
    [slideView removeFromSuperview];
    [slideView release];
    
    if ([mosaicView_ drawView]) {
        [mosaicView_ drawView].firstPoint = NSMakePoint(-100, -100);
        [mosaicView_ drawView].lastPoint = NSMakePoint(-100, -100);
        [[mosaicView_ drawView] removeAllObject];
        [[mosaicView_ drawView] setNeedsDisplay:YES];
    }
    
    [[self window] makeFirstResponder:self];
    if (self.isEditing_) {
        _firstMouseDonwPoint = NSZeroPoint;
        _lastMousePoint = NSZeroPoint;
    }
    [self setNeedsDisplay:YES];
    [((MJCaptureView*)[self superview]) hideSlideShapeView];
}

- (void) AddMosaicView:(MJMosaicView*) mosaicView
{
//    [[[[self window] undoManager] prepareWithInvocationTarget:self] RemoveMosaicView:mosaicView];
//    [self addSubview:mosaicView];
    [self addSubview:mosaicView positioned:NSWindowBelow relativeTo:slideArrayView_.firstObject];
    [self showSlideArrayView];
}

- (void)showSlideArrayView {
    for (NSView *view in slideArrayView_) {
        view.hidden = NO;
    }
}

- (void)hideSlideArrayView {
    for (NSView *view in slideArrayView_) {
        view.hidden = YES;
    }
}

- (void) RemoveMosaicView:(MJMosaicView*) mosaicView
{
//    [[[[self window] undoManager] prepareWithInvocationTarget:self] AddMosaicView:mosaicView];
    [mosaicView removeFromSuperview];
    [mosaicView release];
}

@end

