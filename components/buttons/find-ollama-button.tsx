import { useLLM, useSystem } from "@/context";
import * as Network from "expo-network";
import { StyleSheet, Text, TouchableOpacity } from "react-native";

function FindOllamaButton() {
  const { type, setBaseURL } = useLLM();
  const { colorScheme } = useSystem();

  if (type !== "Ollama" || !setBaseURL) return null;

  const styles = StyleSheet.create({
    button: { 
      color: colorScheme.primary,
      backgroundColor: colorScheme.surfaceVariant,
      paddingVertical: 8,
      paddingHorizontal: 16,
      borderRadius: 20,
    }
  });

  const onPress = async () => {
    const ip = await Network.getIpAddressAsync();
    if (!ip) throw new Error("Could not determine local IP");
  
    const subnetPrefix = ip.split(".").slice(0, 3).join(".");
  
    const probes = [];
    for (let i = 2; i < 255; i++) {
      const target = `${subnetPrefix}.${i}`;
      const url = `http://${target}:11434`;
  
      const probe = fetch(url, { method: "GET" })
        .then((res) => {
          if (res.ok) {
            return url; // return just the working URI
          }
          throw new Error("Not OK");
        })
        .catch(() => {
          throw null; // force rejection so Promise.any ignores it
        });
  
      probes.push(probe);
    }
  
    let foundHost;
    try {
      foundHost = await Promise.any(probes);
    } 
    catch {
      console.log("No Ollama instance found on the local network.");
    }

    if (foundHost) {
      setBaseURL(foundHost);
    } else {
      alert("Could not find Ollama on the local network.");
    }
  };

  return (
    <TouchableOpacity
      onPress={onPress}
    >
      <Text style={styles.button}>
        Find Ollama
      </Text>
    </TouchableOpacity>
  );
}

export default FindOllamaButton;