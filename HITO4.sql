-- CONSULTA 1 STAR: Ingresos por categoría y trimestre
SELECT
    t.anio,
    t.trimestre,
    p.categoria,
    SUM(f.ingresos) AS total_ingresos
FROM olap.fact_ventas f
JOIN olap.dim_tiempo t ON f.tiempo_sk = t.tiempo_sk
JOIN olap.dim_producto p ON f.producto_sk = p.producto_sk
GROUP BY t.anio, t.trimestre, p.categoria
ORDER BY t.anio, t.trimestre, p.categoria;

-- CONSULTA 1 SNOW: misma pregunta con copo de nieve
SELECT
    t.anio,
    t.trimestre,
    c.nombre AS categoria,
    SUM(f.ingresos) AS total_ingresos
FROM olap.fact_ventas_snow f
JOIN olap.dim_tiempo t ON f.tiempo_sk = t.tiempo_sk
JOIN olap.dim_producto_snow p ON f.producto_sk = p.producto_sk
JOIN olap.dim_categoria c ON p.categoria_sk = c.categoria_sk
GROUP BY t.anio, t.trimestre, c.nombre
ORDER BY t.anio, t.trimestre, c.nombre;

-- CONSULTA 1 OLTP: misma pregunta desde sistema transaccional
SELECT
    EXTRACT(YEAR FROM v.fecha_venta) AS anio,
    EXTRACT(QUARTER FROM v.fecha_venta) AS trimestre,
    c.nombre AS categoria,
    SUM(dv.cantidad * dv.precio_unitario) AS total_ingresos
FROM oltp_ventas.ventas v
JOIN oltp_ventas.detalle_venta dv ON v.venta_id = dv.venta_id
JOIN oltp_ventas.productos p ON dv.producto_id = p.producto_id
JOIN oltp_ventas.categorias c ON p.categoria_id = c.categoria_id
GROUP BY anio, trimestre, c.nombre
ORDER BY anio, trimestre, c.nombre;

-- CONSULTA 2: Roll Up (de trimestre a año)
SELECT
    t.anio,
    SUM(f.ingresos) AS total_ingresos
FROM olap.fact_ventas f
JOIN olap.dim_tiempo t ON f.tiempo_sk = t.tiempo_sk
GROUP BY t.anio
ORDER BY t.anio;

-- CONSULTA 3: Drill Down (de año a mes)
SELECT
    t.anio,
    t.mes,
    SUM(f.ingresos) AS total_ingresos
FROM olap.fact_ventas f
JOIN olap.dim_tiempo t ON f.tiempo_sk = t.tiempo_sk
GROUP BY t.anio, t.mes
ORDER BY t.anio, t.mes;

-- CONSULTA 4: Top productos mas rentables
SELECT
    p.nombre AS producto,
    p.categoria,
    SUM(f.cantidad) AS unidades_vendidas,
    SUM(f.ingresos) AS total_ingresos,
    SUM(f.margen) AS total_margen,
    ROUND(SUM(f.margen) / SUM(f.ingresos) * 100, 2) AS porcentaje_margen
FROM olap.fact_ventas f
JOIN olap.dim_producto p ON f.producto_sk = p.producto_sk
GROUP BY p.nombre, p.categoria
ORDER BY total_margen DESC
LIMIT 5;

-- CONSULTA 5: Rendimiento por sucursal y empleado
SELECT
    s.nombre AS sucursal,
    e.nombre || ' ' || e.apellidos AS empleado,
    COUNT(f.venta_sk) AS num_ventas,
    SUM(f.ingresos) AS total_ingresos,
    SUM(f.margen) AS total_margen
FROM olap.fact_ventas f
JOIN olap.dim_sucursal s ON f.sucursal_sk = s.sucursal_sk
JOIN olap.dim_empleado e ON f.empleado_sk = e.empleado_sk
GROUP BY s.nombre, e.nombre, e.apellidos
ORDER BY total_ingresos DESC;