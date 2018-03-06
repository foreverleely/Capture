//
//  MJCaptureAssetView.h
//  MacCapture
//
//  Created by mengjianjun on 15/8/22.
//  Copyright (c) 2015年 jacky.115.com. All rights reserved.
//

#import "DropDownButton.h"
#import "MJCaptureModel.h"
#import "MJCaptureView.h"

@implementation DropDownButton
@synthesize stritemname;
// -------------------------------------------------------------------------------
//	awakeFromNib:
// -------------------------------------------------------------------------------
- (void)awakeFromNib
{
    if ([self menu] != nil)
	{
		[self setUsesMenu:YES];
	}
    stritemname = [[NSString alloc] init];
}
- (id)init{
    if (self == [super init]) {
        if ([self menu] != nil)
        {
            [self setUsesMenu:YES];
        }
        stritemname = [[NSString alloc] initWithString:@"16"];
    }
    return self;
}
- (id)initWithFrame:(NSRect)frameRect{
    if (self == [super initWithFrame:frameRect]) {
        if ([self menu] != nil)
        {
            [self setUsesMenu:YES];
        }
        stritemname = [[NSString alloc] initWithString:@"16"];
    }
    return self;
}

// -------------------------------------------------------------------------------
//	dealloc:
// -------------------------------------------------------------------------------
- (void)dealloc
{
    [popUpCell release];
    [stritemname release];
    [super dealloc];
}

- (void)drawRect:(NSRect)dirtyRect
{
    //[super drawRect:dirtyRect];
    // Drawing code here.
    //return;
    
    NSGraphicsContext *nsGraphicsContext = [NSGraphicsContext currentContext];
	[NSGraphicsContext saveGraphicsState];
	[NSGraphicsContext setCurrentContext:nsGraphicsContext];
	CGContextRef context = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
    int x = 0, y = 0;
    //NSString *strpath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"pop_up.png"];
    //CGImageRef ri = createCGImageWithName(strpath);
    CGImageRef ri=NULL;// = createCGImageRefFromNSImage([super image]);
    
    if ([self isEnabled]) {
        ri = createCGImageRefFromNSImage([self image]);
    }else{
        ri = createCGImageRefFromNSImage([self alternateImage]);
    }
    
    CGContextTranslateCTM(context, 0, [self bounds].size.height);
    CGContextScaleCTM(context, 1, -1);
    
    float w = CGImageGetWidth(ri), h = CGImageGetHeight(ri);
    if (w<dirtyRect.size.width && h<dirtyRect.size.height) {
        CGContextDrawImage(context, CGRectMake((dirtyRect.size.width-w)/2, (dirtyRect.size.height-h)/2+1, w, h), ri);
    }else{
        CGContextDrawImage(context, CGRectMake(x, y, w, h), ri);
    }
    //fslog(@"%f, %f", w, h);
    
    CGContextSetRGBFillColor(context, 1, 1, 1, 0.9);//0.0, 0, 0.5, 0.1);
    
    CGContextSetTextDrawingMode(context, kCGTextFill);
    CGContextSelectFont(context, "Arial", 13, kCGEncodingMacRoman);
    if (!stritemname) {
        stritemname = [NSString stringWithFormat:@"%d", ((MJCaptureView*)[[self superview] superview]).nFontSize_];
    }
    if ([stritemname length] == 0 || [stritemname isEqualToString:@"pt"]) {
        stritemname = [NSString stringWithFormat:@"%d", ((MJCaptureView*)[[self superview] superview]).nFontSize_];
    }
    CGContextShowTextAtPoint(context, 8, 7, [[stritemname stringByAppendingString:@"pt"] UTF8String] , strlen([[stritemname stringByAppendingString:@"pt"] UTF8String]));
    
//    [NSGraphicsContext restoreGraphicsState];
    CGImageRelease(ri);
    //加数字旁边的三角形
    CGContextRef newContext = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
    CGContextSetRGBFillColor(newContext, 1, 1, 1, 0.9);
    CGContextMoveToPoint(newContext, 50, 12);
    CGContextAddLineToPoint(newContext, 56, 12);
    CGContextAddLineToPoint(newContext, 53, 9);
    CGContextSetLineWidth(newContext, 1);
    CGContextClosePath(newContext);
    CGContextFillPath(newContext);
    
    [NSGraphicsContext restoreGraphicsState];
    [[NSColor colorWithSRGBRed:200/255.0 green:200/255.0 blue:200/255.0 alpha:0.4] set];
    [[NSBezierPath bezierPathWithRoundedRect:dirtyRect xRadius:4 yRadius:4] stroke];
    
    
}

// -------------------------------------------------------------------------------
//	setUsesMenu:flag
// -------------------------------------------------------------------------------
- (void)setUsesMenu:(BOOL)flag
{
    if (popUpCell == nil && flag)
	{
        popUpCell = [[NSPopUpButtonCell alloc] initTextCell:@""];
        [popUpCell setPullsDown:YES];
        [popUpCell setPreferredEdge:NSMaxYEdge];
    }
	else if (popUpCell != nil && !flag)
	{
        [popUpCell release];
        popUpCell = nil;
        //fslog(@"%@", popUpCell);
    }
}

// -------------------------------------------------------------------------------
//	usesMenu:
// -------------------------------------------------------------------------------
- (BOOL)usesMenu
{
    return (popUpCell != nil);
}

// -------------------------------------------------------------------------------
//	runPopUp:theEvent
// -------------------------------------------------------------------------------
- (void)runPopUp:(NSEvent *)theEvent
{
    // create the menu the popup will use
    if ([self menu] == nil) {
        return;
    }
    [[self window] makeFirstResponder:self];
//    [self setNeedsDisplay:YES];
//    [[self superview] setNeedsDisplay:YES];
    
    NSMenu *popUpMenu = [[self menu] copy];
    
    NSArray *array = [popUpMenu itemArray];
    for (int i = 0; i < [array count]; i++) {
        NSMenuItem *item = [array objectAtIndex:i];
        item.enabled = YES;
    }
    
    [popUpMenu insertItemWithTitle:@"" action:NULL keyEquivalent:@"" atIndex:0];	// blank item at top
    [popUpCell setMenu:popUpMenu];
    
    // and show it
    [popUpCell performClickWithFrame:[self bounds] inView:self];
    [popUpCell setAutoenablesItems:NO];
    
    for (int i = 0; i < [array count]; i++) {
        [[popUpCell itemAtIndex:i] setEnabled:YES];
    }
    
    [popUpMenu release];
    
    
    /*CGFloat menuItemHeight = 32;
    NSRect viewRect = NSMakeRect(0, 0, 1, menuItemHeight);
    NSView *menuItemView = [[[FullMenuItemView alloc] initWithFrame:viewRect] autorelease];
    menuItemView.autoresizingMask = NSViewWidthSizable;
    [popUpCell selectedItem].view = menuItemView;*/
    
    if ([@"Freeform" isEqualToString:[popUpCell titleOfSelectedItem]]) {
        //fslog(@"runPopUp");
    }
    
    NSLog(@"MenuDropDownButton==>runPopUp    %@", [stritemname stringByAppendingString:@"pt"]);
    
    stritemname = [popUpCell titleOfSelectedItem];
    if ([stritemname length] == 0) {
        return;
        stritemname = [NSString stringWithFormat:@"%d", ((MJCaptureView*)[[self superview] superview]).nFontSize_];
    }else{
        ((MJCaptureView*)[[self superview] superview]).nFontSize_ = [[popUpCell titleOfSelectedItem] intValue];
    }
    if ([stritemname isEqualToString:@"pt"]) {
        stritemname = [NSString stringWithFormat:@"%d", ((MJCaptureView*)[[self superview] superview]).nFontSize_];
    }else{
        ((MJCaptureView*)[[self superview] superview]).nFontSize_ = [[popUpCell titleOfSelectedItem] intValue];
    }
    [self setTitle:[stritemname stringByAppendingString:@"pt"]];
    
//    [[self window] makeFirstResponder:[self window]];
    [((MJCaptureView*)[[self superview] superview]) makeTextViewFocus];
    //fslog(@"%@", stritemname);
    //[self setNeedsDisplay:YES];
}

// -------------------------------------------------------------------------------
//	mouseDown:theEvent
// -------------------------------------------------------------------------------
- (void)mouseDown:(NSEvent*)theEvent
{
	if ([self usesMenu])
	{
		[self runPopUp:theEvent];
	}
    [((MJCaptureView*)[[self superview] superview]) makeTextViewFocus];
}

@end

