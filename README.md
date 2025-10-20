# Proyecto Final SQL – Sistema de Gestión Inmobiliaria

Este proyecto consiste en la creación de una base de datos para analizar la problemática del mercado inmobiliario en la Ciudad de Buenos Aires.

Nos propondremos a estudiar diferentes conceptos a partir de 3 items/ideas principales a seguir:

- Qué zonas y departamentos resultan más accesibles.

- La evolución de los precios de venta y alquiler en el tiempo.

- La relación entre las ventas de inmuebles y la adquisición de créditos hipotecarios.

La intención es comprender mejor por qué el acceso a la primera vivienda resulta tan costoso, 
y así aportar un panorama más claro sobre los factores a tener en cuenta al momento de independizarse.

Fuente de datos: https://data.buenosaires.gob.ar/dataset/mercado-inmobiliario

## 📁 Estructura del Repositorio

### 🟦 **Entrega 1**
Contiene la primera parte del proyecto, centrada en el diseño y creación de la base de datos.

**Archivos incluidos:**
- `Documentación - Valdez Javier.pdf` → Documento con el análisis inicial, modelo entidad-relación y descripción de tablas.  
- `codigo.txt` → Código base utilizado para la creación inicial de la estructura de la base.  
- `Script.sql` → Script SQL con la **creación completa de las tablas** (sin datos).

📌 Esta entrega refleja el diseño estructural y la definición de claves primarias y foráneas del sistema.

---

### 🟩 **Entrega 2**
Incluye la ampliación del proyecto con vistas, funciones, procedimientos almacenados, triggers e importación de datos.

**Contenido principal:**
- `Entrega2_Valdez.pdf` → Documento con el detalle de vistas, funciones, stored procedures y triggers.  
- `creacion_objetos.sql` → Script que crea todos los objetos de la base de datos (vistas, funciones, procedimientos, triggers).  
- Carpeta `datos_importacion/` con los archivos CSV numerados según el orden correcto de carga:
  1_comuna.csv
  2_departamentos.csv
  3_alquiler_final.csv
  4_ventas_final.csv
  5_prestamos_final.csv

## 🧱 Descripción general
El proyecto modela un sistema de gestión inmobiliaria que analiza:
- Precios de venta y alquiler por comuna
- Rentabilidad de propiedades
- Evolución de créditos hipotecarios

## ⚙️ Tecnologías
- MySQL Workbench 8.x
- Python (procesamiento de datos previos)
- Archivos CSV importados mediante el Asistente de Importación

## 📩 Autor
**Javier Valdez**
