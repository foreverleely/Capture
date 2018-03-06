//
//  MJCaptureAssetView.h
//  MacCapture
//
//  Created by mengjianjun on 15/8/22.
//  Copyright (c) 2015年 jacky.115.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DropDownButton : NSButton
{
    NSPopUpButtonCell *popUpCell;
    
    NSMenu *ratiomenu;
    
    NSString *stritemname;
}
@property (retain) NSString *stritemname;

- (void)setUsesMenu:(BOOL)flag;
- (BOOL)usesMenu;

//- (IBAction)popupAction:(id)sender;

@end

