//
//  MJCaptureCustonButton.m
//  test_3
//
//  Created by mengjianjun on 3/25/15.
//  Copyright (c) 2015 mengjianjun. All rights reserved.
//

#import "MJCaptureCustonButton.h"

@implementation MJCImageButton

@synthesize account_info_target_, space_, mouse_stype_;
@synthesize bgNormalColor;
@synthesize bgHoverColor;
@synthesize bgPressColor;
@synthesize TitleNormalColor;
@synthesize TitleHoverColor;
@synthesize TitlePressColor;
@synthesize isPopUpButton;
@synthesize isFirstMenuButton;

- (NSAttributedString*)attributedStringWithString:(NSString*)string
                                         fontSize:(CGFloat)fontSize {
    NSMutableParagraphStyle *paragraphStyle = [[[NSMutableParagraphStyle alloc] init] autorelease];
    [paragraphStyle setAlignment:NSLeftTextAlignment];
    NSDictionary* attributes = @{
                                 NSFontAttributeName:
                                     [NSFont systemFontOfSize:fontSize],
                                 NSForegroundColorAttributeName:
                                     [NSColor blackColor],//[NSColor colorWithCalibratedWhite:0.58 alpha:1.0],
                                 NSParagraphStyleAttributeName:
                                     paragraphStyle
                                 };
    
    return [[[NSAttributedString alloc]
             initWithString:string
             attributes:attributes] autorelease];
}

- (void)createTrackingArea
{
    NSTrackingAreaOptions focusTrackingAreaOptions = NSTrackingActiveInActiveApp;
    focusTrackingAreaOptions |= NSTrackingMouseEnteredAndExited;
    focusTrackingAreaOptions |= NSTrackingAssumeInside;
    focusTrackingAreaOptions |= NSTrackingInVisibleRect;
    
    NSTrackingArea *focusTrackingArea = [[NSTrackingArea alloc] initWithRect:NSZeroRect
                                                                     options:focusTrackingAreaOptions owner:self userInfo:nil];
    [self addTrackingArea:focusTrackingArea];
}

- (void)defaultColor{
    bgNormalColor = [[NSColor colorWithCalibratedRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1] retain];
    bgHoverColor = [[NSColor colorWithCalibratedRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1] retain];
    bgPressColor = [[NSColor colorWithCalibratedRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1] retain];
    TitleNormalColor = [[NSColor blackColor] retain];
    TitleHoverColor = [[NSColor whiteColor] retain];
    TitlePressColor = [[NSColor whiteColor] retain];
}
- (id)init{
    if (self == [super init]) {
        account_info_target_ = nil;
        mouse_stype_ = MJCImageButtonNormal;
        space_ = 2;
        [self createTrackingArea];
        isPopUpButton = NO;
        isFirstMenuButton = NO;
        [self defaultColor];
    }
    return self;
}
- (id)initWithFrame:(NSRect)frameRect{
    if (self == [super initWithFrame:frameRect]) {
        mouse_stype_ = MJCImageButtonNormal;
        space_ = 2;
        [self createTrackingArea];
        isPopUpButton = NO;
        isFirstMenuButton = NO;
        [self defaultColor];
        [self setWantsLayer:YES];
    }
    return self;
}
- (void) awakeFromNib{
    
}

- (void)drawRect:(NSRect)dirtyRect {
    //[super drawRect:dirtyRect];
    
    // Drawing code here.
    NSColor *titleColor = nil;
    NSImage *image = [self image];
    if ([[self title] length] == 0) {
        //        [[NSColor colorWithCalibratedRed:82/255.0 green:85/255.0 blue:82/255.0 alpha:1] setFill];
        //        [[NSBezierPath bezierPathWithRect:dirtyRect] fill];
        switch (mouse_stype_) {
            case MJCImageButtonNormal:{
                titleColor = [TitleNormalColor retain];
                [[NSColor colorWithCalibratedRed:82/255.0 green:85/255.0 blue:82/255.0 alpha:0] setFill];
                [[NSBezierPath bezierPathWithRect:dirtyRect] fill];
                break;
            }
            case MJCImageButtonHover:
            case MJCImageButtonPress:{
                titleColor = [TitleHoverColor retain];
                [[NSColor colorWithCalibratedRed:1 green:1 blue:1 alpha:0.1] setFill];
                [[NSBezierPath bezierPathWithRoundedRect:[self bounds] xRadius:3 yRadius:3] fill];
                break;
            }
        }
        if (image) {
            [image setFlipped:YES];
            [image drawInRect:NSMakeRect((self.bounds.size.width-image.size.width)/2, (self.bounds.size.height-image.size.height)/2, image.size.width, image.size.height) fromRect:NSMakeRect(0,0,image.size.width,image.size.height) operation:NSCompositeSourceOver fraction:1];
        }
        return;
    }else{
        switch (mouse_stype_) {
            case MJCImageButtonNormal:{
                titleColor = [TitleNormalColor retain];
                [bgNormalColor setFill];
                [[NSBezierPath bezierPathWithRect:dirtyRect] fill];
                break;
            }
            case MJCImageButtonHover:{
                titleColor = [TitleHoverColor retain];
                [bgHoverColor setFill];
                [[NSBezierPath bezierPathWithRect:dirtyRect] fill];
                break;
            }
            case MJCImageButtonPress:{
                titleColor = [TitlePressColor retain];
                [bgPressColor setFill];
                [[NSBezierPath bezierPathWithRect:dirtyRect] fill];
                break;
            }
        }
        if (image) {
            [image drawInRect:NSMakeRect(36, (self.bounds.size.height-image.size.height)/2, image.size.width, image.size.height) fromRect:NSMakeRect(0,0,image.size.width,image.size.height) operation:NSCompositeSourceOver fraction:1];
        }
    }
    
}
- (void)mouseDown:(NSEvent *)theEvent{
    [super mouseDown:theEvent];
    
    if (![self isEnabled]) {
        return;
    }
    mouse_stype_ = MJCImageButtonHover;
    if(isFirstMenuButton) mouse_stype_ = MJCImageButtonNormal;
    [self setNeedsDisplay];
}
- (void)mouseEntered:(NSEvent *)theEvent{
    if (mouse_stype_ == MJCImageButtonHover) {
        return;
    }
    if (![self isEnabled]) {
        return;
    }
    mouse_stype_ = MJCImageButtonPress;
    [self setNeedsDisplay];
}
- (void)mouseExited:(NSEvent *)theEvent{
    if (![self isEnabled]) {
        return;
    }
    if (!isPopUpButton) {
        if (mouse_stype_ != MJCImageButtonHover) {
            mouse_stype_ = MJCImageButtonNormal;
        }
    }else{
        mouse_stype_ = MJCImageButtonNormal;
    }
    if(isFirstMenuButton) mouse_stype_ = MJCImageButtonNormal;
    
    [self setNeedsDisplay];
}
- (void)mouseUp:(NSEvent *)theEvent{
    [super mouseUp:theEvent];
    if (![self isEnabled]) {
        return;
    }
    
    NSPoint pt = [theEvent locationInWindow];
    pt = [self convertPoint:pt fromView:nil];
    if (NSPointInRect(pt, [self bounds])) {
        mouse_stype_ = MJCImageButtonHover;
        if(isFirstMenuButton) mouse_stype_ = MJCImageButtonNormal;
    }
    [self setNeedsDisplay];
}

@end


@implementation MJCaptureColorButton
@synthesize bgNormalColor;

- (void)defaultColor{
    bgNormalColor = [[NSColor colorWithCalibratedRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1] retain];
}
- (id)init{
    if (self == [super init]) {
        
    }
    return self;
}
- (id)initWithFrame:(NSRect)frameRect{
    if (self == [super initWithFrame:frameRect]) {
        [self defaultColor];
        [self setWantsLayer:YES];
    }
    return self;
}
- (void) awakeFromNib{
    
}

- (void)drawRect:(NSRect)dirtyRect {
    //[super drawRect:dirtyRect];
    
    // Drawing code here.
    [bgNormalColor setFill];
    [[NSBezierPath bezierPathWithRoundedRect:[self bounds] xRadius:0 yRadius:0] fill];
    
    
    
    NSImage *image = [self image];
    if (image) {
        [image drawInRect:NSMakeRect((self.bounds.size.width-image.size.width)/2, dirtyRect.size.height-8-image.size.height, image.size.width, image.size.height) fromRect:NSMakeRect(0,0,image.size.width,image.size.height) operation:NSCompositeSourceOver fraction:1];
    }
}
- (void)mouseDown:(NSEvent *)theEvent{
    [super mouseDown:theEvent];
}
- (void)mouseUp:(NSEvent *)theEvent{
    [super mouseUp:theEvent];
}
@end




