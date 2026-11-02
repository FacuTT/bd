use GD2015C1

-- Parcial Martes 28/06/2025

-- 1

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

-- 2

/*
	19484 items facturas y sus facturas
*/

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

-- Parcial 15/11/2022

-- 1

/*
	31 rubros

	3000 facturas

	2683 facturas en 2012

	66 clientes compraron, o tienen facturas, en 2012
*/

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

-- 2

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
	62 clientes en total cumplen
*/

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

-- 2

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