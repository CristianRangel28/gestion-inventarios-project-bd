-- =========================================================================
-- SCRIPT: AUDIT TRIGGER SYSTEM (PL/pgSQL)
-- =========================================================================

-- 1. Create the trigger function that handles the log insertion
CREATE OR REPLACE FUNCTION fn_log_audit_action()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'DELETE') THEN
        INSERT INTO audit_logs (action_type, table_name, old_values, new_values)
        VALUES ('DELETE', TG_TABLE_NAME, to_jsonb(OLD), NULL);
        RETURN OLD;
    ELSIF (TG_OP = 'UPDATE') THEN
        INSERT INTO audit_logs (action_type, table_name, old_values, new_values)
        VALUES ('UPDATE', TG_TABLE_NAME, to_jsonb(OLD), to_jsonb(NEW));
        RETURN NEW;
    ELSIF (TG_OP = 'INSERT') THEN
        INSERT INTO audit_logs (action_type, table_name, old_values, new_values)
        VALUES ('INSERT', TG_TABLE_NAME, NULL, to_jsonb(NEW));
        RETURN NEW;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- 2. Bind the trigger to the 'products' table
CREATE TRIGGER trg_audit_products
AFTER INSERT OR UPDATE OR DELETE ON products
FOR EACH ROW
EXECUTE FUNCTION fn_log_audit_action();

-- 3. Bind the trigger to the 'inventory_movements' table
CREATE TRIGGER trg_audit_inventory_movements
AFTER INSERT OR UPDATE OR DELETE ON inventory_movements
FOR EACH ROW
EXECUTE FUNCTION fn_log_audit_action();