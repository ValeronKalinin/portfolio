declare @bn varchar (20)
declare @rm varchar (20)
declare @SQL_make_simple varchar(900)

DECLARE @CURSOR CURSOR
SET @CURSOR  = CURSOR SCROLL
FOR

SELECT  name, recovery_model_desc
   FROM sys.databases 
   where /*recovery_model_desc != 'SIMPLE' and */name NOT IN ('master', 'model', 'tempdb', 'msdb', 'Resource')

/*Открываем курсор*/
OPEN @CURSOR

FETCH NEXT FROM @CURSOR INTO @bn,@rm
  
 WHILE @@FETCH_STATUS = 0
BEGIN


select @bn,@rm
if @rm != 'SIMPLE'
begin
 set @SQL_make_simple = 'USE [master] ; ALTER DATABASE ' + @bn + '  SET RECOVERY SIMPLE ; use['+ @bn+ '];' +
                     'declare @namelog varchar(40)
                     set @namelog =
                    (SELECT name FROM sys.database_files
                    where type_desc like ''LOG'')
                    print @namelog                   
                    DBCC SHRINKFILE (@namelog , 0, TRUNCATEONLY)'
	execute(@SQL_make_simple)
end
else 
begin
set @SQL_make_simple =  'use['+ @bn+ '];' +
                     'declare @namelog varchar(40)
                     set @namelog =
                    (SELECT name FROM sys.database_files
                    where type_desc like ''LOG'')
                    print @namelog                   
                    DBCC SHRINKFILE (@namelog , 0, TRUNCATEONLY)'
				
	execute(@SQL_make_simple)
end
FETCH NEXT FROM @CURSOR INTO @bn,@rm
END
CLOSE @CURSOR



