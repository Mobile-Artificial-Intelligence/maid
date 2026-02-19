// jest.env.js
require("dotenv").config({ path: ".env" });

// Optional: fallbacks so tests don’t crash if .env is missing in CI
process.env.EXPO_PUBLIC_SUPABASE_URL ||= "https://example.supabase.co";
process.env.EXPO_PUBLIC_SUPABASE_KEY ||= "test-anon-key";