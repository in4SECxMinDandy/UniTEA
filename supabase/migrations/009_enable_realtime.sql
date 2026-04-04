-- ============================================================
-- Enable Realtime for chat tables so postgres_changes works
-- ============================================================
ALTER PUBLICATION supabase_realtime ADD TABLE chat_messages;
ALTER PUBLICATION supabase_realtime ADD TABLE chat_sessions;
