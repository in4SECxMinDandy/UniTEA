-- ============================================================
-- Fix Food Images Storage — create bucket + RLS policies
-- Root cause: food-images bucket was never created in migrations.
-- Also adds storage RLS policies for both chat-images and food-images.
-- ============================================================

-- 1. Create food-images storage bucket
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'food-images',
  'food-images',
  true,
  5242880,  -- 5 MB
  ARRAY['image/jpeg', 'image/png', 'image/gif', 'image/webp']
)
ON CONFLICT (id) DO NOTHING;

-- 2. RLS: anyone can view food images
DROP POLICY IF EXISTS "food_images_select_all" ON storage.objects;
CREATE POLICY "food_images_select_all"
  ON storage.objects FOR SELECT
  TO public
  USING (bucket_id = 'food-images');

-- 3. RLS: authenticated users can upload food images (to their own folder)
DROP POLICY IF EXISTS "food_images_insert_auth" ON storage.objects;
CREATE POLICY "food_images_insert_auth"
  ON storage.objects FOR INSERT
  TO authenticated
  WITH CHECK (
    bucket_id = 'food-images'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

-- 4. RLS: users can delete their own food images
DROP POLICY IF EXISTS "food_images_delete_own" ON storage.objects;
CREATE POLICY "food_images_delete_own"
  ON storage.objects FOR DELETE
  TO authenticated
  USING (
    bucket_id = 'food-images'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

-- 5. Also fix chat-images insert policy to restrict to user's own folder
DROP POLICY IF EXISTS "chat_images_insert_auth" ON storage.objects;
CREATE POLICY "chat_images_insert_auth"
  ON storage.objects FOR INSERT
  TO authenticated
  WITH CHECK (
    bucket_id = 'chat-images'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );
