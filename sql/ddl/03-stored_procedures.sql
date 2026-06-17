-- =========================================================================
-- SCRIPT: ADVANCED STORED PROCEDURES (STRESS-TEST RESISTANT)
-- =========================================================================

-- 1. Registro Seguro de Movimientos con Validación de Stock y Bloqueo de Fila
CREATE OR REPLACE PROCEDURE sp_register_inventory_movement(
    p_user_id INT,
    p_branch_id INT,
    p_movement_type VARCHAR(10),
    p_product_id INT,
    p_quantity INT,
    p_unit_price NUMERIC(10,2),
    p_remarks TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_current_stock INT;
    v_movement_id INT;
BEGIN
    -- Bloquear la fila del producto (FOR UPDATE) para evitar condiciones de carrera en pruebas de estrés
    SELECT current_stock INTO v_current_stock 
    FROM products 
    WHERE id_product = p_product_id AND is_active = TRUE
    FOR UPDATE;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'ERROR: El producto activo con ID % no existe.', p_product_id;
    END IF;

    -- Validar disponibilidad si es una salida de inventario
    IF p_movement_type = 'OUT' AND v_current_stock < p_quantity THEN
        RAISE EXCEPTION 'ERROR: Stock insuficiente. Disponible: %, Solicitado: %', v_current_stock, p_quantity;
    END IF;

    -- Insertar la cabecera de la transacción
    INSERT INTO inventory_movements (id_user, id_branch, movement_type, remarks)
    VALUES (p_user_id, p_branch_id, p_movement_type, p_remarks)
    RETURNING id_movement INTO v_movement_id;

    -- Insertar el desglose del movimiento
    INSERT INTO movement_details (id_movement, id_product, quantity, unit_price)
    VALUES (v_movement_id, p_product_id, p_quantity, p_unit_price);

    -- Actualizar los saldos en caliente
    IF p_movement_type = 'IN' THEN
        UPDATE products 
        SET current_stock = current_stock + p_quantity 
        WHERE id_product = p_product_id;
    ELSIF p_movement_type = 'OUT' THEN
        UPDATE products 
        SET current_stock = current_stock - p_quantity 
        WHERE id_product = p_product_id;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        -- Deshace el bloque completo en caso de cualquier error concurrente
        RAISE NOTICE 'Transacción abortada de forma segura por error en estrés: %', SQLERRM;
        RAISE;
END;
$$;


-- 2. Inserción Masiva de Productos en Lotes con Captura Controlada de Errores
CREATE OR REPLACE PROCEDURE sp_bulk_insert_products(
    p_products_data JSONB
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_product RECORD;
BEGIN
    -- Descomponer el bloque JSON enviado por la aplicación en filas individuales
    FOR v_product IN SELECT * FROM jsonb_to_recordset(p_products_data) 
        AS x(id_category INT, id_supplier INT, barcode VARCHAR(50), name VARCHAR(150), description TEXT, sale_price NUMERIC(10,2), current_stock INT, minimum_stock INT)
    LOOP
        BEGIN
            INSERT INTO products (id_category, id_supplier, barcode, name, description, sale_price, current_stock, minimum_stock)
            VALUES (v_product.id_category, v_product.id_supplier, v_product.barcode, v_product.name, v_product.description, v_product.sale_price, v_product.current_stock, v_product.minimum_stock);
        EXCEPTION
            WHEN unique_violation THEN
                -- Captura errores de llaves duplicadas individuales sin tumbar el resto de la inserción masiva
                RAISE NOTICE 'Estrés: Omitiendo código de barras duplicado: %', v_product.barcode;
            WHEN OTHERS THEN
                RAISE NOTICE 'Estrés: Fila omitida por error controlado: %', SQLERRM;
        END;
    END LOOP;
END;
$$;


-- 3. Eliminación Lógica Segura para Conservar Integridad Referencial
CREATE OR REPLACE PROCEDURE sp_logical_delete_product(
    p_product_id INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE products 
    SET is_active = FALSE 
    WHERE id_product = p_product_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'ERROR: No se encontró el producto con ID % para deshabilitar.', p_product_id;
    END IF;
END;
$$;