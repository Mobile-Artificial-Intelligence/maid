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

create or replace function delete_if_both_null() 
returns trigger as $$
begin
    -- Check if both parent and current_child are NULL
    if new.parent is null and new.current_child is null then
        -- Delete the row
        delete from chat_messages where id = old.id;
    end if;
    -- Return the new row (or NULL if you don't want to update it)
    return new;
end;
$$ language plpgsql;