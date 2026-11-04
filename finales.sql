use GD2015C1

-- Parcial Martes 28/06/2025

/*
1. El objetivo es realizar una consulta SQL que identifique a los clientes que 
compraron productos que pertenezcan a dos rankings distintos del año 2012:

	- Los 10 productos más vendidos en 2012.
	- Los 10 productos menos vendidos en 2012 (considerando únicamente los 
	  10 productos con menor cantidad vendida, incluso si hay mas de 10
	  productos con el mismo valor mínimo).

La consulta debe devolver los siguientes datos:

	1. El número de fila (orden correlativo). 
	2. El nombre del cliente. 
	3. Si es cliente en el Ranking de los más vendidos. 
	4. Cantidad total de Facturas del cliente.

El resultado debe estar ordenado en forma descendente según el monto total de 
compras del cliente (de mayor a menor).

Nota: No se permiten select en el from, es decir, select ... from (select ...) as T,... 
Ni WITH. ni tablas temporales.
*/

/*
3687 clientes

19484 items facturas

661 productos vendidos

629 productos vendidos en 2012

4159 items facturas que cumplen que el producto pertenezca a los rankings

58 clientes compraron productos que pertenezcan a dos rankings
*/

select
	row_number() over 
		(order by 
			(select 
				sum(fact_total) 
			from Factura 
			where 
				fact_cliente = c.clie_codigo) desc) as Numero_fila,
	c.clie_razon_social as Nombre_cliente,
	case when
		(select
			count(*)
		from Factura
		join Item_Factura on
			item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero
		where
			fact_cliente = c.clie_codigo and
			item_producto in 
				(select top 10
					item_producto
				from Item_Factura
				join Factura on
					fact_tipo+fact_sucursal+fact_numero = item_tipo+item_sucursal+item_numero
				where
					year(fact_fecha) = 2012
				group by
					item_producto
				order by
					sum(item_cantidad) desc)) > 0
	then
		'Si'
	else
		''
	end as Es_cliente_ranking_mas_vendidos,
	(select
		count(*)
	from Factura
	where
		fact_cliente = c.clie_codigo) as Cant_total_facturas
from Cliente c
join Factura f on
	f.fact_cliente = c.clie_codigo
join Item_Factura i on
	i.item_tipo+i.item_sucursal+i.item_numero = f.fact_tipo+f.fact_sucursal+f.fact_numero
where
	i.item_producto in 
		(select top 10
			item_producto
		from Item_Factura
		join Factura on
			fact_tipo+fact_sucursal+fact_numero = item_tipo+item_sucursal+item_numero
		where
			year(fact_fecha) = 2012
		group by
			item_producto
		order by
			sum(item_cantidad) desc) or
	i.item_producto in
		(select top 10
			item_producto
		from Item_Factura
		join Factura on
			fact_tipo+fact_sucursal+fact_numero = item_tipo+item_sucursal+item_numero
		where
			year(fact_fecha) = 2012
		group by
			item_producto
		order by
			sum(item_cantidad) asc)
group by
	c.clie_codigo,
	c.clie_razon_social
order by
	(select
		sum(fact_total)
	from Factura
	where
		fact_cliente = c.clie_codigo) desc

-- top 10 productos mas vendidos en 2012
select top 10
	item_producto,
	sum(item_cantidad)
from Item_Factura
join Factura on
	fact_tipo+fact_sucursal+fact_numero = item_tipo+item_sucursal+item_numero
where
	year(fact_fecha) = 2012
group by
	item_producto
order by
	sum(item_cantidad) desc

-- top 10 productos menos vendidos en 2012
select top 10
	item_producto,
	sum(item_cantidad)
from Item_Factura
join Factura on
	fact_tipo+fact_sucursal+fact_numero = item_tipo+item_sucursal+item_numero
where
	year(fact_fecha) = 2012
group by
	item_producto
order by
	sum(item_cantidad) asc

/*
SOL: UTNIANOS 10

SELECT
	ROW_NUMBER() OVER(ORDER BY SUM(i.item_precio * i.item_cantidad)) AS
Número_de_Fila,
	c.clie_razon_social AS Cliente,
	(CASE WHEN EXISTS (SELECT TOP 10
									1
								FROM Factura f2
								JOIN Item_Factura i2 ON f2.fact_sucursal =
i2.item_sucursal AND

f2.fact_numero = i2.item_numero AND

f2.fact_tipo = i2.item_tipo
									WHERE f2.fact_cliente = f.fact_cliente AND
										i2.item_producto IN (SELECT TOP 10

				i3.item_producto

	FROM Factura f3

	JOIN Item_Factura i3 ON f3.fact_sucursal = i3.item_sucursal AND

											f3.fact_numero = i3.item_numero AND
	
											f3.fact_tipo = i3.item_tipo
	
	WHERE YEAR(f3.fact_fecha) = 2012
	
	GROUP BY i3.item_producto
	
	ORDER BY SUM(i3.item_cantidad) DESC))
		THEN 'Si'
			ELSE 'No'
	END) AS Es_Cliente_de_los_más_Vendidos,
	(SELECT
		COUNT(*)
	FROM Factura f2
	WHERE f2.fact_cliente = f.fact_cliente) AS Cant_de_Facturas
FROM Factura f
JOIN Cliente c ON f.fact_cliente = c.clie_codigo
JOIN Item_Factura i ON f.fact_sucursal = i.item_sucursal AND
							f.fact_numero = i.item_numero AND
									f.fact_tipo = i.item_tipo
WHERE EXISTS (SELECT TOP 10
						1
				FROM Factura f2
				JOIN Item_Factura i2 ON f2.fact_sucursal = i2.item_sucursal AND
														f2.fact_numero =
i2.item_numero AND
														f2.fact_tipo = i2.item_tipo
				WHERE f2.fact_cliente = f.fact_cliente AND
					i2.item_producto IN (SELECT TOP 10

i3.item_producto

																	FROM Factura f3
																	JOIN
Item_Factura i3 ON f3.fact_sucursal = i3.item_sucursal AND

							f3.fact_numero = i3.item_numero AND

							f3.fact_tipo = i3.item_tipo
																	WHERE
YEAR(f3.fact_fecha) = 2012
																	GROUP BY
i3.item_producto
																	ORDER BY
SUM(i3.item_cantidad) DESC) OR
								i2.item_producto IN (SELECT TOP 10
i3.item_producto
																	FROM Factura f3
																	JOIN
Item_Factura i3 ON f3.fact_sucursal = i3.item_sucursal AND

							f3.fact_numero = i3.item_numero AND

							f3.fact_tipo = i3.item_tipo
																	WHERE
YEAR(f3.fact_fecha) = 2012
																	GROUP BY
i3.item_producto
																	ORDER BY
SUM(i3.item_cantidad) ASC))

GROUP BY f.fact_cliente, c.clie_razon_social
ORDER BY SUM(i.item_precio * i.item_cantidad) DESC
*/

/*
2.Se desea crear una vista denominada v_item_factura que permita visualizar, para 
cada ítem de una factura, la identificación de la factura, el nombre del producto, el 
precio unitario, la cantidad y el total correspondiente a ese ítem.

Sin embargo, se solicita eliminar fisicamente los campos item_precio e item_total de 
la tabla item_factura, ya que se considera que dichos valores no deben almacenarse 
más en esa tabla. Además, no está permitido agregar nuevos campos 
a item_factura.

¿Qué debería implementarse para que la vista v_item_factura pueda mostrar en 
todo momento la información requerida, tanto para los datos actuales como para los 
futuros?
*/

/*
	19484 items facturas y sus facturas
*/

-- Incompleto y mal (creo)
go
create view v_item_factura
as
select
	rtrim(f.fact_tipo) + ' ' + rtrim(f.fact_sucursal) + ' ' + rtrim(f.fact_numero) as Id_factura,
	p.prod_detalle as Nombre_prod,
	i.item_precio as Precio_unit, -- chau
	i.item_cantidad as Cantidad,
	i.item_cantidad * i.item_precio as Total -- chau?
from Item_Factura i
join Factura f on
	f.fact_tipo+f.fact_sucursal+f.fact_numero = i.item_tipo+i.item_sucursal+i.item_numero
join Producto p on
	p.prod_codigo = i.item_producto
go

/*
SOL: UTNIANOS 10

-- Creo la nueva tabla para guardar item_precio e item_total
CREATE TABLE Item_Factura_Precio (
	item_precio_producto CHAR(8),
	item_precio_tipo CHAR(1),
	item_precio_sucursal CHAR(4),
	item_precio_numero CHAR(8),
	item_precio_precio DECIMAL(12,2),
	item_precio_total DECIMAL(12,2)

	FOREIGN KEY(item_precio_producto) REFERENCES Producto(prod_codigo),
	FOREIGN KEY(item_precio_tipo, item_precio_sucursal, item_precio_numero)
	REFERENCES Factura(fact_tipo, fact_sucursal, fact_numero)
)

-- Procedure para cargar la nueva tabla con los datos actuales
CREATE PROCEDURE sp_Cargar_Item_Factura_Precio
AS
BEGIN
	INSERT INTO Item_Factura_Precio (item_precio_producto,
		item_precio_tipo,
		item_precio_sucursal,
		item_precio_numero,
		item_precio_precio,
		item_precio_total)	
	SELECT
		item_producto,
		item_tipo,
		item_sucursal,
		item_numero,
		item_precio,
		item_precio * item_cantidad
	FROM Item_Factura
END

-- Cargo la nueva tabla
EXEC sp_Cargar_Item_Factura_Precio

-- Elimino el campo item_precio
ALTER TABLE Item_Factura DROP COLUMN item_precio

-- Trigger para cargar datos a futuro
CREATE TRIGGER tr_Cargar_Item_Factura_Precio
ON Item_Factura
AFTER INSERT
AS
BEGIN
	INSERT INTO Item_Factura_Precio (item_precio_producto,
		item_precio_tipo,
		item_precio_sucursal,
		item_precio_numero,
		item_precio_precio,
		item_precio_total)
	SELECT
		i.item_producto,
		i.item_tipo,
		i.item_sucursal,
		i.item_numero,
		p.prod_precio,
		p.prod_precio * i.item_cantidad
	FROM inserted i
	JOIN Producto p
		ON i.item_producto = p.prod_codigo
END

-- Creo la vista con los datos actuales y los futuros que se insertar n en la nueva tabla
CREATE VIEW v_item_factura
AS
SELECT
	CONCAT(i.item_numero, '-', i.item_sucursal, '-', i.item_tipo) AS id_Factura,
	p.prod_detalle AS nombre,
	ifp.item_precio_precio AS precio_unitario,
	i.item_cantidad AS cantidad,
	ifp.item_precio_total AS total
FROM Item_Factura i
JOIN Producto p
	ON i.item_producto = p.prod_codigo
JOIN Item_Factura_Precio ifp
	ON ifp.item_precio_tipo = i.item_tipo
	AND ifp.item_precio_sucursal = i.item_sucursal
	AND ifp.item_precio_numero = i.item_numero
	AND ifp.item_precio_producto = i.item_producto
GROUP BY CONCAT(i.item_numero, '-', i.item_sucursal, '-', i.item_tipo),
			p.prod_detalle, ifp.item_precio_precio, i.item_cantidad, ifp.item_precio_total
*/

-- Parcial Martes 15/11/2022

/*
1. Realizar una consulla SQL que permita saber los clientes que 
compraron todos los rubros disponibles del sistema en el 2012.

De estos clientes mostrar, siempre para el 2012:

	1. El código del cliente 
	2. Codigo de producto que en cantidades más compro. 
	3. El nombre del producto del punto 3. 
	4. Cantidad de productos distintos comprados por el 
	   cliente. 
	5. Cantidad de productos con composición comprados 
	   por el cliente.

El resultado deberá ser ordenado por razón social del cliente 
alfabéticamente primero y luego, los clientes que compraron entre un 
20 % y 30% del total facturado en el 2012 primero, luego, los restantes.

Nota: No se permiten select en el from, es decir, select ... from (select ...) as T,...
*/

/*
	31 rubros

	3000 facturas

	2683 facturas en 2012

	66 clientes compraron, o tienen facturas, en 2012
*/

-- Este en teoria esta bien
select
	f.fact_cliente as Codigo_Cliente,
	(select top 1
		item_producto
	from Factura
	join Item_Factura on
		item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero
	where
		fact_cliente = f.fact_cliente and
		year(fact_fecha) = 2012
	group by
		item_producto
	order by
		sum(item_cantidad) desc) as Cod_Prod_Mas_Compro,
	(select top 1
		prod_detalle
	from Factura
	join Item_Factura on
		item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero
	join Producto on
		prod_codigo = item_producto
	where
		fact_cliente = f.fact_cliente and
		year(fact_fecha) = 2012
	group by
		item_producto,
		prod_detalle
	order by
		sum(item_cantidad) desc) as Nombre_Prod_Mas_Compro,
	count(distinct i.item_producto) as Cant_Prod_Distintos,
	count(distinct c.comp_producto) as Cant_Prod_Comp_Comprados
from Factura f
join Item_Factura i on
	i.item_tipo+i.item_sucursal+i.item_numero = f.fact_tipo+f.fact_sucursal+f.fact_numero
join Producto p on
	p.prod_codigo = i.item_producto
left join Composicion c on
	c.comp_producto = p.prod_codigo
join Cliente cli on
	cli.clie_codigo = f.fact_cliente
where
	year(f.fact_fecha) = 2012
group by
	f.fact_cliente,
	cli.clie_razon_social
having
	count(distinct p.prod_rubro) = 
		(select
			count(*)
		from Rubro)
order by
	clie_razon_social,
	case when
		(select
			sum(fact_total)
		from Factura
		where
			fact_cliente = f.fact_cliente and
			year(fact_fecha) = 2012) >
				20 * (select
					sum(fact_total)
				from Factura
				where
					year(fact_fecha) = 2012) / 100 and
		(select
				sum(fact_total)
			from Factura
			where
				fact_cliente = f.fact_cliente and
				year(fact_fecha) = 2012) <
					30 * (select
						sum(fact_total)
					from Factura
					where
						year(fact_fecha) = 2012) / 100
	then
		1
	else
		0
	end

-- Total rubros
select
	rubr_id
from Rubro

-- Total facturado en 2012
select
	sum(fact_total)
from Factura
where
	year(fact_fecha) = 2012

/*
2. Implementar una regla de negocio en linea que al realizar una venta 
(SOLO INSERCION) permita componer los productos descompuestos, 
es decir, si se guardan en la factura 2 hamb. 2 papas 2 gaseosas se 
deberá guardar en la factura 2 (DOS) COMBO1. Si 1 combo1 equivale 
a: 1 hamb. 1 papa y 1 gaseosa.

Nota: Considerar que cada vez que se guardan los items, se mandan 
todos los productos de ese item a la vez, y no de manera parcial
*/

-- Este es el 6 de la guia realmente, preguntar en el parcial si toca algo similar
go
create procedure ej222
as
begin transaction
	declare @fact_tipo char(1)
	declare @fact_sucursal char(4)
	declare @fact_numero char(8)

	declare @combo char(8)
	declare @combo_cant decimal(12,2)

	-- Cursor para recorrer facturas
	declare cFactura cursor for
	select
		fact_tipo,
		fact_sucursal,
		fact_numero
	from Factura

	open cFactura

	fetch next from cFactura into
		@fact_tipo,
		@fact_sucursal,
		@fact_numero

	while @@FETCH_STATUS = 0
	begin

		declare cCombo cursor for
		-- Esto devuelve solo los combos que se pueden armar
		select
			c.comp_producto
		from Item_Factura
		join Composicion c on
			c.comp_componente = item_producto
		where
			item_tipo+item_sucursal+item_numero = @fact_tipo+@fact_sucursal+@fact_numero and
			item_cantidad >= c.comp_cantidad
		group by
			c.comp_producto
		having
			count(*) = 
				(select
					count(*)
				from Composicion
				where
					comp_producto = c.comp_producto)

		open cCombo

		fetch next from cCombo into @combo

		while @@FETCH_STATUS = 0
		begin
			-- Primero hay que calcular la cantidad minima que se puede armar del combo
			select
				@combo_cant = min(floor(item_cantidad/comp_cantidad))
			from Item_Factura
			join Composicion on
				comp_componente = item_producto
			where
				item_tipo+item_sucursal+item_numero = @fact_tipo+@fact_sucursal+@fact_numero and
				comp_producto = @combo

			-- Insertamos el combo
			insert into Item_Factura 
				(
					item_tipo, 
					item_sucursal, 
					item_numero,
					item_producto,
					item_cantidad,
					item_precio
				)
			values
				(
					@fact_tipo,
					@fact_sucursal,
					@fact_numero,
					@combo,
					@combo_cant,
					(select
						prod_precio
					from Producto
					where
						prod_codigo = @combo)
				)

			-- Restamos la cantidad a los items que conformaron el combo
			update Item_Factura
			set
				item_cantidad = item_cantidad - @combo_cant * comp_cantidad
			from Item_Factura i
			join Composicion on
				comp_componente = i.item_producto
			where
				i.item_tipo+i.item_sucursal+i.item_numero = @fact_tipo+@fact_sucursal+@fact_numero and
				comp_producto = @combo 

			-- Borramos los que su cantidad sea 0
			delete from Item_Factura
			where
				item_tipo+item_sucursal+item_numero = @fact_tipo+@fact_sucursal+@fact_numero and
				item_cantidad = 0

			fetch next from cCombo into @combo
		end

		close cCombo
		deallocate cCombo
		
		fetch next from cFactura into
			@fact_tipo,
			@fact_sucursal,
			@fact_numero
	end

	close cFactura
	deallocate cFactura

	return
commit
go

/*
	Que es lo que deberia hacer?
	De los que se insertan ver que combos puedo hacer
	Armar combo a combo e insertarlo hasta que no se pueda mas
	Lo sobrante se inserta tal cual.
*/

-- Parcial Sabado 12/11/2022

/*
1. Realizar una consulta SQL que permita saber los clientes que 
compraron por encima del promedio de compras (fact_total) de todos 
los clientes del 2012.

De estos clientes mostrar para el 2012:

	1. El código del cliente 
	2. La razón social del cliente 
	3. Código de producto que en cantidades más compro 
	4. El nombre del producto del punto 3. 
	5. Cantidad de productos distintos comprados por el 
	   cliente. 
	6. Cantidad de productos con composición comprados 
	   por el cliente.

El resultado deberá ser ordenado poniendo primero aquellos clientes 
que compraron más de entre 5 y 10 productos distintos en el 2012.

Nota: No se permiten select en el from, es decir, select ... from (select ...) as T,...
*/

/*
	62 clientes en total cumplen
*/

-- Este en teoria esta bien
select
	f.fact_cliente,
	c.clie_razon_social,
	(select top 1
		item_producto
	from Factura
	join Item_Factura on
		item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero
	where
		year(fact_fecha) = 2012 and
		fact_cliente = f.fact_cliente
	group by
		item_producto
	order by
		sum(item_cantidad) desc),
	(select top 1
		prod_detalle
	from Factura
	join Item_Factura on
		item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero
	join Producto on
		prod_codigo = item_producto
	where
		year(fact_fecha) = 2012 and
		fact_cliente = f.fact_cliente
	group by
		item_producto,
		prod_detalle
	order by
		sum(item_cantidad) desc),
	count(distinct i.item_producto),
	(select
		count(distinct comp_producto)
	from Factura
	join Item_Factura on
		item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero
	join Composicion on
		comp_producto = item_producto
	where
		year(fact_fecha) = 2012 and
		fact_cliente = f.fact_cliente)
from Factura f
join Cliente c on
	c.clie_codigo = f.fact_cliente
join Item_Factura i on
	i.item_tipo+i.item_sucursal+i.item_numero = f.fact_tipo+f.fact_sucursal+f.fact_numero
where
	year(f.fact_fecha) = 2012
group by
	f.fact_cliente,
	c.clie_razon_social
having
	sum(i.item_cantidad * i.item_precio) >
		(select
			avg(fact_total)
		from Factura
		where
			year(fact_fecha) = 2012)
order by
	(case when
		count(distinct i.item_producto) between 5 and 10
	then
		1
	else
		0
	end) desc

select
	avg(fact_total)
from Factura
where
	year(fact_fecha) = 2012

/*
SOL: Utnianos 9
select f.fact_cliente,
	c.clie_razon_social,
	(select top 1 i2.item_producto
	from Item_Factura i2
	join Factura f2 on f2.fact_tipo+f2.fact_sucursal+f2.fact_numero =
	i2.item_tipo+i2.item_sucursal+i2.item_numero and f2.fact_cliente=f.fact_cliente
	where year(f2.fact_fecha)=2012
	group by i2.item_producto
	order by sum(i2.item_cantidad) desc) as 'Cod_Producto_Mas_Comprado',
	
	(select top 1 p.prod_detalle
	from Item_Factura i2
	join Factura f2 on f2.fact_tipo+f2.fact_sucursal+f2.fact_numero =
	i2.item_tipo+i2.item_sucursal+i2.item_numero and f2.fact_cliente=f.fact_cliente
	join Producto p on p.prod_codigo=i2.item_producto
	where year(f2.fact_fecha)=2012
	group by i2.item_producto, p.prod_detalle
	order by sum(i2.item_cantidad) desc) as 'Producto_Mas_Comprado',

	count(distinct i.item_producto) as 'Productos_Distintos_Comprados',

	(select isnull(sum(i2.item_cantidad),0)
	from Item_Factura i2
	join Factura f2 on f2.fact_tipo+f2.fact_sucursal+f2.fact_numero =
	i2.item_tipo+i2.item_sucursal+i2.item_numero and f2.fact_cliente=f.fact_cliente
	where year(f2.fact_fecha)=2012 and i2.item_producto in (select
	c.comp_producto from Composicion c))

from Factura f
join Cliente c on f.fact_cliente=c.clie_codigo
join Item_Factura i on f.fact_tipo+f.fact_sucursal+f.fact_numero =
i.item_tipo+i.item_sucursal+i.item_numero
where year(f.fact_fecha)=2012
group by f.fact_cliente, c.clie_razon_social
having sum(i.item_cantidad*i.item_precio) > (select avg(f2.fact_total)
										from Factura f2
										where year(f2.fact_fecha)=2012
										)
order by case when count(distinct i.item_producto) between 5 and 10 then 1 else 0 end desc
*/

/*
2. Implementar una regla de negocio de validación en línea que permita 
validar el STOCK al realizarse una venta. Cada venta se debe 
descontar sobre el depósito 00. En caso de que se venda un producto 
compuesto, el descuento de stock se debe realizar por sus 
componentes. Si no hay STOCK para ese articulo, no se deberá 
guardar ese artículo, pero si los otros en los cuales hay stock positivo. 
Es decir, solamente se deberán guardar aquellos para los cuales si hay 
stock, sin guardarse los que no poseen cantidades suficientes.
*/

go
create trigger ej2 on Item_Factura
instead of insert
as
begin transaction
	set transaction isolation level serializable -- agregado extra

	declare @item_tipo char(1)
	declare @item_sucursal char(4)
	declare @item_numero char(8)
	declare @producto char(8)
	declare @cantidad decimal(12,2)
	declare @cant_stock decimal(12,2)
	declare @precio decimal(12,2)

	-- Para caso de producto compuesto 
	declare @cant_min_fabricable decimal(12,2)

	declare cItems cursor for
	select
		item_tipo,
		item_sucursal,
		item_numero,
		item_producto,
		item_cantidad,
		item_precio
	from inserted

	open cItems

	fetch next from cItems into 
		@item_tipo,
		@item_sucursal,
		@item_numero,
		@producto, 
		@cantidad,
		@precio
	
	while @@FETCH_STATUS = 0
	begin
		if (dbo.esCompuesto(@producto) = 1)
		begin
			select
				@cant_min_fabricable = min(floor(stoc_cantidad/comp_cantidad))
			from Composicion
			join STOCK on
				stoc_producto = comp_componente
			where 
				comp_producto = @producto and
				stoc_deposito = '00'

			if (@cant_min_fabricable >= @cantidad)
			begin
				update STOCK
				set
					stoc_cantidad = stoc_cantidad - @cantidad * comp_cantidad
				from STOCK
				join Composicion on
					comp_componente = stoc_producto
				where
					comp_producto = @producto and
					stoc_deposito = '00'

				insert into Item_Factura
					(
						item_tipo,
						item_sucursal,
						item_numero,
						item_producto,
						item_cantidad,
						item_precio
					)
				values
					(
						@item_tipo,
						@item_sucursal,
						@item_numero,
						@producto,
						@cantidad,
						@precio
					)
			end
		end

		else
		begin
			select 
				@cant_stock = stoc_cantidad
			from STOCK 
			where
				stoc_producto = @producto and
				stoc_deposito = '00'

			if (@cant_stock >= @cantidad)
			begin
				update STOCK
				set
					stoc_cantidad = stoc_cantidad - @cantidad
				where
					stoc_producto = @producto and
					stoc_deposito = '00'

				insert into Item_Factura
					(
						item_tipo,
						item_sucursal,
						item_numero,
						item_producto,
						item_cantidad,
						item_precio
					)
				values
					(
						@item_tipo,
						@item_sucursal,
						@item_numero,
						@producto,
						@cantidad,
						@precio
					)
			end
		end

		fetch next from cItems into 
			@item_tipo,
			@item_sucursal,
			@item_numero,
			@producto, 
			@cantidad,
			@precio
	end

	close cItems
	deallocate cItems

	return
commit

go
create function esCompuesto(@producto char(8))
returns int
as
begin
	if (
			(select
				count(*)
			from Composicion
			where
				comp_producto = @producto) > 0
		)
	begin
		return 1
	end

	return 0
end
go

select prod_codigo, dbo.esCompuesto(prod_codigo) from Producto

select comp_producto, dbo.esCompuesto(comp_producto) from Composicion

/*
SOL: UTNIANOS 8
ALTER TABLE STOCK ADD CONSTRAINT const_stock_positivo CHECK (stoc_cantidad >=
0)

CREATE OR ALTER TRIGGER tr_descontar_stock ON dbo.Item_Factura INSTEAD OF
INSERT
AS
	SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
	-- Variables
	DECLARE @producto char(8), @cantidad_vendida decimal(12,2), @componente
char(8), @cantidad_componente decimal(12,2)

	-- Cursor
	DECLARE cursor_producto CURSOR FOR
		SELECT i.item_producto, SUM(i.item_cantidad)
		FROM INSERTED i
		GROUP BY i.item_producto

	OPEN cursor_producto
	FETCH cursor_producto INTO @producto, @cantidad_vendida

	WHILE @@FETCH_STATUS = 0
	BEGIN
		-- Si no es compuesto, descuento sobre el producto original
		IF NOT EXISTS (SELECT 1 FROM Composicion c WHERE c.comp_producto
= @producto)
		BEGIN
			UPDATE STOCK SET stoc_cantidad = stoc_cantidad -
@cantidad_vendida WHERE stoc_deposito = '00' AND stoc_producto = @producto
			IF @@ERROR != 0
			BEGIN
				PRINT(CONCAT('EL PRODUCTO ',
@producto, 'YA NO TIENE STOCK'))
			END
			ELSE
			BEGIN
				INSERT INTO
GD2C2022PRACTICA.dbo.Item_Factura
				(item_tipo, item_sucursal, item_numero,
item_producto, item_cantidad, item_precio)
				SELECT item_tipo, item_sucursal,
item_numero, item_producto, item_cantidad, item_precio
				FROM INSERTED WHERE item_producto =
@producto
			END
		END

		-- Si es compuesto itero y descuento sobre los componentes
		DECLARE cursor_componente CURSOR FOR
			SELECT comp_componente, comp_cantidad
			FROM Composicion
			WHERE comp_producto = @producto

		OPEN cursor_componente
		FETCH cursor_componente INTO @componente, @cantidad_componente

		WHILE @@FETCH_STATUS = 0
		BEGIN
			UPDATE STOCK SET stoc_cantidad = stoc_cantidad -
@cantidad_vendida * @cantidad_componente WHERE stoc_deposito = '00' AND
stoc_producto = @componente
			IF @@ERROR != 0
			BEGIN
				PRINT(CONCAT('EL PRODUCTO ', @componente,
'YA NO TIENE STOCK'))
			END
			ELSE
			BEGIN
				INSERT INTO Item_Factura
				(item_tipo, item_sucursal, item_numero, item_producto,
item_cantidad, item_precio)
				SELECT item_tipo, item_sucursal, item_numero,
item_producto, item_cantidad, item_precio
				FROM INSERTED WHERE item_producto =
@componente
			END
			
			FETCH cursor_componente INTO
@componente,@cantidad_componente
		END
		CLOSE cursor_componente
		DEALLOCATE cursor_componente

		FETCH cursor_producto INTO @producto,@cantidad_vendida
	END
	
	CLOSE cursor_producto
	DEALLOCATE cursor_producto
GO
*/

-- Parcial Recu Sabados 19/11/2022

/*
1. Realizar una consulta SQL que permita saber los clientes que 
compraron en el 2012 al menos 1 unidad de todos los productos 
compuestos.

De estos clientes mostrar, siempre para el 2012:
	
	1. El código del cliente 
	2. Código de producto que en cantidades más compro. 
	3. El número de fila según el orden establecido con un 
	   alias llamado ORDINAL 
	4. Cantidad de productos distintos comprados por el 
	   cliente. 
	5. Monto total comprado.

El resultado deberá ser ordenado por razón social del cliente 
alfabéticamente primero y luego, los clientes que compraron entre un 
20 % y 30% del total facturado en el 2012 primero, luego, los restantes.

Nota: No se permiten select en el from, es decir, select ... from (select ..) as T,...
*/

/*
	2693 facturas en 2012

	66 clientes en 2012 (numero verificado)

	23 clientes en 2012 tienen por lo menos 1 item factura donde se compra un compuesto

	6 productos compuestos en total

	Ningun cliente en 2012 compro todos los compuestos


*/

-- Este en teoria esta bien
select
	f.fact_cliente,
	(select top 1
		item_producto
	from Factura
	join Item_Factura on
		item_tipo = fact_tipo and
		item_sucursal = fact_sucursal and
		item_numero = fact_numero
	where
		year(fact_fecha) = 2012 and
		fact_cliente = f.fact_cliente
	group by
		item_producto
	order by
		sum(item_cantidad) desc) as Prod_Mas_Compro,
	row_number() over (order by 
							cli.clie_razon_social,
							case when
								(select
									sum(fact_total)
								from Factura
								where
									year(fact_fecha) = 2012 and
									fact_cliente = f.fact_cliente) between
									(select
										sum(fact_total)
									from Factura
									where
										year(fact_fecha) = 2012) * 20/100 and
									(select
										sum(fact_total)
									from Factura
									where
										year(fact_fecha) = 2012) * 30/100
							then
								1
							else
								0
							end desc) as ORDINAL,
	(select
		count(distinct item_producto)
	from Factura
	join Item_Factura on
		item_tipo = fact_tipo and
		item_sucursal = fact_sucursal and
		item_numero = fact_numero
	where
		year(fact_fecha) = 2012 and
		fact_cliente = f.fact_cliente) as Cant_Prod_Dist,
	(select
		sum(fact_total)
	from Factura
	where
		year(fact_fecha) = 2012 and
		fact_cliente = f.fact_cliente) as Monto_Total
from Factura f
join Cliente cli on
	cli.clie_codigo = f.fact_cliente
join Item_Factura i on
	i.item_tipo = f.fact_tipo and
	i.item_sucursal = f.fact_sucursal and
	i.item_numero = f.fact_numero
join Composicion c on
	c.comp_producto = i.item_producto
where
	year(f.fact_fecha) = 2012
group by
	f.fact_cliente,
	clie_razon_social
having
	count(distinct c.comp_producto) = 
		(select
			count(distinct comp_producto)
		from Composicion)
order by
	ORDINAL
	/*
	cli.clie_razon_social,
	case when
		(select
			sum(fact_total)
		from Factura
		where
			year(fact_fecha) = 2012 and
			fact_cliente = f.fact_cliente) between
			(select
				sum(fact_total)
			from Factura
			where
				year(fact_fecha) = 2012) * 20/100 and
			(select
				sum(fact_total)
			from Factura
			where
				year(fact_fecha) = 2012) * 30/100
	then
		1
	else
		0
	end desc
	*/

select * from Factura

select clie_razon_social from Cliente order by clie_razon_social

/*
2. Implementar una regla de negocio en linea donde nunca una factura 
nueva tenga un precio de producto distinto al que figura en la tabla 
PRODUCTO. Registrar en una estructura adicional todos los casos 
donde se intenta guardar un precio distinto.
*/

create table Item_Factura_Precio_Diferido (
	item_tipo char(1),
	item_sucursal char(4),
	item_numero char(8),
	item_producto char(8),
	item_cantidad decimal(12,2),
	item_item_precio decimal(12,2),
	item_prod_precio decimal (12,2)

	constraint PK_Item_Factura_Precio_Diferido
	primary key
		(
			item_tipo,
			item_sucursal,
			item_numero,
			item_producto
		),
	
	constraint FK_Item_Factura_Precio_Diferido_Factura
	foreign key
		(
			item_tipo,
			item_sucursal,
			item_numero
		)
		references 
			Factura(
				fact_tipo,
				fact_sucursal,
				fact_numero
			),

	constraint FK_Item_Factura_Precio_Diferido_Producto
	foreign key
		(	
			item_producto
		)
		references
			Producto(
				prod_codigo
			)
)

go
create trigger ej2 on Item_Factura
instead of insert
as
begin transaction
	declare @item_tipo char(1)
	declare @item_sucursal char(4)
	declare @item_numero char(8)
	declare @producto char(8)
	declare @cantidad decimal(12,2)
	declare @precio_item decimal(12,2)
	declare @precio_real decimal(12,2)

	declare cItems cursor for
	select
		item_tipo,
		item_sucursal,
		item_numero,
		item_producto,
		item_cantidad,
		item_precio
	from inserted

	open cItems

	fetch next from cItems into
		@item_tipo,
		@item_sucursal,
		@item_numero,
		@producto,
		@cantidad,
		@precio_item

	while @@FETCH_STATUS = 0
	begin
		select
			@precio_real = prod_precio
		from Producto
		where
			prod_codigo = @producto

		if (@precio_real = @precio_item)
		begin
			insert into Item_Factura
				(
					item_tipo,
					item_sucursal,
					item_numero,
					item_producto,
					item_cantidad,
					item_precio
				)
			values
				(
					@item_tipo,
					@item_sucursal,
					@item_numero,
					@producto,
					@cantidad,
					@precio_item
				)
		end

		else	
		begin
			insert into Item_Factura_Precio_Diferido
				(
					item_tipo,
					item_sucursal,
					item_numero,
					item_producto,
					item_cantidad,
					item_item_precio,
					item_prod_precio
				)
			values
				(
					@item_tipo,
					@item_sucursal,
					@item_numero,
					@producto,
					@cantidad,
					@precio_item,
					@precio_real
				)
		end

		fetch next from cItems into
		@item_tipo,
		@item_sucursal,
		@item_numero,
		@producto,
		@cantidad,
		@precio_item
	end

	close cItems
	deallocate cItems
		
	return
commit
go

/*
SOL: UTNIANOS 8
drop table carga_erronea_de_precios
create table carga_erronea_de_precios (
factura_tipo char(1),
factura_numero char(8),
factura_sucursal char(4),
producto char(8),
precio_distinto decimal(12,2),
constraint PK primary key(factura_tipo,factura_numero,factura_sucursal,producto) --
No sirve para update
)
alter trigger validar_precio_producto on Item_Factura
after insert -- No se contempla el caso de update de un item
as
begin
declare @factura_tipo char(1)
declare @factura_sucursal char(4)
declare @factura_numero char(8)
declare @producto char(8)
declare @precio_distinto decimal(12,2)
declare @precio_real decimal(12,2)
declare cursor_productos cursor for
select i.item_tipo,
i.item_numero, i.item_sucursal, i.item_producto, i.item_precio, p.prod_precio
from inserted i
join Producto p on
i.item_producto = p.prod_codigo
where
i.item_precio != p.prod_precio
open cursor_productos
fetch next from cursor_productos into @factura_tipo, @factura_numero,
@factura_sucursal, @producto, @precio_distinto, @precio_real
while @@fetch_status = 0
begin
insert into carga_erronea_de_precios (factura_tipo, factura_numero,
factura_sucursal, producto, precio_distinto) --EVALUAR UPDATE y CAMBIO EN FACT
TOTAL
values (@factura_tipo, @factura_numero, @factura_sucursal, @producto,
@precio_distinto)
-- Update el precio del item
update Item_Factura
set item_precio = @precio_real
where item_tipo+item_numero+item_sucursal =
@factura_tipo+@factura_numero+@factura_sucursal
and item_producto = @producto
-- No hay informacion suficiente para saber como la tabla Factura esta
calculando su total pero podria
-- ser de la siguiente manera
-- update Factura
-- set fact_total = (select sum(item_precio * item_cantidad) from Item_Factura
where item_tipo+item_numero+item_sucursal =
@factura_tipo+@factura_numero+@factura_sucursal)
-- where fact_tipo+fact_numero+fact_sucursal =
@factura_tipo+@factura_numero+@factura_sucursal
fetch next from cursor_productos into @factura_tipo, @factura_numero,
@factura_sucursal, @producto, @precio_distinto, @precio_real
end
close cursor_productos
deallocate cursor_productos
end
------------------------------------ Pruebas --------------------------------------------------
-- Prueba precio mal
insert into Item_Factura (item_tipo, item_sucursal, item_numero, item_producto,
item_cantidad, item_precio) values
('A', '0003', '00092444', '00000032', 6.00, 3.00)
select * from carga_erronea_de_precios
select *
from Item_Factura
where item_tipo = 'A'
and item_sucursal = '0003'
and item_numero = '00092444'
and item_producto = '00000032'
select *
from Producto
where prod_codigo = '00000032'
-- Prueba precio ok
insert into Item_Factura (item_tipo, item_sucursal, item_numero, item_producto,
item_cantidad, item_precio) values
('A', '0003', '00092444', '00000864', 6.00, 4.70)
select *
from Item_Factura
where item_tipo = 'A'
and item_sucursal = '0003'
and item_numero = '00092444'
and item_producto = '00000864
*/

/*
Simulacro mozzcuza

A partir del año 2027, se va a incorporar un nuevo punto de
venta con el código “28” para el depósito y “0028” para la 
factura. 

En dicho punto de venta, se necesita mantener información de 
los rangos de fecha donde cada producto tuvo un stock por 
debajo del punto de reposición sin alcanzar al valor 0 (cero) o 
negativo. 
Se sabe que al implementar, todos los productos en stock van a 
tener una cantidad por encima del punto de reposición. 

Implementar dicha funcionalidad creando al menos 1 nueva 
tabla y usando triggers para su actualización.
*/

/*
Sol 1:

CREATE TABLE HistorialStockBajo (
    id_historial INT IDENTITY(1,1) PRIMARY KEY,
    stoc_producto CHAR(8) NOT NULL,
    stoc_deposito CHAR(2) NOT NULL,
    fecha_desde DATE NOT NULL,
    fecha_hasta DATE NULL,
)
GO;

CREATE OR ALTER TRIGGER tr_historial_fechas_de_stock_bajo
ON STOCK
AFTER INSERT, UPDATE
AS
BEGIN
    DECLARE @Hoy DATE = CONVERT(DATE, GETDATE())

    UPDATE Historial 
    SET fecha_hasta = @Hoy
    FROM HistorialStockBajo Historial
        INNER JOIN deleted D ON
            D.stoc_producto = Historial.stoc_producto
            AND D.stoc_deposito = Historial.stoc_deposito
        INNER JOIN inserted I ON
            I.stoc_producto = Historial.stoc_producto
            AND I.stoc_deposito = Historial.stoc_deposito
    WHERE 
        Historial.fecha_hasta IS NULL
        AND D.stoc_deposito = '28'
        AND D.stoc_cantidad > 0
        AND D.stoc_cantidad < D.stoc_punto_reposicion
        AND (
            I.stoc_cantidad <= 0
            OR I.stoc_cantidad >= I.stoc_punto_reposicion
        )

    INSERT INTO HistorialStockBajo (
        stoc_producto,
        stoc_deposito,
        fecha_desde,
        fecha_hasta
    )
    SELECT
        I.stoc_producto,
        I.stoc_deposito,
        @Hoy,
        NULL
    FROM inserted I
        INNER JOIN deleted D ON
            D.stoc_producto = I.stoc_producto
            AND D.stoc_deposito = I.stoc_deposito
    WHERE 
        I.stoc_deposito = '28'
        AND I.stoc_cantidad > 0
        AND I.stoc_cantidad < I.stoc_punto_reposicion
        AND (
            D.stoc_producto IS NULL
            OR D.stoc_cantidad <= 0
            OR D.stoc_cantidad >= D.stoc_punto_reposicion
        )
        AND NOT EXISTS (
            SELECT 1
            FROM HistorialStockBajo Historial
            WHERE 
                Historial.stoc_producto = I.stoc_producto
                AND Historial.stoc_deposito = I.stoc_deposito
                AND Historial.fecha_hasta IS NULL
        )
END
*/

/*
Sol 2:

CREATE TABLE dbo.Metricas (
	metricas_producto     CHAR(8),
	metricas_deposito     CHAR(2),
	metricas_fecha_inicio SMALLDATETIME,
	metricas_fecha_fin    SMALLDATETIME
)
GO

CREATE OR ALTER TRIGGER dbo.lectura_stock
ON STOCK
FOR INSERT, UPDATE
AS
BEGIN
	DECLARE @producto CHAR(8)
	DECLARE @deposito CHAR(2)
	DECLARE @cantidad DECIMAL(12,2)
	DECLARE @minimo   DECIMAL(12,2)

	DECLARE recorrer_actualizaciones CURSOR FOR
		SELECT stock.stoc_producto,
		       stock.stoc_deposito,
		       stock.stoc_cantidad,
		       stock.stoc_punto_reposicion
		FROM inserted stock
		WHERE stoc_deposito = '28'

	OPEN recorrer_actualizaciones
	FETCH NEXT FROM recorrer_actualizaciones
	INTO @producto, @deposito, @cantidad, @minimo

	WHILE @@FETCH_STATUS = 0
	BEGIN
		UPDATE dbo.Metricas
		SET metricas_fecha_fin = GETDATE()
		WHERE metricas_deposito = @deposito
		  AND metricas_producto = @producto
		  AND metricas_fecha_fin IS NULL
		  AND @cantidad > @minimo

		IF @cantidad > 0 AND @cantidad < @minimo
		   AND NOT EXISTS (
				SELECT 1
				FROM dbo.Metricas
				WHERE metricas_producto = @producto
				  AND metricas_deposito = @deposito
				  AND metricas_fecha_fin IS NULL
		   )
		BEGIN
			INSERT INTO dbo.Metricas
			VALUES (@producto, @deposito, GETDATE(), NULL)
		END

		FETCH NEXT FROM recorrer_actualizaciones
		INTO @producto, @deposito, @cantidad, @minimo
	END

	CLOSE recorrer_actualizaciones
	DEALLOCATE recorrer_actualizaciones
END
GO
*/