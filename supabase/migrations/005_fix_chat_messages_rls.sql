-- ============================================================
-- Fix Chat Messages RLS — allow authenticated users to insert
-- without requiring a visit_session (QR scan).
-- Root cause: has_valid_visit_session blocks online users.
-- Fix: sender_id = auth.uid() is sufficient authorization.
-- ============================================================

DROP POLICY IF EXISTS "chat_messages_insert" ON chat_messages;

CREATE POLICY "chat_messages_insert" ON chat_messages FOR INSERT WITH CHECK (
  sender_id = auth.uid()
);
