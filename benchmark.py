import psycopg2
import time
import statistics

conn = psycopg2.connect(
    host="localhost",
    database="techzone_db",
    user="postgres",
    password="1234"
)
cur = conn.cursor()

# ------------------------------
# CONSULTAS
# ------------------------------

query_oltp = """
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
"""

query_star = """
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
"""

query_snow = """
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
"""

# ------------------------------
# FUNCIÓN DE MEDICIÓN
# ------------------------------

def medir(nombre, query, repeticiones=20):
    tiempos = []
    for _ in range(repeticiones):
        inicio = time.time()
        cur.execute(query)
        cur.fetchall()
        fin = time.time()
        tiempos.append((fin - inicio) * 1000)
    promedio = round(statistics.mean(tiempos), 4)
    desv = round(statistics.stdev(tiempos), 4)
    minimo = round(min(tiempos), 4)
    maximo = round(max(tiempos), 4)
    print(f"\n--- {nombre} ---")
    print(f"Promedio : {promedio} ms")
    print(f"Desv Std : {desv} ms")
    print(f"Mínimo   : {minimo} ms")
    print(f"Máximo   : {maximo} ms")
    return promedio, desv, minimo, maximo

# ------------------------------
# EJECUCIÓN
# ------------------------------

print("=" * 40)
print("BENCHMARKING TECHZONE S.L.")
print("=" * 40)

oltp = medir("OLTP", query_oltp)
star = medir("STAR Schema", query_star)
snow = medir("SNOWFLAKE Schema", query_snow)

# ------------------------------
# RESUMEN COMPARATIVO
# ------------------------------

print("\n")
print("=" * 40)
print("RESUMEN COMPARATIVO")
print("=" * 40)
print(f"{'Sistema':<20} {'Promedio(ms)':<15} {'Desv Std':<12} {'Min':<10} {'Max'}")
print("-" * 70)
print(f"{'OLTP':<20} {oltp[0]:<15} {oltp[1]:<12} {oltp[2]:<10} {oltp[3]}")
print(f"{'STAR Schema':<20} {star[0]:<15} {star[1]:<12} {star[2]:<10} {star[3]}")
print(f"{'SNOWFLAKE Schema':<20} {snow[0]:<15} {snow[1]:<12} {snow[2]:<10} {snow[3]}")

mejora_star = round((oltp[0] - star[0]) / oltp[0] * 100, 2)
mejora_snow = round((oltp[0] - snow[0]) / oltp[0] * 100, 2)
print(f"\nMejora STAR vs OLTP    : {mejora_star}%")
print(f"Mejora SNOWFLAKE vs OLTP: {mejora_snow}%")

cur.close()
conn.close()
print("\nBenchmarking completado.")