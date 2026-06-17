-- =========================================================================
-- SCRIPT: 10 ADVANCED DEMONSTRATION QUERIES (PERFORMANCE OPTIMIZED)
-- =========================================================================

-- 1. JOINS MÚLTIPLES: Historial detallado de movimientos de inventario
-- Muestra el detalle completo de qué usuario, en qué sucursal, qué producto movió, la cantidad y el tipo de movimiento.
SELECT 
    im.id_movement,
    im.movement_date,
    im.movement_type,
    u.full_name AS operator_name,
    b.name AS branch_name,
    p.name AS product_name,
    md.quantity,
    md.unit_price,
    (md.quantity * md.unit_price) AS total_line_value
FROM inventory_movements im
JOIN users u ON im.id_user = u.id_user
JOIN branches b ON im.id_branch = b.id_branch
JOIN movement_details md ON im.id_movement = md.id_movement
JOIN products p ON md.id_product = p.id_product
ORDER BY im.movement_date DESC;


-- 2. AGREGACIÓN AVANZADA: Valoración actual del inventario agrupado por categoría
-- Calcula el dinero total invertido y la cantidad de productos distintos por cada categoría de la base de datos.
SELECT 
    c.id_category,
    c.name AS category_name,
    COUNT(p.id_product) AS distinct_products,
    SUM(p.current_stock) AS total_items_in_stock,
    SUM(p.current_stock * p.sale_price) AS total_inventory_value
FROM categories c
LEFT JOIN products p ON c.id_category = p.id_category AND p.is_active = TRUE
GROUP BY c.id_category, c.name
HAVING SUM(p.current_stock) > 0
ORDER BY total_inventory_value DESC;


-- 3. SUBCONSULTA CORRELACIONADA: Productos cuyo precio de venta es superior al promedio de su propia categoría
-- Identifica los artículos "Premium" o más costosos comparados internamente con su mismo rubro.
SELECT 
    p1.id_product,
    p1.name AS product_name,
    p1.sale_price,
    c.name AS category_name
FROM products p1
JOIN categories c ON p1.id_category = c.id_category
WHERE p1.sale_price > (
    SELECT AVG(p2.sale_price)
    FROM products p2
    WHERE p2.id_category = p1.id_category AND p2.is_active = TRUE
) AND p1.is_active = TRUE;


-- 4. OPERACIONES CON FECHAS: Balance de movimientos (Entradas vs Salidas) en los últimos 30 días
-- Agrupa dinámicamente cuántos movimientos y qué volumen de stock ha transitado en el último mes.
SELECT 
    im.movement_type,
    COUNT(DISTINCT im.id_movement) AS total_transactions,
    SUM(md.quantity) AS total_units_moved,
    SUM(md.quantity * md.unit_price) AS total_monetary_volume
FROM inventory_movements im
JOIN movement_details md ON im.id_movement = md.id_movement
WHERE im.movement_date >= CURRENT_TIMESTAMP - INTERVAL '30 days'
GROUP BY im.movement_type;


-- 5. SUBCONSULTA COMPLEJA: Proveedores que suministran productos que actualmente están sin stock (Críticos)
-- Ayuda al departamento de compras a saber a quién contactar de inmediato para reabastecimiento.
SELECT 
    s.id_supplier,
    s.company_name,
    s.contact_name,
    s.phone
FROM suppliers s
WHERE s.id_supplier IN (
    SELECT id_supplier 
    FROM products 
    WHERE current_stock = 0 AND is_active = TRUE
);


-- 6. AGREGACIÓN Y VENTANAS (Opcional Avanzado): Top 3 usuarios que más movimientos han registrado
-- Evalúa el rendimiento de los operadores del sistema contando sus interacciones.
SELECT 
    u.id_user,
    u.full_name,
    u.user_role,
    COUNT(im.id_movement) AS total_movements_executed
FROM users u
JOIN inventory_movements im ON u.id_user = im.id_user
GROUP BY u.id_user, u.full_name, u.user_role
ORDER BY total_movements_executed DESC
LIMIT 3;


-- 7. CONSULTA INTEGRAL DE AUDITORÍA: Monitoreo de cambios críticos en la tabla de productos
-- Extrae las modificaciones hechas a los precios o stocks directamente desde el log en formato JSONB.
SELECT 
    id_audit,
    action_timestamp,
    db_user,
    action_type,
    (old_values->>'name') AS product_name,
    (old_values->>'sale_price')::NUMERIC AS old_price,
    (new_values->>'sale_price')::NUMERIC AS new_price
FROM audit_logs
WHERE table_name = 'products' AND action_type = 'UPDATE'
ORDER BY action_timestamp DESC;


-- 8. MAX/MIN CON SUBSELECT: Sucursal que ha movilizado el mayor volumen de mercancía en un solo movimiento
-- Rastrea operaciones atípicas o masivas dentro de la red logística.
SELECT 
    b.name AS branch_name,
    im.id_movement,
    im.movement_date,
    SUM(md.quantity) AS total_quantity_moved
FROM branches b
JOIN inventory_movements im ON b.id_branch = im.id_branch
JOIN movement_details md ON im.id_movement = md.id_movement
GROUP BY b.name, im.id_movement, im.movement_date
HAVING SUM(md.quantity) = (
    SELECT MAX(sub.total_units)
    FROM (
        SELECT SUM(quantity) AS total_units 
        FROM movement_details 
        GROUP BY id_movement
    ) sub
);


-- 9. COALESCE Y OPERACIONES MATEMÁTICAS: Estado de salud de stock por producto (Porcentaje de Alerta)
-- Determina qué tan cerca está un producto de quedarse desabastecido respecto a su mínimo configurado.
SELECT 
    id_product,
    name AS product_name,
    current_stock,
    minimum_stock,
    CASE 
        WHEN current_stock = 0 THEN 'AGOTADO CRÍTICO'
        WHEN current_stock <= minimum_stock THEN 'BAJO MÍNIMO'
        ELSE 'STOCK SEGURO'
    END AS stock_status,
    ROUND((current_stock::NUMERIC / COALESCE(NULLIF(minimum_stock, 0), 1)) * 100, 2) AS safety_percentage
FROM products
WHERE is_active = TRUE
ORDER BY current_stock ASC;


-- 10. REPORTE COMPLETO N:M: Productos cruzados que nunca han tenido rotación (Sin movimientos)
-- Identifica inventario "quieto" o muerto que está generando costos de almacenamiento sin salidas ni entradas registradas.
SELECT 
    p.id_product,
    p.barcode,
    p.name AS product_name,
    c.name AS category_name
FROM products p
JOIN categories c ON p.id_category = c.id_category
WHERE p.id_product NOT IN (
    SELECT DISTINCT id_product 
    FROM movement_details
) AND p.is_active = TRUE;