-- ============================================================
-- Fix: Search Path Mutable Security Warnings
-- Secures all functions by setting a fixed search_path and
-- adding SECURITY DEFINER where missing.
-- Supabase reference: https://supabase.com/docs/guides/database/database-linter?lint=0011
-- ============================================================

-- 1. update_updated_at — trigger function
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- 2. set_deleted_at — trigger function
CREATE OR REPLACE FUNCTION set_deleted_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.deleted_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- 3. set_visit_expires_at — trigger function
CREATE OR REPLACE FUNCTION set_visit_expires_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.expires_at = NEW.started_at + (NEW.expires_in_hours || ' hours')::interval;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- 4. update_chat_session_last_message — trigger function
CREATE OR REPLACE FUNCTION update_chat_session_last_message()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE chat_sessions SET last_message_at = NEW.created_at WHERE id = NEW.session_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- 5. has_role — helper function (already had SECURITY DEFINER, added search_path)
CREATE OR REPLACE FUNCTION public.has_role(uid uuid, role_name text)
RETURNS boolean AS $$
  SELECT EXISTS (
    SELECT 1 FROM user_roles ur
    JOIN roles r ON r.id = ur.role_id
    WHERE ur.user_id = uid AND r.name = role_name
  );
$$ LANGUAGE sql SECURITY DEFINER STABLE SET search_path = public;

-- 6. has_valid_visit_session — helper function (already had SECURITY DEFINER, added search_path)
CREATE OR REPLACE FUNCTION public.has_valid_visit_session(uid uuid)
RETURNS boolean AS $$
  SELECT EXISTS (
    SELECT 1 FROM visit_sessions
    WHERE user_id = uid
      AND is_active = true
      AND expires_at > now()
  );
$$ LANGUAGE sql SECURITY DEFINER STABLE SET search_path = public;

-- 7. handle_new_user — trigger function (already had SECURITY DEFINER, added search_path)
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name)
  VALUES (NEW.id, NEW.raw_user_meta_data->>'full_name');
  INSERT INTO public.user_roles (user_id, role_id)
  SELECT NEW.id, id FROM public.roles WHERE name = 'USER';
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;
