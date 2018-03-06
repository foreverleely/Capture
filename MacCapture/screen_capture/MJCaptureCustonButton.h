//
//  MJCaptureCustonButton.h
//  test_3
//
//  Created by mengjianjun on 3/25/15.
//  Copyright (c) 2015 mengjianjun. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum MJCImageButtonType{
    MJCImageButtonNormal,
    MJCImageButtonHover,
    MJCImageButtonPress
}MJCImageButtonType;
@interface MJCImageButton : NSButton{
    
    int space_;
    MJCImageButtonType mouse_stype_;
    
    id account_info_target_;
    
    NSColor  *bgNormalColor;
    NSColor  *bgHoverColor;
    NSColor  *bgPressColor;
    NSColor  *TitleNormalColor;
    NSColor  *TitleHoverColor;
    NSColor  *TitlePressColor;
}
@property (assign) id account_info_target_;
@property (assign) int space_;
@property (assign) MJCImageButtonType mouse_stype_;
@property (assign) BOOL isPopUpButton;
@property (assign) BOOL isFirstMenuButton;

@property (retain)NSColor  *bgNormalColor;
@property (retain)NSColor  *bgHoverColor;
@property (retain)NSColor  *bgPressColor;
@property (retain)NSColor  *TitleNormalColor;
@property (retain)NSColor  *TitleHoverColor;
@property (retain)NSColor  *TitlePressColor;

@end


@interface MJCaptureColorButton : NSButton{
    NSColor  *bgNormalColor;
}
@property (retain)NSColor  *bgNormalColor;
@end