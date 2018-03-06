//
//  CustomSlider.h
//  WindowTest
//
//  Created by 115 on 16/9/27.
//  Copyright © 2016年 115. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MJCaptureModel.h"
@interface PersistentModal : NSObject<NSCoding>{
    int type_;  //类型：0：矩形，1：圆形，2：箭头，3：画刷，4：马赛克，5：文本
    int line_width_;
    //NSColor* brush_color_;
    int brush_color_;  //保存的是颜色数组的索引
    int text_size_;
    int slider_value_;
}
- (nullable instancetype) init;
- (void)encodeWithCoder:(NSCoder *)aCoder;
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder;

- (int) type;
- (int) lineWidth;
//- (NSColor*) brushColor;
- (int) brushColor;
- (int) textSize;
- (int) sliderValue;

- (void) setType:(int)type;
- (void) setLineWidth:(int)width;
//- (void) setBrushColor:(NSColor*) color;
- (void) setBrushColor:(int)color;
- (void) setTextSize:(int) size;
- (void) setSliderValue:(int)value;

@end




@interface MJPersistentUtil : NSObject{
    NSMutableArray* arr_modal_;
}
+ (id) getInstance;
- (id) init;

- (void) setLineWidth:(int)type lineWidth:(int)width;
//- (void) setBrushColor:(int)type brushColor:(NSColor*) color;
- (void) setBrushColor:(int)type brushColor:(int)color;
- (void) setTextSize:(int)type textSize:(int) size;
- (void) setSliderValue:(int)type sliderValue:(int)value;

- (int) lineWidth:(int)type;
//- (NSColor*) brushColor:(int)type;
- (int) brushColor:(int)type;
- (int) textSize:(int)type;
- (int) sliderValue:(int)type;

- (void) syncPersistentData;

- (int) lineWidthForType:(MJCToolBarFunType) type;
- (void) setLineWidthForType:(MJCToolBarFunType)type lineWidth:(int)width;

- (int) brushColorForType:(MJCToolBarFunType) type;
- (void) setBrushColorForType:(MJCToolBarFunType)type brushColor:(int)color;

- (int) textSizeForType:(MJCToolBarFunType) type;
- (void) setTextSizeForType:(MJCToolBarFunType)type textSize:(int) size;

- (int) sliderValueForType:(MJCToolBarFunType) type;
- (void) setSliderValueForType:(MJCToolBarFunType) type sliderValue:(int)value;
/*
+ (int) lineWidth;
+ (NSColor*) brushColor;
+ (int) textSize;
+ (int) sliderValue;

+ (void) setLineWidth:(int)width;
+ (void) setBrushColor:(NSColor*) color;
+ (void) setTextSize:(int) size;
+ (void) setSliderValue:(int)value;
 */

@end
