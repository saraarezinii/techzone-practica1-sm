-- ESQUEMA OLAP
CREATE SCHEMA olap;

-- DIM TIEMPO
CREATE TABLE olap.dim_tiempo (
    tiempo_sk SERIAL PRIMARY KEY,
    fecha DATE NOT NULL,
    dia INT,
    mes INT,
    trimestre INT,
    anio INT,
    dia_semana VARCHAR(20),
    es_festivo BOOLEAN DEFAULT FALSE
);

-- DIM CLIENTE
CREATE TABLE olap.dim_cliente (
    cliente_sk SERIAL PRIMARY KEY,
    cliente_id INT NOT NULL,
    nombre VARCHAR(100),
    ciudad VARCHAR(50),
    provincia VARCHAR(50),
    segmento VARCHAR(20),
    fecha_inicio DATE DEFAULT CURRENT_DATE,
    fecha_fin DATE DEFAULT '9999-12-31',
    activo BOOLEAN DEFAULT TRUE
);

-- DIM PRODUCTO
CREATE TABLE olap.dim_producto (
    producto_sk SERIAL PRIMARY KEY,
    producto_id INT NOT NULL,
    nombre VARCHAR(100),
    categoria VARCHAR(100),
    marca VARCHAR(50),
    modelo VARCHAR(50),
    precio_venta NUMERIC(10,2),
    coste_unitario NUMERIC(10,2)
);

-- DIM EMPLEADO
CREATE TABLE olap.dim_empleado (
    empleado_sk SERIAL PRIMARY KEY,
    empleado_id INT NOT NULL,
    nombre VARCHAR(100),
    apellidos VARCHAR(100),
    puesto VARCHAR(50),
    sucursal VARCHAR(100),
    ciudad VARCHAR(50)
);

-- DIM SUCURSAL
CREATE TABLE olap.dim_sucursal (
    sucursal_sk SERIAL PRIMARY KEY,
    sucursal_id INT NOT NULL,
    nombre VARCHAR(100),
    ciudad VARCHAR(50),
    provincia VARCHAR(50),
    metros_cuadrados INT
);

-- DIM TRANSPORTISTA
CREATE TABLE olap.dim_transportista (
    transportista_sk SERIAL PRIMARY KEY,
    transportista_id INT NOT NULL,
    nombre VARCHAR(100),
    region_cobertura VARCHAR(100),
    coste_medio_envio NUMERIC(10,2)
);

-- DIM PROVEEDOR
CREATE TABLE olap.dim_proveedor (
    proveedor_sk SERIAL PRIMARY KEY,
    proveedor_id INT NOT NULL,
    nombre VARCHAR(100),
    ciudad VARCHAR(50),
    pais VARCHAR(50),
    plazo_entrega_dias INT
);


-- ETL DIM TIEMPO
INSERT INTO olap.dim_tiempo (fecha, dia, mes, trimestre, anio, dia_semana, es_festivo)
SELECT DISTINCT
    fecha_venta,
    EXTRACT(DAY FROM fecha_venta),
    EXTRACT(MONTH FROM fecha_venta),
    EXTRACT(QUARTER FROM fecha_venta),
    EXTRACT(YEAR FROM fecha_venta),
    TO_CHAR(fecha_venta, 'Day'),
    FALSE
FROM oltp_ventas.ventas
ORDER BY fecha_venta;

-- ETL DIM CLIENTE
INSERT INTO olap.dim_cliente (cliente_id, nombre, ciudad, provincia, segmento)
SELECT
    cliente_id,
    nombre,
    ciudad,
    provincia,
    segmento
FROM oltp_ventas.clientes;

-- ETL DIM PRODUCTO
INSERT INTO olap.dim_producto (producto_id, nombre, categoria, marca, modelo, precio_venta, coste_unitario)
SELECT
    p.producto_id,
    p.nombre,
    c.nombre AS categoria,
    p.marca,
    p.modelo,
    p.precio_venta,
    cp.coste_unitario
FROM oltp_ventas.productos p
JOIN oltp_ventas.categorias c ON p.categoria_id = c.categoria_id
JOIN oltp_inventario.costes_producto cp ON p.producto_id = cp.producto_id;

-- ETL DIM EMPLEADO
INSERT INTO olap.dim_empleado (empleado_id, nombre, apellidos, puesto, sucursal, ciudad)
SELECT
    e.empleado_id,
    e.nombre,
    e.apellidos,
    e.puesto,
    s.nombre AS sucursal,
    s.ciudad
FROM oltp_rrhh.empleados e
JOIN oltp_logistica.sucursales s ON e.sucursal_id = s.sucursal_id;

-- ETL DIM SUCURSAL
INSERT INTO olap.dim_sucursal (sucursal_id, nombre, ciudad, provincia, metros_cuadrados)
SELECT
    sucursal_id,
    nombre,
    ciudad,
    provincia,
    metros_cuadrados
FROM oltp_logistica.sucursales;

-- ETL DIM TRANSPORTISTA
INSERT INTO olap.dim_transportista (transportista_id, nombre, region_cobertura, coste_medio_envio)
SELECT
    transportista_id,
    nombre,
    region_cobertura,
    coste_medio_envio
FROM oltp_logistica.transportistas;

-- ETL DIM PROVEEDOR
INSERT INTO olap.dim_proveedor (proveedor_id, nombre, ciudad, pais, plazo_entrega_dias)
SELECT
    proveedor_id,
    nombre,
    ciudad,
    pais,
    plazo_entrega_dias
FROM oltp_inventario.proveedores;


-- Eliminamos la tabla si se creó a medias
DROP TABLE IF EXISTS olap.fact_ventas;

-- TABLA DE HECHOS CORREGIDA
CREATE TABLE olap.fact_ventas (
    venta_sk SERIAL PRIMARY KEY,
    tiempo_sk INT REFERENCES olap.dim_tiempo(tiempo_sk),
    cliente_sk INT REFERENCES olap.dim_cliente(cliente_sk),
    producto_sk INT REFERENCES olap.dim_producto(producto_sk),
    empleado_sk INT REFERENCES olap.dim_empleado(empleado_sk),
    sucursal_sk INT REFERENCES olap.dim_sucursal(sucursal_sk),
    cantidad INT,
    precio_unitario NUMERIC(10,2),
    descuento NUMERIC(5,2),
    ingresos NUMERIC(12,2),
    coste NUMERIC(12,2),
    margen NUMERIC(12,2)
);

-- ETL FACT VENTAS CORREGIDO
INSERT INTO olap.fact_ventas (
    tiempo_sk, cliente_sk, producto_sk, empleado_sk, sucursal_sk,
    cantidad, precio_unitario, descuento, ingresos, coste, margen
)
SELECT
    dt.tiempo_sk,
    dc.cliente_sk,
    dp.producto_sk,
    de.empleado_sk,
    ds.sucursal_sk,
    dv.cantidad,
    dv.precio_unitario,
    dv.descuento,
    dv.cantidad * dv.precio_unitario * (1 - dv.descuento / 100) AS ingresos,
    dv.cantidad * dp.coste_unitario AS coste,
    (dv.cantidad * dv.precio_unitario * (1 - dv.descuento / 100)) -
    (dv.cantidad * dp.coste_unitario) AS margen
FROM oltp_ventas.detalle_venta dv
JOIN oltp_ventas.ventas v ON dv.venta_id = v.venta_id
JOIN oltp_logistica.envios e ON v.venta_id = e.venta_id
JOIN olap.dim_tiempo dt ON dt.fecha = v.fecha_venta
JOIN olap.dim_cliente dc ON dc.cliente_id = v.cliente_id
JOIN olap.dim_producto dp ON dp.producto_id = dv.producto_id
JOIN olap.dim_empleado de ON de.empleado_id = (
    SELECT empleado_id FROM oltp_rrhh.empleados
    WHERE sucursal_id = e.sucursal_id
    LIMIT 1
)
JOIN olap.dim_sucursal ds ON ds.sucursal_id = e.sucursal_id;




-- MODELO COPO DE NIEVE
-- Desnormalizamos dim_producto separando la categoria

CREATE TABLE olap.dim_categoria (
    categoria_sk SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT
);

CREATE TABLE olap.dim_producto_snow (
    producto_sk SERIAL PRIMARY KEY,
    producto_id INT NOT NULL,
    nombre VARCHAR(100),
    categoria_sk INT REFERENCES olap.dim_categoria(categoria_sk),
    marca VARCHAR(50),
    modelo VARCHAR(50),
    precio_venta NUMERIC(10,2),
    coste_unitario NUMERIC(10,2)
);

-- ETL DIM CATEGORIA
INSERT INTO olap.dim_categoria (nombre, descripcion)
SELECT DISTINCT
    c.nombre,
    c.descripcion
FROM oltp_ventas.categorias c
ORDER BY c.nombre;

-- ETL DIM PRODUCTO SNOW
INSERT INTO olap.dim_producto_snow (
    producto_id, nombre, categoria_sk, marca, modelo, precio_venta, coste_unitario
)
SELECT
    p.producto_id,
    p.nombre,
    dc.categoria_sk,
    p.marca,
    p.modelo,
    p.precio_venta,
    cp.coste_unitario
FROM oltp_ventas.productos p
JOIN oltp_ventas.categorias c ON p.categoria_id = c.categoria_id
JOIN olap.dim_categoria dc ON dc.nombre = c.nombre
JOIN oltp_inventario.costes_producto cp ON p.producto_id = cp.producto_id;

-- TABLA DE HECHOS PARA COPO DE NIEVE
CREATE TABLE olap.fact_ventas_snow (
    venta_sk SERIAL PRIMARY KEY,
    tiempo_sk INT REFERENCES olap.dim_tiempo(tiempo_sk),
    cliente_sk INT REFERENCES olap.dim_cliente(cliente_sk),
    producto_sk INT REFERENCES olap.dim_producto_snow(producto_sk),
    empleado_sk INT REFERENCES olap.dim_empleado(empleado_sk),
    sucursal_sk INT REFERENCES olap.dim_sucursal(sucursal_sk),
    cantidad INT,
    precio_unitario NUMERIC(10,2),
    descuento NUMERIC(5,2),
    ingresos NUMERIC(12,2),
    coste NUMERIC(12,2),
    margen NUMERIC(12,2)
);

-- ETL FACT VENTAS SNOW
INSERT INTO olap.fact_ventas_snow (
    tiempo_sk, cliente_sk, producto_sk, empleado_sk, sucursal_sk,
    cantidad, precio_unitario, descuento, ingresos, coste, margen
)
SELECT
    dt.tiempo_sk,
    dc.cliente_sk,
    dp.producto_sk,
    de.empleado_sk,
    ds.sucursal_sk,
    dv.cantidad,
    dv.precio_unitario,
    dv.descuento,
    dv.cantidad * dv.precio_unitario * (1 - dv.descuento / 100) AS ingresos,
    dv.cantidad * dp.coste_unitario AS coste,
    (dv.cantidad * dv.precio_unitario * (1 - dv.descuento / 100)) -
    (dv.cantidad * dp.coste_unitario) AS margen
FROM oltp_ventas.detalle_venta dv
JOIN oltp_ventas.ventas v ON dv.venta_id = v.venta_id
JOIN oltp_logistica.envios e ON v.venta_id = e.venta_id
JOIN olap.dim_tiempo dt ON dt.fecha = v.fecha_venta
JOIN olap.dim_cliente dc ON dc.cliente_id = v.cliente_id
JOIN olap.dim_producto_snow dp ON dp.producto_id = dv.producto_id
JOIN olap.dim_empleado de ON de.empleado_id = (
    SELECT empleado_id FROM oltp_rrhh.empleados
    WHERE sucursal_id = e.sucursal_id
    LIMIT 1
)
JOIN olap.dim_sucursal ds ON ds.sucursal_id = e.sucursal_id;

SELECT
    t.anio,
    p.categoria,
    SUM(f.ingresos) AS total_ingresos,
    SUM(f.margen) AS total_margen
FROM olap.fact_ventas f
JOIN olap.dim_tiempo t ON f.tiempo_sk = t.tiempo_sk
JOIN olap.dim_producto p ON f.producto_sk = p.producto_sk
GROUP BY t.anio, p.categoria
ORDER BY t.anio, total_ingresos DESC;




