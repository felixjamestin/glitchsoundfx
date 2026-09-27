#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Runs the block and returns the Objective-C exception it raised, because Swift cannot catch one.
FOUNDATION_EXPORT NSException *_Nullable GSFXCatchException(NS_NOESCAPE void (^block)(void));

NS_ASSUME_NONNULL_END
