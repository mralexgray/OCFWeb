// The MIT License (MIT)
// Copyright (c) 2013 Objective-Cloud (chris@objective-cloud.com)
// https://github.com/Objective-Cloud/OCFWeb

#import <OCFWebServer/OCFWebServerRequest.h>


typedef void(^NSControlActionBlock)(id sender);

@interface NSControl (Block)
- (NSControlActionBlock) actionBlock;
- (void)setActionBlock:(NSControlActionBlock)ab;

@end


id CallBlockWithArguments(id block, NSArray *aArguments);



@interface OCFWebServerRequest (OCFWebAdditions)

#pragma mark - Additional Parameters
@property (nonatomic, readonly) NSDictionary *additionalParameters_ocf;

#pragma mark - Convenience
@property (nonatomic, readonly) NSData *data_ocf;

@end



//@synthesize block=_block;
//- (id)handleConnection:(HTTPConnection *)aConnection URL:(NSString *)URL	{
//    OnigResult *result = [_route match:URL];
//    if(result) {
//        NSMutableArray *args = [[result strings] mutableCopy];
//        [args replaceObjectAtIndex:0 withObject:aConnection];
//        return CallBlockWithArguments(self.block, args);
//    }
//    return HTTPSentinel;
//}
