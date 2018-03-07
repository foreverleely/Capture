//
//  SnipManager.m
//  Snip
//
//  Created by rz on 15/1/31.
//  Copyright (c) 2015年 isee15. All rights reserved.
//

#import "SnipManager.h"
#import "SnipWindowController.h"
#import "SnipView.h"
#import "SnipWindow.h"

const double kBORDER_LINE_WIDTH = 2.0;
const int kBORDER_LINE_COLOR = 0x1191FE;
const int kKEY_ESC_CODE = 53;

@interface SnipManager ()
{
    NSString *exportPath;
}
@end

@implementation SnipManager

+ (instancetype)sharedInstance
{
    static SnipManager *sharedSingleton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^(void) {
        sharedSingleton = [[self alloc] init];
        sharedSingleton.windowControllerArray = [NSMutableArray array];
      
      sharedSingleton.funType = MJCToolBarFunRectangle;
      sharedSingleton.nLineWidth = 3;
      sharedSingleton.brushColor  = [NSColor redColor];
      sharedSingleton.nFontSize = 16;
      
      //空间变化时接受通知
        [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:sharedSingleton
                                                               selector:@selector(screenChanged:)
                                                                   name:NSWorkspaceActiveSpaceDidChangeNotification
                                                                 object:[NSWorkspace sharedWorkspace]];
      //计算机的显示器的配置变化时发生变化
        [[NSNotificationCenter defaultCenter] addObserver:sharedSingleton selector:@selector(screenChanged:) name:NSApplicationDidChangeScreenParametersNotification object:nil];
      
    });
    return sharedSingleton;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self];
}

- (void)screenChanged:(NSNotification *)notify
{
    if (self.isWorking) {
        [self endCapture:nil];
    }
}

- (void)clearController
{
    if (_windowControllerArray) {
        [_windowControllerArray removeAllObjects];
    }
}
//开始截图
- (void)startCapture
{
/*
    if (self.isWorking) return;
    self.isWorking = YES;*/
    self.arrayRect = [NSMutableArray array];
  //获取桌面内窗口数量
    NSArray *windows = (__bridge NSArray *) CGWindowListCopyWindowInfo(kCGWindowListOptionOnScreenOnly, kCGNullWindowID);
    NSUInteger count = [windows count];
    for (NSUInteger i = 0; i < count; i++) {
        NSDictionary *windowDescriptionDictionary = windows[i];
        [self.arrayRect addObject:windowDescriptionDictionary];
    }
  //获取屏幕数量
  int i = 0;
    for (NSScreen *screen in [NSScreen screens]) {
      //NSLog(@"screens %d", ++i);
        SnipWindowController *snipController = [[SnipWindowController alloc] init];
        SnipWindow *snipWindow = [[SnipWindow alloc] initWithContentRect:[screen frame] styleMask:NSNonactivatingPanelMask backing:NSBackingStoreBuffered defer:NO screen:screen];
        snipController.window = snipWindow;
        SnipView *snipView = [[SnipView alloc] initWithFrame:NSMakeRect(0, 0, [screen frame].size.width, [screen frame].size.height)];
        snipWindow.contentView = snipView;
        [self.windowControllerArray addObject:snipController];
        self.captureState = CAPTURE_STATE_HILIGHT;
        [snipController startCaptureWithScreen:screen];
      
    }
}

- (void)endCapture:(NSImage *)image
{
  
    
    for (SnipWindowController *windowController in self.windowControllerArray) {
        [windowController.window orderOut:nil];
      
    }
    [self clearController];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyCaptureEnd object:nil userInfo:image == nil ? nil : @{@"image" : image}];
  
}

- (void)configExportPath:(NSString *)path {
    exportPath = path;
}

- (NSString* )getExportPath {
    if (exportPath) {
        return [self checkSnipFolder:exportPath];
    }
    exportPath = [NSSearchPathForDirectoriesInDomains(NSPicturesDirectory, NSUserDomainMask, YES) firstObject];
    return [self checkSnipFolder:exportPath];
}

- (NSString* )checkSnipFolder:(NSString* )rootPath {
    if (![[NSFileManager defaultManager] fileExistsAtPath:rootPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:rootPath attributes:nil];
    }
    NSString *path = [NSString stringWithFormat:@"%@/snip",rootPath];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path attributes:nil];
    }
    return path;
}

@end
