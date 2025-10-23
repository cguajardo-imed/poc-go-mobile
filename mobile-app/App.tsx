import { StatusBar } from "expo-status-bar";
import { StyleSheet, Text, View, Button, NativeModules } from "react-native";
import { useEffect, useState } from "react";
const { WasmModule } = NativeModules;

export default function App() {
  console.log("WasmModule\t", { WasmModule });
  console.log("NativeModules\t", { NativeModules });
  const [result, setResult] = useState<number>(0);
  const [log, setLog] = useState<string[]>([]);

  const cLog = (...args: any[]) => {
    const parsedArgs = args.map((arg) => {
      return typeof arg === "object" ? JSON.stringify(arg) : String(arg);
    });

    console.log(...parsedArgs);
    setLog((prevLog) => [...prevLog, parsedArgs.join(" ")]);
  };

  async function doAdd(a: number, b: number) {
    const result = await WasmModule.add(a, b);
    cLog("WASM add result", result);
  }

  const RandomAdd = async () => {
    const a = Math.floor(Math.random() * 1000);
    const b = Math.floor(Math.random() * 1000);
    const r = await doAdd(a, b).catch((e) => {
      cLog("Error: ", e);
    });
    cLog("Result: ", r);
    if (typeof r === "number") setResult(r);
  };

  useEffect(() => {
    doAdd(1, 999).then((r) => {
      cLog("Result: ", r);
      if (typeof r === "number") setResult(r);
    });
  }, []);

  return (
    <View style={styles.container}>
      <Text>{result}</Text>
      <Button
        color="#841584"
        accessibilityLabel="Learn more about this purple button"
        onPress={() => RandomAdd()}
        title="Sumar Random"
      ></Button>
      <StatusBar style="auto" />
      <Text>{log}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: "#fff",
    alignItems: "center",
    justifyContent: "center",
  },
});
