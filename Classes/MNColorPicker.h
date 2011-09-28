//
//  MNColorPicker.h
//  MNColorPicker
//

#import <UIKit/UIKit.h>
#import "MNColorWheelView.h"
#import "MNBrightnessView.h"
#import "MNColorView.h"

@protocol MNColorPickerDelegate;

@interface MNColorPicker : UIViewController <MNColorWheelViewDelegate, UITextFieldDelegate> {
	id <MNColorPickerDelegate> _delegate;
	MNColorView *_colorView;
	MNColorWheelView *_colorWheelView;
	MNBrightnessView *_brightnessView;
	UIColor *_color;
	BOOL _continuous;
    
    UIButton *copyButton;
    UIButton *pasteButton;
    UIButton *clearButton;
    
    UITextField *rField;
    UITextField *gField;
    UITextField *bField;
}

@property (assign, nonatomic) id<MNColorPickerDelegate> delegate;
@property (retain) UIColor *color;
@property (getter=isContinuous) BOOL continuous;
@property(readwrite,nonatomic,retain) UIButton *copyButton;
@property(readwrite,nonatomic,retain) UIButton *pasteButton;
@property(readwrite,nonatomic,retain) UIButton *clearButton;
@property(readwrite,nonatomic,retain) UITextField *rField;
@property(readwrite,nonatomic,retain) UITextField *gField;
@property(readwrite,nonatomic,retain) UITextField *bField;

@end


@protocol MNColorPickerDelegate <NSObject>

@required
- (void)colorPicker:(MNColorPicker *)picker didFinishWithColor:(UIColor *)color;
- (void)colorPickerViewControllerCleared:(MNColorPicker *)picker;


@optional
- (void)colorPicker:(MNColorPicker *)picker didChangeColor:(UIColor *)color;


@end
