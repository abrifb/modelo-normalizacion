DROP TABLE IF EXISTS
    transaccion,
    cuenta,
    tipotransaccion,
    cliente
CASCADE;

CREATE TABLE cliente (
    id_cliente SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    rut VARCHAR(12) UNIQUE NOT NULL,
    email VARCHAR(100)
);

CREATE TABLE cuenta (
    id_cuenta SERIAL PRIMARY KEY,
    numero_cuenta VARCHAR(20) UNIQUE NOT NULL,
    saldo NUMERIC(12,2) NOT NULL,
    id_cliente INT NOT NULL,
    CONSTRAINT fk_cuenta_cliente
        FOREIGN KEY (id_cliente)
        REFERENCES cliente(id_cliente)
);

CREATE TABLE tipotransaccion (
    id_tipo SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL
);

CREATE TABLE transaccion (
    id_transaccion SERIAL PRIMARY KEY,
    fecha DATE NOT NULL,
    monto NUMERIC(12,2) NOT NULL,
    id_cuenta INT NOT NULL,
    id_tipo INT NOT NULL,
    CONSTRAINT fk_transaccion_cuenta
        FOREIGN KEY (id_cuenta)
        REFERENCES cuenta(id_cuenta),
    CONSTRAINT fk_transaccion_tipo
        FOREIGN KEY (id_tipo)
        REFERENCES tipotransaccion(id_tipo)
);

INSERT INTO cliente (nombre, rut, email) VALUES
('Juan Pérez', '11.111.111-1', 'juan@mail.cl'),
('María Soto', '22.222.222-2', 'maria@mail.cl'),
('Pedro Rojas', '33.333.333-3', 'pedro@mail.cl');

INSERT INTO cuenta (numero_cuenta, saldo, id_cliente) VALUES
('CT-001', 150000, 1),
('CT-002', 850000, 2),
('CT-003', 320000, 3);

INSERT INTO tipotransaccion (nombre) VALUES
('Depósito'),
('Retiro'),
('Transferencia');

INSERT INTO transaccion (fecha, monto, id_cuenta, id_tipo) VALUES
('2026-02-01', 50000, 1, 1),
('2026-02-02', 20000, 1, 2),
('2026-02-03', 100000, 2, 1);

SELECT * FROM cliente;
SELECT * FROM cuenta;
SELECT * FROM tipotransaccion;
SELECT * FROM transaccion;


--Cuentas con cliente

SELECT
    c.numero_cuenta,
    c.saldo,
    cl.nombre AS cliente
FROM cuenta c
JOIN cliente cl ON cl.id_cliente = c.id_cliente;


--Transacciones detalladas

SELECT
    t.id_transaccion,
    t.fecha,
    tt.nombre AS tipo,
    t.monto,
    c.numero_cuenta
FROM transaccion t
JOIN tipotransaccion tt ON tt.id_tipo = t.id_tipo
JOIN cuenta c ON c.id_cuenta = t.id_cuenta
ORDER BY t.fecha;

--Total de movimientos por cuenta

SELECT
    c.numero_cuenta,
    SUM(t.monto) AS total_movimientos
FROM cuenta c
JOIN transaccion t ON t.id_cuenta = c.id_cuenta
GROUP BY c.numero_cuenta;

--Movimientos por cliente

SELECT
    cl.nombre AS cliente,
    COUNT(t.id_transaccion) AS cantidad_transacciones
FROM cliente cl
JOIN cuenta c ON c.id_cliente = cl.id_cliente
JOIN transaccion t ON t.id_cuenta = c.id_cuenta
GROUP BY cl.nombre;