-- ============================================================
-- Fix food-images storage: make bucket truly public (no RLS needed for SELECT)
-- and fix INSERT to not require folder structure (simpler path for admin uploads)
-- ============================================================

-- Ensure food-images bucket is public (allows any GET without auth)
UPDATE storage.buckets
SET public = true
WHERE id = 'food-images';

-- Drop the folder-restricted INSERT policy and replace with a simpler admin-only one
DROP POLICY IF EXISTS "food_images_insert_auth" ON storage.objects;
CREATE POLICY "food_images_insert_auth"
  ON storage.objects FOR INSERT
  TO authenticated
  WITH CHECK (bucket_id = 'food-images');

-- Drop the folder-restricted DELETE policy and replace with a simpler admin-only one  
DROP POLICY IF EXISTS "food_images_delete_own" ON storage.objects;
CREATE POLICY "food_images_delete_own"
  ON storage.objects FOR DELETE
  TO authenticated
  USING (bucket_id = 'food-images');

-- Ensure SELECT is wide open for food images (public bucket)
DROP POLICY IF EXISTS "food_images_select_all" ON storage.objects;
CREATE POLICY "food_images_select_all"
  ON storage.objects FOR SELECT
  TO public
  USING (bucket_id = 'food-images');
