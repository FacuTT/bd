use GD2015C1

/*
1. Hacer una función que dado un artículo y un deposito devuelva un string que
indique el estado del depósito según el artículo. Si la cantidad almacenada es
menor al límite retornar “OCUPACION DEL DEPOSITO XX %” siendo XX el
% de ocupación. Si la cantidad almacenada es mayor o igual al límite retornar
“DEPOSITO COMPLETO”.
*/
go
alter function ej1 (@articulo char(8), @deposito char(2))
returns varchar(50)
as
begin
    declare @stock_max decimal(12,2)
    declare @stock decimal(12,2)
    select @stock = isnull(stoc_cantidad, 0), @stock_max = isnull(stoc_stock_maximo, 0) from STOCK where stoc_deposito = @deposito and stoc_producto = @articulo
    if (@stock >= @stock_max or @stock_max = 0) 
        begin
        return 'DEPOSITO COMPLETO'
        end
    return 'OCUPACION DEL DEPOSITO ' + str((@stock/@stock_max) * 100, 6, 2) + ' %'
end
go

-- select stoc_cantidad, stoc_stock_maximo, dbo.ej1(stoc_producto, stoc_deposito) from STOCK

/*
3. Cree el/los objetos de base de datos necesarios para corregir la tabla empleado
en caso que sea necesario. Se sabe que debería existir un único gerente general
(debería ser el único empleado sin jefe). Si detecta que hay más de un empleado
sin jefe deberá elegir entre ellos el gerente general, el cual será seleccionado por
mayor salario. Si hay más de uno se seleccionara el de mayor antigüedad en la
empresa. Al finalizar la ejecución del objeto la tabla deberá cumplir con la regla
de un único empleado sin jefe (el gerente general) y deberá retornar la cantidad
de empleados que había sin jefe antes de la ejecución.
*/

go
alter procedure ej3 @cantidad int output
as
begin
    select @cantidad = count(*) from Empleado where empl_jefe is null
    if (@cantidad > 1)
        begin
        declare @jefe_cod numeric(6)
        select top 1 @jefe_cod = empl_codigo from Empleado where empl_jefe is null order by empl_salario desc, empl_ingreso asc

        update Empleado set empl_jefe = @jefe_cod where empl_jefe is null and empl_codigo <> @jefe_cod
        end
    return
end
go

/*
declare @CantidadParaEj3 int
exec ej3 @CantidadParaEj3

select empl_codigo, empl_jefe from Empleado

update Empleado set empl_jefe = null where empl_jefe = 1
*/

/*
2. Realizar una función que dado un artículo y una fecha, retorne el stock que
existía a esa fecha
*/

alter function ej2 (@articulo char(8), @fecha smalldatetime)
returns decimal(12,2)
as
begin
    declare @stock_actual decimal(12,2), @cant_vendida_post_fecha decimal(12,2)
    select @stock_actual = isnull(sum(stoc_cantidad), 0) from STOCK where stoc_producto = @articulo
    select @cant_vendida_post_fecha = isnull(sum(item_cantidad), 0) from Item_Factura join Factura on fact_tipo+fact_sucursal+fact_numero = item_tipo+item_sucursal+item_numero where item_producto = @articulo and fact_fecha > @fecha
    return @stock_actual + @cant_vendida_post_fecha
end
go

select sum(isnull(stoc_cantidad, 0)) from STOCK group by stoc_producto

select prod_codigo from Producto

select sum(stoc_cantidad) from STOCK where stoc_producto = '00000102' group by stoc_producto
select sum(item_cantidad) from Item_Factura join Factura on fact_tipo+fact_sucursal+fact_numero = item_tipo+item_sucursal+item_numero where item_producto = '00000102' and fact_fecha > '2022-01-01' group by item_producto

select dbo.ej2('00000102', '20000101')
select dbo.ej2('00000102', '20790601')

SELECT SUM(item_cantidad) AS cantidad_vendida
FROM Item_Factura
JOIN Factura
  ON fact_tipo + fact_sucursal + fact_numero =
     item_tipo + item_sucursal + item_numero
WHERE item_producto = '00000102'
  AND fact_fecha > '20790601';

/*
4. Cree el/los objetos de base de datos necesarios para actualizar la columna de
empleado empl_comision con la sumatoria del total de lo vendido por ese
empleado a lo largo del último año. Se deberá retornar el código del vendedor
que más vendió (en monto) a lo largo del último año.
*/

go
alter procedure ej4 @vend_cod numeric(6) output
as
begin 
    select top 1
        @vend_cod = fact_vendedor
    from Factura
    where
        year(fact_fecha) = (select top 1 year(fact_fecha) from Factura order by fact_fecha desc)
    group by
        fact_vendedor
    order by
        sum(fact_total-fact_total_impuestos) desc

    update Empleado
    set
        empl_comision = isnull((select
                            sum(fact_total-fact_total_impuestos)
                        from Factura
                        where
                            year(fact_fecha) = (select top 1 year(fact_fecha) from Factura order by fact_fecha desc) and
                            fact_vendedor = empl_codigo
                        group by
                            fact_vendedor), 0)
    return
end
go

-- Empleado que mas vendio en el ultimo año
select top 1
    fact_vendedor
from Factura
where
    year(fact_fecha) = (select top 1 year(fact_fecha) from Factura order by fact_fecha desc)
group by
    fact_vendedor
order by
    sum(fact_total-fact_total_impuestos) desc

-- Codigo y comision de todos los empleados
select empl_codigo, empl_comision from Empleado

declare @param_ej4 numeric(6)
exec dbo.ej4 @param_ej4

/*
8. Realizar un procedimiento que complete la tabla Diferencias de precios, para los
productos facturados que tengan composición y en los cuales el precio de
facturación sea diferente al precio del cálculo de los precios unitarios por
cantidad de sus componentes, se aclara que un producto que compone a otro,
también puede estar compuesto por otros y así sucesivamente, la tabla se debe
crear y está formada por las siguientes columnas:
*/

create table Diferencias (
    codigo char(8), 
    detalle char(50),
    cantidad decimal(12,2),
    precio_generado decimal(12,2),
    precio_facturado decimal(12,2)
)

drop table Diferencias

go
alter procedure ej8
as
begin
    declare @comp_prod char(8)
    declare @comp_detalle char(50)
    declare @precio_facturado decimal(12,2)

    declare @cant_combo decimal(12,2)
    declare @precio_genererado decimal(12,2)

    -- Declaramos cursor de todos los productos componente
    declare cComposicion cursor for
    select 
        comp_producto,
        prod_detalle,
        prod_precio
    from Composicion
    join Producto on
        prod_codigo = comp_producto
    join Item_Factura on
        item_producto = comp_producto
    group by 
        comp_producto,
        prod_detalle,
        prod_precio

    open cComposicion

    fetch next from cComposicion into @comp_prod, @comp_detalle, @precio_facturado

    while @@FETCH_STATUS = 0
    begin
        select
            @cant_combo = sum(comp_cantidad),
            @precio_genererado = sum(prod_precio * comp_cantidad)
        from Composicion
        join Producto on 
            prod_codigo = comp_componente
        where
            comp_producto = @comp_prod
        
        if (@precio_facturado <> @precio_genererado)
        begin
            insert into Diferencias (codigo, detalle, cantidad, precio_generado, precio_facturado)
            values (@comp_prod, @comp_detalle, @cant_combo, @precio_genererado, @precio_facturado)
        end

        fetch next from cComposicion into @comp_prod, @comp_detalle, @precio_facturado
    end

    close cComposicion
    deallocate cComposicion

    return
end 
go

-- universo
select
    c.comp_producto, p.prod_precio, c.comp_componente, c.comp_cantidad, p2.prod_precio
from Producto p
join Composicion c on
    c.comp_producto = p.prod_codigo
join Producto p2 on
    p2.prod_codigo = c.comp_componente

-- diferencias
select * from Diferencias

select prod_codigo, prod_precio from Producto where prod_codigo = '00001718'

exec dbo.ej8

-- la respuesta esta mal porque no es recursivo

/*
10. Crear el/los objetos de base de datos que ante el intento de borrar un artículo
verifique que no exista stock y si es así lo borre en caso contrario que emita un
mensaje de error.
*/

go
create procedure ej10
as
begin
    declare @producto char(8)
    declare @stoc_total decimal(12,2)

    declare cProdStoc cursor for select 
        stoc_producto, 
        sum(stoc_cantidad)
    from Producto
    left join STOCK on
        stoc_producto = prod_codigo
    group by stoc_producto

    open cProdStoc

    fetch next cProdStoc into @producto, @stoc_total

    while @@FETCH_STATUS = 0
    begin
        if (@stoc_total is null)
        begin
            delete from Producto
            where prod_codigo = @producto
        end

        print 'Error, el producto aun tiene stock'

        fetch next cProdStoc into @producto, @stoc_total
    end
    
    close cProdStoc
    deallocate cProdStoc

    return 
end
go

-- ejercicio mal, era con un trigger

/*
12. Cree el/los objetos de base de datos necesarios para que nunca un producto
pueda ser compuesto por sí mismo. Se sabe que en la actualidad dicha regla se
cumple y que la base de datos es accedida por n aplicaciones de diferentes tipos
y tecnologías. No se conoce la cantidad de niveles de composición existentes.
*/

go
alter trigger ej12
on Composicion
instead of insert, update
as
begin
    if ((select count(*) from inserted where dbo.compone(comp_componente, comp_producto) = 1) > 0)
    begin
        print 'Error, hay productos que tienen de componente al mismo producto'
    end

    insert into Composicion
    select * from inserted

    return
end 
go

go
alter function compone (@producto char(8), @componente char(8))
returns int
as
begin
    declare @retorno int
    select @retorno = 0

    if (@producto = @componente)
    begin
        select @retorno = 1
        return @retorno
    end

    declare cComponente cursor for
    select
        comp_componente
    from Composicion
    where
        comp_producto = @producto

    open cComponente

    declare @componedor char(8)
    fetch next from cComponente into @componedor

    while @@FETCH_STATUS = 0
    begin
        if (dbo.compone(@componedor, @componente) = 1)
        begin
            select @retorno = 1
            break
        end
        fetch next from cComponente into @componedor
    end

    close cComponente
    deallocate cComponente

    return @retorno
end
go

/*
9. Crear el/los objetos de base de datos que ante alguna modificación de un ítem de
factura de un artículo con composición realice el movimiento de sus
correspondientes componentes.
*/

/*
go
create trigger ej9 on Item_Factura 
instead of update
as
begin
    declare cItem_Factura cursor for
    select
        item_producto,
        item_cantidad,

    from insertead
    join Factura


    update stock
    set
        stoc_cantidad -= 
end 

select
    *
from Item_Factura
join Factura on
    fact_tipo+fact_sucursal+fact_numero = item_tipo+item_sucursal+item_numero
join Empleado on
    empl_codigo = fact_vendedor
join Departamento on
    depa_codigo = empl_departamento
join Zona on
    zona_codigo = depa_zona
join DEPOSITO on
    depo_encargado = empl_codigo
*/

/*
31. Desarrolle el o los objetos de base de datos necesarios, para que un jefe no pueda
tener más de 20 empleados a cargo, directa o indirectamente, si esto ocurre
debera asignarsele un jefe que cumpla esa condición, si no existe un jefe para
asignarle se le deberá colocar como jefe al gerente general que es aquel que no
tiene jefe.
*/

go
create trigger ej31 on Empleado
instead of insert
as
begin
    declare @empl_codigo numeric(6)
    declare @empl_nombre char(50)
    declare @empl_apellido char(50)
    declare @empl_nacimiento smalldatetime
    declare @empl_ingreso smalldatetime
    declare @empl_tareas char(100)
    declare @empl_salario decimal(12,2)
    declare @empl_comision decimal(12,2)
    declare @empl_jefe numeric(6)
    declare @empl_departamento numeric(6,0)
    
    declare cEmpleado cursor for
    select
        *
    from inserted

    open cEmpleado

    fetch next from cEmpleado into
        @empl_codigo,
        @empl_nombre,
        @empl_apellido, 
        @empl_nacimiento,
        @empl_ingreso,
        @empl_tareas,
        @empl_salario,
        @empl_comision,
        @empl_jefe,
        @empl_departamento

    while @@FETCH_STATUS = 0
    begin

        if (dbo.cantidadEmpleados(@empl_jefe) < 20)
        begin
            insert into Empleado 
                (
                    empl_codigo,
                    empl_nombre,
                    empl_apellido, 
                    empl_nacimiento,
                    empl_ingreso,
                    empl_tareas,
                    empl_salario,
                    empl_comision,
                    empl_jefe,
                    empl_departamento
                )
            values
                (
                    @empl_codigo,
                    @empl_nombre,
                    @empl_apellido, 
                    @empl_nacimiento,
                    @empl_ingreso,
                    @empl_tareas,
                    @empl_salario,
                    @empl_comision,
                    @empl_jefe,
                    @empl_departamento
                )
        end

    -- Si llega hasta aca es porque no se le puede asignar dicho jefe, hay que buscar otro

    if (
            (select
                count(*)
            from Empleado
            where
                dbo.cantidadEmpleados(empl_codigo) < 20 and
                empl_jefe is not null) > 0
        )
    begin
        insert into Empleado
            (
                empl_codigo,
                empl_nombre,
                empl_apellido, 
                empl_nacimiento,
                empl_ingreso,
                empl_tareas,
                empl_salario,
                empl_comision,
                empl_jefe,
                empl_departamento
            )
        values
            (
                @empl_codigo,
                @empl_nombre,
                @empl_apellido, 
                @empl_nacimiento,
                @empl_ingreso,
                @empl_tareas,
                @empl_salario,
                @empl_comision,
                (select top 1
                    empl_codigo
                from Empleado
                where
                    dbo.cantidadEmpleados(empl_codigo) < 20 and
                    empl_jefe is not null),
                @empl_departamento
            )

        -- Si llega hasta aca es porque no hay jefe disponible, se le asigna al gerente

        insert into Empleado
            (
                empl_codigo,
                empl_nombre,
                empl_apellido, 
                empl_nacimiento,
                empl_ingreso,
                empl_tareas,
                empl_salario,
                empl_comision,
                empl_jefe,
                empl_departamento
            )
        values
            (
                @empl_codigo,
                @empl_nombre,
                @empl_apellido, 
                @empl_nacimiento,
                @empl_ingreso,
                @empl_tareas,
                @empl_salario,
                @empl_comision,
                (select top 1 -- top 1 por si hay mas de 1 gerente (aunque no deberia por regla de negocio)
                    empl_codigo
                from Empleado
                where
                    empl_jefe is null),
                @empl_departamento
            )
    end

    fetch next from cEmpleado into
        @empl_codigo,
        @empl_nombre,
        @empl_apellido, 
        @empl_nacimiento,
        @empl_ingreso,
        @empl_tareas,
        @empl_salario,
        @empl_comision,
        @empl_jefe,
        @empl_departamento
    end

    close cEmpleado
    deallocate cEmpleado

    return
end
go

go
alter function cantidadEmpleados(@empl_codigo numeric(6))
returns int
as 
begin 
    if (
            (select 
                count(*)
            from Empleado
            where
                empl_jefe = @empl_codigo) = 0
        )
    begin
        return 0
    end

    -- Si llega hasta aca es porque tiene por lo menos 1 empleado a cargo

    declare @cantidad_empleados int

    select
        @cantidad_empleados = count(*)+ sum(dbo.cantidadEmpleados(empl_codigo))
    from Empleado
    where
        empl_jefe = @empl_codigo

    return @cantidad_empleados
end
go

-- universo
select
    e.empl_codigo,
    e.empl_jefe,
    (select 
        count(*)
    from Empleado
    where
        empl_jefe = e.empl_codigo),
    dbo.cantidadEmpleados(e.empl_codigo)
from Empleado e

select 
    count(*)
from Empleado
where
    empl_jefe = 1

/*
16. Desarrolle el/los elementos de base de datos necesarios para que ante una venta
automaticamante se descuenten del stock los articulos vendidos. Se descontaran
del deposito que mas producto poseea y se supone que el stock se almacena
tanto de productos simples como compuestos (si se acaba el stock de los
compuestos no se arman combos)
En caso que no alcance el stock de un deposito se descontara del siguiente y asi
hasta agotar los depositos posibles. En ultima instancia se dejara stock negativo
en el ultimo deposito que se desconto.
*/

go
create trigger ej16
on Item_Factura
after insert
as
begin transaction
    declare @producto char(8)
    declare @cantidad decimal(12,2)

    declare @deposito char(2)
    declare @cant_deposito decimal(12,2)
    declare @ultimo_deposito char(2)

    declare cItems cursor for
    select
        item_producto,
        item_cantidad
    from inseted

    open cItems

    fetch from cItems into @producto, @cantidad

    while @@FETCH_STATUS = 0
    begin

        select top 1
            @ultimo_deposito = stoc_deposito
        from stock
        where
            stoc_producto = @producto
        order by
            stoc_cantidad desc

        declare cStock cursor for
        select
            stoc_deposito,
            stoc_cantidad
        from stock
        where
            stoc_producto = @producto
        order by
            stoc_cantidad desc

        open cStock

        fetch from cStock into @deposito, @cant_deposito

        while (@@FETCH_STATUS = 0 and @cantidad > 0)
        begin
            if (@deposito = @ultimo_deposito)
            begin
                update stock
                set stoc_cantidad = stoc_cantidad - @cantidad
                where
                    stoc_producto = @producto and
                    stoc_deposito = @deposito -- Que es el ultimo deposito
                
                break
            end

            if (@cant_deposito >= @cantidad)
            begin
                update stock
                set stoc_cantidad = stoc_cantidad - @cantidad
                where
                    stoc_producto = @producto and
                    stoc_deposito = @deposito
                
                break
            end
            
            if (@cant_deposito <= 0)
            begin
                fetch from cStock into @deposito, @cant_deposito
                continue
            end

            -- Si llegamos hasta aca es porque el deposito tenia stock, pero no el suficiente para todo el total
            update stock
            set stoc_cantidad = 0
            where
                stoc_producto = @producto and
                stoc_deposito = @deposito
            select @cantidad = @cantidad - @cant_deposito

            fetch from cStock into @deposito, @cant_deposito
        end

        close cStock
        deallocate cStock

        fetch from cItems into @producto, @cantidad
    end

    close cItems
    deallocate cItems

commit
go

-- Esta mal la parte donde se asigna todo al ultimo deposito, dado que es al ultimo donde se DESCONTO.

/*
2. Suponiendo que se aplican los siguientes cambios en el modelo de
datos:
Cambio 1) create table provincia (id int primary key, nombre char(100)) ;
Cambio 2) alter table cliente add pcia_id int null;
Crear el/los objetos necesarios para implementar el concepto de foreign
key entre 2 cliente y provincia.
Nota: No se permite agregar una constraint de tipo FOREIGN KEY entre la
tabla y el campo agregado.
*/

create table Provincia (
    id int PRIMARY KEY,
    nombre char(100)
)

alter table Cliente add provincia_id int null

go
create trigger fkProvincia
on Cliente
after insert, update
as
begin
    transaction
    
    if (
            (select 
                count(*)
            from inserted
            where
                clie_provincia is not null or
                clie_provincia not in (select id from Provincia)) <> 0
    )
    begin
        rollback
        print 'Hay clientes con provincias que no existen'
    end

    return
    commit 
end
go

go
create trigger fkBorrado
on Provincia
after delete
begin 
    transaction

    if (
            (select 
                count(*)
            from Cliente
            join deleted on
                id = clie_provincia) > 0
    )
    begin
        rollback
        print 'Se intento borrar provincias referenciadas por clientes'
    end

    commit
    return
end
go

go
create trigger fkUpdate
on Provincia
after update
begin
    transaction
    
    if (
            (select
                count(*)
            from Cliente
            join deleted on
                id = provincia_id) > 0
    )
    begin
        rollback
        print 'Se intento actualizar ids de provincias que estan siendo referenciadas por clientes'
    end

    commit
    return
end
go

a cada cliente traeme su provincia

solo traera cliente con provincia

si hay mas de 0 significa que encontro por lo menos 1 cliente con provincia

cliente provincia       provincia
1       1               1
2       2               3
3       null            
4       null         

1 cliente con provincia

1 cliente con mala fk

2 clientes sin provincia

/*
Solucion profe:
CREATE TRIGGER TRIGGER_PUNTO2_1 ON Provincia
AFTER DELETE, UPDATE, INSERT 
AS
BEGIN TRANSACTION

    SET TRANSACTION ISOLATION LEVEL READ SERIALIZABLE 

    IF EXISTS(
                SELECT 1
                FROM CLIENTE WHERE 
                clie_pcia NOT IN ( SELECT id from provincia ) 
                )
    BEGIN
        PRINT 'NO SE PUEDE BORRAR UNA PROVINCIA CON CLIENTES ASIGNADOS.'
        ROLLBACK
        RETURN
    END 
COMMIT TRANSACTION

CREATE TRIGGER TRIGGER_PUNTO2_1 ON CLIENTE
AFTER UPDATE, INSERT 
AS
BEGIN TRANSACTION

    SET TRANSACTION ISOLATION LEVEL READ SERIALIZABLE 

    IF EXISTS(
                SELECT 1
                FROM CLIENTE WHERE 
                clie_pcia NOT IN ( SELECT id from provincia ) 
                )
    BEGIN
        PRINT 'NO SE PUEDE BORRAR UNA PROVINCIA CON CLIENTES ASIGNADOS.'
        ROLLBACK
        RETURN
    END 
COMMIT TRANSACTION
*/

/*
Actualmente el campo fact_vendedor representa el empleado que vendio la factura, emplementar los objetos necesarios
para respetar la integridad referencial de dicho campo suponiendo que no existe una foreing key para entre ambos
No se puede usar una foreing key para el ejecicio, debera buscar otro metodo.
*/

/*
Una FK permite las siguientes cosas
1. Tiene que existir la relacion a la que se hace referencia
2. No se puede eliminar una fila si esta siendo referenciada
3. No se puede actualizar una fila si esta siendo referenciada 
*/

create trigger fkVendedor on Factura
after insert, update
as
begin
    if (
            (select
                count(*)
            from inserted
            where
                fact_vendedor is not null and
                fact_vendedor not in 
                    (select
                        empl_codigo
                    from Empleado)) > 0
    )
    begin
        print 'Hay facturas que referencian a vendedores (empleados) inexistentes'
        rollback
    end
    
    return
end

create trigger fkFactura on Empleado
after delete, update
as
begin
    if (
            (select
                count(*)
            from deleted
            join Factura on
                fact_vendedor = empl_codigo) > 0
    )
    begin 
        print 'Hay empleados que estan siendo referenciados por facturas'  
    end   
end

select
    *
from empleado

-- 2 y 6 no tienen factura asociada

select
    empl_codigo
from Empleado
join Factura on
    fact_vendedor = empl_codigo
where
    empl_codigo = 6
group by
    empl_codigo