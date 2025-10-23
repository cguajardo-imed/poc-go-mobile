package com.anonymous.rnapp.wasmbridge

import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.Promise
import com.anonymous.rnapp.wasmmanager.WasmManager

class WasmModule(reactContext: ReactApplicationContext) : ReactContextBaseJavaModule(reactContext) {

    override fun getName(): String = "WasmModule"

    @ReactMethod
    fun add(a: Int, b: Int, promise: Promise) {
        try {

            val result = WasmManager.callAdd(a, b)
            promise.resolve(result)
        } catch (e: Exception) {
            promise.reject("WASM_ERROR", e)
        }
    }
}

