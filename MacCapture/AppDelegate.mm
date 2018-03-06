//
//  AppDelegate.m
//  MacCapture
//
//  Created by 115Browser on 8/16/15.
//  Copyright (c) 2015 jacky.115.com. All rights reserved.
//

#import "AppDelegate.h"

#import <string>

extern NSString *kAppNameKey;
NSString *kDistributedObjectServerNameKey = @"115Browser.Chanel";
NSString *kDistributedObjectClientNameKey = @"MacCapture.115.Chanel";

NSString *kDockClient115PlusIdentifierKey = @"com.115.client.-115Plus";
NSString *kDockClient115IdentifierKey = @"com.115.client.-115";

BOOL g_captureShouldKeepRunning = YES;        // global

@implementation TestPopUpButton

- (void)drawRect:(NSRect)dirtyRect{

}

@end


@implementation AppDelegate


@synthesize hotKey, isSavePitureAs1x_, isSaveToDeskDefault_;

- (void) hotkeyWithEvent:(NSEvent *)hkEvent {
//    NSLog(@"%@", [NSString stringWithFormat:@"Firing -[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd)]);
    NSLog(@"MacCapture hotkeyWithEvent: %@", [NSString stringWithFormat:@"Hotkey event: %@", hkEvent]);
    [self beginCapture:nil];
}

- (void) addOutput:(NSString *)newOutput {
    NSLog(@"%@", newOutput);
}

- (void)closeMacCaptureApp:(NSObject *)object
{
    [NSApp terminate:nil];
}

- (void) BrowserTerminated:(id)no{
//    return;
    NSRunningApplication *runApp = [[no userInfo] valueForKey:@"NSWorkspaceApplicationKey"];
    NSString *strAppID = runApp.bundleIdentifier;
    NSString *strBrowserID = [NSString stringWithFormat:@"%@", @"org.115browser.115Browser"];
    //NSLog(@"BrowserTerminated: bundleIdentifier1--:%@, %lu", strAppID, [strAppID length]);
    //NSLog(@"BrowserTerminated: bundleIdentifier2--:%@, %lu", strBrowserID, [strBrowserID length]);
    //i don't know why the id is equal, but use isEqualToString return false, so use this replace
    if ([strAppID containsString:@"115Browser"] && ([strAppID length] == [strBrowserID length])){
        //在115电脑版挂掉的时候，可以检测自动退出
        NSLog(@"BrowserTerminated: %@", @"检测到主进程没启动了，则退出");
        [self closeMacCaptureApp:nil];
    }
    if ([strBrowserID isEqualToString:strAppID]){
    }
}

void GetContent(std::string *out_response_string){
    std::string strValue = "applicationWillFinishLaunching: 已经正在运行，不用再次启动";
    const char *szContent = strValue.c_str();
    int length = strlen(szContent);

//    for (int i = 0; i < length; i++) {
//        out_response_string->append(&szContent[i], 1);
//        //NSLog(@"TestString:  %c", szContent[i]);
//    }

    int spos = 10;
    while (length > 0) {
        char dest_strl[10]= {0};
        if (length >= spos) {
            strncpy(dest_strl, szContent + (strlen(szContent)-length) , spos);
            out_response_string->append(dest_strl, spos);
            length -= spos;
        }else{
            strncpy(dest_strl, szContent + (strlen(szContent)-length) , length);
            out_response_string->append(dest_strl, length);
            length -= length;
        }
    }
}
- (void)applicationWillFinishLaunching:(NSNotification *)notification{

    isInitFromBrowser_ = NO;
    NSArray *array = [[NSWorkspace sharedWorkspace] runningApplications];
    int run_count = 0;
    for (int i = 0; i < [array count]; i++){
        NSRunningApplication *app = [array objectAtIndex:i];
        //NSLog(@"%@", [app bundleIdentifier]);
        if ([[app bundleIdentifier] isEqualToString:@"jacky.115.com.MacCapture"]) {
            run_count += 1;
            break;
        }
    }
//    std::string strContent = "\0";
//    GetContent(&strContent);
//    NSLog(@"TestString:  %@", [NSString stringWithUTF8String:strContent.c_str()]);

    if (run_count > 1) {
        NSLog(@"applicationWillFinishLaunching: %@", @"已经正在运行，不用再次启动");
        [NSApp terminate:nil];
    }
}

- (void)removeThe115ClientDockIcon{
    //sleep(2);
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary* dockDict = [[userDefaults persistentDomainForName:@"com.apple.dock"] mutableCopy];
    
    BOOL hasKeepDock = NO;
    NSMutableArray* apps = [[dockDict valueForKey:@"persistent-apps"] mutableCopy];
    if (apps != nil)
    {
        for(NSDictionary *anApp in apps)
        {
            NSDictionary* fileDict = [anApp valueForKey:@"tile-data"];
            if(fileDict != nil)
            {
                NSString *identify = [fileDict valueForKey:@"bundle-identifier"];
                if([kDockClient115PlusIdentifierKey isEqualToString:identify])
                {
                    hasKeepDock = YES;
                    [apps removeObject:anApp];
                }
                if([kDockClient115IdentifierKey isEqualToString:identify])
                {
                    hasKeepDock = YES;
                    [apps removeObject:anApp];
                }
            }
        }
    }
    if (hasKeepDock) {
        [dockDict setObject:apps forKey:@"persistent-apps"];
        [userDefaults setPersistentDomain:dockDict forName:@"com.apple.dock"];
        NSArray* array = [NSRunningApplication runningApplicationsWithBundleIdentifier:@"com.apple.dock"];
        for (NSRunningApplication *dock in array) {
            [dock terminate];
        }
    }
}
- (void)applicationWillTerminate:(NSNotification *)notification{
    [self performSelector:@selector(stopConnectionThread) onThread:msgThread withObject:nil waitUntilDone:YES];
    NSLog(@"applicationWillTerminate: %@", notification);
    
    //[self removeThe115ClientDockIcon];
}
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    [_window setDelegate:self];

    msgThread = [[NSThread alloc] initWithTarget:self selector:@selector(createNewConnectionThread) object:nil];
    [msgThread start];
    
    isSavePitureAs1x_ = NO;
    isSaveToDeskDefault_ = YES;

    NSArray* dirs = NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES);
    if ([dirs count] >= 1) {
        strSavePath_ = [[NSString alloc] initWithString:[dirs objectAtIndex:0]];
    }
    captureModel_ = [[MJCaptureModel alloc] init];

    [self performSelector:@selector(sendInitSettingInfoTo115Browser:) withObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], @"isOnlyInit", nil] afterDelay:0.001];

//    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self
//                                                           selector:@selector(BrowserLaunched:)
//                                                               name:NSWorkspaceDidLaunchApplicationNotification
//                                                             object:nil];

    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self
                                                           selector:@selector(BrowserTerminated:)
                                                               name:NSWorkspaceDidTerminateApplicationNotification
                                                             object:nil];                                                              

}
- (void) closeCaptureWindow{
    //[captureWindow_ release];
    captureWindow_ = nil;
}
//add by liuchipeng2016.1.6{
-(void)showKeyWindow{
    [[captureWindow_ CaptureView] mouseMoved:[NSApp currentEvent]];
//}
}
- (void) SetMouseEnventForFirst{
    [[captureWindow_ captureView] mouseEntered:[NSApp currentEvent]];
    [[captureWindow_ captureView] mouseMoved:[NSApp currentEvent]];
}
- (IBAction) beginCapture:(id)sender{
    if (!isInitFromBrowser_) {
        isInitFromBrowser_ = YES;
        sleep(0.01);
        [self sendInitSettingInfoTo115Browser:[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO], @"isOnlyInit", nil]];
        return;
    }
    [[NSPasteboard generalPasteboard] clearContents];
    if (!captureWindow_) {
        //[NSApp activateIgnoringOtherApps:YES];
        NSScreen *screen = [NSScreen mainScreen];
        NSRect rect = [screen frame];
        NSLog(@"screens: %@",[NSScreen screens]);
        int nval = 0;
        rect.origin.x += nval;
        rect.size.width -= nval;
        captureWindow_ = [[MJCaptureWindow alloc] initWithContentRect:rect styleMask:NSBorderlessWindowMask backing:NSBackingStoreRetained defer:YES];
        [captureWindow_ disableFlushWindow];
        captureWindow_.styleMask = NSPopUpMenuWindowLevel;
        //[_window addChildWindow:captureWindow_ ordered:NSWindowAbove];
        //[captureWindow_ makeKeyAndOrderFront:nil];
    }
    [self performSelector:@selector(SetMouseEnventForFirst) withObject:nil afterDelay:0.26];
}


#pragma mark 创建server，接收从115Browser过来的消息
- (void)createNewConnectionThread
{
    NSLog(@"capture-client-: createNewConnectionThread: begin");
    NSAutoreleasePool * pool = [NSAutoreleasePool new];
    //setup server connection
    NSConnection *serverConnection = [NSConnection new];
    //设置self为NSConnection的代理对象
    [serverConnection setRootObject:self];
    //connectionName是注册名称
    [serverConnection registerName:kDistributedObjectClientNameKey];
    
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    NSPort *port = [NSMachPort port];
    [runLoop addPort:port forMode:NSDefaultRunLoopMode]; // adding some input source, that is required for runLoop to runing
    // starting infinite loop which can be stopped by changing the shouldKeepRunning's value
    while (g_captureShouldKeepRunning && [runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]){
        NSLog(@"capture-client-: createNewConnectionThread: running");
    }
    if (port.valid) {
        [port invalidate];
    }
    if (serverConnection.valid){
        [serverConnection invalidate];
    }
    NSLog(@"capture-client-: createNewConnectionThread: stop");
    //[myRunLoop run];
    [pool release];
}
- (void)stopConnectionThread
{
    g_captureShouldKeepRunning = NO;
    CFRunLoopStop(CFRunLoopGetCurrent());
    NSThread *thread = [NSThread currentThread];
    [thread cancel];
}


- (NSString *)GetSavePath{
    return [NSString stringWithString:strSavePath_];
}
- (void)requestInitCaptureInfoAck:(NSMutableDictionary *)dic
{
    [self performSelectorOnMainThread:@selector(requestInitCaptureInfoAckMainThread:) withObject:dic waitUntilDone:NO];

}

- (void)requestInitCaptureInfoAckMainThread:(NSMutableDictionary *)dic{
    isSavePitureAs1x_ = [[dic objectForKey:@"kSaveOriginRetain"] boolValue];
    isSaveToDeskDefault_ = [[dic objectForKey:@"kSaveToDeskDefault"] boolValue];
    if (strSavePath_) {
        [strSavePath_ release];
    }
    strSavePath_ = [[NSString alloc] initWithString:[dic objectForKey:@"kSaveDefaultPath"]];
    //NSLog(@"strSavePath_: %@", strSavePath_);

  [self cleanHotCapture:nil];
}

- (void)beginCaptureImage:(NSObject *)object
{
    //NSLog(@"- (void)beginCaptureImage: %@", object);
    [self performSelectorOnMainThread:@selector(beginCapture:) withObject:nil waitUntilDone:NO];
}

- (void)cleanHotCapture:(NSObject *)object
{
    DDHotKeyCenter *c = [DDHotKeyCenter sharedHotKeyCenter];
    [c unregisterAllHotKeys];
}


#pragma mark  发送消息到115Browser
- (void)sendMessageTo115Browser:(NSImage*)image
{
    //这样就可以通过name取得注册的NSConnection的代理对象
    NSDistantObject *drawer = [NSConnection rootProxyForConnectionWithRegisteredName:kDistributedObjectServerNameKey host:nil];
    //调用代理对象中的方法，就跟普通对象一样，当然如果为了让代理对象的方法可见，可以定义公共的协议protocol
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:image forKey:@"kImage"];
    [drawer performSelector:@selector(finishCaptureImage:) withObject:dic];
}
- (void)sendInitSettingInfoTo115Browser:(NSMutableDictionary*)dic
{
    //NSLog(@"sendInitSettingInfoTo115Browser:  %@", dic);
    NSDistantObject *drawer = [NSConnection rootProxyForConnectionWithRegisteredName:kDistributedObjectServerNameKey host:nil];
    [drawer performSelector:@selector(requestInitCaptureInfo:) withObject:dic];
}

- (void)sendFailToResignHotKeyTo115Browser{
    NSDistantObject *drawer = [NSConnection rootProxyForConnectionWithRegisteredName:kDistributedObjectServerNameKey host:nil];
    [drawer performSelector:@selector(failToResignHotKey) withObject:nil];
}

@end
