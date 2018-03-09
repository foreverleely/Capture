//
//  AppDelegate.h
//  MacCapture
//
//  Created by 115Browser on 8/16/15.
//  Copyright (c) 2015 jacky.115.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DDHotKeyCenter.h"
#import <Carbon/Carbon.h>

#import "MJCaptureModel.h"


@protocol BrowserCaptureServerProtocol <NSObject>
- (void)finishCaptureImage:(NSMutableDictionary *)dic;
- (void)requestInitCaptureInfo:(NSMutableDictionary*)dic;
- (void)failToResignHotKey;
@end

@protocol MacCaptureClientProtocol <NSObject>
- (void)beginCaptureImage:(NSObject *)object;
- (void)requestInitCaptureInfoAck:(NSMutableDictionary *)dic;
- (void)cleanHotCapture:(NSObject *)object;
@end

@interface TestPopUpButton : NSPopUpButton
{
    
}


@end


@interface AppDelegate : NSObject <NSApplicationDelegate, NSWindowDelegate, MacCaptureClientProtocol>{
    NSThread* msgThread;
    
    IBOutlet TestPopUpButton *testPop;
    
    NSEvent *_eventMonitor;
    
    //是否有从浏览器那边传递参数过来初始化过
    BOOL  isInitFromBrowser_;
    //save retain is 1x piture
    BOOL  isSavePitureAs1x_;
    BOOL  isSaveToDeskDefault_;
    NSString *strSavePath_;
    
    //用来判断115电脑版是否存在，如果不存在，则结束该进程
    MJCaptureModel *captureModel_;

}

@property (assign) IBOutlet NSWindow *window;

@property (nonatomic, strong) DDHotKey *hotKey;

@property (assign) BOOL isSavePitureAs1x_;
@property (assign) BOOL isSaveToDeskDefault_;

- (NSString *)GetSavePath;

- (void) closeCaptureWindow;
- (IBAction) beginCapture:(id)sender;

- (void)sendMessageTo115Browser:(NSImage*)image;
@end
