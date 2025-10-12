USE proyecto_final;

CREATE VIEW vista_precios_comuna AS
SELECT 
    c.nombre_comuna,
    COUNT(DISTINCT d.id_departamento) as total_departamentos,
    ROUND(AVG(v.precio_venta), 2) as promedio_venta,
    ROUND(AVG(a.precio_alquiler), 2) as promedio_alquiler,
    ROUND(AVG(d.superficie), 2) as promedio_superficie
FROM Comuna c
LEFT JOIN Departamentos d ON c.id_comuna = d.id_comuna
LEFT JOIN Venta v ON v.id_departamento = d.id_departamento
LEFT JOIN Alquiler a ON a.id_departamento = d.id_departamento
GROUP BY c.id_comuna, c.nombre_comuna;

SELECT * FROM vista_precios_comuna;

CREATE VIEW vista_rentabilidad as
SELECT
	d.id_departamento,
    d.barrio,
    d.ambientes,
    d.estado,
	ROUND(AVG(a.precio_alquiler), 2) alquiler_promedio,
	ROUND(AVG(v.precio_venta), 2) venta_promedio,
	ROUND((AVG(a.precio_alquiler) * 12 / AVG(v.precio_venta)) * 100, 2) as rentabilidad_anual_porcentaje
FROM Departamentos d
LEFT JOIN Alquiler a ON d.id_departamento = a.id_departamento
LEFT JOIN Venta v ON d.id_departamento = v.id_departamento
GROUP BY d.id_departamento, d.barrio, d.ambientes, d.estado
HAVING venta_promedio > 0;

SELECT * FROM vista_rentabilidad;

-- Funciones:

-- 1. Calcular precio por m2 de un departamento especifico.

DELIMITER //

CREATE FUNCTION calcular_precio_m2(depto_id INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE precio DECIMAL(12,2);
    DECLARE superficie DECIMAL(10,2);
    DECLARE precio_m2 DECIMAL(10,2);
    
    -- Obtener el último precio de venta
    SELECT v.precio_venta INTO precio
    FROM Venta v
    WHERE v.id_departamento = depto_id
    ORDER BY v.año_mes DESC
    LIMIT 1;
    
    -- Obtener superficie
    SELECT d.superficie INTO superficie
    FROM Departamentos d
    WHERE d.id_departamento = depto_id;
    
    -- Calcular precio por m²
    IF superficie > 0 AND precio IS NOT NULL THEN
        SET precio_m2 = precio / superficie;
    ELSE
        SET precio_m2 = 0;
    END IF;
    
    RETURN precio_m2;
END //

DELIMITER ;

SELECT id_departamento, barrio, calcular_precio_m2(id_departamento) as precio_m2
FROM Departamentos
LIMIT 10;

-- 2. Calcular categoria de precio de un departamento:

DELIMITER //

DROP FUNCTION IF EXISTS categorizar_precio;

CREATE FUNCTION categorizar_precio(precio DECIMAL(12,2))
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
    DECLARE categoria VARCHAR(20);
    
    -- Rangos ajustados para precios en miles
    IF precio < 1500 THEN
        SET categoria = 'Económico';
    ELSEIF precio >= 1500 AND precio < 2500 THEN
        SET categoria = 'Medio';
    ELSEIF precio >= 2500 AND precio < 5000 THEN
        SET categoria = 'Alto';
    ELSE
        SET categoria = 'Premium';
    END IF;
    
    RETURN categoria;
END //

DELIMITER ;

-- Uso:

SELECT 
    d.barrio,
    v.precio_venta,
    categorizar_precio(v.precio_venta) as categoria
FROM Departamentos d
JOIN Venta v ON d.id_departamento = v.id_departamento
LIMIT 20;

-- Stored Procedures.
-- 1. Registrar una nueva venta completa:

DELIMITER //

CREATE PROCEDURE registrar_venta(
    IN p_id_departamento INT,
    IN p_precio DECIMAL(12,2),
    IN p_fecha DATE
)
BEGIN
    -- Validar que el departamento existe
    IF EXISTS(SELECT 1 FROM Departamentos WHERE id_departamento = p_id_departamento) THEN
        -- Insertar la venta
        INSERT INTO Venta (id_departamento, precio_venta, año_mes)
        VALUES (p_id_departamento, p_precio, p_fecha);
        
        SELECT 'Venta registrada exitosamente' as mensaje;
    ELSE
        SELECT 'Error: Departamento no existe' as mensaje;
    END IF;
END //

DELIMITER ;

-- Uso

CALL registrar_venta(1, 8500000.00, '2024-01-15');

-- 2. Stored Procedure: Reporte de rendimiento de inversión

DELIMITER //

CREATE PROCEDURE reporte_inversion(IN p_id_departamento INT)
BEGIN
    -- Seleccionar información del departamento
    SELECT 
        d.barrio,
        d.ambientes,
        d.superficie,
        d.estado,
        AVG(v.precio_venta) as precio_promedio,
        AVG(a.precio_alquiler) as alquiler_promedio,
        ROUND((AVG(a.precio_alquiler) * 12 / AVG(v.precio_venta)) * 100, 2) as rentabilidad_anual
    FROM Departamentos d
    LEFT JOIN Venta v ON d.id_departamento = v.id_departamento
    LEFT JOIN Alquiler a ON d.id_departamento = a.id_departamento
    WHERE d.id_departamento = p_id_departamento
    GROUP BY d.id_departamento;
    
    -- Mostrar histórico de precios
    SELECT año_mes, precio_venta
    FROM Venta
    WHERE id_departamento = p_id_departamento
    ORDER BY año_mes DESC;
END //

DELIMITER ;

-- Uso

CALL reporte_inversion(50);

-- 1. Trigger: Auditoria de cambios de precios

CREATE TABLE Auditoria_Precios (
    id_auditoria INT AUTO_INCREMENT PRIMARY KEY,
    id_venta INT,
    precio_anterior DECIMAL(12,2),
    precio_nuevo DECIMAL(12,2),
    fecha_cambio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuario VARCHAR(100)
);

-- Trigger

DELIMITER //

CREATE TRIGGER auditoria_cambio_precio
AFTER UPDATE ON Venta
FOR EACH ROW
BEGIN
    IF OLD.precio_venta != NEW.precio_venta THEN
        INSERT INTO Auditoria_Precios (id_venta, precio_anterior, precio_nuevo, usuario)
        VALUES (NEW.id_venta, OLD.precio_venta, NEW.precio_venta, USER());
    END IF;
END //

DELIMITER ;

-- Ejecuto por ejemplo:
UPDATE Venta SET precio_venta = 9000000 WHERE id_venta = 5;

-- El trigger automáticamente guarda en Auditoria_Precios:
-- "El precio cambió de 8500000 a 9000000"

-- 2. Trigger: Validar precios antes de insertar

DELIMITER //

CREATE TRIGGER validar_precio_venta
BEFORE INSERT ON Venta
FOR EACH ROW
BEGIN
    -- Validar que el precio no sea negativo o cero
    IF NEW.precio_venta <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: El precio de venta debe ser mayor a 0';
    END IF;
    
    -- Validar que la fecha no sea futura
    IF NEW.año_mes > CURDATE() THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: La fecha de venta no puede ser futura';
    END IF;
END //

DELIMITER ;

-- Ejemplo de uso

-- Si ejecuto esto:
INSERT INTO Venta (id_departamento, precio_venta, año_mes)
VALUES (1, -5000, '2024-01-01');

-- El trigger lo RECHAZA automáticamente con un error
