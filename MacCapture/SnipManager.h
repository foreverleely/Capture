//
//  SnipManager.h
//  Snip
//
//  Created by rz on 15/1/31.
//  Copyright (c) 2015年 isee15. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "MJCaptureModel.h"

typedef NS_ENUM(NSInteger, CAPTURE_STATE)
{
  CAPTURE_STATE_HILIGHT = 0,          //开始截图，选择窗口状态（最初的状态）
  CAPTURE_STATE_FIRSTMOUSEDOWN,   //鼠标第一次点下去，选中截屏窗口
  CAPTURE_STATE_READYADJUST,      //正在拖动截图区域
  CAPTURE_STATE_ADJUST,           //停止拖动，跟FIRSTMOUSEDOWN状态一样
  CAPTURE_STATE_EDIT,             //编辑
  CAPTURE_STATE_DONE,             //完成
};

typedef NS_ENUM(int, DRAW_TYPE)
{
    DRAW_TYPE_RECT,
    DRAW_TYPE_ELLIPSE,
    DRAW_TYPE_ARROW
};

#define kNotifyCaptureEnd @"kNotifyCaptureEnd"
#define kNotifyMouseLocationChange @"kNotifyMouseLocationChange"
extern const double kBORDER_LINE_WIDTH;
extern const int kBORDER_LINE_COLOR;
extern const int kKEY_ESC_CODE;


@interface SnipManager : NSObject

@property (strong)NSMutableArray *windowControllerArray;

@property (strong)NSMutableArray *arrayRect;

@property CAPTURE_STATE captureState;

@property DRAW_TYPE drawType;

@property BOOL isWorking;

///add new
@property int nLineWidth;
@property MJCToolBarFunType funType;
@property (strong)NSColor* brushColor;
@property int nFontSize;
///

+ (instancetype)sharedInstance;

- (void)endCapture:(NSImage *)image;

- (void)endCaptureimage;

- (void)startCapture;

- (void)configExportPath:(NSString *)path;

- (NSString* )getExportPath;

@end
