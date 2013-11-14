//
//  COINSKeyboard.m
//  FracCalc
//
//  Created by Yusuke IWAMA on 9/16/13.
//  Copyright (c) 2013 COINS Project AID. All rights reserved.
//

#import "COINSKeyboard.h"

@implementation COINSKeyboard {
	NSMutableArray *buttons;
	CGSize buttonSize;
}

@synthesize delegate;
@synthesize buttonInset;
@synthesize row, column;
@synthesize titles;
@synthesize outCharacters;
@synthesize mergeInfo;
@synthesize style;

- (void)updateButtonsWithRow:(NSUInteger)r column:(NSUInteger)c titles:(NSArray *)t outCharacters:(NSString *)o mergeInfo:(NSArray *)m style:(COINSKeyboardStyle)s;
{
	// check if number of buttons and titles match
	if (t.count != o.length) {
		NSLog(@"button title count and out characters don't match!");
		return;
	}

	// remove all buttons from view and array
	if (buttons) {
		for (UIButton *aButton in buttons) {
			[aButton removeFromSuperview];
		}
		[buttons removeAllObjects];
	} else {
		buttons = [NSMutableArray array];
	}
	
	row = r;
	column = c;
	titles = t;
	outCharacters = o;
	style = s;
	mergeInfo = m;
	
	buttonSize = CGSizeMake(self.frame.size.width / column, self.frame.size.height / row);
	for (int i = 0; i < titles.count; i++) {
		UIButton *aButton = [UIButton buttonWithType:UIButtonTypeCustom];
		aButton.frame = CGRectMake((i % column) * buttonSize.width,
								   (i / column) * buttonSize.height,
								   buttonSize.width,
								   buttonSize.height);
		[aButton setTitle:titles[i] forState:UIControlStateNormal];
		[aButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
		aButton.titleLabel.adjustsFontSizeToFitWidth = YES;
		[buttons addObject:aButton];
		[self addSubview:aButton];
	}
	[self updateButtonStyleWithStyle:style];
	[self mergeButtons:mergeInfo];
}

- (void)mergeButtons:(NSArray *)m
{
	for (NSArray *anArray in m) {
		UIButton *topButton, *rightButton, *bottomButton, *leftButton;
		NSUInteger top = NSUIntegerMax, right = 0, bottom = 0, left = NSUIntegerMax; // indexes of the buttons
		for (NSNumber *n in anArray) {
			// Find the most top-left corner and the bottom-right corner.
			NSUInteger i = n.integerValue;
			UIButton *aButton = buttons[i];
			NSUInteger r = i / column;
			NSUInteger c = i % column;
			if (r < top) {
				top = r;
				topButton = aButton;
			}
			if (c > right) {
				right = c;
				rightButton = aButton;
			}
			if (r > bottom) {
				bottom = r;
				bottomButton = aButton;
			}
			if (c < left) {
				left = c;
				leftButton = aButton;
			}
			aButton.hidden = YES;
		}
		NSNumber *n = [anArray objectAtIndex:0];
		NSUInteger representativeIndex = n.integerValue;
		UIButton *representativeButton = buttons[representativeIndex];
		representativeButton.hidden = NO;
		representativeButton.frame = CGRectMake(leftButton.frame.origin.x,
												topButton.frame.origin.y,
												rightButton.frame.origin.x + buttonSize.width - leftButton.frame.origin.x,
												bottomButton.frame.origin.y + buttonSize.height - topButton.frame.origin.y);
	}
}

- (void)buttonPressed:(id)sender
{
	NSUInteger i = [buttons indexOfObject:sender];
	[delegate input:[outCharacters characterAtIndex:i]];
    
}

- (void)updateButtonStyleWithStyle:(COINSKeyboardStyle)s
{
	for (NSUInteger i = 0; i < buttons.count; i++) {
		UIButton *aButton = buttons[i];
		switch (s) {
			case COINSKeyboardStyleiOS7:
			{
				UIColor *backgroundColor = [UIColor blackColor];
				UIColor *keyColor = [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1.0];
				self.backgroundColor = backgroundColor;
				UIEdgeInsets keyboardInset = UIEdgeInsetsMake(0.5, 0.5, 0.5, 0.5);
				buttonSize = CGSizeMake((self.frame.size.width - keyboardInset.left - keyboardInset.right) / column,
										(self.frame.size.height - keyboardInset.top - keyboardInset.bottom) / row);
				aButton.frame = CGRectMake((i % column) * buttonSize.width + keyboardInset.left,
										   (i / column) * buttonSize.height + keyboardInset.top,
										   buttonSize.width,
										   buttonSize.height);
				aButton.titleLabel.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:buttonSize.width / 2];
				// set key color
				NSCharacterSet *operators = [NSCharacterSet characterSetWithCharactersInString:@"+-×÷="];
				NSRange operatorsRange = [aButton.titleLabel.text rangeOfCharacterFromSet:operators];
				if (operatorsRange.location == NSNotFound) {
					NSCharacterSet *numerals = [NSCharacterSet characterSetWithCharactersInString:@"1234567890"];
					NSRange numeralRange = [aButton.titleLabel.text rangeOfCharacterFromSet:numerals];
					if (numeralRange.location == NSNotFound) { // others
						[aButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
						aButton.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0];
					} else { // numeral
						[aButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
						aButton.backgroundColor = keyColor;
					}
				} else { // four arithmetic operator or equal
					[aButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
					aButton.backgroundColor = [UIColor colorWithRed:1.0 green:0.56 blue:0.0 alpha:1.0];
				}
				aButton.layer.borderWidth = 0.5;
				aButton.layer.borderColor = [backgroundColor CGColor];
			}
				break;
			case COINSKeyboardStyleBlackboard:
			{
				UIColor *backgroundColor = [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:0.5];
				UIColor *keyColor = [UIColor colorWithRed:0.0 green:0.3 blue:0.0 alpha:1.0];
				self.backgroundColor = backgroundColor;
				UIEdgeInsets keyboardInset = UIEdgeInsetsMake(0.5, 0.5, 0.5, 0.5);
				buttonSize = CGSizeMake((self.frame.size.width - keyboardInset.left - keyboardInset.right) / column,
										(self.frame.size.height - keyboardInset.top - keyboardInset.bottom) / row);
				aButton.frame = CGRectMake((i % column) * buttonSize.width + keyboardInset.left,
										   (i / column) * buttonSize.height + keyboardInset.top,
										   buttonSize.width,
										   buttonSize.height);
				aButton.titleLabel.font = [UIFont fontWithName:@"Chalkduster" size:buttonSize.width / 2];
				// set key color
				NSCharacterSet *operators = [NSCharacterSet characterSetWithCharactersInString:@"+-×÷="];
				NSRange operatorsRange = [aButton.titleLabel.text rangeOfCharacterFromSet:operators];
				if (operatorsRange.location == NSNotFound) {
					NSCharacterSet *numerals = [NSCharacterSet characterSetWithCharactersInString:@"1234567890"];
					NSRange numeralRange = [aButton.titleLabel.text rangeOfCharacterFromSet:numerals];
					if (numeralRange.location == NSNotFound) { // others
						[aButton setTitleColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.0 alpha:1.0] forState:UIControlStateNormal]; // Yellow
						aButton.backgroundColor = keyColor;
					} else { // numeral
						[aButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
						aButton.backgroundColor = keyColor;
					}
				} else { // four arithmetic operator or equal
					[aButton setTitleColor:[UIColor colorWithRed:1.0 green:0.46 blue:0.8 alpha:1.0] forState:UIControlStateNormal]; // Pink
					aButton.backgroundColor = keyColor;
				}
				aButton.layer.borderWidth = 0.5;
				aButton.layer.borderColor = [backgroundColor CGColor];
			}
				break;
			case COINSKeyboardStylePinkCircle:
			{
				CGFloat hue = 0.9; // Pink
				UIColor *backgroundColor = [UIColor colorWithHue:hue saturation:0.2 brightness:1.0 alpha:1.0];
				UIColor *keyColor = [UIColor colorWithHue:hue saturation:0.4 brightness:1.0 alpha:1.0];
				self.backgroundColor = backgroundColor;
				CGFloat margin = 4.0;
				UIEdgeInsets keyboardInset = UIEdgeInsetsMake(margin, margin, margin, margin);
				buttonSize = CGSizeMake((self.frame.size.width - keyboardInset.left - keyboardInset.right) / column - margin * 2,
										(self.frame.size.height - keyboardInset.top - keyboardInset.bottom) / row - margin * 2);
				CGFloat trimLength;
				// Constrain buttonSize.width and height as the same length
				if (buttonSize.width > buttonSize.height) {
					trimLength = buttonSize.width - buttonSize.height;
					buttonSize.width = buttonSize.height;
					aButton.frame = CGRectMake((i % column) * (buttonSize.width + trimLength + margin * 2) + trimLength / 2.0 + margin + keyboardInset.left,
											   (i / column) * (buttonSize.height + margin * 2) + margin + keyboardInset.top,
											   buttonSize.width,
											   buttonSize.height);

				} else {
					trimLength = buttonSize.height - buttonSize.width;
					buttonSize.height = buttonSize.width;
					aButton.frame = CGRectMake((i % column) * (buttonSize.width + margin * 2) + margin + keyboardInset.left,
											   (i / column) * (buttonSize.height + trimLength + margin * 2) + trimLength / 2.0 + margin + keyboardInset.top,
											   buttonSize.width,
											   buttonSize.height);
				}
				aButton.titleLabel.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:buttonSize.width / 2.5];
				// set key color
				NSCharacterSet *operators = [NSCharacterSet characterSetWithCharactersInString:@"+-×÷="];
				NSRange operatorsRange = [aButton.titleLabel.text rangeOfCharacterFromSet:operators];
				if (operatorsRange.location == NSNotFound) {
					NSCharacterSet *numerals = [NSCharacterSet characterSetWithCharactersInString:@"1234567890"];
					NSRange numeralRange = [aButton.titleLabel.text rangeOfCharacterFromSet:numerals];
					if (numeralRange.location == NSNotFound) { // others
						[aButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
						aButton.backgroundColor = [UIColor colorWithHue:hue saturation:0.5 brightness:1.0 alpha:1.0];
					} else { // numeral
						[aButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
						aButton.backgroundColor = keyColor;
					}
				} else { // four arithmetic operator or equal
					[aButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
					aButton.backgroundColor = [UIColor colorWithHue:hue saturation:0.6 brightness:1.0 alpha:1.0];
				}
				aButton.layer.borderColor = [[UIColor colorWithHue:hue saturation:0.5 brightness:0.8 alpha:1.0] CGColor];
				aButton.layer.borderWidth = 1.0;
				aButton.layer.cornerRadius = buttonSize.width / 2.0;
			}
				break;
			case COINSKeyboardStyleBlueCircle:
			{
				CGFloat hue = 0.55; // Blue
				UIColor *backgroundColor = [UIColor colorWithHue:hue saturation:0.2 brightness:1.0 alpha:1.0];
				UIColor *keyColor = [UIColor colorWithHue:hue saturation:0.4 brightness:1.0 alpha:1.0];
				self.backgroundColor = backgroundColor;
				CGFloat margin = 4.0;
				UIEdgeInsets keyboardInset = UIEdgeInsetsMake(margin, margin, margin, margin);
				buttonSize = CGSizeMake((self.frame.size.width - keyboardInset.left - keyboardInset.right) / column - margin * 2,
										(self.frame.size.height - keyboardInset.top - keyboardInset.bottom) / row - margin * 2);
				CGFloat trimLength;
				// Constrain buttonSize.width and height as the same length
				if (buttonSize.width > buttonSize.height) {
					trimLength = buttonSize.width - buttonSize.height;
					buttonSize.width = buttonSize.height;
					aButton.frame = CGRectMake((i % column) * (buttonSize.width + trimLength + margin * 2) + trimLength / 2.0 + margin + keyboardInset.left,
											   (i / column) * (buttonSize.height + margin * 2) + margin + keyboardInset.top,
											   buttonSize.width,
											   buttonSize.height);
					
				} else {
					trimLength = buttonSize.height - buttonSize.width;
					buttonSize.height = buttonSize.width;
					aButton.frame = CGRectMake((i % column) * (buttonSize.width + margin * 2) + margin + keyboardInset.left,
											   (i / column) * (buttonSize.height + trimLength + margin * 2) + trimLength / 2.0 + margin + keyboardInset.top,
											   buttonSize.width,
											   buttonSize.height);
				}
				aButton.titleLabel.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:buttonSize.width / 2.5];
				// set key color
				NSCharacterSet *operators = [NSCharacterSet characterSetWithCharactersInString:@"+-×÷="];
				NSRange operatorsRange = [aButton.titleLabel.text rangeOfCharacterFromSet:operators];
				if (operatorsRange.location == NSNotFound) {
					NSCharacterSet *numerals = [NSCharacterSet characterSetWithCharactersInString:@"1234567890"];
					NSRange numeralRange = [aButton.titleLabel.text rangeOfCharacterFromSet:numerals];
					if (numeralRange.location == NSNotFound) { // others
						[aButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
						aButton.backgroundColor = [UIColor colorWithHue:hue saturation:0.5 brightness:1.0 alpha:1.0];
					} else { // numeral
						[aButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
						aButton.backgroundColor = keyColor;
					}
				} else { // four arithmetic operator or equal
					[aButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
					aButton.backgroundColor = [UIColor colorWithHue:hue saturation:0.6 brightness:1.0 alpha:1.0];
				}
				aButton.layer.borderColor = [[UIColor colorWithHue:hue saturation:0.5 brightness:0.8 alpha:1.0] CGColor];
				aButton.layer.borderWidth = 1.0;
				aButton.layer.cornerRadius = buttonSize.width / 2.0;
			}
			default:
				break;
		}
	}
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
