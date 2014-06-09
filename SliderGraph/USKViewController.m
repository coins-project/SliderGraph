//
//  USKViewController.m
//  SliderGraph
//
//  Created by Yusuke Iwama on 11/7/13.
//  Copyright (c) 2013 Yusuke Iwama. All rights reserved.
//

#import "USKViewController.h"
#import "UTPopoverContext.h"
#import "UTNumPadViewController.h"

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

@interface USKViewController () <UTNumPadViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *mainGraphView; // display editing graph
@property (weak, nonatomic) IBOutlet UIImageView *subGraphView; // display the others graph, axis and grid.

@property (weak, nonatomic) IBOutlet UIView *controlView;

@property COINSKeyboard *keyboardView;
@property (weak, nonatomic) IBOutlet UISwitch *displaySwitch; // display or hide

@property (weak, nonatomic) IBOutlet UIView *generalFormView;
@property (weak, nonatomic) IBOutlet UIView *standardFormView;

@property (weak, nonatomic) IBOutlet UIView *varView1;
@property (weak, nonatomic) IBOutlet UILabel *varLabel1;
@property (weak, nonatomic) IBOutlet UIButton *varButton1;

@property (weak, nonatomic) IBOutlet UIView *varView2;
@property (weak, nonatomic) IBOutlet UILabel *varLabel2;
@property (weak, nonatomic) IBOutlet UIButton *varButton2;

@property (weak, nonatomic) IBOutlet UIView *varView3;
@property (weak, nonatomic) IBOutlet UILabel *varLabel3;
@property (weak, nonatomic) IBOutlet UIButton *varButton3;


@property (weak, nonatomic) IBOutlet UITextField *fieldK;
@property (weak, nonatomic) IBOutlet UITextField *fieldP;
@property (weak, nonatomic) IBOutlet UITextField *fieldQ;

@property (weak, nonatomic) IBOutlet UISlider *slider1;
@property (weak, nonatomic) IBOutlet UISlider *slider2;
@property (weak, nonatomic) IBOutlet UISlider *slider3;
@property (weak, nonatomic) IBOutlet UISegmentedControl *formControl;


@property (weak, nonatomic) IBOutlet UISegmentedControl *graphControl;


@end

@implementation USKViewController {
	BOOL _updating;
	BOOL _showGrid;
	
	double _a, _b, _c, _k, _p, _q, _A, _B, _C, _K, _P, _Q; // lower case ... current parameters // upper case ... last parameters
	BOOL form, display;
	
	double _parameters[NUMBER_OF_GRAPHS][8]; // 6 ... a, b, c, k, p, q, form, display,
	NSUInteger _currentGraphNumber;
    
    UILabel *_currentSelectedLabel;
}

@synthesize generalFormView, standardFormView;
@synthesize fieldK, fieldP, fieldQ;
@synthesize slider1, slider2, slider3;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	
//	self.displaySwitch.transform = CGAffineTransformMakeRotation(-M_PI_2);
	
	[self.graphControl addTarget:self action:@selector(switchGraphs:) forControlEvents:UIControlEventValueChanged];
	[self switchGraphs:self.graphControl];
	
	slider1.minimumValue = -10.0;
	slider1.maximumValue = 10.0;
	slider2.minimumValue = -10.0;
	slider2.maximumValue = 10.0;
	slider3.minimumValue = -10.0;
	slider3.maximumValue = 10.0;
	[slider1 addTarget:self action:@selector(updateEquation:) forControlEvents:UIControlEventValueChanged];
	[slider2 addTarget:self action:@selector(updateEquation:) forControlEvents:UIControlEventValueChanged];
	[slider3 addTarget:self action:@selector(updateEquation:) forControlEvents:UIControlEventValueChanged];
	[self.formControl addTarget:self action:@selector(changeForm:) forControlEvents:UIControlEventValueChanged];
	
	// set default value
	_a = slider1.value = 1.0;
	_b = slider2.value = 0.0;
	_c = slider3.value = 0.0;
	form = GENERAL_FORM;
	self.displaySwitch.on = display = YES;
	self.formControl.selectedSegmentIndex = 0;
	[self changeForm:self.formControl];
	for (int i = 1; i < NUMBER_OF_GRAPHS; i++) {
		_parameters[i][DISPLAY] = NO;
	}
	
	// prepare keyboard
//	self.keyboardView = [[COINSKeyboard alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 200)];
//	NSArray *keyTopTitles = @[@"0", @"1", @"2", @"3", @"4", @".", @"x", @"5", @"6", @"7", @"8", @"9", @"OK", @"OK"];
//	NSArray *mergeInfo = @[@[@12,@13]];
//	[self.keyboardView updateButtonsWithRow:2 column:7 titles:keyTopTitles outCharacters:@"01234.x56789kk" style:COINSKeyboardStyleiOS7];
//	[self.keyboardView mergeButtons:mergeInfo];
////	self.keyboardView.hidden = YES; // DEBUG
//	fieldA.inputView = self.keyboardView;
	
	
	NSTimer *timer = [NSTimer timerWithTimeInterval:0.03
											 target:self
										   selector:@selector(updateGraphView)
										   userInfo:self
											repeats:YES];
	[[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
	
	_showGrid = YES;
	
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
			slider1.value = _a;
			slider2.value = _b;
			slider3.value = _c;
			break;
		case 1:
			form = STANDARD_FORM;
			generalFormView.alpha = 0.0;
			generalFormView.userInteractionEnabled = NO;
			standardFormView.alpha = 1.0;
			standardFormView.userInteractionEnabled = YES;
			slider1.value = _k;
			slider2.value = _p;
			slider3.value = _q;
		default:
			break;
	}
	[self drawMainGraph];
}

- (void)switchGraphs:(id)sender
{
	// save current graph parameters
	_parameters[_currentGraphNumber][PARAM_A] = _a;
	_parameters[_currentGraphNumber][PARAM_B] = _b;
	_parameters[_currentGraphNumber][PARAM_C] = _c;
	_parameters[_currentGraphNumber][PARAM_K] = _k;
	_parameters[_currentGraphNumber][PARAM_P] = _p;
	_parameters[_currentGraphNumber][PARAM_Q] = _q;
	_parameters[_currentGraphNumber][FORM] = form;
	_parameters[_currentGraphNumber][DISPLAY] = display;
	
	// switch current graph
	_currentGraphNumber = ((UISegmentedControl *)sender).selectedSegmentIndex;
	[self drawSubGraph];
	
	// set appearance
	UIColor *tintColor = [UIColor colorWithHue:((double)_currentGraphNumber / NUMBER_OF_GRAPHS) saturation:1.0 brightness:0.7 alpha:1.0];
	[self.displaySwitch setOnTintColor:tintColor];
	NSArray *subViews = [self.controlView subviews];
	for (UIView *aSubView in subViews) {
		if ([aSubView isEqual:self.graphControl]) {
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
	_a = _parameters[_currentGraphNumber][PARAM_A];
	_b = _parameters[_currentGraphNumber][PARAM_B];
	_c = _parameters[_currentGraphNumber][PARAM_C];
	_k = _parameters[_currentGraphNumber][PARAM_K];
	_p = _parameters[_currentGraphNumber][PARAM_P];
	_q = _parameters[_currentGraphNumber][PARAM_Q];
	form = _parameters[_currentGraphNumber][FORM];
	display = _parameters[_currentGraphNumber][DISPLAY];
	
	// set fields
	self.varLabel1.text = [NSString stringWithFormat:@"%2.2f", _a];
	self.varLabel2.text = [NSString stringWithFormat:@"%+2.2f", _b];
	self.varLabel3.text = [NSString stringWithFormat:@"%+2.2f", _c];
	fieldK.text = [NSString stringWithFormat:@"%2.2f", _k];
	fieldP.text = [NSString stringWithFormat:@"%+2.2f", _p];
	fieldQ.text = [NSString stringWithFormat:@"%+2.2f", _q];
	
	// set sliders
	slider1.value = _a;
	slider2.value = _b;
	slider3.value = _c;
	
	// set formControl
	self.formControl.selectedSegmentIndex = form;
	[self changeForm:self.formControl];
	self.displaySwitch.on = display;
	
	[self drawMainGraph];
}

- (void)updateEquation:(id)sender
{
	switch (self.formControl.selectedSegmentIndex) {
		case 0:
			if ([sender isEqual:slider1]) {
				_A = _a;
				_a = slider1.value;
				self.varLabel1.text = [NSString stringWithFormat:@"%2.2f", _a];
			} else if ([sender isEqual:slider2]) {
				_B = _b;
				_b = slider2.value;
				self.varLabel2.text = [NSString stringWithFormat:@"%+2.2f", _b];
			} else if ([sender isEqual:slider3]) {
				_C = _c;
				_c = slider3.value;
				self.varLabel3.text = [NSString stringWithFormat:@"%+2.2f", _c];
			}
			break;
		case 1:
			if ([sender isEqual:slider1]) {
				_K = _k;
				_k = slider1.value;
				fieldK.text = [NSString stringWithFormat:@"%2.2f", _k];
			} else if ([sender isEqual:slider2]) {
				_P = _p;
				_p = slider2.value;
				fieldP.text = [NSString stringWithFormat:@"%+2.2f", _p];
			} else if ([sender isEqual:slider3]) {
				_Q = _q;
				_q = slider3.value;
				fieldQ.text = [NSString stringWithFormat:@"%+2.2f", _q];
			}
			break;
		default:
			break;
	}
}

- (void)forceUpdateEquation
{
		_a = slider1.value;
		self.varLabel1.text = [NSString stringWithFormat:@"%2.2f", _a];
		_b = slider2.value;
		self.varLabel2.text = [NSString stringWithFormat:@"%+2.2f", _b];
		_c = slider3.value;
		self.varLabel3.text = [NSString stringWithFormat:@"%+2.2f", _c];
		_k = slider1.value;
		fieldK.text = [NSString stringWithFormat:@"%2.2f", _k];
		_p = slider2.value;
		fieldP.text = [NSString stringWithFormat:@"%+2.2f", _p];
		_q = slider3.value;
		fieldQ.text = [NSString stringWithFormat:@"%+2.2f", _q];
}

- (void)updateGraphView
{
	if (_updating
		|| (_a == _A && _b == _B && _c == _C && _k == _K && _p == _P && _q == _Q) ) {
		return;
	} else {
		_updating = YES;
		
		[self drawMainGraph];
		
		_A = _a;
		_B = _b;
		_C = _c;
		_K = _k;
		_P = _p;
		_Q = _q;
		_updating = NO;
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
		plotColor = [[UIColor colorWithHue:(double)_currentGraphNumber / NUMBER_OF_GRAPHS saturation:1.0 brightness:1.0 alpha:1.0] CGColor];
	} else {
		plotColor = [[UIColor colorWithHue:(double)_currentGraphNumber / NUMBER_OF_GRAPHS saturation:1.0 brightness:1.0 alpha:0.0] CGColor];
	}
	

	CGContextSetLineWidth(context, 4.0);
	switch (self.formControl.selectedSegmentIndex) {
		case 0: // general form
			CGContextMoveToPoint(context, 0, -((_a * pow(-10, 2) + _b * (-10) + _c) / valuePerPixel) + self.mainGraphView.frame.size.height / 2.0);
			for (int j = 1; j <= self.mainGraphView.frame.size.width; j += xInterval) {
				double x = (double)j / self.mainGraphView.frame.size.width * 20.0 - 10;
				double y = _a * pow(x, 2) + _b * (x) + _c;
				double i = -(y / valuePerPixel) + self.mainGraphView.frame.size.height / 2.0;
				CGContextAddLineToPoint(context, j, i);
			}
			CGContextSetStrokeColorWithColor(context, plotColor);
			CGContextStrokePath(context);
			break;
		case 1: // standard form
			CGContextMoveToPoint(context, 0, -((_k * pow((-10 + _p), 2) + _q) / valuePerPixel) + self.mainGraphView.frame.size.height / 2.0);
			for (int j = 1; j <= self.mainGraphView.frame.size.width; j += xInterval) {
				double x = (double)j / self.mainGraphView.frame.size.width * 20.0 - 10;
				double y = _k * pow((x + _p), 2) + _q;
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
		if (i == _currentGraphNumber
			|| _parameters[i][DISPLAY] == NO) {
			continue;
		}
		CGColorRef plotColor = [[UIColor colorWithHue:(double)i / NUMBER_OF_GRAPHS saturation:1.0 brightness:1.0 alpha:1.0] CGColor];
		CGContextSetLineWidth(context, 4.0);
		switch ((int)(_parameters[i][FORM])) {
			case GENERAL_FORM: // general form
				tempA = _parameters[i][PARAM_A];
				tempB = _parameters[i][PARAM_B];
				tempC = _parameters[i][PARAM_C];
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
				tempK = _parameters[i][PARAM_K];
				tempP = _parameters[i][PARAM_P];
				tempQ = _parameters[i][PARAM_Q];
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
	[self.keyboardView updateButtonsWithFrame:self.keyboardView.frame Row:self.keyboardView.row column:self.keyboardView.column titles:self.keyboardView.titles outCharacters:self.keyboardView.outCharacters style:self.keyboardView.style];
	[self.keyboardView mergeButtons:self.keyboardView.mergeInfo];
	[self drawSubGraph];
	[self drawMainGraph];
}

- (IBAction)changeDisplay:(id)sender {
	UISwitch *aSwitch = sender;
	display = aSwitch.on;
	[self drawMainGraph];
}

- (IBAction)presentNumPad:(id)sender {
    UIButton *button = sender;
    if ([button isEqual:_varButton1]) {
        _currentSelectedLabel = _varLabel1;
    } else if ([button isEqual:_varButton2]) {
        _currentSelectedLabel = _varLabel2;
    } else if ([button isEqual:_varButton3]) {
        _currentSelectedLabel = _varLabel3;
    }
    
    UTPopoverContext *popoverContext = [UTPopoverContext sharedPopoverContext];
    UTNumPadViewController *contentViewController = [[UTNumPadViewController alloc] initWithNibName:@"UTNumPadViewController" bundle:[NSBundle mainBundle]];
    contentViewController.delegate = self;
    [popoverContext presentPopoverWithContentViewController:contentViewController fromRect:button.frame inView:generalFormView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

#pragma mark - UTNumPadViewControllerDelegate

- (void)numPadDidDisappear:(UTNumPadViewController *)numPad
{
    _currentSelectedLabel.text = numPad.numberString;
    if ([_currentSelectedLabel isEqual:_varLabel1]) {
        _a = [_currentSelectedLabel.text doubleValue];
    } else if ([_currentSelectedLabel isEqual:_varLabel2]) {
        _b = [_currentSelectedLabel.text doubleValue];
    } else if ([_currentSelectedLabel isEqual:_varLabel3]) {
        _c = [_currentSelectedLabel.text doubleValue];
    }
}


@end
