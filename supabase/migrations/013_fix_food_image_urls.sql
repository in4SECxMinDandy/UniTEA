-- ============================================================
-- Fix food image URLs — add /public/ segment to existing URLs
-- Root cause: images were stored without /public/ in path,
-- causing 400 errors when bucket RLS requires authenticated access.
-- ============================================================

-- Update food image URLs: replace /object/food-images/ with /object/public/food-images/
UPDATE foods
SET image_url = REPLACE(
  image_url,
  '/storage/v1/object/food-images/',
  '/storage/v1/object/public/food-images/'
)
WHERE image_url LIKE '%/storage/v1/object/food-images/%'
  AND image_url NOT LIKE '%/storage/v1/object/public/food-images/%';

-- Also fix food_categories image URLs if any
UPDATE food_categories
SET image_url = REPLACE(
  image_url,
  '/storage/v1/object/food-images/',
  '/storage/v1/object/public/food-images/'
)
WHERE image_url LIKE '%/storage/v1/object/food-images/%'
  AND image_url NOT LIKE '%/storage/v1/object/public/food-images/%';
