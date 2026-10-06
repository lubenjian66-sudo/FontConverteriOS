#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FontPythonBridge : NSObject
+ (void)convertSource:(NSString *)sourcePath
          templatePath:(NSString *)templatePath
            outputPath:(NSString *)outputPath
               ttcMode:(BOOL)ttcMode
          manualScale:(double)manualScale
            completion:(void (^)(BOOL success, NSString * _Nullable errorMessage))completion;
@end

NS_ASSUME_NONNULL_END
