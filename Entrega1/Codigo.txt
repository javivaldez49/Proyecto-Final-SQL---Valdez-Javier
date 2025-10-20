CREATE SCHEMA Proyecto_Final;
USE Proyecto_Final;

CREATE TABLE Departamentos (
    id_departamento INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    barrio VARCHAR(100),
    id_comuna INT NOT NULL,
    ambientes INT NOT NULL,
    estado VARCHAR(100),
    superficie DECIMAL(10,2) 
);

CREATE TABLE Alquiler (
    id_alquiler INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    id_departamento INT NOT NULL,
    precio_alquiler DECIMAL(12,2),
    año_mes DATE NOT NULL
);

CREATE TABLE Venta (
    id_venta INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    id_departamento INT NOT NULL,
    precio_venta DECIMAL(12,2),
    año_mes DATE NOT NULL
);

CREATE TABLE Prestamos_Hipotecarios (
    id_prestamo INT AUTO_INCREMENT PRIMARY KEY,
    monto_operado DECIMAL(14,2) NOT NULL,
    variacion_mensual DECIMAL(7,2),
    variacion_anual DECIMAL(7,2),
    año_mes DATE NOT NULL
);

CREATE TABLE Comuna (
    id_comuna INT AUTO_INCREMENT PRIMARY KEY,
    nombre_comuna VARCHAR(100) NOT NULL
);

CREATE TABLE Superficies_Comuna (
    id_superficie INT AUTO_INCREMENT PRIMARY KEY,
    id_comuna INT NOT NULL,
    superficie_total DECIMAL(14,2) NOT NULL,
    año INT NOT NULL,
    mes INT NOT NULL,
    FOREIGN KEY (id_comuna) REFERENCES Comuna(id_comuna)
);

ALTER TABLE Venta ADD CONSTRAINT fk_venta_departamentos
    FOREIGN KEY (id_departamento) REFERENCES Departamentos(id_departamento);

ALTER TABLE Alquiler ADD CONSTRAINT fk_alquiler_departamentos    
    FOREIGN KEY (id_departamento) REFERENCES Departamentos(id_departamento);
