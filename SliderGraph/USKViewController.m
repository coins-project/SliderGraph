//
//  USKViewController.m
//  SliderGraph
//
//  Created by Yusuke Iwama on 11/7/13.
//  Copyright (c) 2013 Yusuke Iwama. All rights reserved.
//

#import "USKViewController.h"

@implementation USKViewController {
	double a, b, c, a2, b2, c2;
	double lastA, lastB, lastC, lastA2, lastB2, lastC2;
	BOOL updating;
	
	BOOL showGrid;
}

@synthesize graphView;
@synthesize equationLabel, equationLabel2;
@synthesize sliderA, sliderB, sliderC, sliderA2, sliderB2, sliderC2;
@synthesize formControl, formControl2;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	
	sliderA.minimumValue = sliderA2.minimumValue = -10.0;
	sliderA.maximumValue = sliderA2.maximumValue = 10.0;
	a = sliderA.value = 1.0;
	a2 = sliderA2.value = 0.0;
	sliderB.minimumValue = sliderB2.minimumValue = -10.0;
	sliderB.maximumValue = sliderB2.maximumValue = 10.0;
	b = sliderB.value = -4.0;
	b2 = sliderB2.value = 1.0;
	sliderC.minimumValue = sliderC2.minimumValue = -10.0;
	sliderC.maximumValue = sliderC2.maximumValue = 10.0;
	c = sliderC.value = 0.0;
	c2 = sliderC2.value = 0.0;
	[sliderA addTarget:self action:@selector(updateEquation:) forControlEvents:UIControlEventValueChanged];
	[sliderB addTarget:self action:@selector(updateEquation:) forControlEvents:UIControlEventValueChanged];
	[sliderC addTarget:self action:@selector(updateEquation:) forControlEvents:UIControlEventValueChanged];
	[sliderA2 addTarget:self action:@selector(updateEquation:) forControlEvents:UIControlEventValueChanged];
	[sliderB2 addTarget:self action:@selector(updateEquation:) forControlEvents:UIControlEventValueChanged];
	[sliderC2 addTarget:self action:@selector(updateEquation:) forControlEvents:UIControlEventValueChanged];
	formControl.selectedSegmentIndex = formControl2.selectedSegmentIndex = 0;
	[formControl addTarget:self action:@selector(drawGraph) forControlEvents:UIControlEventValueChanged];
	[formControl addTarget:self action:@selector(updateLabel:) forControlEvents:UIControlEventValueChanged];
	[formControl2 addTarget:self action:@selector(drawGraph) forControlEvents:UIControlEventValueChanged];
	[formControl2 addTarget:self action:@selector(updateLabel:) forControlEvents:UIControlEventValueChanged];
	[self updateLabel:equationLabel];
	[self updateLabel:equationLabel2];
	
	NSTimer *timer = [NSTimer timerWithTimeInterval:0.03
											 target:self
										   selector:@selector(updateGraphView)
										   userInfo:self
											repeats:YES];
	[[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
	
	showGrid = YES;
	[self drawGraph];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateEquation:(id)sender
{
	if ([sender isEqual:sliderA]) {
		lastA = a;
		a = sliderA.value;
		[self updateLabel:equationLabel];
	} else if ([sender isEqual:sliderB]) {
		lastB = b;
		b = sliderB.value;
		[self updateLabel:equationLabel];
	} else if ([sender isEqual:sliderC]) {
		lastC = c;
		c = sliderC.value;
		[self updateLabel:equationLabel];
	} else if ([sender isEqual:sliderA2]) {
		lastA2 = a2;
		a2 = sliderA2.value;
		[self updateLabel:equationLabel2];
	} else if ([sender isEqual:sliderB2]) {
		lastB2 = b2;
		b2 = sliderB2.value;
		[self updateLabel:equationLabel2];
	} else if ([sender isEqual:sliderC2]) {
		lastC2 = c2;
		c2 = sliderC2.value;
		[self updateLabel:equationLabel2];
	}
}

- (void)updateLabel:(id)label
{
	if ([label isEqual:equationLabel]) {
		if (formControl.selectedSegmentIndex == 0) {
			equationLabel.text = [NSString stringWithFormat:@"y = %+2.2fx^2 %+2.2fx %+2.2f", a, b, c];
		} else {
			equationLabel.text = [NSString stringWithFormat:@"y = %+2.2f(x %+2.2f)^2 %+2.2f", a, b, c];
		}
	} else if ([label isEqual:equationLabel2]) {
		if (formControl2.selectedSegmentIndex == 0) {
			equationLabel2.text = [NSString stringWithFormat:@"y = %+2.2fx^2 %+2.2fx %+2.2f", a2, b2, c2];
		} else {
			equationLabel2.text = [NSString stringWithFormat:@"y = %+2.2f(x %+2.2f)^2 %+2.2f", a2, b2, c2];
		}
	} else if ([label isKindOfClass:[UISegmentedControl class]]) {
		[self updateLabel:equationLabel];
		[self updateLabel:equationLabel2];
	}
}

- (void)updateGraphView
{
	if (updating
		|| (a == lastA && b == lastB && c == lastC && a2 == lastA2 && b2 == lastB2 && c2 == lastC2) ) {
		return;
	} else {
		updating = YES;
		
		[self drawGraph];
		
		lastA = a;
		lastB = b;
		lastC = c;
		lastA2 = a2;
		lastB2 = b2;
		lastC2 = c2;
		updating = NO;
	}
}

- (void)drawGraph
{
	UIGraphicsBeginImageContextWithOptions(graphView.frame.size, YES, 1.0);
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	// axis
	CGColorRef axisColor = [[UIColor whiteColor] CGColor];
	CGContextSetLineWidth(context, 2.0);
	CGContextSetStrokeColorWithColor(context, axisColor);
	CGContextMoveToPoint(context, 0.0, graphView.frame.size.height / 2.0);
	CGContextAddLineToPoint(context, graphView.frame.size.width, graphView.frame.size.height / 2.0);
	CGContextMoveToPoint(context, graphView.frame.size.width / 2.0, 0.0);
	CGContextAddLineToPoint(context, graphView.frame.size.width / 2.0, graphView.frame.size.height);
	CGContextStrokePath(context);
	
	double valuePerPixel = 20.0 / graphView.frame.size.width;
	
	// grid
	CGContextSetLineWidth(context, 0.5);
	CGContextSetStrokeColorWithColor(context, axisColor);
	for (int x = -20; x < 20; x++) {
		int j = x / valuePerPixel + graphView.frame.size.width / 2.0;
		CGContextMoveToPoint(context, j, 0);
		CGContextAddLineToPoint(context, j, graphView.frame.size.height);
	}
	for (int y = -20; y < 20; y++) {
		int i = y / valuePerPixel + graphView.frame.size.height / 2.0;
		CGContextMoveToPoint(context, 0, i);
		CGContextAddLineToPoint(context, graphView.frame.size.width, i);
	}
	CGContextStrokePath(context);
	
	// plot 1
	CGColorRef plotColor = [[UIColor greenColor] CGColor];
	CGContextSetLineWidth(context, 4.0);
	switch (formControl.selectedSegmentIndex) {
		case 0: // general form
			CGContextMoveToPoint(context, 0, -((a * pow(-10, 2) + b * (-10) + c) / valuePerPixel) + graphView.frame.size.height / 2.0);
			for (int j = 1; j <= graphView.frame.size.width; j += 2) {
				double x = (double)j / graphView.frame.size.width * 20.0 - 10;
				double y = a * pow(x, 2) + b * (x) + c;
				int i = -(y / valuePerPixel) + graphView.frame.size.height / 2.0;
				CGContextAddLineToPoint(context, j, i);
			}
			CGContextSetStrokeColorWithColor(context, plotColor);
			CGContextStrokePath(context);
			break;
		case 1: // standard form
			CGContextMoveToPoint(context, 0, -((a * pow((-10 + b), 2) + c) / valuePerPixel) + graphView.frame.size.height / 2.0);
			for (int j = 1; j <= graphView.frame.size.width; j += 2) {
				double x = (double)j / graphView.frame.size.width * 20.0 - 10;
				double y = a * pow((x + b), 2) + c;
				int i = -(y / valuePerPixel) + graphView.frame.size.height / 2.0;
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

	
	// plot 2
	CGColorRef plotColor2 = [[UIColor redColor] CGColor];
	CGContextSetLineWidth(context, 4.0);
	switch (formControl2.selectedSegmentIndex) {
		case 0: // general form
		{
			CGContextMoveToPoint(context, 0, -((a2 * pow(-10, 2) + b2 * (-10) + c2) / valuePerPixel) + graphView.frame.size.height / 2.0);
			for (int j = 1; j <= graphView.frame.size.width; j += 2) {
				double x = (double)j / graphView.frame.size.width * 20.0 - 10;
				double y = a2 * pow(x, 2) + b2 * (x) + c2;
				int i = -(y / valuePerPixel) + graphView.frame.size.height / 2.0;
				CGContextAddLineToPoint(context, j, i);
			}
			CGContextSetStrokeColorWithColor(context, plotColor2);
			CGContextStrokePath(context);
			break;
		}
		case 1:
		{ // standard form
			CGContextMoveToPoint(context, 0, -((a2 * pow((-10 + b2), 2) + c2) / valuePerPixel) + graphView.frame.size.height / 2.0);
			for (int j = 1; j <= graphView.frame.size.width; j += 2) {
				double x = (double)j / graphView.frame.size.width * 20.0 - 10;
				double y = a2 * pow((x + b2), 2) + c2;
				int i = -(y / valuePerPixel) + graphView.frame.size.height / 2.0;
				CGContextAddLineToPoint(context, j, i);
			}
			CGContextSetStrokeColorWithColor(context, plotColor2);
			CGContextStrokePath(context);
			break;
		}
		default:
			break;
			
	}
	CGContextSetStrokeColorWithColor(context, plotColor);
	CGContextStrokePath(context);


	
	graphView.image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	[self drawGraph];
}

@end
