import { useSystem } from "@/context";
import MaterialCommunityIcons from '@expo/vector-icons/MaterialCommunityIcons';
import MaterialIcons from '@expo/vector-icons/MaterialIcons';
import { StyleProp, TouchableOpacity, ViewStyle } from "react-native";

interface IconButtonProps {
  icon: string;
  size?: number;
  color?: string;
  disabledColor?: string;
  style?: StyleProp<ViewStyle>;
  disabled?: boolean;
  onPress: () => void;
}

export function MaterialIconButton(props: IconButtonProps) {
  const { colorScheme } = useSystem();

  return (
    <TouchableOpacity 
      style={[props.style, { margin: 4 }]}
      onPress={props.onPress}
      disabled={props.disabled}
    >
      <MaterialIcons
        name={props.icon as any}
        size={props.size ?? 28}
        color={props.disabled ? (props.disabledColor ?? colorScheme.outline) : (props.color ?? colorScheme.onSurface)}
      />
    </TouchableOpacity>
  );
}

export function MaterialCommunityIconButton(props: IconButtonProps) {
  const { colorScheme } = useSystem();

  return (
    <TouchableOpacity 
      style={[props.style, { margin: 4 }]}
      onPress={props.onPress}
      disabled={props.disabled}
    >
      <MaterialCommunityIcons
        name={props.icon as any}
        size={props.size ?? 28}
        color={props.disabled ? (props.disabledColor ?? colorScheme.outline) : (props.color ?? colorScheme.onSurface)}
      />
    </TouchableOpacity>
  );
}