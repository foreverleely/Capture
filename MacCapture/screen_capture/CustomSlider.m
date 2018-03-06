//
//  CustomSlider.m
//  WindowTest
//
//  Created by 115 on 16/9/27.
//  Copyright © 2016年 115. All rights reserved.
//

#import "CustomSlider.h"
#import <availabilitymacros.h>

@implementation CustomSlider

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (instancetype)initWithFrame:(NSRect)frameRect
                   trackImage:(NSImage*) track_img
                   rangeImage:(NSImage*) range_img
                   thumbImage:(NSImage*) thumb_img
{
    self = [super initWithFrame:frameRect];
    if(self){
        
        int widthTrackImg = track_img.size.width;
        int heightTrackImg = track_img.size.height;
        _trackImageView_ = [[NSImageView alloc] initWithFrame:NSMakeRect(0, (frameRect.size.height - heightTrackImg)/2, widthTrackImg, heightTrackImg)];
        _trackImageView_.image = track_img;
        [self addSubview:_trackImageView_];
        
        _headImageView_ = [[NSImageView alloc] initWithFrame:NSMakeRect(0, (frameRect.size.height - 8)/2, 4, 8)];
        _headImageView_.image = [NSImage imageNamed:@"mj_capture_head"];
        [self addSubview:_headImageView_];
        
        
        int widthRange = 0;
        int heightRange = range_img.size.height;
        _rangeImageView_ = [[NSImageView alloc] initWithFrame:NSMakeRect(2, (frameRect.size.height - heightRange)/2, widthRange, heightRange)];
        _rangeImageView_.image = range_img;
        _rangeImageView_.imageScaling = NSImageScaleAxesIndependently;
        _rangeImageView_.imageAlignment = NSImageAlignTop;
        [self addSubview:_rangeImageView_];
        
        int widthThumb = thumb_img.size.width;
        int heightThumb = thumb_img.size.height;
        _thumbImageView_ = [[NSImageView alloc] initWithFrame:NSMakeRect(0,0,widthThumb, heightThumb)];
        _thumbImageView_.image = thumb_img;
        [self addSubview:_thumbImageView_];
        
        panGestureRecognizer_ = [[NSPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        //panGestureRecognizer_.delegate = self;
        [_thumbImageView_ addGestureRecognizer:panGestureRecognizer_];
    }
    return self;
}

- (void) setMinimumValue:(int)min setMaximumValue:(int)max
{
    minimum_value_ = min;
    maximum_value_ = max;
}

- (CGSize) intrinsicContentSize{
    CGFloat width = [_trackImageView_ frame].size.width;
    CGFloat height = [_thumbImageView_ frame].size.width;
    return CGSizeMake(width, height);
}

- (void)layoutSubviews
{
    CGFloat width = CGRectGetWidth(self.frame);
    CGFloat thumbWidth = [_thumbImageView_ frame].size.width;
    
    CGFloat rangeX = width / (maximum_value_ - minimum_value_) * sliderValue_;
    
    //NSLog(@"CustomSlider rangeX=%f, slider value=%f", rangeX, sliderValue_);
    
    int availRange = width - thumbWidth;
    if(rangeX<0 || rangeX>availRange)
        return;
    if(rangeX < 0){
        rangeX = 0;
    }else if(rangeX>availRange){
        rangeX = availRange;
    }else if(sliderValue_ > 95){
        rangeX = availRange;
    }
    //NSLog(@"CustomSlider rangeX=%f, slider value=%f", rangeX, sliderValue_);
    
    CGRect rectRange = [_rangeImageView_ frame];
    rectRange.size.width = rangeX;
    _rangeImageView_.frame = rectRange;
    
    rectRange_ = rectRange;
    
    CGRect rectThumb = [_thumbImageView_ frame];
    rectThumb.origin.x = rangeX;
    
    _thumbImageView_.frame = rectThumb;
}

- (void)handlePan:(NSPanGestureRecognizer *)gesture
{
    CGPoint translation = [gesture translationInView:self];
    CGRect ttt = [self frame];
    
    CGRect ssss = [self superview].frame;
    
    if(gesture.state == NSGestureRecognizerStateBegan)
    {
        //NSLog(@"gesture NSGestureRecognizerStateBegan...");
        
        CGPoint tempPoint = NSMakePoint(0, 0);
        tempPoint.x = rectRange_.size.width + translation.x;
        [gesture setTranslation:tempPoint inView:self];
        
    }else if(gesture.state == NSGestureRecognizerStateChanged)
    {
        //NSLog(@"gesture NSGestureRecognizerStateChanged...");
        
        CGFloat width = [self frame].size.width;
        unsigned major, minor, bugFix;
        [self getSystemVersionMajor:&major minor:&minor bugFix:&bugFix];
        NSLog(@"%u.%u.%u", major, minor, bugFix);
        if(major == 10){
            if(minor >= 12){ //如果系统是10.12以上
                sliderValue_ = translation.x / width * (maximum_value_ - minimum_value_);
            }else{
                sliderValue_ = (translation.x - ttt.origin.x - ssss.origin.x) / width * (maximum_value_ - minimum_value_);
            }
        }

        //更新进度
        [self layoutSubviews];
        
        //回调
        if(sliderValue_ >= 100)
            sliderValue_ = 100;
        if(sliderValue_ <= 0)
            sliderValue_ = 0;
        if(_delegate_){
            [_delegate_ valueChanged:sliderValue_];
        }
        
    }
    else if(gesture.state == NSGestureRecognizerStateEnded){
        NSLog(@"gesture NSGestureRecognizerStateEnded...");
    }else if(gesture.state == NSGestureRecognizerStateCancelled){
        NSLog(@"gesture NSGestureRecognizerStateCancelled...");
    }else if(gesture.state == NSGestureRecognizerStateFailed){
        NSLog(@"gesture NSGestureRecognizerStateFailed...");
    }else if(gesture.state == NSGestureRecognizerStateRecognized){
        NSLog(@"gesture NSGestureRecognizerStateRecognized...");
    }
}

- (void) mouseDown:(NSEvent *)theEvent
{
    NSPoint pt = theEvent.locationInWindow;
    NSPoint convertPoint = [self convertPoint:pt fromView:nil];
    NSLog(@"CustomSlider mouseDown x=%f, y=%f", convertPoint.x, convertPoint.y);
    NSRect rect = NSMakeRect(0, ([self frame].size.height - _trackImageView_.image.size.height)/2, _trackImageView_.image.size.width, _trackImageView_.image.size.height);
    if(NSPointInRect(convertPoint, rect)){
        //NSLog(@"CustomSlider point in rect...");
        CGFloat width = [self frame].size.width;
        NSRect tempRect = [_thumbImageView_ frame];
        tempRect.origin.x = convertPoint.x - tempRect.size.width/2;
        if(tempRect.origin.x <= tempRect.size.width/2)
            tempRect.origin.x = 0;
        if(tempRect.origin.x >= (width - tempRect.size.width))
            tempRect.origin.x = (width - tempRect.size.width);
        
        [_thumbImageView_ setFrame:tempRect];
        
        NSRect rectRange = [_rangeImageView_ frame];
        rectRange.size.width = tempRect.origin.x;
        _rangeImageView_.frame = rectRange;
        rectRange_ = rectRange;
        
        sliderValue_ = rectRange_.size.width / width * (maximum_value_ - minimum_value_);
        NSLog(@"slider value= %f", sliderValue_);
        //回调
        if(sliderValue_ >= 100)
            sliderValue_ = 100;
        if(sliderValue_ <= 0)
            sliderValue_ = 0;
        if(_delegate_){
            [_delegate_ valueChanged:sliderValue_];
        }
    }
}

- (void) updateSlider:(int)value{

    CGFloat width = [self frame].size.width;
    int rectRangeWidth = value * width / (maximum_value_ - minimum_value_);
    sliderValue_ = rectRangeWidth;
    
    NSRect rectRange = [_rangeImageView_ frame];
    rectRange.size.width = rectRangeWidth;
    _rangeImageView_.frame = rectRange;
    rectRange_ = rectRange;
    
    NSRect tempRect = [_thumbImageView_ frame];
    tempRect.origin.x = rectRangeWidth /*- tempRect.size.width/2*/;
    if(tempRect.origin.x <= tempRect.size.width/2)
        tempRect.origin.x = 0;
    if(tempRect.origin.x >= (width - tempRect.size.width))
        tempRect.origin.x = (width - tempRect.size.width);
    [_thumbImageView_ setFrame:tempRect];
}

- (BOOL)gestureRecognizer:(NSGestureRecognizer *)gestureRecognizer shouldAttemptToRecognizeWithEvent:(NSEvent *)event{
    return YES;
}

- (void) mouseDragged:(NSEvent *)theEvent{
    NSLog(@"CustomSlider mouseDragged....");
}

- (void)getSystemVersionMajor:(unsigned *)major
                        minor:(unsigned *)minor
                       bugFix:(unsigned *)bugFix{
    OSErr err;
    SInt32 systemVersion, versionMajor, versionMinor, versionBugFix;
    if ((err = Gestalt(gestaltSystemVersion, &systemVersion)) != noErr) goto fail;
    if (systemVersion < 0x1040)
    {
        if (major) *major = ((systemVersion & 0xF000) >> 12) * 10 +
            ((systemVersion & 0x0F00) >> 8);
        if (minor) *minor = (systemVersion & 0x00F0) >> 4;
        if (bugFix) *bugFix = (systemVersion & 0x000F);
    }
    else
    {
        if ((err = Gestalt(gestaltSystemVersionMajor, &versionMajor)) != noErr) goto fail;
        if ((err = Gestalt(gestaltSystemVersionMinor, &versionMinor)) != noErr) goto fail;
        if ((err = Gestalt(gestaltSystemVersionBugFix, &versionBugFix)) != noErr) goto fail;
        if (major) *major = versionMajor;
        if (minor) *minor = versionMinor;
        if (bugFix) *bugFix = versionBugFix;
    }
    
    return;
    
fail:
    NSLog(@"Unable to obtain system version: %ld", (long)err);
    if (major) *major = 10;
    if (minor) *minor = 0;
    if (bugFix) *bugFix = 0;
}

@end
