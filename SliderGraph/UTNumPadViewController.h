//
//  EM2P11ViewController.h
//  eMATCH2
//
//  Created by sasaki on 2013/11/28.
//  Copyright (c) 2013年 Systems Nakashima co., ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UTNumPadViewControllerDelegate;


@interface UTNumPadViewController : UIViewController

@property (nonatomic, weak) id <UTNumPadViewControllerDelegate> delegate;

@property (nonatomic, weak) IBOutlet UILabel *monitorLabel;

// DelegateがP1-1パネルから数字の文字列を取得する時に利用するメソッド。
- (NSString *)numberString;

@end


@protocol UTNumPadViewControllerDelegate <NSObject>

- (void)numPadDidDisappear:(UTNumPadViewController *)numPad;

@end