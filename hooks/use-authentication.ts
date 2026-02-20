import getSupabase from "@/utilities/supabase";
import { useEffect, useState } from "react";

function useAuthentication(): [boolean, boolean] {
  const [authenticated, setAuthenticated] = useState<boolean>(false);
  const [anonymous, setAnonymous] = useState<boolean>(false);

  useEffect(() => {
    const { data: subscription } = getSupabase().auth.onAuthStateChange(
      async (event, session) => {
        const user = session?.user;

        if (event === "SIGNED_IN" && user) {
          setAuthenticated(true);
          setAnonymous(user.is_anonymous || false);
        } else {
          setAuthenticated(false);
          setAnonymous(false);
        }
      }
    );

    return () => {
      subscription.subscription.unsubscribe();
    };
  }, []);

  return [authenticated, anonymous];
}

export default useAuthentication;