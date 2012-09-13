//
//  RGBSCViewController.m
//  REDLEDClient
//
//  Created by Maximilian Christ on 2012-09-08.
//  Copyright (c) 2012 mczonk.de. All rights reserved.
//

#import "RGBSCViewController.h"

#import "MCUDPSocket.h"

#import "RGBStrip.h"
#import "HSBColor.h"

@interface RGBSCViewController () <NSStreamDelegate>

@property (nonatomic, strong) MCUDPSocket* socket;

@end

@implementation RGBSCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
#if 0
	self.hSlider.colors = @[
		UIColor.redColor,
		UIColor.yellowColor,
		UIColor.greenColor,
		UIColor.cyanColor,
		UIColor.blueColor,
		UIColor.magentaColor,
		UIColor.redColor,
	];
	
	self.sSlider.colors = @[
		UIColor.whiteColor,
		UIColor.redColor,
	];
	
	self.bSlider.colors = @[
		UIColor.blackColor,
		UIColor.redColor,
	];
#endif
	
	self.hSlider.value = 0.5f;
	self.sSlider.value = 1.0f;
	self.bSlider.value = 1.0f;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)bindToAddress:(NSData*)address
{
	self.socket = [[MCUDPSocket alloc] initWithAddress:address];
}

- (IBAction)sliderChanged:(id)sender
{
	float h = self.hSlider.value;
	float s = self.sSlider.value;
	float b = self.bSlider.value;

	self.hSlider.colors = @[
		[UIColor colorWithHue:0.0f / 6.0f saturation:s brightness:b alpha:1.0f],
		[UIColor colorWithHue:1.0f / 6.0f saturation:s brightness:b alpha:1.0f],
		[UIColor colorWithHue:2.0f / 6.0f saturation:s brightness:b alpha:1.0f],
		[UIColor colorWithHue:3.0f / 6.0f saturation:s brightness:b alpha:1.0f],
		[UIColor colorWithHue:4.0f / 6.0f saturation:s brightness:b alpha:1.0f],
		[UIColor colorWithHue:5.0f / 6.0f saturation:s brightness:b alpha:1.0f],
		[UIColor colorWithHue:6.0f / 6.0f saturation:s brightness:b alpha:1.0f],
	];
	
	self.sSlider.colors = @[
		[UIColor colorWithHue:h saturation:0.0f brightness:b alpha:1.0f],
		[UIColor colorWithHue:h saturation:1.0f brightness:b alpha:1.0f],
	];
	
	self.bSlider.colors = @[
		[UIColor colorWithHue:h saturation:s brightness:0.0f alpha:1.0f],
		[UIColor colorWithHue:h saturation:s brightness:1.0f alpha:1.0f],
	];

	RGBStripMessageSetRange message;
	message.color = HSBColor(h, s, b);
	
	message.firstLED = self.firstStepper.value;
	message.lastLED = self.lastStepper.value;

	message.animation = 0;
	
	message.fillChecksum();
	
	NSData* data = message;
	
	NSLog(@"%@ success:%d", data, [self.socket sendData:data]);
}

- (IBAction)firstLEDChanged:(id)sender
{
	self.firstTextView.text = [NSString stringWithFormat:@"%.0f", self.firstStepper.value];
}

- (IBAction)lastLEDChanged:(id)sender
{
	self.lastTextView.text = [NSString stringWithFormat:@"%.0f", self.lastStepper.value];
}

@end
