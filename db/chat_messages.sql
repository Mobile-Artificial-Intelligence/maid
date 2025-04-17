create extension if not exists "uuid-ossp";

create table chat_messages (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid references auth.users(id) on delete cascade,
  role text not null,
  content text not null,
  parent uuid references chat_messages(id) on delete cascade,
  current_child uuid references chat_messages(id),
  children uuid[] default '{}',
  create_time timestamptz default now(),
  update_time timestamptz default now()
);

alter table chat_messages enable row level security;

create policy "Allow users to access their own messages"
  on chat_messages for all
  using (auth.uid() = user_id);