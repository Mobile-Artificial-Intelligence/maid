create extension if not exists "uuid-ossp";

create table messages (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid references auth.users(id) on delete cascade,
  role text not null,
  content text not null,
  parent uuid references messages(id) on delete cascade,
  child uuid references messages(id) on delete set null,
  metadata jsonb,
);

alter table messages enable row level security;

-- One policy that covers SELECT/INSERT/UPDATE/DELETE
create policy "Allow users to access their own messages"
on public.messages
for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

-- Trigger function to delete a message if both parent and child are NULL
create or replace function delete_if_both_null() 
returns trigger as $$
begin
    -- Check if both parent and child are NULL
    if new.parent is null and new.child is null then
        -- Delete the row
        delete from messages where id = old.id;
    end if;
    -- Return the new row (or NULL if you don't want to update it)
    return new;
end;
$$ language plpgsql;