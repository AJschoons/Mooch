//
//  UIFont+CustomFonts.m
//  Mooch
//
//  Created by adam on 11/4/16.
//  Copyright © 2016 cse498. All rights reserved.
//

#import <objc/runtime.h>
#import "UIFont+CustomFonts.h"

NSString *const FORegularFontName = @"AzoSans-Regular";
NSString *const FOBoldFontName = @"AzoSans-Bold";
NSString *const FOItalicFontName = @"AzoSans-Regular";

//http://stackoverflow.com/questions/8707082/set-a-default-font-for-whole-ios-app

#pragma mark - UIFont category
@implementation UIFont (CustomFonts)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"
+ (void)replaceClassSelector:(SEL)originalSelector withSelector:(SEL)modifiedSelector {
    Method originalMethod = class_getClassMethod(self, originalSelector);
    Method modifiedMethod = class_getClassMethod(self, modifiedSelector);
    method_exchangeImplementations(originalMethod, modifiedMethod);
}

+ (void)replaceInstanceSelector:(SEL)originalSelector withSelector:(SEL)modifiedSelector {
    Method originalDecoderMethod = class_getInstanceMethod(self, originalSelector);
    Method modifiedDecoderMethod = class_getInstanceMethod(self, modifiedSelector);
    method_exchangeImplementations(originalDecoderMethod, modifiedDecoderMethod);
}

+ (UIFont *)regularFontWithSize:(CGFloat)size
{
    return [UIFont fontWithName:FORegularFontName size:size];
}

+ (UIFont *)boldFontWithSize:(CGFloat)size
{
    return [UIFont fontWithName:FOBoldFontName size:size];
}

+ (UIFont *)italicFontOfSize:(CGFloat)fontSize
{
    return [UIFont fontWithName:FOItalicFontName size:fontSize];
}

- (id)initCustomWithCoder:(NSCoder *)aDecoder {
    BOOL result = [aDecoder containsValueForKey:@"UIFontDescriptor"];
    
    if (result) {
        UIFontDescriptor *descriptor = [aDecoder decodeObjectForKey:@"UIFontDescriptor"];
        
        NSString *fontName;
        if ([descriptor.fontAttributes[@"NSCTFontUIUsageAttribute"] isEqualToString:@"CTFontRegularUsage"]) {
            fontName = FORegularFontName;
        }
        else if ([descriptor.fontAttributes[@"NSCTFontUIUsageAttribute"] isEqualToString:@"CTFontEmphasizedUsage"]) {
            fontName = FOBoldFontName;
        }
        else if ([descriptor.fontAttributes[@"NSCTFontUIUsageAttribute"] isEqualToString:@"CTFontObliqueUsage"]) {
            fontName = FOItalicFontName;
        }
        else {
            fontName = descriptor.fontAttributes[@"NSFontNameAttribute"];
        }
        
        return [UIFont fontWithName:fontName size:descriptor.pointSize];
    }
    
    self = [self initCustomWithCoder:aDecoder];
    
    return self;
}

+ (void)load
{
    [self replaceClassSelector:@selector(systemFontOfSize:) withSelector:@selector(regularFontWithSize:)];
    [self replaceClassSelector:@selector(boldSystemFontOfSize:) withSelector:@selector(boldFontWithSize:)];
    [self replaceClassSelector:@selector(italicSystemFontOfSize:) withSelector:@selector(italicFontOfSize:)];
    
    [self replaceInstanceSelector:@selector(initWithCoder:) withSelector:@selector(initCustomWithCoder:)];
}
#pragma clang diagnostic pop

@end
