#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(WasmModule, NSObject)

RCT_EXTERN_METHOD(add:(NSInteger)a
                  b:(NSInteger)b
                  resolver:(RCTPromiseResolveBlock)resolver
                  rejecter:(RCTPromiseRejectBlock)rejecter)

@end
