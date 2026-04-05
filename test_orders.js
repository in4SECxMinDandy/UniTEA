require('dotenv').config({ path: '.env.local' });
const { createClient } = require('@supabase/supabase-js');

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL,
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY
);

async function checkSessions() {
  const { data, error } = await supabase
    .from('visit_sessions')
    .select('*, admin:profiles!visit_sessions_user_id_fkey(full_name)')
    .order('created_at', { ascending: false })
    .limit(50)

  console.log('Error:', error);
  console.log('Length:', data && data.length);
  
  if (error) {
    const { data: raw, error: rawError } = await supabase.from('visit_sessions').select('*');
    console.log('Raw:', raw);
  }
}

checkSessions();
