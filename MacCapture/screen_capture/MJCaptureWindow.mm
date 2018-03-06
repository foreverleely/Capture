//
//  MJCaptureWindow.m
//  MacCapture
//
//  Created by 115Browser on 8/16/15.
//  Copyright (c) 2015 jacky.115.com. All rights reserved.
//

#import "MJCaptureWindow.h"
#import "AppDelegate.h"

@implementation MJCaptureWindow

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag{
    if (self = [super initWithContentRect:contentRect styleMask:aStyle backing:bufferingType defer:flag]) {
        screenShotImageView_ = [[[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, contentRect.size.width, contentRect.size.height)] autorelease];
        //[[self contentView] addSubview:screenShotImageView_];
        captureView_ = [[[MJCaptureView alloc] initWithFrame:NSMakeRect(0, 0, contentRect.size.width, contentRect.size.height)] autorelease];
        
        scrollView_ = [[NSScrollView alloc] initWithFrame:NSMakeRect(0, 0, contentRect.size.width, contentRect.size.height)];
        [scrollView_ setBorderType:NSNoBorder];
        [scrollView_ setHasVerticalScroller:NO];
        [scrollView_ setHasHorizontalScroller:NO];
        [scrollView_ setAutohidesScrollers:YES];
        [scrollView_ setScrollsDynamically:NO];
        [scrollView_ setBackgroundColor:[NSColor clearColor]];
        [scrollView_ setAutoresizingMask:NSViewWidthSizable |
         NSViewHeightSizable];
        
        [[self contentView] addSubview:scrollView_];
        [scrollView_ setDocumentView:captureView_];
        
        
        [self setDelegate:self];
        [self setOpaque:NO];
        [self setBackgroundColor:[NSColor whiteColor]];
        //[self setBackgroundColor:[NSColor clearColor]];
        //[self setBackgroundColor:[NSColor colorWithCalibratedRed:1 green:1 blue:1 alpha:0.1]];
        [self setHasShadow:NO];
        
        //[self setLevel:NSMainMenuWindowLevel + 2];
        [self setLevel:99999];
        //需要等待获取好图片之后，再show出来，否则会导致浏览器主窗口中的部分弹窗截图前就会自动关掉
//        [self makeKeyAndOrderFront:nil];
//        //这个必须要，否则从快捷键启动过来的时候，会出现点击两次才能截图的问题
//        [self becomeKeyWindow];
        
    }
    return self;
}

- (void) dealloc{
    [scrollView_ release];
    
    [super dealloc];
}

- (void)keyDown:(NSEvent *)theEvent{
    if (theEvent.keyCode == 53) {
        [NSApp stopModal];
        [NSApp endSheet:self];
        [self close];
    }
}

//这个必须要，否则里面的文本输入框将无法获得焦点输入
- (BOOL)canBecomeKeyWindow {
    return YES;
}


- (void)windowWillClose:(NSNotification*)notification {
        AppDelegate *delegate = (AppDelegate*)[NSApp delegate];
        [delegate closeCaptureWindow];
}

- (void)setScreenShotImage:(NSImage*)image{
    //[screenShotImageView_ setImage:image];
}

- (NSImage*)getScreenShotImage{
    return [captureView_ getScreenShotImage];
}
//add by liuchipeng2016.1.5{点击按钮默认选中区域为浏览器
-(MJCaptureView*)CaptureView{
    return captureView_;
}
//}
- (MJCaptureView *) captureView{
    return captureView_;
}

@end
