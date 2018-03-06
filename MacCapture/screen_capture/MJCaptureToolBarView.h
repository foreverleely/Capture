//
//  MJCaptureToolBarView.h
//  MacCapture
//
//  Created by 115Browser on 8/16/15.
//  Copyright (c) 2015 jacky.115.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MJCaptureCustonButton.h"
#import "MJCaptureModel.h"

#import "DropDownButton.h"
#import "CustomSlider.h"


@interface MJCaptureToolBarView : NSView<ICustomSliderDelegate>{
    int nSpace_;
    int btnWidth_;
    int btnHeight_;
    ///add by aries{
    MJCImageButton *btnMosaic_;
    MJCImageButton* fuzzyDegreeImageView_;  //模糊度
    CustomSlider* mosaicSlider_;  //模糊度滑块
    ///}
    MJCImageButton *btnRectangle_;
    MJCImageButton *btnCircle_;
    MJCImageButton *btnTriangleArrow_;//箭头
    MJCImageButton *btnBrush_;//刷
    MJCImageButton *btnText_;//文字
    MJCImageButton *btnUndo_;//返回
    MJCImageButton *btnSave_;//报错
    MJCImageButton *btnCancel_;
    MJCImageButton *btnOK_;
    
    MJCImageButton *btnLineWidthSmall_;
    MJCImageButton *btnLineWidthMid_;
    MJCImageButton *btnLineWidthBig_;
    
    MJCImageButton *textFontImageView_;
    NSTextField *textFontSize_;
    
    MJCaptureColorButton *btnSelectColor_;
    NSMutableArray *btnColorArray_;
    
    //是否显示子功能view
    BOOL isShowSubFunction_;
    
    BOOL isMouseDown_;
    NSPoint firstMouseDonwPoint_;
    NSRect oldRect_;
    
    
    DropDownButton     *ibratiomenu;
    NSMenu             *ratiomenu;
    float seletedBtnRectX;
    
}

- (IBAction)popupAction:(id)sender;
- (void)selectMenuIndex:(id)sender;

- (void)ResetFunType:(MJCToolBarFunType)type;
- (void)btnAction:(id)sender;
- (void)btnColorAction:(id)sender;

//如果不是save，则放到剪切板中
- (void)CreatSaveImage:(BOOL)isSave;

//点解图案改变按钮状态
-(void)ResetButtonType:(MJCToolBarFunType)type;
-(void)ResetLingWidthType:(int)nLineWidth_;

//滑块改变
- (void) valueChanged:(CGFloat)newValue;

//根据配置文件初始化线宽控件
-(void) setLineWithBtnStateFromConfig;
-(void) setBrushColorFromConfig;
-(void) setTextSizeFromConfig;
-(void) setSliderValueFromConfig;

//重新设置工具栏按钮状态
-(void) resetToolbarBtnStatus;
@end
