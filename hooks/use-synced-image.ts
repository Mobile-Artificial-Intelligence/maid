import supabase, { isAnonymous } from "@/utilities/supabase";
import AsyncStorage from "@react-native-async-storage/async-storage";
import { Buffer } from "buffer";
import * as FileSystem from "expo-file-system";
import { Dispatch, SetStateAction, useEffect, useRef, useState } from "react";

async function uploadImageFromUri(opts: {
  bucket: string;
  path: string;        // e.g. `${user.id}.jpg`
  uri: string;         // file://...
  contentType?: string; // "image/jpeg"
}) {
  const { bucket, path, uri, contentType = "image/jpeg" } = opts;

  // Read the file from disk as base64
  const base64 = await FileSystem.readAsStringAsync(uri, {
    encoding: FileSystem.EncodingType.Base64,
  });

  // Convert base64 -> bytes
  const bytes = Uint8Array.from(Buffer.from(base64, "base64"));

  const { error } = await supabase.storage
    .from(bucket)
    .upload(path, bytes, {
      upsert: true,
      contentType,
      cacheControl: "3600",
    });

  if (error) throw error;
}

function useSyncedImage(
  authenticated: boolean,
  options: { key: string, bucket: string, ext?: string }
): [string | undefined, Dispatch<SetStateAction<string | undefined>>] {
  const { key, bucket, ext = "jpg" } = options;
  const [imageUri, setImageUri] = useState<string | undefined>(undefined);

  const hydratingRef = useRef(false);
  const lastUploadedRef = useRef<string | undefined>(undefined);

  const objectPathForUser = (userId: string) => `${userId}.${ext}`;

  const saveLocal = async (uri: string | undefined) => {
    try {
      if (uri) await AsyncStorage.setItem(key, uri);
      else await AsyncStorage.removeItem(key);
    } catch (e) {
      console.error(`Error saving ${key}:`, e);
    }
  };

  const loadLocal = async () => {
    try {
      return await AsyncStorage.getItem(key);
    } catch (e) {
      console.error(`Error loading ${key}:`, e);
      return null;
    }
  };

  const loadSupabaseUrl = async (): Promise<string | null> => {
    if (await isAnonymous()) {
      console.warn("User is anonymous; skipping Supabase load");
      return null;
    }

    const { data: userRes, error: userErr } = await supabase.auth.getUser();
    if (userErr) {
      console.error("getUser error:", userErr);
      return null;
    }
    const user = userRes.user;
    if (!user) return null;

    const path = objectPathForUser(user.id);

    // If bucket is PUBLIC you can use getPublicUrl instead.
    const { data, error } = await supabase.storage
      .from(bucket)
      .createSignedUrl(path, 3600);

    if (error) {
      // Most common: 404 (no image yet)
      // Log it so you can see what's happening:
      console.warn(`Storage signedUrl error (${bucket}/${path}):`, error.message);
      return null;
    }

    // Cache-bust so Image refreshes when you re-upload
    const url = `${data.signedUrl}${data.signedUrl.includes("?") ? "&" : "?"}t=${Date.now()}`;
    return url;
  };

  const saveSupabase = async (uri: string) => {
    if (await isAnonymous()) {
      console.warn("User is anonymous; skipping Supabase save");
      return;
    }

    const { data: userRes, error: userErr } = await supabase.auth.getUser();
    if (userErr) {
      console.error("getUser error:", userErr);
      return;
    }
    const user = userRes.user;
    if (!user) return;

    // If uri is already a signed/public URL from storage, don't re-upload it.
    // (Otherwise you can get weird loops.)
    if (uri.startsWith("http://") || uri.startsWith("https://")) return;

    if (lastUploadedRef.current === uri) return;

    if (!imageUri || imageUri.startsWith("http")) return;

    try {
      const path = `${user.id}.jpg`;

      await uploadImageFromUri({
        bucket,
        path,
        uri: imageUri!,
        contentType: "image/jpeg",
      });

      lastUploadedRef.current = uri;
    } catch (e) {
      console.error(`Error saving ${bucket} image:`, e);
    }
  };

  // Load on auth change
  useEffect(() => {
    (async () => {
      hydratingRef.current = true;
      try {
        if (authenticated) {
          // Prefer remote when signed in
          const remoteUrl = await loadSupabaseUrl();
          if (remoteUrl) {
            setImageUri(remoteUrl);
            // also persist locally as a fallback (optional)
            await saveLocal(remoteUrl);
            return;
          }
          // fallback to local if remote missing
          const local = await loadLocal();
          if (local) setImageUri(local);
        } else {
          const local = await loadLocal();
          if (local) setImageUri(local);
          else setImageUri(undefined);
        }
      } finally {
        hydratingRef.current = false;
      }
    })();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [authenticated, bucket, key, ext]);

  // Persist when changed
  useEffect(() => {
    (async () => {
      if (hydratingRef.current) return;

      await saveLocal(imageUri);

      if (authenticated && imageUri) {
        await saveSupabase(imageUri);
        // After upload, refresh signed URL so you see the new image immediately
        const remoteUrl = await loadSupabaseUrl();
        if (remoteUrl) setImageUri(remoteUrl);
      }
    })();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [imageUri, authenticated]);

  return [imageUri, setImageUri];
}

export default useSyncedImage;
