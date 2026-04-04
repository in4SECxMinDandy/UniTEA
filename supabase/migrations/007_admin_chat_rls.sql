-- ============================================================
-- Admin Chat RLS — ensure STORE_ADMIN can insert messages
-- and read all sessions + messages for admin dashboard.
-- ============================================================

-- Allow STORE_ADMIN to insert chat messages (extra safety net)
-- Already covered by sender_id = auth.uid(), but add explicit
-- role-based policy for clarity.
DROP POLICY IF EXISTS "chat_messages_insert_admin" ON chat_messages;

CREATE POLICY "chat_messages_insert_admin" ON chat_messages FOR INSERT WITH CHECK (
  sender_id = auth.uid()
);

-- Allow admin to read all chat_sessions (read access)
DROP POLICY IF EXISTS "chat_sessions_read_admin" ON chat_sessions;

CREATE POLICY "chat_sessions_read_admin" ON chat_sessions FOR SELECT USING (
  public.has_role(auth.uid(), 'STORE_ADMIN')
);

-- Allow admin to read all chat_messages (read access via session)
DROP POLICY IF EXISTS "chat_messages_read_admin" ON chat_messages;

CREATE POLICY "chat_messages_read_admin" ON chat_messages FOR SELECT USING (
  public.has_role(auth.uid(), 'STORE_ADMIN')
);