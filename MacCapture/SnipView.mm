//
//  SnipView.m
//  Snip
//
//  Created by rz on 15/1/31.
//  Copyright (c) 2015年 isee15. All rights reserved.
//

#import "SnipView.h"
#import "NSColor+Helper.h"
#import "SnipManager.h"

#import "MJCaptureInfoView.h"
#import "MJCaptureToolBarView.h"
#import "MJCaptureAssetView.h"
#import "MJCaptureInfoView.h"
#import "MJMosaicView.h"
#import "MJMosaicUtil.h"
#import "MJPersistentUtil.h"
#import "SnipWindowController.h"

#import "AppDelegate.h"
const int kDRAG_POINT_NUM = 8;
const int kDRAG_POINT_LEN = 5;

@interface SnipView ()

@property MJCaptureInfoView *pointInfoView;
@property MJCaptureZoomInfoView *zoomInfoView;

@end

@implementation SnipView
- (instancetype)initWithFrame:(NSRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    [self setupTool];
    _isAfterClean = NO;
  }
  return self;
}

- (void)setupTrackingArea:(NSRect)rect
{
    self.trackingArea = [[NSTrackingArea alloc] initWithRect:rect options:NSTrackingMouseMoved | NSTrackingActiveAlways owner:self userInfo:nil];
    //NSLog(@"track init:%@", NSStringFromRect(self.frame));
    [self addTrackingArea:self.trackingArea];
}

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent
{
    return YES;
}

- (NSRect)pointRect:(int)index inRect:(NSRect)rect
{
    double x = 0, y = 0;
    switch (index) {
        case 0:
            x = NSMinX(rect);
            y = NSMaxY(rect);
            break;
        case 1:
            x = NSMidX(rect);
            y = NSMaxY(rect);
            break;
        case 2:
            x = NSMaxX(rect);
            y = NSMaxY(rect);
            break;
        case 3:
            x = NSMinX(rect);
            y = NSMidY(rect);
            break;
        case 4:
            x = NSMaxX(rect);
            y = NSMidY(rect);
            break;
        case 5:
            x = NSMinX(rect);
            y = NSMinY(rect);
            break;
        case 6:
            x = NSMidX(rect);
            y = NSMinY(rect);
            break;
        case 7:
            x = NSMaxX(rect);
            y = NSMinY(rect);
            break;

        default:
            break;
    }
    return NSMakeRect(x - kDRAG_POINT_LEN, y - kDRAG_POINT_LEN, kDRAG_POINT_LEN * 2, kDRAG_POINT_LEN * 2);
}

- (void)drawRect:(NSRect)dirtyRect
{
  //解决从桌面顶部开始截图
  if ([SnipManager sharedInstance].captureState == CAPTURE_STATE_EDIT) {
    [self setWantsLayer:YES];
  }
  
    NSDisableScreenUpdates();
    [super drawRect:dirtyRect];

    if (self.image) {
        NSRect imageRect = NSIntersectionRect(self.drawingRect, self.bounds);
        [self.image drawInRect:imageRect fromRect:imageRect operation:NSCompositeSourceOver fraction:1.0];
        [[NSColor colorFromInt:kBORDER_LINE_COLOR] set];
      if ([SnipManager sharedInstance].captureState == CAPTURE_STATE_DONE) {
        [[NSColor clearColor] set];
      }
        NSBezierPath *rectPath = [NSBezierPath bezierPath];
        [rectPath setLineWidth:kBORDER_LINE_WIDTH];
        [rectPath removeAllPoints];
        [rectPath appendBezierPathWithRect:imageRect];
        [rectPath stroke];
      //停止拖动，跟FIRSTMOUSEDOWN状态一样
        if ([SnipManager sharedInstance].captureState == CAPTURE_STATE_ADJUST) {
            [[NSColor whiteColor] set];
            for (int i = 0; i < kDRAG_POINT_NUM; i++) {
                NSBezierPath *adjustPath = [NSBezierPath bezierPath];
                [adjustPath removeAllPoints];
                [adjustPath appendBezierPathWithOvalInRect:[self pointRect:i inRect:imageRect]];
                [adjustPath fill];
            }
        }
      
      [self reSetLeftTopInfoView];
      //设置工具栏
      [self reSetToolbarView];
      
      if ([SnipManager sharedInstance].captureState == CAPTURE_STATE_DONE) {
        //保存图片前先去掉框跟线
        NSBezierPath *rectPath = [NSBezierPath bezierPath];
        [rectPath removeAllPoints];
      }
      
    }
    // Drawing code here.
    NSEnableScreenUpdates();
}

- (void)setupTool
{
 
  _assetView = [[MJCaptureAssetView alloc] initWithFrame:NSMakeRect(0, 0, 350, 40)];
  [self addSubview:_assetView];
  [_assetView setHidden:YES];
  
  _toolbarView = [[MJCaptureToolBarView alloc] initWithFrame:NSMakeRect(0, 0, 416 + 32, 44)];
  [self addSubview:_toolbarView];
  [_toolbarView setHidden:YES];
  
  _slideShapeView = [[MJSlideShapeView alloc] initWithFrame:NSMakeRect(0, 0, 0, 0)];
  [self addSubview:_slideShapeView];
  [_slideShapeView setHidden:YES];
  
  _zoomInfoView = [[MJCaptureZoomInfoView alloc] initWithFrame:NSMakeRect(0, 0, 0, 0)];
  [self addSubview:_zoomInfoView];
  
  _pointInfoView = [[MJCaptureInfoView alloc] initWithFrame:NSMakeRect(0, 0, 90, 28)];
  [self addSubview:_pointInfoView];
  
  [self setZoomAndPointViewHide:YES];
  
  [_toolbarView setWantsLayer:YES];
  
  //[self.window setContentSize:_screen.frame.size];
}

- (void)setZoomAndPointViewHide:(BOOL)isHidde {
  [_zoomInfoView setHidden:isHidde];
  [_pointInfoView setHidden:isHidde];
  NSLog(@"set two view hide %@",isHidde ? @"YES" : @"NO");
}

- (void)setzoomInfoView:(BOOL)isHidde {
    [_zoomInfoView setHidden:isHidde];
  NSLog(@"set _zoomInfoView hide %@",isHidde ? @"YES" : @"NO");
}

- (void)setpointInfoView:(BOOL)isHidde {
  [_pointInfoView setHidden:isHidde];
}

- (void)ReSetZoomInfoView:(NSEvent*)event{
  
  
  NSRect srect = [_screen frame];
  int scaleWidth = [_zoomInfoView GetImageViewWidth]/4.0;
  int scaleHeight = [_zoomInfoView GetImageViewHeight]/4.0;
  //如果_image为空，会发生崩溃
  if (_image == nil) {
    [_zoomInfoView setFrame:NSZeroRect];
    [self setzoomInfoView:YES];
    return;
  } else {
    NSLog(@"01here setzoomInfoView");
    [self setzoomInfoView:NO];
  }
  //return;
  dispatch_async(dispatch_get_global_queue(0, 0), ^{
    // 追加任务1
    NSRect zoomImageViewRect = NSMakeRect(event.locationInWindow.x-scaleWidth/2.0, srect.size.height-(event.locationInWindow.y)-scaleHeight/2.0, scaleWidth, scaleHeight);
    CGImageRef screenImageRef = createCGImageRefFromNSImage(_image);
    CGFloat ratio = [[NSScreen mainScreen] backingScaleFactor];
    zoomImageViewRect.origin.x *= ratio;
    zoomImageViewRect.origin.y *= ratio;
    zoomImageViewRect.size.width *= ratio;
    zoomImageViewRect.size.height *= ratio;
    // 这里放异步执行任务代码
    CGImageRef imageRef = CGImageCreateWithImageInRect(screenImageRef, zoomImageViewRect);
    CGImageRelease(screenImageRef);
    NSImage *zoomImage = createNSImageFromCGImageRef(imageRef);
    CGImageRelease(imageRef);
    
    dispatch_sync(dispatch_get_main_queue(), ^{
      // 主线程更新UI
      [_zoomInfoView SetZoomImage:zoomImage];
      [_zoomInfoView SetCurrentPoint:event.locationInWindow];
      //如果zoomImage的size为0会发生崩溃
      if (CGSizeEqualToSize(NSSizeToCGSize(zoomImage.size), NSZeroSize)) {
        [_zoomInfoView setFrame:NSZeroRect];
        NSLog(@"02here setzoomInfoView");
        [self setzoomInfoView:NO];
        return;
      }
      
      [zoomImage lockFocus];
      NSColor *pixelColor = NSReadPixel(NSMakePoint(zoomImage.size.width/2.0, zoomImage.size.height/2.0));
      NSColor *color = [pixelColor colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
      [_zoomInfoView SetCurrentColor:color];
      [zoomImage unlockFocus];
      NSPoint zoomPt = NSMakePoint(event.locationInWindow.x+20, event.locationInWindow.y-_zoomInfoView.frame.size.height);
      NSRect zoomRect = _zoomInfoView.frame;
      zoomRect.origin = zoomPt;
      if (NSMaxX(zoomRect) > srect.size.width) {
        zoomPt.x = event.locationInWindow.x-20-_zoomInfoView.frame.size.width;
        zoomRect.origin = zoomPt;
      }
      if (NSMinY(zoomRect) < 30) {
        zoomPt.y = event.locationInWindow.y;
        zoomRect.origin = zoomPt;
      }
      [_zoomInfoView setFrame:zoomRect];
    });
  });
  
}

- (void)reSetLeftTopInfoView {
  NSRect srect = [_screen frame];
  NSRect rect = NSMakeRect(_drawingRect.origin.x+4, NSMaxY(_drawingRect), _pointInfoView.frame.size.width, _pointInfoView.frame.size.height);
  if (NSMaxY(rect) > srect.size.height) {
    rect.origin.y = NSMaxY(_drawingRect)-_pointInfoView.frame.size.height;
  }
  [_pointInfoView setFrame:rect];
  [_pointInfoView SetLeftTopPoint:NSMakePoint(_drawingRect.size.width - 2 * [SnipManager sharedInstance].nLineWidth, _drawingRect.size.height - 2 * [SnipManager sharedInstance].nLineWidth)];
}

- (void)reSetToolbarView {
  NSRect oldRect = [_toolbarView frame];
  oldRect.origin = NSMakePoint(_drawingRect.origin.x+_drawingRect.size.width-_toolbarView.frame.size.width, _drawingRect.origin.y-_toolbarView.frame.size.height);
  NSRect screenRect = [_screen frame];
  if (oldRect.origin.x < 0) {
    oldRect.origin.x = 0;
  }
  if (oldRect.origin.y < 0) {
    oldRect.origin.y = NSMaxY(_drawingRect);
  }
  if (oldRect.origin.x+oldRect.size.width>screenRect.size.width) {
    oldRect.origin.x = screenRect.size.width-oldRect.size.width;
  }
  if (oldRect.origin.y+oldRect.size.height>screenRect.size.height) {
    oldRect.origin.y = screenRect.size.height-oldRect.size.height;
  }
  [_toolbarView setFrame:oldRect];
  //[_toolbarView setFrameOrigin:NSMakePoint(_drawingRect.origin.x+_drawingRect.size.width-_toolbarView.frame.size.width, _drawingRect.origin.y-_toolbarView.frame.size.height)];
}

- (void)cleanOpationAndReStart{
  _isAfterClean = YES;
  //设置状态
  [_toolbarView setHidden:YES];
  
  [_assetView removeFromSuperview];
  _assetView = [[MJCaptureAssetView alloc] initWithFrame:NSMakeRect(0, 0, 350, 40)];
  
  [self addSubview:_assetView];
  [_assetView setHidden:YES];
  [SnipManager sharedInstance].captureState = CAPTURE_STATE_HILIGHT;
  [((SnipWindowController*)self.window.windowController) captureAppScreen];
  [self setNeedsDisplay:YES];
}

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

- (void)setToolbarhidde:(BOOL)isHidde{
  [self.toolbarView setHidden:isHidde];
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
      [view setBrushColor:[SnipManager sharedInstance].brushColor];
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
      [view setNFontSize_:[SnipManager sharedInstance].nFontSize];
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

- (void)BeginEdit{
  [SnipManager sharedInstance].captureState = CAPTURE_STATE_EDIT;
  
  [_assetView setHidden:NO];
  NSRect rect = NSInsetRect(_drawingRect, 4, 4/2.0);
  NSLog(@"BeginEdit:  %@", NSStringFromRect(rect));
  [_assetView setFrame:rect];
  [_assetView setNeedsDisplay:YES];
  
  //add by aries{
  if([SnipManager sharedInstance].funType == MJCToolBarFunMosaic){
    //先隐藏控件
    [self hideSlideShapeView];
    
    int sliderValue = [[MJPersistentUtil getInstance] sliderValueForType:[SnipManager sharedInstance].funType];
    if(sliderValue == 0){
      sliderValue = 6;
    }
    
    NSRect selectRect = rect;
    selectRect = NSIntegralRect(selectRect);
    
    if (![_assetView getMosaicView]) {
      [_assetView hideSlideArrayView];
      NSBitmapImageRep* rep = [self bitmapImageRepForCachingDisplayInRect:selectRect];
      [self cacheDisplayInRect:selectRect toBitmapImageRep:rep];
      NSImage *image = [[NSImage alloc] init];
      [image addRepresentation:rep];
      NSImage* bgImg = [MJMosaicUtil transToMosaicImage:image blockLevel:sliderValue];
      [_assetView beginMosaic:bgImg foreground:image];
    } else {
      [[_assetView getMosaicView] changeLineWidth:3*[SnipManager sharedInstance].nLineWidth];
    }
    
  }
}

- (void)changeMosaic:(int)sliderValue
{
  if(_assetView && _assetView.isHidden==FALSE){
    [_assetView beginChangeMosaic:sliderValue];
  }
}

- (void)CreatSaveImage:(BOOL)isSave{
  //add by liuchipeng 2016.1.7{
  [SnipManager sharedInstance].captureState = CAPTURE_STATE_DONE;
  
  [self hideSlideShapeView];
  [_pointInfoView setHidden:YES];
  //}
  [_toolbarView setHidden:YES];
  NSSound * mySound = [NSSound soundNamed:@"camera"];
  [mySound play];
  
  [_assetView resetSlideFocusNone];
  [[self window] makeFirstResponder:self];
  
  //_drawingRect = NSInsetRect(_drawingRect, 4, 4);
  _drawingRect = NSIntegralRect(_drawingRect);
  
  if ([[[self superview] superview] isKindOfClass:[NSScrollView class]]) {
    [[[self superview] superview] setHidden:YES];
  }
  if ([[self superview] isKindOfClass:[NSScrollView class]]) {
    [[self superview] setHidden:YES];
  }
  NSBitmapImageRep* rep = [self bitmapImageRepForCachingDisplayInRect:_drawingRect];
  [self cacheDisplayInRect:_drawingRect toBitmapImageRep:rep];
  
  NSImage *image = [[NSImage alloc] init];
  [image addRepresentation:rep];
  
  AppDelegate *app_delegate = (AppDelegate*)[NSApp delegate];
  NSScreen *mainScreen = _screen;
  if ([mainScreen backingScaleFactor] > 1.0) {
    if (app_delegate.isSavePitureAs1x_){
      NSImage *tempImage = [self resizeImage:image size:NSMakeSize(_drawingRect.size.width, _drawingRect.size.height)];
      image = tempImage;
      rep = [image bitmapImageRepresentation];
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
  
  [_pointInfoView setHidden:NO];
  [[SnipManager sharedInstance] endCaptureimage];
  [self setNeedsDisplay:YES];
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
  
  return targetImage;
}

///
- (void)keyDown:(NSEvent *)theEvent{
  NSLog(@"keyDown");
  //add by liuchipeng 2016.1.6{按下方向键移动选择框
  if ([SnipManager sharedInstance].captureState != CAPTURE_STATE_EDIT) {
    if(theEvent.keyCode==124){
      NSRect newRect = _drawingRect;
      newRect.origin.x += 1;
      _drawingRect.origin.x += 1;
      NSRect newToolBarRect = _toolbarView.frame;
      newToolBarRect.origin.x +=1;
      [_toolbarView setFrame:newToolBarRect];
      _drawingRect = newRect;
      NSRect newInfoRect = _pointInfoView.frame;
      newInfoRect.origin.x += 1;
      [_pointInfoView setFrame:newInfoRect];
      [self setNeedsDisplay:YES];
    }
    if(theEvent.keyCode==123){
      NSRect newRect = _drawingRect;
      newRect.origin.x-=1;
      _drawingRect.origin.x-=1;
      _drawingRect= newRect;
      NSRect newToolBarRect = _toolbarView.frame;
      newToolBarRect.origin.x -=1;
      [_toolbarView setFrame:newToolBarRect];
      NSRect newInfoRect = _pointInfoView.frame;
      newInfoRect.origin.x -= 1;
      [_pointInfoView setFrame:newInfoRect];
      [self setNeedsDisplay:YES];
    }
    if(theEvent.keyCode==125){
      NSRect newRect = _drawingRect;
      newRect.origin.y-=1;
      _drawingRect.origin.y-=1;
      _drawingRect = newRect;
      NSRect newToolBarRect = _toolbarView.frame;
      newToolBarRect.origin.y -=1;
      [_toolbarView setFrame:newToolBarRect];
      NSRect newInfoRect = _pointInfoView.frame;
      newInfoRect.origin.y -= 1;
      [_pointInfoView setFrame:newInfoRect];
      [self setNeedsDisplay:YES];
    }
    if(theEvent.keyCode==126){
      NSRect newRect = _drawingRect;
      newRect.origin.y+=1;
      _drawingRect.origin.y+=1;
      _drawingRect = newRect;
      NSRect newToolBarRect = _toolbarView.frame;
      newToolBarRect.origin.y +=1;
      [_toolbarView setFrame:newToolBarRect];
      NSRect newInfoRect = _pointInfoView.frame;
      newInfoRect.origin.y += 1;
      [_pointInfoView setFrame:newInfoRect];
      [self setNeedsDisplay:YES];
    }
  }else{
    
  }
  //}
  
  //command + s 保存截图
  if (theEvent.modifierFlags == 0x100108 && theEvent.keyCode == 1 && [SnipManager sharedInstance].captureState != CAPTURE_STATE_HILIGHT) {
    [self CreatSaveImage:YES];
    [[SnipManager sharedInstance] endCaptureimage];
  }
  
  
  if (theEvent.keyCode == 53) {//esc
    [[SnipManager sharedInstance] endCaptureimage];
  }
  if (theEvent.keyCode == 36) {//enter
    [self CreatSaveImage:NO];
    [[SnipManager sharedInstance] endCaptureimage];
  }
  //add by liuchipeng 2016.1.4{
  
  
  //}
  
}

- (void)rightMouseDown:(NSEvent *)event {
  [[SnipManager sharedInstance] endCaptureimage];
}

- (BOOL)isToolbarViewHidden{
  return [self.toolbarView isHidden];
}
@end
