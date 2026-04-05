-- ============================================================
-- Chat Guest Identity — distinguish QR guests vs account users
-- Adds: guest_name (optional display name for QR guests),
--       session_type ('qr' | 'account') for categorization
-- ============================================================

-- Add guest_name column: QR guests can optionally provide a name
ALTER TABLE chat_sessions
  ADD COLUMN IF NOT EXISTS guest_name text,
  ADD COLUMN IF NOT EXISTS session_type text DEFAULT 'qr';

-- Back-fill: sessions that have a visit_session_id are 'qr', others 'account'
UPDATE chat_sessions
SET session_type = CASE
  WHEN visit_session_id IS NOT NULL THEN 'qr'
  ELSE 'account'
END
WHERE session_type IS NULL OR session_type = 'qr';

-- Allow admins to read guest_name (already covered by existing RLS on chat_sessions)
-- No additional RLS changes needed — chat_sessions RLS already allows STORE_ADMIN full read

-- Allow users/anon to update their own chat_session (to set guest_name after creation)
DROP POLICY IF EXISTS "chat_sessions_update_own" ON chat_sessions;
CREATE POLICY "chat_sessions_update_own" ON chat_sessions
  FOR UPDATE USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());
