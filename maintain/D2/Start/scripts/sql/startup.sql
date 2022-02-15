declare @r int, @TextOut varchar(255)   
declare @ClearingDate datetime
select @ClearingDate = MAX(dat_open_day) from CLEARING.CLEARING_CLR.dbo.system where dat_open_day is not null
exec @r = FUTURES_HOPE..GO_SetData @TextOut = @TextOut out, @type = 'STARTUP'
select @r, @TextOut, @@trancount
select getdate()
DECLARE @return_value int
declare @SessId int = (select max(sess_id) from FUTURES_HOPE..session)
EXEC @return_value =FUTURES_HOPE.core.sp_fortsGo_Play
        @SessId = @SessId,
        @ClearingDate = @ClearingDate
SELECT  'PLAY return Value' = @return_value
update FUTURES_HOPE..session set sost = 0 where cleared = 0
--update OPTIONS_HOPE..session set sost = 0 where clearing = 0