//
//  MNColorPicker.m
//  MNColorPicker
//

#import "MNColorPicker.h"
#import "MNBrightnessView.h"
#import "UIColor+ColorSpaces.h"


@interface MNColorPicker ()

- (void)_layoutViewsForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;

@end


@implementation MNColorPicker

@synthesize copyButton;
@synthesize pasteButton;
@synthesize clearButton;
@synthesize rField;
@synthesize gField;
@synthesize bField;

#pragma mark -
#pragma mark Loading & Memory Management

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;{
	self = [super initWithNibName:nil bundle:nil];
	if (self != nil) {
		self.color = [UIColor whiteColor];
		self.continuous = NO;
	}
	return self;
}

- (void)updateRGBFields:(id)sender {
    CGColorRef colorref = [self.color CGColor];
    
    int numComponents = CGColorGetNumberOfComponents(colorref);
    
    CGFloat red;
    CGFloat green;
    CGFloat blue;
    CGFloat alpha;
    if (numComponents == 4) {
        const CGFloat *components = CGColorGetComponents(colorref);
        red     = components[0];
        green = components[1];
        blue   = components[2];
        alpha = components[3];
        
    }
    
    [rField setText:[NSString stringWithFormat:@"%.f", red*255.f]];
    [gField setText:[NSString stringWithFormat:@"%.f", green*255.f]];
    [bField setText:[NSString stringWithFormat:@"%.f", blue*255.f]];
}

- (void)loadView {
	[super loadView];
	
	self.view = [[UIView alloc] initWithFrame:CGRectZero];
	[self.view setBackgroundColor:[UIColor scrollViewTexturedBackgroundColor]];
    
	[self.view sizeToFit];
	[self.view release];
	
	_colorView = [[MNColorView alloc] initWithFrame:CGRectZero];
	[self.view addSubview:_colorView];
	[_colorView release];
	
	_colorWheelView = [[MNColorWheelView alloc] initWithFrame:CGRectZero];
	_colorWheelView.delegate = self;
	[self.view addSubview:_colorWheelView];
	[_colorWheelView release];
	[_colorWheelView setNeedsDisplay];
	
	_brightnessView = [[MNBrightnessView alloc] initWithFrame:CGRectZero];
	[self.view addSubview:_brightnessView];
	[_colorWheelView setBrightnessView:_brightnessView];
	[_brightnessView release];
	
	
	self.title = @"Color Picker";
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Choose" style:UIBarButtonItemStyleDone target:self action:@selector(didPressDone)];
	self.navigationItem.rightBarButtonItem = doneButton;
    [doneButton release];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(didPressCancel)];
	self.navigationItem.leftBarButtonItem = cancelButton;
    [cancelButton release];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	[self _layoutViewsForInterfaceOrientation:self.interfaceOrientation];
	_colorView.color = self.color;
	_colorWheelView.color = self.color;
	[_brightnessView setHue:[self.color mn_hueComponent] saturation:[self.color mn_saturationComponent]];
	_brightnessView.brightness = [self.color mn_brightnessComponent];
    [self updateRGBFields:self];
    self.clearButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [clearButton setTitle:@"Clear" forState:UIControlStateNormal];
    [clearButton setFrame:CGRectMake(10, 10, 52, 28)];
    [clearButton addTarget:self action:@selector(clearButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:clearButton];
    
    self.copyButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [copyButton setTitle:@"Copy" forState:UIControlStateNormal];
    [copyButton setFrame:CGRectMake(10+57, 10, 52, 28)];
    [copyButton addTarget:self action:@selector(copyButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:copyButton];
    
    self.pasteButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [pasteButton setTitle:@"Paste" forState:UIControlStateNormal];
    [pasteButton setFrame:CGRectMake(10+57+57, 10, 52, 28)];
    [pasteButton addTarget:self action:@selector(pasteButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:pasteButton];
    
    self.rField = [[UITextField alloc] initWithFrame:CGRectMake(10, 10+30, 52, 31)];
    [rField setBorderStyle:UITextBorderStyleRoundedRect];
    [rField setFont:[UIFont systemFontOfSize:16]];
    [rField setMinimumFontSize:16];
    [rField setAdjustsFontSizeToFitWidth:YES];
    [rField setKeyboardType:UIKeyboardTypeNumberPad];
    [rField setTextAlignment:UITextAlignmentCenter];
    [rField setDelegate:self];
    [self.view addSubview:rField];
    
    self.gField = [[UITextField alloc] initWithFrame:CGRectMake(10+57, 10+30, 52, 31)];
    [gField setBorderStyle:UITextBorderStyleRoundedRect];
    [gField setAdjustsFontSizeToFitWidth:YES];
    [gField setFont:[UIFont systemFontOfSize:16]];
    [gField setMinimumFontSize:16];
    [gField setKeyboardType:UIKeyboardTypeNumberPad];
    [gField setTextAlignment:UITextAlignmentCenter];
    [gField setDelegate:self];
    [self.view addSubview:gField];
    
    self.bField = [[UITextField alloc] initWithFrame:CGRectMake(10+57+57, 10+30, 52, 31)];
    [bField setBorderStyle:UITextBorderStyleRoundedRect];
    [bField setAdjustsFontSizeToFitWidth:YES];
    [bField setFont:[UIFont systemFontOfSize:16]];
    [bField setMinimumFontSize:16];
    [bField setKeyboardType:UIKeyboardTypeNumberPad];
    [bField setTextAlignment:UITextAlignmentCenter];
    [bField setDelegate:self];
    [self.view addSubview:bField];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 3.2) {
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(keyboardDidShow:) 
													 name:UIKeyboardDidShowNotification 
												   object:nil];		
	} else {
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(keyboardWillShow:) 
													 name:UIKeyboardWillShowNotification 
												   object:nil];
	}
    [self updateRGBFields:self];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)addButtonToKeyboard {
	// create custom button
	UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
	doneButton.frame = CGRectMake(0, 163, 106, 53);
	doneButton.adjustsImageWhenHighlighted = NO;
	if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 3.0) {
		[doneButton setImage:[UIImage imageNamed:@"DoneUp3.png"] forState:UIControlStateNormal];
		[doneButton setImage:[UIImage imageNamed:@"DoneDown3.png"] forState:UIControlStateHighlighted];
	} else {        
		[doneButton setImage:[UIImage imageNamed:@"DoneUp.png"] forState:UIControlStateNormal];
		[doneButton setImage:[UIImage imageNamed:@"DoneDown.png"] forState:UIControlStateHighlighted];
	}
	[doneButton addTarget:self action:@selector(doneButton:) forControlEvents:UIControlEventTouchUpInside];
	// locate keyboard view
	UIWindow* tempWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:1];
	UIView* keyboard;
	for(int i=0; i<[tempWindow.subviews count]; i++) {
		keyboard = [tempWindow.subviews objectAtIndex:i];
		// keyboard found, add the button
		if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 3.2) {
			if([[keyboard description] hasPrefix:@"<UIPeripheralHost"] == YES)
				[keyboard addSubview:doneButton];
		} else {
			if([[keyboard description] hasPrefix:@"<UIKeyboard"] == YES)
				[keyboard addSubview:doneButton];
		}
	}
}

- (void)keyboardWillShow:(NSNotification *)note {
	// if clause is just an additional precaution, you could also dismiss it
	if ([[[UIDevice currentDevice] systemVersion] floatValue] < 3.2) {
		[self addButtonToKeyboard];
	}
}

- (void)keyboardDidShow:(NSNotification *)note {
	// if clause is just an additional precaution, you could also dismiss it
	if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 3.2) {
		[self addButtonToKeyboard];
    }
}


- (void)doneButton:(id)sender {
    [rField resignFirstResponder];
    [gField resignFirstResponder];
    [bField resignFirstResponder];
}



- (void)copyButton:(id)sender {
    UIPasteboard *pasteBoard = [UIPasteboard pasteboardWithName:@"ColorCopyier" create:YES];
    pasteBoard.persistent = YES;
    [pasteBoard setColor:self.color];
}

- (void)pasteButton:(id)sender {
    UIPasteboard *pasteBoard = [UIPasteboard pasteboardWithName:@"ColorCopyier" create:YES];
    self.color = [pasteBoard color];
    _colorView.color = self.color;
	_colorWheelView.color = self.color;
	[_brightnessView setHue:[self.color mn_hueComponent] saturation:[self.color mn_saturationComponent]];
	_brightnessView.brightness = [self.color mn_brightnessComponent];
    [self updateRGBFields:self];
    
}

- (void)dealloc {
	self.color = nil;
    [clearButton release];
    [copyButton release];
    [pasteButton release];
    [rField release];
    [gField release];
    [bField release];
    [super dealloc];
}

#pragma mark -
#pragma mark Properties

@synthesize delegate=_delegate;
@synthesize color=_color;
@synthesize continuous=_continuous;


#pragma mark -
#pragma mark Layout

/*- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
	return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
	
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[self _layoutViewsForInterfaceOrientation:toInterfaceOrientation];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	[_brightnessView setNeedsDisplay]; // update the orientation
}*/


- (void)_layoutViewsForInterfaceOrientation: (UIInterfaceOrientation)interfaceOrientation {

	if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
		_colorView.frame = CGRectMake(10+57+57+57+5, 20, 120, 40);
		_colorWheelView.frame = CGRectMake(35, 80, 250, 250);
		_brightnessView.frame = CGRectMake(35, 360, 250, 30);
	}
	[_colorView setNeedsDisplay];
	[_brightnessView updateToInterfaceOrientation:interfaceOrientation];
}

#pragma mark -
#pragma mark Actions

- (void)didPressDone {
	[self.delegate colorPicker:self didFinishWithColor:self.color];
}

- (void)didPressCancel {
	[self.delegate colorPicker:self didFinishWithColor:nil];
}

- (void)clearButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(colorPickerViewControllerCleared:)]) {
        [self.delegate colorPickerViewControllerCleared:self];
    }
}

#pragma mark -
#pragma mark MNColorWheelView Delegate


- (void)colorWheelView:(MNColorWheelView *)colorWheelView didChangeColor:(UIColor *)color {
	self.color = color;
	_colorView.color = color;
	
	if (self.continuous && [self.delegate respondsToSelector:@selector(colorPicker:didChangeColor:)]) {
		[self.delegate performSelector:@selector(colorPicker:didChangeColor:) withObject:self withObject:self.color];
	}
    [self updateRGBFields:self];
}


#pragma text field delegate
- (void)updateColorPositionFromRGB {
    float red = [rField.text floatValue];
    float green = [gField.text floatValue];
    float blue = [bField.text floatValue];
    //NSLog(@"%.2f %.2f %.2f", red, green, blue);
    if (red < 0) {
        red = 0;
    }
    else if (red > 255) {
        red = 255;
    }
    
    if (green < 0) {
        green = 0;
    }
    else if (green > 255) {
        green = 255;
    }
    
    if (blue < 0) {
        blue = 0;
    }
    else if (blue > 255) {
        blue = 255;
    }
    
    self.color = [UIColor colorWithRed:red/255.f green:green/255.f blue:blue/255.f alpha:1.0];
    _colorView.color = self.color;
	_colorWheelView.color = self.color;
	[_brightnessView setHue:[self.color mn_hueComponent] saturation:[self.color mn_saturationComponent]];
	_brightnessView.brightness = [self.color mn_brightnessComponent];
    
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
    if ([textField.text isEqualToString:@""]) {
        [textField setText:@"0"];
    }
	[self updateColorPositionFromRGB];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    if ([textField.text isEqualToString:@""]) {
        [textField setText:@"0"];
    }
	[self updateColorPositionFromRGB];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    [self performSelector:@selector(updateColorPositionFromRGB) withObject:nil afterDelay:0.2f];
    return YES;
}
@end
