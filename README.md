# Práctica 1 — Sistemas Multidimensionales
**Universidad de Granada — Facultad de Educación, Economía y Tecnología de Ceuta**

**Asignatura:** Sistemas Multidimensionales  
**Alumna:** Sara Rezini Ahmed  
**Profesor:** José Ángel Díaz García  

---

## Descripción

Este repositorio contiene el desarrollo completo de la Práctica 1 de Sistemas 
Multidimensionales, que consiste en el diseño e implementación de un Data Warehouse 
para la empresa ficticia **TechZone S.L.**, una cadena de tiendas de tecnología 
española con 6 sucursales en Andalucía y Ceuta.

El proyecto recorre el ciclo completo de un sistema de inteligencia de negocio:
desde los sistemas transaccionales (OLTP) hasta el modelo dimensional (OLAP),
incluyendo el proceso ETL y la evaluación de rendimiento mediante benchmarking.

---
---

## Tecnologías utilizadas

- **PostgreSQL 16** — Motor de base de datos
- **pgAdmin 4** — Cliente SQL
- **Python 3** — Script de benchmarking
- **psycopg2** — Librería Python para conectar con PostgreSQL
- **draw.io** — Diagramas ER y OLAP

---

## Caso de estudio: TechZone S.L.

TechZone S.L. es una cadena de tiendas de tecnología española con 6 sucursales 
en Sevilla, Málaga, Granada, Córdoba, Almería y Ceuta. El sistema gestiona:

- Venta de smartphones, portátiles, tablets, accesorios y smartwatches
- 18 empleados distribuidos por sucursal
- 20 productos de 6 categorías tecnológicas
- 9 proveedores tecnológicos
- 5 empresas de transporte

---

## Arquitectura del sistema

### Sistemas OLTP (5 esquemas)
| Esquema | Departamento | Tablas |
|---|---|---|
| oltp_ventas | Ventas | clientes, productos, categorias, ventas, detalle_venta |
| oltp_inventario | Inventario | proveedores, almacenes, stock, costes_producto |
| oltp_logistica | Logística | sucursales, transportistas, envios, incidencias |
| oltp_rrhh | RRHH | empleados, turnos, asignacion_turnos, ausencias |
| oltp_finanzas | Finanzas | facturas, pagos, gastos, presupuestos |

### Data Warehouse (esquema olap)
| Tabla | Tipo | Descripción |
|---|---|---|
| dim_tiempo | Dimensión | Análisis temporal por día, mes, trimestre, año |
| dim_producto | Dimensión | Catálogo con categoría, precio y coste |
| dim_cliente | Dimensión | Clientes con SCD Tipo 2 |
| dim_empleado | Dimensión | Personal por sucursal y puesto |
| dim_sucursal | Dimensión | Tiendas físicas por ciudad y región |
| dim_proveedor | Dimensión | Proveedores tecnológicos |
| dim_transportista | Dimensión | Empresas de transporte |
| fact_ventas | Hecho | Métricas: cantidad, ingresos, coste, margen |

---
