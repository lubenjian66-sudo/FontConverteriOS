#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PythonRuntimeManager : NSObject
+ (instancetype)shared;
- (BOOL)start:(NSError * _Nullable * _Nullable)error;
@end

NS_ASSUME_NONNULL_END
