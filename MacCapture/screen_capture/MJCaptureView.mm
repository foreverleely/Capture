//
//  MJCaptureView.m
//  MacCapture
//
//  Created by 115Browser on 8/16/15.
//  Copyright (c) 2015 jacky.115.com. All rights reserved.
//

#import "MJCaptureView.h"
#import "MJCaptureWindow.h"
#import "AppDelegate.h"
#import "MJPersistentUtil.h"

#import <CoreAudio/CoreAudio.h>
#import <CoreAudioKit/CoreAudioKit.h>
#import <AudioToolbox/AudioToolbox.h>

extern NSString *kAppNameKey;
extern NSString *kWindowOriginKey;
extern NSString *kWindowSizeKey;
extern NSString *kWindowFrameKey;
extern NSString *kWindowIsOnscreenKey;
extern NSString *kWindowIDKey;
extern NSString *kWindowLevelKey;
extern NSString *kWindowOrderKey;



@implementation MJScreenShotImageView
@synthesize isSaving_;
- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        isSaving_ = NO;
    }
    return self;
}
- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    if (isSaving_) {
        return;
    }
    // Drawing code here.
    if (!((MJCaptureView*)[self superview]).isCapture_ && ((MJCaptureView*)[self superview]).isPreCapture_) {
        [[NSColor colorWithCalibratedRed:1 green:0.1 blue:0.1 alpha:0.5] set];
//        if (NSIsEmptyRect(((MJCaptureView*)[self superview]).oldRangeRect_)) {
//            return;
//        }
        NSRect tempRect = ((MJCaptureView*)[self superview]).oldRangeRect_;
        tempRect = NSInsetRect(tempRect, ((MJCaptureView*)[self superview]).selectRangeView_.nSpanValue_/2.0, ((MJCaptureView*)[self superview]).selectRangeView_.nSpanValue_/2.0);
        
        CGContextRef context = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
        if (context != NULL) {
            
            //做编辑框内部透明效果
            CGMutablePathRef path = CGPathCreateMutable();
            CGPathAddRect(path, nil, NSRectToCGRect(dirtyRect));
            CGPathAddRect(path, nil, NSRectToCGRect(tempRect));
            CGContextSetRGBFillColor(context, 0.1, 0.1, 0.1, 0.5);
            CGContextAddPath(context, path);
            //            CGContextFillPath(context);
            CGContextDrawPath(context, kCGPathEOFill);
            CFRelease(path);
        }
        
        [[NSColor colorWithCalibratedRed:0.035 green:0.529 blue:0.957 alpha:1] set];
        NSBezierPath *strokePath = [NSBezierPath bezierPathWithRect:tempRect];
        [strokePath setLineWidth:3];
        [strokePath stroke];
    }
    if (((MJCaptureView*)[self superview]).isCapture_ && !((MJCaptureView*)[self superview]).isPreCapture_) {
        [[NSColor colorWithCalibratedRed:0.1 green:0.1 blue:0.1 alpha:0.5] set];
        NSRect tempRect = ((MJCaptureView*)[self superview]).oldRangeRect_;
        tempRect = NSInsetRect(tempRect, ((MJCaptureView*)[self superview]).selectRangeView_.nSpanValue_/2.0, ((MJCaptureView*)[self superview]).selectRangeView_.nSpanValue_/2.0);
        NSBezierPath *path = [NSBezierPath bezierPathWithRect:NSMakeRect(dirtyRect.origin.x, dirtyRect.origin.y, tempRect.origin.x, dirtyRect.size.height)];
        [path appendBezierPathWithRect:NSMakeRect(NSMaxX(tempRect), dirtyRect.origin.y, dirtyRect.size.width-NSMaxX(tempRect), dirtyRect.size.height)];
        [path appendBezierPathWithRect:NSMakeRect(tempRect.origin.x, dirtyRect.origin.y, tempRect.size.width, tempRect.origin.y)];
        [path appendBezierPathWithRect:NSMakeRect(tempRect.origin.x, NSMaxY(tempRect), tempRect.size.width, dirtyRect.size.height-NSMaxY(tempRect))];
        [path fill];
    }else{
    }
}
- (void)mouseDown:(NSEvent*)theEvent {
    [super mouseDown:theEvent];
}
- (void)mouseUp:(NSEvent *)theEvent{
    [super mouseUp:theEvent];
}
- (void)mouseEntered:(NSEvent*)theEvent {
    [super mouseEntered:theEvent];
}

- (void)mouseExited:(NSEvent*)theEvent {
    [super mouseExited:theEvent];
}

- (void)mouseMoved:(NSEvent *)theEvent{
    [super mouseMoved:theEvent];
}
@end

@interface MJCaptureView (Private)


@end

@implementation MJCaptureView

@synthesize isPreCapture_, isCapture_, isEdit_, funType_, nLineWidth_, brushColor_, nFontSize_, oldRangeRect_, selectRangeView_;

uint32_t MJCaptureViewChangeBits(uint32_t currentBits, uint32_t flagsToChange, BOOL setFlags)
{
    if(setFlags)
    {	// Set Bits
        return currentBits | flagsToChange;
    }
    else
    {	// Clear Bits
        return currentBits & ~flagsToChange;
    }
}

- (void)activeCaptureViewLater{
//    [[self window] makeKeyWindow];
//    [[self window] makeFirstResponder:self];
//    [self keyDown:[NSApp currentEvent]];
    
    [NSApp activateIgnoringOtherApps:YES];
    [NSApp setWindowsNeedUpdate:YES];
    [[self window] makeKeyAndOrderFront:[self window]];
    
    //这个必须要，否则从快捷键启动过来的时候，会出现点击两次才能截图的问题
    [[self window] becomeKeyWindow];
    [[self window] makeFirstResponder:self];
}
- (void)beginCaptureImage{
    captureModel_ = [[MJCaptureModel alloc] init];
    
    MJCaptureWindow *window = (MJCaptureWindow*)[self window];
    //[captureModel_ setDelegate:self];
    CGImageRef imageRef = [captureModel_ createScreenShotImage];
    if(imageRef != NULL)
    {
        // Create a bitmap rep from the image...
        NSBitmapImageRep *bitmapRep = [[NSBitmapImageRep alloc] initWithCGImage:imageRef];
        // Create an NSImage and add the bitmap rep to it...
        NSImage *image = [[NSImage alloc] init];
        [image addRepresentation:bitmapRep];
        [bitmapRep release];
        // Set the output view to the new NSImage.
        [screenShotImageView_ setImage:image];
        //[window setScreenShotImage:image];
        [image release];
        
        CGImageRelease(imageRef);
    }
    else
    {
        //[screenShotImageView_ setImage:nil];
        [window setScreenShotImage:nil];
    }
    
    if ([prunedWindowList_ count] == 0) {
        [prunedWindowList_ release];
        CGWindowListOption listOptions = kCGWindowListOptionAll;
        listOptions = MJCaptureViewChangeBits(listOptions, kCGWindowListOptionOnScreenOnly, YES);
        listOptions = MJCaptureViewChangeBits(listOptions, kCGWindowListExcludeDesktopElements, NO);
        //listOptions = MJCaptureViewChangeBits(listOptions, kCGWindowListOptionIncludingWindow, YES);
        prunedWindowList_ = [[NSMutableArray alloc] initWithArray:[captureModel_ getWindowList:listOptions windowID:kCGNullWindowID]];
    }
    
    [self performSelector:@selector(activeCaptureViewLater) withObject:nil afterDelay:0.01];
}

- (NSImage*)getScreenShotImage{
    return [screenShotImageView_ image];
}
- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        isPreCapture_ = YES;
        isCapture_ = NO;
        isEdit_ = NO;
        isAfterClean = NO;
        funType_ = MJCToolBarFunRectangle;
        //nLineWidth_ = 4;
        //add by aries{
        //nLineWidth_ = [MJPersistentUtil lineWidth];
        //if(nLineWidth_ == 0){
            nLineWidth_ = 3;
            //[MJPersistentUtil setLineWidth:3];
        //}
        ///}
        prunedWindowList_ = [[NSMutableArray alloc] init];
        brushColor_  = [[NSColor redColor] retain];

        nFontSize_ = 16;

        
        screenShotImageView_ = [[[MJScreenShotImageView alloc] initWithFrame:NSMakeRect(0, 0, frame.size.width, frame.size.height)] autorelease];
        [self addSubview:screenShotImageView_];
        
        selectRangeView_ = [[MJCaptureSelectRangeView alloc] initWithFrame:NSZeroRect];
        [self addSubview:selectRangeView_];
        
        _assetView = [[[MJCaptureAssetView alloc] initWithFrame:NSMakeRect(0, 0, 350, 40)] autorelease];
        [self addSubview:_assetView];
        [_assetView setHidden:YES];
        
        ///modify by aries{
        _toolbarView = [[[MJCaptureToolBarView alloc] initWithFrame:NSMakeRect(0, 0, 416 + 32, 44)] autorelease];
        ///}
        [self addSubview:_toolbarView];
        [_toolbarView setHidden:YES];
        
        _slideShapeView = [[[MJSlideShapeView alloc] initWithFrame:NSMakeRect(0, 0, 0, 0)] autorelease];
        [self addSubview:_slideShapeView];
        [_slideShapeView setHidden:YES];
       
        
        zoomInfoView_ = [[[MJCaptureZoomInfoView alloc] initWithFrame:NSMakeRect(0, 0, 0, 0)] autorelease];
        [self addSubview:zoomInfoView_];
        [zoomInfoView_ setHidden:YES];
        
        pointInfoView_ = [[[MJCaptureInfoView alloc] initWithFrame:NSMakeRect(0, 0, 90, 28)] autorelease];
        [self addSubview:pointInfoView_];
        [pointInfoView_ setHidden:YES];
        
        
        [screenShotImageView_ setWantsLayer:YES];
        [selectRangeView_ setHidden:YES];
        [selectRangeView_ setWantsLayer:YES];
        [_toolbarView setWantsLayer:YES];
        [_assetView setWantsLayer:YES];
        [self setWantsLayer:YES];
        
        //ps:注意，如果没有经过awakeFromNib的话，还需要加上acceptsFirstResponder才能让mouseMoved起作用
        //        [self addTrackingRect:self.bounds owner:self userData:nil assumeInside:YES];
        NSTrackingAreaOptions options = (NSTrackingActiveAlways | NSTrackingInVisibleRect |
                                         NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved);
        trackingArea_ = [[NSTrackingArea alloc] initWithRect:[self bounds]
                                                     options:options
                                                       owner:self
                                                    userInfo:nil];
        [self addTrackingArea:trackingArea_];
        //        [[self window] setAcceptsMouseMovedEvents:YES];
        
        //这里需要延迟，否则beginCaptureImage里面取[self window]就取不到值
        [self performSelector:@selector(beginCaptureImage) withObject:nil afterDelay:0];
        //[self beginCaptureImage];
    }
    return self;
}

- (void) dealloc{
    [trackingArea_ release];
    [prunedWindowList_ release];
    [captureModel_ release];
    [brushColor_ release];
    
    [super dealloc];
}

- (void)CleanOpationAndReStart{
    isAfterClean = YES;
    isPreCapture_ = YES;
    isCapture_ = NO;
    isEdit_ = NO;
    [_toolbarView setHidden:YES];
    
    [selectRangeView_ setHidden:YES];
    [[selectRangeView_ enclosingScrollView] setDocumentCursor:[NSCursor arrowCursor]];
    
    [_assetView removeFromSuperview];
    _assetView = nil;
    _assetView = [[[MJCaptureAssetView alloc] initWithFrame:NSMakeRect(0, 0, 350, 40)] autorelease];
    [self addSubview:_assetView];
    [_assetView setHidden:YES];
    
    
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    [screenShotImageView_ setNeedsDisplay];
    return;

//    if (!isCapture_ && isPreCapture_) {
//        [[NSColor colorWithCalibratedRed:1 green:0.1 blue:0.1 alpha:0.5] set];
//        if (NSIsEmptyRect(oldRangeRect_)) {
//            return;
//        }
//        NSRect tempRect = oldRangeRect_;
//        tempRect = NSInsetRect(tempRect, selectRangeView_.nSpanValue_/2.0, selectRangeView_.nSpanValue_/2.0);
//       
//        CGContextRef context = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
//        if (context != NULL) {
//            
//            //做编辑框内部透明效果
//            CGMutablePathRef path = CGPathCreateMutable();
//            CGPathAddRect(path, nil, NSRectToCGRect(dirtyRect));
//            CGPathAddRect(path, nil, NSRectToCGRect(tempRect));
//            CGContextSetRGBFillColor(context, 0.1, 0.1, 0.1, 0.5);
//            CGContextAddPath(context, path);
//            CGContextDrawPath(context, kCGPathEOFill);
//            CFRelease(path);
//        }
//        
//        [[NSColor colorWithCalibratedRed:0.035 green:0.529 blue:0.957 alpha:1] set];
//        NSBezierPath *strokePath = [NSBezierPath bezierPathWithRect:tempRect];
//        [strokePath setLineWidth:3];
//        [strokePath stroke];
//    }
//    if (isCapture_ && !isPreCapture_) {
//        [[NSColor colorWithCalibratedRed:0.1 green:0.1 blue:0.1 alpha:0.5] set];
//        NSRect tempRect = oldRangeRect_;
//        tempRect = NSInsetRect(tempRect, selectRangeView_.nSpanValue_/2.0, selectRangeView_.nSpanValue_/2.0);
//        NSBezierPath *path = [NSBezierPath bezierPathWithRect:NSMakeRect(dirtyRect.origin.x, dirtyRect.origin.y, tempRect.origin.x, dirtyRect.size.height)];
//        [path appendBezierPathWithRect:NSMakeRect(NSMaxX(tempRect), dirtyRect.origin.y, dirtyRect.size.width-NSMaxX(tempRect), dirtyRect.size.height)];
//        [path appendBezierPathWithRect:NSMakeRect(tempRect.origin.x, dirtyRect.origin.y, tempRect.size.width, tempRect.origin.y)];
//        [path appendBezierPathWithRect:NSMakeRect(tempRect.origin.x, NSMaxY(tempRect), tempRect.size.width, dirtyRect.size.height-NSMaxY(tempRect))];
//        [path fill];
//    }
}

#pragma mark slideShapeView operation


- (BOOL)isHiddenSlideShapeView{
    return [_slideShapeView isHidden];
}
- (void)showSlideShapeView:(MJCaptureSlideView*)view{
    [_slideShapeView setHidden:NO];
    [[_slideShapeView window] makeFirstResponder:_slideShapeView];
    NSRect rect = [view frame];
    rect = NSInsetRect(rect, view.nLineWidth_/2.0, view.nLineWidth_/2.0);
    rect = NSOffsetRect(rect, -_slideShapeView.nSpace_/2.0, -_slideShapeView.nSpace_/2.0);
    rect.size = NSMakeSize(rect.size.width+_slideShapeView.nSpace_, rect.size.height+_slideShapeView.nSpace_);
    rect = [self convertRect:rect fromView:_assetView];
    [_slideShapeView setFrame:rect];
    
    [_slideShapeView reDrawFocusPoint:rect];
    [_assetView setIsDragging:NO];
    [_slideShapeView setNeedsDisplay:YES];
}
- (void)hideSlideShapeView{
    [_slideShapeView setHidden:YES];
}
- (void)upSelectSlideViewRect{
    NSArray *array = [_assetView subviews];
    for (int i = 0; i < [array count]; i++){
        NSView* viewAt = [array objectAtIndex:i];
        if([viewAt isKindOfClass:[MJCaptureSlideView class]]){
            MJCaptureSlideView *view = [array objectAtIndex:i];
            if ((view.isMouseDown_ && view.isHasForcus_) || ((view.funType_ == MJCToolBarFunText) && ((view.isMouseDown_ || view.isHasForcus_)))) {
                NSRect rect = [_slideShapeView frame];
                rect = NSOffsetRect(rect, _slideShapeView.nSpace_/2.0, _slideShapeView.nSpace_/2.0);
                rect.size = NSMakeSize(rect.size.width-_slideShapeView.nSpace_, rect.size.height-_slideShapeView.nSpace_);
                
                rect = NSOffsetRect(rect, -view.nLineWidth_/2.0, -view.nLineWidth_/2.0);
                rect.size = NSMakeSize(rect.size.width+view.nLineWidth_, rect.size.height+view.nLineWidth_);
                
                rect = [_assetView convertRect:rect fromView:self];
                [view setFrame:rect];
                break;
            }
        }
    }
}
- (void)makeSelectSlideTextViewFocus{
    NSArray *array = [_assetView subviews];
    for (int i = 0; i < [array count]; i++){
        MJCaptureSlideView *view = [array objectAtIndex:i];
        if (view.funType_ == MJCToolBarFunText && (view.isMouseDown_ || view.isHasForcus_)) {
            [view makeSelectSlideTextViewFocus];
            break;
        }
    }
}

- (void)makeTextViewFocus{
    NSArray *array = [_assetView subviews];
    for (int i = 0; i < [array count]; i++){
        MJCaptureSlideView *view = [array objectAtIndex:i];
        if (view.funType_ == MJCToolBarFunText) {
            [view makeSelectSlideTextViewFocus];
            break;
        }
    }
}

- (void)upSelectSlideViewColor{
    NSArray *array = [_assetView subviews];
    for (int i = 0; i < [array count]; i++){
        MJCaptureSlideView *view = [array objectAtIndex:i];
        BOOL isWantMouseDown = NO;
        if (view.funType_ == MJCToolBarFunText && view.isHasForcus_) {
            isWantMouseDown  = YES;
        }else{
            if (view.isHasForcus_ && view.isMouseDown_) {
                isWantMouseDown = YES;
            }
        }
        if (view.isHasForcus_ && isWantMouseDown) {
            [view setBrushColor:brushColor_];
            [view setNeedsDisplay:YES];
            break;
        }
    }
}
- (void)upSelectSlideViewFontSize{
    NSArray *array = [_assetView subviews];
    for (int i = 0; i < [array count]; i++){
        MJCaptureSlideView *view = [array objectAtIndex:i];
        if (view.funType_ == MJCToolBarFunText && view.isHasForcus_) {
            [view setNFontSize_:nFontSize_];
            [view upSelectSlideViewFontSize];
            [view setNeedsDisplay:YES];
            break;
        }
    }
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

- (void)keyDown:(NSEvent *)theEvent{
    //add by liuchipeng 2016.1.6{按下方向键移动选择框
  if (!isEdit_) {
    if(theEvent.keyCode==124){
      NSRect newRect = selectRangeView_.frame;
      newRect.origin.x += 1;
      oldRangeRect_.origin.x += 1;
      NSRect newToolBarRect = _toolbarView.frame;
      newToolBarRect.origin.x +=1;
      [_toolbarView setFrame:newToolBarRect];
      [selectRangeView_ setFrame:newRect];
      NSRect newInfoRect = pointInfoView_.frame;
      newInfoRect.origin.x += 1;
      [pointInfoView_ setFrame:newInfoRect];
      [self setNeedsDisplay:YES];
    }
    if(theEvent.keyCode==123){
      NSRect newRect = selectRangeView_.frame;
      newRect.origin.x-=1;
      oldRangeRect_.origin.x-=1;
      [selectRangeView_ setFrame:newRect];
      NSRect newToolBarRect = _toolbarView.frame;
      newToolBarRect.origin.x -=1;
      [_toolbarView setFrame:newToolBarRect];
      NSRect newInfoRect = pointInfoView_.frame;
      newInfoRect.origin.x -= 1;
      [pointInfoView_ setFrame:newInfoRect];
      [self setNeedsDisplay:YES];
    }
    if(theEvent.keyCode==125){
      NSRect newRect = selectRangeView_.frame;
      newRect.origin.y-=1;
      oldRangeRect_.origin.y-=1;
      [selectRangeView_ setFrame:newRect];
      NSRect newToolBarRect = _toolbarView.frame;
      newToolBarRect.origin.y -=1;
      [_toolbarView setFrame:newToolBarRect];
      NSRect newInfoRect = pointInfoView_.frame;
      newInfoRect.origin.y -= 1;
      [pointInfoView_ setFrame:newInfoRect];
      [self setNeedsDisplay:YES];
    }
    if(theEvent.keyCode==126){
      NSRect newRect = selectRangeView_.frame;
      newRect.origin.y+=1;
      oldRangeRect_.origin.y+=1;
      [selectRangeView_ setFrame:newRect];
      NSRect newToolBarRect = _toolbarView.frame;
      newToolBarRect.origin.y +=1;
      [_toolbarView setFrame:newToolBarRect];
      NSRect newInfoRect = pointInfoView_.frame;
      newInfoRect.origin.y += 1;
      [pointInfoView_ setFrame:newInfoRect];
      [self setNeedsDisplay:YES];
    }
  }else{
    
  }
    //}
  
    //command + s 保存截图
    if (theEvent.modifierFlags == 0x100108 && theEvent.keyCode == 1 && isCapture_) {
        [self CreatSaveImage:YES];
        [NSApp stopModal];
        [NSApp endSheet:[self window]];
        [[self window] close];
    }
    
    
    if (theEvent.keyCode == 53) {//esc
        [NSApp stopModal];
        [NSApp endSheet:[self window]];
        [[self window] close];
    }
    if (theEvent.keyCode == 36) {//enter
        [self CreatSaveImage:NO];
        [NSApp stopModal];
        [NSApp endSheet:[self window]];
        [[self window] close];
    }
}

#pragma mark mouse action
- (NSMutableArray *)getTopDictionary:(NSMutableArray *)array point:(NSPoint)point{
    if (!array || [array count] == 0) {
        return [NSMutableArray array];
    }
    if ([array count] == 1) {
        return array;
    }
    CGWindowListOption listOptions = kCGWindowListOptionAll;
    listOptions = MJCaptureViewChangeBits(listOptions, kCGWindowListOptionOnScreenOnly, NO);
    listOptions = MJCaptureViewChangeBits(listOptions, kCGWindowListExcludeDesktopElements, YES);
    listOptions = MJCaptureViewChangeBits(listOptions, kCGWindowListOptionOnScreenAboveWindow, YES);
    
    NSMutableArray *tempArray = [captureModel_ getWindowList:listOptions windowID:[[[array objectAtIndex:0] objectForKey:kWindowIDKey] intValue]];
    
    for (int i = (int)[tempArray count]-1; i >= 0; i--) {
        NSMutableDictionary *dic = [tempArray objectAtIndex:i];
        NSRect fr = NSRectFromString([dic objectForKey:kWindowFrameKey]);
        if (!NSPointInRect(point, fr)) {
            [tempArray removeObjectAtIndex:i];
        }
    }
    
    if ([tempArray count] == 0) {
        return [NSMutableArray arrayWithObject:[array objectAtIndex:0]];
    }else if ([tempArray count] == 1){
        return tempArray;
    }else{
        return [self getTopDictionary:tempArray point:point];
    }
    
    return nil;
}
- (NSRect)getTopMousePointWindowFrame:(NSPoint)point{
    NSRect framRect = NSZeroRect;
   
    NSMutableArray *ptArray = [NSMutableArray array];
    for (int i = 0; i < (int)[prunedWindowList_ count]; i++) {
        NSMutableDictionary *dic = [prunedWindowList_ objectAtIndex:i];
        NSRect fr = NSRectFromString([dic objectForKey:kWindowFrameKey]);
        if (NSPointInRect(point, fr)) {
            [ptArray addObject:dic];
        }
    }
    NSMutableArray *oneArray = [self getTopDictionary:ptArray point:point];
    if (!oneArray || [oneArray count] == 0) {
        return NSZeroRect;
    }
    
//    NSLog(@"getTopMousePointWindowFrame:  %@", [oneArray objectAtIndex:0]);
    NSDictionary *dic = [oneArray objectAtIndex:0];
    NSString *applicationName = dic[@"applicationName"];
    if([applicationName isEqualToString:@"Window Server"]){
        return NSZeroRect;
    }
    
    return NSRectFromString([[oneArray objectAtIndex:0] objectForKey:kWindowFrameKey]);
    
    
    int maxOrder = 0;
    int topOrderIndex = 0;
    for (int i = 0; i < (int)[ptArray count]; i++) {
        NSMutableDictionary *dic = [ptArray objectAtIndex:i];
        int tempOrder = [[dic objectForKey:kWindowOrderKey] intValue];
        if (tempOrder > maxOrder) {
            maxOrder = tempOrder;
            topOrderIndex = i;
        }
    }
    if ((int)[ptArray count] > 0 && topOrderIndex < (int)[ptArray count]) {
        NSMutableDictionary *dic = [ptArray objectAtIndex:topOrderIndex];
        NSRect fr = NSRectFromString([dic objectForKey:kWindowFrameKey]);
        
        NSLog(@"appName:%@   maxOrder: %d    frame:%@    onScreen:%@",[dic objectForKey:kAppNameKey], maxOrder, [dic objectForKey:kWindowFrameKey], [dic objectForKey:kWindowIsOnscreenKey]);
        return fr;
    }
    
    return framRect;
}

- (void)mouseDown:(NSEvent*)theEvent {
    //    add by liuchipeng{
    NSPoint pt = theEvent.locationInWindow;
    BOOL inOrOut = NSPointInRect([selectRangeView_ convertPoint:pt fromView:self], [selectRangeView_ bounds]);
    if (!inOrOut) {
        MJCaptureSlideView *view = (MJCaptureSlideView *)[[_assetView subviews] lastObject];
        NSString *string = [[view slideTextView] string];
        if (view && (view.funType_ == MJCToolBarFunText)&&([string length]==0)) {
            [[[_assetView subviews]lastObject]removeFromSuperview];
        }
    }
    
    if (inOrOut){//add by liuchipeng 2016.1.1
        int viewCount = (int)[[_assetView subviews] count];
        if(viewCount>0){
            for(int i=0;i<viewCount;i++){
                MJCaptureSlideView *view = (MJCaptureSlideView *)[[_assetView subviews] objectAtIndex:i];
                NSString *string = [[view slideTextView] string];
                if (view && (view.funType_ == MJCToolBarFunText)&&([string length]==0)) {
                    [view removeFromSuperview];
                }
            }
            
        }
    }
    //}
    
    if (isCapture_) {
        NSPoint mouseDownPoint = theEvent.locationInWindow;
        BOOL showSlideShapeView = NO;
        NSArray *array = [_assetView subviews];
        for (int i = 0; i < [array count]; i++){
            MJCaptureSlideView *view = [array objectAtIndex:i];
            if (NSPointInRect(mouseDownPoint, [view frame])) {
                showSlideShapeView = YES;
            }
        }
        if (NSPointInRect(mouseDownPoint, [_slideShapeView frame])) {
                showSlideShapeView = YES;
        }
        if (!showSlideShapeView) {
            [_slideShapeView setHidden:YES];
        }
        
        return;
    }
    firstMouseDonwPoint_ = [self convertPoint:pt fromView:nil];
    if (isPreCapture_) {
        [self setNeedsDisplay:YES];
    }
    
}
- (void)mouseUp:(NSEvent *)theEvent{
    //    NSPoint pt = theEvent.locationInWindow;
    if (!isCapture_) {
        isCapture_ = YES;
        isPreCapture_ = NO;
        
        //处理点击桌面等情况
        if (oldRangeRect_.size.width == 8 && oldRangeRect_.size.height == 8) {
            if (oldRangeRect_.origin.x == -4 && oldRangeRect_.origin.y == -4) {
                oldRangeRect_ = [[NSScreen mainScreen] frame];
            }
        }
        if (NSIsEmptyRect(oldRangeRect_)) {
//            oldRangeRect_ = NSInsetRect([[self window] frame], 60, 60);
            oldRangeRect_ = [[NSScreen mainScreen] frame];
        }
        
        [_toolbarView setFrameOrigin:NSMakePoint(oldRangeRect_.origin.x+oldRangeRect_.size.width-_toolbarView.frame.size.width, oldRangeRect_.origin.y-_toolbarView.frame.size.height)];
        if (isAfterClean) {
            [_toolbarView removeFromSuperview];
            [self addSubview:_toolbarView];
            isAfterClean = NO;
        }
        [_toolbarView setHidden:NO];
        
        [self ReCalculateViewFrameChangeSize:NO event:theEvent];
        [selectRangeView_ setHidden:NO];
        [selectRangeView_ setFrame:oldRangeRect_];
        [selectRangeView_ setNeedsDisplay:YES];
        [self setNeedsDisplay:YES];
        
        [self ReSetLeftTopInfoView];
        
        [zoomInfoView_ setHidden:YES];
        [pointInfoView_ setHidden:YES];
        
        
    }else{
        //[[self enclosingScrollView] setDocumentCursor:[NSCursor arrowCursor]];
        return;
    }
    
}
- (void)rightMouseDown:(NSEvent *)theEvent{
    [NSApp stopModal];
    [NSApp endSheet:(MJCaptureWindow*)[self window]];
    [[self window] close];
}
- (void)mouseEntered:(NSEvent*)theEvent {
    //    NSLog(@"MJCaptureView: %@", @"mouseEntered");
    if (isPreCapture_) {
        [self setNeedsDisplay:YES];
    }
}

- (void)mouseExited:(NSEvent*)theEvent {
    if (isPreCapture_) {
        [self setNeedsDisplay:YES];
    }
}

- (void)mouseMoved:(NSEvent *)theEvent{
    NSPoint pt = theEvent.locationInWindow;
    if (isCapture_) {
        return;
    }
    NSRect fr = [self getTopMousePointWindowFrame:pt];
    oldRangeRect_ = [self convertRect:fr fromView:nil];
    if (fr.size.height == 868) {
        NSLog(@"SelectRect %@,  %@", NSStringFromRect(oldRangeRect_),  NSStringFromRect([self frame]));
    }
    if (NSIsEmptyRect(oldRangeRect_)) {
        oldRangeRect_ = [[NSScreen mainScreen] frame];
    }
    if (!NSContainsRect([[NSScreen mainScreen] frame], oldRangeRect_)) {
        oldRangeRect_ = NSIntersectionRect([[NSScreen mainScreen] frame], oldRangeRect_);
    }
    oldRangeRect_.origin.x -=selectRangeView_.nSpanValue_/2.0;
    oldRangeRect_.origin.y -=selectRangeView_.nSpanValue_/2.0;
    oldRangeRect_.size.width +=selectRangeView_.nSpanValue_;
    oldRangeRect_.size.height +=selectRangeView_.nSpanValue_;
    [self setNeedsDisplay:YES];
    [selectRangeView_ setFrame:oldRangeRect_];
    
    [self ReSetLeftTopInfoView];
    //[selectRangeView_ setNeedsDisplay:YES];
    //[(MJCaptureWindow*)[self window] getPointInTopWindowFrame:[self convertPoint:pt fromView:nil]];
}
- (void)mouseDragged:(NSEvent *)theEvent{
    //    NSLog(@"MJCaptureView: %@", @"mouseDragged");
    NSPoint pt = theEvent.locationInWindow;
    if (isCapture_) {
        return;
    }
    
    pt = [self convertPoint:pt fromView:nil];
    if (pt.x > firstMouseDonwPoint_.x) {
        if (pt.y > firstMouseDonwPoint_.y) {
            oldRangeRect_.origin = NSMakePoint(firstMouseDonwPoint_.x, firstMouseDonwPoint_.y);
        }else{
            oldRangeRect_.origin = NSMakePoint(firstMouseDonwPoint_.x, pt.y);
        }
    }else{
        if (pt.y > firstMouseDonwPoint_.y) {
            oldRangeRect_.origin = NSMakePoint(pt.x, firstMouseDonwPoint_.y);
        }else{
            oldRangeRect_.origin = NSMakePoint(pt.x, pt.y);
        }
    }
    oldRangeRect_.size = NSMakeSize(fabs(pt.x - firstMouseDonwPoint_.x), fabs(pt.y - firstMouseDonwPoint_.y));
    oldRangeRect_ = NSIntegralRect(oldRangeRect_);
    oldRangeRect_.origin.x -=selectRangeView_.nSpanValue_/2.0;
    oldRangeRect_.origin.y -=selectRangeView_.nSpanValue_/2.0;
    oldRangeRect_.size.width +=selectRangeView_.nSpanValue_;
    oldRangeRect_.size.height +=selectRangeView_.nSpanValue_;
    [selectRangeView_ setFrame:oldRangeRect_];
    [selectRangeView_ setNeedsDisplay:YES];
    
    [self ReSetLeftTopInfoView];
    if (isPreCapture_) {
        [self setNeedsDisplay:YES];
    }
    
    [self ReSetZoomInfoView:theEvent];
}

#pragma mark capture with mouse action
- (void)CaptureMousePointOfWindowFrame:(NSRect)frameRect{
    
}
- (void)CaptureSetPrunedWindowList:(NSMutableArray*)array{
    [prunedWindowList_ release];
    prunedWindowList_ = [array retain];
}


#pragma mark CaptureDelegate
- (void)CaptureImageOutput:(NSImage*)image{
    
}

- (void)CapturePrunedWindowList:(NSMutableArray*)array{
    [self CaptureSetPrunedWindowList:array];
}

#pragma mark Views Coordinate system and frame change
- (void)HideZoomInfoVew{
    [zoomInfoView_ setHidden:YES];
    [pointInfoView_ setHidden:YES];
}
- (void)ReSetZoomInfoView:(NSEvent*)event{
    if ([zoomInfoView_ isHidden]) {
        [zoomInfoView_ setHidden:NO];
        [pointInfoView_ setHidden:NO];
    }
    NSRect srect = [[NSScreen mainScreen] frame];
    int scaleWidth = [zoomInfoView_ GetImageViewWidth]/4.0;
    int scaleHeight = [zoomInfoView_ GetImageViewHeight]/4.0;
    
    NSRect zoomImageViewRect = NSMakeRect(event.locationInWindow.x-scaleWidth/2.0, srect.size.height-(event.locationInWindow.y)-scaleHeight/2.0, scaleWidth, scaleHeight);
    NSImage *image = [(MJCaptureWindow*)[self window] getScreenShotImage];
    CGImageRef screenImageRef = createCGImageRefFromNSImage(image);
    CGFloat ratio = [[NSScreen mainScreen] backingScaleFactor];
    zoomImageViewRect.origin.x *= ratio;
    zoomImageViewRect.origin.y *= ratio;
    zoomImageViewRect.size.width *= ratio;
    zoomImageViewRect.size.height *= ratio;
    CGImageRef imageRef = CGImageCreateWithImageInRect(screenImageRef, zoomImageViewRect);
    CGImageRelease(screenImageRef);
    NSImage *zoomImage = createNSImageFromCGImageRef(imageRef);
    CGImageRelease(imageRef);
    [zoomInfoView_ SetZoomImage:zoomImage];
    [zoomInfoView_ SetCurrentPoint:event.locationInWindow];
    [zoomImage lockFocus];
    NSColor *pixelColor = NSReadPixel(NSMakePoint(zoomImage.size.width/2.0, zoomImage.size.height/2.0));
    NSColor *color = [pixelColor colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
//    NSLog(@"color: %@", color);
    //NSLog(@"[zoomImage bitmapImageRepresentation]: %@", [zoomImage bitmapImageRepresentation]);
    //color = [[zoomImage bitmapImageRepresentation] colorAtX:zoomImage.size.width/2.0 y:zoomImage.size.height/2.0];
    //NSLog(@"color: %@", color);
    [zoomInfoView_ SetCurrentColor:color];
    [zoomImage unlockFocus];
    [zoomImage release];
    
    NSPoint zoomPt = NSMakePoint(event.locationInWindow.x+20, event.locationInWindow.y-zoomInfoView_.frame.size.height);
    NSRect zoomRect = zoomInfoView_.frame;
    zoomRect.origin = zoomPt;
    if (NSMaxX(zoomRect) > srect.size.width) {
        zoomPt.x = event.locationInWindow.x-20-zoomInfoView_.frame.size.width;
        zoomRect.origin = zoomPt;
    }
    if (NSMinY(zoomRect) < 30) {
        zoomPt.y = event.locationInWindow.y;
        zoomRect.origin = zoomPt;
    }
    [zoomInfoView_ setFrame:zoomRect];
}
- (void)ReSetLeftTopInfoView{
    NSRect srect = [[NSScreen mainScreen] frame];
    NSRect rect = NSMakeRect(oldRangeRect_.origin.x+4, NSMaxY(oldRangeRect_), pointInfoView_.frame.size.width, pointInfoView_.frame.size.height);
    if (NSMaxY(rect) > srect.size.height) {
        rect.origin.y = NSMaxY(oldRangeRect_)-pointInfoView_.frame.size.height;
    }
    [pointInfoView_ setFrame:rect];
    [pointInfoView_ SetLeftTopPoint:NSMakePoint(oldRangeRect_.size.width - 2 * self.nLineWidth_, oldRangeRect_.size.height - 2 * self.nLineWidth_)];
//    [pointInfoView_ setHidden:NO];
}
- (void)ReCalculateViewFrameChangeSize:(BOOL)change event:(NSEvent*)event{
    NSRect oldRect = [_toolbarView frame];
    oldRect.origin = NSMakePoint(oldRangeRect_.origin.x+oldRangeRect_.size.width-_toolbarView.frame.size.width, oldRangeRect_.origin.y-_toolbarView.frame.size.height);
    NSRect screenRect = [[NSScreen mainScreen] frame];
    if (oldRect.origin.x < 0) {
        oldRect.origin.x = 0;
    }
    if (oldRect.origin.y < 0) {
        oldRect.origin.y = NSMaxY(oldRangeRect_);
    }
    if (oldRect.origin.x+oldRect.size.width>screenRect.size.width) {
        oldRect.origin.x = screenRect.size.width-oldRect.size.width;
    }
    if (oldRect.origin.y+oldRect.size.height>screenRect.size.height) {
        oldRect.origin.y = screenRect.size.height-oldRect.size.height;
    }
    [_toolbarView setFrame:oldRect];
    [self setNeedsDisplay:YES];
    
    [self ReSetLeftTopInfoView];
    if (change && event) {
        [self ReSetZoomInfoView:event];
    }
}

- (void)BeginEdit{
    isEdit_ = YES;
    
    [_assetView setHidden:NO];
    NSRect rect = [selectRangeView_ frame];
    rect = NSInsetRect(rect, selectRangeView_.nSpanValue_/2.0, selectRangeView_.nSpanValue_/2.0);
    NSLog(@"BeginEdit:  %@", NSStringFromRect(rect));
    [_assetView setFrame:rect];
    [_assetView setNeedsDisplay:YES];
    
    //add by aries{
    if(funType_ == MJCToolBarFunMosaic){
        //先隐藏控件
        [self hideSlideShapeView];
        [_toolbarView setHidden:YES];
        [selectRangeView_ setHidden:YES];
        
        [pointInfoView_ setHidden:YES];
        isCapture_ = YES;
        
        //先不更新底图，等截图完成再更新底图
        //BOOL oldIsSaving = screenShotImageView_.isSaving_;
        screenShotImageView_.isSaving_ = YES;
        [screenShotImageView_ setNeedsDisplay:YES];

        //截图
        //int sliderValue = [MJPersistentUtil sliderValue];
        int sliderValue = [[MJPersistentUtil getInstance] sliderValueForType:funType_];
        if(sliderValue == 0){
            sliderValue = 6;
        }
        
        NSRect selectRect = rect;
        selectRect = NSIntegralRect(selectRect);
        
        if (![_assetView getMosaicView]) {
            [_assetView hideSlideArrayView];
            NSBitmapImageRep* rep = [self bitmapImageRepForCachingDisplayInRect:selectRect];
            [self cacheDisplayInRect:selectRect toBitmapImageRep:rep];
            NSImage *image = [[[NSImage alloc] init] autorelease];
            [image addRepresentation:rep];
            NSImage* bgImg = [MJMosaicUtil transToMosaicImage:image blockLevel:sliderValue];
            [_assetView beginMosaic:bgImg foreground:image];
        } else {
            [[_assetView getMosaicView] changeLineWidth:3*nLineWidth_];
        }
        
        //更新底图
        screenShotImageView_.isSaving_ = NO;
        [screenShotImageView_ setNeedsDisplay:YES];
        
        //显示必要的控件
        [_toolbarView setHidden:NO];
        [selectRangeView_ setHidden:NO];
    }
    ///}
}

- (void)changeMosaic:(int)sliderValue
{
    if(_assetView && _assetView.isHidden==FALSE){
        [_assetView beginChangeMosaic:sliderValue];
    }
}

#pragma mark Get Image From MJCaptureAssetView
- (NSImage*) resizeImage:(NSImage*)sourceImage size:(NSSize)size
{
    
    NSRect targetFrame = NSMakeRect(0, 0, size.width, size.height);
    NSImage* targetImage = nil;
    NSImageRep *sourceImageRep =
    [sourceImage bestRepresentationForRect:targetFrame
                                   context:nil
                                     hints:nil];
    
    targetImage = [[NSImage alloc] initWithSize:size];
    
    [targetImage lockFocus];
    [sourceImageRep drawInRect: targetFrame];
    [targetImage unlockFocus];
    
    return [targetImage autorelease];
}

- (NSImage*) resizeImage1:(NSImage*)sourceImage size:(NSSize)size
{
    NSRect targetFrame = NSMakeRect(0, 0, size.width, size.height);
    NSImage*  targetImage = [[NSImage alloc] initWithSize:size];
    
    [targetImage lockFocus];
    
    [sourceImage drawInRect:targetFrame
                   fromRect:NSZeroRect       //portion of source image to draw
                  operation:NSCompositeCopy  //compositing operation
                   fraction:1.0              //alpha (transparency) value
             respectFlipped:YES              //coordinate system
                      hints:@{NSImageHintInterpolation:
                                  [NSNumber numberWithInt:NSImageInterpolationHigh]}];
    
    [targetImage unlockFocus];
    return [targetImage autorelease];
}
- (void)CreatSaveImage:(BOOL)isSave{
    //add by liuchipeng 2016.1.7{
    [self hideSlideShapeView];
    //}
    [_toolbarView setHidden:YES];
    NSSound * mySound = [NSSound soundNamed:@"camera"];
    [mySound play];
    
    [selectRangeView_ setHidden:YES];
    [pointInfoView_ setHidden:YES];
    isCapture_ = YES;
    BOOL oldIsSaving = screenShotImageView_.isSaving_;
    screenShotImageView_.isSaving_ = YES;
    [screenShotImageView_ setNeedsDisplay:YES];
    
    [_assetView resetSlideFocusNone];
    [[self window] makeFirstResponder:self];
    NSRect selectRect = [selectRangeView_ frame];
    selectRect = NSInsetRect(selectRect, selectRangeView_.nSpanValue_/2.0, selectRangeView_.nSpanValue_/2.0);
    selectRect = NSIntegralRect(selectRect);
    if ([[[self superview] superview] isKindOfClass:[NSScrollView class]]) {
        [[[self superview] superview] setHidden:YES];
    }
    if ([[self superview] isKindOfClass:[NSScrollView class]]) {
        [[self superview] setHidden:YES];
    }
    NSBitmapImageRep* rep = [self bitmapImageRepForCachingDisplayInRect:selectRect];
    [self cacheDisplayInRect:selectRect toBitmapImageRep:rep];
    
    NSImage *image = [[NSImage alloc] init];
    [image addRepresentation:rep];
    
    AppDelegate *app_delegate = (AppDelegate*)[NSApp delegate];
    NSScreen *mainScreen = [NSScreen mainScreen];
    if ([mainScreen backingScaleFactor] > 1.0) {
        //bool is_enable = ProfileManager::GetLastUsedProfile()->GetPrefs()->GetBoolean(prefs::kScreenCaptureSavaOriginSize);
        if (app_delegate.isSavePitureAs1x_){//(is_enable) {
//            CGImageRef imageRef = createScaleImageByRatio(image, 1);
//            [image release];
//            image = createNSImageFromCGImageRef(imageRef);
//            CGImageRelease(imageRef);
//            rep = [image bitmapImageRepresentation];
            NSImage *tempImage = [self resizeImage:image size:NSMakeSize(selectRect.size.width, selectRect.size.height)];
            [image release];
            image = tempImage;
            rep = [image bitmapImageRepresentation];
            //[image setSize:NSMakeSize(selectRect.size.width, selectRect.size.height)];
        }
    }
    
    NSLog(@"app_delegate.isSavePitureAs1x_: %d", app_delegate.isSavePitureAs1x_);
    if (isSave) {
        saveCaptureImage([NSString stringWithString:[app_delegate GetSavePath]], rep);
    }else{
        if (app_delegate.isSaveToDeskDefault_) {
            saveCaptureImage([NSString stringWithString:[app_delegate GetSavePath]], rep);
        }
        
        NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
        [pasteboard clearContents];
        NSArray *copiedObjects = [NSArray arrayWithObject:image];
        [pasteboard writeObjects:copiedObjects];
    }
    [app_delegate sendMessageTo115Browser:image];
    [image release];
    
    screenShotImageView_.isSaving_ = oldIsSaving;
    [selectRangeView_ setHidden:NO];
    [pointInfoView_ setHidden:NO];
    [self setNeedsDisplay:YES];
}

@end
