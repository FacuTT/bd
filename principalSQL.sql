use GD2015C1;

/* 1. Mostrar el código, razón social de todos los clientes cuyo límite de crédito sea mayor o igual a $ 1000 
ordenado por código de cliente. */

select c.clie_codigo as Codigo, c.clie_razon_social as Razon_Social
from Cliente c
where c.clie_limite_credito >= 1000
order by clie_codigo;

/* 2. Mostrar el código, detalle de todos los artículos vendidos 
en el año 2012 ordenados por cantidad vendida. */

select 
    p.prod_codigo as Prod_Codigo,
    p.prod_detalle as Prod_Detalle
from Factura f
join Item_Factura i on
    f.fact_tipo = i.item_tipo and
    f.fact_sucursal = i.item_sucursal and
    f.fact_numero = i.item_numero
join Producto p on
    i.item_producto = p.prod_codigo
where year(f.fact_fecha) = 2012
group by
    p.prod_codigo,
    p.prod_detalle
order by sum(i.item_cantidad);

/* 3. Realizar una consulta que muestre código de producto, nombre de producto y el stock total, 
sin importar en que deposito se encuentre, 
los datos deben ser ordenados por nombre del artículo de menor a mayor. */

select 
    p.prod_codigo as Prod_Codigo,
    p.prod_detalle as Prod_Nombre,
    sum(s.stoc_cantidad) as Stock_Total
from Producto p
join STOCK s on
    p.prod_codigo = s.stoc_producto
group by
    p.prod_codigo,
    p.prod_detalle
order by p.prod_detalle asc

/* 4. Realizar una consulta que muestre para todos los artículos código, detalle y cantidad de
artículos que lo componen. Mostrar solo aquellos artículos para los cuales el stock
promedio por depósito sea mayor a 100. */

select
    p.prod_codigo as Prod_Codigo,
    p.prod_detalle as Prod_Detalle,
    sum(c.comp_cantidad) as Cant_Prod_Comp
from Producto p
join Composicion c on
    p.prod_codigo = c.comp_producto
join STOCK s on
    p.prod_codigo = s.stoc_producto
group by
    p.prod_codigo,
    p.prod_detalle
having
    avg(s.stoc_cantidad) > 100

----------

SELECT 
    Producto.prod_codigo, 
    Producto.prod_detalle, 
    isnull( SUM (comp_cantidad) / COUNT (DISTINCT stoc_deposito),0) AS Componentes
FROM Producto
LEFT JOIN Composicion ON Producto.prod_codigo = Composicion.comp_producto
JOIN Stock ON Producto.prod_codigo = Stock.stoc_producto
GROUP BY Producto.prod_codigo, Producto.prod_detalle
HAVING AVG (Stock.stoc_cantidad) > 100

/* 
5. Realizar una consulta que muestre código de artículo, detalle y cantidad de egresos de
stock que se realizaron para ese artículo en el año 2012 (egresan los productos que
fueron vendidos). Mostrar solo aquellos que hayan tenido más egresos que en el 2011.
*/

select 
    p.prod_codigo,
    p.prod_detalle,
    sum(i.item_cantidad) total_egresos
from Producto p
join Item_Factura i on
    i.item_producto = p.prod_codigo
join Factura f on
    f.fact_tipo+f.fact_sucursal+f.fact_numero = i.item_tipo+i.item_sucursal+i.item_numero
where year(f.fact_fecha) = 2012
group by 
    p.prod_codigo,
    p.prod_detalle
having sum(i.item_cantidad) > isnull((select 
                                sum(item_cantidad) 
                             from Item_Factura
                             join Factura on fact_tipo+fact_sucursal+fact_numero = item_tipo+item_sucursal+item_numero
                             where 
                                item_producto = p.prod_codigo and
                                year(fact_fecha) = 2011), 0)

select 
    p.prod_codigo,
    p.prod_detalle,
    sum(i.item_cantidad) as cantidad_egresos
from Producto p
join Item_Factura i on i.item_producto = p.prod_codigo
join Factura f on 
    f.fact_tipo = i.item_tipo and
    f.fact_sucursal = i.item_sucursal and
    f.fact_numero = i.item_numero
where 
    year(f.fact_fecha) = 2012
group by p.prod_codigo, p.prod_detalle
having
    isnull((select sum(i.item_cantidad)
    from Item_Factura i
    join Factura f on 
        f.fact_tipo = i.item_tipo and
        f.fact_sucursal = i.item_sucursal and
        f.fact_numero = i.item_numero 
    where
        i.item_producto = p.prod_codigo and
        year(f.fact_fecha) = 2011), 0) < sum(i.item_cantidad)

/*
6. Mostrar para todos los rubros de artículos código, detalle, cantidad de artículos de ese
rubro y stock total de ese rubro de artículos. Solo tener en cuenta aquellos artículos que
tengan un stock mayor al del artículo ‘00000000’ en el depósito ‘00’
*/

select 
    rubr_id, 
    rubr_detalle,
    count(distinct prod_codigo),
    sum(isnull(stoc_cantidad, 0))
from Rubro
left join Producto on
    prod_rubro = rubr_id
left join STOCK on
    prod_codigo = stoc_producto and
    prod_codigo in (select stoc_producto from STOCK
                        group by stoc_producto
                        having sum(stoc_cantidad) > (select stoc_cantidad from STOCK where stoc_producto = '00000000' and stoc_deposito = '00'))
group by rubr_id, rubr_detalle
order by 1 

/*
7. Generar una consulta que muestre para cada artículo código, detalle, mayor precio
menor precio y % de la diferencia de precios (respecto del menor Ej.: menor precio =
10, mayor precio =12 => mostrar 20 %). Mostrar solo aquellos artículos que posean
stock.
*/

/*
8. Mostrar para el o los artículos que tengan stock en todos los depósitos, nombre del
artículo, stock del depósito que más stock tiene.
*/

select
    p.prod_detalle,
    (select
        max(stoc_cantidad)   
     from STOCK
     where
        stoc_producto = p.prod_codigo)
from Producto p
join STOCK s on
    s.stoc_producto = p.prod_codigo
group by 
    p.prod_detalle,
    p.prod_codigo
having
    count(s.stoc_deposito) = (select 
                                count(*)
                              from DEPOSITO)

-----

select
    prod_detalle,
    MAX(stoc_cantidad),
    depo_codigo
from Producto
join STOCK on
    prod_codigo = stoc_producto
RIGHT join DEPOSITO on
    depo_codigo = stoc_deposito and 
    isnull(stoc_cantidad, -1) > 0
GROUP BY
    depo_codigo,
    prod_detalle,
    stoc_cantidad
having
    count(depo_codigo) = (select count(depo_codigo)
                          from DEPOSITO)
ORDER BY 1
    
/*
10. Mostrar los 10 productos más vendidos en la historia y también los 10 productos menos
vendidos en la historia. Además mostrar de esos productos, quien fue el cliente que
mayor compra realizo
*/

select
    p.prod_codigo,
    f.fact_cliente,
    sum(i.item_cantidad)
from Producto p
join Item_Factura i on
    i.item_producto = p.prod_codigo
join Factura f on
    f.fact_tipo+f.fact_sucursal+f.fact_numero = i.item_tipo+i.item_sucursal+i.item_numero
where 
    (p.prod_codigo in 
        (select top 10
            prod_codigo
        from Producto
        join Item_Factura on
            item_producto = prod_codigo
        group by
            prod_codigo
        order by sum(item_cantidad) desc) or
    p.prod_codigo in
        (select top 10
            prod_codigo
        from Producto
        join Item_Factura on
            item_producto = prod_codigo
        group by
            prod_codigo
        order by sum(item_cantidad) asc)) and
    f.fact_cliente in 
        (select top 1
            fact_cliente
        from Factura
        join Item_Factura on
            fact_tipo+fact_sucursal+fact_numero = item_tipo+item_sucursal+item_numero and
            item_producto = p.prod_codigo
        group by 
            fact_cliente
        order by
            sum(item_cantidad) desc)
group by
    p.prod_codigo,
    f.fact_cliente
order by
    sum(i.item_cantidad) desc

-- 10 mas vendidos
select top 10
    prod_codigo,
    sum(item_cantidad)
from Producto
join Item_Factura on
    item_producto = prod_codigo
group by
    prod_codigo
order by sum(item_cantidad) desc

-- 10 menos vendidos
select top 10
    prod_codigo,
    sum(item_cantidad)
from Producto
join Item_Factura on
    item_producto = prod_codigo
group by
    prod_codigo
order by sum(item_cantidad) asc

/*
13. Realizar una consulta que retorne para cada producto que posea composición nombre
del producto, precio del producto, precio de la sumatoria de los precios por la cantidad
de los productos que lo componen. Solo se deberán mostrar los productos que estén
compuestos por más de 2 productos y deben ser ordenados de mayor a menor por
cantidad de productos que lo componen.
*/

-- sumatoria (precio * cantidad)

-- 6 prod, 12 filas comp

select
    p.prod_detalle,
    p.prod_precio,
    sum(p2.prod_precio * c.comp_cantidad)
from Producto p
join Composicion c on
    c.comp_producto = p.prod_codigo
join Producto p2 on
    p2.prod_codigo = c.comp_componente
group by
    p.prod_detalle,
    p.prod_precio
having
    count(distinct c.comp_componente) >= 2
order by sum(c.comp_cantidad) desc -- se referia a cant productos, no unidades del componente (un count(*))

/*
14. Escriba una consulta que retorne una estadística de ventas por cliente. Los campos que
debe retornar son:
Código del cliente
Cantidad de veces que compro en el último año
Promedio por compra en el último año
Cantidad de productos diferentes que compro en el último año
Monto de la mayor compra que realizo en el último año
Se deberán retornar todos los clientes ordenados por la cantidad de veces que compro en
el último año.
No se deberán visualizar NULLs en ninguna columna
*/

-- 3000 clientes con factura
-- 66 clientes tienen factura el ultimo año

select
    f.fact_cliente,
    count(distinct (f.fact_tipo+fact_sucursal+fact_numero)) cant_compras,
    (select 
        avg(fact_total) 
    from Factura 
    where 
        fact_cliente = f.fact_cliente and 
        year(fact_fecha) = (select max(year(fact_fecha)) from Factura) 
    group by 
        fact_cliente) promedio_por_compra,
    count(distinct i.item_producto) cant_prod_diferentes,
    max(fact_total)
from Factura f
join Item_Factura i on
    i.item_tipo+i.item_sucursal+i.item_numero = f.fact_tipo+f.fact_sucursal+f.fact_numero
where
    year(f.fact_fecha) = (select max(year(fact_fecha)) from Factura)
group by 
    f.fact_cliente

/*
15. Escriba una consulta que retorne los pares de productos que hayan sido vendidos juntos
(en la misma factura) más de 500 veces. El resultado debe mostrar el código y
descripción de cada uno de los productos y la cantidad de veces que fueron vendidos
juntos. El resultado debe estar ordenado por la cantidad de veces que se vendieron
juntos dichos productos. Los distintos pares no deben retornarse más de una vez.
Ejemplo de lo que retornaría la consulta:
PROD1 DETALLE1 PROD2 DETALLE2 VECES
1731 MARLBORO KS 1 7 1 8 P H ILIPS MORRIS KS 5 0 7
1718 PHILIPS MORRIS KS 1 7 0 5 P H I L I P S MORRIS BOX 10 5 6 2
*/

select
    p1.prod_codigo,
    p1.prod_detalle,
    p2.prod_codigo,
    p2.prod_detalle,
    count(*)
from Producto p1
join Item_Factura i1 on
    i1.item_producto = p1.prod_codigo
join Item_Factura i2 on
    i2.item_tipo+i2.item_sucursal+i2.item_numero = i1.item_tipo+i1.item_sucursal+i1.item_numero
join Producto p2 on
    p2.prod_codigo = i2.item_producto
where
    p1.prod_codigo > p2.prod_codigo
group by
    p1.prod_codigo,
    p1.prod_detalle,
    p2.prod_codigo,
    p2.prod_detalle
having
    count(*) > 500
order by count(*) asc

/*
16. Con el fin de lanzar una nueva campaña comercial para los clientes que menos compran
en la empresa, se pide una consulta SQL que retorne aquellos clientes cuyas ventas son
inferiores a 1/3 del promedio de ventas del producto que más se vendió en el 2012.
Además mostrar
1. Nombre del Cliente
2. Cantidad de unidades totales vendidas en el 2012 para ese cliente.
3. Código de producto que mayor venta tuvo en el 2012 (en caso de existir más de 1,
mostrar solamente el de menor código) para ese cliente.
Aclaraciones:
La composición es de 2 niveles, es decir, un producto compuesto solo se compone de
productos no compuestos.
Los clientes deben ser ordenados por código de provincia ascendente.
*/

select
    c.clie_codigo,
    c.clie_razon_social,
    sum(f.fact_total),
    (select top 1
        item_producto
    from Item_Factura
    join Factura on
        fact_tipo+fact_sucursal+fact_numero = item_tipo+item_sucursal+item_numero
    where
        fact_cliente = c.clie_codigo and
        year(fact_fecha) = 2012
    group by
        item_producto
    order by
        sum(item_cantidad * item_precio) desc,
        item_producto asc)
from Cliente c
join Factura f on
    f.fact_cliente = c.clie_codigo
group by
    c.clie_codigo,
    c.clie_razon_social,
    c.clie_domicilio
having
    sum(f.fact_total) <
        (select top 1
            avg(item_cantidad * item_precio)
        from Item_Factura
        join Factura on
            fact_tipo+fact_sucursal+fact_numero = item_tipo+item_sucursal+item_numero
        where
            year(fact_fecha) = 2012
        group by
            item_producto
        order by
            avg(item_cantidad * item_precio) desc) / 3
order by
    c.clie_domicilio asc

(select top 1
    avg(item_cantidad * item_precio) / 3
from Item_Factura
join Factura on
    fact_tipo+fact_sucursal+fact_numero = item_tipo+item_sucursal+item_numero
where
    year(fact_fecha) = 2012
group by
    item_producto
order by
    avg(item_cantidad * item_precio) / 3 desc)

/*
25. Realizar una consulta SQL que para cada año y familia muestre :
a. Año
b. El código de la familia más vendida en ese año.
c. Cantidad de Rubros que componen esa familia.
d. Cantidad de productos que componen directamente al producto más vendido de
esa familia.
e. La cantidad de facturas en las cuales aparecen productos pertenecientes a esa
familia.
f. El código de cliente que más compro productos de esa familia.
g. El porcentaje que representa la venta de esa familia respecto al total de venta
del año.
El resultado deberá ser ordenado por el total vendido por año y familia en forma
descendente.
*/

select
    year(f.fact_fecha) anio,
    p.prod_familia familia_mas_vendida,
    (select
        count(distinct prod_rubro)
    from Producto
    where
        prod_familia = p.prod_familia),
    (select
        count(*)
    from Composicion
    where
        comp_producto = 
            (select top 1
                prod_codigo
            from Item_Factura
            join Factura on
                fact_tipo+fact_sucursal+fact_numero = item_tipo+item_sucursal+item_numero
            join Producto on
                prod_codigo = item_producto
            where
                year(fact_fecha) = year(f.fact_fecha) and
                prod_familia = p.prod_familia
            group by
                prod_codigo
            order by
                sum(item_cantidad) desc)) cant_prod_comp_mas_vend,
    count(*),
    (select top 1 
        fact_cliente
    from Factura
    join Item_Factura on
        item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero
    join Producto on
        prod_codigo = item_producto
    where
        year(fact_fecha) = year(f.fact_fecha) and
        prod_familia = p.prod_familia
    group by
        fact_cliente
    order by
        count(item_cantidad) desc) clie_mas_comprador,
    sum(item_cantidad*item_precio) /
        (select
            sum(fact_total) 
        from Factura 
        where
            year(fact_fecha) = year(f.fact_fecha)) * 100 porcentaje_venta_fam_total
from Item_Factura i
join Factura f on
    f.fact_tipo+f.fact_sucursal+f.fact_numero = i.item_tipo+i.item_sucursal+i.item_numero
join Producto p on
    p.prod_codigo = i.item_producto
where
    p.prod_familia =    (select top 1
                            fami_id
                        from Familia
                        join Producto on
                            prod_familia = fami_id
                        join Item_Factura on
                            item_producto = prod_codigo
                        join Factura on
                            fact_tipo+fact_sucursal+fact_numero = item_tipo+item_sucursal+item_numero
                        where
                            year(fact_fecha) = year(f.fact_fecha)
                        group by
                            fami_id
                        order by
                            count(item_cantidad) desc)
group by
    year(f.fact_fecha),
    p.prod_familia
order by
    sum(f.fact_total) desc

--select * from Familia

/*
20. Escriba una consulta sql que retorne un ranking de los mejores 3 empleados del 2012
Se debera retornar legajo, nombre y apellido, anio de ingreso, puntaje 2011, puntaje
2012. El puntaje de cada empleado se calculara de la siguiente manera: para los que
hayan vendido al menos 50 facturas el puntaje se calculara como la cantidad de facturas
que superen los 100 pesos que haya vendido en el año, para los que tengan menos de 50
facturas en el año el calculo del puntaje sera el 50% de cantidad de facturas realizadas
por sus subordinados directos en dicho año.
*/

select top 3
    e.empl_codigo legajo,
    rtrim(e.empl_nombre) + ' ' + rtrim(e.empl_apellido) nombre_y_apellido,
    year(e.empl_ingreso) anio_ingreso,
    case when 
        (select
            count(*)
        from Factura
        where
            fact_vendedor = e.empl_codigo and
            year(fact_fecha) = 2011) >= 50 
    then 
        (select
            count(*)
        from Factura
        where
            year(fact_fecha) = 2011 and
            fact_vendedor = e.empl_codigo and
            fact_total >= 100)
    else
        (select
            count(*)
        from Factura
        where
            year(fact_fecha) = 2011 and
            fact_vendedor in 
                (select
                    empl_codigo
                from Empleado
                where
                    empl_jefe = e.empl_codigo)) / 2
    end,
    case when 
        count(*) >= 50 
    then 
        (select
            count(*)
        from Factura
        where
            year(fact_fecha) = 2012 and
            fact_vendedor = e.empl_codigo and
            fact_total >= 100)
    else 
        (select
            count(*)
        from Factura
        where
            fact_vendedor in 
                (select
                    empl_codigo
                from Empleado
                where
                    empl_jefe = e.empl_codigo) and
            year(fact_fecha) = 2012) / 2
    end
from Empleado e
join Factura f on
    f.fact_vendedor = e.empl_codigo
where
    year(f.fact_fecha) = 2012
group by
    e.empl_codigo,
    rtrim(e.empl_nombre) + ' ' + rtrim(e.empl_apellido),
    year(e.empl_ingreso)
order by
    5 desc

/*
23. Realizar una consulta SQL que para cada año muestre :
 Año
 El producto con composición más vendido para ese año.
 Cantidad de productos que componen directamente al producto más vendido
 La cantidad de facturas en las cuales aparece ese producto.
 El código de cliente que más compro ese producto.
 El porcentaje que representa la venta de ese producto respecto al total de venta
del año.
El resultado deberá ser ordenado por el total vendido por año en forma descendente
*/

select
    year(f.fact_fecha),
    (select top 1
        comp_producto
    from Composicion
    join Item_Factura on
        item_producto = comp_producto
    join Factura on
        fact_tipo+fact_sucursal+fact_numero = item_tipo+item_sucursal+item_numero
    where
        year(fact_fecha) = year(f.fact_fecha)
    group by
        comp_producto
    order by
        sum(item_cantidad) desc),
    (select top 1
        count(distinct comp_componente)
    from Composicion
    join Item_Factura on
        item_producto = comp_producto
    join Factura on
        fact_tipo+fact_sucursal+fact_numero = item_tipo+item_sucursal+item_numero
    where
        year(fact_fecha) = year(f.fact_fecha)
    group by
        comp_producto
    order by
        sum(item_cantidad) desc),
    (select top 1
        count(distinct fact_tipo+fact_sucursal+fact_numero)
    from Composicion
    join Item_Factura on
        item_producto = comp_producto
    join Factura on
        fact_tipo+fact_sucursal+fact_numero = item_tipo+item_sucursal+item_numero
    where
        year(fact_fecha) = year(f.fact_fecha)
    group by
        comp_producto
    order by
        sum(item_cantidad) desc),
    (select top 1
        fact_cliente
    from Factura
    join Item_Factura on
        fact_tipo+fact_sucursal+fact_numero = item_tipo+item_sucursal+item_numero
    where
        year(fact_fecha) = year(f.fact_fecha) and
        item_producto =
            (select top 1
                comp_producto
            from Composicion
            join Item_Factura on
                item_producto = comp_producto
            join Factura on
                fact_tipo+fact_sucursal+fact_numero = item_tipo+item_sucursal+item_numero
            where
                year(fact_fecha) = year(f.fact_fecha)
            group by
                comp_producto
            order by
                sum(item_cantidad) desc)
    group by
        fact_cliente
    order by
        sum(item_cantidad) desc),
    (select top 1
        sum(item_cantidad * item_precio) / count(distinct comp_componente)
    from Composicion
    join Item_Factura on
        item_producto = comp_producto
    join Factura on
        fact_tipo+fact_sucursal+fact_numero = item_tipo+item_sucursal+item_numero
    where
        year(fact_fecha) = year(f.fact_fecha)
    group by
        comp_producto
    order by
        sum(item_cantidad) desc) / 
    (select
        sum(fact_total)
    from Factura
    where
        year(fact_fecha) = year(f.fact_fecha)) * 100
from Factura f
group by
    year(f.fact_fecha)
order by
    sum(fact_total) desc

/* Mas vendido de un año
select top 1
        comp_producto
    from Composicion
    join Item_Factura on
        item_producto = comp_producto
    join Factura on
        fact_tipo+fact_sucursal+fact_numero = item_tipo+item_sucursal+item_numero
    where
        year(fact_fecha) = 2010
    group by
        comp_producto
    order by
        sum(item_cantidad) desc
*/

select
    count(*)
from Composicion
join Item_Factura on
    item_producto = comp_producto
join Factura on
    fact_tipo+fact_sucursal+fact_numero = item_tipo+item_sucursal+item_numero
where
    year(fact_fecha) = 2011 and
    comp_producto = '00001718'

/*
Extra:
Realizar una consulta SQL que retorne para el ultimo año, los 5 venderdores con menos clientes asignados,
que mas vendieron en pesos (si hay varios con menos clientes asignados debe tirar el que mas vendio):

1) Apellido y Nombre del vendedor
2) Total de unidades de Producto Vendidas
3) Monto promedio de venta por factura
4) Monto total de ventas

El resultado debera mostrar ordenado la cantidad de ventas descendente, en caso de igualdad de candtidades, ordenar por codigo de vendedor.
*/

-- 2683 facturas en 2012
-- 6 vendedores en 2012

select
    rtrim(e.empl_apellido) + ' ' + rtrim(e.empl_nombre),
    sum(item_cantidad),
    avg(item_cantidad*item_cantidad),
    sum(item_cantidad*item_precio)
from Factura f
join Empleado e on
    e.empl_codigo = f.fact_vendedor
join Item_Factura i on
    i.item_tipo+i.item_sucursal+i.item_numero = f.fact_tipo+f.fact_sucursal+f.fact_numero
where
    year(f.fact_fecha) =
        (select top 1
            year(fact_fecha)
        from Factura
        order by
            year(fact_fecha) desc) and
    e.empl_codigo in 
        (select top 5
            empl_codigo
        from Factura
        join Empleado on
            empl_codigo = fact_vendedor
        where
            year(fact_fecha) =
                (select top 1
                    year(fact_fecha)
                from Factura
                order by
                    year(fact_fecha) desc)
        group by
            empl_codigo
        order by
            count(distinct fact_cliente) asc,
            sum(fact_total) desc)
group by
    e.empl_codigo,
    rtrim(e.empl_apellido) + ' ' + rtrim(e.empl_nombre)
order by
    count(distinct f.fact_tipo+f.fact_sucursal+f.fact_numero) desc,
    e.empl_codigo

/*
Extra:
Dado la baja de operaciones detectada, la empresa esta evaluando el lanzamiento de nuevas promociones y beneficios 
para ciertos clientes. Para lo cual, le solicitan un informe de los 30 clientes que posean mayor limite de credito, 
con las siguientes columnas:

- Razon social del cliente.
- Promedio en pesos de las compras realizadas durante el año 2012.
- Un string que indique "Compro productos compuestos", en caso de que alguno de todos los productos comprados 
    tenga composicion, en caso contrario ese string estara en blanco.

Se deberan mostrar 30 filas, si alguno de los clientes no compro en ese año se debera mostrar en cero.
Se deberan ordenar los resultados por el codigo del cliente.

NOTA: No se permite el uso de sub-selects en el FROM ni funciones definidas por el usuario para este punto
*/

-- 3687 clientes
-- hasta clie 02797 con 9923 limite credito

-- 6680 clientes * facturas (a cada cliente le trae sus facturas, y los que no tienen le pone factura con nulls)

-- 6364 clientes * facturas (a cada cliente le trae sus facturas, solo del 2012, y los que no tienen le pone factura con nulls)

-- 337


select
    c.clie_codigo,
    c.clie_razon_social
from Cliente c
left join Factura f on
    f.fact_vendedor = c.clie_codigo and
    year(f.fact_fecha) = 2012
group by
    c.clie_codigo,
    c.clie_razon_social
order by
    c.clie_limite_credito desc

-- posible otra solucion

select
    c.clie_codigo,
    c.clie_razon_social,
    isnull(avg(fact_total), 0),
    isnull((select
        avg(fact_total)
    from Factura
    where
        fact_cliente = c.clie_codigo and
        year(fact_fecha) = 2012
    group by
        fact_cliente), 0),
    case when
        count(distinct co.comp_producto) > 0
    then
        'Compro productos compuestos'
    else
        ''
    end
    /*
    case when
        (select
            count(*)
        from Item_Factura
        join Composicion on
            comp_producto = item_producto
        where
            item_tipo+item_sucursal+item_numero = f.fact_tipo+f.fact_sucursal+f.fact_numero
        group by
            comp_producto) > 0
    then
        'Compro productos compuestos'
    else
        ''
    end
    */
from Cliente c
left join Factura f on
    f.fact_cliente = c.clie_codigo and
    year(f.fact_fecha) = 2012
left join Item_Factura i on
    i.item_tipo+i.item_sucursal+i.item_numero = f.fact_tipo+f.fact_sucursal+f.fact_numero
left join Composicion co on
    co.comp_producto = i.item_producto
where
    c.clie_codigo in 
        (select --top 30
            clie_codigo
        from Cliente ) /*
        order by
            clie_limite_credito desc)*/
group by
    c.clie_codigo,
    c.clie_razon_social
order by
    c.clie_codigo

--

select
    fact_cliente,
    clie_razon_social,
    avg(fact_total)
from Factura
join Cliente on
    clie_codigo = fact_cliente
where
    year(fact_fecha) = 2012
group by
    fact_cliente,
    clie_razon_social
order by
    3 desc

--

-- Se comprueba que al left joinear on item se modifica el avg cosa que tiene sentido por la cantidad de fact_total se multiplican segun cantidad de items.

select
    c.clie_codigo,
    c.clie_razon_social,
    isnull(avg(fact_total), 0),
    isnull((select
        avg(fact_total)
    from Factura
    where
        fact_cliente = c.clie_codigo and
        year(fact_fecha) = 2012
    group by
        fact_cliente), 0)
from Cliente c
left join Factura f on
    f.fact_cliente = c.clie_codigo and
    year(f.fact_fecha) = 2012
left join Item_Factura i on
    i.item_tipo+i.item_sucursal+i.item_numero = f.fact_tipo+f.fact_sucursal+f.fact_numero
where
    c.clie_codigo in 
        (select --top 30
            clie_codigo
        from Cliente ) /*
        order by
            clie_limite_credito desc)*/
group by
    c.clie_codigo,
    c.clie_razon_social
order by
    c.clie_codigo

/*
Extra:
Realizar una consulta SQL que devuelva todos los clientes que durante
2 años consecutivos compraron al menos 5 productos distintos. De
esos clientes mostrar:
● El código de cliente
● El monto total comprado en el 2012
● La cantidad de unidades de productos compradas en el 2012
El resultado debe ser ordenado primero por aquellos clientes que compraron
solo productos compuestos en algún momento, luego el resto.
*/

-- Otra solucion

-- clientes que compraron en 2 años consecutivos, tengan una factura en año x y otra en año x + 1

select
    *
from Cliente c
join Factura f on
    f.fact_cliente = c.clie_codigo
where
    year(f.fact_fecha) =
        (select

        from Factura
        join Item_Factura on
            item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero
        where
            fact_cliente = c.clie_codigo and
            year(fact_fecha) = year(f.fact_fecha) + 1
        group by
            fact_cliente
        having
            count(distinct item_producto) > 5)


select
from Cliente
join Factura on
    fact_cliente = clie_codigo

-- Solucion original

-- 3687 clientes

-- 3000 clientes y sus facturas

-- 19484 clientes, sus facturas y items facturas para cada factura

--  800K facturas del mismo cliente de años consecutivos 

select
    c.clie_codigo,
    isnull((select
        sum(fact_total)
    from Factura
    where
        fact_cliente = c.clie_codigo and
        year(fact_fecha) = 2012
    group by
        fact_cliente), 0),
    (select
        sum(item_cantidad)
    from Factura
    join Item_Factura on
        item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero
    where
        fact_cliente = c.clie_codigo and
        year(fact_fecha) = 2012
    group by
        fact_cliente)
from Cliente c 
join Factura f on
    f.fact_cliente = c.clie_codigo
join Factura f2 on
    f2.fact_cliente = c.clie_codigo
join Item_Factura i on
    i.item_tipo+i.item_sucursal+i.item_numero = f.fact_tipo+f.fact_sucursal+f.fact_numero
join Item_Factura i2 on
    i2.item_tipo+i2.item_sucursal+i2.item_numero = f2.fact_tipo+f2.fact_sucursal+f2.fact_numero
where
    year(f.fact_fecha) + 1 = year(f2.fact_fecha)
group by
    c.clie_codigo 
having
    count(distinct i.item_producto) > 5 and 
    count(distinct i2.item_producto) > 5
order by
    (select
        count(*)
    from Factura
    join Item_Factura on
        item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero
    join Composicion on
        comp_producto = item_producto
    where
        fact_cliente = c.clie_codigo
    ) desc


factura1 factura2 ambos pertenecen a mismo cliente

/*
SIMON ROJAS 20:14
select c.clie_codigo,
(select sum(fact_total) 
from Factura
where fact_cliente = c.clie_codigo and YEAR(fact_fecha) = 2012) as total_comprado,
(select sum(item_cantidad) 
from Factura
join Item_Factura on item_numero = fact_numero and
item_sucursal = fact_sucursal and
item_tipo = fact_tipo
where fact_cliente = c.clie_codigo and YEAR(fact_fecha) = 2012) as total_cantidades
from Cliente c
join Factura f on f.fact_cliente = c.clie_codigo
join Factura f2 on f2.fact_cliente = c.clie_codigo 
join Item_Factura i on (f.fact_numero = i.item_numero and
f.fact_sucursal = i.item_sucursal and
f.fact_tipo= i.item_tipo)
where (YEAR(f.fact_fecha) - 1 = YEAR(f2.fact_fecha)) or
(YEAR(f2.fact_fecha) - 1 = YEAR(f.fact_fecha))
group by c.clie_codigo
having (count(distinct item_producto) >= 5)
order by
 case when exists (select 1 from Composicion 
       join Item_Factura on item_producto = comp_producto
       join Factura on item_numero = fact_numero and
         item_sucursal = fact_sucursal and
         item_tipo = fact_tipo and
         fact_cliente = c.clie_codigo)
  then 1
 else 
  0
end
desc

Natalia JazmÍn Espejo Mendoza 20:14
SELECT
cl.clie_codigo AS Cod_Cliente,
ISNULL((SELECT SUM(f2.fact_total) 
FROM Factura f2 
WHERE YEAR(f2.fact_fecha) = 2012 AND f2.fact_cliente = cl.clie_codigo)
, 0) AS Monto_Total,
ISNULL((SELECT SUM(i.item_cantidad)
FROM Factura f
JOIN Item_Factura i ON f.fact_tipo = i.item_tipo AND f.fact_sucursal = i.item_sucursal AND f.fact_numero = I.item_numero
WHERE cl.clie_codigo = f.fact_cliente)
, 0) AS Cant_Unid_Prod
FROM Cliente cl
WHERE cl.clie_codigo IN (
    SELECT fb.fact_cliente--,YEAR(fb.fact_fecha)
    FROM Factura fb
    GROUP BY fb.fact_cliente, YEAR(fb.fact_fecha) --order by fb.fact_cliente asc
    HAVING (SELECT COUNT(DISTINCT i1.item_producto)
            FROM Factura f1
            JOIN Item_Factura i1 ON f1.fact_tipo = i1.item_tipo AND f1.fact_sucursal = i1.item_sucursal AND f1.fact_numero = i1.item_numero
            WHERE f1.fact_cliente = fb.fact_cliente
              AND YEAR(f1.fact_fecha) = YEAR(fb.fact_fecha) ) >= 5
       AND (SELECT COUNT(DISTINCT i2.item_producto)
            FROM Factura f2
            JOIN Item_Factura i2 ON f2.fact_tipo = i2.item_tipo AND f2.fact_sucursal = i2.item_sucursal AND f2.fact_numero = i2.item_numero
            WHERE f2.fact_cliente = fb.fact_cliente
              AND YEAR(f2.fact_fecha) = YEAR(fb.fact_fecha) + 1) >= 5
            )
ORDER BY 
    CASE
        WHEN EXISTS (
            SELECT 1
            FROM Factura fc
            WHERE fc.fact_cliente = cl.clie_codigo
              AND EXISTS (
                    SELECT 1
                    FROM Item_Factura ic
                    WHERE ic.item_tipo = fc.fact_tipo AND ic.item_sucursal = fc.fact_sucursal AND ic.item_numero = fc.fact_numero )
              AND NOT EXISTS (
                    SELECT 1
                    FROM Item_Factura ic2
                    WHERE ic2.item_tipo = fc.fact_tipo AND ic2.item_sucursal = fc.fact_sucursal AND ic2.item_numero = fc.fact_numero
                      AND ic2.item_producto NOT IN (
                            SELECT comp_producto
                            FROM Composicion) )
            ) THEN 0 ELSE 1
    END, cl.clie_codigo
*/

/*
Extra Parcial:
Se solicita una estadistica por Año y familia, para ello se debera mostrar:

Año,
Codigo de la familia,
Detalle de la familia,
Cantidad de facturas,
Cantidad de productos con composicion vendidos,
Monto total vendido.

Solo se debera considerar las familias que tengan al menos un producto com composicion y que
se hayan vendido conjuntamente (en la misma factura) con otra familia distinta.

NOTA: No se permite el uso de sub-selects en el FROM ni funciones definidas por el usuario para este punto
*/

-- 3000 facturas

-- 19484 items facturas y sus facturas

-- 19484 items facturas, sus facturas y sus productos

select
    year(f.fact_fecha),
    fa.fami_id,
    fa.fami_detalle,
    count(distinct f.fact_tipo+f.fact_sucursal+f.fact_numero),
    (select
    from ),
    sum(i.item_cantidad * i.item_precio)
from Factura f
join Item_Factura i on
    i.item_tipo+i.item_sucursal+i.item_numero = f.fact_tipo+f.fact_sucursal+f.fact_numero
join Producto p on
    p.prod_codigo = i.item_producto
join Familia fa on
    fa.fami_id = p.prod_familia
where
    fa.fami_id in 
        (select
            prod_familia
        from Producto 
        join Composicion on
            comp_producto = prod_codigo
        join Item_Factura on
            item_tipo+item_sucursal+item_numero = f.fact_tipo+f.fact_sucursal+f.fact_numero and
            item_producto = prod_codigo
        where
            prod_familia <> p.prod_familia
        group by
            prod_familia)
group by
    year(f.fact_fecha)

-- 95 familias en total

-- 92 familias estan asociados a al menos 1 producto

-- 12 productos y sus componentes.

-- 2 familias tienen productos con composicion

select
    *
from Producto 
join Composicion on
    comp_producto = prod_codigo
join Item_Factura on
    item_tipo+item_sucursal+item_numero = and
    item_producto = prod_codigo
where
    prod_familia <> 
group by
    prod_familia
