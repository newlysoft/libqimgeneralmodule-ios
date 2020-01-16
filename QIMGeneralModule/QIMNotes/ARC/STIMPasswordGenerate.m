//
//  STIMPasswordGenerate.m
//  STChatIphone
//
//  Created by 李海彬 on 2017/7/11.
//
//

#import "STIMPasswordGenerate.h"
enum {
    STIMType,
    STIMType_UpperCase,
    STIMType_LowerCase,
    STIMType_SpecialCharacters,
};

static STIMPasswordGenerate *__STIMPasswordGenerate = nil;

@implementation STIMPasswordGenerate {
    NSArray *_numberList;
    NSArray *_upperCaseList;
    NSArray *_lowerCaseList;
    NSArray *_scList;
}

+ (STIMPasswordGenerate *)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __STIMPasswordGenerate = [[STIMPasswordGenerate alloc] init];
    });
    return __STIMPasswordGenerate;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _numberList = @[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"0",];
        _upperCaseList = @[@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y" ,@"Z",];
        _lowerCaseList = @[@"a",@"b",@"c",@"d",@"e",@"f",@"g",@"h",@"i",@"j",@"k",@"l",@"m",@"n",@"o",@"p",@"q",@"r",@"s",@"t",@"u",@"v",@"w",@"x",@"y",@"z",];
        _scList = @[@"~",@"!",@"@",@"#",@"$",@"%",@"^",@"&",@"*",@"(",@")",@"[",@"]",@"{",@"}",@";",@":",@"'",@"\"",@",",@".",@"/",@"<",@">",@"?",@"\\",@"|",];
    }
    return self;
}

- (NSString *)createPasswordWithBit:(int)bit //密码位数
                         WithNumber:(int)numberCount //数字个数
                      WithUpperCase:(int)ucCount //大写字母个数
                      WithLowerCase:(int)lcCount //小写字母个数
              WithSpecialCharacters:(int)scCount //特殊字符
                    WithAllowRepeat:(BOOL)allowRepeat //是否允许出现重复字符
{
    NSMutableString *password = [[NSMutableString alloc] initWithCapacity:bit];
    NSMutableArray *typeList = [NSMutableArray array];
    if (numberCount > 0) {
        [typeList addObject:@(STIMType)];
    }
    if (ucCount > 0) {
        [typeList addObject:@(STIMType_UpperCase)];
    }
    if (lcCount > 0) {
        [typeList addObject:@(STIMType_LowerCase)];
    }
    if (scCount > 0) {
        [typeList addObject:@(STIMType_SpecialCharacters)];
    }
    NSMutableArray *tempNumberList = [NSMutableArray arrayWithArray:_numberList];
    NSMutableArray *tempUCList = [NSMutableArray arrayWithArray:_upperCaseList];
    NSMutableArray *tempLCList = [NSMutableArray arrayWithArray:_lowerCaseList];
    NSMutableArray *tempSCList = [NSMutableArray arrayWithArray:_scList];
    do {
        int index = arc4random() % typeList.count;
        int cType = [[typeList objectAtIndex:index] intValue];
        switch (cType) {
            case STIMType:
            {
                int index = arc4random() % tempNumberList.count;
                NSString *str = [tempNumberList objectAtIndex:index];
                [password appendString:str];
                if (allowRepeat == NO) {
                    [tempNumberList removeObject:str];
                }
                numberCount--;
                if (numberCount <= 0) {
                    [typeList removeObject:@(STIMType)];
                }
            }
                break;
            case STIMType_UpperCase:
            {
                int index = arc4random() % tempUCList.count;
                NSString *str = [tempUCList objectAtIndex:index];
                [password appendString:str];
                if (allowRepeat == NO) {
                    [tempUCList removeObject:str];
                }
                ucCount--;
                if (ucCount <= 0) {
                    [typeList removeObject:@(STIMType_UpperCase)];
                }
            }
                break;
            case STIMType_LowerCase:
            {
                int index = arc4random() % tempLCList.count;
                NSString *str = [tempLCList objectAtIndex:index];
                [password appendString:str];
                if (allowRepeat == NO) {
                    [tempLCList removeObject:str];
                }
                lcCount--;
                if (lcCount <= 0) {
                    [typeList removeObject:@(STIMType_LowerCase)];
                }
            }
                break;
            case STIMType_SpecialCharacters:
            {
                int index = arc4random() % tempSCList.count;
                NSString *str = [tempSCList objectAtIndex:index];
                [password appendString:str];
                if (allowRepeat == NO) {
                    [tempSCList removeObject:str];
                }
                scCount--;
                if (scCount <= 0) {
                    [typeList removeObject:@(STIMType_SpecialCharacters)];
                }
            }
                break;
            default:
                break;
        }
    } while (password.length < bit ||( numberCount > 0 && ucCount > 0 && lcCount > 0 && scCount > 0));
    
    return password;
    
}

@end