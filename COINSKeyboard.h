//
//  COINSKeyboard.h
//  FracCalc
//
//  Created by Yusuke IWAMA on 9/16/13.
//  Copyright (c) 2013 COINS Project AID. All rights reserved.
//

/**
 キーボードを実現するクラスである。
 このクラスのインスタンスを作るには、入力を処理するデリゲート、座標、キーの行数・列数、キートップに表示するタイトル、
 入力を判別するための文字を格納した文字列を渡す。
 
 ユーザーがキーをタップすると、デリゲートに対して押されたキーに対応する文字列が渡される。
*/

#import <UIKit/UIKit.h>

typedef enum COINSKeyboardStyle {
	COINSKeyboardStyleiOS7 = 0,
	COINSKeyboardStyleBlackboard,
	COINSKeyboardStylePinkCircle,
	COINSKeyboardStyleBlueCircle,
	COINSKeyboardStyleDefault = COINSKeyboardStyleiOS7,
	} COINSKeyboardStyle;

@protocol COINSKeyboardDelegate <NSObject>

- (void)input:(unichar)c;

@end


@interface COINSKeyboard : UIView

@property id<COINSKeyboardDelegate> delegate;
@property UIEdgeInsets buttonInset;

@property (readonly) NSUInteger row;
@property (readonly) NSUInteger column;
@property (readonly) NSArray *titles;
@property (readonly) NSString *outCharacters;
@property (readonly) NSArray *mergeInfo;
@property (readonly) COINSKeyboardStyle style;

- (void)updateButtonsWithRow:(NSUInteger)r column:(NSUInteger)c titles:(NSArray *)t outCharacters:(NSString *)o mergeInfo:(NSArray *)m style:(COINSKeyboardStyle)s;

@end

