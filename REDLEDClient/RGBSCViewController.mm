//
//  RGBSCViewController.m
//  REDLEDClient
//
//  Created by Maximilian Christ on 2012-09-08.
//  Copyright (c) 2012 mczonk.de. All rights reserved.
//

#import "RGBSCViewController.h"

#import "MCUDPSocket.h"

#import "ColorMessage.h"
#import "ColorArrayMessage.h"
#import "ColorListMessage.h"


@interface RGBSCViewController () <NSNetServiceDelegate>

@property (nonatomic, strong) NSNetService* netService;
@property (nonatomic, strong) MCUDPSocket* socket;

@property (nonatomic, assign) NSUInteger ledCount;

@end

@implementation RGBSCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
		
	self.hSlider.value = 0.5f;
	self.sSlider.value = 1.0f;
	self.bSlider.value = 1.0f;
	
	self.rangeSlider.maximumRange = NSMakeRange(0, self.ledCount);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)bindToNetService:(NSNetService*)netService
{
	if(self.netService.delegate == self)
	{
		self.netService.delegate = nil;
	}
	
	self.netService = netService;
	self.netService.delegate = self;
	
	self.title = self.netService.name;
	
	NSData* address = [self.netService.addresses objectAtIndex:0];
	
	self.socket = [[MCUDPSocket alloc] initWithAddress:address];
	
	NSDictionary* txtRecord = [NSNetService dictionaryFromTXTRecordData:self.netService.TXTRecordData];
	
	{
		NSData* ledsData = [txtRecord objectForKey:@"leds"];
		
		NSString* ledsString = [[NSString alloc] initWithData:ledsData encoding:NSASCIIStringEncoding];
		
		self.ledCount = ledsString.integerValue;
		
		NSLog(@"leds: %u", self.ledCount);
	}
	
#if 0
	// Test random colors
	
	NSMutableData* data = [NSMutableData dataWithLength:RGBStrip::ColorArrayMessage::size(56)];
	
	RGBStrip::ColorArrayMessage& message = *(RGBStrip::ColorArrayMessage*)data.mutableBytes;
	
	message.fillHeader(56);
	
	message.offset = 0;
	message.count = 56;

	for(NSUInteger index = 0; index < 56; ++index)
	{
		message.colors[index] = HSBColor((uint16_t)(rand() % 1536), (uint8_t)(rand() % 255), (uint8_t)(rand() % 256));
	}
	
	NSLog(@"%@ success:%d", data, [self.socket sendData:data]);
#elif 1
	// Test list
	
	NSMutableData* data = [NSMutableData dataWithLength:RGBStrip::ColorListMessage::size(7)];
	
	RGBStrip::ColorListMessage& message = *(RGBStrip::ColorListMessage*)data.mutableBytes;
	
	message.fillHeader(7);
	
	message.offset = 0;
	message.count = 7;

	message.keys[0].index = 0;
	message.keys[0].color = HSBColor((uint16_t)   0, (uint8_t)255, (uint8_t)255);

	message.keys[1].index = 8;
	message.keys[1].color = HSBColor((uint16_t) 256, (uint8_t)255, (uint8_t)255);

	message.keys[2].index = 16;
	message.keys[2].color = HSBColor((uint16_t) 512, (uint8_t)255, (uint8_t)255);

	message.keys[3].index = 32;
	message.keys[3].color = HSBColor((uint16_t) 768, (uint8_t)255, (uint8_t)255);

	message.keys[4].index = 40;
	message.keys[4].color = HSBColor((uint16_t)1024, (uint8_t)255, (uint8_t)255);

	message.keys[5].index = 48;
	message.keys[5].color = HSBColor((uint16_t)1280, (uint8_t)255, (uint8_t)255);

	message.keys[6].index = 55;
	message.keys[6].color = HSBColor((uint16_t)1536 - 32, (uint8_t)255, (uint8_t)255);

	NSLog(@"%@ success:%d", data, [self.socket sendData:data]);
#endif
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
	
	NSMutableData* data = [NSMutableData dataWithLength:RGBStrip::ColorMessage::size()];
	
	RGBStrip::ColorMessage& message = *(RGBStrip::ColorMessage*)data.mutableBytes;

	message.fillHeader();
	
	message.offset = self.rangeSlider.value.location;
	message.count = self.rangeSlider.value.length;
	
	message.color = HSBColor(h, s, b);
	
	NSLog(@"%@ success:%d", data, [self.socket sendData:data]);
}

- (IBAction)ledRangeChanged:(id)sender
{
	self.firstTextView.text = [NSString stringWithFormat:@"%d", self.rangeSlider.value.location+1];
	self.lastTextView.text = [NSString stringWithFormat:@"%d", NSMaxRange(self.rangeSlider.value)];
}



#pragma mark - NSNetServiceDelegate

- (void)netServiceDidStop:(NSNetService *)sender
{
//	[self.navigationController popViewControllerAnimated:YES];
}

- (void)netService:(NSNetService *)sender didUpdateTXTRecordData:(NSData *)data
{
	
}


@end
