-- =========================================================================
-- INVENDATA - SCRIPT DE LIMPIEZA Y REINICIO CONTROLADO
-- =========================================================================

DROP TRIGGER IF EXISTS trigger_audit_log_categories ON categories;
DROP TRIGGER IF EXISTS trigger_audit_log_suppliers ON suppliers;
DROP TRIGGER IF EXISTS trigger_audit_log_products ON products;
DROP TRIGGER IF EXISTS trigger_audit_log_branches ON branches;
DROP TRIGGER IF EXISTS trigger_audit_log_users ON users;
DROP TRIGGER IF EXISTS trigger_audit_log_inventory_movements ON inventory_movements;
DROP TRIGGER IF EXISTS trigger_audit_log_movement_details ON movement_details;

DROP FUNCTION IF EXISTS process_audit_log() CASCADE;
DROP FUNCTION IF EXISTS calculate_branch_balance(INT);
DROP FUNCTION IF EXISTS get_low_stock_alerts_count();

DROP PROCEDURE IF EXISTS register_inventory_movement(INT, INT, VARCHAR, TEXT);
DROP PROCEDURE IF EXISTS add_movement_detail(INT, INT, INT, NUMERIC);
DROP PROCEDURE IF EXISTS safely_update_product_price(INT, NUMERIC);

DROP TABLE IF EXISTS audit_logs CASCADE;
DROP TABLE IF EXISTS movement_details CASCADE;
DROP TABLE IF EXISTS inventory_movements CASCADE;
DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS branches CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS suppliers CASCADE;
DROP TABLE IF EXISTS categories CASCADE;