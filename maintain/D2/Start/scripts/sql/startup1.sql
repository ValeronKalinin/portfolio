USE [master]
GO

DECLARE @ini nvarchar(max)

-- TODO: Set parameter values here.

EXECUTE [dbo].[sp_fortsGo_Init] 
   'C:\ReplP2\ska_agent\go_sql.ini'
GO


---------------------------------------------
USE [master]
GO

EXECUTE [dbo].[sp_fortsGo_OpenSeance] 
GO

----------------------------------------------
update FUTURES_HOPE..GO_setting set Started=0
set nocount on
go

select getdate()
declare @rc int, @TextOut varchar(255)
exec @rc = FUTURES_HOPE..GO_SetData @TextOut = @TextOut out, @type = 'STARTUP'
select @rc, @TextOut
select getdate()

--WAITFOR DELAY '00:00:30';

UPDATE FUTURES_HOPE..session set sost=0
where cleared = 0

--select * from FUTURES_HOPE..session
--update TestGO..P2ReplDbScheme set value = 0 where id = 1

--insert into FUTURES_HOPE.dbo.tp_user (n_user, d_n, d_k, grup, kod, prior1, lang, is_tm) values        ('ROBOTB', '2000-01-01', '2050-12-31', 6, '*******', 509, 0, 1)


