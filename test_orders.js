require('dotenv').config({ path: '.env.local' });
const { createClient } = require('@supabase/supabase-js');

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL,
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY
);

async function checkOrders() {
  const { data, error } = await supabase
    .from('orders')
    .select(`
      *,
      profiles!orders_user_id_fkey(full_name),
      food:foods(name, price)
    `)
    .order('created_at', { ascending: false })

  console.log('Error:', error);
  console.log('Orders:', data);
  
  // also get just raw orders without profiles to be sure
  const { data: rawData } = await supabase.from('orders').select('*');
  console.log('Raw Orders:', rawData);
}

checkOrders();
