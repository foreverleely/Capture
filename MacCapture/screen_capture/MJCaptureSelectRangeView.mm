//
//  MJCaptureSelectRangeView.m
//  MacCapture
//
//  Created by 115Browser on 8/17/15.
//  Copyright (c) 2015 jacky.115.com. All rights reserved.
//

#import "MJCaptureSelectRangeView.h"
#import "MJCaptureView.h"

@implementation MJCaptureSelectRangeView//截图所选区域
@synthesize nSpanValue_;
- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        nSpanValue_ = 8;
        firstBeginDrag_ = NO;
        mouseDragAction_ = MJCMouseInCropMove;
        
        
        
        //ps:注意，如果没有经过awakeFromNib的话，还需要加上acceptsFirstResponder才能让mouseMoved起作用
        //        [self addTrackingRect:self.bounds owner:self userData:nil assumeInside:YES];
        NSTrackingAreaOptions options = (NSTrackingActiveAlways | NSTrackingInVisibleRect |
                                         NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved);
        trackingArea_ = [[NSTrackingArea alloc] initWithRect:[self bounds]
                                                     options:options
                                                       owner:self
                                                    userInfo:nil];
        [self addTrackingArea:trackingArea_];
    }
    return self;
}

- (void) dealloc{
    [trackingArea_ release];
    [super dealloc];
}

- (void)drawRect:(NSRect)dirtyRect
{
    //[super drawRect:dirtyRect];
    
    [[NSColor colorWithCalibratedRed:0.035 green:0.529 blue:0.957 alpha:1] set];
    //[[NSColor blueColor] set];
    NSRect insetRect = NSInsetRect(dirtyRect, nSpanValue_/2.0, nSpanValue_/2.0);
    NSBezierPath *strokePath = [NSBezierPath bezierPathWithRect:insetRect];
    //strokePath = [NSBezierPath bezierPathWithRect:dirtyRect];
    [strokePath setLineWidth:3];
    [strokePath stroke];
    
    if (((MJCaptureView*)[self superview]).isCapture_) {
        NSPoint start = insetRect.origin;
        NSSize size = NSMakeSize(insetRect.size.width, insetRect.size.height);
        start.x-=nSpanValue_/2.0;
        start.y-=nSpanValue_/2.0;
        NSRect re[9];
        re[0] = NSMakeRect(start.x, start.y, nSpanValue_, nSpanValue_);
        re[1] = NSMakeRect(start.x+size.width/2, start.y,nSpanValue_,nSpanValue_);
        re[2] = NSMakeRect(start.x+size.width, start.y, nSpanValue_, nSpanValue_);
        start.y+=size.height/2;
        re[3] = NSMakeRect(start.x, start.y, nSpanValue_, nSpanValue_);
        re[4] = NSMakeRect(start.x+size.width, start.y, nSpanValue_, nSpanValue_);
        start.y+=size.height/2;
        re[5] = NSMakeRect(start.x, start.y, nSpanValue_, nSpanValue_);
        re[6] = NSMakeRect(start.x+size.width/2, start.y, nSpanValue_, nSpanValue_);
        re[7] = NSMakeRect(start.x+size.width, start.y, nSpanValue_, nSpanValue_);
        re[8] = NSMakeRect(start.x+size.width/2, start.y+20, nSpanValue_, nSpanValue_);
        NSBezierPath *pathCircle = [NSBezierPath bezierPath];
        [[NSColor whiteColor] set];
        for(int j=0;j<8;++j)
        {
            pathCircle = [NSBezierPath bezierPathWithOvalInRect:re[j]];
            [pathCircle fill];
        }
    }
    
    return;
    //[[self superview] drawRect:dirtyRect];
}

- (void)keyDown:(NSEvent *)theEvent{
//    NSLog(@"MJCaptureSelectRangeView: keydown:%@", theEvent);
}

- (MJCMouseState)getMouseActionType:(NSPoint)pt{
    NSRect insetRect = NSInsetRect([self bounds], nSpanValue_/2.0, nSpanValue_/2.0);
    NSPoint start = insetRect.origin;
    NSSize size = NSMakeSize(insetRect.size.width, insetRect.size.height);
    start.x-=nSpanValue_/2.0;
    start.y-=nSpanValue_/2.0;
    NSRect re[8];
    re[MJCMouseLeftBotton] = NSMakeRect(0, 0, nSpanValue_, nSpanValue_);
    re[MJCMouseBottomMid] = NSMakeRect(nSpanValue_, 0,[self bounds].size.width-nSpanValue_*2,nSpanValue_);
    re[MJCMouseRightBotton] = NSMakeRect([self bounds].size.width-nSpanValue_, 0, nSpanValue_, nSpanValue_);
    start.y+=size.height/2;
    re[MJCMouseLeftMid] = NSMakeRect(0, nSpanValue_, nSpanValue_, [self bounds].size.height-nSpanValue_*2);
    re[MJCMouseRightMid] = NSMakeRect([self bounds].size.width-nSpanValue_, nSpanValue_, nSpanValue_, [self bounds].size.height-nSpanValue_*2);
    start.y+=size.height/2;
    re[MJCMouseLeftTop] = NSMakeRect(0, [self bounds].size.height-nSpanValue_, nSpanValue_, nSpanValue_);
    re[MJCMouseTopMid] = NSMakeRect(nSpanValue_, [self bounds].size.height-nSpanValue_, [self bounds].size.width-nSpanValue_*2, nSpanValue_);
    re[MJCMouseRightTop] = NSMakeRect([self bounds].size.width-nSpanValue_, [self bounds].size.height-nSpanValue_, nSpanValue_, nSpanValue_);
    
    NSPoint tempPoint = [self convertPoint:pt fromView:nil];
    
    MJCMouseState state = MJCMouseInCropMove;
    BOOL isDraggeChangeSize = NO;
    for (int i = 0; i < 8; i++) {
        if (NSPointInRect(tempPoint, re[i])) {
            state = (MJCMouseState)i;
            isDraggeChangeSize = YES;
            break;
        }
    }
    if (!isDraggeChangeSize) {
        state = MJCMouseInCropMove;
    }
    
    //	NSLog(@"mouseDragAction_:  %d", state);
    return state;
}
- (NSImage *)GetCaptureCursorImage{
//    ResourceBundle& rb = ResourceBundle::GetSharedInstance();
//    return rb.GetNativeImageNamed(IDR_X115_SCREEN_CURSOR7).ToNSImage();
    return [NSImage imageNamed:@"mj_capture_cursor7"];
}

- (void)setCursorForState:(MJCMouseState)state{
    NSCursor *cursor;
    NSImage *image;
    switch (state) {
        case MJCMouseLeftBotton:
            image = [NSImage imageNamed:@"mj_capture_cursor1"];
            cursor = [[NSCursor alloc] initWithImage:image hotSpot:NSMakePoint([image size].width/2, [image size].height/2)];
            [[self enclosingScrollView] setDocumentCursor:cursor];
            [cursor autorelease];
            break;
        case MJCMouseLeftMid:
            image = [NSImage imageNamed:@"mj_capture_cursor4"];
            cursor = [[NSCursor alloc] initWithImage:image hotSpot:NSMakePoint([image size].width/2, [image size].height/2)];
            [[self enclosingScrollView] setDocumentCursor:cursor];
            [cursor autorelease];
            break;
        case MJCMouseLeftTop:
            image = [NSImage imageNamed:@"mj_capture_cursor2"];
            cursor = [[NSCursor alloc] initWithImage:image hotSpot:NSMakePoint([image size].width/2, [image size].height/2)];
            [[self enclosingScrollView] setDocumentCursor:cursor];
            [cursor autorelease];
            break;
        case MJCMouseTopMid:
            image = [NSImage imageNamed:@"mj_capture_cursor3"];
            cursor = [[NSCursor alloc] initWithImage:image hotSpot:NSMakePoint([image size].width/2, [image size].height/2)];
            [[self enclosingScrollView] setDocumentCursor:cursor];
            [cursor autorelease];
            break;
        case MJCMouseRightTop:
            image = [NSImage imageNamed:@"mj_capture_cursor1"];
            cursor = [[NSCursor alloc] initWithImage:image hotSpot:NSMakePoint([image size].width/2, [image size].height/2)];
            [[self enclosingScrollView] setDocumentCursor:cursor];
            [cursor autorelease];
            break;
        case MJCMouseRightMid:
            image = [NSImage imageNamed:@"mj_capture_cursor4"];
            cursor = [[NSCursor alloc] initWithImage:image hotSpot:NSMakePoint([image size].width/2, [image size].height/2)];
            [[self enclosingScrollView] setDocumentCursor:cursor];
            [cursor autorelease];
            break;
        case MJCMouseRightBotton:
            image = [NSImage imageNamed:@"mj_capture_cursor2"];
            cursor = [[NSCursor alloc] initWithImage:image hotSpot:NSMakePoint([image size].width/2, [image size].height/2)];
            [[self enclosingScrollView] setDocumentCursor:cursor];
            [cursor autorelease];
            break;
        case MJCMouseBottomMid:
            image = [NSImage imageNamed:@"mj_capture_cursor3"];
            cursor = [[NSCursor alloc] initWithImage:image hotSpot:NSMakePoint([image size].width/2, [image size].height/2)];
            [[self enclosingScrollView] setDocumentCursor:cursor];
            [cursor autorelease];
            break;
        case MJCMouseInCropMove:
            if (((MJCaptureView*)[self superview]).isEdit_) {
                [[self enclosingScrollView] setDocumentCursor:[NSCursor crosshairCursor]];
            }else{
//                image = [NSImage imageNamed:@"cursor6"];
//                cursor = [[NSCursor alloc] initWithImage:image hotSpot:NSMakePoint([image size].width/2, [image size].height/2)];
//                [cursor push];
//                [cursor autorelease];
                [[self enclosingScrollView] setDocumentCursor:[NSCursor openHandCursor]];
            }
            break;
        default:
            [[self enclosingScrollView] setDocumentCursor:[NSCursor arrowCursor]];
            break;
    }
}
- (void)mouseDown:(NSEvent*)theEvent {
    [super mouseDown:theEvent];
    NSPoint pt = theEvent.locationInWindow;
    //add by liuchipeng 2016.1.4{
    if (theEvent.clickCount >= 2){
        MJCaptureView* captureView = (MJCaptureView*)[self superview];
        if ([captureView isCapture_]) {
            [captureView CreatSaveImage:NO];
            [NSApp stopModal];
            [NSApp endSheet:[self window]];
            [[self window] close];
            return;
        }
    }
    //}
    if (((MJCaptureView*)[self superview]).isEdit_) {
        return;
    }
    if (((MJCaptureView*)[self superview]).isCapture_) {
        oldFrameRect_ = [self frame];
        firstMouseDonwPoint_ = pt;//[self convertPoint:pt fromView:nil];
    }
    
    state_ = [self getMouseActionType:pt];
    
    if (state_ == MJCMouseInCropMove) {
        [[self enclosingScrollView] setDocumentCursor:[NSCursor closedHandCursor]];
    } else {
        [self setCursorForState:state_];
    }
}
- (void)mouseUp:(NSEvent *)theEvent{
    [super mouseUp:theEvent];
    
    if (((MJCaptureView*)[self superview]).isEdit_) {
        return;
    }
    [((MJCaptureView*)[self superview]) HideZoomInfoVew];
 
    firstBeginDrag_ = NO;
    NSPoint pt = theEvent.locationInWindow;
    state_ = [self getMouseActionType:pt];
    
    if (state_ == MJCMouseInCropMove) {
        [[self enclosingScrollView] setDocumentCursor:[NSCursor openHandCursor]];
    } else {
        [self setCursorForState:state_];
    }
}
- (void)mouseEntered:(NSEvent*)theEvent {
    [super mouseEntered:theEvent];
    
    if (((MJCaptureView*)[self superview]).isEdit_) {
        return;
    }

}

- (void)mouseExited:(NSEvent*)theEvent {
    [super mouseExited:theEvent];
    
    if (((MJCaptureView*)[self superview]).isEdit_) {
        return;
    }
    [[self enclosingScrollView] setDocumentCursor:[NSCursor arrowCursor]];
}

- (void)mouseMoved:(NSEvent *)theEvent{
    [super mouseMoved:theEvent];
    
    if (((MJCaptureView*)[self superview]).isEdit_) {
        return;
    }
    //NSLog(@"MJCaptureSelectRangeView: %@", @"mouseMoved");
    MJCaptureView *captureView = (MJCaptureView*)[self superview];
    
    NSPoint pt = theEvent.locationInWindow;
    if (captureView != nil && NSPointInRect(pt, captureView.toolbarView.frame)) {
        [[self enclosingScrollView] setDocumentCursor:[NSCursor arrowCursor]];
    } else {
        MJCMouseState state = [self getMouseActionType:pt];
        [self setCursorForState:state];
    }
    
}
- (void)mouseDraggeMoveView:(NSPoint)pt isChangeSize:(BOOL)change event:(NSEvent*)event{
    NSRect oldRect = oldFrameRect_;
    oldRect.origin.x += (pt.x-firstMouseDonwPoint_.x);
    oldRect.origin.y += (pt.y-firstMouseDonwPoint_.y);
    oldRect = NSIntegralRect(oldRect);
    
    NSRect screenRect = [[NSScreen mainScreen] frame];
    if (oldRect.origin.x < 0) {
        oldRect.origin.x = 0;
    }
    if (oldRect.origin.y < 0) {
        oldRect.origin.y = 0;
    }
    if (oldRect.origin.x+oldRect.size.width>screenRect.size.width) {
        oldRect.origin.x = screenRect.size.width-oldRect.size.width;
    }
    if (oldRect.origin.y+oldRect.size.height>screenRect.size.height) {
        oldRect.origin.y = screenRect.size.height-oldRect.size.height;
    }
    
    [self setFrame:oldRect];
    ((MJCaptureView*)[self superview]).oldRangeRect_ = oldRect;
    [((MJCaptureView*)[self superview]) ReCalculateViewFrameChangeSize:change event:event];
}

- (void)mouseDraggeFromChangeFrame:(NSPoint)pt isChangeSize:(BOOL)change event:(NSEvent*)event{
    NSRect oldRect = oldFrameRect_;
    switch (mouseDragAction_) {
        case MJCMouseLeftBotton:
        {
            oldRect.origin.x += (pt.x-firstMouseDonwPoint_.x);
            oldRect.size.width -= (pt.x-firstMouseDonwPoint_.x);
            if (oldRect.size.width < 0) {
                oldRect.origin.x += oldRect.size.width - nSpanValue_;
                oldRect.size.width = -oldRect.size.width;
            }
            
            oldRect.origin.y += (pt.y-firstMouseDonwPoint_.y);
            oldRect.size.height -= (pt.y-firstMouseDonwPoint_.y);
            if (oldRect.size.height < 0) {
                oldRect.origin.y += oldRect.size.height - nSpanValue_;
                oldRect.size.height = -oldRect.size.height;
            }
        }
            break;
        case MJCMouseLeftMid:
        {
            oldRect.origin.x += (pt.x-firstMouseDonwPoint_.x);
            oldRect.size.width -= (pt.x-firstMouseDonwPoint_.x);
            if (oldRect.size.width < 0) {
                oldRect.origin.x += oldRect.size.width - nSpanValue_;
                oldRect.size.width = -oldRect.size.width;
            }
        }
            break;
        case MJCMouseLeftTop:
        {
            oldRect.origin.x += (pt.x-firstMouseDonwPoint_.x);
            oldRect.size.width -= (pt.x-firstMouseDonwPoint_.x);
            if (oldRect.size.width < 0) {
                oldRect.origin.x += oldRect.size.width - nSpanValue_;
                oldRect.size.width = -oldRect.size.width;
            }
            
            oldRect.size.height += (pt.y-firstMouseDonwPoint_.y);
            if (oldRect.size.height < 0) {
                oldRect.origin.y += oldRect.size.height + nSpanValue_;
                oldRect.size.height = -oldRect.size.height;
            }
        }
            break;
        case MJCMouseTopMid:
        {
            oldRect.size.height += (pt.y-firstMouseDonwPoint_.y);
            if (oldRect.size.height < 0) {
                oldRect.origin.y += oldRect.size.height + nSpanValue_;
                oldRect.size.height = -oldRect.size.height;
            }
        }
            break;
        case MJCMouseRightTop:
        {
            oldRect.size.width += (pt.x-firstMouseDonwPoint_.x);
            if (oldRect.size.width < 0) {
                oldRect.origin.x += oldRect.size.width + nSpanValue_;
                oldRect.size.width = -oldRect.size.width;
            }
            oldRect.size.height += (pt.y-firstMouseDonwPoint_.y);
            if (oldRect.size.height < 0) {
                oldRect.origin.y += oldRect.size.height + nSpanValue_;
                oldRect.size.height = -oldRect.size.height;
            }
        }
            break;
        case MJCMouseRightMid:
        {
            oldRect.size.width += (pt.x-firstMouseDonwPoint_.x);
            if (oldRect.size.width < 0) {
                oldRect.origin.x += oldRect.size.width + nSpanValue_;
                oldRect.size.width = -oldRect.size.width;
            }
        }
            break;
        case MJCMouseRightBotton:
        {
            oldRect.size.width += (pt.x-firstMouseDonwPoint_.x);
            if (oldRect.size.width < 0) {
                oldRect.origin.x += oldRect.size.width + nSpanValue_;
                oldRect.size.width = -oldRect.size.width;
            }
            oldRect.origin.y += (pt.y-firstMouseDonwPoint_.y);
            oldRect.size.height -= (pt.y-firstMouseDonwPoint_.y);
            if (oldRect.size.height < 0) {
                oldRect.origin.y += oldRect.size.height - nSpanValue_;
                oldRect.size.height = -oldRect.size.height;
            }
        }
            break;
        case MJCMouseBottomMid:
        {
            oldRect.origin.y += (pt.y-firstMouseDonwPoint_.y);
            oldRect.size.height -= (pt.y-firstMouseDonwPoint_.y);
            if (oldRect.size.height < 0) {
                oldRect.origin.y += oldRect.size.height - nSpanValue_;
                oldRect.size.height = -oldRect.size.height;
            }
        }
            break;
        case MJCMouseInCropMove:
        {
            [self mouseDraggeMoveView:pt isChangeSize:change event:event];
            return;
        }
            break;
            
        default:
            break;
    }
    oldRect = NSIntegralRect(oldRect);
    [self setFrame:oldRect];
    ((MJCaptureView*)[self superview]).oldRangeRect_ = oldRect;
    [((MJCaptureView*)[self superview]) ReCalculateViewFrameChangeSize:YES event:event];
}
- (void)mouseDragged:(NSEvent *)theEvent{
    [super mouseDragged:theEvent];
    //    NSLog(@"MJCaptureView: %@", @"mouseDragged");
    if (((MJCaptureView*)[self superview]).isEdit_) {
        return;
    }
    
    NSPoint pt = theEvent.locationInWindow;
    if (((MJCaptureView*)[self superview]).isCapture_) {
        //pt = [self convertPoint:pt fromView:nil];
        if (firstBeginDrag_) {
            BOOL change = (state_ == MJCMouseInCropMove) ? NO : YES;
            [self mouseDraggeFromChangeFrame:pt isChangeSize:(BOOL)change event:theEvent];
        }else{
            firstBeginDrag_ = YES;
            mouseDragAction_ = [self getMouseActionType:pt];
            
            BOOL change = (state_ == MJCMouseInCropMove) ? NO : YES;
            [self mouseDraggeFromChangeFrame:pt isChangeSize:(BOOL)change event:theEvent];
        }
        
        if (state_ == MJCMouseInCropMove) {
            [[self enclosingScrollView] setDocumentCursor:[NSCursor closedHandCursor]];
        } else {
            [self setCursorForState:state_];
        }
        
    }
}

@end
