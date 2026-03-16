--ALTER DATABASE mybudget ADD FILEGROUP Out1FG;
--ALTER DATABASE mybudget ADD FILEGROUP Out2FG;
--ALTER DATABASE mybudget ADD FILEGROUP Out3FG;
--ALTER DATABASE mybudget ADD FILEGROUP Out4FG;
--ALTER DATABASE mybudget ADD FILEGROUP Out5FG;
--ALTER DATABASE mybudget ADD FILEGROUP Out6FG;
--ALTER DATABASE mybudget ADD FILEGROUP Out7FG;
--ALTER DATABASE mybudget ADD FILEGROUP Out8FG;
--ALTER DATABASE mybudget ADD FILEGROUP Out9FG;
--ALTER DATABASE mybudget ADD FILEGROUP Out10FG;
--ALTER DATABASE mybudget ADD FILEGROUP Out11FG;
--ALTER DATABASE mybudget ADD FILEGROUP Out12FG;
--ALTER DATABASE mybudget ADD FILEGROUP OutDFFG;
--GO
--ALTER DATABASE mybudget ADD FILE ( 
--	FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL16.DEV\MSSQL\DATA\OutDFFG.ndf', 
--	NAME = OutDFFG, SIZE = 5MB,FILEGROWTH = 5MB ) TO FILEGROUP OutDFFG;

--ALTER DATABASE mybudget ADD FILE ( 
--	FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL16.DEV\MSSQL\DATA\Out1FG.ndf', 
--	NAME = Out1FG, SIZE = 5MB,FILEGROWTH = 5MB ) TO FILEGROUP Out1FG;

--ALTER DATABASE mybudget ADD FILE ( 
--	FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL16.DEV\MSSQL\DATA\Out2FG.ndf', 
--	NAME = Out2FG, SIZE = 5MB,FILEGROWTH = 5MB ) TO FILEGROUP Out2FG;

--ALTER DATABASE mybudget ADD FILE ( 
--	FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL16.DEV\MSSQL\DATA\Out3FG.ndf', 
--	NAME = Out3FG, SIZE = 5MB,FILEGROWTH = 5MB ) TO FILEGROUP Out3FG;

--ALTER DATABASE mybudget ADD FILE ( 
--	FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL16.DEV\MSSQL\DATA\Out4FG.ndf', 
--	NAME = Out4FG, SIZE = 5MB,FILEGROWTH = 5MB ) TO FILEGROUP Out4FG;

--ALTER DATABASE mybudget ADD FILE ( 
--	FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL16.DEV\MSSQL\DATA\Out5FG.ndf', 
--	NAME = Out5FG, SIZE = 5MB,FILEGROWTH = 5MB ) TO FILEGROUP Out5FG;

--ALTER DATABASE mybudget ADD FILE ( 
--	FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL16.DEV\MSSQL\DATA\Out6FG.ndf', 
--	NAME = Out6FG, SIZE = 5MB,FILEGROWTH = 5MB ) TO FILEGROUP Out6FG;

--ALTER DATABASE mybudget ADD FILE ( 
--	FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL16.DEV\MSSQL\DATA\Out7FG.ndf', 
--	NAME = Out7FG, SIZE = 5MB,FILEGROWTH = 5MB ) TO FILEGROUP Out7FG;

--ALTER DATABASE mybudget ADD FILE ( 
--	FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL16.DEV\MSSQL\DATA\Out8FG.ndf', 
--	NAME = Out8FG, SIZE = 5MB,FILEGROWTH = 5MB ) TO FILEGROUP Out8FG;

--ALTER DATABASE mybudget ADD FILE ( 
--	FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL16.DEV\MSSQL\DATA\Out9FG.ndf', 
--	NAME = Out9FG, SIZE = 5MB,FILEGROWTH = 5MB ) TO FILEGROUP Out9FG;

--ALTER DATABASE mybudget ADD FILE ( 
--	FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL16.DEV\MSSQL\DATA\Out10FG.ndf', 
--	NAME = Out10FG, SIZE = 5MB,FILEGROWTH = 5MB ) TO FILEGROUP Out10FG;

--ALTER DATABASE mybudget ADD FILE ( 
--	FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL16.DEV\MSSQL\DATA\Out11FG.ndf', 
--	NAME = Out11FG, SIZE = 5MB,FILEGROWTH = 5MB ) TO FILEGROUP Out11FG;

--ALTER DATABASE mybudget ADD FILE ( 
--	FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL16.DEV\MSSQL\DATA\Out12FG.ndf', 
--	NAME = Out12FG, SIZE = 5MB,FILEGROWTH = 5MB ) TO FILEGROUP Out12FG;



DECLARE @DatePartitionFunction nvarchar(max) = 
N'CREATE PARTITION FUNCTION Out_PF (date) 
AS RANGE RIGHT FOR VALUES (';  

DECLARE @DatePartitionScheme nvarchar(max) = 
N'CREATE PARTITION SCHEME Out_PS
AS PARTITION Out_PF TO (';  

declare @dt1 date = '2026-03-16';

with a as (
	select cast(@dt1 as date) dt, 1 as i, month(@dt1) m
	union all
	select cast(dateadd(dd, 1, a.dt) as date) dt, i+1 as i, month(a.dt) m from a
	where a.dt < dateadd(yy, 40, @dt1) --40 years
), sstr  as (
SELECT STRING_AGG(cast('''' + CONVERT(CHAR(10), dt, 120) + ''''as varchar(max)), ', ' ) AS func
	 , STRING_AGG('Out' + cast(m as varchar(max)) + 'FG', ', ' ) AS schm
FROM a
)
select	@DatePartitionFunction = @DatePartitionFunction + sstr.func + ');'
	,	@DatePartitionScheme = @DatePartitionScheme + sstr.schm + ', OutDFFG' + ');'
from sstr
OPTION (MAXRECURSION 0);

--select @DatePartitionFunction;
--select @DatePartitionScheme;
EXEC sp_executesql @DatePartitionFunction;  
EXEC sp_executesql @DatePartitionScheme;  
