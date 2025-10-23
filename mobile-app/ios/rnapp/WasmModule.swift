import Foundation
import React

@objc(WasmModule)
class WasmModule: NSObject {
  
  @objc
  static func requiresMainQueueSetup() -> Bool {
    return false
  }
  
  @objc
  func add(_ a: Int, b: Int, resolver: @escaping RCTPromiseResolveBlock, rejecter: @escaping RCTPromiseRejectBlock) {
    do {
      let result = WasmManager.shared.callAdd(a: a, b: b)
      resolver(result)
    } catch {
      rejecter("WASM_ERROR", "Failed to execute WASM add function", error)
    }
  }
}
