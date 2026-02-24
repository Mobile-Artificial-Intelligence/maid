import Dropdown from "@/components/dropdowns/dropdown";
import { useSystem } from "@/context";
import { getLocales } from 'expo-localization';
import { getAvailableVoicesAsync, Voice } from "expo-speech";
import { useEffect, useState } from "react";
import { StyleSheet, Text, View } from "react-native";

function getLanguage(tag: string): string {
  return tag.split("-")[0].toLowerCase();
}

function VoiceDropdown() {
  const [voices, setVoices] = useState<Array<Voice>>([]);
  const { voice, setVoice } = useSystem();
  const { colorScheme } = useSystem();

  const loadVoices = async () => {
    try {
      const locales = getLocales();
      const availableVoices = await getAvailableVoicesAsync();

      const filteredVoices = availableVoices.filter(voice =>
        locales.some(
          locale => getLanguage(locale.languageTag) === getLanguage(voice.language)
        )
      );

      setVoices(filteredVoices);
    } catch (error) {
      console.error("Error loading voices:", error);
    }
  };

  useEffect(() => {
    loadVoices();
    
    const interval = setInterval(() => {
      loadVoices();
    }, 10000);

    return () => clearInterval(interval);
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

  if (voices.length === 0) return null;

  return (
    <View style={styles.view}>
      <Text style={styles.title}>
        Voice
      </Text>
      <Dropdown<Voice | undefined>
        items={items}
        selectedValue={voice}
        onValueChange={setVoice}
      />
    </View>
  );
}

export default VoiceDropdown;