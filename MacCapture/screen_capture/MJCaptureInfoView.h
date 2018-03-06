//
//  MJCaptureInfoView.h
//  MacCapture
//
//  Created by mengjianjun on 15/9/29.
//  Copyright (c) 2015年 jacky.115.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MJCaptureInfoView : NSView{
    NSTextField *tfLeftTopPoint_;
}
- (void) SetLeftTopPoint:(NSPoint)point;
@end


@interface MJCrosshairView : NSView

@end

@interface MJCaptureZoomInfoView : NSView{
    MJCrosshairView *crosshairView_;
    NSImageView *zoomImageView_;
    
    NSTextField *tfCurrentPoint_;
    NSTextField *tfCurrentColor_;
    
}
- (int) GetImageViewWidth;
- (int) GetImageViewHeight;
- (void) SetZoomImage:(NSImage*)image;
- (void) SetCurrentPoint:(NSPoint)point;
- (void) SetCurrentColor:(NSColor*)color;

@end
