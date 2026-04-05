require('dotenv').config({ path: '.env.local' });
const { createClient } = require('@supabase/supabase-js');
const fs = require('fs');

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL,
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY
);

async function testAuthUpload() {
  // First login as the superadmin or an existing user to get an authenticated session
  // We can just create a dummy user or login using our stored credentials.
  // We need the email/password of an admin.
  // Wait, I can just use a dummy user and give them STORE_ADMIN role, or just see if the upload works for *any* authenticated user.
  const email = `test-upload-${Date.now()}@test.com`;
  const { data: authData, error: authError } = await supabase.auth.signUp({
    email,
    password: 'password123',
    options: {
      data: { full_name: 'Test Uploader' },
    }
  });

  if (authError) {
    console.error('Sign up error:', authError);
    return;
  }

  console.log('Logged in as:', authData.user.id);

  // Buffer representing a 1x1 png image
  const buffer = Buffer.from("iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=", "base64");
  const blob = new Blob([buffer], { type: 'image/png' });
  const filename = `${Date.now()}.png`;

  console.log('Attempting upload to', filename);
  const { data, error } = await supabase.storage
    .from('food-images')
    .upload(filename, blob);

  if (error) {
    console.error('Upload Error Details:');
    console.error(JSON.stringify(error, null, 2));
  } else {
    console.log('Upload Success:', data);
  }
}

testAuthUpload();
