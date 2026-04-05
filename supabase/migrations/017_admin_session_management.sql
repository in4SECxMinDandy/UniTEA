-- 1. Allow Admins to Delete/Update Visit Sessions
DROP POLICY IF EXISTS "visit_sessions_delete_admin" ON visit_sessions;
CREATE POLICY "visit_sessions_delete_admin" ON visit_sessions FOR DELETE USING (has_role(auth.uid(), 'STORE_ADMIN'));

-- 2. Allow Admins to Update Chat Sessions (e.g. status='closed')
DROP POLICY IF EXISTS "chat_sessions_update_admin" ON chat_sessions;
CREATE POLICY "chat_sessions_update_admin" ON chat_sessions FOR UPDATE USING (has_role(auth.uid(), 'STORE_ADMIN'));

-- 3. Block messages if session is closed
-- Drop the old overly-complex or broken insert policy
DROP POLICY IF EXISTS "chat_messages_insert" ON chat_messages;

-- Create a robust insert policy based directly on the chat_sessions status
CREATE POLICY "chat_messages_insert" ON chat_messages FOR INSERT WITH CHECK (
    sender_id = auth.uid()
    AND EXISTS (
      SELECT 1 FROM chat_sessions 
      WHERE id = session_id 
        AND status = 'open' 
        AND (user_id = auth.uid() OR has_role(auth.uid(), 'STORE_ADMIN'))
    )
);
