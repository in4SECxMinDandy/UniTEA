-- Add a foreign key to profiles explicitly so PostgREST can resolve the join automatically
ALTER TABLE public.orders
  ADD CONSTRAINT orders_user_id_profiles_fkey
  FOREIGN KEY (user_id)
  REFERENCES public.profiles(id)
  ON DELETE CASCADE;
