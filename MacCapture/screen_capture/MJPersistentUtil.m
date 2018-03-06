//
//  CustomSlider.m
//  WindowTest
//
//  Created by 115 on 16/9/27.
//  Copyright © 2016年 115. All rights reserved.
//

#import "MJPersistentUtil.h"

@implementation PersistentModal

- (nullable instancetype) init{
    if(self = [super init]){
        type_ = 0;
        line_width_ = 3;
        //brush_color_ = nil;
        brush_color_ = 10;
        text_size_ = 16;
        slider_value_ = 0;
    }
    return self;
}
- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeInt:type_ forKey:@"type_"];
    [aCoder encodeInt:line_width_ forKey:@"line_width_"];
    //[aCoder encodeObject:brush_color_ forKey:@"brush_color_"];
    [aCoder encodeInt:brush_color_ forKey:@"brush_color_"];
    [aCoder encodeInt:text_size_ forKey:@"text_size_"];
    [aCoder encodeInt:slider_value_ forKey:@"slider_value_"];
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder{
    if(self  = [super init]){
        type_ = [aDecoder decodeIntForKey:@"type_"];
        line_width_ = [aDecoder decodeIntForKey:@"line_width_"];
        //brush_color_ = [aDecoder decodeObjectForKey:@"brush_color_"];
        brush_color_ = [aDecoder decodeIntForKey:@"brush_color_"];
        text_size_ = [aDecoder decodeIntForKey:@"text_size_"];
        slider_value_ = [aDecoder decodeIntForKey:@"slider_value_"];
    }
    return self;
}
- (int) type{
    return type_;
}
- (int) lineWidth{
    return line_width_;
}
/*
- (NSColor*) brushColor{
    return brush_color_;
}
 */
- (int) brushColor{
    return brush_color_;
}
- (int) textSize{
    return text_size_;
}
- (int) sliderValue{
    return slider_value_;
}
- (void) setType:(int)type{
    type_ = type;
}
- (void) setLineWidth:(int)width{
    line_width_ = width;
}
/*
- (void) setBrushColor:(NSColor*) color{
    NSLog(@"%@", color);
    brush_color_ = [color retain];
}
 */
- (void) setBrushColor:(int)color{
    brush_color_ = color;
}
- (void) setTextSize:(int) size{
    text_size_ = size;
}
- (void) setSliderValue:(int)value{
    slider_value_ = value;
}

@end







@implementation MJPersistentUtil

static MJPersistentUtil* instance_ = nil;

+ (id) getInstance{
    if(!instance_)
        instance_ = [[MJPersistentUtil alloc] init];
    return instance_;
}

- (id) init{
    if(self = [super init]){
        arr_modal_ = [[NSMutableArray alloc] init];

        //读取配置
        NSMutableArray* arr = nil;
        NSUserDefaults* user = [NSUserDefaults standardUserDefaults];
        if([[[user dictionaryRepresentation] allKeys] containsObject:@"persistent_modal_data"]){
            NSData* data = [user objectForKey:@"persistent_modal_data"];
            arr = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        }
        if(arr == nil){
            for(int m=0; m<6; m++){
                PersistentModal* modal = [[PersistentModal alloc] init];
                [modal setType:m];
                [arr_modal_ addObject:modal];
            }
        }else{
            for(int m=0; m<6; m++){
                PersistentModal* modal = [[PersistentModal alloc] init];
                [modal setType:m];
                [arr_modal_ addObject:modal];
            }
            for(int m=0; m<6; m++){
                PersistentModal* modal = [arr_modal_ objectAtIndex:m];
                
                for(int i=0; i<[arr count]; i++){
                    PersistentModal* temp = [arr objectAtIndex:i];
                    if([temp type] == [modal type]){
                        [modal setLineWidth: [temp lineWidth]];
                        [modal setBrushColor:[temp brushColor]];
                        [modal setTextSize:[temp textSize]];
                        [modal setSliderValue:[temp sliderValue]];
                    }
                }
            }
        }
        
        //同步保存到文件
        [self syncPersistentData];
    }
    return self;
}

- (void) setLineWidth:(int)type lineWidth:(int)width{
    //修改内存值
    for(int m=0; m<[arr_modal_ count]; m++){
        PersistentModal* modal = [arr_modal_ objectAtIndex:m];
        if([modal type] == type){
            [modal setLineWidth:width];
            break;
        }
    }
    //同步保存到文件
    [self syncPersistentData];
}
/*
- (void) setBrushColor:(int)type brushColor:(NSColor*) color{
    //修改内容
    for(int m=0; m<[arr_modal_ count]; m++){
        PersistentModal* modal = [arr_modal_ objectAtIndex:m];
        if([modal type] == type){
            [modal setBrushColor:color];
            break;
        }
    }
    //同步保存到文件
    [self syncPersistentData];
}
 */
- (void) setBrushColor:(int)type brushColor:(int)color{
    //修改内容
    for(int m=0; m<[arr_modal_ count]; m++){
        PersistentModal* modal = [arr_modal_ objectAtIndex:m];
        if([modal type] == type){
            [modal setBrushColor:color];
            break;
        }
    }
    //同步保存到文件
    [self syncPersistentData];
}

- (void) setTextSize:(int)type textSize:(int) size{
    //修改内容
    for(int m=0; m<[arr_modal_ count]; m++){
        PersistentModal* modal = [arr_modal_ objectAtIndex:m];
        if([modal type] == type){
            [modal setTextSize:size];
            break;
        }
    }
    //同步保存到文件
    [self syncPersistentData];
}
- (void) setSliderValue:(int)type sliderValue:(int)value{
    //修改内容
    for(int m=0; m<[arr_modal_ count]; m++){
        PersistentModal* modal = [arr_modal_ objectAtIndex:m];
        if([modal type] == type){
            [modal setSliderValue:value];
            break;
        }
    }
    //同步保存到文件
    [self syncPersistentData];
}

- (int) lineWidth:(int)type{
    //读取内存值
    for(int m=0; m<[arr_modal_ count]; m++){
        PersistentModal* modal = [arr_modal_ objectAtIndex:m];
        if([modal type] == type){
            return [modal lineWidth];
        }
    }
    return 3;
}
/*
- (NSColor*) brushColor:(int)type{
    //读取内存值
    for(int m=0; m<[arr_modal_ count]; m++){
        PersistentModal* modal = [arr_modal_ objectAtIndex:m];
        if([modal type] == type){
            return [modal brushColor];
        }
    }
    return [NSColor redColor];
}
 */
- (int) brushColor:(int)type{
    //读取内存值
    for(int m=0; m<[arr_modal_ count]; m++){
        PersistentModal* modal = [arr_modal_ objectAtIndex:m];
        if([modal type] == type){
            return [modal brushColor];
        }
    }
    return 0;
}

- (int) textSize:(int)type{
    //读取内存值
    for(int m=0; m<[arr_modal_ count]; m++){
        PersistentModal* modal = [arr_modal_ objectAtIndex:m];
        if([modal type] == type){
            return [modal textSize];
        }
    }
    return 16;
}
- (int) sliderValue:(int)type{
    //读取内存值
    for(int m=0; m<[arr_modal_ count]; m++){
        PersistentModal* modal = [arr_modal_ objectAtIndex:m];
        if([modal type] == type){
            return [modal sliderValue];
        }
    }
    return 0;
}

- (void) syncPersistentData{
    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:arr_modal_];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"persistent_modal_data"];
}

- (int) lineWidthForType:(MJCToolBarFunType) type{
    int lineWidth = 0;
    switch (type) {
        case MJCToolBarFunRectangle:
            lineWidth = [self lineWidth:0];
            break;
        case MJCToolBarFunCircle:
            lineWidth = [self lineWidth:1];
            break;
        case MJCToolBarFunTriangleArrow:
            lineWidth = [self lineWidth:2];
            break;
        case MJCToolBarFunBrush:
            lineWidth = [self lineWidth:3];
            break;
        case MJCToolBarFunMosaic:
            lineWidth = [self lineWidth:4];
            break;
        case MJCToolBarFunText:
            lineWidth = [self lineWidth:5];
            break;
    }
    return lineWidth;
}

- (void) setLineWidthForType:(MJCToolBarFunType)type lineWidth:(int)width{
    switch (type) {
        case MJCToolBarFunRectangle:
            [self setLineWidth:0 lineWidth:width];
            break;
        case MJCToolBarFunCircle:
            [self setLineWidth:1 lineWidth:width];
            break;
        case MJCToolBarFunTriangleArrow:
            [self setLineWidth:2 lineWidth:width];
            break;
        case MJCToolBarFunBrush:
            [self setLineWidth:3 lineWidth:width];
            break;
        case MJCToolBarFunMosaic:
            [self setLineWidth:4 lineWidth:width];
            break;
        case MJCToolBarFunText:
            [self setLineWidth:5 lineWidth:width];
            break;
    }
}

- (int) brushColorForType:(MJCToolBarFunType) type{
    int color = 0;
    switch (type) {
        case MJCToolBarFunRectangle:
            color = [self brushColor:0];
            break;
        case MJCToolBarFunCircle:
            color = [self brushColor:1];
            break;
        case MJCToolBarFunTriangleArrow:
            color = [self brushColor:2];
            break;
        case MJCToolBarFunBrush:
            color = [self brushColor:3];
            break;
        case MJCToolBarFunMosaic:
            color = [self brushColor:4];
            break;
        case MJCToolBarFunText:
            color = [self brushColor:5];
            break;
    }
    return color;
}

- (void) setBrushColorForType:(MJCToolBarFunType)type brushColor:(int)color{
    switch (type) {
        case MJCToolBarFunRectangle:
            [self setBrushColor:0 brushColor:color];
            break;
        case MJCToolBarFunCircle:
            [self setBrushColor:1 brushColor:color];
            break;
        case MJCToolBarFunTriangleArrow:
            [self setBrushColor:2 brushColor:color];
            break;
        case MJCToolBarFunBrush:
            [self setBrushColor:3 brushColor:color];
            break;
        case MJCToolBarFunMosaic:
            [self setBrushColor:4 brushColor:color];
            break;
        case MJCToolBarFunText:
            [self setBrushColor:5 brushColor:color];
            break;
    }
}

- (int) textSizeForType:(MJCToolBarFunType) type{
    int textSize = 0;
    switch (type) {
        case MJCToolBarFunRectangle:
            textSize = [self textSize:0];
            break;
        case MJCToolBarFunCircle:
            textSize = [self textSize:1];
            break;
        case MJCToolBarFunTriangleArrow:
            textSize = [self textSize:2];
            break;
        case MJCToolBarFunBrush:
            textSize = [self textSize:3];
            break;
        case MJCToolBarFunMosaic:
            textSize = [self textSize:4];
            break;
        case MJCToolBarFunText:
            textSize = [self textSize:5];
            break;
    }
    return textSize;
}

- (void) setTextSizeForType:(MJCToolBarFunType)type textSize:(int) size{
    switch (type) {
        case MJCToolBarFunRectangle:
            [self setTextSize:0 textSize:size];
            break;
        case MJCToolBarFunCircle:
            [self setTextSize:1 textSize:size];
            break;
        case MJCToolBarFunTriangleArrow:
            [self setTextSize:2 textSize:size];
            break;
        case MJCToolBarFunBrush:
            [self setTextSize:3 textSize:size];
            break;
        case MJCToolBarFunMosaic:
            [self setTextSize:4 textSize:size];
            break;
        case MJCToolBarFunText:
            [self setTextSize:5 textSize:size];
            break;
    }
}

- (int) sliderValueForType:(MJCToolBarFunType) type{
    int sliderValue = 0;
    switch (type) {
        case MJCToolBarFunRectangle:
            sliderValue = [self sliderValue:0];
            break;
        case MJCToolBarFunCircle:
            sliderValue = [self sliderValue:1];
            break;
        case MJCToolBarFunTriangleArrow:
            sliderValue = [self sliderValue:2];
            break;
        case MJCToolBarFunBrush:
            sliderValue = [self sliderValue:3];
            break;
        case MJCToolBarFunMosaic:
            sliderValue = [self sliderValue:4];
            break;
        case MJCToolBarFunText:
            sliderValue = [self sliderValue:5];
            break;
    }
    return sliderValue;
}

- (void) setSliderValueForType:(MJCToolBarFunType) type sliderValue:(int)value{
    switch (type) {
        case MJCToolBarFunRectangle:
            [self setSliderValue:0 sliderValue:value];
            break;
        case MJCToolBarFunCircle:
            [self setSliderValue:1 sliderValue:value];
            break;
        case MJCToolBarFunTriangleArrow:
            [self setSliderValue:2 sliderValue:value];
            break;
        case MJCToolBarFunBrush:
            [self setSliderValue:3 sliderValue:value];
            break;
        case MJCToolBarFunMosaic:
            [self setSliderValue:4 sliderValue:value];
            break;
        case MJCToolBarFunText:
            [self setSliderValue:5 sliderValue:value];
            break;
    }
}








/*
+ (int) lineWidth{
    int ret = 0;
    NSUserDefaults* user = [NSUserDefaults standardUserDefaults];
    if([[[user dictionaryRepresentation] allKeys] containsObject:@"line_width"]){
        //ret = [[user stringForKey:@"line_width"] intValue];
        ret = [user integerForKey:@"line_width"];
    }
    //NSLog(@"%d", ret);
    return ret;
}

+ (NSColor*) brushColor{
    NSColor* color = nil;
    NSUserDefaults* user = [NSUserDefaults standardUserDefaults];
    if([[[user dictionaryRepresentation] allKeys] containsObject:@"brush_color"]){
        NSData *colorData = [user objectForKey:@"brush_color"];
        color = [NSKeyedUnarchiver unarchiveObjectWithData:colorData];
    }
    //NSLog(@"%@", color);
    
    return color;
}

+ (int) textSize{
    NSInteger ret = 0;
    NSUserDefaults* user = [NSUserDefaults standardUserDefaults];
    //if([user objectIsForcedForKey:@"text_size"]){
        //ret = [user integerForKey:@"text_size"];
    //}
    if([[[user dictionaryRepresentation] allKeys] containsObject:@"text_size"]){
        ret = [user integerForKey:@"text_size"];
    }
    return (int)ret;
}

+ (int) sliderValue{
    NSInteger ret = 0;
    NSUserDefaults* user = [NSUserDefaults standardUserDefaults];
    //if([user objectIsForcedForKey:@"slider_value"]){
        //ret = [user integerForKey:@"slider_value"];
    //}
    if([[[user dictionaryRepresentation] allKeys] containsObject:@"slider_value"]){
        ret = [user integerForKey:@"slider_value"];
    }
    return (int)ret;
}

+ (void) setLineWidth:(int)width{
    NSUserDefaults* user = [NSUserDefaults standardUserDefaults];
    //NSString *stringInt = [NSString stringWithFormat:@"%d",width];
    //[user setObject:stringInt forKey:@"line_width"];
    [user setInteger:width forKey:@"line_width"];
}

+ (void) setBrushColor:(NSColor*) color{
    //NSUserDefaults* user = [NSUserDefaults standardUserDefaults];
    //[user setObject:color forKey:@"brush_color"];
    NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:color];
    [[NSUserDefaults standardUserDefaults] setObject:colorData forKey:@"brush_color"];
    
    NSLog(@"setBrushColor");
}

+ (void) setTextSize:(int) size{
    NSUserDefaults* user = [NSUserDefaults standardUserDefaults];
    //[user setInteger:size forKey:@"text_size"];
    //[user synchronize];
    [user setInteger:size forKey:@"text_size"];
}

+ (void) setSliderValue:(int)value{
    NSUserDefaults* user = [NSUserDefaults standardUserDefaults];
    //[user setInteger:value forKey:@"slider_value"];
    //[user synchronize];
    [user setInteger:value forKey:@"slider_value"];
}
*/
@end
