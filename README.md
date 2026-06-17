# Inventory Management System (PostgreSQL)

Este repositorio contiene el diseño, modelado e implementación física de una base de datos relacional robusta para un **Sistema de Gestión de Inventarios**. El proyecto cumple estrictamente con las especificaciones académicas de diseño conceptual, lógicos y físicos avanzados.

## 🚀 Características Principales y Resistencia a Estrés
Este sistema ha sido diseñado pensando en entornos de alta disponibilidad y pruebas de estrés masivo, incorporando las siguientes directrices técnicas:
- **Indexación Concurrente:** Creación de índices (`INDEX`) en llaves foráneas y códigos de barra para reducir tiempos de respuesta en consultas masivas de milisegundos a nanosegundos.
- **Transaccionalidad Segura:** Procedimientos almacenados blindados con bloques `BEGIN...EXCEPTION` que previenen condiciones de carrera (Race Conditions) y aseguran que un fallo aislado no corrompa el lote completo de datos.
- **Borrado Lógico Obligatorio:** Implementación del atributo `is_active` en productos para inhabilitar registros sin romper la integridad referencial ni violar el historial de auditoría durante inyecciones concurrentes.

---

## 📂 Estructura del Repositorio
Siguiendo las buenas prácticas y lineamientos solicitados, el proyecto se organiza de la siguiente manera:

```text
├── sql/
│   ├── ddl/
│   │   ├── 01-structure_tables.sql       # Creación de tablas e índices de rendimiento
│   │   ├── 02-audit_trigger.sql          # Función y Triggers de auditoría CRUD en JSONB
│   │   ├── 03-stored_procedures.sql      # Procedimientos transaccionales y borrado lógico
│   │   └── 04-custom_functions.sql       # Funciones analíticas y reportes dinámicos
│   │
│   ├── dml/
│   │   ├── 02-insert_categories.sql      # Inserciones ordenadas con datos realistas
│   │   ├── 03-insert_suppliers.sql       # e identidades contextualizadas en español
│   │   ├── ...                           # (Secuencia del 02 al 08)
│   │   └── 08-insert_movement_details.sql
│   │
│   └── queries/
│       └── 10-advanced_queries.sql       # Pool de 10 consultas complejas de demostración
│
├── docs/
│   └── database_documentation.md         # Justificación de normalización y Diccionario de datos
└── README.md                             # Guía general del proyecto