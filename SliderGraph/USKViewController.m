//
//  USKViewController.m
//  SliderGraph
//
//  Created by Yusuke Iwama on 11/7/13.
//  Copyright (c) 2013 Yusuke Iwama. All rights reserved.
//

#import "USKViewController.h"

@implementation USKViewController {
	double a, b, c;
	double lastA, lastB, lastC;
	BOOL updating;
	
	BOOL showGrid;
}

@synthesize graphView;
@synthesize sliderA, sliderB, sliderC;
@synthesize formControl;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	
	sliderA.minimumValue = -10.0;
	sliderA.maximumValue = 10.0;
	sliderA.value = 0.0;
	sliderB.minimumValue = -10.0;
	sliderB.maximumValue = 10.0;
	sliderB.value = 0.0;
	sliderC.minimumValue = -10.0;
	sliderC.maximumValue = 10.0;
	sliderC.value = 0.0;
	[sliderA addTarget:self action:@selector(updateEquation:) forControlEvents:UIControlEventValueChanged];
	[sliderB addTarget:self action:@selector(updateEquation:) forControlEvents:UIControlEventValueChanged];
	[sliderC addTarget:self action:@selector(updateEquation:) forControlEvents:UIControlEventValueChanged];
	
	formControl.selectedSegmentIndex = 0;
	[formControl addTarget:self action:@selector(drawGraph) forControlEvents:UIControlEventValueChanged];
	
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
	} else if ([sender isEqual:sliderB]) {
		lastB = b;
		b = sliderB.value;
	} else if ([sender isEqual:sliderC]) {
		lastC = c;
		c = sliderC.value;
	}
}

- (void)updateGraphView
{
	if (updating
		|| (a == lastA && b == lastB && c == lastC)) {
		return;
	} else {
		updating = YES;
		
		[self drawGraph];
		
		lastA = a;
		lastB = b;
		lastC = c;
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
	
	// plot
	CGColorRef plotColor = [[UIColor yellowColor] CGColor];
	CGContextSetLineWidth(context, 4.0);
	switch (formControl.selectedSegmentIndex) {
		case 0:
		{
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
		}
		case 1:
		{
			double k = 0.2;
			CGContextMoveToPoint(context, 0, -((k * pow((-10 - a), 2) + b) / valuePerPixel) + graphView.frame.size.height / 2.0);
			for (int j = 1; j <= graphView.frame.size.width; j += 2) {
				double x = (double)j / graphView.frame.size.width * 20.0 - 10;
				double y = k * pow((x - a), 2) + b;
				int i = -(y / valuePerPixel) + graphView.frame.size.height / 2.0;
				CGContextAddLineToPoint(context, j, i);
			}
			CGContextSetStrokeColorWithColor(context, plotColor);
			CGContextStrokePath(context);
			break;
		}
		default:
			break;
	}
	CGContextMoveToPoint(context, 0, -10.0 / valuePerPixel + graphView.frame.size.height / 2.0);
	for (int j = 1; j <= graphView.frame.size.width; j+= 2) {
		double x = (double)j / graphView.frame.size.width * 20.0 - 10.0;
		double y = x;
		int i = -(y / valuePerPixel) + graphView.frame.size.height / 2.0;
		CGContextAddLineToPoint(context, j, i);
	}
	CGContextSetStrokeColorWithColor(context, plotColor);
	CGContextStrokePath(context);


	
	graphView.image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
}

@end
