create extension if not exists "uuid-ossp";

create table public.reports (
  id uuid primary key default uuid_generate_v4(),
  content text not null,
  provider text not null,
  model text not null,
  upvoted boolean not null default false,
  time timestamptz not null default now()
);

alter table public.reports enable row level security;

create policy "Allow anonymous inserts"
on public.reports
for insert
to anon, authenticated
with check (true);

create policy "Deny updates"
on public.reports
for update
to anon, authenticated
using (false);

create policy "Deny deletes"
on public.reports
for delete
to anon, authenticated
using (false);

grant usage on schema public to anon, authenticated;
grant insert on table public.reports to anon, authenticated;

revoke select, update, delete on table public.reports from anon, authenticated;

alter table public.reports
  add constraint reports_content_len check (char_length(content) between 1 and 5000),
  add constraint reports_provider_len check (char_length(provider) between 1 and 100),
  add constraint reports_model_len check (char_length(model) between 1 and 200);