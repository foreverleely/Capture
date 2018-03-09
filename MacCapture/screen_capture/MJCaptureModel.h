//
//  MJCaptureModel.h
//  MacCapture
//
//  Created by 115Browser on 8/16/15.
//  Copyright (c) 2015 jacky.115.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>
#import <Quartz/Quartz.h>


typedef enum MJCToolBarFunType{
    MJCToolBarFunRectangle,
    MJCToolBarFunCircle,
    MJCToolBarFunTriangleArrow,
    MJCToolBarFunBrush,
    MJCToolBarFunText,
    MJCToolBarFunMosaic
}MJCToolBarFunType;

typedef enum MJCMouseState{
  MJCMouseLeftBotton,       //0
  MJCMouseLeftMid,          //1
  MJCMouseLeftTop,          //2
  MJCMouseTopMid,           //3
  MJCMouseRightTop,         //4
  MJCMouseRightMid,         //5
  MJCMouseRightBotton,      //6
  MJCMouseBottomMid,        //7
  
  MJCMouseInCropMove,       //8
  MJCMouseOutCropRotation   //9
}MJCMouseState;

@interface NSImage (MJCaptureImage)
- (NSBitmapImageRep *)bitmapImageRepresentation;
@end

int getTriangleArrowWidth();
void drawTriangleArrow(CGContextRef context, CGPoint from, CGPoint to, int lineWidth);

void releaseMyContextData(CGContextRef content);
CGContextRef MyCreateBitmapContext (int pixelsWide, int pixelsHigh);

#pragma mark image operation
void saveCaptureImage(NSString *strSavePath, NSBitmapImageRep* rep);

NSImage* createNSImageFromCGImageRef(CGImageRef image);
//缩放图片 按比例
CGImageRef createScaleImageByRatio(NSImage *image, float fratio);
//缩放图片 按宽高 (既新的返回图片的宽变成width 高变成height)
//CGImageRef createScaleImageByXY(CGImageRef image, float width, float height);
CGImageRef createCGImageRefFromNSImage(NSImage* image);

BOOL saveImagepng(NSString *strSavePath, CGImageRef imageRef);


uint32_t ChangeBits(uint32_t currentBits, uint32_t flagsToChange, BOOL setFlags);

@protocol MJCaptureImageDelegate <NSObject>

- (void)CapturePrunedWindowList:(NSMutableArray*)array;
- (void)CaptureImageOutput:(NSImage*)image;

@end

#pragma mark MJCaptureModel
@interface MJCaptureModel : NSObject{
    id<MJCaptureImageDelegate> delegate;
    
    CGWindowListOption listOptions;
    CGWindowListOption singleWindowListOptions;
    CGWindowImageOption imageOptions;
    CGRect imageBounds;
}

@property (assign) id<MJCaptureImageDelegate> delegate;

-(NSMutableArray *)getWindowList:(CGWindowListOption)customListOptions  windowID:(CGWindowID)windowID;

// Simple screen shot mode!
-(CGImageRef)createScreenShotImage;
-(IBAction)refreshWindowList:(id)sender;

@end
