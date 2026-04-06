-- ============================================================
-- Fix 1: Allow STORE_ADMIN to read all profiles
--        (Needed so admin can see customer names in orders & chat)
-- ============================================================
DROP POLICY IF EXISTS "profiles_select_admin" ON profiles;
CREATE POLICY "profiles_select_admin" ON profiles
  FOR SELECT
  USING (has_role(auth.uid(), 'STORE_ADMIN'));

-- ============================================================
-- Fix 2: Rewrite order stock trigger to prevent double-deduction
--        Add stock_deducted flag to orders so trigger only fires once.
-- ============================================================

-- Add tracking column to orders (idempotent)
ALTER TABLE public.orders
  ADD COLUMN IF NOT EXISTS stock_deducted boolean NOT NULL DEFAULT false;

-- Rewrite the stock trigger function
CREATE OR REPLACE FUNCTION handle_order_stock()
RETURNS TRIGGER AS $$
BEGIN
  -- ── INSERT: deduct stock once and mark as deducted ──────────────
  IF (TG_OP = 'INSERT') THEN
    UPDATE public.foods
    SET stock_quantity = GREATEST(stock_quantity - NEW.quantity, 0)
    WHERE id = NEW.food_id;

    -- Mark this order as already having stock deducted
    NEW.stock_deducted := true;

  -- ── UPDATE: only handle cancellation (refund) or re-cancellation guard ──
  ELSIF (TG_OP = 'UPDATE') THEN
    -- Refund stock if order moves TO cancelled and stock was deducted
    IF (NEW.status = 'cancelled' AND OLD.status != 'cancelled' AND OLD.stock_deducted = true) THEN
      UPDATE public.foods
      SET stock_quantity = stock_quantity + OLD.quantity
      WHERE id = OLD.food_id;
      NEW.stock_deducted := false;
    END IF;

    -- If order moves OUT of cancelled (e.g. re-opened) and stock not yet deducted
    IF (OLD.status = 'cancelled' AND NEW.status != 'cancelled' AND NEW.stock_deducted = false) THEN
      UPDATE public.foods
      SET stock_quantity = GREATEST(stock_quantity - NEW.quantity, 0)
      WHERE id = NEW.food_id;
      NEW.stock_deducted := true;
    END IF;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- Drop and recreate trigger as BEFORE (so NEW fields can be mutated)
DROP TRIGGER IF EXISTS tr_order_stock ON public.orders;
CREATE TRIGGER tr_order_stock
BEFORE INSERT OR UPDATE ON public.orders
FOR EACH ROW EXECUTE FUNCTION handle_order_stock();

-- Back-fill stock_deducted for existing non-cancelled orders
UPDATE public.orders
SET stock_deducted = true
WHERE status IN ('pending', 'confirmed', 'completed')
  AND stock_deducted = false;

-- ============================================================
-- Fix 3: Ensure existing account-type chat sessions are correctly
--        marked as 'account' (not 'qr' from backfill in 011)
-- ============================================================
UPDATE chat_sessions
SET session_type = 'account'
WHERE visit_session_id IS NULL
  AND session_type != 'account';
