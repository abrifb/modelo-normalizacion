-- ======================================
-- SISTEMA DE ENCOMIENDAS
-- ======================================

SELECT * FROM cliente;
SELECT * FROM sucursal;
SELECT * FROM tarifa;

-- ----------------------
-- CLIENTE
-- ----------------------
CREATE TABLE cliente (
    id_cliente SERIAL PRIMARY KEY,
    nombre     VARCHAR(100) NOT NULL,
    email      VARCHAR(120) UNIQUE,
    telefono   VARCHAR(20)
);

-- ----------------------
-- SUCURSAL
-- ----------------------
CREATE TABLE sucursal (
    id_sucursal SERIAL PRIMARY KEY,
    nombre      VARCHAR(100) NOT NULL,
    ciudad      VARCHAR(50) NOT NULL
);

-- ----------------------
-- TARIFA
-- ----------------------
CREATE TABLE tarifa (
    id_tarifa   SERIAL PRIMARY KEY,
    descripcion VARCHAR(100),
    precio_base NUMERIC(10,2) NOT NULL CHECK (precio_base >= 0),
    precio_kg   NUMERIC(10,2) NOT NULL CHECK (precio_kg >= 0)
);

-- ----------------------
-- ESTADO (CATÁLOGO)
-- ----------------------
CREATE TABLE estado (
    id_estado SERIAL PRIMARY KEY,
    nombre    VARCHAR(50) NOT NULL UNIQUE
);

-- ----------------------
-- ENCOMIENDA
-- ----------------------
CREATE TABLE encomienda (
    id_encomienda      SERIAL PRIMARY KEY,
    fecha_envio        DATE NOT NULL,
    peso_kg            NUMERIC(6,2) NOT NULL CHECK (peso_kg > 0),
    monto_total        NUMERIC(12,2) NOT NULL CHECK (monto_total >= 0),

    id_cliente          INT NOT NULL,
    id_sucursal_origen  INT NOT NULL,
    id_sucursal_destino INT NOT NULL,
    id_tarifa           INT NOT NULL,

    CONSTRAINT fk_encomienda_cliente
        FOREIGN KEY (id_cliente)
        REFERENCES cliente(id_cliente)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT fk_encomienda_sucursal_origen
        FOREIGN KEY (id_sucursal_origen)
        REFERENCES sucursal(id_sucursal)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT fk_encomienda_sucursal_destino
        FOREIGN KEY (id_sucursal_destino)
        REFERENCES sucursal(id_sucursal)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT fk_encomienda_tarifa
        FOREIGN KEY (id_tarifa)
        REFERENCES tarifa(id_tarifa)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

-- ----------------------
-- HISTORIAL DE ESTADOS
-- ----------------------
CREATE TABLE historial_estado (
    id_historial SERIAL PRIMARY KEY,
    fecha_estado TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    id_encomienda INT NOT NULL,
    id_estado     INT NOT NULL,

    CONSTRAINT fk_historial_encomienda
        FOREIGN KEY (id_encomienda)
        REFERENCES encomienda(id_encomienda)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_historial_estado
        FOREIGN KEY (id_estado)
        REFERENCES estado(id_estado)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

INSERT INTO cliente (nombre, email, telefono)
VALUES
('Juan Pérez', 'juan@mail.com', '987654321'),
('María González', 'maria@mail.com', '912345678');

INSERT INTO sucursal (nombre, ciudad)
VALUES
('Sucursal Santiago Centro', 'Santiago'),
('Sucursal Valparaíso', 'Valparaíso');

INSERT INTO tarifa (descripcion, precio_base, precio_kg)
VALUES
('Tarifa estándar', 3000, 1200),
('Tarifa express', 5000, 2000);

INSERT INTO estado (nombre)
VALUES
('Recibida'),
('En tránsito'),
('Entregada');

SELECT * FROM estado;

INSERT INTO encomienda (
    fecha_envio,
    peso_kg,
    monto_total,
    id_cliente,
    id_sucursal_origen,
    id_sucursal_destino,
    id_tarifa
)
VALUES
('2026-02-01', 2.5, 6000, 1, 1, 2, 1),
('2026-02-02', 1.2, 5400, 2, 2, 1, 2);

    INSERT INTO historial_estado (id_encomienda, id_estado)
    VALUES
    (7, 1),  -- Recibida
    (7, 2),  -- En tránsito
    (8, 1);  -- Recibida

SELECT id_encomienda FROM encomienda;

--Ver encomiendas con cliente y sucursales
SELECT
    e.id_encomienda,
    c.nombre AS cliente,
    so.nombre AS sucursal_origen,
    sd.nombre AS sucursal_destino,
    e.fecha_envio,
    e.monto_total
FROM encomienda e
JOIN cliente c ON c.id_cliente = e.id_cliente
JOIN sucursal so ON so.id_sucursal = e.id_sucursal_origen
JOIN sucursal sd ON sd.id_sucursal = e.id_sucursal_destino;

--Ver historial completo de estados de cada encomienda

SELECT
    e.id_encomienda,
    es.nombre AS estado,
    h.fecha_estado
FROM historial_estado h
JOIN encomienda e ON e.id_encomienda = h.id_encomienda
JOIN estado es ON es.id_estado = h.id_estado
ORDER BY e.id_encomienda, h.fecha_estado;

--Estado actual de cada encomienda (último estado)
SELECT
    e.id_encomienda,
    es.nombre AS estado_actual,
    MAX(h.fecha_estado) AS fecha_estado
FROM encomienda e
JOIN historial_estado h ON h.id_encomienda = e.id_encomienda
JOIN estado es ON es.id_estado = h.id_estado
GROUP BY e.id_encomienda, es.nombre;



