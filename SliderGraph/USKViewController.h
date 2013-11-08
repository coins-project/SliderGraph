//
//  USKViewController.h
//  SliderGraph
//
//  Created by Yusuke Iwama on 11/7/13.
//  Copyright (c) 2013 Yusuke Iwama. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface USKViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *graphView;


@property (weak, nonatomic) IBOutlet UILabel *equationLabel;
@property (weak, nonatomic) IBOutlet UISlider *sliderA;
@property (weak, nonatomic) IBOutlet UISlider *sliderB;
@property (weak, nonatomic) IBOutlet UISlider *sliderC;
@property (weak, nonatomic) IBOutlet UISegmentedControl *formControl;


@property (weak, nonatomic) IBOutlet UILabel *equationLabel2;
@property (weak, nonatomic) IBOutlet UISlider *sliderA2;
@property (weak, nonatomic) IBOutlet UISlider *sliderB2;
@property (weak, nonatomic) IBOutlet UISlider *sliderC2;
@property (weak, nonatomic) IBOutlet UISegmentedControl *formControl2;


@end
