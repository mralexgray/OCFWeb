// The MIT License (MIT)
// Copyright (c) 2013 Objective-Cloud (chris@objective-cloud.com)
// https://github.com/Objective-Cloud/OCFWeb

#import "OCFMustache.h"

@interface OCFMustache ()

#pragma mark - Properties
@property (nonatomic, copy, readwrite) NSString *name;
@property (nonatomic, strong, readwrite) id object;

@end

@implementation OCFMustache

#pragma mark - Creating a Mustache "Response"
- (instancetype)initWithName:(NSString *)name object:(id)object {
    return self = [super init] ? _name = name,  _object = object, self : nil;
}

- (instancetype)init {
    @throw [NSException exceptionWithName:@"OCFInvalidInitializer" reason:nil userInfo:nil];
}

+ (instancetype)newMustacheWithName:(NSString *)name object:(id)object {
    return [[[self class] alloc] initWithName:name object:object];
}

+ (NSString*)templateForName:			(NSString*)name {

}
@end
