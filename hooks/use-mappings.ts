import validateMappings from '@/utilities/mappings';
import supabase from '@/utilities/supabase';
import AsyncStorage from '@react-native-async-storage/async-storage';
import * as Application from "expo-application";
import * as Device from "expo-device";
import { MessageNode } from 'message-nodes';
import { Dispatch, SetStateAction, useEffect, useState } from "react";

function useMappings(authenticated: boolean): [Record<string, MessageNode<string, Record<string, any>>>, Dispatch<SetStateAction<Record<string, MessageNode<string, Record<string, any>>>>>] {
  const [mappings, setMappings] = useState<Record<string, MessageNode<string>>>({});

  const saveSupabaseMappings = async () => {
    const { data: { user }, error: userErr } = await supabase.auth.getUser();
    if (userErr) {
      console.error("getUser error:", userErr);
      return;
    }
    if (!user) {
      console.warn("Not signed in; skipping save");
      return;
    }

    const nodes = Object.values(mappings);

    const upsertData = nodes.map(node => ({
      id: node.id,
      user_id: user.id,
      role: node.role,
      content: node.content || "New Chat",
      root: node.root,
      parent: node.parent ?? null,
      child: node.child ?? null,
      metadata: {
        appVersion: node.metadata?.appVersion || Application.nativeApplicationVersion || undefined,
        appBuild: node.metadata?.appBuild || Application.nativeBuildVersion || undefined,
        device: node.metadata?.device || Device.modelName || undefined,
        osBuildId: node.metadata?.osBuildId || Device.osBuildId || undefined,
        osVersion: node.metadata?.osVersion || Device.osVersion || undefined,
        cpu: node.metadata?.cpu || Device.supportedCpuArchitectures || undefined,
        ram: node.metadata?.ram || Device.totalMemory || undefined,
        createTime: node.metadata?.createTime || new Date().toISOString(),
        updateTime: node.metadata?.updateTime || new Date().toISOString(),
      }
    }));

    const { error } = await supabase
      .from("messages")
      .upsert(upsertData, { onConflict: "id" }); // explicit

    if (error) console.error("Error saving messages:", error);
  };

  useEffect(() => {
    if (!authenticated) return;

    const timeout = setTimeout(() => {
      saveSupabaseMappings();
    }, 5000); // Save every 5 seconds

    return () => clearTimeout(timeout);
  }, [mappings, authenticated]);

  const loadSupabaseMappings = async () => {
    const userResponse = await supabase.auth.getUser();
    const user = userResponse.data.user;
    
    if (!user) {
      throw new Error("No user logged in");
    }

    const { data, error } = await supabase
      .from('messages')
      .select('*');

    if (error) {
      throw new Error("Failed to load chat messages");
    }

    const map: Record<string, MessageNode> = data.map(item => ({
      id: item.id,
      role: item.role,
      content: item.content,
      root: item.root,
      parent: item.parent || undefined,
      child: item.child || undefined,
      metadata: item.metadata || undefined,
    })).reduce(
      (acc, node) => {
        acc[node.id] = node;
        return acc;
      },
      {} as Record<string, MessageNode>
    );

    const validMap = validateMappings(map);

    setMappings(prev => ({ ...prev, ...validMap }));
  };

  useEffect(() => {
    if (authenticated) {
      loadSupabaseMappings().catch((error) => {
        console.error("Error loading messages:", error);
      });
    }
  }, [authenticated]);

  const saveLocalMappings = async () => {
    try {
      await AsyncStorage.setItem("mappings", JSON.stringify(mappings));
    } catch (error) {
      console.error("Error saving mappings:", error);
    }
  };

  useEffect(() => {
    const timeout = setTimeout(() => {
      saveLocalMappings();
    }, 5000); // 5 seconds

    return () => clearTimeout(timeout);
  }, [mappings]);

  const loadLocalMappings = async () => {
    try {
      const storedMappings = await AsyncStorage.getItem("mappings");
      if (storedMappings) {
        const parsed = JSON.parse(storedMappings) as Record<string, MessageNode<string>>;
        setMappings(prev => ({ ...prev, ...parsed }));
      }
    } catch (error) {
      console.error("Error loading mappings:", error);
    }
  };

  useEffect(() => {
    loadLocalMappings();
  }, []);

  return [mappings, setMappings];
}

export default useMappings;