//
//  MJCaptureModel.m
//  MacCapture
//
//  Created by 115Browser on 8/16/15.
//  Copyright (c) 2015 jacky.115.com. All rights reserved.
//

#import "MJCaptureModel.h"


int kTriangleArrowWidth = 60;
int getTriangleArrowWidth(){
    return kTriangleArrowWidth;
}
void drawTriangleArrow(CGContextRef context, CGPoint from, CGPoint to, int lineWidth)
{
    double slopy, cosy, siny;
    // Arrow size
    double length = 12.0;
    double width = lineWidth*2;
    if (lineWidth  == 4) {
        width = 12;
    }else if (lineWidth  == 8){
        width = 24;
    }else if (lineWidth  == 16){
        width = 36;
    }
    
    slopy = atan2((from.y - to.y), (from.x - to.x));
    cosy = cos(slopy);
    siny = sin(slopy);
    
    CGContextSetLineWidth(context, lineWidth);
    
    //draw a line between the 2 endpoint
    CGContextMoveToPoint(context, from.x - length * cosy/2.0, from.y - length * siny/2.0 );
    CGContextAddLineToPoint(context, to.x + length * cosy/2.0, to.y + length * siny/2.0);
    //paints a line along the current path
    CGContextStrokePath(context);
    
    //here is the tough part - actually drawing the arrows
    //a total of 6 lines drawn to make the arrow shape
    //    CGContextMoveToPoint(context, from.x, from.y);
    //    CGContextAddLineToPoint(context,
    //                            from.x + ( - length * cosy - ( width / 2.0 * siny )),
    //                            from.y + ( - length * siny + ( width / 2.0 * cosy )));
    ////    CGContextAddLineToPoint(context, from.x - length * cosy/2.0, from.y - length * siny/2.0 );
    //    CGContextAddLineToPoint(context,
    //                            from.x + (- length * cosy + ( width / 2.0 * siny )),
    //                            from.y - (width / 2.0 * cosy + length * siny ) );
    //    CGContextClosePath(context);
    //    CGContextStrokePath(context);
    
    /*/-------------similarly the the other end-------------/*/
    CGContextMoveToPoint(context, to.x, to.y);
    CGContextAddLineToPoint(context,
                            to.x +  (length * cosy - ( width / 2.0 * siny )),
                            to.y +  (length * siny + ( width / 2.0 * cosy )) );
    CGContextAddLineToPoint(context,
                            to.x +  (length * cosy + width / 2.0 * siny),
                            to.y -  (width / 2.0 * cosy - length * siny) );
    CGContextClosePath(context);
    //    CGContextStrokePath(context);
    CGContextFillPath(context);
}

void TriangleArrow1(CGContextRef context, CGPoint from, CGPoint to)
{
    double slopy, cosy, siny;
    // Arrow size
    double length = 12.0;
    double width = 16.0;
    
    slopy = atan2((from.y - to.y), (from.x - to.x));
    cosy = cos(slopy);
    siny = sin(slopy);
    
    //draw a line between the 2 endpoint
    CGContextMoveToPoint(context, from.x - length * cosy/2.0, from.y - length * siny/2.0 );
    CGContextAddLineToPoint(context, to.x + length * cosy/2.0, to.y + length * siny/2.0);
    //paints a line along the current path
    CGContextStrokePath(context);
    
    //here is the tough part - actually drawing the arrows
    //a total of 6 lines drawn to make the arrow shape
    CGContextMoveToPoint(context, from.x, from.y);
    CGContextAddLineToPoint(context,
                            from.x + ( - length * cosy - ( width / 2.0 * siny )),
                            from.y + ( - length * siny + ( width / 2.0 * cosy )));
    //    CGContextAddLineToPoint(context, from.x - length * cosy/2.0, from.y - length * siny/2.0 );
    CGContextAddLineToPoint(context,
                            from.x + (- length * cosy + ( width / 2.0 * siny )),
                            from.y - (width / 2.0 * cosy + length * siny ) );
    CGContextClosePath(context);
    CGContextStrokePath(context);
    
    /*/-------------similarly the the other end-------------/*/
    CGContextMoveToPoint(context, to.x, to.y);
    CGContextAddLineToPoint(context,
                            to.x +  (length * cosy - ( width / 2.0 * siny )),
                            to.y +  (length * siny + ( width / 2.0 * cosy )) );
    CGContextAddLineToPoint(context,
                            to.x +  (length * cosy + width / 2.0 * siny),
                            to.y -  (width / 2.0 * cosy - length * siny) );
    CGContextClosePath(context);
    CGContextStrokePath(context);
}


void releaseMyContextData(CGContextRef content){
    void *imgdata =CGBitmapContextGetData(content);
    CGContextRelease(content);
    if (imgdata) {
        free(imgdata);
    }
}

CGContextRef MyCreateBitmapContext (int pixelsWide,
                                    int pixelsHigh)
{
    CGContextRef context = NULL;
    CGColorSpaceRef colorSpace;
    GLubyte		*bitmapData;
    int			bitmapByteCount;
    int			bitmapBytesPerRow;
    
    bitmapBytesPerRow = (pixelsWide * 4);
    bitmapByteCount = (bitmapBytesPerRow * pixelsHigh);
    
    colorSpace = CGColorSpaceCreateDeviceRGB();//CGColorSpaceCreateWithName(kCGColorSpaceSRGB);//CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);//
    
    //z这里初始化用malloc和calloc都可以 (注意:malloc只能分配内存 初始化所分配的内存空间 calloc则可以)
    //在此需要特别注意的是  第二个参数传0进去  如果传比较大的数值进去的话  则会内存泄漏 比如传8之类的就会出现大的泄漏问题
    /*如果调用成功,函数malloc()和函数calloc()都
     将返回所分配的内存空间的首地址。
     函数malloc()和函数calloc()的主要区别是前
     者不能初始化所分配的内存空间,而后者能。如
     果由malloc()函数分配的内存空间原来没有被
     使用过，则其中的每一位可能都是0;反之,如果
     这部分内存曾经被分配过,则其中可能遗留有各
     种各样的数据。也就是说，使用malloc()函数
     的程序开始时(内存空间还没有被重新分配)能
     正常进行,但经过一段时间(内存空间还已经被
     重新分配)可能会出现问题
     函数calloc()会将所分配的内存空间中的每一
     位都初始化为零,也就是说,如果你是为字符类
     型或整数类型的元素分配内存,那麽这些元素将
     保证会被初始化为0;如果你是为指针类型的元
     素分配内存,那麽这些元素通常会被初始化为空
     指针;如果你为实型数据分配内存,则这些元素
     会被初始化为浮点型的零*/
    //NSLog(@"%lu", sizeof(GLubyte));
    bitmapData = (GLubyte*)calloc(bitmapByteCount,sizeof(GLubyte));//or malloc(bitmapByteCount);//
    
    if (bitmapData == NULL) {
        fprintf(stderr, "Memory not allocated!");
        return NULL;
    }
    
    context = CGBitmapContextCreate(bitmapData,
                                    pixelsWide,
                                    pixelsHigh,
                                    8,
                                    bitmapBytesPerRow,
                                    colorSpace,
                                    kCGImageAlphaPremultipliedLast);
    if (context == NULL) {
        free(bitmapData);
        fprintf(stderr, "Context not created!");
        return NULL;
    }
    CGColorSpaceRelease(colorSpace);
    return context;
}

#pragma mark image operation
void saveCaptureImage(NSString *strSavePath, NSBitmapImageRep* rep){
    NSData* data = [rep representationUsingType:NSPNGFileType properties:nil];
//    NSString* strSavePath = NSHomeDirectory();
//    //strSave  = [strSave stringByAppendingPathComponent:@"Documents/com.115.ScreenCapture"];
//    strSavePath  = [strSavePath stringByAppendingPathComponent:@"Desktop/"];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL isDir = YES;
    NSLog(@"saveCaptureImage strSavePath: %@", strSavePath);
    if (![fm fileExistsAtPath:strSavePath isDirectory:&isDir]) {
        NSLog(@"saveCaptureImage path not exist: %@", strSavePath);
        NSError *error = nil;
        if (![fm createDirectoryAtPath:strSavePath withIntermediateDirectories:YES attributes:nil error:&error]) {
            NSLog(@"saveCaptureImage createDirectoryAtPath path error: %@", error);
            return;
        }else{
            NSLog(@"saveCaptureImage createDirectoryAtPath path success");
        }
    }
    
    NSDate* currentDate = [NSDate date];
    NSString *dateDescStr = [currentDate descriptionWithLocale:[NSLocale currentLocale]];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    //[dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dateFormat setDateFormat:@"yyyyMMddHHmmss"];
    NSString *theDate = [dateFormat stringFromDate:currentDate];
    NSLog(@"%@", dateDescStr);
    NSString* strPath = [strSavePath stringByAppendingPathComponent:[NSString stringWithFormat:@"115截图%@.png", theDate]];
    int i = 1;
    while ([fm fileExistsAtPath:strPath]) {
        strPath = [strSavePath stringByAppendingPathComponent:[NSString stringWithFormat:@"115截图%@%d.png", theDate,i]];
        i++;
    }
    NSLog(@"strPath:%@", strPath);
    [data writeToFile:strPath atomically:YES];
}

NSImage* createNSImageFromCGImageRef(CGImageRef image){
    NSRect  imageRect = NSMakeRect(0, 0, 0, 0);
    CGContextRef imageContext = nil;
    NSImage *newImage = nil;
    //Get the image dimensions
    @try {
        imageRect.size.height = CGImageGetHeight(image);
        imageRect.size.width = CGImageGetWidth(image);
        
        //要转换成整数，否则在大图片时可能出现异常
        //Create a new image to receive the Quartz image data
        newImage = [[NSImage alloc] initWithSize:imageRect.size];
        [newImage lockFocus];
        
        //Get the Quartz context and draw
        imageContext = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
        //CGContextSaveGState(imageContext);
        CGContextDrawImage(imageContext, *(CGRect*)&imageRect, image);
        //CGContextRestoreGState(imageContext);
        [newImage unlockFocus];
        //CFRelease(imageContext);
        
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
    
    return newImage;
}
CGImageRef createScaleImageByRatio(NSImage *image, float fratio){
    NSData *imageData;
    imageData = [image TIFFRepresentation];
    if (imageData) {
        CGImageSourceRef imageSource = CGImageSourceCreateWithData((CFDataRef)imageData, NULL);
        
        NSDictionary *options = [[NSDictionary alloc] initWithObjectsAndKeys:
                                 // Ask ImageIO to create a thumbnail from the file's image data, if it can't find a suitable existing thumbnail image in the file.  We could comment out the following line if only existing thumbnails were desired for some reason (maybe to favor performance over being guaranteed a complete set of thumbnails).
                                 [NSNumber numberWithBool:YES], (NSString *)kCGImageSourceCreateThumbnailFromImageIfAbsent,
                                 [NSNumber numberWithInt:[image size].width*fratio], (NSString *)kCGImageSourceThumbnailMaxPixelSize,
                                 nil];
        CGImageRef thumbnail = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, (CFDictionaryRef)options);
        CFRelease(imageSource);
        return thumbnail;
    }
    
    return nil;
}
CGImageRef createCGImageRefFromNSImage(NSImage* image)
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
            
            //要用这个带option的  否则会出现很严重的内存泄漏问题
            imageRef = CGImageSourceCreateImageAtIndex(imageSource, 0, (CFDictionaryRef)options);
            //imageRef = CGImageSourceCreateImageAtIndex(imageSource, 0, NULL);
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
//CGImageRef createScaleImageByXY(CGImageRef image, float width, float height) {
//    CGContextRef content = MyCreateBitmapContext(width, height);
//    CGContextDrawImage(content, CGRectMake(0, 0, width, height), image);
//    CGImageRef img = CGBitmapContextCreateImage(content);
//
//    releaseMyContextData(content);
//
//    return img;
//}

BOOL saveImagepng(NSString *strSavePath, CGImageRef imageRef)
{
    NSString *finalPath = [NSString stringWithString:strSavePath];
    CFURLRef url = CFURLCreateWithFileSystemPath (
                                                  kCFAllocatorDefault,
                                                  (CFStringRef)finalPath,
                                                  kCFURLPOSIXPathStyle,
                                                  false);
    CGImageDestinationRef dest = CGImageDestinationCreateWithURL(url, CFSTR("public.png"), 1, NULL);
    assert(dest);
    CGImageDestinationAddImage(dest, imageRef, NULL);
    assert(dest);
    if (dest == NULL) {
        NSLog(@"CGImageDestinationCreateWithURL failed");
    }
    //NSLog(@"%@", dest);
    assert(CGImageDestinationFinalize(dest));
    
    //这三句话用来释放对象
    CFRelease(dest);
    //CGImageRelease(imageRef);
    CFRelease(url);
    return YES;
}


@implementation NSImage (MJCaptureImage)
- (NSBitmapImageRep *)bitmapImageRepresentation {
    int width = [self size].width;
    int height = [self size].height;
    
    if(width < 1 || height < 1)
        return nil;
    
    NSBitmapImageRep *rep = [[NSBitmapImageRep alloc]
                             initWithBitmapDataPlanes: NULL
                             pixelsWide: width
                             pixelsHigh: height
                             bitsPerSample: 8
                             samplesPerPixel: 4
                             hasAlpha: YES
                             isPlanar: NO
                             colorSpaceName: NSDeviceRGBColorSpace
                             bytesPerRow: width * 4
                             bitsPerPixel: 32];
    
    NSGraphicsContext *ctx = [NSGraphicsContext graphicsContextWithBitmapImageRep: rep];
    [NSGraphicsContext saveGraphicsState];
    [NSGraphicsContext setCurrentContext: ctx];
    [self drawAtPoint: NSZeroPoint fromRect: NSZeroRect operation: NSCompositeCopy fraction: 1.0];
    [ctx flushGraphics];
    [NSGraphicsContext restoreGraphicsState];
    
    return [rep autorelease];
}


@end



#pragma mark MJCaptureModel
@implementation MJCaptureModel
@synthesize delegate;

#pragma mark Basic Profiling Tools
// Set to 1 to enable basic profiling. Profiling information is logged to console.
#ifndef PROFILE_WINDOW_GRAB
#define PROFILE_WINDOW_GRAB 0
#endif

#if PROFILE_WINDOW_GRAB
#define StopwatchStart() AbsoluteTime start = UpTime()
#define Profile(img) CFRelease(CGDataProviderCopyData(CGImageGetDataProvider(img)))
#define StopwatchEnd(caption) do { Duration time = AbsoluteDeltaToDuration(UpTime(), start); double timef = time < 0 ? time / -1000000.0 : time / 1000.0; NSLog(@"%s Time Taken: %f seconds", caption, timef); } while(0)
#else
#define StopwatchStart()
#define Profile(img)
#define StopwatchEnd(caption)
#endif

#pragma mark Utilities

// Simple helper to twiddle bits in a uint32_t.
//inline uint32_t ChangeBits(uint32_t currentBits, uint32_t flagsToChange, BOOL setFlags);
/*inline*/ uint32_t ChangeBits(uint32_t currentBits, uint32_t flagsToChange, BOOL setFlags)
{
    if(setFlags)
    {	// Set Bits
        return currentBits | flagsToChange;
    }
    else
    {	// Clear Bits
        return currentBits & ~flagsToChange;
    }
}

-(void)setOutputImage:(CGImageRef)cgImage
{
    if(cgImage != NULL)
    {
        // Create a bitmap rep from the image...
        NSBitmapImageRep *bitmapRep = [[NSBitmapImageRep alloc] initWithCGImage:cgImage];
        // Create an NSImage and add the bitmap rep to it...
        NSImage *image = [[NSImage alloc] init];
        [image addRepresentation:bitmapRep];
        [bitmapRep release];
        // Set the output view to the new NSImage.
        if (delegate && [delegate respondsToSelector:@selector(CaptureImageOutput:)]) {
            [delegate CaptureImageOutput:image];
        }
        [image release];
    }
    else
    {
        if (delegate && [delegate respondsToSelector:@selector(CaptureImageOutput:)]) {
            [delegate CaptureImageOutput:nil];
        }
    }
}

#pragma mark Window List & Window Image Methods
typedef struct
{
    // Where to add window information
    NSMutableArray * outputArray;
    // Tracks the index of the window when first inserted
    // so that we can always request that the windows be drawn in order.
    int order;
} WindowListApplierData;

NSString *kAppNameKey = @"applicationName";	// Application Name & PID
NSString *kWindowOriginKey = @"windowOrigin";	// Window Origin as a string
NSString *kWindowSizeKey = @"windowSize";		// Window Size as a string
NSString *kWindowFrameKey = @"windowFrame";		// Window frame as a string
NSString *kWindowIsOnscreenKey = @"windowIsOnscreen";		// kCGWindowIsOnscreen

NSString *kWindowIDKey = @"windowID";			// Window ID
NSString *kWindowLevelKey = @"windowLevel";	// Window Level
NSString *kWindowOrderKey = @"windowOrder";	// The overall front-to-back ordering of the windows as returned by the window server

void WindowListApplierFunction(const void *inputDictionary, void *context);
void WindowListApplierFunction(const void *inputDictionary, void *context)
{
    NSDictionary *entry = (NSDictionary*)inputDictionary;
    WindowListApplierData *data = (WindowListApplierData*)context;
    
    // The flags that we pass to CGWindowListCopyWindowInfo will automatically filter out most undesirable windows.
    // However, it is possible that we will get back a window that we cannot read from, so we'll filter those out manually.
    //int sharingState = [[entry objectForKey:(id)kCGWindowSharingState] intValue];
    
    id isOnscreen = [entry objectForKey:(id)kCGWindowIsOnscreen];
    if(isOnscreen)//(sharingState != kCGWindowSharingNone && isOnscreen)
    {
        NSMutableDictionary *outputEntry = [NSMutableDictionary dictionary];
        
        // Grab the application name, but since it's optional we need to check before we can use it.
        NSString *applicationName = [entry objectForKey:(id)kCGWindowOwnerName];
        if(applicationName != NULL)
        {
            // PID is required so we assume it's present.
            //			NSString *nameAndPID = [NSString stringWithFormat:@"%@ (%@)", applicationName, [entry objectForKey:(id)kCGWindowOwnerPID]];
            //            [outputEntry setObject:nameAndPID forKey:kAppNameKey];
            [outputEntry setObject:applicationName forKey:kAppNameKey];
        }
        else
        {
            // The application name was not provided, so we use a fake application name to designate this.
            // PID is required so we assume it's present.
            //			NSString *nameAndPID = [NSString stringWithFormat:@"((unknown)) (%@)", [entry objectForKey:(id)kCGWindowOwnerPID]];
            //			[outputEntry setObject:nameAndPID forKey:kAppNameKey];
            
            [outputEntry setObject:@"unknown" forKey:kAppNameKey];
        }
        
        // Grab the Window Bounds, it's a dictionary in the array, but we want to display it as a string
        CGRect bounds;
        CGRectMakeWithDictionaryRepresentation((CFDictionaryRef)[entry objectForKey:(id)kCGWindowBounds], &bounds);
        
        bounds.origin.y=[[NSScreen mainScreen] frame].size.height-bounds.origin.y-bounds.size.height;
        
        NSString *originString = NSStringFromPoint(NSPointFromCGPoint(bounds.origin));
        [outputEntry setObject:originString forKey:kWindowOriginKey];
        NSString *sizeString = NSStringFromSize(NSSizeFromCGSize(bounds.size));
        [outputEntry setObject:sizeString forKey:kWindowSizeKey];
        
        //NSLog(@"%@", [[NSBundle mainBundle] resourcePath]);
        NSString *strAppName = [[[NSBundle mainBundle] executablePath] lastPathComponent];
        //NSLog(@"%@", strAppName);
        NSString *strtemp = @"115";//115\U6d4f\U89c8\U5668
        //NSLog(@"appName1: %@", strAppName);
        //NSLog(@"appName2: %@", strtemp);
        //NSLog(@"appName3: %@", applicationName);
        if (NSEqualRects(NSRectFromCGRect(bounds), [[NSScreen mainScreen] frame]) && ([applicationName isEqualToString:@"Dock"] || [applicationName isEqualToString:@"Window Server"] || [applicationName isEqualToString:@"Finder"] || [applicationName isEqualToString:strAppName] || [applicationName isEqualToString:strtemp])) {
            return;
        }
        
        [outputEntry setObject:NSStringFromRect(NSRectFromCGRect(bounds)) forKey:kWindowFrameKey];
        
        if ([entry objectForKey:(id)kCGWindowIsOnscreen]) {
            [outputEntry setObject:isOnscreen forKey:kWindowIsOnscreenKey];
        }
        
        // Grab the Window ID & Window Level. Both are required, so just copy from one to the other
        [outputEntry setObject:[entry objectForKey:(id)kCGWindowNumber] forKey:kWindowIDKey];
        [outputEntry setObject:[entry objectForKey:(id)kCGWindowLayer] forKey:kWindowLevelKey];
        
        // Finally, we are passed the windows in order from front to back by the window server
        // Should the user sort the window list we want to retain that order so that screen shots
        // look correct no matter what selection they make, or what order the items are in. We do this
        // by maintaining a window order key that we'll apply later.
        [outputEntry setObject:[NSNumber numberWithInt:data->order] forKey:kWindowOrderKey];
        data->order++;
        
        [data->outputArray addObject:outputEntry];
    }
}

-(NSMutableArray *)getWindowList:(CGWindowListOption)customListOptions  windowID:(CGWindowID)windowID
{
    // Ask the window server for the list of windows.
    StopwatchStart();
    CFArrayRef windowList = CGWindowListCopyWindowInfo(customListOptions, windowID);
    StopwatchEnd("Create Window List");
    
    // Copy the returned list, further pruned, to another list. This also adds some bookkeeping
    // information to the list as well as
    NSMutableArray * prunedWindowList = [NSMutableArray array];
    WindowListApplierData data = {prunedWindowList, 0};
    CFArrayApplyFunction(windowList, CFRangeMake(0, CFArrayGetCount(windowList)), &WindowListApplierFunction, &data);
    
    //    if (delegate && [delegate respondsToSelector:@selector(CapturePrunedWindowList:)]) {
    //        [delegate CapturePrunedWindowList:prunedWindowList];
    //    }
    
    CFRelease(windowList);
    
    return prunedWindowList;
    
    // Set the new window list
    //	[arrayController setContent:prunedWindowList];
}

-(CFArrayRef)newWindowListFromSelection:(NSArray*)selection
{
    // Create a sort descriptor array. It consists of a single descriptor that sorts based on the kWindowOrderKey in ascending order
    NSArray * sortDescriptors = [NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:kWindowOrderKey ascending:YES] autorelease]];
    
    // Next sort the selection based on that sort descriptor array
    NSArray * sortedSelection = [selection sortedArrayUsingDescriptors:sortDescriptors];
    
    // Now we Collect the CGWindowIDs from the sorted selection
    CGWindowID *windowIDs = (CGWindowID *)calloc([sortedSelection count], sizeof(CGWindowID));
    int i = 0;
    for(NSMutableDictionary *entry in sortedSelection)
    {
        windowIDs[i++] = [[entry objectForKey:kWindowIDKey] unsignedIntValue];
    }
    // CGWindowListCreateImageFromArray expect a CFArray of *CGWindowID*, not CGWindowID wrapped in a CF/NSNumber
    // Hence we typecast our array above (to avoid the compiler warning) and use NULL CFArray callbacks
    // (because CGWindowID isn't a CF type) to avoid retain/release.
    CFArrayRef windowIDsArray = CFArrayCreate(kCFAllocatorDefault, (const void**)windowIDs, [sortedSelection count], NULL);
    free(windowIDs);
    
    // And send our new array on it's merry way
    return windowIDsArray;
}

-(void)createSingleWindowShot:(CGWindowID)windowID
{
    // Create an image from the passed in windowID with the single window option selected by the user.
    StopwatchStart();
    CGImageRef windowImage = CGWindowListCreateImage(imageBounds, singleWindowListOptions, windowID, imageOptions);
    Profile(windowImage);
    StopwatchEnd("Single Window");
    //	[self setOutputImage:windowImage];
    CGImageRelease(windowImage);
}

-(void)createMultiWindowShot:(NSArray*)selection
{
    // Get the correctly sorted list of window IDs. This is a CFArrayRef because we need to put integers in the array
    // instead of CFTypes or NSObjects.
    CFArrayRef windowIDs = [self newWindowListFromSelection:selection];
    
    // And finally create the window image and set it as our output image.
    StopwatchStart();
    CGImageRef windowImage = CGWindowListCreateImageFromArray(imageBounds, windowIDs, imageOptions);
    Profile(windowImage);
    StopwatchEnd("Multiple Window");
    CFRelease(windowIDs);
    //	[self setOutputImage:windowImage];
    CGImageRelease(windowImage);
}

-(CGImageRef)createScreenShotImage
{
    // This just invokes the API as you would if you wanted to grab a screen shot. The equivalent using the UI would be to
    // enable all windows, turn off "Fit Image Tightly", and then select all windows in the list.
    StopwatchStart();
    CGImageRef screenShot = CGWindowListCreateImage(CGRectInfinite, kCGWindowListOptionOnScreenOnly, kCGNullWindowID, kCGWindowImageDefault);
    Profile(screenShot);
    StopwatchEnd("Screenshot");
    //	[self setOutputImage:screenShot];
    
    return screenShot;
}

#pragma mark GUI Support

-(void)updateImageWithSelection
{
    // Depending on how much is selected either clear the output image
    // set the image based on a single selected window or
    // set the image based on multiple selected windows.
    //	NSArray *selection = [arrayController selectedObjects];
    //	if([selection count] == 0)
    //	{
    //		[self setOutputImage:NULL];
    //	}
    //	else if([selection count] == 1)
    //	{
    //		// Single window selected, so use the single window options.
    //		// Need to grab the CGWindowID to pass to the method.
    //		CGWindowID windowID = [[[selection objectAtIndex:0] objectForKey:kWindowIDKey] unsignedIntValue];
    //		[self createSingleWindowShot:windowID];
    //	}
    //	else
    //	{
    //		// Multiple windows selected, so composite just those windows
    //		[self createMultiWindowShot:selection];
    //	}
}

enum
{
    // Constants that correspond to the rows in the
    // Single Window Option matrix.
    kSingleWindowAboveOnly = 0,
    kSingleWindowAboveIncluded = 1,
    kSingleWindowOnly = 2,
    kSingleWindowBelowIncluded = 3,
    kSingleWindowBelowOnly = 4,
};

// Simple helper that converts the selected row number of the singleWindow NSMatrix
// to the appropriate CGWindowListOption.
-(CGWindowListOption)singleWindowOption
{
    CGWindowListOption option = kCGWindowListOptionIncludingWindow;
    //	switch([singleWindow selectedRow])
    //	{
    //		case kSingleWindowAboveOnly:
    //			option = kCGWindowListOptionOnScreenAboveWindow;
    //			break;
    //
    //		case kSingleWindowAboveIncluded:
    //			option = kCGWindowListOptionOnScreenAboveWindow | kCGWindowListOptionIncludingWindow;
    //			break;
    //
    //		case kSingleWindowOnly:
    //			option = kCGWindowListOptionIncludingWindow;
    //			break;
    //
    //		case kSingleWindowBelowIncluded:
    //			option = kCGWindowListOptionOnScreenBelowWindow | kCGWindowListOptionIncludingWindow;
    //			break;
    //
    //		case kSingleWindowBelowOnly:
    //			option = kCGWindowListOptionOnScreenBelowWindow;
    //			break;
    //
    //		default:
    //			break;
    //	}
    return option;
}

NSString *kvoContext = @"SonOfGrabContext";
-(id)init
{
    if (self == [super init]) {
        
        // Set the initial list options to match the UI.
        listOptions = kCGWindowListOptionAll;
        listOptions = ChangeBits(listOptions, kCGWindowListOptionOnScreenOnly, NO);
        listOptions = ChangeBits(listOptions, kCGWindowListExcludeDesktopElements, YES);
        
        // Set the initial image options to match the UI.
        imageOptions = kCGWindowImageDefault;
        imageOptions = ChangeBits(imageOptions, kCGWindowImageBoundsIgnoreFraming, YES);
        imageOptions = ChangeBits(imageOptions, kCGWindowImageShouldBeOpaque, NO);
        imageOptions = ChangeBits(imageOptions, kCGWindowImageOnlyShadows, NO);
        
        // Set initial single window options to match the UI.
        singleWindowListOptions = [self singleWindowOption];
        
        // CGWindowListCreateImage & CGWindowListCreateImageFromArray will determine their image size dependent on the passed in bounds.
        // This sample only demonstrates passing either CGRectInfinite to get an image the size of the desktop
        // or passing CGRectNull to get an image that tightly fits the windows specified, but you can pass any rect you like.
        imageBounds = YES ? CGRectNull : CGRectInfinite;
        
    }
    return self;
}

- (void) dealloc{
    [super dealloc];
}

#pragma mark Control Actions

-(IBAction)refreshWindowList:(id)sender
{
#pragma unused(sender)
    // Refreshing the window list combines updating the window list and updating the window image.
    //    [self getWindowList:listOptions];
    //	[self updateImageWithSelection];
}

@end
