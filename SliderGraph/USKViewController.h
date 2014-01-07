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

- (IBAction)changeDisplay:(id)sender;

@end


/* 
 拡大縮小ができるようにする
・xRange, yRangeの導入
・textFieldのframe移動をconstraint baseにする
 ・ドラッグ値域、変域
 ・

*/