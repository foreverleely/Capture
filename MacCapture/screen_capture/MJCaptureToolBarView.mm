//
//  MJCaptureToolBarView.m
//  MacCapture
//
//  Created by 115Browser on 8/16/15.
//  Copyright (c) 2015 jacky.115.com. All rights reserved.
//

#import "MJCaptureToolBarView.h"
#import "MJPersistentUtil.h"
#import "SnipManager.h"
#import "SnipView.h"

@implementation MJCaptureToolBarView

- (void)InitButtonsColor{
    NSMutableArray *colorArray = [NSMutableArray array];
  
    [colorArray addObject:[NSColor colorWithCalibratedRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:1]];
    [colorArray addObject:[NSColor colorWithCalibratedRed:127/255.0 green:127/255.0 blue:127/255.0 alpha:1]];
    [colorArray addObject:[NSColor colorWithCalibratedRed:153/255.0 green:0/255.0 blue:0/255.0 alpha:1]];
    [colorArray addObject:[NSColor colorWithCalibratedRed:107/255.0 green:132/255.0 blue:20/255.0 alpha:1]];
    [colorArray addObject:[NSColor colorWithCalibratedRed:0/255.0 green:113/255.0 blue:3/255.0 alpha:1]];
    [colorArray addObject:[NSColor colorWithCalibratedRed:16/255.0 green:41/255.0 blue:191/255.0 alpha:1]];
    [colorArray addObject:[NSColor colorWithCalibratedRed:166/255.0 green:9/255.0 blue:109/255.0 alpha:1]];
    [colorArray addObject:[NSColor colorWithCalibratedRed:6/255.0 green:138/255.0 blue:112/255.0 alpha:1]];
    
    [colorArray addObject:[NSColor colorWithCalibratedRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1]];
    [colorArray addObject:[NSColor colorWithCalibratedRed:210/255.0 green:210/255.0 blue:210/255.0 alpha:1]];
    [colorArray addObject:[NSColor colorWithCalibratedRed:255/255.0 green:0/255.0 blue:0/255.0 alpha:1]];
    [colorArray addObject:[NSColor colorWithCalibratedRed:238/255.0 green:244/255.0 blue:60/255.0 alpha:1]];
    [colorArray addObject:[NSColor colorWithCalibratedRed:101/255.0 green:192/255.0 blue:4/255.0 alpha:1]];
    [colorArray addObject:[NSColor colorWithCalibratedRed:26/255.0 green:114/255.0 blue:234/255.0 alpha:1]];
    [colorArray addObject:[NSColor colorWithCalibratedRed:217/255.0 green:67/255.0 blue:223/255.0 alpha:1]];
    [colorArray addObject:[NSColor colorWithCalibratedRed:2/255.0 green:233/255.0 blue:225/255.0 alpha:1]];
    
    btnColorArray_ = [[NSMutableArray alloc] init];
    for (int i = 0; i < (int)[colorArray count]; i++) {
        [btnColorArray_ addObject:[[self addColorButton:[colorArray objectAtIndex:i] titleID:@"" action:@selector(btnColorAction:) rect:NSZeroRect] autorelease]];
    }
}
- (MJCImageButton*)addButtonWithImageID:(NSString*)imageName titleID:(NSString *)title
                               fontSize:(CGFloat)fontSize
                                 action:(SEL)action
                                   rect:(NSRect)rect{
  
    MJCImageButton* button = [[[MJCImageButton alloc] initWithFrame:rect] autorelease];
    [[button cell] setBordered:NO];
    [button setTarget:self];
    [button setAction:action];
    [button setToolTip:title];
    [button setImage:[NSImage imageNamed:imageName]];
    [button setTitle:@""];
    [self addSubview:button];
    return button;
}

- (MJCaptureColorButton*)addColorButton:(NSColor*)color titleID:(NSString *)title
                                 action:(SEL)action
                                   rect:(NSRect)rect{
    MJCaptureColorButton* button = [[MJCaptureColorButton alloc] initWithFrame:rect];
    [[button cell] setBordered:NO];
    [button setTarget:self];
    [button setAction:action];
    [button setToolTip:title];
    [button setTitle:@""];
    button.bgNormalColor = color;
    [self addSubview:button];
    [button setHidden:YES];
    return button;
}

-(void)observeValueForKeyPath:(NSString *)keyPath
                     ofObject:(id)object
                       change:(NSDictionary *)change
                      context:(void *)context
{
    if ([keyPath isEqual:@"knobThickness"]) {
        
    }
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        isShowSubFunction_ = NO;
        isMouseDown_ = NO;
        firstMouseDonwPoint_ = frame.origin;
        oldRect_ = frame;
        seletedBtnRectX = -100;
        
        [self setWantsLayer:YES];
        nSpace_ = 6;
        btnWidth_ = 32;
        btnHeight_ = 32;
        float leftOffset = (frame.size.width - 10*(nSpace_+btnWidth_)) / 2;
        
        NSRect btnRect = NSMakeRect(leftOffset - 4 * nSpace_, nSpace_, btnWidth_, btnHeight_);
        ///add by aries{
        
        ///}
        btnRectangle_ = [[[self addButtonWithImageID:@"mj_capture_rectange" titleID:@"矩形" fontSize:12 action:@selector(btnAction:) rect:btnRect] retain] autorelease];
        btnRectangle_.isFirstMenuButton = YES;
        btnRect.origin.x += btnWidth_ + 2 * nSpace_;
        btnCircle_ = [[[self addButtonWithImageID:@"mj_capture_circle" titleID:@"椭圆" fontSize:12 action:@selector(btnAction:) rect:btnRect] retain] autorelease];
        btnCircle_.isFirstMenuButton = YES;
        btnRect.origin.x += btnWidth_ + 2 * nSpace_;
        btnTriangleArrow_ = [[[self addButtonWithImageID:@"mj_capture_triangle" titleID:@"箭头" fontSize:12 action:@selector(btnAction:) rect:btnRect] retain] autorelease];
        btnTriangleArrow_.isFirstMenuButton = YES;
        btnRect.origin.x += btnWidth_ + 2 * nSpace_;
        btnBrush_ = [[[self addButtonWithImageID:@"mj_capture_brush" titleID:@"线条" fontSize:12 action:@selector(btnAction:) rect:btnRect] retain] autorelease];
        btnRect.origin.x += btnWidth_ + 2 * nSpace_;
        btnBrush_.isFirstMenuButton = YES;
        //add by aries{
        btnMosaic_ = [[[self addButtonWithImageID:@"mj_capture_mosaic" titleID:@"马赛克" fontSize:12 action:@selector(btnAction:) rect:btnRect] retain] autorelease];
        btnMosaic_.isFirstMenuButton = YES;
        btnRect.origin.x += btnWidth_ + 2 * nSpace_;
        //}
        btnText_ = [[[self addButtonWithImageID:@"mj_capture_text" titleID:@"文字" fontSize:12 action:@selector(btnAction:) rect:btnRect] retain] autorelease];
        btnRect.origin.x += btnWidth_ + 2 * nSpace_ + 1;
        btnText_.isFirstMenuButton = YES;
        btnUndo_ = [[[self addButtonWithImageID:@"mj_capture_undo" titleID:@"撤销" fontSize:12 action:@selector(btnAction:) rect:btnRect] retain] autorelease];
        btnUndo_.isFirstMenuButton = YES;
        btnRect.origin.x += btnWidth_ + 2 * nSpace_;
        btnSave_ = [[[self addButtonWithImageID:@"mj_capture_save" titleID:@"保存" fontSize:12 action:@selector(btnAction:) rect:btnRect] retain] autorelease];
        btnRect.origin.x += btnWidth_ + 2 * nSpace_ + 1;
        btnCancel_ = [[[self addButtonWithImageID:@"mj_capture_cancel" titleID:@"取消" fontSize:12 action:@selector(btnAction:) rect:btnRect] retain] autorelease];
        btnRect.origin.x += btnWidth_ + 2 * nSpace_;
        btnOK_ = [[[self addButtonWithImageID:@"mj_capture_ok" titleID:@"确定" fontSize:12 action:@selector(btnAction:) rect:btnRect] retain] autorelease];
        
        
        btnRect = NSMakeRect(btnRectangle_.frame.origin.x, nSpace_, btnWidth_, btnHeight_);
        btnLineWidthSmall_ = [[[self addButtonWithImageID:@"mj_capture_small_circle" titleID:@"小" fontSize:12 action:@selector(btnAction:) rect:btnRect] retain] autorelease];
        [btnLineWidthSmall_ setHidden:YES];
        btnRect.origin.x += btnWidth_;
        btnLineWidthMid_ = [[[self addButtonWithImageID:@"mj_capture_mid_circle" titleID:@"中" fontSize:12 action:@selector(btnAction:) rect:btnRect] retain] autorelease];
        [btnLineWidthMid_ setHidden:YES];
        btnRect.origin.x += btnWidth_;
        btnLineWidthBig_ = [[[self addButtonWithImageID:@"mj_capture_big_circle" titleID:@"大" fontSize:12 action:@selector(btnAction:) rect:btnRect] retain] autorelease];
        [btnLineWidthBig_ setHidden:YES];
        btnLineWidthSmall_.mouse_stype_ = MJCImageButtonHover;
        [btnLineWidthSmall_ setNeedsDisplay];
        
        btnRect.origin.x += btnWidth_ + 50;
        btnSelectColor_ = [[[self addColorButton:[NSColor redColor] titleID:@"" action:@selector(btnColorAction:) rect:NSMakeRect(btnRect.origin.x, (frame.size.height - btnHeight_ ) / 2 - 1, btnRect.size.width, btnRect.size.height)] retain] autorelease];
        [btnSelectColor_ setHidden:YES];
        [self InitButtonsColor];
      
        NSRect fuzzyDrgreeRect = [btnSelectColor_ frame];
        fuzzyDrgreeRect.size.width += 10;
        fuzzyDegreeImageView_ = [[[self addButtonWithImageID:@"mj_capture_fuzzy_degree" titleID:@"模糊度" fontSize:12 action:@selector(btnAction:) rect:fuzzyDrgreeRect] retain] autorelease];
        [fuzzyDegreeImageView_ setEnabled:NO];
        [self addSubview:fuzzyDegreeImageView_];
        [fuzzyDegreeImageView_ setHidden:YES];
      
        NSRect mosaicSliderRect = [fuzzyDegreeImageView_ frame];
        mosaicSliderRect.origin.x = mosaicSliderRect.origin.x + mosaicSliderRect.size.width + 20;
        mosaicSliderRect.size.width = 210;
        mosaicSliderRect.size.height = 16;
        mosaicSliderRect.origin.y = (frame.size.height - 16 ) / 2 - 1;
        mosaicSlider_ = [[CustomSlider alloc] initWithFrame:mosaicSliderRect
                                                 trackImage:[NSImage imageNamed:@"mj_capture_slider_gray"]
                                                 rangeImage:[NSImage imageNamed:@"mj_capture_slider_blue"]
                                                 thumbImage:[NSImage imageNamed:@"mj_capture_thumb"]];
        [mosaicSlider_ setMinimumValue:0 setMaximumValue:100];
        mosaicSlider_.delegate_ = self;
        [self addSubview:mosaicSlider_];
        [mosaicSlider_ setHidden:YES];
        ///}
        
        textFontImageView_ = [[[self addButtonWithImageID:@"mj_capture_text" titleID:@"字体" fontSize:12 action:@selector(btnAction:) rect:[btnLineWidthSmall_ frame]] retain] autorelease];
        [textFontImageView_ setEnabled:NO];
        [self addSubview:textFontImageView_];
        textFontSize_ = [[[NSTextField alloc] initWithFrame:NSMakeRect(44, 9, 56, 22)] autorelease];
        [textFontSize_ setStringValue:@"16pt"];
        [textFontSize_ setEditable:NO];
        [textFontSize_ setBordered:NO];
        [textFontSize_ setBackgroundColor:[NSColor clearColor]];
        [textFontSize_ setFocusRingType:NSFocusRingTypeNone];
        [textFontSize_ setAlignment:NSCenterTextAlignment];
        [textFontSize_ setTextColor:[NSColor whiteColor]];
        [self addSubview:textFontSize_];
        [textFontSize_ setSelectable:NO];
        [textFontImageView_ setHidden:YES];
        [textFontSize_ setHidden:YES];
        
        [textFontSize_ setHidden:YES];
        
        ratiomenu = [[NSMenu alloc] init];
        [ratiomenu addItemWithTitle:@"9" action:@selector(popupAction:) keyEquivalent:@""];
        [ratiomenu addItemWithTitle:@"10" action:@selector(popupAction:) keyEquivalent:@""];
        [ratiomenu addItemWithTitle:@"11" action:@selector(popupAction:) keyEquivalent:@""];
        [ratiomenu addItemWithTitle:@"12" action:@selector(popupAction:) keyEquivalent:@""];
        [ratiomenu addItemWithTitle:@"13" action:@selector(popupAction:) keyEquivalent:@""];
        [ratiomenu addItemWithTitle:@"14" action:@selector(popupAction:) keyEquivalent:@""];
        [ratiomenu addItemWithTitle:@"18" action:@selector(popupAction:) keyEquivalent:@""];
        [ratiomenu addItemWithTitle:@"24" action:@selector(popupAction:) keyEquivalent:@""];
        [ratiomenu addItemWithTitle:@"36" action:@selector(popupAction:) keyEquivalent:@""];
        [ratiomenu addItemWithTitle:@"48" action:@selector(popupAction:) keyEquivalent:@""];
        [ratiomenu addItemWithTitle:@"64" action:@selector(popupAction:) keyEquivalent:@""];
        [ratiomenu addItemWithTitle:@"72" action:@selector(popupAction:) keyEquivalent:@""];
        [ratiomenu addItemWithTitle:@"96" action:@selector(popupAction:) keyEquivalent:@""];
        ibratiomenu = [[DropDownButton alloc] initWithFrame:NSMakeRect(55, 9, 65, 24)];
        [ibratiomenu setMenu:ratiomenu];
        [ibratiomenu setBordered:NO];
        [ibratiomenu setBezelStyle:NSRoundRectBezelStyle];
        [self addSubview:ibratiomenu];
        [ibratiomenu setUsesMenu:YES];
        [ibratiomenu setTitle:@"16pt"];
        [ibratiomenu setHidden:YES];
        self.layer.cornerRadius = 6;
        self.layer.masksToBounds = YES;
        NSTrackingAreaOptions options = (NSTrackingActiveAlways | NSTrackingInVisibleRect |
                                         NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved);
        [self addTrackingArea:[[NSTrackingArea alloc] initWithRect:self.bounds options:options owner:self userInfo:nil]];
    }
    return self;
}

- (void) valueChanged:(CGFloat)newValue
{
  
    MJCToolBarFunType type = [SnipManager sharedInstance].funType;
    
    int changeValue = 0;
    if(newValue < 2){
        changeValue = 6;
        [((SnipView*)[self superview]) changeMosaic:changeValue];
        [[MJPersistentUtil getInstance] setSliderValueForType:type sliderValue:0];
    }
    else if(newValue > 95){
        if(newValue == 100)
            return;
        //changeValue = 30;
        changeValue = 95;
        [((SnipView*)[self superview]) changeMosaic:changeValue];
        //[MJPersistentUtil setSliderValue:100];
        [[MJPersistentUtil getInstance] setSliderValueForType:type sliderValue:100];
    }else{
        changeValue = newValue;
        [((SnipView*)[self superview]) changeMosaic:changeValue];
        //[MJPersistentUtil setSliderValue:changeValue];
        [[MJPersistentUtil getInstance] setSliderValueForType:type sliderValue:changeValue];
    }
}

#pragma mark -
#pragma mark NSPopUpButton

// -------------------------------------------------------------------------------
//	popupAction:
//
//	User chose a menu item from one of the popups.
//	Note that all four popup buttons share the same action method.
// -------------------------------------------------------------------------------
- (IBAction)popupAction:(id)sender
{
    if ([sender isKindOfClass:[NSMenuItem class]]) {
        NSString *str = [(NSMenuItem*)sender title];
        int fontSize = [str intValue];
        
        [SnipManager sharedInstance].nFontSize = fontSize;
        [((SnipView*)[self superview]) upSelectSlideViewFontSize];
        NSLog(@"selectMenuIndex: %@,   %d", sender, fontSize);
        
        ///add by aries{
        //[MJPersistentUtil setTextSize:fontSize];
        [[MJPersistentUtil getInstance] setTextSizeForType:[SnipManager sharedInstance].funType textSize:fontSize];
        ///
    }
}
- (void)selectMenuIndex:(id)sender{
    //NSLog(@"selectMenuIndex: %@", sender);
}

- (void)dealloc{
    [btnColorArray_ release];
    btnColorArray_ = nil;
    [super dealloc];
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    // Drawing code here.
    NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:dirtyRect xRadius:4 yRadius:4];
    [[NSColor colorWithCalibratedRed:0.157 green:0.157 blue:0.157 alpha:1] set];
    [path fill];
    
    [[NSColor colorWithSRGBRed:40/255.0 green:40/255.0 blue:43/255.0 alpha:0.9] set];
    [path stroke];
    if (isShowSubFunction_) {
        [[NSColor colorWithSRGBRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.2] setFill];
        [[NSBezierPath bezierPathWithRect:NSMakeRect(btnSelectColor_.frame.origin.x-21, 4, 1, 32)] fill];
        [[NSColor colorWithSRGBRed:0 green:0 blue:0 alpha:0.2] set];
        [[NSBezierPath bezierPathWithRect:NSMakeRect(dirtyRect.origin.x, dirtyRect.origin.y, dirtyRect.size.width, dirtyRect.size.height/2)] fill];
        [[NSBezierPath bezierPathWithRect:NSMakeRect(seletedBtnRectX, dirtyRect.size.height/2, 40, dirtyRect.size.height/2)] fill];
    }
}

- (void)ResetFunType:(MJCToolBarFunType)type{
    [SnipManager sharedInstance].funType = type;
    
    if (!isShowSubFunction_) {
        NSRect oldRect = [self frame];
        oldRect.origin.y -= 40;
        oldRect.size.height += 40;
        [self setFrame:oldRect];
        
        int btnDy = 40+nSpace_;
        NSRect btnRect = NSMakeRect(nSpace_+7, btnDy, btnWidth_, btnHeight_);
        ///add by aries{
        ///}
        [btnRectangle_ setFrame:btnRect];
        btnRect.origin.x += btnWidth_ + 2 * nSpace_;
        [btnCircle_ setFrame:btnRect];
        btnRect.origin.x += btnWidth_ + 2 * nSpace_;
        [btnTriangleArrow_ setFrame:btnRect];
        btnRect.origin.x += btnWidth_ + 2 * nSpace_;
        [btnBrush_ setFrame:btnRect];
        //add by aries{
        btnRect.origin.x += btnWidth_ + 2 * nSpace_;
        [btnMosaic_ setFrame:btnRect];
        ///}
        btnRect.origin.x += btnWidth_ + 2 * nSpace_;
        [btnText_ setFrame:btnRect];
        btnRect.origin.x += btnWidth_ + 2 * nSpace_ + 1;
        [btnUndo_ setFrame:btnRect];
        btnRect.origin.x += btnWidth_ + 2 * nSpace_;
        [btnSave_ setFrame:btnRect];
        btnRect.origin.x += btnWidth_ + 2 * nSpace_ + 1;
        [btnCancel_ setFrame:btnRect];
        btnRect.origin.x += btnWidth_ + 2 * nSpace_;
        [btnOK_ setFrame:btnRect];
        
        [btnLineWidthSmall_ setHidden:NO];
        [btnLineWidthMid_ setHidden:NO];
        [btnLineWidthBig_ setHidden:NO];
        
        [btnSelectColor_ setHidden:NO];
        int btnColorLenght = 12;
        int nReWidth = [self frame].size.width - (btnSelectColor_.frame.origin.x+btnSelectColor_.frame.size.width);
        int btnWColorSpace = (nReWidth - btnColorLenght*8)/9.0;
        int btnHColorSpace = 5;//(40 - btnColorLenght)/3.0;
        int dx = btnSelectColor_.frame.origin.x+btnSelectColor_.frame.size.width;
        NSRect btnColorRect = NSMakeRect(dx+btnWColorSpace, btnHColorSpace*2+btnColorLenght, btnColorLenght, btnColorLenght);
        for (int i = 0; i < (int)[btnColorArray_ count]; i++) {
            if (i == 8) {
                btnColorRect = NSMakeRect(dx+btnWColorSpace, btnHColorSpace, btnColorLenght, btnColorLenght);
            }
            [[btnColorArray_ objectAtIndex:i] setFrame:btnColorRect];
            [[btnColorArray_ objectAtIndex:i] setHidden:NO];
            btnColorRect.origin.x += btnColorLenght+btnWColorSpace;
        }
        /*
        NSRect sreenRect = [[NSScreen mainScreen] frame];
        if (!NSContainsRect(sreenRect, self.frame)) {
            [((SnipView*)[self superview]) ReCalculateViewFrameChangeSize:NO event:[NSApp currentEvent]];
        }*/
        [self setNeedsDisplay:YES];
    }
    isShowSubFunction_ = YES;
    
    //if (![SnipManager sharedInstance].isEdit_) {
        [((SnipView*)[self superview]) BeginEdit];
    //}
}
- (void)btnAction1:(id)sender{
    if ([mosaicSlider_ isEqual:sender]) {
        NSLog(@"btnAction1: %f", mosaicSlider_.floatValue);
    }
}
- (void)btnAction:(id)sender{
    if ([btnRectangle_ isEqual:sender]) {
        seletedBtnRectX = btnRectangle_.frame.origin.x - 4;
        [self ResetFunType:MJCToolBarFunRectangle];
        
        btnRectangle_.mouse_stype_ = MJCImageButtonHover;
        [btnRectangle_ setNeedsDisplay];
        btnCircle_.mouse_stype_ = MJCImageButtonNormal;
        [btnCircle_ setNeedsDisplay];
        btnTriangleArrow_.mouse_stype_ = MJCImageButtonNormal;
        [btnTriangleArrow_ setNeedsDisplay];
        btnBrush_.mouse_stype_ = MJCImageButtonNormal;
        [btnBrush_ setNeedsDisplay];
        btnText_.mouse_stype_ = MJCImageButtonNormal;
        [btnText_ setNeedsDisplay];
        
        [btnLineWidthSmall_ setHidden:NO];
        [btnLineWidthMid_ setHidden:NO];
        [btnLineWidthBig_ setHidden:NO];
        [textFontImageView_ setHidden:YES];
        [textFontSize_ setHidden:YES];
        [ibratiomenu setHidden:YES];
        //add by aries
        [btnSelectColor_ setHidden:NO];
        for (int i = 0; i < (int)[btnColorArray_ count]; i++) {
            [[btnColorArray_ objectAtIndex:i] setHidden:NO];
        }
        [fuzzyDegreeImageView_ setHidden:YES];
        [mosaicSlider_ setHidden:YES];
        
        [self setLineWithBtnStateFromConfig];
        [self setBrushColorFromConfig];
        ///}
    }else if ([btnCircle_ isEqual:sender]) {
        seletedBtnRectX = btnCircle_.frame.origin.x - 4;
        [self ResetFunType:MJCToolBarFunCircle];
        
        btnRectangle_.mouse_stype_ = MJCImageButtonNormal;
        [btnRectangle_ setNeedsDisplay];
        btnCircle_.mouse_stype_ = MJCImageButtonHover;
        [btnCircle_ setNeedsDisplay];
        btnTriangleArrow_.mouse_stype_ = MJCImageButtonNormal;
        [btnTriangleArrow_ setNeedsDisplay];
        btnBrush_.mouse_stype_ = MJCImageButtonNormal;
        [btnBrush_ setNeedsDisplay];
        btnText_.mouse_stype_ = MJCImageButtonNormal;
        [btnText_ setNeedsDisplay];
        
        [btnLineWidthSmall_ setHidden:NO];
        [btnLineWidthMid_ setHidden:NO];
        [btnLineWidthBig_ setHidden:NO];
        [textFontImageView_ setHidden:YES];
        [textFontSize_ setHidden:YES];
        [ibratiomenu setHidden:YES];
        //add by aries
        [btnSelectColor_ setHidden:NO];
        for (int i = 0; i < (int)[btnColorArray_ count]; i++) {
            [[btnColorArray_ objectAtIndex:i] setHidden:NO];
        }
        [fuzzyDegreeImageView_ setHidden:YES];
        [mosaicSlider_ setHidden:YES];
        
        [self setLineWithBtnStateFromConfig];
        [self setBrushColorFromConfig];
        ///}
    }else if ([btnTriangleArrow_ isEqual:sender]) {
        seletedBtnRectX = btnTriangleArrow_.frame.origin.x - 4;
        [self ResetFunType:MJCToolBarFunTriangleArrow];
        
        btnRectangle_.mouse_stype_ = MJCImageButtonNormal;
        [btnRectangle_ setNeedsDisplay];
        btnCircle_.mouse_stype_ = MJCImageButtonNormal;
        [btnCircle_ setNeedsDisplay];
        btnTriangleArrow_.mouse_stype_ = MJCImageButtonHover;
        [btnTriangleArrow_ setNeedsDisplay];
        btnBrush_.mouse_stype_ = MJCImageButtonNormal;
        [btnBrush_ setNeedsDisplay];
        btnText_.mouse_stype_ = MJCImageButtonNormal;
        [btnText_ setNeedsDisplay];
        
        [btnLineWidthSmall_ setHidden:NO];
        [btnLineWidthMid_ setHidden:NO];
        [btnLineWidthBig_ setHidden:NO];
        [textFontImageView_ setHidden:YES];
        [textFontSize_ setHidden:YES];
        [ibratiomenu setHidden:YES];
        //add by aries
        [btnSelectColor_ setHidden:NO];
        for (int i = 0; i < (int)[btnColorArray_ count]; i++) {
            [[btnColorArray_ objectAtIndex:i] setHidden:NO];
        }
        [fuzzyDegreeImageView_ setHidden:YES];
        [mosaicSlider_ setHidden:YES];
        
        [self setLineWithBtnStateFromConfig];
        [self setBrushColorFromConfig];
        ///}
    }else if ([btnBrush_ isEqual:sender]) {
        seletedBtnRectX = btnBrush_.frame.origin.x - 4;
        [self ResetFunType:MJCToolBarFunBrush];
        
        btnRectangle_.mouse_stype_ = MJCImageButtonNormal;
        [btnRectangle_ setNeedsDisplay];
        btnCircle_.mouse_stype_ = MJCImageButtonNormal;
        [btnCircle_ setNeedsDisplay];
        btnTriangleArrow_.mouse_stype_ = MJCImageButtonNormal;
        [btnTriangleArrow_ setNeedsDisplay];
        btnBrush_.mouse_stype_ = MJCImageButtonHover;
        [btnBrush_ setNeedsDisplay];
        btnText_.mouse_stype_ = MJCImageButtonNormal;
        [btnText_ setNeedsDisplay];
        
        [btnLineWidthSmall_ setHidden:NO];
        [btnLineWidthMid_ setHidden:NO];
        [btnLineWidthBig_ setHidden:NO];
        [textFontImageView_ setHidden:YES];
        [textFontSize_ setHidden:YES];
        [ibratiomenu setHidden:YES];
        //add by aries
        [btnSelectColor_ setHidden:NO];
        for (int i = 0; i < (int)[btnColorArray_ count]; i++) {
            [[btnColorArray_ objectAtIndex:i] setHidden:NO];
        }
        [fuzzyDegreeImageView_ setHidden:YES];
        [mosaicSlider_ setHidden:YES];
        
        [self setLineWithBtnStateFromConfig];
        [self setBrushColorFromConfig];
        ///}
    }else if ([btnText_ isEqual:sender]) {
        seletedBtnRectX = btnText_.frame.origin.x - 4;
        [self ResetFunType:MJCToolBarFunText];
        
        btnRectangle_.mouse_stype_ = MJCImageButtonNormal;
        [btnRectangle_ setNeedsDisplay];
        btnCircle_.mouse_stype_ = MJCImageButtonNormal;
        [btnCircle_ setNeedsDisplay];
        btnTriangleArrow_.mouse_stype_ = MJCImageButtonNormal;
        [btnTriangleArrow_ setNeedsDisplay];
        btnBrush_.mouse_stype_ = MJCImageButtonNormal;
        [btnBrush_ setNeedsDisplay];
        btnText_.mouse_stype_ = MJCImageButtonHover;
        [btnText_ setNeedsDisplay];
        
        [btnLineWidthSmall_ setHidden:YES];
        [btnLineWidthMid_ setHidden:YES];
        [btnLineWidthBig_ setHidden:YES];
        [textFontImageView_ setHidden:NO];
        [textFontSize_ setHidden:YES];
        [ibratiomenu setHidden:NO];
        //add by aries
        [btnSelectColor_ setHidden:NO];
        for (int i = 0; i < (int)[btnColorArray_ count]; i++) {
            [[btnColorArray_ objectAtIndex:i] setHidden:NO];
        }
        [fuzzyDegreeImageView_ setHidden:YES];
        [mosaicSlider_ setHidden:YES];
        
        [self setBrushColorFromConfig];
        [self setTextSizeFromConfig];
        ///}
    }else if ([btnUndo_ isEqual:sender]) {
//        seletedBtnRectX = -100;
        if ([[[self window] undoManager] canUndo]) {
            [[[self window] undoManager] undo];
            btnUndo_.mouse_stype_ = MJCImageButtonNormal;
            [btnUndo_ setNeedsDisplay:YES];
            NSLog(@"btnUndo_ 1");
        }else{
            [((SnipView*)[self superview]) cleanOpationAndReStart];
            [self resetToolbarBtnStatus];
            NSLog(@"btnUndo_ 2");
        }
    }else if ([btnSave_ isEqual:sender]) {
        [self CreatSaveImage:YES];
      [[SnipManager sharedInstance] endCaptureimage];
    }else if ([btnCancel_ isEqual:sender]) {
        [[SnipManager sharedInstance] endCaptureimage];
    }else if ([btnOK_ isEqual:sender]) {
        [self CreatSaveImage:NO];
        [[SnipManager sharedInstance] endCaptureimage];
    }
    
    
    else if ([btnLineWidthSmall_ isEqual:sender]) {
        [SnipManager sharedInstance].nLineWidth = 3;
        
        btnLineWidthSmall_.mouse_stype_ = MJCImageButtonHover;
        [btnLineWidthSmall_ setNeedsDisplay];
        btnLineWidthMid_.mouse_stype_ = MJCImageButtonNormal;
        [btnLineWidthMid_ setNeedsDisplay];
        btnLineWidthBig_.mouse_stype_ = MJCImageButtonNormal;
        [btnLineWidthBig_ setNeedsDisplay];
        //add by aries
        [[MJPersistentUtil getInstance] setLineWidthForType:[SnipManager sharedInstance].funType lineWidth:3];
        if([SnipManager sharedInstance].funType == MJCToolBarFunMosaic){
            [((SnipView*)[self superview]) BeginEdit];
        }
        ///}
    }else if ([btnLineWidthMid_ isEqual:sender]) {
        [SnipManager sharedInstance].nLineWidth = 6;
        
        btnLineWidthSmall_.mouse_stype_ = MJCImageButtonNormal;
        [btnLineWidthSmall_ setNeedsDisplay];
        btnLineWidthMid_.mouse_stype_ = MJCImageButtonHover;
        [btnLineWidthMid_ setNeedsDisplay];
        btnLineWidthBig_.mouse_stype_ = MJCImageButtonNormal;
        [btnLineWidthBig_ setNeedsDisplay];
        //add by aries
        [[MJPersistentUtil getInstance] setLineWidthForType:[SnipManager sharedInstance].funType lineWidth:6];
        if([SnipManager sharedInstance].funType == MJCToolBarFunMosaic){
            [((SnipView*)[self superview]) BeginEdit];
        }
        ///}
    }else if ([btnLineWidthBig_ isEqual:sender]) {
        [SnipManager sharedInstance].nLineWidth = 12;
        
        btnLineWidthSmall_.mouse_stype_ = MJCImageButtonNormal;
        [btnLineWidthSmall_ setNeedsDisplay];
        btnLineWidthMid_.mouse_stype_ = MJCImageButtonNormal;
        [btnLineWidthMid_ setNeedsDisplay];
        btnLineWidthBig_.mouse_stype_ = MJCImageButtonHover;
        [btnLineWidthBig_ setNeedsDisplay];
        //add by aries
        [[MJPersistentUtil getInstance] setLineWidthForType:[SnipManager sharedInstance].funType lineWidth:12];
        if([SnipManager sharedInstance].funType == MJCToolBarFunMosaic){
            [((SnipView*)[self superview]) BeginEdit];
        }
        
        ///}
    }
    
    ///add by aries{
    else if([btnMosaic_ isEqual:sender]){
        seletedBtnRectX = btnMosaic_.frame.origin.x - 4;
        //读取配置文件
        [SnipManager sharedInstance].funType = MJCToolBarFunMosaic;
        [self setLineWithBtnStateFromConfig];
        [self setSliderValueFromConfig];
        [self ResetFunType:MJCToolBarFunMosaic];
        //隐藏不需要的控件
        [textFontImageView_ setHidden:YES];
        [textFontSize_ setHidden:YES];
        [ibratiomenu setHidden:YES];
        [btnSelectColor_ setHidden:YES];
        for (int i = 0; i < (int)[btnColorArray_ count]; i++) {
            [[btnColorArray_ objectAtIndex:i] setHidden:YES];
        }
        //显示必要控件
        [btnLineWidthSmall_ setHidden:NO];
        [btnLineWidthMid_ setHidden:NO];
        [btnLineWidthBig_ setHidden:NO];
        [fuzzyDegreeImageView_ setHidden:NO];
        [mosaicSlider_ setHidden:NO];
      
        
    }
    else if([mosaicSlider_ isEqual:sender]){
        //取得滑块的值
        //int sliderValue = [mosaicSlider_ intValue];
        //int sliderValue = 50;
        //改变模糊度
        //[((SnipView*)[self superview]) changeMosaic:sliderValue];
    }
    ///}
    [self setNeedsDisplay:YES];
}

//如果不是save，则放到剪切板中
- (void)CreatSaveImage:(BOOL)isSave{
    [((SnipView*)[self superview]) CreatSaveImage:isSave];
}

- (void)btnColorAction:(id)sender{
    if (![btnSelectColor_ isEqual:sender]) {
        btnSelectColor_.bgNormalColor = ((MJCaptureColorButton*)sender).bgNormalColor;
        
        [SnipManager sharedInstance].brushColor = btnSelectColor_.bgNormalColor;
        //[((SnipView*)[self superview]) upSelectSlideViewColor];
        
        [btnSelectColor_ setNeedsDisplay:YES];
      
        long long index = [btnColorArray_ indexOfObject:((MJCaptureColorButton*)sender)];
        MJCToolBarFunType type = [SnipManager sharedInstance].funType;
        [[MJPersistentUtil getInstance] setBrushColorForType:type brushColor:(int)index];
    }
}


- (void)mouseDown:(NSEvent*)theEvent {
    firstMouseDonwPoint_ = theEvent.locationInWindow;
    oldRect_ = [self frame];
    isMouseDown_ = YES;
}
- (void)mouseUp:(NSEvent *)theEvent{
    if (isMouseDown_) {
        NSPoint pt = theEvent.locationInWindow;
        NSRect oldRect = oldRect_;
        
        oldRect.origin.x = oldRect.origin.x + (pt.x-firstMouseDonwPoint_.x);
        oldRect.origin.y = oldRect.origin.y + (pt.y-firstMouseDonwPoint_.y);
        
        NSRect screenRect = ((SnipView*)self.superview).screen.frame;
        if (oldRect.origin.x < 0) {
            oldRect.origin.x = 0;
        }
        if (oldRect.origin.y < 0) {
            oldRect.origin.y = 0;
        }
        if (oldRect.origin.x+oldRect.size.width > screenRect.size.width) {
            oldRect.origin.x = screenRect.size.width - oldRect.size.width;
        }
        if (oldRect.origin.y+oldRect.size.height > screenRect.size.height) {
            oldRect.origin.y = screenRect.size.height-oldRect.size.height;
        }
        [self setFrame:oldRect];
    }
    isMouseDown_ = NO;
}

- (void)mouseDragged:(NSEvent *)theEvent{
    if (isMouseDown_) {
        NSPoint pt = theEvent.locationInWindow;
        NSRect oldRect = oldRect_;
        oldRect.origin = NSMakePoint(oldRect.origin.x+(pt.x-firstMouseDonwPoint_.x), oldRect.origin.y+(pt.y-firstMouseDonwPoint_.y));
        [self setFrameOrigin:oldRect.origin];
    }
}

-(void)ResetButtonType:(MJCToolBarFunType)type{
    
    switch (type) {
        case MJCToolBarFunTriangleArrow:{
            [self btnAction:btnTriangleArrow_];
//            btnTriangleArrow_.mouse_stype_ = MJCImageButtonHover;
//            [self AllButtonRedraw];
        }
            break;
        case MJCToolBarFunRectangle:{
            [self btnAction:btnRectangle_];
//            btnRectangle_.mouse_stype_ = MJCImageButtonHover;
//            [self AllButtonRedraw];
        }
            break;
        case MJCToolBarFunCircle:{
            [self btnAction:btnCircle_];
//            btnCircle_.mouse_stype_ = MJCImageButtonHover;
//            [self AllButtonRedraw];
        }
            break;
        case MJCToolBarFunBrush:{
            [self btnAction:btnBrush_];
//            btnBrush_.mouse_stype_ = MJCImageButtonHover;
//            [self AllButtonRedraw];
        }
            break;
        case MJCToolBarFunText:{
            [self btnAction:btnText_];
//            btnText_.mouse_stype_ = MJCImageButtonHover;
//            [self AllButtonRedraw];
        }
            break;
        default:
            break;
    }
    btnRectangle_.mouse_stype_ = MJCImageButtonNormal;
    btnCircle_.mouse_stype_ = MJCImageButtonNormal;
    btnTriangleArrow_.mouse_stype_ = MJCImageButtonNormal;
    btnBrush_.mouse_stype_ = MJCImageButtonNormal;
    btnText_.mouse_stype_ = MJCImageButtonNormal;
    [self AllButtonRedraw];
}

-(void)ResetLingWidthType:(int)nLineWidth_ {
    if (nLineWidth_==4) {
        [SnipManager sharedInstance].nLineWidth = 4;
        btnLineWidthSmall_.mouse_stype_ = MJCImageButtonHover;
        [btnLineWidthSmall_ setNeedsDisplay];
        btnLineWidthMid_.mouse_stype_ = MJCImageButtonNormal;
        [btnLineWidthMid_ setNeedsDisplay];
        btnLineWidthBig_.mouse_stype_ = MJCImageButtonNormal;
        [btnLineWidthBig_ setNeedsDisplay];
    }else if (nLineWidth_==6) {
        [SnipManager sharedInstance].nLineWidth = 6;
        
        btnLineWidthSmall_.mouse_stype_ = MJCImageButtonNormal;
        [btnLineWidthSmall_ setNeedsDisplay];
        btnLineWidthMid_.mouse_stype_ = MJCImageButtonHover;
        [btnLineWidthMid_ setNeedsDisplay];
        btnLineWidthBig_.mouse_stype_ = MJCImageButtonNormal;
        [btnLineWidthBig_ setNeedsDisplay];
    }else if (nLineWidth_==12) {
        [SnipManager sharedInstance].nLineWidth = 12;
        
        btnLineWidthSmall_.mouse_stype_ = MJCImageButtonNormal;
        [btnLineWidthSmall_ setNeedsDisplay];
        btnLineWidthMid_.mouse_stype_ = MJCImageButtonNormal;
        [btnLineWidthMid_ setNeedsDisplay];
        btnLineWidthBig_.mouse_stype_ = MJCImageButtonHover;
        [btnLineWidthBig_ setNeedsDisplay];
    }
}
-(void)AllButtonRedraw{
    [btnTriangleArrow_ setNeedsDisplay:YES];
    [btnRectangle_ setNeedsDisplay:YES];
    [btnCircle_ setNeedsDisplay:YES];
    [btnBrush_ setNeedsDisplay:YES];
    [btnText_ setNeedsDisplay:YES];
}

-(void) setLineWithBtnStateFromConfig{
  
    MJCToolBarFunType type = [SnipManager sharedInstance].funType;
    int lineWidth = [[MJPersistentUtil getInstance] lineWidthForType:type];
    if(lineWidth == 3){
        btnLineWidthSmall_.mouse_stype_ = MJCImageButtonHover;
        [btnLineWidthSmall_ setNeedsDisplay];
        btnLineWidthMid_.mouse_stype_ = MJCImageButtonNormal;
        [btnLineWidthMid_ setNeedsDisplay];
        btnLineWidthBig_.mouse_stype_ = MJCImageButtonNormal;
        [btnLineWidthBig_ setNeedsDisplay];
    }else if(lineWidth == 6){
        btnLineWidthSmall_.mouse_stype_ = MJCImageButtonNormal;
        [btnLineWidthSmall_ setNeedsDisplay];
        btnLineWidthMid_.mouse_stype_ = MJCImageButtonHover;
        [btnLineWidthMid_ setNeedsDisplay];
        btnLineWidthBig_.mouse_stype_ = MJCImageButtonNormal;
        [btnLineWidthBig_ setNeedsDisplay];
    }else if(lineWidth == 12){
        btnLineWidthSmall_.mouse_stype_ = MJCImageButtonNormal;
        [btnLineWidthSmall_ setNeedsDisplay];
        btnLineWidthMid_.mouse_stype_ = MJCImageButtonNormal;
        [btnLineWidthMid_ setNeedsDisplay];
        btnLineWidthBig_.mouse_stype_ = MJCImageButtonHover;
        [btnLineWidthBig_ setNeedsDisplay];
    }
    
    [SnipManager sharedInstance].nLineWidth = lineWidth;
}

-(void) setBrushColorFromConfig{
    
    MJCToolBarFunType type = [SnipManager sharedInstance].funType;
    int index = [[MJPersistentUtil getInstance] brushColorForType:type];
    MJCaptureColorButton* btn = [btnColorArray_ objectAtIndex:index];
    btnSelectColor_.bgNormalColor = btn.bgNormalColor;
    [btnSelectColor_ setNeedsDisplay:YES];
    
    [SnipManager sharedInstance].brushColor = btnSelectColor_.bgNormalColor;
}

-(void) setTextSizeFromConfig{
  
    MJCToolBarFunType type = [SnipManager sharedInstance].funType;
    int size = [[MJPersistentUtil getInstance] textSizeForType:type];
    NSString *stringSize = [NSString stringWithFormat:@"%d",size];
    
    NSInteger index = [ratiomenu indexOfItemWithTitle:stringSize];
    if(index != -1){
        //[ratiomenu selectItemAtIndex:index];
        [ibratiomenu setTitle:stringSize];
        ibratiomenu.stritemname = stringSize;
        [ibratiomenu setNeedsDisplay];
        //NSLog(stringSize);
    }
    
    [SnipManager sharedInstance].nFontSize = size;
}

-(void) setSliderValueFromConfig{
    /*
    int sliderValue = [MJPersistentUtil sliderValue];
    [mosaicSlider_ updateSlider:sliderValue];
     */
    MJCToolBarFunType type = [SnipManager sharedInstance].funType;
    int sliderValue = [[MJPersistentUtil getInstance] sliderValueForType:type];
    [mosaicSlider_ updateSlider:sliderValue];
}

-(void)resetToolbarBtnStatus {
    seletedBtnRectX = -100;
    [self setNeedsDisplay:YES];
}

#pragma mark - Mouse Actions
- (BOOL)acceptsFirstMouse:(NSEvent *)event {
    return YES;
}

- (BOOL)acceptsFirstResponder {
    return YES;
}

- (void)mouseEntered:(NSEvent *)event {
    [[self enclosingScrollView] setDocumentCursor:[NSCursor arrowCursor]];
}

- (void)mouseExited:(NSEvent *)event {
    
}

@end
