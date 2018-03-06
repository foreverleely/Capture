//
//  MJMosaicUtil.m
//  MacCapture
//
//  Created by 115 on 16/9/19.
//  Copyright © 2016年 jacky.115.com. All rights reserved.
//

#import "MJMosaicUtil.h"

#define kBitsPerComponent (8)
#define kBitsPerPixel (32)
#define kPixelChannelCount (4)

@implementation MJMosaicUtil

+ (CGImageRef) createCGImageRefFromNSImage : (NSImage*) image
{
    NSData *imageData;
    CGImageRef imageRef;
    @try {
        imageData = [image TIFFRepresentation];
        if (imageData) {
            CGImageSourceRef imageSource = CGImageSourceCreateWithData((CFDataRef)imageData, NULL);
            NSDictionary* options = [NSDictionary dictionaryWithObjectsAndKeys:
                                     (id)kCFBooleanFalse, (id)kCGImageSourceShouldCache,
                                     (id)kCFBooleanTrue, (id)kCGImageSourceShouldAllowFloat,
                                     nil];
            
            //要用这个带option的 kCGImageSourceShouldCache指出不需要系统做cache操作 默认是会做的
            imageRef = CGImageSourceCreateImageAtIndex(imageSource, 0, (CFDictionaryRef)options);
            CFRelease(imageSource);
            return imageRef;
        }else{
            return NULL;
        }
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
    
    return NULL;
}

//这个是苹果官方的标准写法
NSImage* createNSImageFromCGImageRef2(CGImageRef image)
{
    NSImage* newImage = nil;
#if MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_5
    NSBitmapImageRep*newRep = [[NSBitmapImageRep alloc] initWithCGImage:image];
    NSSize imageSize;
    // Get the image dimensions.
    imageSize.height = CGImageGetHeight(image);
    imageSize.width = CGImageGetWidth(image);
    newImage = [[NSImage alloc] initWithSize:imageSize];
    [newImage addRepresentation:newRep];
    //[newRep release];
#else
    NSRect imageRect = NSMakeRect(0.0, 0.0, 0.0, 0.0);
    CGContextRef imageContext = nil;
    // Get the image dimensions.
    imageRect.size.height = CGImageGetHeight(image);
    imageRect.size.width = CGImageGetWidth(image);
    // Create a new image to receive the Quartz image data.
    newImage = [[NSImage alloc] initWithSize:imageRect.size];
    [newImage lockFocus];
    // Get the Quartz context and draw.
    imageContext = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
    CGContextDrawImage(imageContext, *(CGRect*)&imageRect, image);
    [newImage unlockFocus];
#endif
    return newImage;//[newImage autorelease];
}

+ (NSImage *)transToMosaicImage:(NSImage*)orginImage blockLevel:(NSUInteger)level
{
    //获取BitmapData
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    //CGImageRef imgRef = orginImage.CGImage;
    CGImageRef imgRef = [self createCGImageRefFromNSImage:orginImage];
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    CGContextRef context = CGBitmapContextCreate (nil,
                                                  width,
                                                  height,
                                                  kBitsPerComponent,        //每个颜色值8bit
                                                  width*kPixelChannelCount, //每一行的像素点占用的字节数，每个像素点的ARGB四个通道各占8个bit
                                                  colorSpace,
                                                  kCGImageAlphaPremultipliedLast);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imgRef);
    unsigned char *bitmapData = CGBitmapContextGetData (context);
    
    //这里把BitmapData进行马赛克转换,就是用一个点的颜色填充一个level*level的正方形
    unsigned char pixel[kPixelChannelCount] = {0};
    NSUInteger index,preIndex;
    for (NSUInteger i = 0; i < height - 1 ; i++) {
        for (NSUInteger j = 0; j < width - 1; j++) {
            index = i * width + j;
            if (i % level == 0) {
                if (j % level == 0) {
                    memcpy(pixel, bitmapData + kPixelChannelCount*index, kPixelChannelCount);
                }else{
                    memcpy(bitmapData + kPixelChannelCount*index, pixel, kPixelChannelCount);
                }
            } else {
                preIndex = (i-1)*width +j;
                memcpy(bitmapData + kPixelChannelCount*index, bitmapData + kPixelChannelCount*preIndex, kPixelChannelCount);
            }
        }
    }
    
    NSInteger dataLength = width*height* kPixelChannelCount;
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, bitmapData, dataLength, NULL);
    //创建要输出的图像
    CGImageRef mosaicImageRef = CGImageCreate(width, height,
                                              kBitsPerComponent,
                                              kBitsPerPixel,
                                              width*kPixelChannelCount ,
                                              colorSpace,
                                              kCGImageAlphaPremultipliedLast,
                                              provider,
                                              NULL, NO,
                                              kCGRenderingIntentDefault);
    CGContextRef outputContext = CGBitmapContextCreate(nil,
                                                       width,
                                                       height,
                                                       kBitsPerComponent,
                                                       width*kPixelChannelCount,
                                                       colorSpace,
                                                       kCGImageAlphaPremultipliedLast);
    CGContextDrawImage(outputContext, CGRectMake(0.0f, 0.0f, width, height), mosaicImageRef);
    CGImageRef resultImageRef = CGBitmapContextCreateImage(outputContext);
    /*
     UIImage *resultImage = nil;
     if([UIImage respondsToSelector:@selector(imageWithCGImage:scale:orientation:)]) {
     float scale = [[UIScreen mainScreen] scale];
     resultImage = [UIImage imageWithCGImage:resultImageRef scale:scale orientation:UIImageOrientationUp];
     } else {
     resultImage = [UIImage imageWithCGImage:resultImageRef];
     }
     */
    NSImage* resultImage = createNSImageFromCGImageRef2(resultImageRef);
    //释放
    if(resultImageRef){
        CFRelease(resultImageRef);
    }
    if(mosaicImageRef){
        CFRelease(mosaicImageRef);
    }
    if(colorSpace){
        CGColorSpaceRelease(colorSpace);
    }
    if(provider){
        CGDataProviderRelease(provider);
    }
    if(context){
        CGContextRelease(context);
    }
    if(outputContext){
        CGContextRelease(outputContext);
    }
    
    return resultImage;
}

@end
