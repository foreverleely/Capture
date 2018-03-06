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
#import "MJCaptureModel.h"

const int kDRAG_POINT_NUM = 8;
const int kDRAG_POINT_LEN = 5;

@interface SnipView ()

@property MJCaptureInfoView *pointInfoView;
@property MJCaptureZoomInfoView *zoomInfoView;

@end

@implementation SnipView

- (instancetype)initWithCoder:(NSCoder *)coder
{

    if (self = [super initWithCoder:coder]) {
        //_rectArray = [NSMutableArray array];
        
    }
    return self;
}

- (void)setupTrackingArea:(NSRect)rect
{
    self.trackingArea = [[NSTrackingArea alloc] initWithRect:rect options:NSTrackingMouseMoved | NSTrackingActiveAlways owner:self userInfo:nil];
    NSLog(@"track init:%@", NSStringFromRect(self.frame));
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
    NSDisableScreenUpdates();
    [super drawRect:dirtyRect];

    if (self.image) {
        NSRect imageRect = NSIntersectionRect(self.drawingRect, self.bounds);
        [self.image drawInRect:imageRect fromRect:imageRect operation:NSCompositeSourceOver fraction:1.0];
        [[NSColor colorFromInt:kBORDER_LINE_COLOR] set];
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
      //
      [self reSetLeftTopInfoView];
    }
    // Drawing code here.
    NSEnableScreenUpdates();
}

- (void)setupTool
{
  _zoomInfoView = [[MJCaptureZoomInfoView alloc] initWithFrame:NSMakeRect(0, 0, 0, 0)];
  [self addSubview:_zoomInfoView];
  
  _pointInfoView = [[MJCaptureInfoView alloc] initWithFrame:NSMakeRect(0, 0, 90, 28)];
  [self addSubview:_pointInfoView];
  
  [self setZoomAndPointViewHide:YES];
  
}

- (void)setZoomAndPointViewHide:(BOOL)isHidde {
  [_zoomInfoView setHidden:isHidde];
  [_pointInfoView setHidden:isHidde];
}

- (void)ReSetZoomInfoView:(NSEvent*)event{
  /*
   //线程
   dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
   // 异步执行任务创建方法
   dispatch_async(queue, ^{
   // 这里放异步执行任务代码
   
   
   });
   */
  
  NSRect srect = [_screen frame];
  int scaleWidth = [_zoomInfoView GetImageViewWidth]/4.0;
  int scaleHeight = [_zoomInfoView GetImageViewHeight]/4.0;
  
  NSRect zoomImageViewRect = NSMakeRect(event.locationInWindow.x-scaleWidth/2.0, srect.size.height-(event.locationInWindow.y)-scaleHeight/2.0, scaleWidth, scaleHeight);

  CGImageRef screenImageRef = createCGImageRefFromNSImage(_image);
  CGFloat ratio = [[NSScreen mainScreen] backingScaleFactor];
  zoomImageViewRect.origin.x *= ratio;
  zoomImageViewRect.origin.y *= ratio;
  zoomImageViewRect.size.width *= ratio;
  zoomImageViewRect.size.height *= ratio;
  CGImageRef imageRef = CGImageCreateWithImageInRect(screenImageRef, zoomImageViewRect);
  CGImageRelease(screenImageRef);
  NSImage *zoomImage = createNSImageFromCGImageRef(imageRef);
  CGImageRelease(imageRef);
  [_zoomInfoView SetZoomImage:zoomImage];
  [_zoomInfoView SetCurrentPoint:event.locationInWindow];
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
  /*
  dispatch_sync(dispatch_get_main_queue(), ^{
    // 主线程更新UI
    [_zoomInfoView setFrame:zoomRect];
  });
  */
}

- (void)reSetLeftTopInfoView {
  NSRect srect = [_screen frame];
  NSRect rect = NSMakeRect(_drawingRect.origin.x+4, NSMaxY(_drawingRect), _pointInfoView.frame.size.width, _pointInfoView.frame.size.height);
  if (NSMaxY(rect) > srect.size.height) {
    rect.origin.y = NSMaxY(_drawingRect)-_pointInfoView.frame.size.height;
  }
  [_pointInfoView setFrame:rect];
  [_pointInfoView SetLeftTopPoint:NSMakePoint(_drawingRect.size.width - 2 * _nLineWidth, _drawingRect.size.height - 2 * _nLineWidth)];
}
@end
