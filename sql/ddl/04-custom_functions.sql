-- =========================================================================
-- SCRIPT: ADVANCED CUSTOM FUNCTIONS (PERFORMANCE OPTIMIZED)
-- =========================================================================

-- 1. Cálculo de Valor Total de Inventario Global de Productos Activos
-- Esta función calcula instantáneamente cuánto dinero hay invertido en mercancía
CREATE OR REPLACE FUNCTION fn_get_total_inventory_value()
RETURNS NUMERIC(15,2)
LANGUAGE plpgsql
AS $$
DECLARE
    v_total_value NUMERIC(15,2);
BEGIN
    -- Cálculo directo indexado para responder de inmediato en pruebas de estrés
    SELECT COALESCE(SUM(current_stock * sale_price), 0.00) INTO v_total_value
    FROM products
    WHERE is_active = TRUE;

    RETURN v_total_value;
END;
$$;


-- 2. Alerta Inmediata de Productos Bajo el Mínimo de Stock (Formato JSONB)
-- Retorna un reporte compacto con los artículos en estado crítico. Al usar JSONB,
-- evita que múltiples Joins pesados saturen la CPU durante lecturas concurrentes.
CREATE OR REPLACE FUNCTION fn_check_low_stock_alerts()
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_report JSONB;
BEGIN
    SELECT jsonb_agg(jsonb_build_object(
        'product_id', id_product,
        'product_name', name,
        'barcode', barcode,
        'current_stock', current_stock,
        'minimum_stock', minimum_stock
    )) INTO v_report
    FROM products
    WHERE current_stock <= minimum_stock AND is_active = TRUE;

    -- Si no hay alertas, retorna un arreglo vacío estructurado
    RETURN COALESCE(v_report, '[]'::jsonb);
END;
$$;