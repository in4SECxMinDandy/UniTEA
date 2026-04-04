-- ============================================================
-- Fix: Chat RLS — token-based visit session validation
--
-- Problem:
--   has_valid_visit_session(uid) checks visit_sessions.user_id = uid.
--   Admin-generated QR sessions have user_id = admin.id, not the
--   customer's id. This blocks customers from sending messages.
--
-- Solution:
--   1. Add visit_token column to chat_sessions.
--   2. Create a token-based function: has_valid_visit_session_by_token.
--   3. Update the INSERT policy for chat_messages to use the token check.
--
-- Supabase reference:
--   https://supabase.com/docs/guides/database/database-linter?lint=0011
-- ============================================================

-- Step 1: Add visit_token column (idempotent — uses IF NOT EXISTS)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'chat_sessions' AND column_name = 'visit_token'
  ) THEN
    ALTER TABLE chat_sessions ADD COLUMN visit_token text;
  END IF;
END $$;

-- Step 2: Create the token-based visit session validator (OR REPLACE is safe)
CREATE OR REPLACE FUNCTION has_valid_visit_session_by_token(v_token text)
RETURNS boolean AS $$
  SELECT EXISTS (
    SELECT 1 FROM visit_sessions
    WHERE visit_token = v_token
      AND is_active = true
      AND expires_at > now()
  );
$$ LANGUAGE sql SECURITY DEFINER STABLE SET search_path = public;

-- Step 3: Replace the chat_messages INSERT policy:
-- - Admins can always send (has_role check).
-- - QR customers: their chat_session has a valid visit_token.
-- - Non-QR customers: sender_id = auth.uid() ensures they can only
--   send as themselves, and chat_sessions_insert already restricts
--   them to their own sessions.
DROP POLICY IF EXISTS chat_messages_insert ON chat_messages;
CREATE POLICY chat_messages_insert ON chat_messages FOR INSERT WITH CHECK (
  sender_id = auth.uid()
  AND (
    has_role(auth.uid(), 'STORE_ADMIN')
    OR (
      session_id IN (
        SELECT id FROM chat_sessions
        WHERE visit_token IS NOT NULL
          AND has_valid_visit_session_by_token(visit_token)
      )
    )
  )
);
