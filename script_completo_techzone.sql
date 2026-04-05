-- ============================================================
-- SCRIPT COMPLETO TECHZONE S.L.
-- Sistemas Multidimensionales — Práctica 1
-- Alumna: Sara Rezini Ahmed
-- Universidad de Granada
-- ============================================================

-- ============================================================
-- PASO 1: CREACIÓN DE ESQUEMAS
-- ============================================================

CREATE SCHEMA oltp_ventas;
CREATE SCHEMA oltp_inventario;
CREATE SCHEMA oltp_logistica;
CREATE SCHEMA oltp_rrhh;
CREATE SCHEMA oltp_finanzas;

-- ============================================================
-- PASO 2: DDL SISTEMA OLTP
-- ============================================================

-- ---- LOGISTICA (primero porque otros dependen de sucursales) ----

CREATE TABLE oltp_logistica.sucursales (
    sucursal_id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    ciudad VARCHAR(50) NOT NULL,
    provincia VARCHAR(50),
    direccion VARCHAR(150),
    metros_cuadrados INT,
    fecha_apertura DATE
);

CREATE TABLE oltp_logistica.transportistas (
    transportista_id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    telefono VARCHAR(20),
    email VARCHAR(100),
    region_cobertura VARCHAR(100),
    coste_medio_envio NUMERIC(10,2)
);

CREATE TABLE oltp_logistica.envios (
    envio_id SERIAL PRIMARY KEY,
    venta_id INT,
    transportista_id INT REFERENCES oltp_logistica.transportistas(transportista_id),
    sucursal_id INT REFERENCES oltp_logistica.sucursales(sucursal_id),
    fecha_envio DATE NOT NULL,
    fecha_entrega_estimada DATE,
    fecha_entrega_real DATE,
    coste_envio NUMERIC(10,2),
    estado VARCHAR(20) CHECK (estado IN ('Pendiente','En camino','Entregado','Devuelto'))
);

CREATE TABLE oltp_logistica.incidencias (
    incidencia_id SERIAL PRIMARY KEY,
    envio_id INT REFERENCES oltp_logistica.envios(envio_id),
    tipo VARCHAR(50),
    descripcion TEXT,
    fecha_incidencia DATE,
    resuelta BOOLEAN DEFAULT FALSE
);

-- ---- VENTAS ----

CREATE TABLE oltp_ventas.clientes (
    cliente_id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    telefono VARCHAR(20),
    ciudad VARCHAR(50) NOT NULL,
    provincia VARCHAR(50),
    segmento VARCHAR(20) CHECK (segmento IN ('Premium','Estandar','Ocasional'))
);

CREATE TABLE oltp_ventas.categorias (
    categoria_id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT
);

CREATE TABLE oltp_ventas.productos (
    producto_id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    categoria_id INT REFERENCES oltp_ventas.categorias(categoria_id),
    precio_venta NUMERIC(10,2) NOT NULL,
    marca VARCHAR(50),
    modelo VARCHAR(50)
);

CREATE TABLE oltp_ventas.ventas (
    venta_id SERIAL PRIMARY KEY,
    cliente_id INT REFERENCES oltp_ventas.clientes(cliente_id),
    fecha_venta DATE NOT NULL,
    total NUMERIC(12,2)
);

CREATE TABLE oltp_ventas.detalle_venta (
    detalle_id SERIAL PRIMARY KEY,
    venta_id INT REFERENCES oltp_ventas.ventas(venta_id),
    producto_id INT REFERENCES oltp_ventas.productos(producto_id),
    cantidad INT NOT NULL CHECK (cantidad > 0),
    precio_unitario NUMERIC(10,2) NOT NULL,
    descuento NUMERIC(5,2) DEFAULT 0
);

-- ---- INVENTARIO ----

CREATE TABLE oltp_inventario.proveedores (
    proveedor_id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    contacto VARCHAR(100),
    telefono VARCHAR(20),
    ciudad VARCHAR(50),
    pais VARCHAR(50) DEFAULT 'España',
    plazo_entrega_dias INT
);

CREATE TABLE oltp_inventario.almacenes (
    almacen_id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    ciudad VARCHAR(50),
    provincia VARCHAR(50),
    capacidad_max INT
);

CREATE TABLE oltp_inventario.stock (
    stock_id SERIAL PRIMARY KEY,
    producto_id INT REFERENCES oltp_ventas.productos(producto_id),
    almacen_id INT REFERENCES oltp_inventario.almacenes(almacen_id),
    cantidad_disponible INT NOT NULL DEFAULT 0,
    cantidad_minima INT DEFAULT 5,
    ultima_actualizacion DATE
);

CREATE TABLE oltp_inventario.costes_producto (
    coste_id SERIAL PRIMARY KEY,
    producto_id INT REFERENCES oltp_ventas.productos(producto_id),
    proveedor_id INT REFERENCES oltp_inventario.proveedores(proveedor_id),
    coste_unitario NUMERIC(10,2) NOT NULL,
    fecha_actualizacion DATE
);

-- ---- RRHH ----

CREATE TABLE oltp_rrhh.empleados (
    empleado_id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    telefono VARCHAR(20),
    puesto VARCHAR(50),
    fecha_contrato DATE,
    salario NUMERIC(10,2),
    sucursal_id INT REFERENCES oltp_logistica.sucursales(sucursal_id)
);

CREATE TABLE oltp_rrhh.turnos (
    turno_id SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    hora_inicio TIME,
    hora_fin TIME
);

CREATE TABLE oltp_rrhh.asignacion_turnos (
    asignacion_id SERIAL PRIMARY KEY,
    empleado_id INT REFERENCES oltp_rrhh.empleados(empleado_id),
    turno_id INT REFERENCES oltp_rrhh.turnos(turno_id),
    fecha DATE NOT NULL,
    sucursal_id INT REFERENCES oltp_logistica.sucursales(sucursal_id)
);

CREATE TABLE oltp_rrhh.ausencias (
    ausencia_id SERIAL PRIMARY KEY,
    empleado_id INT REFERENCES oltp_rrhh.empleados(empleado_id),
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE,
    motivo VARCHAR(100),
    justificada BOOLEAN DEFAULT FALSE
);

-- ---- FINANZAS ----

CREATE TABLE oltp_finanzas.facturas (
    factura_id SERIAL PRIMARY KEY,
    venta_id INT REFERENCES oltp_ventas.ventas(venta_id),
    fecha_factura DATE NOT NULL,
    importe_total NUMERIC(12,2),
    iva NUMERIC(5,2) DEFAULT 21.00,
    estado VARCHAR(20) CHECK (estado IN ('Pendiente','Pagada','Anulada'))
);

CREATE TABLE oltp_finanzas.pagos (
    pago_id SERIAL PRIMARY KEY,
    factura_id INT REFERENCES oltp_finanzas.facturas(factura_id),
    fecha_pago DATE NOT NULL,
    importe NUMERIC(12,2),
    metodo_pago VARCHAR(50) CHECK (metodo_pago IN ('Efectivo','Tarjeta','Transferencia','Bizum'))
);

CREATE TABLE oltp_finanzas.gastos (
    gasto_id SERIAL PRIMARY KEY,
    sucursal_id INT REFERENCES oltp_logistica.sucursales(sucursal_id),
    concepto VARCHAR(100) NOT NULL,
    importe NUMERIC(12,2),
    fecha DATE NOT NULL,
    categoria VARCHAR(50)
);

CREATE TABLE oltp_finanzas.presupuestos (
    presupuesto_id SERIAL PRIMARY KEY,
    sucursal_id INT REFERENCES oltp_logistica.sucursales(sucursal_id),
    anio INT NOT NULL,
    trimestre INT CHECK (trimestre BETWEEN 1 AND 4),
    importe_objetivo NUMERIC(12,2),
    importe_real NUMERIC(12,2)
);

-- ============================================================
-- PASO 3: DML — DATOS SINTÉTICOS
-- ============================================================

-- ---- SUCURSALES ----
INSERT INTO oltp_logistica.sucursales (nombre, ciudad, provincia, direccion, metros_cuadrados, fecha_apertura) VALUES
('TechZone Sevilla Centro', 'Sevilla', 'Sevilla', 'Calle Sierpes 45', 320, '2015-03-10'),
('TechZone Málaga', 'Málaga', 'Málaga', 'Avenida de Andalucía 12', 280, '2016-06-15'),
('TechZone Granada', 'Granada', 'Granada', 'Gran Vía 33', 250, '2017-09-01'),
('TechZone Córdoba', 'Córdoba', 'Córdoba', 'Calle Cruz Conde 8', 210, '2018-02-20'),
('TechZone Almería', 'Almería', 'Almería', 'Paseo de Almería 67', 190, '2019-05-11'),
('TechZone Ceuta', 'Ceuta', 'Ceuta', 'Calle Real 22', 175, '2020-01-08');

-- ---- CATEGORIAS ----
INSERT INTO oltp_ventas.categorias (nombre, descripcion) VALUES
('Smartphones', 'Teléfonos móviles y accesorios'),
('Portátiles', 'Ordenadores portátiles y ultrabooks'),
('Tablets', 'Tablets y e-readers'),
('Accesorios', 'Fundas, cargadores, auriculares y periféricos'),
('Smartwatches', 'Relojes inteligentes y pulseras de actividad'),
('Televisores', 'Smart TVs y monitores');

-- ---- PRODUCTOS ----
INSERT INTO oltp_ventas.productos (nombre, categoria_id, precio_venta, marca, modelo) VALUES
('iPhone 15', 1, 1099.00, 'Apple', 'iPhone 15'),
('Samsung Galaxy S24', 1, 949.00, 'Samsung', 'Galaxy S24'),
('Xiaomi 14', 1, 799.00, 'Xiaomi', '14'),
('iPhone 15 Pro', 1, 1299.00, 'Apple', 'iPhone 15 Pro'),
('MacBook Air M2', 2, 1449.00, 'Apple', 'MacBook Air M2'),
('Dell XPS 13', 2, 1299.00, 'Dell', 'XPS 13'),
('Lenovo ThinkPad X1', 2, 1199.00, 'Lenovo', 'ThinkPad X1'),
('HP Spectre x360', 2, 1349.00, 'HP', 'Spectre x360'),
('iPad Air', 3, 749.00, 'Apple', 'iPad Air'),
('Samsung Galaxy Tab S9', 3, 699.00, 'Samsung', 'Galaxy Tab S9'),
('AirPods Pro', 4, 279.00, 'Apple', 'AirPods Pro 2'),
('Samsung Galaxy Buds', 4, 149.00, 'Samsung', 'Galaxy Buds 2'),
('Funda iPhone 15', 4, 29.00, 'Apple', 'Funda Silicona'),
('Cargador USB-C 65W', 4, 49.00, 'Anker', 'PowerPort III'),
('Apple Watch Series 9', 5, 449.00, 'Apple', 'Watch Series 9'),
('Samsung Galaxy Watch 6', 5, 299.00, 'Samsung', 'Galaxy Watch 6'),
('Samsung QLED 55"', 6, 899.00, 'Samsung', 'QLED Q70C'),
('LG OLED 55"', 6, 1199.00, 'LG', 'OLED C3'),
('Teclado Logitech MX', 4, 119.00, 'Logitech', 'MX Keys'),
('Ratón Logitech MX', 4, 99.00, 'Logitech', 'MX Master 3');

-- ---- CLIENTES ----
INSERT INTO oltp_ventas.clientes (nombre, email, telefono, ciudad, provincia, segmento) VALUES
('Carlos García López', 'carlos.garcia@gmail.com', '+34-611-234567', 'Sevilla', 'Sevilla', 'Premium'),
('María Fernández Ruiz', 'maria.fernandez@hotmail.com', '+34-622-345678', 'Málaga', 'Málaga', 'Estandar'),
('Antonio Martínez Pérez', 'antonio.martinez@gmail.com', '+34-633-456789', 'Granada', 'Granada', 'Premium'),
('Laura Sánchez Torres', 'laura.sanchez@yahoo.es', '+34-644-567890', 'Córdoba', 'Córdoba', 'Ocasional'),
('José Romero Díaz', 'jose.romero@gmail.com', '+34-655-678901', 'Almería', 'Almería', 'Estandar'),
('Ana López Jiménez', 'ana.lopez@gmail.com', '+34-666-789012', 'Ceuta', 'Ceuta', 'Premium'),
('Miguel Moreno Castro', 'miguel.moreno@hotmail.com', '+34-677-890123', 'Sevilla', 'Sevilla', 'Estandar'),
('Isabel Ruiz Navarro', 'isabel.ruiz@gmail.com', '+34-688-901234', 'Málaga', 'Málaga', 'Ocasional'),
('Francisco Jiménez Gil', 'francisco.jimenez@gmail.com', '+34-699-012345', 'Granada', 'Granada', 'Premium'),
('Carmen Díaz Vargas', 'carmen.diaz@yahoo.es', '+34-611-123456', 'Córdoba', 'Córdoba', 'Estandar'),
('Pedro Álvarez Reyes', 'pedro.alvarez@gmail.com', '+34-622-234567', 'Almería', 'Almería', 'Ocasional'),
('Lucía Torres Molina', 'lucia.torres@gmail.com', '+34-633-345678', 'Ceuta', 'Ceuta', 'Premium'),
('David Herrera Ortega', 'david.herrera@hotmail.com', '+34-644-456789', 'Sevilla', 'Sevilla', 'Estandar'),
('Sara Flores Campos', 'sara.flores@gmail.com', '+34-655-567890', 'Málaga', 'Málaga', 'Premium'),
('Javier Morales Vega', 'javier.morales@gmail.com', '+34-666-678901', 'Granada', 'Granada', 'Estandar'),
('Elena Castro Blanco', 'elena.castro@yahoo.es', '+34-677-789012', 'Córdoba', 'Córdoba', 'Ocasional'),
('Roberto Núñez Pardo', 'roberto.nunez@gmail.com', '+34-688-890123', 'Almería', 'Almería', 'Premium'),
('Patricia Serrano Luna', 'patricia.serrano@gmail.com', '+34-699-901234', 'Ceuta', 'Ceuta', 'Estandar'),
('Alejandro Ramos Cruz', 'alejandro.ramos@hotmail.com', '+34-611-345678', 'Sevilla', 'Sevilla', 'Premium'),
('Cristina Peña Medina', 'cristina.pena@gmail.com', '+34-622-456789', 'Málaga', 'Málaga', 'Ocasional'),
('Fernando Aguilar Soto', 'fernando.aguilar@gmail.com', '+34-633-567890', 'Granada', 'Granada', 'Estandar'),
('Marta Gutiérrez Ríos', 'marta.gutierrez@yahoo.es', '+34-644-678901', 'Córdoba', 'Córdoba', 'Premium'),
('Raúl Molina Fuentes', 'raul.molina@gmail.com', '+34-655-789012', 'Almería', 'Almería', 'Estandar'),
('Nuria Ortega Carrasco', 'nuria.ortega@gmail.com', '+34-666-890123', 'Ceuta', 'Ceuta', 'Premium'),
('Sergio Blanco Ibáñez', 'sergio.blanco@hotmail.com', '+34-677-901234', 'Sevilla', 'Sevilla', 'Ocasional');

-- ---- EMPLEADOS ----
INSERT INTO oltp_rrhh.empleados (nombre, apellidos, email, telefono, puesto, fecha_contrato, salario, sucursal_id) VALUES
('Carlos', 'Pérez Ruiz', 'carlos.perez@techzone.es', '+34-611-111001', 'Vendedor', '2020-01-15', 1800.00, 1),
('María', 'González López', 'maria.gonzalez@techzone.es', '+34-622-111002', 'Vendedor', '2020-03-10', 1800.00, 1),
('Antonio', 'Fernández Díaz', 'antonio.fernandez@techzone.es', '+34-633-111003', 'Supervisor', '2019-06-01', 2200.00, 1),
('Laura', 'Martínez García', 'laura.martinez@techzone.es', '+34-644-111004', 'Vendedor', '2021-02-20', 1800.00, 2),
('José', 'Sánchez Torres', 'jose.sanchez@techzone.es', '+34-655-111005', 'Vendedor', '2021-05-15', 1800.00, 2),
('Ana', 'Romero Castro', 'ana.romero@techzone.es', '+34-666-111006', 'Supervisor', '2018-09-01', 2200.00, 2),
('Miguel', 'López Jiménez', 'miguel.lopez@techzone.es', '+34-677-111007', 'Vendedor', '2022-01-10', 1800.00, 3),
('Isabel', 'Moreno Navarro', 'isabel.moreno@techzone.es', '+34-688-111008', 'Vendedor', '2022-03-15', 1800.00, 3),
('Francisco', 'Ruiz Gil', 'francisco.ruiz@techzone.es', '+34-699-111009', 'Supervisor', '2019-11-01', 2200.00, 3),
('Carmen', 'Jiménez Vargas', 'carmen.jimenez@techzone.es', '+34-611-111010', 'Vendedor', '2020-07-20', 1800.00, 4),
('Pedro', 'Díaz Reyes', 'pedro.diaz@techzone.es', '+34-622-111011', 'Vendedor', '2021-09-10', 1800.00, 4),
('Lucía', 'Álvarez Molina', 'lucia.alvarez@techzone.es', '+34-633-111012', 'Supervisor', '2018-04-15', 2200.00, 4),
('David', 'Torres Ortega', 'david.torres@techzone.es', '+34-644-111013', 'Vendedor', '2022-06-01', 1800.00, 5),
('Sara', 'Herrera Campos', 'sara.herrera@techzone.es', '+34-655-111014', 'Vendedor', '2022-08-20', 1800.00, 5),
('Javier', 'Flores Vega', 'javier.flores@techzone.es', '+34-666-111015', 'Supervisor', '2020-02-10', 2200.00, 5),
('Elena', 'Morales Blanco', 'elena.morales@techzone.es', '+34-677-111016', 'Vendedor', '2021-11-15', 1800.00, 6),
('Roberto', 'Castro Pardo', 'roberto.castro@techzone.es', '+34-688-111017', 'Vendedor', '2022-04-01', 1800.00, 6),
('Patricia', 'Núñez Luna', 'patricia.nunez@techzone.es', '+34-699-111018', 'Supervisor', '2019-08-20', 2200.00, 6);

-- ---- TURNOS ----
INSERT INTO oltp_rrhh.turnos (nombre, hora_inicio, hora_fin) VALUES
('Mañana', '09:00', '14:00'),
('Tarde', '15:00', '21:00'),
('Completo', '09:00', '21:00');

-- ---- VENTAS ----
INSERT INTO oltp_ventas.ventas (cliente_id, fecha_venta, total) VALUES
(1, '2023-01-15', 1099.00),(2, '2023-01-22', 949.00),(3, '2023-02-05', 1728.00),
(4, '2023-02-14', 279.00),(5, '2023-03-01', 1449.00),(6, '2023-03-18', 749.00),
(7, '2023-04-02', 299.00),(8, '2023-04-20', 1299.00),(9, '2023-05-10', 899.00),
(10, '2023-05-28', 449.00),(11, '2023-06-05', 799.00),(12, '2023-06-22', 1199.00),
(13, '2023-07-08', 149.00),(14, '2023-07-25', 1349.00),(15, '2023-08-12', 119.00),
(16, '2023-08-30', 99.00),(17, '2023-09-14', 1299.00),(18, '2023-09-28', 949.00),
(19, '2023-10-05', 749.00),(20, '2023-10-19', 279.00),(21, '2023-11-03', 1099.00),
(22, '2023-11-20', 449.00),(23, '2023-12-01', 1449.00),(24, '2023-12-15', 899.00),
(25, '2024-01-10', 299.00),(1, '2024-01-25', 1299.00),(2, '2024-02-08', 799.00),
(3, '2024-02-22', 149.00),(4, '2024-03-07', 1199.00),(5, '2024-03-21', 449.00),
(6, '2024-04-04', 949.00),(7, '2024-04-18', 1099.00),(8, '2024-05-02', 279.00),
(9, '2024-05-16', 749.00),(10, '2024-05-30', 1449.00),(11, '2024-06-13', 119.00),
(12, '2024-06-27', 99.00),(13, '2024-07-11', 899.00),(14, '2024-07-25', 1299.00),
(15, '2024-08-08', 449.00),(16, '2024-08-22', 799.00),(17, '2024-09-05', 149.00),
(18, '2024-09-19', 1199.00),(19, '2024-10-03', 949.00),(20, '2024-10-17', 1099.00),
(21, '2024-11-01', 279.00),(22, '2024-11-15', 749.00),(23, '2024-12-01', 1449.00),
(24, '2024-12-15', 899.00),(25, '2024-12-28', 299.00);

-- ---- DETALLE VENTA ----
INSERT INTO oltp_ventas.detalle_venta (venta_id, producto_id, cantidad, precio_unitario, descuento) VALUES
(1,1,1,1099.00,0),(2,2,1,949.00,0),(3,5,1,1449.00,5),(3,11,1,279.00,0),
(4,11,1,279.00,0),(5,5,1,1449.00,0),(6,9,1,749.00,0),(7,16,1,299.00,0),
(8,8,1,1349.00,3),(9,17,1,899.00,0),(10,15,1,449.00,0),(11,3,1,799.00,0),
(12,18,1,1199.00,5),(13,12,1,149.00,0),(14,8,1,1349.00,0),(15,19,1,119.00,0),
(16,20,1,99.00,0),(17,6,1,1299.00,0),(18,2,1,949.00,0),(19,9,1,749.00,0),
(20,11,1,279.00,0),(21,1,1,1099.00,0),(22,15,1,449.00,0),(23,5,1,1449.00,0),
(24,17,1,899.00,0),(25,16,1,299.00,0);

-- ---- PROVEEDORES ----
INSERT INTO oltp_inventario.proveedores (nombre, contacto, telefono, ciudad, pais, plazo_entrega_dias) VALUES
('Apple Iberia S.L.', 'Juan Apple', '+34-911-100001', 'Madrid', 'España', 3),
('Samsung Electronics España', 'Pedro Samsung', '+34-911-100002', 'Madrid', 'España', 4),
('Xiaomi España', 'Luis Xiaomi', '+34-911-100003', 'Madrid', 'España', 5),
('Dell Technologies España', 'Ana Dell', '+34-911-100004', 'Madrid', 'España', 7),
('Lenovo España', 'Sara Lenovo', '+34-911-100005', 'Barcelona', 'España', 6),
('HP España', 'Carlos HP', '+34-911-100006', 'Barcelona', 'España', 5),
('LG Electronics España', 'María LG', '+34-911-100007', 'Madrid', 'España', 6),
('Logitech Iberia', 'Antonio Logi', '+34-911-100008', 'Barcelona', 'España', 4),
('Anker España', 'Laura Anker', '+34-911-100009', 'Valencia', 'España', 3);

-- ---- ALMACENES ----
INSERT INTO oltp_inventario.almacenes (nombre, ciudad, provincia, capacidad_max) VALUES
('Almacén Central Sevilla', 'Sevilla', 'Sevilla', 5000),
('Almacén Málaga', 'Málaga', 'Málaga', 3000),
('Almacén Granada', 'Granada', 'Granada', 2500),
('Almacén Sur', 'Córdoba', 'Córdoba', 2000);

-- ---- STOCK ----
INSERT INTO oltp_inventario.stock (producto_id, almacen_id, cantidad_disponible, cantidad_minima, ultima_actualizacion) VALUES
(1,1,45,10,'2024-12-01'),(2,1,38,10,'2024-12-01'),(3,1,52,10,'2024-12-01'),
(4,1,30,8,'2024-12-01'),(5,2,25,5,'2024-12-01'),(6,2,18,5,'2024-12-01'),
(7,2,22,5,'2024-12-01'),(8,2,15,5,'2024-12-01'),(9,3,40,8,'2024-12-01'),
(10,3,35,8,'2024-12-01'),(11,1,80,15,'2024-12-01'),(12,1,65,15,'2024-12-01'),
(13,1,120,20,'2024-12-01'),(14,1,95,20,'2024-12-01'),(15,2,28,8,'2024-12-01'),
(16,2,32,8,'2024-12-01'),(17,3,20,5,'2024-12-01'),(18,3,15,5,'2024-12-01'),
(19,4,45,10,'2024-12-01'),(20,4,50,10,'2024-12-01');

-- ---- COSTES PRODUCTO ----
INSERT INTO oltp_inventario.costes_producto (producto_id, proveedor_id, coste_unitario, fecha_actualizacion) VALUES
(1,1,780.00,'2024-01-01'),(2,2,650.00,'2024-01-01'),(3,3,540.00,'2024-01-01'),
(4,1,920.00,'2024-01-01'),(5,1,980.00,'2024-01-01'),(6,4,850.00,'2024-01-01'),
(7,5,780.00,'2024-01-01'),(8,6,880.00,'2024-01-01'),(9,1,480.00,'2024-01-01'),
(10,2,440.00,'2024-01-01'),(11,1,160.00,'2024-01-01'),(12,2,85.00,'2024-01-01'),
(13,1,12.00,'2024-01-01'),(14,9,22.00,'2024-01-01'),(15,1,280.00,'2024-01-01'),
(16,2,180.00,'2024-01-01'),(17,2,580.00,'2024-01-01'),(18,7,750.00,'2024-01-01'),
(19,8,65.00,'2024-01-01'),(20,8,55.00,'2024-01-01');

-- ---- TRANSPORTISTAS ----
INSERT INTO oltp_logistica.transportistas (nombre, telefono, email, region_cobertura, coste_medio_envio) VALUES
('MRW Andalucía', '+34-900-300400', 'mrw@mrw.es', 'Andalucía', 4.50),
('SEUR Sur', '+34-900-100010', 'seur@seur.es', 'Andalucía y Ceuta', 5.20),
('GLS España', '+34-900-100020', 'gls@gls-spain.es', 'Nacional', 4.80),
('Correos Express', '+34-902-197197', 'correos@correos.es', 'Nacional', 3.90),
('DHL Express', '+34-902-345345', 'dhl@dhl.es', 'Internacional', 8.50);

-- ---- ENVIOS ----
INSERT INTO oltp_logistica.envios (venta_id, transportista_id, sucursal_id, fecha_envio, fecha_entrega_estimada, fecha_entrega_real, coste_envio, estado) VALUES
(1,1,1,'2023-01-16','2023-01-18','2023-01-18',4.50,'Entregado'),
(2,2,2,'2023-01-23','2023-01-25','2023-01-26',5.20,'Entregado'),
(3,1,1,'2023-02-06','2023-02-08','2023-02-08',4.50,'Entregado'),
(4,3,3,'2023-02-15','2023-02-17','2023-02-17',4.80,'Entregado'),
(5,2,2,'2023-03-02','2023-03-04','2023-03-05',5.20,'Entregado'),
(6,4,4,'2023-03-19','2023-03-21','2023-03-21',3.90,'Entregado'),
(7,1,1,'2023-04-03','2023-04-05','2023-04-05',4.50,'Entregado'),
(8,3,3,'2023-04-21','2023-04-23','2023-04-24',4.80,'Entregado'),
(9,2,2,'2023-05-11','2023-05-13','2023-05-13',5.20,'Entregado'),
(10,4,4,'2023-05-29','2023-05-31','2023-05-31',3.90,'Entregado'),
(11,1,1,'2023-06-06','2023-06-08','2023-06-09',4.50,'Entregado'),
(12,5,5,'2023-06-23','2023-06-25','2023-06-25',8.50,'Entregado'),
(13,3,3,'2023-07-09','2023-07-11','2023-07-11',4.80,'Entregado'),
(14,2,2,'2023-07-26','2023-07-28','2023-07-28',5.20,'Entregado'),
(15,4,4,'2023-08-13','2023-08-15','2023-08-15',3.90,'Entregado'),
(16,1,1,'2023-08-31','2023-09-02','2023-09-02',4.50,'Entregado'),
(17,3,3,'2023-09-15','2023-09-17','2023-09-18',4.80,'Entregado'),
(18,2,2,'2023-09-29','2023-10-01','2023-10-01',5.20,'Entregado'),
(19,4,4,'2023-10-06','2023-10-08','2023-10-08',3.90,'Entregado'),
(20,5,5,'2023-10-20','2023-10-22','2023-10-23',8.50,'Entregado'),
(21,1,1,'2023-11-04','2023-11-06','2023-11-06',4.50,'Entregado'),
(22,2,2,'2023-11-21','2023-11-23','2023-11-23',5.20,'Entregado'),
(23,3,3,'2023-12-02','2023-12-04','2023-12-04',4.80,'Entregado'),
(24,4,4,'2023-12-16','2023-12-18','2023-12-19',3.90,'Entregado'),
(25,1,1,'2024-01-11','2024-01-13','2024-01-13',4.50,'Entregado');

-- ---- INCIDENCIAS ----
INSERT INTO oltp_logistica.incidencias (envio_id, tipo, descripcion, fecha_incidencia, resuelta) VALUES
(2,'Retraso','Retraso de un día por volumen de pedidos','2023-01-26',true),
(5,'Retraso','Retraso por condiciones meteorológicas','2023-03-05',true),
(8,'Retraso','Retraso de un día en la entrega','2023-04-24',true),
(11,'Retraso','Entrega tardía por falta de personal','2023-06-09',true),
(17,'Retraso','Retraso por huelga de transportes','2023-09-18',true),
(20,'Daño','Producto con embalaje dañado, resuelta con reenvío','2023-10-23',true),
(24,'Retraso','Retraso por festivos navideños','2023-12-19',true);

-- ---- FACTURAS ----
INSERT INTO oltp_finanzas.facturas (venta_id, fecha_factura, importe_total, iva, estado) VALUES
(1,'2023-01-15',1099.00,21.00,'Pagada'),(2,'2023-01-22',949.00,21.00,'Pagada'),
(3,'2023-02-05',1728.00,21.00,'Pagada'),(4,'2023-02-14',279.00,21.00,'Pagada'),
(5,'2023-03-01',1449.00,21.00,'Pagada'),(6,'2023-03-18',749.00,21.00,'Pagada'),
(7,'2023-04-02',299.00,21.00,'Pagada'),(8,'2023-04-20',1299.00,21.00,'Pagada'),
(9,'2023-05-10',899.00,21.00,'Pagada'),(10,'2023-05-28',449.00,21.00,'Pagada'),
(11,'2023-06-05',799.00,21.00,'Pagada'),(12,'2023-06-22',1199.00,21.00,'Pagada'),
(13,'2023-07-08',149.00,21.00,'Pagada'),(14,'2023-07-25',1349.00,21.00,'Pagada'),
(15,'2023-08-12',119.00,21.00,'Pagada'),(16,'2023-08-30',99.00,21.00,'Pagada'),
(17,'2023-09-14',1299.00,21.00,'Pagada'),(18,'2023-09-28',949.00,21.00,'Pagada'),
(19,'2023-10-05',749.00,21.00,'Pagada'),(20,'2023-10-19',279.00,21.00,'Pagada'),
(21,'2023-11-03',1099.00,21.00,'Pagada'),(22,'2023-11-20',449.00,21.00,'Pagada'),
(23,'2023-12-01',1449.00,21.00,'Pagada'),(24,'2023-12-15',899.00,21.00,'Pagada'),
(25,'2024-01-10',299.00,21.00,'Pagada');

-- ---- PAGOS ----
INSERT INTO oltp_finanzas.pagos (factura_id, fecha_pago, importe, metodo_pago) VALUES
(1,'2023-01-15',1099.00,'Tarjeta'),(2,'2023-01-22',949.00,'Tarjeta'),
(3,'2023-02-05',1728.00,'Tarjeta'),(4,'2023-02-14',279.00,'Efectivo'),
(5,'2023-03-01',1449.00,'Tarjeta'),(6,'2023-03-18',749.00,'Bizum'),
(7,'2023-04-02',299.00,'Tarjeta'),(8,'2023-04-20',1299.00,'Transferencia'),
(9,'2023-05-10',899.00,'Tarjeta'),(10,'2023-05-28',449.00,'Efectivo'),
(11,'2023-06-05',799.00,'Tarjeta'),(12,'2023-06-22',1199.00,'Tarjeta'),
(13,'2023-07-08',149.00,'Bizum'),(14,'2023-07-25',1349.00,'Tarjeta'),
(15,'2023-08-12',119.00,'Efectivo'),(16,'2023-08-30',99.00,'Tarjeta'),
(17,'2023-09-14',1299.00,'Transferencia'),(18,'2023-09-28',949.00,'Tarjeta'),
(19,'2023-10-05',749.00,'Bizum'),(20,'2023-10-19',279.00,'Tarjeta'),
(21,'2023-11-03',1099.00,'Tarjeta'),(22,'2023-11-20',449.00,'Efectivo'),
(23,'2023-12-01',1449.00,'Tarjeta'),(24,'2023-12-15',899.00,'Transferencia'),
(25,'2024-01-10',299.00,'Tarjeta');

-- ---- GASTOS ----
INSERT INTO oltp_finanzas.gastos (sucursal_id, concepto, importe, fecha, categoria) VALUES
(1,'Alquiler enero 2023',2500.00,'2023-01-01','Alquiler'),
(1,'Suministros enero 2023',350.00,'2023-01-05','Suministros'),
(2,'Alquiler enero 2023',2200.00,'2023-01-01','Alquiler'),
(2,'Suministros enero 2023',280.00,'2023-01-05','Suministros'),
(3,'Alquiler enero 2023',1900.00,'2023-01-01','Alquiler'),
(3,'Suministros enero 2023',240.00,'2023-01-05','Suministros'),
(4,'Alquiler febrero 2023',1700.00,'2023-02-01','Alquiler'),
(4,'Suministros febrero 2023',210.00,'2023-02-05','Suministros'),
(5,'Alquiler febrero 2023',1600.00,'2023-02-01','Alquiler'),
(5,'Suministros febrero 2023',195.00,'2023-02-05','Suministros'),
(6,'Alquiler febrero 2023',1500.00,'2023-02-01','Alquiler'),
(6,'Suministros febrero 2023',180.00,'2023-02-05','Suministros');

-- ---- PRESUPUESTOS ----
INSERT INTO oltp_finanzas.presupuestos (sucursal_id, anio, trimestre, importe_objetivo, importe_real) VALUES
(1,2023,1,50000.00,48500.00),(1,2023,2,52000.00,54200.00),
(1,2023,3,55000.00,53100.00),(1,2023,4,60000.00,62300.00),
(2,2023,1,45000.00,43200.00),(2,2023,2,47000.00,48900.00),
(2,2023,3,50000.00,49100.00),(2,2023,4,55000.00,57800.00),
(3,2023,1,40000.00,38700.00),(3,2023,2,42000.00,43500.00),
(3,2023,3,44000.00,42800.00),(3,2023,4,48000.00,50100.00);

-- ---- ASIGNACION TURNOS ----
INSERT INTO oltp_rrhh.asignacion_turnos (empleado_id, turno_id, fecha, sucursal_id) VALUES
(1,1,'2024-01-08',1),(2,2,'2024-01-08',1),(3,3,'2024-01-08',1),
(4,1,'2024-01-08',2),(5,2,'2024-01-08',2),(6,3,'2024-01-08',2),
(7,1,'2024-01-08',3),(8,2,'2024-01-08',3),(9,3,'2024-01-08',3),
(10,1,'2024-01-08',4),(11,2,'2024-01-08',4),(12,3,'2024-01-08',4),
(13,1,'2024-01-08',5),(14,2,'2024-01-08',5),(15,3,'2024-01-08',5),
(16,1,'2024-01-08',6),(17,2,'2024-01-08',6),(18,3,'2024-01-08',6);

-- ---- AUSENCIAS ----
INSERT INTO oltp_rrhh.ausencias (empleado_id, fecha_inicio, fecha_fin, motivo, justificada) VALUES
(1,'2023-03-15','2023-03-17','Enfermedad',true),
(3,'2023-05-22','2023-05-26','Vacaciones',true),
(5,'2023-07-10','2023-07-21','Vacaciones',true),
(7,'2023-09-04','2023-09-05','Enfermedad',true),
(9,'2023-11-13','2023-11-13','Asunto personal',false),
(11,'2024-01-29','2024-02-02','Vacaciones',true),
(13,'2024-03-18','2024-03-19','Enfermedad',true),
(15,'2024-06-24','2024-07-05','Vacaciones',true);

-- ============================================================
-- PASO 4: CREACIÓN DEL DATA WAREHOUSE (OLAP)
-- ============================================================

CREATE SCHEMA olap;

CREATE TABLE olap.dim_tiempo (
    tiempo_sk SERIAL PRIMARY KEY,
    fecha DATE NOT NULL,
    dia INT, mes INT, trimestre INT, anio INT,
    dia_semana VARCHAR(20),
    es_festivo BOOLEAN DEFAULT FALSE
);

CREATE TABLE olap.dim_cliente (
    cliente_sk SERIAL PRIMARY KEY,
    cliente_id INT NOT NULL,
    nombre VARCHAR(100), ciudad VARCHAR(50), provincia VARCHAR(50),
    segmento VARCHAR(20),
    fecha_inicio DATE DEFAULT CURRENT_DATE,
    fecha_fin DATE DEFAULT '9999-12-31',
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE olap.dim_producto (
    producto_sk SERIAL PRIMARY KEY,
    producto_id INT NOT NULL,
    nombre VARCHAR(100), categoria VARCHAR(100),
    marca VARCHAR(50), modelo VARCHAR(50),
    precio_venta NUMERIC(10,2), coste_unitario NUMERIC(10,2)
);

CREATE TABLE olap.dim_empleado (
    empleado_sk SERIAL PRIMARY KEY,
    empleado_id INT NOT NULL,
    nombre VARCHAR(100), apellidos VARCHAR(100),
    puesto VARCHAR(50), sucursal VARCHAR(100), ciudad VARCHAR(50)
);

CREATE TABLE olap.dim_sucursal (
    sucursal_sk SERIAL PRIMARY KEY,
    sucursal_id INT NOT NULL,
    nombre VARCHAR(100), ciudad VARCHAR(50),
    provincia VARCHAR(50), metros_cuadrados INT
);

CREATE TABLE olap.dim_transportista (
    transportista_sk SERIAL PRIMARY KEY,
    transportista_id INT NOT NULL,
    nombre VARCHAR(100), region_cobertura VARCHAR(100),
    coste_medio_envio NUMERIC(10,2)
);

CREATE TABLE olap.dim_proveedor (
    proveedor_sk SERIAL PRIMARY KEY,
    proveedor_id INT NOT NULL,
    nombre VARCHAR(100), ciudad VARCHAR(50),
    pais VARCHAR(50), plazo_entrega_dias INT
);

-- ============================================================
-- PASO 5: ETL — CARGA DE DIMENSIONES
-- ============================================================

INSERT INTO olap.dim_tiempo (fecha, dia, mes, trimestre, anio, dia_semana, es_festivo)
SELECT DISTINCT fecha_venta,
    EXTRACT(DAY FROM fecha_venta), EXTRACT(MONTH FROM fecha_venta),
    EXTRACT(QUARTER FROM fecha_venta), EXTRACT(YEAR FROM fecha_venta),
    TO_CHAR(fecha_venta, 'Day'), FALSE
FROM oltp_ventas.ventas ORDER BY fecha_venta;

INSERT INTO olap.dim_cliente (cliente_id, nombre, ciudad, provincia, segmento)
SELECT cliente_id, nombre, ciudad, provincia, segmento FROM oltp_ventas.clientes;

INSERT INTO olap.dim_producto (producto_id, nombre, categoria, marca, modelo, precio_venta, coste_unitario)
SELECT p.producto_id, p.nombre, c.nombre, p.marca, p.modelo, p.precio_venta, cp.coste_unitario
FROM oltp_ventas.productos p
JOIN oltp_ventas.categorias c ON p.categoria_id = c.categoria_id
JOIN oltp_inventario.costes_producto cp ON p.producto_id = cp.producto_id;

INSERT INTO olap.dim_empleado (empleado_id, nombre, apellidos, puesto, sucursal, ciudad)
SELECT e.empleado_id, e.nombre, e.apellidos, e.puesto, s.nombre, s.ciudad
FROM oltp_rrhh.empleados e
JOIN oltp_logistica.sucursales s ON e.sucursal_id = s.sucursal_id;

INSERT INTO olap.dim_sucursal (sucursal_id, nombre, ciudad, provincia, metros_cuadrados)
SELECT sucursal_id, nombre, ciudad, provincia, metros_cuadrados FROM oltp_logistica.sucursales;

INSERT INTO olap.dim_transportista (transportista_id, nombre, region_cobertura, coste_medio_envio)
SELECT transportista_id, nombre, region_cobertura, coste_medio_envio FROM oltp_logistica.transportistas;

INSERT INTO olap.dim_proveedor (proveedor_id, nombre, ciudad, pais, plazo_entrega_dias)
SELECT proveedor_id, nombre, ciudad, pais, plazo_entrega_dias FROM oltp_inventario.proveedores;

-- ============================================================
-- PASO 6: TABLA DE HECHOS Y ETL
-- ============================================================

CREATE TABLE olap.fact_ventas (
    venta_sk SERIAL PRIMARY KEY,
    tiempo_sk INT REFERENCES olap.dim_tiempo(tiempo_sk),
    cliente_sk INT REFERENCES olap.dim_cliente(cliente_sk),
    producto_sk INT REFERENCES olap.dim_producto(producto_sk),
    empleado_sk INT REFERENCES olap.dim_empleado(empleado_sk),
    sucursal_sk INT REFERENCES olap.dim_sucursal(sucursal_sk),
    cantidad INT, precio_unitario NUMERIC(10,2), descuento NUMERIC(5,2),
    ingresos NUMERIC(12,2), coste NUMERIC(12,2), margen NUMERIC(12,2)
);

INSERT INTO olap.fact_ventas (
    tiempo_sk, cliente_sk, producto_sk, empleado_sk, sucursal_sk,
    cantidad, precio_unitario, descuento, ingresos, coste, margen)
SELECT
    dt.tiempo_sk, dc.cliente_sk, dp.producto_sk, de.empleado_sk, ds.sucursal_sk,
    dv.cantidad, dv.precio_unitario, dv.descuento,
    dv.cantidad * dv.precio_unitario * (1 - dv.descuento / 100),
    dv.cantidad * dp.coste_unitario,
    (dv.cantidad * dv.precio_unitario * (1 - dv.descuento / 100)) - (dv.cantidad * dp.coste_unitario)
FROM oltp_ventas.detalle_venta dv
JOIN oltp_ventas.ventas v ON dv.venta_id = v.venta_id
JOIN oltp_logistica.envios e ON v.venta_id = e.venta_id
JOIN olap.dim_tiempo dt ON dt.fecha = v.fecha_venta
JOIN olap.dim_cliente dc ON dc.cliente_id = v.cliente_id
JOIN olap.dim_producto dp ON dp.producto_id = dv.producto_id
JOIN olap.dim_empleado de ON de.empleado_id = (
    SELECT empleado_id FROM oltp_rrhh.empleados
    WHERE sucursal_id = e.sucursal_id LIMIT 1)
JOIN olap.dim_sucursal ds ON ds.sucursal_id = e.sucursal_id;

-- ============================================================
-- PASO 7: MODELO COPO DE NIEVE
-- ============================================================

CREATE TABLE olap.dim_categoria (
    categoria_sk SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL, descripcion TEXT
);

CREATE TABLE olap.dim_producto_snow (
    producto_sk SERIAL PRIMARY KEY,
    producto_id INT NOT NULL, nombre VARCHAR(100),
    categoria_sk INT REFERENCES olap.dim_categoria(categoria_sk),
    marca VARCHAR(50), modelo VARCHAR(50),
    precio_venta NUMERIC(10,2), coste_unitario NUMERIC(10,2)
);

CREATE TABLE olap.fact_ventas_snow (
    venta_sk SERIAL PRIMARY KEY,
    tiempo_sk INT REFERENCES olap.dim_tiempo(tiempo_sk),
    cliente_sk INT REFERENCES olap.dim_cliente(cliente_sk),
    producto_sk INT REFERENCES olap.dim_producto_snow(producto_sk),
    empleado_sk INT REFERENCES olap.dim_empleado(empleado_sk),
    sucursal_sk INT REFERENCES olap.dim_sucursal(sucursal_sk),
    cantidad INT, precio_unitario NUMERIC(10,2), descuento NUMERIC(5,2),
    ingresos NUMERIC(12,2), coste NUMERIC(12,2), margen NUMERIC(12,2)
);

INSERT INTO olap.dim_categoria (nombre, descripcion)
SELECT DISTINCT nombre, descripcion FROM oltp_ventas.categorias ORDER BY nombre;

INSERT INTO olap.dim_producto_snow (producto_id, nombre, categoria_sk, marca, modelo, precio_venta, coste_unitario)
SELECT p.producto_id, p.nombre, dc.categoria_sk, p.marca, p.modelo, p.precio_venta, cp.coste_unitario
FROM oltp_ventas.productos p
JOIN oltp_ventas.categorias c ON p.categoria_id = c.categoria_id
JOIN olap.dim_categoria dc ON dc.nombre = c.nombre
JOIN oltp_inventario.costes_producto cp ON p.producto_id = cp.producto_id;

INSERT INTO olap.fact_ventas_snow (
    tiempo_sk, cliente_sk, producto_sk, empleado_sk, sucursal_sk,
    cantidad, precio_unitario, descuento, ingresos, coste, margen)
SELECT
    dt.tiempo_sk, dc.cliente_sk, dp.producto_sk, de.empleado_sk, ds.sucursal_sk,
    dv.cantidad, dv.precio_unitario, dv.descuento,
    dv.cantidad * dv.precio_unitario * (1 - dv.descuento / 100),
    dv.cantidad * dp.coste_unitario,
    (dv.cantidad * dv.precio_unitario * (1 - dv.descuento / 100)) - (dv.cantidad * dp.coste_unitario)
FROM oltp_ventas.detalle_venta dv
JOIN oltp_ventas.ventas v ON dv.venta_id = v.venta_id
JOIN oltp_logistica.envios e ON v.venta_id = e.venta_id
JOIN olap.dim_tiempo dt ON dt.fecha = v.fecha_venta
JOIN olap.dim_cliente dc ON dc.cliente_id = v.cliente_id
JOIN olap.dim_producto_snow dp ON dp.producto_id = dv.producto_id
JOIN olap.dim_empleado de ON de.empleado_id = (
    SELECT empleado_id FROM oltp_rrhh.empleados
    WHERE sucursal_id = e.sucursal_id LIMIT 1)
JOIN olap.dim_sucursal ds ON ds.sucursal_id = e.sucursal_id;

-- ============================================================
-- FIN DEL SCRIPT
-- ============================================================