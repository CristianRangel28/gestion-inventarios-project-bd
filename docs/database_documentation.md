# Sistema de Gestión de Inventarios - Documentación de Base de Datos

Este documento contiene la especificación técnica, el diseño conceptual, la justificación de normalización y el diccionario de datos del **Sistema de Gestión de Inventarios**. La base de datos está diseñada sobre **PostgreSQL** y optimizada con índices concurrentes y bloques transaccionales para soportar pruebas de alta carga y estrés.

---

## 1. Arquitectura y Componentes del Sistema

El sistema se compone de un esquema relacional de 8 tablas principales que aíslan los catálogos maestros de los registros operativos y de control:

* **Catálogos Maestros:** `categories`, `suppliers`, `products`, `branches`, `users`.
* **Bloque Transaccional (Relación N:M):** `inventory_movements` (Cabecera) y `movement_details` (Detalle de productos por movimiento).
* **Bloque de Seguridad y Auditoría:** `audit_logs`.

---

## 2. Justificación de Normalización (1FN a 4FN)

Para garantizar la integridad referencial y evitar anomalías de inserción, actualización o borrado bajo condiciones de estrés, el modelo cumple estrictamente con las Formas Normales:

* **Primera Forma Normal (1FN):** Todos los atributos de las tablas son atómicos (valores indivisibles). No existen grupos repetitivos ni listas de elementos en una sola celda.
* **Segunda Forma Normal (2FN):** El sistema cumple con la 1FN y todas las columnas que no forman parte de la clave primaria poseen una dependencia funcional completa sobre ella.
* **Tercera Forma Normal (3FN):** No existen dependencias transitivas entre columnas que no sean claves. Por ejemplo, los datos de contacto del proveedor se manejan exclusivamente en `suppliers`, evitando almacenar redundancias en `products`.
* **Cuarta Forma Normal (4FN):** Se eliminaron por completo las dependencias multivaluadas independientes mediante la creación de la tabla puente `movement_details`, aislando la relación de muchos a muchos (N:M) entre movimientos y productos.

---

## 3. Diccionario de Datos Detallado

### 3.1. Tabla: `categories`
Almacena las clasificaciones generales de los productos.

| Columna | Tipo de Datos | Restricciones | Descripción |
| :--- | :--- | :--- | :--- |
| `id_category` | SERIAL | PRIMARY KEY | Identificador único autoincremental de la categoría. |
| `name` | VARCHAR(100) | NOT NULL, UNIQUE | Nombre descriptivo de la categoría (ej. Electrónica). |
| `description` | TEXT | NULL | Detalle o alcance de la categoría. |

### 3.2. Tabla: `suppliers`
Registra la información de contacto de las empresas proveedoras de mercancía.

| Columna | Tipo de Datos | Restricciones | Descripción |
| :--- | :--- | :--- | :--- |
| `id_supplier` | SERIAL | PRIMARY KEY | Identificador único autoincremental del proveedor. |
| `company_name` | VARCHAR(150) | NOT NULL | Nombre de la empresa o razón social. |
| `contact_name` | VARCHAR(100) | NULL | Nombre del asesor o contacto comercial. |
| `phone` | VARCHAR(20) | NULL | Teléfono de contacto (Formato colombiano). |
| `email` | VARCHAR(100) | UNIQUE, NULL | Correo electrónico de soporte o ventas. |
| `address` | TEXT | NULL | Dirección física de despacho del proveedor. |

### 3.3. Tabla: `products`
Catálogo central de los artículos disponibles para el inventario de la empresa.

| Columna | Tipo de Datos | Restricciones | Descripción |
| :--- | :--- | :--- | :--- |
| `id_product` | SERIAL | PRIMARY KEY | Identificador único del artículo. |
| `id_category` | INT | FOREIGN KEY | Enlace a la categoría asignada (`ON DELETE SET NULL`). |
| `id_supplier` | INT | FOREIGN KEY | Enlace al proveedor asignado (`ON DELETE SET NULL`). |
| `barcode` | VARCHAR(50) | NOT NULL, UNIQUE | Código de barras único para escaneo veloz (Indexado). |
| `name` | VARCHAR(150) | NOT NULL | Nombre comercial del producto. |
| `description` | TEXT | NULL | Especificaciones técnicas del producto. |
| `sale_price` | NUMERIC(10,2) | NOT NULL, CHECK (>=0) | Precio unitario asignado para la venta. |
| `current_stock` | INT | NOT NULL, DEFAULT 0 | Saldo real actual en inventario (Modificado por SP). |
| `minimum_stock`| INT | NOT NULL, DEFAULT 5 | Umbral mínimo permitido antes de generar alertas. |
| `is_active` | BOOLEAN | NOT NULL, DEFAULT TRUE| Estado para el borrado lógico en pruebas de estrés. |

### 3.4. Tabla: `branches`
Define los espacios físicos o almacenes logísticos de la red de distribución.

| Columna | Tipo de Datos | Restricciones | Descripción |
| :--- | :--- | :--- | :--- |
| `id_branch` | SERIAL | PRIMARY KEY | Identificador de la sucursal o bodega. |
| `name` | VARCHAR(100) | NOT NULL, UNIQUE | Nombre de la sede (ej. Bodega Principal Norte). |
| `address` | TEXT | NULL | Dirección de la ubicación de la sede. |
| `phone` | VARCHAR(20) | NULL | Teléfono fijo o móvil de la bodega. |

### 3.5. Tabla: `users`
Registra el personal autorizado para operar el software e interactuar con la base de datos.

| Columna | Tipo de Datos | Restricciones | Descripción |
| :--- | :--- | :--- | :--- |
| `id_user` | SERIAL | PRIMARY KEY | Identificador único del usuario. |
| `full_name` | VARCHAR(100) | NOT NULL | Nombre completo del operador o administrador. |
| `email` | VARCHAR(100) | NOT NULL, UNIQUE | Correo institucional del trabajador. |
| `user_role` | VARCHAR(50) | CHECK (In Roles) | Rol asignado: 'Admin', 'Operator' o 'Supervisor'. |
| `created_at` | TIMESTAMP | DEFAULT NOW() | Fecha de registro del usuario en la plataforma. |

### 3.6. Tabla: `inventory_movements` (Cabecera N:M)
Cabecera que agrupa los metadatos globales de una transacción de entrada o salida.

| Columna | Tipo de Datos | Restricciones | Descripción |
| :--- | :--- | :--- | :--- |
| `id_movement` | SERIAL | PRIMARY KEY | Identificador de la transacción general. |
| `id_user` | INT | FOREIGN KEY | Operador que ejecuta el cambio (`ON DELETE RESTRICT`). |
| `id_branch` | INT | FOREIGN KEY | Sucursal destino u origen del stock (`ON DELETE RESTRICT`). |
| `movement_type`| VARCHAR(10) | CHECK ('IN', 'OUT') | Naturaleza del movimiento: Entrada (IN) o Salida (OUT). |
| `movement_date`| TIMESTAMP | DEFAULT NOW() | Sello de tiempo exacto del movimiento (Indexado). |
| `remarks` | TEXT | NULL | Observaciones o justificación del movimiento. |

### 3.7. Tabla: `movement_details` (Cuerpo N:M)
Tabla de quiebre o puente que detalla los artículos y cantidades específicas consolidadas por movimiento.

| Columna | Tipo de Datos | Restricciones | Descripción |
| :--- | :--- | :--- | :--- |
| `id_detail` | SERIAL | PRIMARY KEY | Identificador de la línea de detalle. |
| `id_movement` | INT | FOREIGN KEY | Asociación a la cabecera del movimiento (`CASCADE`). |
| `id_product` | INT | FOREIGN KEY | Producto involucrado en el flujo (`RESTRICT`). |
| `quantity` | INT | NOT NULL, CHECK (>0) | Cantidad física de unidades movilizadas. |
| `unit_price` | NUMERIC(10,2) | NOT NULL, CHECK (>=0) | Precio del artículo al momento de la operación. |

### 3.8. Tabla: `audit_logs`
Bitácora global automatizada mediante triggers para la persistencia del rastro CRUD del sistema.

| Columna | Tipo de Datos | Restricciones | Descripción |
| :--- | :--- | :--- | :--- |
| `id_audit` | SERIAL | PRIMARY KEY | Identificador único del registro de auditoría. |
| `db_user` | VARCHAR(100) | DEFAULT CURRENT_USER| Usuario del motor que ejecutó el comando en consola. |
| `action_type` | VARCHAR(10) | CHECK (Actions) | Acción realizada: 'INSERT', 'UPDATE' o 'DELETE'. |
| `table_name` | VARCHAR(100) | NOT NULL | Nombre de la tabla afectada por la operación. |
| `old_values` | JSONB | NULL | Captura del estado anterior de la fila (Formato JSON). |
| `new_values` | JSONB | NULL | Captura del estado posterior de la fila (Formato JSON). |
| `action_timestamp`| TIMESTAMP | DEFAULT NOW() | Fecha y hora exacta de la intercepción del trigger. |