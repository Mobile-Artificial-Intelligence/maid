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