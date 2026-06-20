-- =========================================================================
-- INVENDATA - OPERACIONES CRUD DE REFERENCIA
-- ENFOQUE OPERACIONAL: TABLA SUPPLIERS (PROVEEDORES)
-- =========================================================================

-- 1. CREATE (Crear / Insertar un nuevo proveedor de pruebas)
INSERT INTO suppliers (company_name, contact_name, phone, email, address)
VALUES ('Tecnologias del Norte SAS', 'Ing. Carlos Mendoza', '+57 315 987 6543', 'mayorista@tecnonorte.com', 'Av. 4 # 10-25, Cucuta');


-- 2. READ (Leer / Consultar la informacion del proveedor creado)
SELECT id_supplier, company_name, contact_name, phone, email, address 
FROM suppliers 
WHERE company_name = 'Tecnologias del Norte SAS';


-- 3. UPDATE (Actualizar / Modificar los datos de contacto del proveedor)
UPDATE suppliers 
SET contact_name = 'Dra. Maria Paula Duarte', phone = '+57 320 456 7890'
WHERE company_name = 'Tecnologias del Norte SAS';


-- 4. DELETE (Borrar / Eliminar el proveedor de pruebas)
-- NOTA: Se ejecuta sobre este registro aislado para demostrar el funcionamiento del comando DELETE sin comprometer la integridad de los productos reales.
DELETE FROM suppliers 
WHERE company_name = 'Tecnologias del Norte SAS';