-- ============================================================
-- Anonymous Guest Chat — allow Supabase anonymous users to chat
-- Root cause: chat requires login; QR guests should not need account.
-- Solution: Use Supabase anonymous sign-in (anon JWT with uid).
--   anonymous users have auth.uid() but no email/profile.
-- ============================================================

-- 1. Allow anonymous users to insert into profiles (auto-create stub)
--    Anonymous users have auth.uid() set but no profile row yet.
DROP POLICY IF EXISTS "profiles_insert_anon" ON profiles;
CREATE POLICY "profiles_insert_anon" ON profiles FOR INSERT WITH CHECK (
  auth.uid() = id
);

-- 2. Allow anonymous users to select their own profile
--    (already covered by profiles_select_own but add explicit for anon)
--    profiles_select_own: auth.uid() = id — already works, no change needed.

-- 3. Allow authenticated (incl. anonymous) users to insert chat_sessions
--    Already exists: chat_sessions_insert_auth — auth.uid() IS NOT NULL
--    Anonymous users do have auth.uid() so this already works.

-- 4. Allow anonymous users to read their own chat_sessions
--    Already covered by: chat_sessions_select USING (has_role... OR user_id = auth.uid())
--    This works for anon users since user_id = auth.uid() will match.

-- 5. Fix chat_messages INSERT policy to allow anon users
--    (they have sender_id = auth.uid() but no visit session by uid)
DROP POLICY IF EXISTS "chat_messages_insert" ON chat_messages;
DROP POLICY IF EXISTS "chat_messages_insert_admin" ON chat_messages;

-- Unified insert policy: sender_id must match auth.uid() (works for anon + auth)
CREATE POLICY "chat_messages_insert" ON chat_messages FOR INSERT WITH CHECK (
  sender_id = auth.uid()
);

-- 6. Allow anonymous users to read messages in their own sessions
--    Already covered by: chat_messages_select USING (has_role OR session_id IN ...)
--    The subquery checks chat_sessions.user_id = auth.uid() which works for anon.

-- 7. Allow anon users to read visit_sessions (needed to validate QR token)
DROP POLICY IF EXISTS "visit_sessions_select_anon_by_token" ON visit_sessions;
CREATE POLICY "visit_sessions_select_anon_by_token" ON visit_sessions FOR SELECT USING (
  is_active = true AND expires_at > now()
);
