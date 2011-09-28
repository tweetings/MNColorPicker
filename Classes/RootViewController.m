//
//  RootViewController.m
//  MNColorPicker
//

#import "RootViewController.h"

@implementation RootViewController


- (IBAction)showColorPicker {
	MNColorPicker *colorPicker = [[MNColorPicker alloc] init];
	colorPicker.delegate = self;
	colorPicker.color = self.view.backgroundColor;
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:colorPicker];
	[colorPicker release], colorPicker = nil;
	[self presentModalViewController:navigationController animated:YES];
	[navigationController release], navigationController = nil;
}


#pragma mark -
#pragma mark MNColorPickerDelegate

- (void)colorPicker:(MNColorPicker*)colorPicker didFinishWithColor:(UIColor *)color {
	[self dismissModalViewControllerAnimated:YES];
	if (color) {
		self.view.backgroundColor = color;	
	}
}

- (void)colorPickerViewControllerCleared:(MNColorPicker*)colorPicker {
    [self dismissModalViewControllerAnimated:YES];
    self.view.backgroundColor = [UIColor clearColor];
}

@end

