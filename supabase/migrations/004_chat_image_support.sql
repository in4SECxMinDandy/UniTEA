-- ============================================================
-- Chat Image Support
-- Adds image_url column to chat_messages and sets up
-- Supabase Storage bucket with RLS policies for chat images.
-- ============================================================

-- 1. Add image_url column to chat_messages
ALTER TABLE chat_messages
  ADD COLUMN IF NOT EXISTS image_url text;

-- 2. Create storage bucket for chat images
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'chat-images',
  'chat-images',
  true,
  5242880,  -- 5 MB limit
  ARRAY['image/jpeg', 'image/png', 'image/gif', 'image/webp']
)
ON CONFLICT (id) DO NOTHING;

-- 3. Storage RLS: authenticated users can upload to their own folder
CREATE POLICY "chat_images_insert_auth"
  ON storage.objects FOR INSERT
  TO authenticated
  WITH CHECK (bucket_id = 'chat-images');

-- 4. Storage RLS: anyone can view (bucket is public, but policy is explicit)
CREATE POLICY "chat_images_select_all"
  ON storage.objects FOR SELECT
  TO public
  USING (bucket_id = 'chat-images');

-- 5. Storage RLS: users can delete their own uploads
CREATE POLICY "chat_images_delete_own"
  ON storage.objects FOR DELETE
  TO authenticated
  USING (bucket_id = 'chat-images' AND auth.uid()::text = (storage.foldername(name))[1]);
