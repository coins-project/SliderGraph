//
//  USKViewController.m
//  SliderGraph
//
//  Created by Yusuke Iwama on 11/7/13.
//  Copyright (c) 2013 Yusuke Iwama. All rights reserved.
//

#import "USKViewController.h"

#define NUMBER_OF_GRAPHS 5
#define PARAM_A 0
#define PARAM_B 1
#define PARAM_C 2
#define PARAM_K 3
#define PARAM_P 4
#define PARAM_Q 5
#define FORM 6
#define DISPLAY 7
#define GENERAL_FORM 0
#define STANDARD_FORM 1

@implementation USKViewController {
	BOOL updating;
	BOOL showGrid;
	
	double a, b, c, k, p, q, A, B, C, K, P, Q; // lower case ... current parameters // upper case ... last parameters
	BOOL form, display;
	
	double parameters[NUMBER_OF_GRAPHS][8]; // 6 ... a, b, c, k, p, q, form, display,
	NSUInteger currentGraphNumber;

}

@synthesize keyboardView;
@synthesize displaySwitch;
@synthesize generalFormView, standardFormView;
@synthesize fieldA, fieldB, fieldC, fieldK, fieldP, fieldQ;
@synthesize slider1, slider2, slider3;
@synthesize formControl;
@synthesize graphControl;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	
//	displaySwitch.transform = CGAffineTransformMakeRotation(-M_PI_2);
	
	[graphControl addTarget:self action:@selector(switchGraphs:) forControlEvents:UIControlEventValueChanged];
	[self switchGraphs:graphControl];
	
	slider1.minimumValue = -10.0;
	slider1.maximumValue = 10.0;
	slider2.minimumValue = -10.0;
	slider2.maximumValue = 10.0;
	slider3.minimumValue = -10.0;
	slider3.maximumValue = 10.0;
	[slider1 addTarget:self action:@selector(updateEquation:) forControlEvents:UIControlEventValueChanged];
	[slider2 addTarget:self action:@selector(updateEquation:) forControlEvents:UIControlEventValueChanged];
	[slider3 addTarget:self action:@selector(updateEquation:) forControlEvents:UIControlEventValueChanged];
	[formControl addTarget:self action:@selector(changeForm:) forControlEvents:UIControlEventValueChanged];
	
	// set default value
	a = slider1.value = 1.0;
	b = slider2.value = 0.0;
	c = slider3.value = 0.0;
	form = GENERAL_FORM;
	displaySwitch.on = display = YES;
	formControl.selectedSegmentIndex = 0;
	[self changeForm:formControl];
	for (int i = 1; i < NUMBER_OF_GRAPHS; i++) {
		parameters[i][DISPLAY] = NO;
	}
	
	// prepare keyboard
	NSArray *keyTopTitles = @[@"0", @"1", @"2", @"3", @"4", @".", @"x", @"5", @"6", @"7", @"8", @"9", @"OK", @"OK"];
	NSArray *mergeInfo = @[@[@12,@13]];
	[keyboardView updateButtonsWithRow:2 column:7 titles:keyTopTitles outCharacters:@"01234.x56789kk" mergeInfo:mergeInfo style:COINSKeyboardStyleiOS7];
	keyboardView.hidden = YES; // DEBUG
	
	
	NSTimer *timer = [NSTimer timerWithTimeInterval:0.03
											 target:self
										   selector:@selector(updateGraphView)
										   userInfo:self
											repeats:YES];
	[[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
	
	showGrid = YES;
	
	[self forceUpdateEquation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{ // draw in case the orientation is landscape
	[self drawSubGraph];
	[self drawMainGraph];
}

- (void)changeForm:(id)sender
{
	switch (((UISegmentedControl *)sender).selectedSegmentIndex) {
		case 0:
			form = GENERAL_FORM;
			generalFormView.alpha = 1.0;
			generalFormView.userInteractionEnabled = YES;
			standardFormView.alpha = 0.0;
			standardFormView.userInteractionEnabled = NO;
			slider1.value = a;
			slider2.value = b;
			slider3.value = c;
			break;
		case 1:
			form = STANDARD_FORM;
			generalFormView.alpha = 0.0;
			generalFormView.userInteractionEnabled = NO;
			standardFormView.alpha = 1.0;
			standardFormView.userInteractionEnabled = YES;
			slider1.value = k;
			slider2.value = p;
			slider3.value = q;
		default:
			break;
	}
	[self drawMainGraph];
}

- (void)switchGraphs:(id)sender
{
	// save current graph parameters
	parameters[currentGraphNumber][PARAM_A] = a;
	parameters[currentGraphNumber][PARAM_B] = b;
	parameters[currentGraphNumber][PARAM_C] = c;
	parameters[currentGraphNumber][PARAM_K] = k;
	parameters[currentGraphNumber][PARAM_P] = p;
	parameters[currentGraphNumber][PARAM_Q] = q;
	parameters[currentGraphNumber][FORM] = form;
	parameters[currentGraphNumber][DISPLAY] = display;
	
	// switch current graph
	currentGraphNumber = ((UISegmentedControl *)sender).selectedSegmentIndex;
	[self drawSubGraph];
	
	// set appearance
	UIColor *tintColor = [UIColor colorWithHue:((double)currentGraphNumber / NUMBER_OF_GRAPHS) saturation:1.0 brightness:0.7 alpha:1.0];
	[displaySwitch setOnTintColor:tintColor];
	NSArray *subViews = [self.controlView subviews];
	for (UIView *aSubView in subViews) {
		if ([aSubView isEqual:graphControl]) {
			continue;
		}
		if ([aSubView respondsToSelector:@selector(setTintColor:)]) {
			[aSubView setTintColor:tintColor];
		}
	}
	subViews = [generalFormView subviews];
	for (UILabel *aSubView in subViews) {
		if ([aSubView respondsToSelector:@selector(setTextColor:)]) {
			[aSubView setTextColor:tintColor];
		}
	}
	subViews = [standardFormView subviews];
	for (UILabel *aSubView in subViews) {
		if ([aSubView respondsToSelector:@selector(setTextColor:)]) {
			[aSubView setTextColor:tintColor];
		}
	}
	
	// fetch next graph parameters
	a = parameters[currentGraphNumber][PARAM_A];
	b = parameters[currentGraphNumber][PARAM_B];
	c = parameters[currentGraphNumber][PARAM_C];
	k = parameters[currentGraphNumber][PARAM_K];
	p = parameters[currentGraphNumber][PARAM_P];
	q = parameters[currentGraphNumber][PARAM_Q];
	form = parameters[currentGraphNumber][FORM];
	display = parameters[currentGraphNumber][DISPLAY];
	
	// set fields
	fieldA.text = [NSString stringWithFormat:@"%2.2f", a];
	fieldB.text = [NSString stringWithFormat:@"%+2.2f", b];
	fieldC.text = [NSString stringWithFormat:@"%+2.2f", c];
	fieldK.text = [NSString stringWithFormat:@"%2.2f", k];
	fieldP.text = [NSString stringWithFormat:@"%+2.2f", p];
	fieldQ.text = [NSString stringWithFormat:@"%+2.2f", q];
	
	// set sliders
	slider1.value = a;
	slider2.value = b;
	slider3.value = c;
	
	// set formControl
	formControl.selectedSegmentIndex = form;
	[self changeForm:formControl];
	displaySwitch.on = display;
	
	[self drawMainGraph];
}

- (void)updateEquation:(id)sender
{
	switch (formControl.selectedSegmentIndex) {
		case 0:
			if ([sender isEqual:slider1]) {
				A = a;
				a = slider1.value;
				fieldA.text = [NSString stringWithFormat:@"%2.2f", a];
			} else if ([sender isEqual:slider2]) {
				B = b;
				b = slider2.value;
				fieldB.text = [NSString stringWithFormat:@"%+2.2f", b];
			} else if ([sender isEqual:slider3]) {
				C = c;
				c = slider3.value;
				fieldC.text = [NSString stringWithFormat:@"%+2.2f", c];
			}
			break;
		case 1:
			if ([sender isEqual:slider1]) {
				K = k;
				k = slider1.value;
				fieldK.text = [NSString stringWithFormat:@"%2.2f", k];
			} else if ([sender isEqual:slider2]) {
				P = p;
				p = slider2.value;
				fieldP.text = [NSString stringWithFormat:@"%+2.2f", p];
			} else if ([sender isEqual:slider3]) {
				Q = q;
				q = slider3.value;
				fieldQ.text = [NSString stringWithFormat:@"%+2.2f", q];
			}
			break;
		default:
			break;
	}
}

- (void)forceUpdateEquation
{
		a = slider1.value;
		fieldA.text = [NSString stringWithFormat:@"%2.2f", a];
		b = slider2.value;
		fieldB.text = [NSString stringWithFormat:@"%+2.2f", b];
		c = slider3.value;
		fieldC.text = [NSString stringWithFormat:@"%+2.2f", c];
		k = slider1.value;
		fieldK.text = [NSString stringWithFormat:@"%2.2f", k];
		p = slider2.value;
		fieldP.text = [NSString stringWithFormat:@"%+2.2f", p];
		q = slider3.value;
		fieldQ.text = [NSString stringWithFormat:@"%+2.2f", q];
}

- (void)updateGraphView
{
	if (updating
		|| (a == A && b == B && c == C && k == K && p == P && q == Q) ) {
		return;
	} else {
		updating = YES;
		
		[self drawMainGraph];
		
		A = a;
		B = b;
		C = c;
		K = k;
		P = p;
		Q = q;
		updating = NO;
	}
}

- (void)drawMainGraph
{
	UIGraphicsBeginImageContextWithOptions(self.mainGraphView.frame.size, NO, 0.0);
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	double valuePerPixel = 20.0 / self.mainGraphView.frame.size.width;
	int xInterval = 2;

	CGColorRef plotColor;
	if (display) {
		plotColor = [[UIColor colorWithHue:(double)currentGraphNumber / NUMBER_OF_GRAPHS saturation:1.0 brightness:1.0 alpha:1.0] CGColor];
	} else {
		plotColor = [[UIColor colorWithHue:(double)currentGraphNumber / NUMBER_OF_GRAPHS saturation:1.0 brightness:1.0 alpha:0.5] CGColor];
	}
	

	CGContextSetLineWidth(context, 4.0);
	switch (formControl.selectedSegmentIndex) {
		case 0: // general form
			CGContextMoveToPoint(context, 0, -((a * pow(-10, 2) + b * (-10) + c) / valuePerPixel) + self.mainGraphView.frame.size.height / 2.0);
			for (int j = 1; j <= self.mainGraphView.frame.size.width; j += xInterval) {
				double x = (double)j / self.mainGraphView.frame.size.width * 20.0 - 10;
				double y = a * pow(x, 2) + b * (x) + c;
				double i = -(y / valuePerPixel) + self.mainGraphView.frame.size.height / 2.0;
				CGContextAddLineToPoint(context, j, i);
			}
			CGContextSetStrokeColorWithColor(context, plotColor);
			CGContextStrokePath(context);
			break;
		case 1: // standard form
			CGContextMoveToPoint(context, 0, -((k * pow((-10 + p), 2) + q) / valuePerPixel) + self.mainGraphView.frame.size.height / 2.0);
			for (int j = 1; j <= self.mainGraphView.frame.size.width; j += xInterval) {
				double x = (double)j / self.mainGraphView.frame.size.width * 20.0 - 10;
				double y = k * pow((x + p), 2) + q;
				double i = -(y / valuePerPixel) + self.mainGraphView.frame.size.height / 2.0;
				CGContextAddLineToPoint(context, j, i);
			}
			CGContextSetStrokeColorWithColor(context, plotColor);
			CGContextStrokePath(context);
			break;
		default:
			break;
	}
	CGContextSetStrokeColorWithColor(context, plotColor);
	CGContextStrokePath(context);
	
	self.mainGraphView.image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
}

- (void)drawSubGraph
{
	UIGraphicsBeginImageContextWithOptions(self.subGraphView.frame.size, YES, 0.0);
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	// axis
	CGColorRef axisColor = [[UIColor whiteColor] CGColor];
	CGContextSetLineWidth(context, 2.0);
	CGContextSetStrokeColorWithColor(context, axisColor);
	CGContextMoveToPoint(context, 0.0, self.subGraphView.frame.size.height / 2.0);
	CGContextAddLineToPoint(context, self.subGraphView.frame.size.width, self.subGraphView.frame.size.height / 2.0);
	CGContextMoveToPoint(context, self.subGraphView.frame.size.width / 2.0, 0.0);
	CGContextAddLineToPoint(context, self.subGraphView.frame.size.width / 2.0, self.subGraphView.frame.size.height);
	CGContextStrokePath(context);
	
	double valuePerPixel = 20.0 / self.subGraphView.frame.size.width;
	
	// grid
	CGContextSetLineWidth(context, 0.5);
	CGContextSetStrokeColorWithColor(context, axisColor);
	for (int x = -20; x < 20; x++) {
		int j = x / valuePerPixel + self.subGraphView.frame.size.width / 2.0;
		CGContextMoveToPoint(context, j, 0);
		CGContextAddLineToPoint(context, j, self.subGraphView.frame.size.height);
	}
	for (int y = -20; y < 20; y++) {
		int i = y / valuePerPixel + self.subGraphView.frame.size.height / 2.0;
		CGContextMoveToPoint(context, 0, i);
		CGContextAddLineToPoint(context, self.subGraphView.frame.size.width, i);
	}
	CGContextStrokePath(context);
	
	// plot general setting
	int xInterval = 2;
	
	// draw graphs
	double tempA, tempB, tempC, tempK, tempP, tempQ;
	for (int i = 0; i < NUMBER_OF_GRAPHS; i++) {
		if (i == currentGraphNumber
			|| parameters[i][DISPLAY] == NO) {
			continue;
		}
		CGColorRef plotColor = [[UIColor colorWithHue:(double)i / NUMBER_OF_GRAPHS saturation:1.0 brightness:1.0 alpha:1.0] CGColor];
		CGContextSetLineWidth(context, 4.0);
		switch ((int)(parameters[i][FORM])) {
			case GENERAL_FORM: // general form
				tempA = parameters[i][PARAM_A];
				tempB = parameters[i][PARAM_B];
				tempC = parameters[i][PARAM_C];
				CGContextMoveToPoint(context, 0, -((tempA * pow(-10, 2) + tempB * (-10) + tempC) / valuePerPixel) + self.mainGraphView.frame.size.height / 2.0);
				for (int j = 1; j <= self.mainGraphView.frame.size.width; j += xInterval) {
					double x = (double)j / self.mainGraphView.frame.size.width * 20.0 - 10;
					double y = tempA * pow(x, 2) + tempB * (x) + tempC;
					double i = -(y / valuePerPixel) + self.mainGraphView.frame.size.height / 2.0;
					CGContextAddLineToPoint(context, j, i);
				}
				CGContextSetStrokeColorWithColor(context, plotColor);
				CGContextStrokePath(context);
				break;
			case STANDARD_FORM: // standard form
				tempK = parameters[i][PARAM_K];
				tempP = parameters[i][PARAM_P];
				tempQ = parameters[i][PARAM_Q];
				CGContextMoveToPoint(context, 0, -((tempK * pow((-10 + tempP), 2) + tempQ) / valuePerPixel) + self.mainGraphView.frame.size.height / 2.0);
				for (int j = 1; j <= self.mainGraphView.frame.size.width; j += xInterval) {
					double x = (double)j / self.mainGraphView.frame.size.width * 20.0 - 10;
					double y = tempK * pow((x + tempP), 2) + tempQ;
					double i = -(y / valuePerPixel) + self.mainGraphView.frame.size.height / 2.0;
					CGContextAddLineToPoint(context, j, i);
				}
				CGContextSetStrokeColorWithColor(context, plotColor);
				CGContextStrokePath(context);
				break;
			default:
				break;
				
		}
		CGContextSetStrokeColorWithColor(context, plotColor);
		CGContextStrokePath(context);
	}
	
	self.subGraphView.image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	[keyboardView updateButtonsWithRow:keyboardView.row column:keyboardView.column titles:keyboardView.titles outCharacters:keyboardView.outCharacters mergeInfo:keyboardView.mergeInfo style:keyboardView.style];
	[self drawSubGraph];
	[self drawMainGraph];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	[UIView animateWithDuration:0.3 animations:^{
		self.controlView.frame = CGRectMake(self.controlView.frame.origin.x, self.controlView.frame.origin.y - 200, self.controlView.frame.size.width, self.controlView.frame.size.height);
	}];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	
	[UIView animateWithDuration:0.3 animations:^{
		self.controlView.frame = CGRectMake(self.controlView.frame.origin.x, self.controlView.frame.origin.y + 200, self.controlView.frame.size.width, self.controlView.frame.size.height);
	}];
		
	if ([textField isEqual:fieldA]) {
		A = a;
		a = [textField.text doubleValue];
		slider1.value = a;
		[self updateEquation:slider1];
	} else if ([textField isEqual:fieldB]) {
		B = b;
		b = [textField.text doubleValue];
		slider2.value = b;
		[self updateEquation:slider2];
	} else if ([textField isEqual:fieldC]) {
		C = c;
		c = [textField.text doubleValue];
		slider3.value = c;
		[self updateEquation:slider3];
	} else if ([textField isEqual:fieldK]) {
		K = k;
		k = [textField.text doubleValue];
		slider1.value = k;
		[self updateEquation:slider1];
	} else if ([textField isEqual:fieldP]) {
		P = p;
		p = [textField.text doubleValue];
		slider2.value = p;
		[self updateEquation:slider2];
	} else if ([textField isEqual:fieldQ]) {
		Q = q;
		q = [textField.text doubleValue];
		slider3.value = q;
		[self updateEquation:slider3];
	}
	[self drawMainGraph];
	return YES;
}

- (IBAction)changeDisplay:(id)sender {
	UISwitch *aSwitch = sender;
	display = aSwitch.on;
	[self drawMainGraph];
}

@end
