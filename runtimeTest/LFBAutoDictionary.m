//
//  LFBAutoDictionary.m
//  runtimeTest
//
//  Created by branon_liu on 2017/8/14.
//  Copyright © 2017年 postop_iosdev. All rights reserved.
//

#import "LFBAutoDictionary.h"
#import <objc/runtime.h>

@interface LFBAutoDictionary ()
@property (nonatomic, strong) NSMutableDictionary *backStore; // 后台存储用字典
@end

@implementation LFBAutoDictionary

@dynamic obj;//禁止自动生成setter&getter


- (instancetype)init
{
    self = [super init];
    if (self) {
        _backStore = @{}.mutableCopy;
    }
    return self;
}

//消息转发，当设置@dynamic关键字以后，在自身方法列表，以及父类方法列表中都不能找到对应的setter和getter方法，此时系统会自动进行消息转发，第一步会调用resolveInstanceMethod方法，当调用为类方法则会调用resolveClassMethod方法，这两个方法都没有返回YES，则继续调用forwardingTargetForSelector,如果还是没有反应则调用forwardInvocation方法，如果最后还是没有反应那就直接抛出异常

+ (BOOL)resolveInstanceMethod:(SEL)sel{

    NSString *selString = NSStringFromSelector(sel);
    
    // 类型编码：v->void  @->OC对象  :->SEL选择器
    // 响应setter方法的选择器
    if ([selString hasPrefix:@"set"]) {
        class_addMethod(self, sel, (IMP)autoDictionarySetter, "v@:@");
    } else { // 响应getter方法的选择器
        class_addMethod(self, sel, (IMP)autoDictionaryGetter, "@@:");
    }
    
    return YES;
}

// 处理setter方法的函数
void autoDictionarySetter(id self, SEL sel, id value) {
    LFBAutoDictionary *autoDict = (LFBAutoDictionary *)self;
    NSMutableDictionary *backStore = autoDict.backStore;
    
    NSString *selString = NSStringFromSelector(sel);
    NSMutableString *key = selString.mutableCopy;
    [key deleteCharactersInRange:NSMakeRange(key.length - 1, 1)];
    [key deleteCharactersInRange:NSMakeRange(0, 3)];
    [key replaceCharactersInRange:NSMakeRange(0, 1) withString:[[key substringToIndex:1] lowercaseString]];
    
    if (value) {
        [backStore setObject:value forKey:key];
    } else {
        [backStore removeObjectForKey:key];
    }
}

// 处理getter方法的函数
id autoDictionaryGetter(id self, SEL sel) {
    LFBAutoDictionary *autoDict = (LFBAutoDictionary *)self;
    NSMutableDictionary *backStore = autoDict.backStore;
    
    NSString *key = NSStringFromSelector(sel);
    return [backStore objectForKey:key];
}


@end
