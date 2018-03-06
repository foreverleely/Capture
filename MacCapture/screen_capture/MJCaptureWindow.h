//
//  MJCaptureWindow.h
//  MacCapture
//
//  Created by 115Browser on 8/16/15.
//  Copyright (c) 2015 jacky.115.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "MJCaptureView.h"

@interface MJCaptureWindow : NSWindow<NSWindowDelegate>{
    NSImageView *screenShotImageView_;
    MJCaptureView *captureView_;
    
    NSView *subView_;
    NSScrollView* scrollView_;
}

- (void)setScreenShotImage:(NSImage*)image;
- (NSImage*)getScreenShotImage;
//add by liuchipeng2016.1.5{点击按钮默认选中区域为浏览器
-(MJCaptureView*)CaptureView;
//}
- (MJCaptureView *) captureView;

@end
