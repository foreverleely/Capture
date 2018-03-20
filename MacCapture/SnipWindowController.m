//
//  SnipWindowController.m
//  Snip
//
//  Created by rz on 15/1/31.
//  Copyright (c) 2015年 isee15. All rights reserved.
//

#import "SnipWindowController.h"
#import "SnipWindow.h"
#import "SnipUtil.h"
#import "SnipView.h"
#import "SnipManager.h"

const int kAdjustKnown = 8;

@interface SnipWindowController ()
@property(weak) SnipView *snipView;
@property NSImage *originImage;
@property NSImage *darkImage;
@property(assign) NSRect captureWindowRect;
@property(assign) NSRect dragWindowRect;

@property NSRect lastRect;
@property NSPoint startPoint;
@property NSPoint endPoint;
@property int dragDirection;

@property NSPoint rectBeginPoint;
@property NSPoint rectEndPoint;
@property BOOL rectDrawing;

@end

@implementation SnipWindowController

- (void)windowDidLoad
{
    [super windowDidLoad];
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)doSnapshot:(NSScreen *)screen
{
    // 获取所有OnScreen的窗口
    //kCGWindowListExcludeDesktopElements

    CGImageRef imgRef = [SnipUtil screenShot:screen];

    NSRect mainFrame = [screen frame];
    self.originImage = [[NSImage alloc] initWithCGImage:imgRef size:mainFrame.size];
    self.darkImage = [[NSImage alloc] initWithCGImage:imgRef size:mainFrame.size];
    CGImageRelease(imgRef);

    // 对darkImage做暗化处理
    [self.darkImage lockFocus];
    [[NSColor colorWithCalibratedWhite:0 alpha:0.33] set];
    NSRectFillUsingOperation([SnipUtil rectToZero:mainFrame], NSCompositeSourceAtop);
    [self.darkImage unlockFocus];

}

- (void)captureAppScreen
{
  
    NSScreen *screen = self.window.screen;
    NSPoint mouseLocation = [NSEvent mouseLocation];
    NSRect screenFrame = [screen frame];
    self.captureWindowRect = screenFrame;
    double minArea = screenFrame.size.width * screenFrame.size.height;
    for (NSDictionary *dir in [SnipManager sharedInstance].arrayRect) {
        CGRect windowRect;
        CGRectMakeWithDictionaryRepresentation((__bridge CFDictionaryRef) dir[(id) kCGWindowBounds], &windowRect);
        NSRect rect = [SnipUtil cgWindowRectToScreenRect:windowRect];
        int layer = 0;
        CFNumberRef numberRef = (__bridge CFNumberRef) dir[(id) kCGWindowLayer];
        CFNumberGetValue(numberRef, kCFNumberSInt32Type, &layer);
        if (layer < 0) continue;
        if ([SnipUtil isPoint:mouseLocation inRect:rect]) {
            if (layer == 0) {
                self.captureWindowRect = rect;
                break;
            }
            else {
                if (rect.size.width * rect.size.height < minArea) {
                    self.captureWindowRect = rect;
                    minArea = rect.size.width * rect.size.height;
                    break;
                }

            }
        }

    }
    NSLog(@"capture-----%@",NSStringFromRect(self.captureWindowRect));
    if ([SnipUtil isPoint:mouseLocation inRect:screenFrame]) {
        [self redrawView:self.originImage];
    }
    else {
      //如果鼠标点不在截屏窗口中的话，发个通知
        [self redrawView:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyMouseLocationChange object:nil userInfo:@{@"context":self}];
    }
}

- (void)redrawView:(NSImage *)image
{
  
    self.captureWindowRect = NSIntersectionRect(self.captureWindowRect, self.window.frame);
    if (image != nil && (int) self.lastRect.origin.x == (int) self.captureWindowRect.origin.x
            && (int) self.lastRect.origin.y == (int) self.captureWindowRect.origin.y
            && (int) self.lastRect.size.width == (int) self.captureWindowRect.size.width
            && (int) self.lastRect.size.height == (int) self.captureWindowRect.size.height) {
        return;
    }
    if (self.snipView.image == nil && image == nil) return;
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.snipView setImage:image];
        NSRect rect = [self.window convertRectFromScreen:self.captureWindowRect];
        [self.snipView setDrawingRect:rect];
        [self.snipView setNeedsDisplay:YES];
        self.lastRect = self.captureWindowRect;
      
    });

}

- (NSPoint)dragPointCenter:(int)index
{
    double x = 0, y = 0;
    switch (index) {
        case 0:
            x = NSMinX(self.captureWindowRect);
            y = NSMaxY(self.captureWindowRect);
            break;
        case 1:
            x = NSMidX(self.captureWindowRect);
            y = NSMaxY(self.captureWindowRect);
            break;
        case 2:
            x = NSMaxX(self.captureWindowRect);
            y = NSMaxY(self.captureWindowRect);
            break;
        case 3:
            x = NSMinX(self.captureWindowRect);
            y = NSMidY(self.captureWindowRect);
            break;
        case 4:
            x = NSMaxX(self.captureWindowRect);
            y = NSMidY(self.captureWindowRect);
            break;
        case 5:
            x = NSMinX(self.captureWindowRect);
            y = NSMinY(self.captureWindowRect);
            break;
        case 6:
            x = NSMidX(self.captureWindowRect);
            y = NSMinY(self.captureWindowRect);
            break;
        case 7:
            x = NSMaxX(self.captureWindowRect);
            y = NSMinY(self.captureWindowRect);
            break;

        default:
            break;
    }
    return NSMakePoint(x, y);
}


- (int)dragDirectionFromPoint:(NSPoint)point
{
    if (NSWidth(self.captureWindowRect) <= kAdjustKnown * 2 || NSHeight(self.captureWindowRect) <= kAdjustKnown * 2) {
        if (NSPointInRect(point, self.captureWindowRect)) {
            return 8;
        }
    }
    NSRect innerRect = NSInsetRect(self.captureWindowRect, kAdjustKnown, kAdjustKnown);
    if (NSPointInRect(point, innerRect)) {
        return 8;
    }
    NSRect outerRect = NSInsetRect(self.captureWindowRect, -kAdjustKnown, -kAdjustKnown);
    if (!NSPointInRect(point, outerRect)) {
        return -1;
    }
    double minDistance = kAdjustKnown * kAdjustKnown;
    int ret = -1;
    for (int i = 0; i < 8; i++) {
        NSPoint dragPoint = [self dragPointCenter:i];
        double distance = [SnipUtil pointDistance:dragPoint toPoint:point];
        if (distance < minDistance) {
            minDistance = distance;
            ret = i;
        }
    }
    return ret;
}

- (void)startCaptureWithScreen:(NSScreen *)screen
{
    [self doSnapshot:screen];
    
    [self.window setBackgroundColor:[NSColor colorWithPatternImage:self.darkImage]];
    NSRect screenFrame = [screen frame];
    screenFrame.size.width /= 1;
    screenFrame.size.height /= 1;
    [self.window setFrame:screenFrame display:YES animate:NO];

    self.snipView = self.window.contentView;
    self.snipView.screen = screen;
    ((SnipWindow *) self.window).mouseDelegate = self;
    [self.snipView setupTrackingArea:self.window.screen.frame];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotifyMouseChange:) name:kNotifyMouseLocationChange object:nil];
    //[self showWindow:nil];
    ///add new
  [self performSelector:@selector(activeCaptureViewLater) withObject:nil afterDelay:0.01];
  ///
  
    [self captureAppScreen];
}

- (void)activeCaptureViewLater{
  [NSApp activateIgnoringOtherApps:YES];
  [NSApp setWindowsNeedUpdate:YES];
  [[self window] makeKeyAndOrderFront:[self window]];
  
  [[self window] becomeKeyWindow];
  [[self window] makeFirstResponder:self];
}

- (void)onNotifyMouseChange:(NSNotification *)notify
{
    if (notify.userInfo[@"context"] == self) return;
    if ([SnipManager sharedInstance].captureState == CAPTURE_STATE_HILIGHT && self.window.isVisible && [SnipUtil isPoint:[NSEvent mouseLocation] inRect:self.window.screen.frame]) {

        __weak __typeof__(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^() {
            __typeof__(self) strongSelf = weakSelf;
            [strongSelf showWindow:nil];
            //[self.window makeKeyAndOrderFront:nil];
            strongSelf.lastRect = NSZeroRect;
            [strongSelf captureAppScreen];
        });

    }
}
//鼠标点击下
- (void)mouseDown:(NSEvent *)event
{
  
    NSPoint mouseLocation = [NSEvent mouseLocation];
  //双击
    if ([event clickCount] == 2) {
        //鼠标双击必须在截图圈内
        if (!NSPointInRect(mouseLocation, self.captureWindowRect)) {
          return;
        }
        
        if ([SnipManager sharedInstance].captureState != CAPTURE_STATE_HILIGHT) {
          [self.snipView CreatSaveImage:NO];
          [[SnipManager sharedInstance] endCaptureimage];
          return;
        }
    }
  //单击 选中截屏窗口
    if ([SnipManager sharedInstance].captureState == CAPTURE_STATE_HILIGHT) {
        [SnipManager sharedInstance].captureState = CAPTURE_STATE_FIRSTMOUSEDOWN;
        self.startPoint = [NSEvent mouseLocation];
    }
  //已经选中了截屏窗口，此时点击先记录开始点
    else if ([SnipManager sharedInstance].captureState == CAPTURE_STATE_ADJUST) {
        self.startPoint = [NSEvent mouseLocation];
        self.captureWindowRect = [SnipUtil uniformRect:self.captureWindowRect];
        self.dragWindowRect = self.captureWindowRect;
        self.dragDirection = [self dragDirectionFromPoint:[NSEvent mouseLocation]];
    }
    if ([SnipManager sharedInstance].captureState != CAPTURE_STATE_EDIT) {
    }
    else {
      //否则显示
      
        if (NSPointInRect(mouseLocation, self.captureWindowRect)) {
            self.rectBeginPoint = mouseLocation;
            self.rectDrawing = YES;
        }
    }
}
//鼠标放开
- (void)mouseUp:(NSEvent *)theEvent
{
  ///鼠标放开隐藏
  [self.snipView setZoomAndPointViewHide:YES];
  //显示工具栏
  [self.snipView setToolbarhidde:NO];
  
  //NSLogM(@"captureWindowRect --> %@",NSStringFromRect(self.captureWindowRect));
  //NSLogM(@"%ld",(long)[SnipManager sharedInstance].captureState);
  /*
    if ([SnipManager sharedInstance].captureState == CAPTURE_STATE_FIRSTMOUSEDOWN
        ||[SnipManager sharedInstance].captureState == CAPTURE_STATE_READYADJUST) {
      
      if (CGRectEqualToRect(NSRectToCGRect(self.captureWindowRect), CGRectZero)) {
        [SnipManager sharedInstance].captureState = CAPTURE_STATE_HILIGHT;
        [self.snipView setToolbarhidde:YES];
        return;
      }
      
    }*/
  //第一次点击或者移动中点击放开
    if ([SnipManager sharedInstance].captureState == CAPTURE_STATE_FIRSTMOUSEDOWN || [SnipManager sharedInstance].captureState == CAPTURE_STATE_READYADJUST) {
        [SnipManager sharedInstance].captureState = CAPTURE_STATE_ADJUST;
        [self.snipView setNeedsDisplay:YES];
      
    }
    if ([SnipManager sharedInstance].captureState != CAPTURE_STATE_EDIT) {
      //如果不在编辑状态
        [self.snipView setNeedsDisplay:YES];
    }
    else {
      //在编辑状态
        if (self.rectDrawing) {
            self.rectDrawing = NO;
            self.rectEndPoint = [NSEvent mouseLocation];
            [self.snipView setNeedsDisplayInRect:[self.window convertRectFromScreen:self.captureWindowRect]];
        }
    }

}

- (void)mouseDragged:(NSEvent *)theEvent
{
  //拖动扩大截图区域
    if ([SnipManager sharedInstance].captureState == CAPTURE_STATE_FIRSTMOUSEDOWN
            || [SnipManager sharedInstance].captureState == CAPTURE_STATE_READYADJUST) {
        [SnipManager sharedInstance].captureState = CAPTURE_STATE_READYADJUST;
        self.endPoint = [NSEvent mouseLocation];
      //显示放大的视图 左上角视图 显示视图跟
      [self.snipView setZoomAndPointViewHide:NO];
      [self.snipView ReSetZoomInfoView:theEvent];
      
      self.captureWindowRect = NSUnionRect(NSMakeRect(self.startPoint.x, self.startPoint.y, 1, 1), NSMakeRect(self.endPoint.x, self.endPoint.y, 1, 1));
      self.captureWindowRect = NSIntersectionRect(self.captureWindowRect, self.window.frame);
      [self redrawView:self.originImage];
    }
  //编辑
    else if ([SnipManager sharedInstance].captureState == CAPTURE_STATE_EDIT) {
        if (self.rectDrawing) {
            self.rectEndPoint = [NSEvent mouseLocation];
        }
    }
  //移动整个截图区域
    else if ([SnipManager sharedInstance].captureState == CAPTURE_STATE_ADJUST) {
      //显示
      [self.snipView setpointInfoView:NO];
      //[self.snipView setzoomInfoView:NO];
      if (self.dragDirection == -1) return;
        NSPoint mouseLocation = [NSEvent mouseLocation];
        self.endPoint = mouseLocation;
        CGFloat deltaX = self.endPoint.x - self.startPoint.x;
        CGFloat deltaY = self.endPoint.y - self.startPoint.y;
        NSRect rect = self.dragWindowRect;
        switch (self.dragDirection) {
            case 8: {
                rect = NSOffsetRect(rect, self.endPoint.x - self.startPoint.x, self.endPoint.y - self.startPoint.y);
                if (!NSContainsRect(self.window.frame, rect)) {
                    NSRect rcOrigin = self.window.frame;
                    if (rect.origin.x < rcOrigin.origin.x) {
                        rect.origin.x = rcOrigin.origin.x;
                    }
                    if (rect.origin.y < rcOrigin.origin.y) {
                        rect.origin.y = rcOrigin.origin.y;
                    }
                    if (rect.origin.x > rcOrigin.origin.x + rcOrigin.size.width - rect.size.width) {
                        rect.origin.x = rcOrigin.origin.x + rcOrigin.size.width - rect.size.width;
                    }
                    if (rect.origin.y > rcOrigin.origin.y + rcOrigin.size.height - rect.size.height) {
                        rect.origin.y = rcOrigin.origin.y + rcOrigin.size.height - rect.size.height;
                    }
                    self.endPoint = NSMakePoint(self.startPoint.x + rect.origin.x - self.dragWindowRect.origin.x, self.startPoint.y + rect.origin.y - self.dragWindowRect.origin.y);
                }
            }
                break;
            case 7: {
                rect.origin.y += deltaY;
                rect.size.width += deltaX;
                rect.size.height -= deltaY;

            }
                break;
            case 6: {
                rect.origin.y += deltaY;
                rect.size.height -= deltaY;
            }
                break;
            case 5: {
                rect.origin.x += deltaX;
                rect.origin.y += deltaY;
                rect.size.width -= deltaX;
                rect.size.height -= deltaY;
            }
                break;
            case 4: {
                rect.size.width += deltaX;
            }
                break;
            case 3: {
                rect.origin.x += deltaX;
                rect.size.width -= deltaX;
            }
                break;
            case 2: {
                rect.size.width += deltaX;
                rect.size.height += deltaY;
            }
                break;
            case 1: {
                rect.size.height += deltaY;
            }
                break;
            case 0: {
                rect.origin.x += deltaX;
                rect.size.width -= deltaX;
                rect.size.height += deltaY;
            }
                break;
            default:
                break;
        }
        self.dragWindowRect = rect;
        if ((int) rect.size.width == 0) rect.size.width = 1;
        if ((int) rect.size.height == 0) rect.size.height = 1;
        self.captureWindowRect = [SnipUtil uniformRect:rect];
        self.startPoint = self.endPoint;
        [self redrawView:self.originImage];
    }
}

- (void)mouseMoved:(NSEvent *)theEvent
{
  //如果在刚开启截图时，才去寻找鼠标所在的窗口
  NSLog(@"Now in %@",self.screenIdentification);
  
  if ([SnipManager sharedInstance].captureState == CAPTURE_STATE_HILIGHT) {
    NSLog(@"searching the hight window");
      [self captureAppScreen];
  } else {
    NSLog(@"donot searching");
  }
  
}

- (void)onOK
{
    //获取截屏的图片
    NSImage *pasteImage = [self getCaptureImage];
    // 把选择的截图保存到粘贴板
    if (pasteImage != nil) {
        NSPasteboard *pasteBoard = [NSPasteboard generalPasteboard];
        [pasteBoard clearContents];
        [pasteBoard writeObjects:@[pasteImage]];
    }
    [[SnipManager sharedInstance] endCapture:pasteImage];
    [self.window orderOut:nil];

}

- (void)onExportImage {
    NSImage *pasteImage = [self getCaptureImage];
    if (pasteImage != nil) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd-HH-mm-ss";
        NSString *imagePath = [NSString stringWithFormat:@"%@/snip-%@.png",[[SnipManager sharedInstance] getExportPath],[formatter stringFromDate:[NSDate new]]];
        [self saveImage:pasteImage atPath:imagePath];
        NSLog(@"onExportImage: %@",imagePath);
    }
}


- (void)saveImage:(NSImage *)image atPath:(NSString *)path {
    
    CGImageRef cgRef = [image CGImageForProposedRect:NULL
                                             context:nil
                                               hints:nil];
    NSBitmapImageRep *newRep = [[NSBitmapImageRep alloc] initWithCGImage:cgRef];
    [newRep setSize:[image size]];   // if you want the same resolution
    NSData *pngData = [newRep representationUsingType:NSPNGFileType properties:nil];
    [pngData writeToFile:path atomically:YES];
}

- (NSImage *)getCaptureImage {
  [self.originImage lockFocus];
  NSRect rect = NSIntersectionRect(self.captureWindowRect, self.window.frame);
  //[self.snipView.pathView drawFinishCommentInRect:[self.window convertRectFromScreen:rect]];
  //先设置 下面一个实例
  NSBitmapImageRep *bits = [[NSBitmapImageRep alloc] initWithFocusedViewRect:[self.window convertRectFromScreen:rect]];
  
  [self.originImage unlockFocus];
  
  //再设置后面要用到得 props属性
  NSDictionary *imageProps = @{NSImageCompressionFactor : @(1.0)};
  
  //之后 转化为NSData 以便存到文件中
  NSData *imageData = [bits representationUsingType:NSJPEGFileType properties:imageProps];
  
  return [[NSImage alloc] initWithData:imageData];
}

- (void)keyDown:(NSEvent *)event {
  [[SnipManager sharedInstance] endCaptureimage];
  [super keyDown:event];
}
@end
