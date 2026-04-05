-- ============================================================
-- Admin Delete Chat — allow STORE_ADMIN to delete sessions and messages
-- ============================================================

-- Allow STORE_ADMIN to delete chat_messages
DROP POLICY IF EXISTS "chat_messages_delete_admin" ON chat_messages;

CREATE POLICY "chat_messages_delete_admin" ON chat_messages FOR DELETE USING (
  public.has_role(auth.uid(), 'STORE_ADMIN')
);

-- Allow STORE_ADMIN to delete chat_sessions
DROP POLICY IF EXISTS "chat_sessions_delete_admin" ON chat_sessions;

CREATE POLICY "chat_sessions_delete_admin" ON chat_sessions FOR DELETE USING (
  public.has_role(auth.uid(), 'STORE_ADMIN')
);

-- Allow STORE_ADMIN to update chat_sessions (close session)
DROP POLICY IF EXISTS "chat_sessions_update_admin" ON chat_sessions;

CREATE POLICY "chat_sessions_update_admin" ON chat_sessions FOR UPDATE USING (
  public.has_role(auth.uid(), 'STORE_ADMIN')
);
