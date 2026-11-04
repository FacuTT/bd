/* ============================================================
   1. VARIABLES
   ============================================================ */

DECLARE @variable INT;
DECLARE @variable2 VARCHAR(100);

SET @variable = valor;

SELECT @variable = columna
FROM tabla
WHERE condicion;


/* ============================================================
   2. SELECT
   ============================================================ */

SELECT [DISTINCT] columnas
FROM tabla
[INNER | LEFT | RIGHT | FULL] JOIN otra_tabla
    ON condicion
WHERE condicion
GROUP BY columnas
HAVING condicion
ORDER BY columna [ASC | DESC];


/* SUBCONSULTA */

SELECT columnas
FROM tabla
WHERE columna operador (
    SELECT columna
    FROM otra_tabla
    WHERE condicion
);


/* EXISTS / NOT EXISTS */

SELECT columnas
FROM tabla t
WHERE [NOT] EXISTS (
    SELECT 1
    FROM otra_tabla o
    WHERE condicion
);


/* UNION */

SELECT columnas FROM tabla1
UNION [ALL]
SELECT columnas FROM tabla2;


/* ============================================================
   3. INSERT
   ============================================================ */

INSERT INTO tabla (columna1, columna2, ...)
VALUES (valor1, valor2, ...);


/* INSERT MULTIPLE */

INSERT INTO tabla (columna1, columna2, ...)
VALUES
    (valor1, valor2),
    (valor1, valor2);


/* INSERT SELECT */

INSERT INTO tabla_destino (columna1, columna2)
SELECT columna1, columna2
FROM tabla_origen
WHERE condicion;


/* INSERT OUTPUT */

INSERT INTO tabla (columnas)
OUTPUT inserted.columna
VALUES (valores);


/* IDENTITY */

SELECT SCOPE_IDENTITY();


/* ============================================================
   4. UPDATE
   ============================================================ */

UPDATE tabla
SET columna1 = valor1,
    columna2 = valor2
WHERE condicion;


/* UPDATE CON JOIN */

UPDATE t
SET t.columna = expresion
FROM tabla t
JOIN otra_tabla o
    ON condicion
WHERE condicion;


/* UPDATE CON SUBCONSULTA */

UPDATE tabla
SET columna = (
    SELECT expresion
    FROM otra_tabla
    WHERE condicion
)
WHERE condicion;


/* UPDATE OUTPUT */

UPDATE tabla
SET columna = expresion
OUTPUT deleted.columna, inserted.columna
WHERE condicion;


/* ============================================================
   5. DELETE / TRUNCATE
   ============================================================ */

DELETE FROM tabla
WHERE condicion;


/* DELETE CON JOIN */

DELETE t
FROM tabla t
JOIN otra_tabla o
    ON condicion
WHERE condicion;


/* DELETE OUTPUT */

DELETE FROM tabla
OUTPUT deleted.*
WHERE condicion;


/* TRUNCATE */

TRUNCATE TABLE tabla;


/* DROP TABLE */

DROP TABLE tabla;


/* ============================================================
   6. CREATE TABLE / ALTER TABLE
   ============================================================ */

CREATE TABLE tabla (
    columna1 tipo_dato [NULL | NOT NULL],
    columna2 tipo_dato [NULL | NOT NULL],

    CONSTRAINT nombre_pk
        PRIMARY KEY (columna1),

    CONSTRAINT nombre_fk
        FOREIGN KEY (columna2)
        REFERENCES otra_tabla(columna),

    CONSTRAINT nombre_unique
        UNIQUE (columna),

    CONSTRAINT nombre_check
        CHECK (condicion),

    CONSTRAINT nombre_default
        DEFAULT (valor) FOR columna
);


/* AGREGAR COLUMNA */

ALTER TABLE tabla
ADD columna tipo_dato;


/* MODIFICAR COLUMNA */

ALTER TABLE tabla
ALTER COLUMN columna tipo_dato;


/* ELIMINAR COLUMNA */

ALTER TABLE tabla
DROP COLUMN columna;


/* AGREGAR RESTRICCION */

ALTER TABLE tabla
ADD CONSTRAINT nombre_restriccion
CHECK (condicion);


/* ELIMINAR RESTRICCION */

ALTER TABLE tabla
DROP CONSTRAINT nombre_restriccion;


/* ============================================================
   7. FUNCTION ESCALAR
   ============================================================ */

CREATE FUNCTION esquema.nombre_funcion (
    @parametro1 tipo_dato,
    @parametro2 tipo_dato
)
RETURNS tipo_dato
AS
BEGIN

    DECLARE @resultado tipo_dato;

    -- LOGICA

    RETURN @resultado;

END;


/* INVOCAR */

SELECT esquema.nombre_funcion(argumentos);


/* MODIFICAR */

ALTER FUNCTION esquema.nombre_funcion (
    @parametro tipo_dato
)
RETURNS tipo_dato
AS
BEGIN

    -- LOGICA

    RETURN valor;

END;


/* ELIMINAR */

DROP FUNCTION esquema.nombre_funcion;


/* ============================================================
   8. FUNCTION QUE DEVUELVE TABLA (INLINE)
   ============================================================ */

CREATE FUNCTION esquema.nombre_funcion (
    @parametro tipo_dato
)
RETURNS TABLE
AS
RETURN
(
    SELECT columnas
    FROM tabla
    WHERE condicion
);


/* INVOCAR */

SELECT *
FROM esquema.nombre_funcion(argumento);


/* ============================================================
   9. FUNCTION CON TABLA DE RETORNO VARIABLE
   ============================================================ */

CREATE FUNCTION esquema.nombre_funcion (
    @parametro tipo_dato
)
RETURNS @resultado TABLE (
    columna1 tipo_dato,
    columna2 tipo_dato
)
AS
BEGIN

    INSERT INTO @resultado (columna1, columna2)
    SELECT columna1, columna2
    FROM tabla
    WHERE condicion;

    RETURN;

END;


/* ============================================================
   10. STORED PROCEDURE
   ============================================================ */

CREATE PROCEDURE esquema.nombre_procedure
AS
BEGIN

    -- INSTRUCCIONES

END;


/* PROCEDURE CON PARAMETROS */

CREATE PROCEDURE esquema.nombre_procedure
    @parametro1 tipo_dato,
    @parametro2 tipo_dato
AS
BEGIN

    -- INSTRUCCIONES

END;


/* PROCEDURE CON OUTPUT */

CREATE PROCEDURE esquema.nombre_procedure
    @parametro tipo_dato,
    @salida tipo_dato OUTPUT
AS
BEGIN

    SET @salida = valor;

END;


/* EJECUTAR PROCEDURE */

EXEC esquema.nombre_procedure
    @parametro1 = valor,
    @parametro2 = valor;


/* EJECUTAR CON OUTPUT */

DECLARE @resultado tipo_dato;

EXEC esquema.nombre_procedure
    @parametro = valor,
    @salida = @resultado OUTPUT;


/* MODIFICAR PROCEDURE */

ALTER PROCEDURE esquema.nombre_procedure
    @parametro tipo_dato
AS
BEGIN

    -- INSTRUCCIONES

END;


/* ELIMINAR PROCEDURE */

DROP PROCEDURE esquema.nombre_procedure;


/* ============================================================
   11. TRIGGER AFTER
   ============================================================ */

CREATE TRIGGER nombre_trigger
ON tabla
AFTER INSERT, UPDATE, DELETE
AS
BEGIN

    SET NOCOUNT ON;

    -- inserted: registros nuevos
    -- deleted: registros anteriores

END;


/* ============================================================
   12. TRIGGER INSTEAD OF
   ============================================================ */

CREATE TRIGGER nombre_trigger
ON tabla
INSTEAD OF INSERT, UPDATE, DELETE
AS
BEGIN

    SET NOCOUNT ON;

    -- LOGICA

END;


/* ============================================================
   13. TRIGGER CON VALIDACION
   ============================================================ */

CREATE TRIGGER nombre_trigger
ON tabla
AFTER INSERT, UPDATE
AS
BEGIN

    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted
        WHERE condicion
    )
    BEGIN

        THROW numero_error, 'mensaje', estado;

    END;

END;


/* HABILITAR / DESHABILITAR */

ENABLE TRIGGER nombre_trigger ON tabla;

DISABLE TRIGGER nombre_trigger ON tabla;


/* ELIMINAR */

DROP TRIGGER nombre_trigger;


/* ============================================================
   14. TRANSACCIONES
   ============================================================ */

BEGIN TRANSACTION;

-- OPERACIONES

COMMIT TRANSACTION;


/* DESHACER */

ROLLBACK TRANSACTION;


/* TRY / CATCH CON TRANSACCION */

BEGIN TRY

    BEGIN TRANSACTION;

    -- OPERACIONES

    COMMIT TRANSACTION;

END TRY

BEGIN CATCH

    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;

    THROW;

END CATCH;


/* SAVEPOINT */

SAVE TRANSACTION nombre_savepoint;


/* ROLLBACK A SAVEPOINT */

ROLLBACK TRANSACTION nombre_savepoint;


/* ============================================================
   15. NIVELES DE AISLAMIENTO
   ============================================================ */

/* READ UNCOMMITTED */

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;


/* READ COMMITTED */

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;


/* REPEATABLE READ */

SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;


/* SERIALIZABLE */

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;


/* SNAPSHOT */

SET TRANSACTION ISOLATION LEVEL SNAPSHOT;


/* ESTRUCTURA DE USO */

SET TRANSACTION ISOLATION LEVEL nivel;

BEGIN TRANSACTION;

-- OPERACIONES

COMMIT TRANSACTION;


/* HABILITAR SNAPSHOT */

ALTER DATABASE nombre_base
SET ALLOW_SNAPSHOT_ISOLATION ON;


/* HABILITAR READ COMMITTED SNAPSHOT */

ALTER DATABASE nombre_base
SET READ_COMMITTED_SNAPSHOT ON;


/* ============================================================
   16. CURSORES
   ============================================================ */

/* DECLARACION */

DECLARE nombre_cursor CURSOR
[LOCAL | GLOBAL]
[FORWARD_ONLY | SCROLL]
[STATIC | KEYSET | DYNAMIC | FAST_FORWARD]
[READ_ONLY | SCROLL_LOCKS | OPTIMISTIC]
FOR
    SELECT columnas
    FROM tabla
    WHERE condicion;


/* ABRIR */

OPEN nombre_cursor;


/* PRIMER FETCH */

FETCH NEXT FROM nombre_cursor
INTO @variable1, @variable2;


/* RECORRIDO */

WHILE @@FETCH_STATUS = 0
BEGIN

    -- OPERACIONES

    FETCH NEXT FROM nombre_cursor
    INTO @variable1, @variable2;

END;


/* CERRAR Y LIBERAR */

CLOSE nombre_cursor;

DEALLOCATE nombre_cursor;


/* FETCH CON SCROLL */

FETCH FIRST FROM nombre_cursor INTO @variable;

FETCH LAST FROM nombre_cursor INTO @variable;

FETCH PRIOR FROM nombre_cursor INTO @variable;

FETCH NEXT FROM nombre_cursor INTO @variable;

FETCH ABSOLUTE numero FROM nombre_cursor INTO @variable;

FETCH RELATIVE numero FROM nombre_cursor INTO @variable;


/* ============================================================
   17. ESTRUCTURAS DE CONTROL
   ============================================================ */

/* IF / ELSE */

IF condicion
BEGIN

    -- INSTRUCCIONES

END
ELSE
BEGIN

    -- INSTRUCCIONES

END;


/* WHILE */

WHILE condicion
BEGIN

    -- INSTRUCCIONES

END;


/* BREAK / CONTINUE */

BREAK;

CONTINUE;


/* RETURN */

RETURN;

RETURN valor;


/* ============================================================
   18. CASE / IIF
   ============================================================ */

CASE
    WHEN condicion THEN resultado
    WHEN condicion THEN resultado
    ELSE resultado
END;


IIF(condicion, valor_verdadero, valor_falso);


/* ============================================================
   19. FUNCIONES DE AGREGACION
   ============================================================ */

COUNT(*);

SUM(columna);

AVG(columna);

MIN(columna);

MAX(columna);


/* ============================================================
   20. FUNCIONES PARA NULL
   ============================================================ */

ISNULL(expresion, reemplazo);

COALESCE(expresion1, expresion2, ...);

NULLIF(expresion1, expresion2);


/* ============================================================
   21. CONVERSION DE TIPOS
   ============================================================ */

CAST(expresion AS tipo_dato);

CONVERT(tipo_dato, expresion [, estilo]);

TRY_CAST(expresion AS tipo_dato);

TRY_CONVERT(tipo_dato, expresion [, estilo]);


/* ============================================================
   22. FUNCIONES DE FECHA
   ============================================================ */

GETDATE();

SYSDATETIME();

YEAR(fecha);

MONTH(fecha);

DAY(fecha);

DATEADD(parte_fecha, cantidad, fecha);

DATEDIFF(parte_fecha, fecha_inicio, fecha_fin);

EOMONTH(fecha);


/* ============================================================
   23. FUNCIONES DE TEXTO
   ============================================================ */

LEN(cadena);

LEFT(cadena, cantidad);

RIGHT(cadena, cantidad);

SUBSTRING(cadena, inicio, cantidad);

CHARINDEX(busqueda, cadena);

REPLACE(cadena, buscar, reemplazar);

UPPER(cadena);

LOWER(cadena);

LTRIM(cadena);

RTRIM(cadena);

TRIM(cadena);

CONCAT(valor1, valor2, ...);


/* ============================================================
   24. FUNCIONES NUMERICAS
   ============================================================ */

ABS(numero);

ROUND(numero, decimales);

CEILING(numero);

FLOOR(numero);


/* ============================================================
   25. VARIABLES Y FUNCIONES DEL SISTEMA
   ============================================================ */

@@ROWCOUNT;

@@FETCH_STATUS;

@@TRANCOUNT;

XACT_STATE();

SCOPE_IDENTITY();

@@IDENTITY;

IDENT_CURRENT('nombre_tabla');

ERROR_NUMBER();

ERROR_MESSAGE();

ERROR_SEVERITY();

ERROR_STATE();

ERROR_LINE();

ERROR_PROCEDURE();


/* ============================================================
   26. MANEJO DE ERRORES
   ============================================================ */

/* THROW */

THROW numero_error, 'mensaje', estado;


/* RAISERROR */

RAISERROR ('mensaje', severidad, estado);


/* ============================================================
   27. VISTAS
   ============================================================ */

/* CREAR */

CREATE VIEW esquema.nombre_vista
AS
SELECT columnas
FROM tabla
WHERE condicion;


/* MODIFICAR */

ALTER VIEW esquema.nombre_vista
AS
SELECT columnas
FROM tabla
WHERE condicion;


/* CONSULTAR */

SELECT *
FROM esquema.nombre_vista;


/* ELIMINAR */

DROP VIEW esquema.nombre_vista;


/* ============================================================
   28. INDICES
   ============================================================ */

/* INDICE NO AGRUPADO */

CREATE NONCLUSTERED INDEX nombre_indice
ON tabla (columna1, columna2);


/* INDICE AGRUPADO */

CREATE CLUSTERED INDEX nombre_indice
ON tabla (columna);


/* INDICE UNIQUE */

CREATE UNIQUE NONCLUSTERED INDEX nombre_indice
ON tabla (columna);


/* ELIMINAR */

DROP INDEX nombre_indice ON tabla;


/* ============================================================
   29. CTE
   ============================================================ */

WITH nombre_cte (columna1, columna2, ...)
AS
(
    SELECT columna1, columna2, ...
    FROM tabla
    WHERE condicion
)
SELECT *
FROM nombre_cte;


/* ============================================================
   30. TABLAS TEMPORALES Y VARIABLES DE TABLA
   ============================================================ */

/* TEMPORAL LOCAL */

CREATE TABLE #tabla_temporal (
    columna1 tipo_dato,
    columna2 tipo_dato
);


/* TEMPORAL GLOBAL */

CREATE TABLE ##tabla_temporal (
    columna1 tipo_dato,
    columna2 tipo_dato
);


/* VARIABLE DE TABLA */

DECLARE @tabla_variable TABLE (
    columna1 tipo_dato,
    columna2 tipo_dato
);


/* ============================================================
   FIN DEL AYUDAMEMORIA
   ============================================================ */