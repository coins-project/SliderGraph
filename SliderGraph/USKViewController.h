//
//  USKViewController.h
//  SliderGraph
//
//  Created by Yusuke Iwama on 11/7/13.
//  Copyright (c) 2013 Yusuke Iwama. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "COINSKeyboard.h"

@interface USKViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *mainGraphView; // display editing graph
@property (weak, nonatomic) IBOutlet UIImageView *subGraphView; // display the others graph, axis and grid.

@property (weak, nonatomic) IBOutlet UIView *controlView;

@property (weak, nonatomic) IBOutlet COINSKeyboard *keyboardView;
@property (weak, nonatomic) IBOutlet UISwitch *displaySwitch; // display or hide

@property (weak, nonatomic) IBOutlet UIView *generalFormView;
@property (weak, nonatomic) IBOutlet UITextField *fieldA;
@property (weak, nonatomic) IBOutlet UITextField *fieldB;
@property (weak, nonatomic) IBOutlet UITextField *fieldC;
@property (weak, nonatomic) IBOutlet UIView *standardFormView;
@property (weak, nonatomic) IBOutlet UITextField *fieldK;
@property (weak, nonatomic) IBOutlet UITextField *fieldP;
@property (weak, nonatomic) IBOutlet UITextField *fieldQ;

@property (weak, nonatomic) IBOutlet UISlider *slider1;
@property (weak, nonatomic) IBOutlet UISlider *slider2;
@property (weak, nonatomic) IBOutlet UISlider *slider3;
@property (weak, nonatomic) IBOutlet UISegmentedControl *formControl;


@property (weak, nonatomic) IBOutlet UISegmentedControl *graphControl;

- (IBAction)changeDisplay:(id)sender;

@end


/* 
 拡大縮小ができるようにする
・xRange, yRangeの導入
・textFieldのframe移動をconstraint baseにする
 ・ドラッグ値域、変域
 ・

*/