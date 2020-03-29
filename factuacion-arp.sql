create database facturacion_arp
use facturacion_arp

exec sp_addtype cve_factura,'char(4)' --sp_addtype crea un tipo de dato y recibe el nombre y el tipo con su tamano
exec sp_addtype cve_cliente,'char(5)'
go

CREATE DEFAULT porcentaje_iva as 0.16 --La sentencia create default, crea un valor costante para una variable
go
create default pais as 'MEX'
go


create rule cve_cliente as --La sentencia create rule determina una regla de los valores aceptados que pueden ser insertados en una columna
@cve_cliente like '[a-z][0-9][0-9][0-9][0-9]'
go
create rule cve_factura as
@cve_factura like '[A-Z][A-Z][0-9][0-9]'
go
create rule valor_valido as
@valor_valido> 0
go




create table clientes_arp(
id_cliente cve_cliente not null, --Aqui le decimos que la variable id cliente sera de tipo cve cliente
nombre varchar(100) not null,
calle varchar(50),
numero int check(numero between 1 and 1000), --Esto se serciora de que los datos introducidos esten entre 1 y 1000
c_p varchar(5),
ciudad varchar(20),
estado varchar(4),
pais varchar(3)	check(pais in( 'MEX', 'USA', 'CAN')) --la sentencia check se serciora de que el valor introducido sea alguno de esos tres
)




create table facturas_arp (
id_factura cve_factura not null,
id_cliente cve_cliente not null,
descripcion varchar(100) not null,
importe money, --Es un tipo de dato que representa dinero (smallmoney son para cifras mas pequenas)
porc_iva float,
fecha datetime default getdate() --Esta funcion nos da la fecha y hora de la maquina que ejecuta
)



create table pagos_arp(
id_factura cve_factura not null,
id_pago int not null,
id_cliente cve_cliente not null,
importe money not null,
fecha_mov datetime
)


exec sp_bindefault porcentaje_iva,'facturas_arp.porc_iva' --el proceso almacenado sp_bindefault vincula un valor predeterminado a una columna o un tipo de dato de alias.
exec sp_bindefault pais,'clientes_arp.pais'

exec sp_bindrule cve_cliente,'clientes_arp.id_cliente' --sp_bindrule vincula una regla a una columna o un tipoo de dato de alias
exec sp_bindrule cve_factura,'facturas_arp.id_factura'
exec sp_bindrule cve_factura,'pagos_arp.id_factura'
exec sp_bindrule valor_valido,'facturas_arp.importe'
exec sp_bindrule valor_valido,'pagos_arp.importe'


alter table clientes_arp --alter es usado para anadir,borrar o modificar columnas de una tabla existente
add constraint pk_cli_id_cliente primary key (id_cliente) --add constraint se usa para crear una restriccion despues de que la tabla ya fue creada

alter table facturas_arp
add constraint pk_fac_cli primary key (id_factura,id_cliente)

alter table pagos_arp
add constraint pk_fac_pag primary key (id_factura,id_cliente,id_pago)


alter table facturas_arp
add constraint fk_facturas foreign key(id_cliente) references clientes_arp(id_cliente)
on delete cascade --on cascade delete significa que si el registro de la tabla padre es borrado, entonces los registros correspondientes en el hijo tambien se borran
on update cascade

alter table pagos_arp 
add constraint fk_pagos foreign key(id_factura,id_cliente) references facturas_arp(id_factura,id_cliente)
on delete cascade
on update cascade --significa que si el padre de la llave primaria es cambiado, el valor hijo tambien 


--INSERCIONES
   
use facturacion_arp

insert into clientes_arp(id_cliente,nombre,calle,numero,c_p,ciudad,estado)
values ('A0001','SIVESA','Pte.5',100,'54032','OR','VER')

insert into clientes_arp(id_cliente,nombre,calle,numero,c_p,ciudad,estado)
values ('A0002','APASCO','Cam.Nac.',999,'98765','IXT','VER')

insert into clientes_arp(id_cliente,nombre,calle,numero,c_p,ciudad,estado)
values ('B0001','TAMSA','Cam.Nac.',124,'9834','VER','VER')
	
insert into clientes_arp(id_cliente,nombre,calle,numero,c_p,ciudad,estado)
values ('C0001','VW','Calle 3',654,'67123','PUE','PUE')

insert into clientes_arp(id_cliente,nombre,calle,numero,c_p,ciudad,estado)
values ('E0002','SOFTEK','Av.Rev.',24,'65123','MEX','DF')

insert into clientes_arp(id_cliente,nombre,calle,numero,c_p,ciudad,estado)
values ('E0001','GUEDAS','Calle 2',876,'8965','PUE','PUE')

select * from clientes_arp



insert into facturas_arp(id_factura,id_cliente,descripcion,importe,porc_iva,fecha)
values ('FA01','A0001','Estimacion unica',5000,0.15,'1/1/2002')

insert into facturas_arp(id_factura,id_cliente,descripcion,importe,porc_iva,fecha)
values ('FA02','A0001','Transporte de Silice',15000,0.15,'1/5/2002')

insert into facturas_arp(id_factura,id_cliente,descripcion,importe,porc_iva,fecha)
values ('FB01','A0002','Pago de 10 ton.cemento',12500,0.15,'6/15/2002')

insert into facturas_arp(id_factura,id_cliente,descripcion,importe,porc_iva,fecha)
values ('FC01','B0001','Pago de 20 ton.de acero',50000,0.12,'8/15/2002')

insert into facturas_arp(id_factura,id_cliente,descripcion,importe,porc_iva,fecha)
values ('FE01','C0001','Compra de jetta 2002',225000,0.1,'5/30/2002')

insert into facturas_arp(id_factura,id_cliente,descripcion,importe,porc_iva,fecha)
values ('FD01','E0001','Pago de SW de inventarios',300000,0.12,'6/30/2002')

insert into facturas_arp(id_factura,id_cliente,descripcion,importe,porc_iva,fecha)
values ('FD02','E0002','Pago de SW de rec. humanos',25000,0.12,'7/30/2002')

select * from facturas_arp


insert into pagos_arp(id_factura,id_cliente,id_pago,importe,fecha_mov)
values ('FA01','A0001',1,3000,'2/1/2002')

insert into pagos_arp(id_factura,id_cliente,id_pago,importe,fecha_mov)
values ('FA02','A0001',2,10000,'1/15/2002')

insert into pagos_arp(id_factura,id_cliente,id_pago,importe,fecha_mov)
values ('FE01','C0001',3,150000,'6/15/2002')
insert into pagos_arp(id_factura,id_cliente,id_pago,importe,fecha_mov)
values ('FE01','C0001',4,50000,'6/30/2002')

insert into pagos_arp(id_factura,id_cliente,id_pago,importe,fecha_mov)
values ('FD01','E0001',5,100000,'7/15/2002')

insert into pagos_arp(id_factura,id_cliente,id_pago,importe,fecha_mov)
values ('FD01','E0001',6,125000,'7/30/2002')

insert into pagos_arp(id_factura,id_cliente,id_pago,importe,fecha_mov)
values ('FD02','E0002',7,50000,'7/15/2002')

insert into pagos_arp(id_factura,id_cliente,id_pago,importe,fecha_mov)
values ('FD02','E0002',8,75000,'7/20/2002')

insert into pagos_arp(id_factura,id_cliente,id_pago,importe,fecha_mov)
values ('FD02','E0002',9,100000,'7/30/2002')

--TAREA:
select * from pagos_arp
use facturacion_arp

select * from clientes_arp --Todos los datos de los clientes


select id_cliente, nombre from clientes_arp
where ciudad like 'OR'  --2.- La clave y nombre de clientes de la ciudad de Orizaba


--3.-El nombre, calle y número de los clientes del estado de Puebla
select nombre,calle,numero from clientes_arp
where estado like 'PUE'

--4.- El nombre y código postal de los clientes de la ciudad de Orizaba o Veracruz

select nombre,c_p from clientes_arp
where (ciudad = 'OR') OR (ciudad = 'VER')

--5.-Todos los datos de los clientes cuya clave empiecen con 'A'
select * from clientes_arp
where id_cliente like 'A%'

--6.- El nombre, ciudad y estado de los clientes, cuyo nombre empiece con 'S ' y q' sean del DF
select nombre,ciudad,estado from clientes_arp
where nombre like 'S%' and estado = 'DF'

select * from clientes_arp

--7.- El nombre de los clientes cuyo nombre contenga una 'A'
select nombre from clientes_arp
where nombre like '%A%'

--8.- El nombre d' los clientes cuyo nombre contenga una 'S 'y q' sean del estado de Veracruz
select nombre,estado from clientes_arp
where nombre like '%S%' and estado = 'VER'

--9.- El nombre d' los clientes, calle, numero y código postal cuyo numero sea mayor a 100
select nombre,calle,numero,c_p from clientes_arp
where numero>100

--10.- El nombre d' los clientes, calle y numero donde la calle contenga 'Cam'
select nombre,calle,numero from clientes_arp
where calle like '%Cam%'

--11.- Todas las facturas del cliente con clave ' A0001'
use facturacion_arp
select * from facturas_arp
where id_cliente like 'A0001'

--12.- Todas las facturas q' en su descripción empiece con 'pago'
select * from facturas_arp
where descripcion like 'pago%'

--13.- Todas las facturas q' en su descripción contenga 'SW'
select * from facturas_arp
where descripcion like '%SW%'

--14.- La clave d' factura, clave de cliente e importe d' las facturas donde el importe este entre 1 y 100000
select * from facturas_arp
select id_factura, id_cliente,importe from facturas_arp
where importe>1 and importe<100000

--15.- La clave d' factura, clave d' cliente e importe d' las facturas donde el importe sea mayor a 100000
select id_factura,id_cliente,importe from facturas_arp
where importe>100000

--16.- La clave d' factura, fecha e importe d' las facturas donde la fecha este en los primeros 3 meses del 2002
select id_factura,fecha,importe from facturas_arp
where fecha between '2002-01-01 00:00:00:00' and '2002-03-31 00:00:00:00'
select * from facturas_arp

--17.- Todos los datos d' las facturas con iva del 0.15
select * from facturas_arp
where porc_iva like '0.15'

--18.- Todos los datos d' las facturas con iva del 0.1 o 0.12
select * from facturas_arp
where porc_iva= 0.1 or porc_iva= 0.12

--19.- El número d' facturas q' se han elaborado (n)
select * from facturas_arp

select COUNT(*) as total
from facturas_arp

--20.- El número d' facturas q' se han elaborado (n) para el cliente con clave 'A0001'
select * from facturas_arp
select COUNT(id_cliente) as total from facturas_arp where id_cliente= 'A0001'

--21.- El número d' facturas q' se han elaborado (n) con porcentaje d' iva del 0.12
select COUNT(porc_iva) as total
from facturas_arp
where porc_iva= 0.12

--22.- El número d' facturas q' se han elaborado (n)  con porcentaje del iva del 0.1 o 0.15
select COUNT(porc_iva) as total
from facturas_arp
where porc_iva like 0.1 or porc_iva= 0.15

--23.- El importe d' la factura d' mayor costo
select importe from facturas_arp
order by importe desc

--24.- El importe d' la factura d' menor costo
select importe from facturas_arp
order by importe 

--25.- El importe promedio d' las facturas
select AVG(importe) as promedio from facturas_arp

--26.- El importe d' la factura d' mayor costo del cliente con clave 'C0001'
select * from facturas_arp

select importe from facturas_arp
where id_cliente = 'C0001'
order by importe

--27.- Todos los datos d' las facturas cuya clave contenga 'D'
select * from facturas_arp
select * from facturas_arp
where id_factura like '%D%'

--28.- Todos los datos d' los pagos con clave entre 1 y 5
select * from pagos_arp
where id_pago between '1' and '5'

--29.- Todos los datos d'  los pagos realizados a la factura con clave 'FD02'
select * from pagos_arp
where id_factura like 'FD02'

--30.- El importe del pago d' mayor costo d' los primeros 6 meses del año 2002
select MAX(importe) from facturas_arp
where fecha between '2002-01-01 00:00:00.000' and '2002-06-01 00:00:00.000'

select * from facturas_arp

--31.- El importe del pago del menor costo cuya fecha este en los últimos 6 meses del año 2002
select MIN(importe) from facturas_arp
where fecha between '2002-06-01 00:00:00.000' and '2002-12-01 00:00:00.000'

--32.- La clave d' factura, clave d' cliente e importe d' las facturas de importe mayor a 50000
select id_factura,id_cliente,importe from facturas_arp
where importe>50000

--33.- La clave d' factura, clave d' cliente e importe d' las facturas donde el importe este entre 1 y 150000
select id_factura,id_cliente,importe from facturas_arp
where importe between 1 and 150000

--34.- El número d' pagos (n) realizados mayores d' 100000
select COUNT(importe) as total from pagos_arp 
where importe>100000

select * from pagos_arp

--PRACTICA No.2
--use facturacion_arp

--1.- Todas las facturas realizadas en el segundo semestre del año 2002
select * from facturas_arp
select * from facturas_arp
where fecha between '2002-06-00 00:00:00.000' and '2002-12-31 00:00:00.000'

--2.- El número d' facturas realizadas en días hábiles (L a V) d' cualquier año --Datepart

select COUNT(DATEPART(DAY, '2002-01-01 00:00:00.000')) as resultado
from facturas_arp
select * from facturas_arp

--3.- El importe d' la factura d' mayos costo del primer trimestre del año 2002 
select MAX(importe) from facturas_arp
where fecha between '2002-01-01 00:00:00.000' and '2002-03-31 00:00:00.000'


--PRACTICA No 3

--1.- La clave del cliente y el numero d' facturas (n) q' se le han elaborado
select * from facturas_arp
select *from clientes_arp

select id_cliente, count(*) as numero_facturas from facturas_arp group by id_cliente

select id_factura,nombre, COUNT(*) from facturas_arp INNER JOIN clientes_arp WHERE (facturas_arp.id_factura=clientes_arp.nombre)
SELECT id_factura as numero_facturas, nombre, count(*) from facturas_arp JOIN clientes_arp ON id_factura = nombre



