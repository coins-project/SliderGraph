//
//  UTNumPadViewController.m
//  eMATCH2
//
//  Created by sasaki on 2013/11/28.
//  Copyright (c) 2013年 Systems Nakashima co., ltd. All rights reserved.
//

#import "UTNumPadViewController.h"

/** 数字キーに対しては値が同一であることを保証する */
typedef NS_ENUM(NSInteger, UTNumPadKeyType) {
    UTNumPadKeyType0 = 0,
    UTNumPadKeyType1 = 1,
    UTNumPadKeyType2 = 2,
    UTNumPadKeyType3 = 3,
    UTNumPadKeyType4 = 4,
    UTNumPadKeyType5 = 5,
    UTNumPadKeyType6 = 6,
    UTNumPadKeyType7 = 7,
    UTNumPadKeyType8 = 8,
    UTNumPadKeyType9 = 9,
    UTNumPadKeyTypeMinus,
    UTNumPadKeyTypeDot,
    UTNumPadKeyTypeNoEffect,
    UTNumPadKeyTypeClear,
    UTNumPadKeyTypeBackspace,
};

@interface UTNumPadViewController ()

@property (weak, nonatomic) IBOutlet UIView *numPadView;

@end

@implementation UTNumPadViewController {
    NSMutableArray *_buttons;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    // NumPadボタンを配置
    NSArray *items = @[@"7", @"8", @"9",
                       @"4", @"5", @"6",
                       @"1", @"2", @"3",
                       @"-", @"0", @".",
                       @"BS"]; // 最後の@""はバックスペース。キートップにはテキストではなく画像を貼る。
    CGSize buttonMargin = CGSizeMake(0.5, 0.5);
    NSInteger numColumns = 3;
    NSInteger numRows = ([items count] - 1) / numColumns + 1;
//    CGSize buttonSize = CGSizeMake(106, 87.5);
    CGSize buttonSize = CGSizeMake(_numPadView.frame.size.width / numColumns, _numPadView.frame.size.height / numRows);
    for (NSInteger i = 0; i < [items count]; i++) {
        UIButton *aButton = [UIButton buttonWithType:UIButtonTypeCustom];
        aButton.frame = CGRectMake(0.5 + (buttonSize.width + buttonMargin.width) * (i % numColumns),
                                   (buttonSize.height + buttonMargin.height) * (i / numColumns),
                                   buttonSize.width,
                                   buttonSize.height);
        aButton.backgroundColor = [UIColor colorWithWhite:0.97 alpha:1.0];
        [aButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        aButton.titleLabel.font = [UIFont fontWithName:@"HiraKakuProN-W6" size:40.0];
        [aButton setTitle:items[i] forState:UIControlStateNormal];
        aButton.tag = [self keyTypeAtIndex:i]; // ボタンのtagにはKeyTypeを持たせる。
        [aButton addTarget:self action:@selector(didTapButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.numPadView addSubview:aButton];
        [_buttons addObject:aButton];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    if ([self.delegate respondsToSelector:@selector(numPadDidDisappear:)]) {
        [self.delegate numPadDidDisappear:self];
    }
}

- (NSInteger)keyTypeAtIndex:(NSInteger)index
{
    switch (index) {
        case 0:  return UTNumPadKeyType7;
        case 1:  return UTNumPadKeyType8;
        case 2:  return UTNumPadKeyType9;
        case 3:  return UTNumPadKeyType4;
        case 4:  return UTNumPadKeyType5;
        case 5:  return UTNumPadKeyType6;
        case 6:  return UTNumPadKeyType1;
        case 7:  return UTNumPadKeyType2;
        case 8:  return UTNumPadKeyType3;
        case 9:  return UTNumPadKeyTypeMinus;
        case 10: return UTNumPadKeyType0;
        case 11: return UTNumPadKeyTypeDot;
        default: return UTNumPadKeyTypeNoEffect;
    }
}

- (void)didTapButton:(id)sender
{
    UIButton *button = sender;
    switch (button.tag) {
        case UTNumPadKeyType0:
        case UTNumPadKeyType1:
        case UTNumPadKeyType2:
        case UTNumPadKeyType3:
        case UTNumPadKeyType4:
        case UTNumPadKeyType5:
        case UTNumPadKeyType6:
        case UTNumPadKeyType7:
        case UTNumPadKeyType8:
        case UTNumPadKeyType9:
            if ([self.monitorLabel.text length] < 10) { // 10桁以上の入力は無視する。
                self.monitorLabel.text = [self.monitorLabel.text stringByAppendingFormat:@"%ld", (long)button.tag];
            }
            break;
        case UTNumPadKeyTypeDot:
            if ([self.monitorLabel.text length] < 10) { // 10桁以上の入力は無視する。
                self.monitorLabel.text = [self.monitorLabel.text stringByAppendingString:@"."];
            }
            break;
        case UTNumPadKeyTypeMinus:
            if ([self.monitorLabel.text length] < 10) { // 10桁以上の入力は無視する。
                self.monitorLabel.text = [self.monitorLabel.text stringByAppendingString:@"-"];
            }
            break;
        default:
            break;
    }
}

- (NSString *)numberString
{
    return _monitorLabel.text;
}


@end
