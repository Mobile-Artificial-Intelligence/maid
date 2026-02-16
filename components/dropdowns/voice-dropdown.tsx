import Dropdown from "@/components/dropdowns/dropdown";
import { useSystem } from "@/context";
import { getAvailableVoicesAsync, Voice } from "expo-speech";
import { useEffect, useState } from "react";
import { StyleSheet, Text, View } from "react-native";

function VoiceDropdown() {
  const [voices, setVoices] = useState<Array<Voice>>([]);
  const { voice, setVoice } = useSystem();
  const { colorScheme } = useSystem();

  const loadVoices = async () => {
    const availableVoices = await getAvailableVoicesAsync();
    setVoices(availableVoices);
  };

  useEffect(() => {
    loadVoices();
  }, []);

  const styles = StyleSheet.create({
    view: {
      flexDirection: "row",
      alignItems: "center",
      justifyContent: "space-between",
      width: "100%",
    },
    label: {
      flexDirection: "column"
    },
    title: {
      color: colorScheme.onSurface,
      fontSize: 16
    },
    subtitle: { 
      color: colorScheme.onSurface, 
      fontSize: 12 
    },
  });

  // construct items by capitilizing the first letter of each voice
  const items = voices.map((voice) => {
    return {
      label: (
        <View style={styles.label}>
          <Text style={styles.title}>{voice.name}</Text>
          <Text style={styles.subtitle}>{`Language: ${voice.language}`}</Text>
          <Text style={styles.subtitle}>{`Quality: ${voice.quality}`}</Text>
        </View>
      ),
      selectedLabel: voice.name,
      value: voice
    }
  });

  return (
    <View style={styles.view}>
      <Text style={styles.title}>
        Voice
      </Text>
      {voices.length > 0 && (
        <Dropdown<Voice | undefined>
          items={items}
          selectedValue={voice}
          onValueChange={setVoice}
        />
      )}
    </View>
  );
}

export default VoiceDropdown;