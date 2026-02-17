import AsyncStorage from '@react-native-async-storage/async-storage';
import { createClient, processLock } from '@supabase/supabase-js';
import 'react-native-url-polyfill/auto';

const supabase = createClient(
  process.env.EXPO_PUBLIC_SUPABASE_URL!,
  process.env.EXPO_PUBLIC_SUPABASE_KEY!,
  {
    auth: {
      storage: AsyncStorage,
      autoRefreshToken: true,
      persistSession: true,
      detectSessionInUrl: false,
      lock: processLock,
    },
  }
);

export async function isAuthenticated(): Promise<boolean> {
  try {
    const { data: sessionRes, error: sessionErr } = await supabase.auth.getSession();
    if (sessionErr) console.warn("getSession error:", sessionErr);

    let userId = sessionRes?.session?.user?.id;

    if (!userId) {
      const authAny = supabase.auth as any;

      if (typeof authAny.signInAnonymously !== "function") {
        console.error("Anonymous sign-in not supported. Update supabase-js and enable anonymous sign-ins in Supabase.");
        return false;
      }

      const { data: anonRes, error: anonErr } = await authAny.signInAnonymously();
      if (anonErr || !anonRes?.user?.id) {
        console.error("Anonymous sign-in failed:", anonErr);
        return false;
      }
    }

    return true;
  } catch (e) {
    console.error("Error checking authentication:", e);
    return false;
  }
}

export async function isAnonymous(): Promise<boolean> {
  const session = await supabase.auth.getSession().then(({ data }) => data.session).catch(() => null);
  const user = session?.user;
  if (!user) return false;

  // Newer SDKs expose `user.is_anonymous`; keep a fallback so TS/older builds don’t explode.
  const direct = (user as any).is_anonymous;
  if (typeof direct === "boolean") return direct;

  // Fallbacks (best-effort)
  const provider = (user.app_metadata as any)?.provider;
  if (provider === "anonymous") return true;

  const identities = (user as any).identities as Array<{ provider?: string }> | undefined;
  if (identities?.some((i) => i.provider === "anonymous")) return true;

  return false;
}

export default supabase;