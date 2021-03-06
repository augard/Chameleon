#import "UIClassSwapper.h"


static NSString* const kUIClassNameKey = @"UIClassName";
static NSString* const kUIOriginalClassNameKey = @"UIOriginalClassName";


@implementation UIClassSwapper

- (id) initWithCoder:(NSCoder*)coder
{
    NSString* className = [coder decodeObjectForKey:kUIClassNameKey];
    Class class = NSClassFromString(className);
    if (!class) {
        NSString* originalClassName = [coder decodeObjectForKey:kUIOriginalClassNameKey];
        class = NSClassFromString(originalClassName);
    }
    return [[class alloc] initWithCoder:coder];
}

- (void) encodeWithCoder:(NSCoder*)coder
{
    [self doesNotRecognizeSelector:_cmd];
}

@end
