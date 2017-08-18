//
//  Target.m
//  runtimeTest
//
//  Created by branon_liu on 2017/8/15.
//  Copyright © 2017年 postop_iosdev. All rights reserved.
//

#import "Target.h"
#import "Boy.h"
#import <objc/runtime.h>


@implementation Target


//methodSignatureForSelector用来生成方法签名，这个签名就是给forwardInvocation中的参数NSInvocation调用的。
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector{

    NSMethodSignature *signature = [super methodSignatureForSelector:aSelector];
    if (!signature) {
        if ([Boy instancesRespondToSelector:aSelector]) {
            signature = [Boy instanceMethodSignatureForSelector:aSelector];
        }
    }
    return signature;
}

//所以我们需要做的是自己新建方法签名，再在forwardInvocation中用你要转发的那个对象调用这个对应的签名，这样也实现了消息转发。
- (void)forwardInvocation:(NSInvocation *)anInvocation{

    if ([Boy  instancesRespondToSelector:anInvocation.selector]) {
        [anInvocation invokeWithTarget:[Boy new]];
    }
}







@end
