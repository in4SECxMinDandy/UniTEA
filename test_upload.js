const { createClient } = require('@supabase/supabase-js')
require('dotenv').config({ path: '.env.local' })

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL,
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY
)

async function testUpload() {
  const fileContent = "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=";
  const buffer = Buffer.from(fileContent, 'base64');
  
  // Make a mocked user context. Actually, anon key can't upload without RLS login!
  // Wait, I need an authenticated session to simulate the browser upload!
  // But let's just see if anon upload gives 403 or 400.
  const { data, error } = await supabase.storage
    .from('food-images')
    .upload('test_anon.png', buffer, { contentType: 'image/png' })
  
  console.log('Upload Result:', data)
  console.log('Upload Error:', error ? JSON.stringify(error, null, 2) : null)
}

testUpload()
