-- Enable RLS for storage
alter table storage.objects enable row level security;

-- Allow user to read *only their own profile image*
create policy "Users can read their own profile image"
on storage.objects for select
using (
  bucket_id = 'avatars'
  AND auth.uid() IS NOT NULL
  AND storage.objects.name = auth.uid() || '.jpg'
);

-- Allow user to insert *only their own profile image*
create policy "Users can upload their own profile image"
on storage.objects for insert
with check (
  bucket_id = 'avatars'
  AND auth.uid() IS NOT NULL
  AND storage.objects.name = auth.uid() || '.jpg'
);

-- Allow user to update *only their own profile image*
create policy "Users can upsert own profile image"
on storage.objects for all
using (
  bucket_id = 'avatars'
  AND auth.uid() = substring(name from '[^/]+')::uuid
);
