//
//  MJMosaicView.h
//  MacCapture
//
//  Created by 115 on 16/9/19.
//  Copyright © 2016年 jacky.115.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>
#import <CoreGraphics/CoreGraphics.h>

@interface MJDrawerView : NSView
{
    NSMutableArray *brushPoint_;
}
- (id) initWithFrame : (NSRect)frameRect;
- (void) addObject:(NSString*)obj;
- (void) removeAllObject;

@property (nonatomic, assign) NSPoint firstPoint;
@property (nonatomic, assign) NSPoint lastPoint;

@end


@interface MJMosaicModel : NSObject

@property (nonatomic, assign) CGMutablePathRef path;

@property (nonatomic, assign) NSPoint startPoint;

@end

@interface MJMosaicView : NSView
{
    NSImageView* surfaceImageView;
    CALayer* imageLayer;
    CAShapeLayer* shapeLayer;
    CGMutablePathRef pathRef_;
    NSImage* image;
    NSImage* surfaceImage;
    NSTrackingArea *trackingArea_;
    NSPoint ptTest_;
        
    MJDrawerView* drawView_;
    
    NSMutableArray *linesArr_;
    CGMutablePathRef currentPathRef_;
}

@property NSPoint firstPoint_;
@property NSPoint lastPoint_;
@property (nonatomic, weak) MJDrawerView* drawView;

- (id) initWithFrame:(NSRect)frameRect backgroundImg:(NSImage*)bgImg forgroundImg:(NSImage*)forImg lineWidth:(CGFloat)lw;
- (void) dealloc;

- (NSImage*) forgroundImg;
- (void) changeMosaic:(int)sliderValue;
- (void)changeLineWidth:(NSInteger)lineWidth;

- (void) mouseEntered:(NSEvent *)theEvent;
- (void) mouseExited:(NSEvent *)theEvent;
- (void) mouseDown:(NSEvent *)theEvent;
- (void) mouseUp:(NSEvent *)theEvent;
- (void) mouseMoved:(NSEvent *)theEvent;
- (void) mouseDragged:(NSEvent *)theEvent;

- (BOOL) hasShapeFocus;

- (void) changeCursor;

@end
