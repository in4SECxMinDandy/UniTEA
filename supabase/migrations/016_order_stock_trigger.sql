-- Function to manage stock quantity based on orders
CREATE OR REPLACE FUNCTION handle_order_stock()
RETURNS TRIGGER AS $$
BEGIN
  -- Deduct stock when a new order is placed (pending)
  IF (TG_OP = 'INSERT') THEN
    UPDATE public.foods
    SET stock_quantity = GREATEST(stock_quantity - NEW.quantity, 0)
    WHERE id = NEW.food_id;
  
  -- Refund stock if an order is cancelled
  ELSIF (TG_OP = 'UPDATE') THEN
    IF (NEW.status = 'cancelled' AND OLD.status != 'cancelled') THEN
      UPDATE public.foods
      SET stock_quantity = stock_quantity + NEW.quantity
      WHERE id = NEW.food_id;
    END IF;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER tr_order_stock
AFTER INSERT OR UPDATE ON public.orders
FOR EACH ROW EXECUTE FUNCTION handle_order_stock();
