//
//  MJMosaicView.m
//  MacCapture
//
//  Created by 115 on 16/9/19.
//  Copyright © 2016年 jacky.115.com. All rights reserved.
//

#import "MJMosaicView.h"
#import "MJMosaicUtil.h"
#import "MJCaptureView.h"
#import "MJCaptureAssetView.h"
#import "MJCaptureModel.h"
#import "SnipManager.h"

@implementation MJDrawerView

- (id) initWithFrame : (NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    if(self){
        brushPoint_ = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void) addObject:(NSString*)obj
{
    [brushPoint_ addObject:obj];
}

- (void) removeAllObject
{
    if([brushPoint_ count] > 0){
        [brushPoint_ removeAllObjects];
    }
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    //NSBezierPath* path = [NSBezierPath bezierPathWithRect:dirtyRect];
    //NSColor* bgColor = [NSColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    //[bgColor set];
    //[path fill];
    
    MJMosaicView* mosaicView = (MJMosaicView*)[self superview];
    MJCaptureAssetView* assetView = (MJCaptureAssetView*)[mosaicView superview];
    //画箭头
    if([SnipManager sharedInstance].funType == MJCToolBarFunTriangleArrow){
      if (_firstPoint.x == _lastPoint.x &&
          _firstPoint.y == _lastPoint.y) {
        return;
      }
        [[SnipManager sharedInstance].brushColor set];
        
        CGContextRef context = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
        drawTriangleArrow(context, NSPointToCGPoint(_firstPoint), NSPointToCGPoint(_lastPoint), [SnipManager sharedInstance].nLineWidth);
    }
    //画刷
    else if([SnipManager sharedInstance].funType == MJCToolBarFunBrush && [brushPoint_ count] > 1){
        [[SnipManager sharedInstance].brushColor set];
        
        NSBezierPath *brushPath = [NSBezierPath bezierPath];
        for (int i = 0; i < (int)[brushPoint_ count]; i++) {
            if (i == 0) {
                [brushPath moveToPoint:NSPointFromString([brushPoint_ objectAtIndex:i])];
            }else{
                [brushPath lineToPoint:NSPointFromString([brushPoint_ objectAtIndex:i])];
            }
        }
        [brushPath setLineWidth:[SnipManager sharedInstance].nLineWidth];
        [brushPath setLineCapStyle:NSRoundLineCapStyle];
        [brushPath setLineJoinStyle:NSMiterLineJoinStyle];
        [brushPath stroke];
    }
}

@end


@implementation MJMosaicModel

- (instancetype)init {
    if (self = [super init]) {
        
        _path = CGPathCreateMutable();
    }
    return self;
}

- (void)setPath:(CGMutablePathRef)path {
    if (path && _path != path) {
        CGPathRelease(_path);
        _path = CGPathCreateMutableCopy(path);
    }
}

- (void)dealloc {
    if (_path) CGPathRelease(_path);
    [super dealloc];
}

@end

@implementation MJMosaicView

@synthesize drawView = drawView_;

- (id) initWithFrame:(NSRect)frameRect backgroundImg:(NSImage*)bgImg forgroundImg:(NSImage*)forImg lineWidth:(CGFloat)lw
{
    self = [super initWithFrame:frameRect];
    if(self){
        image = bgImg;
        surfaceImage = forImg;
        [self setWantsLayer:YES];
        
        surfaceImageView = [[NSImageView alloc] initWithFrame:self.bounds];
        surfaceImageView.image = forImg;
//        [self addSubview:surfaceImageView];
        //添加layer（imageLayer）到self上
        imageLayer = [CALayer layer];
        imageLayer.frame = self.bounds;
        imageLayer.contents = (id)[MJMosaicUtil createCGImageRefFromNSImage:bgImg];
        [self.layer addSublayer:imageLayer];
        //添加shape layer
        shapeLayer = [CAShapeLayer layer];
        shapeLayer.frame = self.bounds;
        shapeLayer.lineCap = kCALineCapRound;
        shapeLayer.lineJoin = kCALineJoinRound;
        shapeLayer.lineWidth = lw;
        shapeLayer.strokeColor = [NSColor blueColor].CGColor;
        shapeLayer.fillColor = nil;
        [self.layer addSublayer:shapeLayer];
      
        imageLayer.mask = shapeLayer;
        pathRef_ = CGPathCreateMutable();
        
        NSTrackingAreaOptions options = (NSTrackingActiveAlways | NSTrackingInVisibleRect |
                                         NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved);
        trackingArea_ = [[NSTrackingArea alloc] initWithRect:[self bounds]
                                                     options:options
                                                       owner:self
                                                    userInfo:nil];
        [self addTrackingArea:trackingArea_];
        
        
        drawView_ = [[MJDrawerView alloc] initWithFrame:frameRect];
        [self addSubview:drawView_];
        [drawView_ setHidden:YES];
        
        linesArr_ = [[NSMutableArray alloc] init];
        currentPathRef_ = CGPathCreateMutable();
    }
    return self;
}

- (void)dealloc
{
    [linesArr_ release];
    linesArr_ = nil;
    if (currentPathRef_) CGPathRelease(currentPathRef_);

    if (pathRef_) {
        CGPathRelease(pathRef_);
    }
    [super dealloc];
}

- (void)mouseDown:(NSEvent *)theEvent
{
    NSPoint pt = theEvent.locationInWindow;
    
    MJCaptureAssetView* assetView = (MJCaptureAssetView*)[self superview];
    if([SnipManager sharedInstance].funType != MJCToolBarFunMosaic){
      //如果是画箭头就保存坐标位置
      [drawView_ removeAllObject];
      drawView_.firstPoint = drawView_.lastPoint = [self convertPoint:pt fromView:nil];
        if(![self hasShapeFocus]){
            if([SnipManager sharedInstance].funType == MJCToolBarFunTriangleArrow){
                _firstPoint_ = [self convertPoint:pt fromView:nil];
                [drawView_ setHidden:NO];
                drawView_.firstPoint = drawView_.lastPoint = [self convertPoint:pt fromView:nil];
            }else if([SnipManager sharedInstance].funType == MJCToolBarFunBrush){
                [drawView_ setHidden:NO];
                [drawView_ addObject:NSStringFromPoint([self convertPoint:pt fromView:nil])];
            }
        }
      [drawView_ setNeedsDisplay:YES];
        [assetView mouseDown:theEvent];
        return;
    }
    
    pt = [self convertPoint:pt fromView:nil];

    [self addLine:pt];
}

- (void)addLine:(NSPoint)startPoint {
    [[[[self window] undoManager] prepareWithInvocationTarget:self] removeLastLine];
    // 每次画新的线条先把之前的当前值relese掉
    if(currentPathRef_) {
        CGPathRelease(currentPathRef_);
        currentPathRef_ = CGPathCreateMutable();
    }
    CGPathMoveToPoint(currentPathRef_, NULL, startPoint.x, startPoint.y);
    CGPathAddPath(pathRef_, NULL, currentPathRef_);
    MJMosaicModel *model = [[[MJMosaicModel alloc] init] autorelease];
    model.startPoint = startPoint;
    [linesArr_ addObject:model];
    shapeLayer.path = pathRef_;
}

- (void)removeLastLine {
    [[[[self window] undoManager] prepareWithInvocationTarget:self] addLine:[(MJMosaicModel*)[linesArr_ lastObject] startPoint]];
    [linesArr_ removeLastObject];
    
    CGMutablePathRef mPath = CGPathCreateMutable();
    CGPathMoveToPoint(pathRef_, NULL, 0, 0);
    CGPathAddLineToPoint(pathRef_, NULL, 0, 0);
    for (int i = 0; i < linesArr_.count; i++) {
        CGPathAddPath(mPath, NULL, [(MJMosaicModel *)[linesArr_ objectAtIndex:i] path]);
    }
    
    if (pathRef_) CGPathRelease(pathRef_);
    pathRef_ = CGPathCreateMutable();
    pathRef_ = CGPathCreateMutableCopy(mPath);
    CGPathRelease(mPath);
    shapeLayer.path = pathRef_;
    [self setNeedsDisplay:YES];
}

- (void)mouseUp:(NSEvent *)theEvent
{
    MJCaptureAssetView* assetView = (MJCaptureAssetView*)[self superview];
    if([SnipManager sharedInstance].funType != MJCToolBarFunMosaic){
        if(![self hasShapeFocus]){
            if([SnipManager sharedInstance].funType == MJCToolBarFunTriangleArrow ||
               [SnipManager sharedInstance].funType == MJCToolBarFunBrush){
                //如果是画箭头或者画刷就关闭绘画view
                [drawView_ setHidden:YES];
            }
        }
        [assetView mouseUp:theEvent];
        return;
    }
    
    CGMutablePathRef path = CGPathCreateMutableCopy(currentPathRef_);
    [(MJMosaicModel*)[linesArr_ lastObject] setPath:path];
    CGPathRelease(path);
}

- (void)mouseMoved:(NSEvent *)theEvent
{
    MJCaptureAssetView* assetView = (MJCaptureAssetView*)[self superview];
    //改变鼠标样式
    if([SnipManager sharedInstance].funType == MJCToolBarFunMosaic){
        [self changeCursor];
    }
    //是否需要消息转发
    if([SnipManager sharedInstance].funType != MJCToolBarFunMosaic){
        [assetView mouseMoved:theEvent];
        return;
    }
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    NSPoint pt = theEvent.locationInWindow;
    
    MJCaptureAssetView* assetView = (MJCaptureAssetView*)[self superview];
    if([SnipManager sharedInstance].funType != MJCToolBarFunMosaic){
        if(![self hasShapeFocus]){
        //如果是画箭头就先保存坐标再绘画
        if([SnipManager sharedInstance].funType == MJCToolBarFunTriangleArrow){
            _lastPoint_ = [self convertPoint:pt fromView:nil];
            drawView_.lastPoint = [self convertPoint:pt fromView:nil];
            [drawView_ setNeedsDisplay:YES];
        }
        else if([SnipManager sharedInstance].funType == MJCToolBarFunBrush){
            [drawView_ addObject:NSStringFromPoint([self convertPoint:pt fromView:nil])];
            [drawView_ setNeedsDisplay:YES];
        }
        }
        [assetView mouseDragged:theEvent];
        return;
    }
    
    pt = [self convertPoint:pt fromView:nil];
    ptTest_ = pt;
    
    [self setNeedsDisplay:YES];
    
    CGPathAddLineToPoint(currentPathRef_, NULL, pt.x, pt.y);
    CGPathAddPath(pathRef_, NULL, currentPathRef_);
    CGMutablePathRef pathRef = CGPathCreateMutableCopy(pathRef_);
    shapeLayer.path = pathRef;
    CGPathRelease(pathRef);
}

- (void)mouseEntered:(NSEvent *)theEvent
{
    MJCaptureAssetView* assetView = (MJCaptureAssetView*)[self superview];
    //改变鼠标样式
    if([SnipManager sharedInstance].funType == MJCToolBarFunMosaic){
        [self changeCursor];
    }
    //是否需要消息转发
    if([SnipManager sharedInstance].funType != MJCToolBarFunMosaic){
        [assetView mouseEntered:theEvent];
        return;
    }
}

- (void)mouseExited:(NSEvent *)theEvent
{
    MJCaptureAssetView* assetView = (MJCaptureAssetView*)[self superview];
    //改变鼠标样式
    [[NSCursor arrowCursor] set];
    
    //是否需要消息转发
    if([SnipManager sharedInstance].funType != MJCToolBarFunMosaic){
        [assetView mouseExited:theEvent];
        return;
    }
}

- (BOOL) hasShapeFocus
{
    return FALSE;
}

- (NSImage*) forgroundImg
{
    return surfaceImage;
}

- (void)changeMosaic:(int)sliderValue
{
    
    NSImage* bgImgFromSlider = [MJMosaicUtil transToMosaicImage:surfaceImage blockLevel:sliderValue];
    imageLayer.contents = (id)[MJMosaicUtil createCGImageRefFromNSImage:bgImgFromSlider];
    image = bgImgFromSlider;
}

- (void)changeLineWidth:(NSInteger)lineWidth {
    [[[[self window] undoManager] prepareWithInvocationTarget:self] resetLineWidth:shapeLayer.lineWidth];
    shapeLayer.lineWidth = lineWidth;
    shapeLayer.path = pathRef_;
    [shapeLayer setNeedsDisplay];
//    [self changeCursor];
    [self setNeedsDisplay:YES];
}

- (void)resetLineWidth:(NSInteger)lineWidth {
    [[[[self window] undoManager] prepareWithInvocationTarget:self] changeLineWidth:shapeLayer.lineWidth];
    shapeLayer.lineWidth = lineWidth;
    shapeLayer.path = pathRef_;
    [shapeLayer setNeedsDisplay];
    [self setNeedsDisplay:YES];
}

- (void)changeCursor{
    MJCaptureAssetView* assetView = (MJCaptureAssetView*)[self superview];
    MJCaptureView* captureView = (MJCaptureView*)[assetView superview];
    NSCursor* cursor = nil;
    if(captureView.nLineWidth_ == 3){
        cursor = [[[NSCursor alloc] initWithImage:[NSImage imageNamed:@"mj_capture_mosaic_brush_small"] hotSpot:NSMakePoint(4, 4)] autorelease];
    }else if(captureView.nLineWidth_ == 6){
        cursor = [[[NSCursor alloc] initWithImage:[NSImage imageNamed:@"mj_capture_mosaic_brush_mid"] hotSpot:NSMakePoint(8, 8)] autorelease];
    }else if(captureView.nLineWidth_ == 12){
        cursor = [[[NSCursor alloc] initWithImage:[NSImage imageNamed:@"mj_capture_mosaic_brush_big"] hotSpot:NSMakePoint(16, 16)] autorelease];
    }
    [cursor set];
}

@end
