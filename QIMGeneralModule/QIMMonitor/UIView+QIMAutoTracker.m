//
//  UIView+QIMAutoTracker.m
//  QIMAutoTracker
//
//  Created by lilulucas.li on 2019/04/18.
//

#import "UIView+QIMAutoTracker.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "QIMAutoTrackerOperation.h"
#import "NSObject+QIMAutoTracker.h"

@implementation UIView (QIMAutoTracker)

+ (void)startTracker {
    Method addGestureRecognizerMethod = class_getInstanceMethod(self, @selector(addGestureRecognizer:));
    Method ddAddGestureRecognizerMethod = class_getInstanceMethod(self, @selector(dd_addGestureRecognizer:));
    method_exchangeImplementations(addGestureRecognizerMethod, ddAddGestureRecognizerMethod);
}

- (void)dd_addGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer {
    [self dd_addGestureRecognizer:gestureRecognizer];
    //只监听UITapGestureRecognizer事件
    if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
        Ivar targetsIvar = class_getInstanceVariable([UIGestureRecognizer class], "_targets");
        id targetActionPairs = object_getIvar(gestureRecognizer, targetsIvar);
        
        Class targetActionPairClass = NSClassFromString(@"UIGestureRecognizerTarget");
        Ivar targetIvar = class_getInstanceVariable(targetActionPairClass, "_target");
        Ivar actionIvar = class_getInstanceVariable(targetActionPairClass, "_action");
        
        for (id targetActionPair in targetActionPairs) {
            id target = object_getIvar(targetActionPair, targetIvar);
            SEL action = (__bridge void *)object_getIvar(targetActionPair, actionIvar);
            if (target &&
                action) {
                Class class = [target class];
                SEL originSelector = action;
                SEL swizzlSelector = NSSelectorFromString(@"dd_didTapView");
                BOOL didAddMethod = class_addMethod(class, swizzlSelector, (IMP)dd_didTapView, "v@:@@");
                if (didAddMethod) {
                    Method originMethod = class_getInstanceMethod(class, swizzlSelector);
                    Method swizzlMethod = class_getInstanceMethod(class, originSelector);
                    method_exchangeImplementations(originMethod, swizzlMethod);
                    break;
                }
            }
        }
    }
}

void dd_didTapView(id self, SEL _cmd, id gestureRecognizer) {
    NSMethodSignature *signture = [[self class] instanceMethodSignatureForSelector:_cmd];
    NSUInteger numberOfArguments = signture.numberOfArguments;
    SEL selector = NSSelectorFromString(@"dd_didTapView");
    if (3 == numberOfArguments) {
        ((void(*)(id, SEL, id))objc_msgSend)(self, selector, gestureRecognizer);
    }else if (2 == numberOfArguments) {
        ((void(*)(id, SEL))objc_msgSend)(self, selector);
    }
    
    NSString *aciton = NSStringFromSelector(_cmd);
    NSString *eventId = [NSString stringWithFormat:@"%@&&%@",NSStringFromClass([self class]),aciton];
    NSDictionary *infoDictionary = [self ddInfoDictionary];
    NSLog(@"dd_didTapView : %@", infoDictionary);
    [[QIMAutoTrackerOperation sharedInstance] sendTrackerData:eventId
                                                        info:infoDictionary];
}

@end
