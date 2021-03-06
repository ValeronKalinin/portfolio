USE [master]
GO
/****** Object:  StoredProcedure [dbo].[SinglebaseRestore]    Script Date: 16.03.2020 10:38:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

ALTER PROCEDURE [dbo].[SinglebaseRestore]
@backup_path	varchar(200) ,
@basename	varchar(200) 
as
declare @SQL varchar(900)
declare @Singleuser varchar(900)
declare @MultiUser varchar(900)

declare @RC int
set @RC = 0

set @SQL='RESTORE DATABASE ' +@basename+  ' FROM  DISK = N'''++ @backup_path +
		@basename +'.bak'' '+
		' WITH  FILE = 1,  NOUNLOAD,  REPLACE,  STATS = 10'	
set @Singleuser='ALTER DATABASE '+@basename+ ' SET SINGLE_USER WITH ROLLBACK IMMEDIATE'
set @MultiUser=	'ALTER DATABASE '+@basename+ ' SET MULTI_USER'

	print 'Starting to restore database: '+ @basename
	execute(@Singleuser)
	execute(@SQL)
	set @RC = @@ERROR
	execute(@MultiUser)

	return @RC