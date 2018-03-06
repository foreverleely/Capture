//
//  MJMosaicUtil.h
//  MacCapture
//
//  Created by 115 on 16/9/19.
//  Copyright © 2016年 jacky.115.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import <CoreGraphics/CoreGraphics.h>

@interface MJMosaicUtil : NSObject

+ (CGImageRef) createCGImageRefFromNSImage : (NSImage*) image;
+ (NSImage *)transToMosaicImage:(NSImage*)orginImage blockLevel:(NSUInteger)level;

@end
