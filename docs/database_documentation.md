# DOCUMENTO DE SUSTENTACION TECNICA: SISTEMA DE GESTION DE INVENTARIOS

**Empresa:** InvenData  
**Eslogan:** "Transformando el inventario en decisiones operativas."  
**Asignatura:** Bases de Datos Avanzadas  
**Profesor:** Alejandro Jaimes  
**Modalidad de Entrega:** Modalidad A (Base de Datos Relacional Optimizada)  


## INDICE DEL DOCUMENTO

1. Identidad Corporativa y Justificacion
2. Proceso de Normalizacion Formal (1FN a 4FN)
3. Modelado Visual del Sistema
4. Diccionario de Datos Detallado
5. Inteligencia del Motor (Procedimientos, Funciones y Triggers)
6. Operaciones CRUD de Referencia
7. Manual de Instalacion y Despliegue
8. Analisis de Rendimiento bajo Estres


## 1. IDENTIDAD CORPORATIVA Y JUSTIFICACION

### 1.1. Origen del Nombre
InvenData nace como un juego de palabras estrategico entre Inventario y Data (Datos). El nombre destaca que el sistema va mas alla de ser una simple bodega digital que almacena existencias fisicas; esta concebido desde su base como un motor de inteligencia operativa capaz de procesar analiticas complejas, calcular balances financieros y emitir alertas de stock critico en tiempo real.

### 1.2. Representacion del Logo y Concepto
El logotipo de InvenData se fundamenta en la silueta clasica de una base de datos relacional (los tres cilindros apilados), pero con la particularidad de que las lineas divisorias se transforman en una grafica de barras ascendente. Los colores corporativos seleccionados son el verde esmeralda (que representa crecimiento financiero, rentabilidad y stock saludable) y el gris metalico (que aporta la estructura formal, seriedad y precision tecnologica). El diseño visual representa de forma directa como la correcta indexacion y la optimizacion del motor relacional impulsan la escalabilidad del negocio.


## 2. PROCESO DE NORMALIZACION FORMAL (1FN A 4FN)

Para mitigar anomalias de insercion, actualizacion y borrado fisico en escenarios de alto estres, el diseño se sometio a una estricta descomposicion relacional:

* Primera Forma Normal (1FN): Todos los atributos del esquema son atomicos. Se eliminaron listas de productos dentro de las cabeceras de movimientos mediante la atomizacion de registros individuales.
* Segunda Forma Normal (2FN): El sistema cumple la 1FN y todas las columnas que no forman parte de las claves primarias (PK) poseen una dependencia funcional completa de dicha clave, eliminando la redundancia parcial en las entidades maestras products y suppliers.
* Tercera Forma Normal (3FN): Se eliminaron las dependencias transitivas. Los atributos especificos de los proveedores (como telefono corporativo o direccion fiscal) dependen estrictamente del id_supplier en su respectiva tabla y no se duplican ni arrastran a la tabla de productos.
* Cuarta Forma Normal (4FN): Se aislo la relacion multivaluada independiente entre los movimientos logisticos y los articulos fisicos mediante el diseño de la tabla puente movement_details. Esto quebro de forma correcta la relacion Muchos a Muchos (N:M), impidiendo duplicaciones operacionales masivas.


## 3. MODELADO VISUAL DEL SISTEMA

### 3.1. Modelo Entidad-Relacion Conceptual (Notacion de Chen)
COLOCAR AQUI LA IMAGEN: Entidad-Relacion-Gestion-Inventarios.drawio.jpg

### 3.2. Modelo Relacional Avanzado
COLOCAR AQUI LA IMAGEN: Modelo-Relacional-Gestion-Inventarios.drawio.jpg

### 3.3. Modelo Fisico de Base de Datos
COLOCAR AQUI LA IMAGEN: Modelo-Fisico_Gestion-Inventarios.png


## 4. DICCIONARIO DE DATOS DETALLADO

### 4.1. Tabla: categories (Catálogo maestro de clasificaciones)

| Campo | Tipo de Dato | Tamaño | Restricción | Descripción |
| :--- | :--- | :--- | :--- | :--- |
| id_category | INT / SERIAL | No aplica | PK | Identificador único autoincremental de la categoría. |
| name | VARCHAR | 100 | UNIQUE, NOT NULL | Nombre descriptivo de la clasificación comercial. |
| description | TEXT | Variable | NULL | Detalle explicativo sobre el alcance de la categoría. |

### 4.2. Tabla: suppliers (Registro de proveedores de mercancía)

| Campo | Tipo de Dato | Tamaño | Restricción | Descripción |
| :--- | :--- | :--- | :--- | :--- |
| id_supplier | INT / SERIAL | No aplica | PK | Identificador único del proveedor de mercancía. |
| company_name | VARCHAR | 150 | NOT NULL | Razón social o nombre legal de la organización. |
| contact_name | VARCHAR | 100 | NULL | Nombre completo del asesor o punto de contacto técnico. |
| phone | VARCHAR | 20 | NULL | Teléfono corporativo para la gestión de pedidos. |
| email | VARCHAR | 100 | UNIQUE, NULL | Correo electrónico para trámites de facturación. |
| address | TEXT | Variable | NULL | Dirección fiscal de la central del proveedor. |

### 4.3. Tabla: products (Catálogo maestro de artículos en inventario)

| Campo | Tipo de Dato | Tamaño | Restricción | Descripción |
| :--- | :--- | :--- | :--- | :--- |
| id_product | INT / SERIAL | No aplica | PK | Identificador único del artículo en inventario. |
| id_category | INT | No aplica | FK | Llave foránea vinculada a la tabla categories. |
| id_supplier | INT | No aplica | FK | Llave foránea vinculada a la tabla suppliers. |
| barcode | VARCHAR | 50 | UNIQUE, NOT NULL | Código de barras indexado para velocidad de búsqueda. |
| name | VARCHAR | 150 | NOT NULL | Nombre comercial y técnico del producto. |
| description | TEXT | Variable | NULL | Especificaciones detalladas o ficha técnica. |
| sale_price | NUMERIC | 10,2 | NOT NULL, CHECK | Precio de venta unitario restringido a valores mayores o iguales a cero. |
| current_stock | INT | No aplica | NOT NULL, DEFAULT | Saldo total de unidades calculado por disparador. |
| minimum_stock | INT | No aplica | NOT NULL, DEFAULT | Umbral de existencias mínimas permitido antes de emitir alertas. |
| is_active | BOOLEAN | No aplica | NOT NULL, DEFAULT | Estado lógico para dar de baja registros sin romper relaciones fijas. |

### 4.4. Tabla: branches (Bodegas y sedes de distribución)

| Campo | Tipo de Dato | Tamaño | Restricción | Descripción |
| :--- | :--- | :--- | :--- | :--- |
| id_branch | INT / SERIAL | No aplica | PK | Identificador único del almacén o sede logística. |
| name | VARCHAR | 100 | UNIQUE, NOT NULL | Nombre representativo de la bodega física. |
| address | TEXT | Variable | NULL | Dirección geográfica de la sede de distribución. |
| phone | VARCHAR | 20 | NULL | Teléfono de contacto de la administración local. |

### 4.5. Tabla: users (Operadores calificados del sistema)

| Campo | Tipo de Dato | Tamaño | Restricción | Descripción |
| :--- | :--- | :--- | :--- | :--- |
| id_user | INT / SERIAL | No aplica | PK | Identificador único del operador del software. |
| full_name | VARCHAR | 100 | NOT NULL | Nombre completo del empleado responsable de la operación. |
| email | VARCHAR | 100 | UNIQUE, NOT NULL | Correo electrónico corporativo de autenticación. |
| user_role | VARCHAR | 50 | NOT NULL, CHECK | Rol de usuario restringido formalmente a Admin, Operator o Supervisor. |
| created_at | TIMESTAMP | No aplica | NOT NULL, DEFAULT | Fecha y hora exacta del alta de usuario. |

### 4.6. Tabla: inventory_movements (Cabecera transaccional)

| Campo | Tipo de Dato | Tamaño | Restricción | Descripción |
| :--- | :--- | :--- | :--- | :--- |
| id_movement | INT / SERIAL | No aplica | PK | Identificador único de la transacción de inventario. |
| id_user | INT | No aplica | FK | Operador calificado que ejecutó la operación logística. |
| id_branch | INT | No aplica | FK | Bodega física donde se origina o recibe la mercancía. |
| movement_type | VARCHAR | 10 | NOT NULL, CHECK | Sentido del movimiento restringido estrictamente a Entrada o Salida. |
| movement_date | TIMESTAMP | No aplica | NOT NULL, DEFAULT | Timestamp del procesamiento de la operación. |
| remarks | TEXT | Variable | NULL | Observaciones del motivo del movimiento logístico. |

### 4.7. Tabla: movement_details (Cuerpo y detalle de transacciones - Relación N:M)

| Campo | Tipo de Dato | Tamaño | Restricción | Descripción |
| :--- | :--- | :--- | :--- | :--- |
| id_detail | INT / SERIAL | No aplica | PK | Identificador único de la línea de transacción. |
| id_movement | INT | No aplica | FK | Vínculo estructural a la cabecera general del movimiento. |
| id_product | INT | No aplica | FK | Artículo físico movilizado durante la operación. |
| quantity | INT | No aplica | NOT NULL, CHECK | Cantidad transferida restringida a valores mayores a cero. |
| unit_price | NUMERIC | 10,2 | NOT NULL | Valor financiero registrado al momento exacto de la operación. |

### 4.8. Tabla: audit_logs (Historial inmutable del sistema)

| Campo | Tipo de Dato | Tamaño | Restricción | Descripción |
| :--- | :--- | :--- | :--- | :--- |
| id_audit | INT / SERIAL | No aplica | PK | Código incremental e inmutable de la auditoría de base de datos. |
| db_user | VARCHAR | 100 | NOT NULL, DEFAULT | Identidad del usuario del motor que ejerció el cambio. |
| action_type | VARCHAR | 10 | NOT NULL, CHECK | Tipo de acción detectada limitada exclusivamente a INSERT, UPDATE o DELETE. |
| table_name | VARCHAR | 100 | NOT NULL | Nombre de la tabla afectada por la mutación de datos. |
| old_values | JSONB | Variable | NULL | Captura del estado previo de la fila antes del cambio en formato JSON. |
| new_values | JSONB | Variable | NULL | Captura del estado posterior de la fila tras el cambio en formato JSON. |
| action_timestamp | TIMESTAMP | No aplica | NOT NULL, DEFAULT | Estampa cronológica automática disparada por el log. |


## 5. INTELIGENCIA DEL MOTOR

### 5.1. Procedimientos Almacenados (Control Transaccional)
El sistema encapsula su logica transaccional en tres bloques robustos protegidos contra condiciones de carrera mediante capturas de excepciones controladas:
1. `register_inventory_movement`: Inicializa y procesa las cabeceras logísticas evaluando la existencia de operadores y sedes.
2. `add_movement_detail`: Realiza la insercion en el cuerpo logistico y recalcula de forma controlada el stock fisico, denegando transacciones que induzcan saldos negativos.
3. `safely_update_product_price`: Gestiona la actualizacion masiva o individual de tarifas comerciales validando que no se vulneren los margenes operativos de la compañia.

### 5.2. Funciones Personalizadas (Analitica Integrada)
Diseñadas bajo el estandar nativo de PostgreSQL para acelerar los reportes agregados evitando sobrecargar las aplicaciones:
* `calculate_branch_balance`: Computa en milisegundos el valor financiero consolidado neto de existencias por sede.
* `get_low_stock_alerts_count`: Devuelve un recuento entero optimizado sobre productos que requieren suministro inmediato.

### 5.3. Triggers (Auditoria Inmutable en JSONB)
El motor de base de datos vigila activamente el comportamiento operativo a traves de un disparador automatico interceptor de eventos CRUD. Al capturar modificaciones (`OLD` y `NEW`), serializa de manera dinamica el payload de los registros directamente en campos binarios de tipo `JSONB`. Esto mantiene una sola bitacora centralizada sin degradar el rendimiento del almacenamiento fisico.


## 6. OPERACIONES CRUD DE REFERENCIA

Para validar la manipulacion de datos sin interferir de forma directa con el inventario consolidado, el repositorio incluye un script dedicado en `sql/queries/11-crud_operations.sql` centrado en la entidad maestra suppliers:

* Create: Insercion de proveedores bajo restricciones referenciales limpias.
* Read: Consultas selectivas de datos comerciales indexados por campos de tipo unique.
* Update: Modificaciones puntuales sobre campos variables sin alterar llaves estructurales.
* Delete: Remocion fisica segura bajo validacion estricta de aislamiento referencial.


## 7. MANUAL DE INSTALACION Y DESPLIEGUE

Para inicializar la base de datos de InvenData localmente, conéctese a su gestor PostgreSQL (pgAdmin, DBeaver o psql console) e inyecte los módulos SQL en el siguiente orden secuencial estricto:

1. sql/ddl/01-structure_tables.sql       (Crea tablas, llaves e índices)
2. sql/ddl/02-audit_trigger.sql         (Compila e inyecta la auditoría automática)
3. sql/ddl/03-stored_procedures.sql     (Registra los procedimientos de inserción/actualización)
4. sql/ddl/04-custom_functions.sql       (Carga las rutinas analíticas)
5. sql/dml/                              (Ejecutar secuencialmente del archivo 02 al 08 para insertar datos de prueba)
6. sql/queries/10-advanced_queries.sql   (Carga el pool de consultas avanzadas de control)
7. sql/queries/11-crud_operations.sql    (Pruebas operativas del módulo CRUD)

**NOTA DE MANTENIMIENTO:**
Si desea reiniciar el entorno de pruebas, borrar por completo la base de datos y volver a ejecutar la instalación desde cero, puede ejecutar el script final:
* sql/ddl/05-cleanup.sql                 (Borrado absoluto en cascada de estructuras y lógica)

## 8. ANALISIS DE RENDIMIENTO BAJO ESTRES

El diseño fisico del sistema incorpora tres directrices avanzadas de optimizacion de bases de datos relacionales:

* **Indexacion B-Tree Eficiente:** Se establecieron indices dedicados en las columnas clave de busqueda y ordenamiento masivo (`barcode`, `id_product`, `movement_date`). Esto suprime de raiz los barridos secuenciales completos de las tablas (*Sequential Scans*), estabilizando los tiempos de respuesta en lecturas de complejidad logaritmica $O(\log n)$.
* **Reduccion de Bloqueos Exclusivos:** El uso de almacenamiento semiestructurado `JSONB` dentro del trigger de auditoria centralizado evita bloqueos prolongados sobre las tablas maestras operativas en escenarios concurrenciales intensivos.
* **Borrado Logico y Transacciones Hermeticas:** El campo de tipo flag `is_active` asegura la consistencia historica y referencial del sistema, permitiendo dar de baja productos obsoletos en nanosegundos utilizando un comando `UPDATE` en lugar de un costoso comando `DELETE` fisico que degradaria los indices del motor bajo alta concurrencia.

