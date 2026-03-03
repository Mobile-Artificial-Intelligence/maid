import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";
const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, content-type"
};
function json(data, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: {
      ...corsHeaders,
      "content-type": "application/json; charset=utf-8"
    }
  });
}
Deno.serve(async (req)=>{
  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", {
      headers: corsHeaders
    });
  }
  try {
    // 🔐 Get JWT from Authorization header
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return json({
        error: "Missing Authorization header"
      }, 401);
    }
    const token = authHeader.replace("Bearer ", "");
    // 🔐 Create client with user's JWT (for auth verification)
    const supabaseUserClient = createClient(Deno.env.get("SUPABASE_URL"), Deno.env.get("SUPABASE_ANON_KEY"), {
      global: {
        headers: {
          Authorization: `Bearer ${token}`
        }
      }
    });
    // 🔍 Get the authenticated user
    const { data: { user }, error: userError } = await supabaseUserClient.auth.getUser();
    if (userError || !user) {
      return json({
        error: "Invalid or expired token"
      }, 401);
    }
    // 🔐 Admin client for deleting the user
    const supabaseAdmin = createClient(Deno.env.get("SUPABASE_URL"), Deno.env.get("SUPABASE_SERVICE_ROLE_KEY"));
    // 🗑 Delete the user
    const { error: deleteError } = await supabaseAdmin.auth.admin.deleteUser(user.id);
    if (deleteError) {
      console.error(deleteError);
      return json({
        error: "Failed to delete user"
      }, 500);
    }
    return json({
      success: true,
      message: "Account deleted"
    });
  } catch (err) {
    console.error(err);
    return json({
      error: "Unexpected error"
    }, 500);
  }
});
