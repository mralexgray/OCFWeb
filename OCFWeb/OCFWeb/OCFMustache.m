// The MIT License (MIT)
// Copyright (c) 2013 Objective-Cloud (chris@objective-cloud.com)
// https://github.com/Objective-Cloud/OCFWeb

#import "OCFMustache.h"

//@interface OCFMustache ()
#pragma mark - Properties
//@property (copy) NSString * name;
//@property						   id	  object;
//@end

@implementation OCFMustache @synthesize  name = _name, object = _object;

#pragma mark - Creating a Mustache "Response"

- (instancetype)initWithName:(NSString*)name object:(id)object { return self = super.init ? _name = name.copy, _object = object, self : nil; }

- (instancetype)init { @throw [NSException exceptionWithName:@"OCFInvalidInitializer" reason:nil userInfo:nil]; }

+ (instancetype)newMustacheWithName:(NSString *)name object:(id)object { return [self.class.alloc initWithName:name object:object]; }

+ (NSString*)templateForName:			(NSString*)name { @throw [NSException exceptionWithName:@"UNIMPLEMENTED" reason:nil userInfo:nil]; }
@end
