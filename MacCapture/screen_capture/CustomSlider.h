//
//  CustomSlider.h
//  WindowTest
//
//  Created by 115 on 16/9/27.
//  Copyright © 2016年 115. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@protocol ICustomSliderDelegate <NSObject>

- (void) valueChanged:(CGFloat)newValue;

@end


@interface CustomSlider : NSControl{
    CGFloat sliderValue_;
    CGRect rectRange_;
    int minimum_value_;
    int maximum_value_;
    NSPanGestureRecognizer* panGestureRecognizer_;
}

- (instancetype)initWithFrame:(NSRect)frameRect
                   trackImage:(NSImage*) track_img
                   rangeImage:(NSImage*) range_img
                   thumbImage:(NSImage*) thumb_img;

@property (nonatomic) NSImageView* trackImageView_;
@property (nonatomic) NSImageView* rangeImageView_;
@property (nonatomic) NSImageView* thumbImageView_;
@property (nonatomic) NSImageView* headImageView_;

@property (retain) id<ICustomSliderDelegate> delegate_;

- (void) setMinimumValue:(int)min setMaximumValue:(int)max;

- (void) mouseDown:(NSEvent *)theEvent;

- (void) updateSlider:(int)value;

- (BOOL)gestureRecognizer:(NSGestureRecognizer *)gestureRecognizer shouldAttemptToRecognizeWithEvent:(NSEvent *)event;

- (void) mouseDown:(NSEvent *)theEvent;
- (void) mouseDragged:(NSEvent *)theEvent;

- (void)getSystemVersionMajor:(unsigned *)major
                        minor:(unsigned *)minor
                       bugFix:(unsigned *)bugFix;

@end
