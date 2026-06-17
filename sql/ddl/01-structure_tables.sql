-- =========================================================================
-- DDL SCRIPT: TABLE CREATION - INVENTORY MANAGEMENT SYSTEM
-- =========================================================================

-- 1. Categories Table
CREATE TABLE categories (
    id_category SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT
);

-- 2. Suppliers Table
CREATE TABLE suppliers (
    id_supplier SERIAL PRIMARY KEY,
    company_name VARCHAR(150) NOT NULL,
    contact_name VARCHAR(100),
    phone VARCHAR(20),
    email VARCHAR(100) UNIQUE,
    address TEXT
);

-- 3. Products Table
CREATE TABLE products (
    id_product SERIAL PRIMARY KEY,
    id_category INT REFERENCES categories(id_category) ON DELETE SET NULL,
    id_supplier INT REFERENCES suppliers(id_supplier) ON DELETE SET NULL,
    barcode VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(150) NOT NULL,
    description TEXT,
    sale_price NUMERIC(10, 2) NOT NULL CHECK (sale_price >= 0),
    current_stock INT NOT NULL DEFAULT 0 CHECK (current_stock >= 0),
    minimum_stock INT NOT NULL DEFAULT 5 CHECK (minimum_stock >= 0)
);

-- 4. Branches Table
CREATE TABLE branches (
    id_branch SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    address TEXT,
    phone VARCHAR(20)
);

-- 5. Users Table
CREATE TABLE users (
    id_user SERIAL PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    user_role VARCHAR(50) NOT NULL CHECK (user_role IN ('Admin', 'Operator', 'Supervisor')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 6. Inventory Movements Table (Header)
CREATE TABLE inventory_movements (
    id_movement SERIAL PRIMARY KEY,
    id_user INT REFERENCES users(id_user) ON DELETE RESTRICT,
    id_branch INT REFERENCES branches(id_branch) ON DELETE RESTRICT,
    movement_type VARCHAR(10) NOT NULL CHECK (movement_type IN ('IN', 'OUT')),
    movement_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    remarks TEXT
);

-- 7. Movement Details Table (N:M Junction Table between Movements and Products)
CREATE TABLE movement_details (
    id_detail SERIAL PRIMARY KEY,
    id_movement INT REFERENCES inventory_movements(id_movement) ON DELETE CASCADE,
    id_product INT REFERENCES products(id_product) ON DELETE RESTRICT,
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price NUMERIC(10, 2) NOT NULL CHECK (unit_price >= 0),
    CONSTRAINT uq_movement_product UNIQUE (id_movement, id_product)
);

-- 8. Audit Logs Table (Mandatory CRUD System)
CREATE TABLE audit_logs (
    id_audit SERIAL PRIMARY KEY,
    db_user VARCHAR(100) NOT NULL DEFAULT CURRENT_USER,
    action_type VARCHAR(10) NOT NULL CHECK (action_type IN ('INSERT', 'UPDATE', 'DELETE')),
    table_name VARCHAR(100) NOT NULL,
    old_values JSONB,
    new_values JSONB,
    action_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);