import Dropdown from "@/components/dropdowns/dropdown";
import { useSystem, useTTS } from "@/context";
import { KokoroVoice, KokoroVoices } from "expo-kokoro";
import { StyleSheet, Text, View } from "react-native";

function VoiceDropdown() {
  const { voice, setVoice } = useTTS();
  const { colorScheme } = useSystem();

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
  const items = KokoroVoices.map((voice) => {
    return {
      label: (
        <View style={styles.label}>
          <Text style={styles.title}>{voice.name}</Text>
          <Text style={styles.subtitle}>{`Gender: ${voice.gender}`}</Text>
          <Text style={styles.subtitle}>{`Nationality: ${voice.nationality}`}</Text>
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
      <Dropdown<KokoroVoice>
        items={items}
        selectedValue={voice}
        onValueChange={setVoice}
      />
    </View>
  );
}

export default VoiceDropdown;