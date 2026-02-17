import validateMappings from '@/utilities/mappings';
import supabase, { isAnonymous, isAuthenticated } from '@/utilities/supabase';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { MessageNode } from 'message-nodes';
import { Dispatch, SetStateAction, useEffect, useState } from "react";

function useMappings(): [Record<string, MessageNode<string, Record<string, any>>>, Dispatch<SetStateAction<Record<string, MessageNode<string, Record<string, any>>>>>] {
  const [mappings, setMappings] = useState<Record<string, MessageNode<string>>>({});

  const saveSupabaseMappings = async () => {
    if (!await isAuthenticated()) {
      console.warn("User not authenticated; skipping Supabase save");
      return;
    }

    if (await isAnonymous()) {
      console.warn("User is anonymous; skipping Supabase save");
      return;
    }

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
      content: node.content,
      root: node.root,
      parent: node.parent ?? null,
      child: node.child ?? null,
      metadata: {
        ...node.metadata,
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
    const timeout = setTimeout(() => {
      saveSupabaseMappings();
    }, 5000); // Save every 5 seconds

    return () => clearTimeout(timeout);
  }, [mappings]);

  const loadSupabaseMappings = async () => {
    if (!await isAuthenticated()) {
      console.warn("User not authenticated; skipping Supabase load");
      return;
    }

    if (await isAnonymous()) {
      console.warn("User is anonymous; skipping Supabase load");
      return;
    }

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
    const { data: subscription } = supabase.auth.onAuthStateChange(
      async (event, session) => {
        if (event !== "SIGNED_IN" || !session?.user) return;

        try {
          await loadSupabaseMappings();

          await saveSupabaseMappings();
        } 
        catch (error) {
          console.error("Error loading messages on auth change:", error);
        }
      }
    );

    return () => {
      subscription.subscription.unsubscribe();
    };
  }, []);

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