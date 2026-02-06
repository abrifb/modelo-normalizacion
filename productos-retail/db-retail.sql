DROP TABLE IF EXISTS
    pago,
    detalle_pedido,
    pedido,
    producto,
    categoria,
    cliente
CASCADE;

SELECT * FROM cliente;
SELECT * FROM categoria;
SELECT * FROM producto;
SELECT * FROM pedido;
SELECT * FROM detalle_pedido;
SELECT * FROM pago;



-- ==========================
-- SISTEMA RETAIL
-- ==========================

CREATE TABLE cliente (
    id_cliente SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(120) UNIQUE
);

CREATE TABLE categoria (
    id_categoria SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE producto (
    id_producto SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    precio NUMERIC(10,2) NOT NULL,
    stock INT NOT NULL,
    id_categoria INT NOT NULL,
    FOREIGN KEY (id_categoria)
        REFERENCES categoria(id_categoria)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

CREATE TABLE pedido (
    id_pedido SERIAL PRIMARY KEY,
    fecha_pedido DATE NOT NULL,
    total NUMERIC(12,2) NOT NULL,
    id_cliente INT NOT NULL,
    FOREIGN KEY (id_cliente)
        REFERENCES cliente(id_cliente)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

CREATE TABLE detalle_pedido (
    id_pedido INT NOT NULL,
    id_producto INT NOT NULL,
    cantidad INT NOT NULL,
    precio_unitario NUMERIC(10,2) NOT NULL,
    PRIMARY KEY (id_pedido, id_producto),
    FOREIGN KEY (id_pedido)
        REFERENCES pedido(id_pedido)
        ON DELETE CASCADE,
    FOREIGN KEY (id_producto)
        REFERENCES producto(id_producto)
        ON DELETE RESTRICT
);

CREATE TABLE pago (
    id_pago SERIAL PRIMARY KEY,
    fecha_pago DATE NOT NULL,
    monto NUMERIC(12,2) NOT NULL,
    metodo VARCHAR(50),
    id_pedido INT NOT NULL,
    FOREIGN KEY (id_pedido)
        REFERENCES pedido(id_pedido)
        ON DELETE CASCADE
);

INSERT INTO cliente (nombre, email) VALUES
('Ana Soto', 'ana@mail.com'),
('Carlos Díaz', 'carlos@mail.com'),
('María López', 'maria@mail.com');

INSERT INTO categoria (nombre) VALUES
('Electrónica'),
('Hogar'),
('Oficina');


INSERT INTO producto (nombre, precio, stock, id_categoria) VALUES
('Mouse', 8000, 50, 1),
('Teclado', 15000, 30, 1),
('Silla Oficina', 85000, 10, 3),
('Lámpara', 12000, 25, 2);

INSERT INTO pedido (fecha_pedido, total, id_cliente) VALUES
('2026-02-05', 23000, 1),
('2026-02-06', 85000, 2),
('2026-02-07', 20000, 3);

INSERT INTO detalle_pedido (id_pedido, id_producto, cantidad, precio_unitario) VALUES
(1, 1, 1, 8000),
(1, 2, 1, 15000),
(2, 3, 1, 85000),
(3, 4, 2, 10000);

--SELECT DE PRUEBA

--Total vendido por pedido (recalculado)

SELECT
    pe.id_pedido,
    SUM(dp.cantidad * dp.precio_unitario) AS total_calculado,
    pe.total AS total_registrado
FROM pedido pe
JOIN detalle_pedido dp ON dp.id_pedido = pe.id_pedido
GROUP BY pe.id_pedido, pe.total
ORDER BY pe.id_pedido;

--Total comprado por cliente

SELECT
    cl.nombre AS cliente,
    SUM(pe.total) AS total_comprado
FROM cliente cl
JOIN pedido pe ON pe.id_cliente = cl.id_cliente
GROUP BY cl.nombre
ORDER BY total_comprado DESC;

--Productos más vendidos

SELECT
    pr.nombre AS producto,
    SUM(dp.cantidad) AS cantidad_vendida
FROM producto pr
JOIN detalle_pedido dp ON dp.id_producto = pr.id_producto
GROUP BY pr.nombre
ORDER BY cantidad_vendida DESC;
