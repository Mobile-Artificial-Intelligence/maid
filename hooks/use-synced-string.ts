import useAuthentication from "@/hooks/use-authentication";
import getSupabase from "@/utilities/supabase";
import AsyncStorage from "@react-native-async-storage/async-storage";
import { Dispatch, SetStateAction, useEffect, useRef, useState } from "react";

function normalizeString(value: unknown): string | undefined {
  if (typeof value !== "string") return undefined;
  const v = value.trim();
  return v.length ? v : undefined;
}

function useSyncedString(
  options: { key: string, defaultValue: string }
): [string | undefined, Dispatch<SetStateAction<string | undefined>>] {
  const [authenticated, anonymous] = useAuthentication();
  const { key, defaultValue } = options;

  const [value, setValue] = useState<string | undefined>(undefined);

  // Avoid saving before we've loaded once.
  const hydratedRef = useRef(false);

  // Track what we last saw on Supabase to avoid redundant updates.
  const lastRemoteRef = useRef<string | undefined>(undefined);

  // 1) LOAD (on mount + auth changes)
  useEffect(() => {
    let cancelled = false;

    const load = async () => {
      hydratedRef.current = false;

      try {
        if (authenticated && !anonymous) {
          const { data: { user }, error } = await getSupabase().auth.getUser();
          if (cancelled) return;

          if (error || !user) {
            console.warn("Not signed in / getUser failed; falling back to local");
            const stored = await AsyncStorage.getItem(key);
            if (cancelled) return;
            setValue(stored ?? defaultValue);
            return;
          }

          const remote = normalizeString((user.user_metadata as any)?.[key]);
          lastRemoteRef.current = remote;

          const next = remote ?? defaultValue;
          setValue(next);

          // Optional: keep local in sync with the remote we loaded
          if (remote && remote !== defaultValue) {
            await AsyncStorage.setItem(key, remote);
          } else {
            await AsyncStorage.removeItem(key);
          }
        } else {
          const stored = await AsyncStorage.getItem(key);
          if (cancelled) return;
          setValue(stored ?? defaultValue);
        }
      } catch (e) {
        console.error(`Error loading ${key}:`, e);
        if (!cancelled) setValue(defaultValue);
      } finally {
        if (!cancelled) hydratedRef.current = true;
      }
    };

    load();
    return () => {
      cancelled = true;
    };
  }, [authenticated, anonymous, key, defaultValue]);

  // 2) SAVE (when value changes, after initial hydration)
  useEffect(() => {
    if (!hydratedRef.current) return;
    if (value === undefined) return;

    const persist = async () => {
      try {
        // Local: treat default/empty as "unset" like your original code
        if (value && value !== defaultValue) {
          await AsyncStorage.setItem(key, value);
        } else {
          await AsyncStorage.removeItem(key);
        }

        if (!authenticated || anonymous) return;

        // Remote: only write non-default values (matching your current behavior)
        if (!value || value === defaultValue) return;

        // Skip if we already know remote matches
        if (value === lastRemoteRef.current) return;

        const { data: { user }, error: userErr } = await getSupabase().auth.getUser();
        if (userErr || !user) return;

        const currentRemote = normalizeString((user.user_metadata as any)?.[key]);
        if (currentRemote === value) {
          lastRemoteRef.current = value;
          return;
        }

        const { error } = await getSupabase().auth.updateUser({
          data: { [key]: value },
        });

        if (error) {
          console.error(`Error updating ${key}:`, error);
        } else {
          lastRemoteRef.current = value;
        }
      } catch (e) {
        console.error(`Error saving ${key}:`, e);
      }
    };

    persist();
  }, [value, authenticated, anonymous, key, defaultValue]);

  return [value, setValue];
}

export default useSyncedString;
