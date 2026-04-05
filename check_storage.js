const { createClient } = require('@supabase/supabase-js')
require('dotenv').config({ path: '.env.local' })

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL,
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY
)

async function run() {
  const { data, error } = await supabase.storage.getBucket('food-images')
  console.log('Bucket Error:', error)
  console.log('Bucket Data:', data)
  
  // Try sending a dummy upload
  const blob = new Blob(['dummy content'], { type: 'text/plain' })
  const { data: uploadData, error: uploadErr } = await supabase.storage.from('food-images').upload('test.png', blob, { upsert: true })
  console.log('Upload Result:', uploadData)
  console.log('Upload Error:', uploadErr)
}

run()
