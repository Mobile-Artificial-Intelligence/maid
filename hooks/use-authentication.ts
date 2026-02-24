import getSupabase from "@/utilities/supabase";
import type { Session } from "@supabase/supabase-js";
import { useEffect, useState } from "react";

function useAuthentication(): [boolean, boolean] {
  const [authenticated, setAuthenticated] = useState(false);
  const [anonymous, setAnonymous] = useState(false);

  useEffect(() => {
    const supabase = getSupabase();

    const applySession = (session: Session | null) => {
      const user = session?.user;

      if (user) {
        setAuthenticated(true);
        setAnonymous(user.is_anonymous ?? false);
      } else {
        setAuthenticated(false);
        setAnonymous(false);
      }
    };

    // 🔹 1. Check existing session on mount
    supabase.auth.getSession().then(({ data }) => {
      applySession(data.session);
    });

    // 🔹 2. Subscribe to auth changes
    const {
      data: { subscription },
    } = supabase.auth.onAuthStateChange((_event, session) => {
      applySession(session);
    });

    // 🔹 3. Cleanup
    return () => {
      subscription.unsubscribe();
    };
  }, []);

  return [authenticated, anonymous];
}

export default useAuthentication;