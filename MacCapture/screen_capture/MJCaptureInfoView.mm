//
//  MJCaptureInfoView.m
//  MacCapture
//
//  Created by mengjianjun on 15/9/29.
//  Copyright (c) 2015年 jacky.115.com. All rights reserved.
//

#import "MJCaptureInfoView.h"


const int kCaptureZoomInfoWidth = 112;
const int kCaptureZoomInfoHeight = 140;
const int kCaptureZoomImageViewHeight = 100;
const float kStrokeLineWidth = 1.5;

@implementation MJCaptureInfoView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        tfLeftTopPoint_ = [[[NSTextField alloc] initWithFrame:NSMakeRect(0, 3, frame.size.width, frame.size.height-9)] autorelease];
        [tfLeftTopPoint_ setStringValue:@"(0,0)"];
        [tfLeftTopPoint_ setFont:[NSFont systemFontOfSize:12]];
        [tfLeftTopPoint_ setEditable:NO];
        [tfLeftTopPoint_ setBordered:NO];
        [tfLeftTopPoint_ setBackgroundColor:[NSColor clearColor]];
        [tfLeftTopPoint_ setFocusRingType:NSFocusRingTypeNone];
        [tfLeftTopPoint_ setAlignment:NSCenterTextAlignment];
        [tfLeftTopPoint_ setTextColor:[NSColor whiteColor]];
        [self addSubview:tfLeftTopPoint_];
        [tfLeftTopPoint_ setSelectable:NO];
    }
    return self;
}
- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    [[NSColor colorWithCalibratedRed:97/255.0 green:98/255.0 blue:100/255.0 alpha:1] set];
    [[NSBezierPath bezierPathWithRoundedRect:dirtyRect xRadius:4 yRadius:4] fill];
}

- (void) SetLeftTopPoint:(NSPoint)point{
    NSString *strPoint = @"(";
    strPoint = [strPoint stringByAppendingString:[NSString stringWithFormat:@"%d*", (int)(point.x)]];
    strPoint = [strPoint stringByAppendingString:[NSString stringWithFormat:@"%d)", (int)(point.y)]];
    [tfLeftTopPoint_ setStringValue:strPoint];
}

@end


@implementation MJCrosshairView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
    
    [[NSColor colorWithCalibratedRed:0.302 green:0.808 blue:0.953 alpha:0.5] set];
    [[NSBezierPath bezierPathWithRect:NSMakeRect(0, dirtyRect.size.height/2.0-2, dirtyRect.size.width, 4)] fill];
    [[NSBezierPath bezierPathWithRect:NSMakeRect(dirtyRect.size.width/2.0-2, 0, 4, dirtyRect.size.height)] fill];
}

@end


@implementation MJCaptureZoomInfoView

- (id)initWithFrame:(NSRect)frame
{
    frame = NSMakeRect(frame.origin.x, frame.origin.y, kCaptureZoomInfoWidth, kCaptureZoomInfoHeight);
    self = [super initWithFrame:frame];
    if (self) {
        int fontH = 13;
        int nBorder = 1;
        int xTextHeight = kCaptureZoomInfoHeight - 3 - kCaptureZoomImageViewHeight;
        int nTextSpance = (xTextHeight - fontH*2)/3.0;
        int yPos = nBorder + nTextSpance+nBorder;
        tfCurrentColor_ = [[[NSTextField alloc] initWithFrame:NSMakeRect(-6, yPos, kCaptureZoomInfoWidth+12, fontH)] autorelease];
        [tfCurrentColor_ setStringValue:@"RGB:(255,255,255)"];
        [tfCurrentColor_ setFont:[NSFont systemFontOfSize:11]];
        [tfCurrentColor_ setEditable:NO];
        [tfCurrentColor_ setBordered:NO];
        [tfCurrentColor_ setBackgroundColor:[NSColor clearColor]];
        [tfCurrentColor_ setFocusRingType:NSFocusRingTypeNone];
        [tfCurrentColor_ setAlignment:NSCenterTextAlignment];
        [tfCurrentColor_ setTextColor:[NSColor whiteColor]];
        [self addSubview:tfCurrentColor_];
        [tfCurrentColor_ setSelectable:NO];
        
        yPos+=fontH+nTextSpance;
        tfCurrentPoint_ = [[[NSTextField alloc] initWithFrame:NSMakeRect(kStrokeLineWidth, yPos+2, kCaptureZoomInfoWidth-2*kStrokeLineWidth, fontH)] autorelease];
        [tfCurrentPoint_ setStringValue:@"(0,0)"];
        [tfCurrentPoint_ setFont:[NSFont systemFontOfSize:11]];
        [tfCurrentPoint_ setEditable:NO];
        [tfCurrentPoint_ setBordered:NO];
        [tfCurrentPoint_ setBackgroundColor:[NSColor clearColor]];
        [tfCurrentPoint_ setFocusRingType:NSFocusRingTypeNone];
        [tfCurrentPoint_ setAlignment:NSCenterTextAlignment];
        [tfCurrentPoint_ setTextColor:[NSColor whiteColor]];
        [self addSubview:tfCurrentPoint_];
        [tfCurrentPoint_ setSelectable:NO];
        
        yPos+=fontH+nTextSpance+nBorder;
        zoomImageView_ = [[[NSImageView alloc] initWithFrame:NSMakeRect(kStrokeLineWidth, yPos, kCaptureZoomInfoWidth-2*kStrokeLineWidth, kCaptureZoomImageViewHeight)] autorelease];
        [self addSubview:zoomImageView_];
        [[zoomImageView_ cell] setImageScaling:NSScaleToFit];
        crosshairView_ = [[[MJCrosshairView alloc] initWithFrame:NSMakeRect(kStrokeLineWidth, yPos, kCaptureZoomInfoWidth-2*kStrokeLineWidth, kCaptureZoomImageViewHeight)] autorelease];
        [self addSubview:crosshairView_];
        
        [self setWantsLayer:YES];
        NSShadow *shadow = [[[NSShadow alloc] init] autorelease];
        shadow.shadowBlurRadius = 10;
        [self setShadow:shadow];
    }
    return self;
}

- (int) GetImageViewWidth{
    return kCaptureZoomInfoWidth-2;
}
- (int) GetImageViewHeight{
    return kCaptureZoomImageViewHeight;
}

- (void) SetZoomImage:(NSImage*)image{
    [zoomImageView_ setImage:image];
}

- (void) SetCurrentPoint:(NSPoint)point{
    NSString *strPoint = @"(";
    strPoint = [strPoint stringByAppendingString:[NSString stringWithFormat:@"%d,", (int)(point.x)]];
    strPoint = [strPoint stringByAppendingString:[NSString stringWithFormat:@"%d)", (int)(point.y)]];
    [tfCurrentPoint_ setStringValue:strPoint];
}
- (void) SetCurrentColor:(NSColor*)color{
    NSString *strColor = @"RGB:(";
    strColor = [strColor stringByAppendingString:[NSString stringWithFormat:@"%d,", (int)(([color redComponent]+0.0001)*255.0)]];
    strColor = [strColor stringByAppendingString:[NSString stringWithFormat:@"%d,", (int)(([color greenComponent]+0.0001)*255.0)]];
    strColor = [strColor stringByAppendingString:[NSString stringWithFormat:@"%d)", (int)(([color blueComponent]+0.0001)*255.0)]];
//    NSLog(@"strColor:  %@", strColor);
    [tfCurrentColor_ setStringValue:strColor];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
    dirtyRect = NSIntegralRect(dirtyRect);
    [[NSColor whiteColor] set];
//    [[NSBezierPath bezierPathWithRect:dirtyRect] stroke];
//    [[NSBezierPath bezierPathWithRect:NSMakeRect(0, zoomImageView_.frame.origin.y-1, dirtyRect.size.width, 1)] fill];
    [NSBezierPath setDefaultLineWidth:kStrokeLineWidth];
    [[NSBezierPath bezierPathWithRoundedRect:dirtyRect xRadius:4 yRadius:4] fill];
    
    [[NSColor colorWithCalibratedRed:0.369 green:0.369 blue:0.361 alpha:1] set];
    [[NSBezierPath bezierPathWithRect:NSMakeRect(kStrokeLineWidth, kStrokeLineWidth, dirtyRect.size.width-2*kStrokeLineWidth, zoomImageView_.frame.origin.y)] fill];
}

@end