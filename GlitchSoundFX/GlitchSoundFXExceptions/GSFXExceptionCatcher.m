#import "include/GSFXExceptionCatcher.h"

NSException *_Nullable GSFXCatchException(NS_NOESCAPE void (^block)(void)) {
    @try {
        block();
        return nil;
    } @catch (NSException *exception) {
        return exception;
    }
}
