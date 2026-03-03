

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;


CREATE EXTENSION IF NOT EXISTS "pg_cron" WITH SCHEMA "pg_catalog";






COMMENT ON SCHEMA "public" IS 'standard public schema';



CREATE EXTENSION IF NOT EXISTS "pg_net" WITH SCHEMA "public";






CREATE SCHEMA IF NOT EXISTS "private";


ALTER SCHEMA "private" OWNER TO "postgres";


CREATE EXTENSION IF NOT EXISTS "pg_graphql" WITH SCHEMA "graphql";






CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pgjwt" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "supabase_vault" WITH SCHEMA "vault";






CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";






CREATE OR REPLACE FUNCTION "public"."delete_if_both_null"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
begin
    -- Check if both parent and child are NULL
    if new.parent is null and new.child is null then
        -- Delete the row
        delete from messages where id = new.id;
    end if;
    -- Return the new row (or NULL if you don't want to update it)
    return new;
end;
$$;


ALTER FUNCTION "public"."delete_if_both_null"() OWNER TO "postgres";

SET default_tablespace = '';

SET default_table_access_method = "heap";


CREATE TABLE IF NOT EXISTS "public"."messages" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "user_id" "uuid",
    "role" "text" NOT NULL,
    "content" "text" NOT NULL,
    "parent" "uuid",
    "child" "uuid",
    "root" "uuid",
    "metadata" "jsonb"
);


ALTER TABLE "public"."messages" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."ollama_cloud" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "ip" "text" NOT NULL,
    "port" smallint NOT NULL,
    "ping" smallint,
    "last_checked" timestamp without time zone,
    "models" "text"[]
);


ALTER TABLE "public"."ollama_cloud" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."reports" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "content" "text" NOT NULL,
    "provider" "text" NOT NULL,
    "model" "text" NOT NULL,
    "upvoted" boolean DEFAULT false NOT NULL,
    "time" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "reports_content_len" CHECK ((("char_length"("content") >= 1) AND ("char_length"("content") <= 5000))),
    CONSTRAINT "reports_model_len" CHECK ((("char_length"("model") >= 1) AND ("char_length"("model") <= 200))),
    CONSTRAINT "reports_provider_len" CHECK ((("char_length"("provider") >= 1) AND ("char_length"("provider") <= 100)))
);


ALTER TABLE "public"."reports" OWNER TO "postgres";


ALTER TABLE ONLY "public"."messages"
    ADD CONSTRAINT "chat_messages_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."ollama_cloud"
    ADD CONSTRAINT "ollama_cloud_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."reports"
    ADD CONSTRAINT "reports_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."messages"
    ADD CONSTRAINT "chat_messages_child_fkey" FOREIGN KEY ("child") REFERENCES "public"."messages"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."messages"
    ADD CONSTRAINT "chat_messages_parent_fkey" FOREIGN KEY ("parent") REFERENCES "public"."messages"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."messages"
    ADD CONSTRAINT "chat_messages_root_fkey" FOREIGN KEY ("root") REFERENCES "public"."messages"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."messages"
    ADD CONSTRAINT "chat_messages_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



CREATE POLICY "Allow anonymous inserts" ON "public"."reports" FOR INSERT TO "authenticated", "anon" WITH CHECK (true);



CREATE POLICY "Allow users to access their own messages" ON "public"."messages" USING ((("auth"."uid"() = "user_id") AND ((("auth"."jwt"() ->> 'is_anonymous'::"text"))::boolean = false))) WITH CHECK ((("auth"."uid"() = "user_id") AND ((("auth"."jwt"() ->> 'is_anonymous'::"text"))::boolean = false)));



CREATE POLICY "Deny deletes" ON "public"."reports" FOR DELETE TO "authenticated", "anon" USING (false);



CREATE POLICY "Deny updates" ON "public"."reports" FOR UPDATE TO "authenticated", "anon" USING (false);



ALTER TABLE "public"."messages" ENABLE ROW LEVEL SECURITY;


-- Row Level Security is enabled on ollama_cloud; define policies to control access
CREATE POLICY "Allow users to access their own ollama_cloud rows"
    ON "public"."ollama_cloud"
    USING ((("auth"."uid"() = "user_id") AND ((("auth"."jwt"() ->> 'is_anonymous'::"text"))::boolean = false)))
    WITH CHECK ((("auth"."uid"() = "user_id") AND ((("auth"."jwt"() ->> 'is_anonymous'::"text"))::boolean = false)));

CREATE POLICY "Deny deletes from ollama_cloud"
    ON "public"."ollama_cloud"
    FOR DELETE
    TO "authenticated", "anon"
    USING (false);

ALTER TABLE "public"."ollama_cloud" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."reports" ENABLE ROW LEVEL SECURITY;




ALTER PUBLICATION "supabase_realtime" OWNER TO "postgres";





GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";
































































































































































































GRANT ALL ON FUNCTION "public"."delete_if_both_null"() TO "anon";
GRANT ALL ON FUNCTION "public"."delete_if_both_null"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."delete_if_both_null"() TO "service_role";
























GRANT ALL ON TABLE "public"."messages" TO "authenticated";
GRANT ALL ON TABLE "public"."messages" TO "service_role";



GRANT ALL ON TABLE "public"."ollama_cloud" TO "authenticated";
GRANT ALL ON TABLE "public"."ollama_cloud" TO "service_role";



GRANT INSERT,REFERENCES,TRIGGER,TRUNCATE ON TABLE "public"."reports" TO "anon";
GRANT INSERT,REFERENCES,TRIGGER,TRUNCATE ON TABLE "public"."reports" TO "authenticated";
GRANT ALL ON TABLE "public"."reports" TO "service_role";









ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "service_role";






























drop extension if exists "pg_net";

create extension if not exists "pg_net" with schema "public";

drop policy "Allow anonymous inserts" on "public"."reports";

drop policy "Deny deletes" on "public"."reports";

drop policy "Deny updates" on "public"."reports";

revoke delete on table "public"."messages" from "anon";

revoke insert on table "public"."messages" from "anon";

revoke references on table "public"."messages" from "anon";

revoke select on table "public"."messages" from "anon";

revoke trigger on table "public"."messages" from "anon";

revoke truncate on table "public"."messages" from "anon";

revoke update on table "public"."messages" from "anon";

revoke delete on table "public"."reports" from "anon";

revoke select on table "public"."reports" from "anon";

revoke update on table "public"."reports" from "anon";

revoke delete on table "public"."reports" from "authenticated";

revoke select on table "public"."reports" from "authenticated";

revoke update on table "public"."reports" from "authenticated";


  create policy "Allow anonymous inserts"
  on "public"."reports"
  as permissive
  for insert
  to anon, authenticated
with check (true);



  create policy "Deny deletes"
  on "public"."reports"
  as permissive
  for delete
  to anon, authenticated
using (false);



  create policy "Deny updates"
  on "public"."reports"
  as permissive
  for update
  to anon, authenticated
using (false);



  create policy "Users can delete their own assistant image"
  on "storage"."objects"
  as permissive
  for delete
  to authenticated
using (((bucket_id = 'assistant-images'::text) AND (name = ((auth.uid())::text || '.jpg'::text)) AND (((auth.jwt() ->> 'is_anonymous'::text))::boolean = false)));



  create policy "Users can delete their own user image"
  on "storage"."objects"
  as permissive
  for delete
  to authenticated
using (((bucket_id = 'user-images'::text) AND (name = ((auth.uid())::text || '.jpg'::text)) AND (((auth.jwt() ->> 'is_anonymous'::text))::boolean = false)));



  create policy "Users can read their own assistant image"
  on "storage"."objects"
  as permissive
  for select
  to authenticated
using (((bucket_id = 'assistant-images'::text) AND (name = ((auth.uid())::text || '.jpg'::text)) AND (((auth.jwt() ->> 'is_anonymous'::text))::boolean = false)));



  create policy "Users can read their own user image"
  on "storage"."objects"
  as permissive
  for select
  to authenticated
using (((bucket_id = 'user-images'::text) AND (name = ((auth.uid())::text || '.jpg'::text)) AND (((auth.jwt() ->> 'is_anonymous'::text))::boolean = false)));



  create policy "Users can update their own assistant image"
  on "storage"."objects"
  as permissive
  for update
  to authenticated
using (((bucket_id = 'assistant-images'::text) AND (name = ((auth.uid())::text || '.jpg'::text)) AND (((auth.jwt() ->> 'is_anonymous'::text))::boolean = false)))
with check (((bucket_id = 'assistant-images'::text) AND (name = ((auth.uid())::text || '.jpg'::text)) AND (((auth.jwt() ->> 'is_anonymous'::text))::boolean = false)));



  create policy "Users can update their own user image"
  on "storage"."objects"
  as permissive
  for update
  to authenticated
using (((bucket_id = 'user-images'::text) AND (name = ((auth.uid())::text || '.jpg'::text)) AND (((auth.jwt() ->> 'is_anonymous'::text))::boolean = false)))
with check (((bucket_id = 'user-images'::text) AND (name = ((auth.uid())::text || '.jpg'::text)) AND (((auth.jwt() ->> 'is_anonymous'::text))::boolean = false)));



  create policy "Users can upload their own assistant image"
  on "storage"."objects"
  as permissive
  for insert
  to authenticated
with check (((bucket_id = 'assistant-images'::text) AND (name = ((auth.uid())::text || '.jpg'::text)) AND (((auth.jwt() ->> 'is_anonymous'::text))::boolean = false)));



  create policy "Users can upload their own user image"
  on "storage"."objects"
  as permissive
  for insert
  to authenticated
with check (((bucket_id = 'user-images'::text) AND (name = ((auth.uid())::text || '.jpg'::text)) AND (((auth.jwt() ->> 'is_anonymous'::text))::boolean = false)));



