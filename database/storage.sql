
-- READ (authenticated only)
create policy "Users can read their own user image"
on storage.objects
for select
to authenticated
using (
  bucket_id = 'user-images'
  and name = auth.uid()::text || '.jpg'
);

create policy "Users can read their own assistant image"
on storage.objects
for select
to authenticated
using (
  bucket_id = 'assistant-images'
  and name = auth.uid()::text || '.jpg'
);

-- INSERT (authenticated only)
create policy "Users can upload their own user image"
on storage.objects
for insert
to authenticated
with check (
  bucket_id = 'user-images'
  and name = auth.uid()::text || '.jpg'
);

create policy "Users can upload their own assistant image"
on storage.objects
for insert
to authenticated
with check (
  bucket_id = 'assistant-images'
  and name = auth.uid()::text || '.jpg'
);

-- UPDATE (authenticated only)
create policy "Users can update their own user image"
on storage.objects
for update
to authenticated
using (
  bucket_id = 'user-images'
  and name = auth.uid()::text || '.jpg'
)
with check (
  bucket_id = 'user-images'
  and name = auth.uid()::text || '.jpg'
);

create policy "Users can update their own assistant image"
on storage.objects
for update
to authenticated
using (
  bucket_id = 'assistant-images'
  and name = auth.uid()::text || '.jpg'
)
with check (
  bucket_id = 'assistant-images'
  and name = auth.uid()::text || '.jpg'
);

-- DELETE (optional, authenticated only)
create policy "Users can delete their own user image"
on storage.objects
for delete
to authenticated
using (
  bucket_id = 'user-images'
  and name = auth.uid()::text || '.jpg'
);

create policy "Users can delete their own assistant image"
on storage.objects
for delete
to authenticated
using (
  bucket_id = 'assistant-images'
  and name = auth.uid()::text || '.jpg'
);
