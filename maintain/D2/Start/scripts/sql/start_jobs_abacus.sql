USE msdb ;  
GO  
  
EXEC dbo.sp_start_job N'JobAutoExtenLimit' ;  
EXEC dbo.sp_start_job N'Job_Start_Opt_ThPrice' ;  
--EXEC dbo.sp_start_job N'Job_Start_TuneVolat' ;  
EXEC dbo.sp_start_job N'JobFixClearingStarted' ;  
EXEC dbo.sp_start_job N'JobFixPrclResults' ;  
EXEC dbo.sp_start_job N'JobFixBaseGO' ;  
EXEC dbo.sp_start_job N'JobGOStart' ;  
EXEC dbo.sp_start_job N'JobLoadMarketData' ;  
EXEC dbo.sp_start_job N'JobMergeP2SynchroEventClrStarted' ;  
EXEC dbo.sp_start_job N'DBCC JobMergeP2Tables' ;  
EXEC dbo.sp_start_job N'JobNotifyFailPreLS' ;  
EXEC dbo.sp_start_job N'JobPRCLStart' ;  
EXEC dbo.sp_start_job N'JobRunTasks' ;  
-- EXEC dbo.sp_start_job N'JobSetVolat' ;  
EXEC dbo.sp_start_job N'JobProcessStartHalt' ;  
EXEC dbo.sp_start_job N'JobSetTradingHalts' ;  
EXEC dbo.sp_start_job N'JobSetProhibition' ;  
EXEC dbo.sp_start_job N'JobMergeP2SynchroEventClrStarted' ;  
EXEC dbo.sp_start_job N'JobMergeP2Tables' ;  

EXEC dbo.sp_start_job N'JobProcessCommandMessage'
EXEC dbo.sp_start_job N'JobProcessCommandMessage2'
EXEC dbo.sp_start_job N'JobProcessCommandMessage3'
EXEC dbo.sp_start_job N'JobProcessCommandMessage4'
EXEC dbo.sp_start_job N'JobProcessCommandMessage5'
EXEC dbo.sp_start_job N'JobProcessCommandMessage6'
EXEC dbo.sp_start_job N'JobProcessCommandMessage7'
EXEC dbo.sp_start_job N'JobProcessCommandMessage8'
EXEC dbo.sp_start_job N'JobProcessErrorMessage'

USE msdb ;  
GO  
UPDATE FUTURES_HOPE.dbo.remote_office
set  is_test=1 
--update [FUTURES_HOPE].[rpl_core_trades].[P2ReplDbScheme]
--set value =0  where name ='IntFUTTRADE_BIG_DELAY:term_IntFUTTRADE_BIG_DELAY' and "key" like 'lifenum'
--update [FUTURES_HOPE].[rpl_posbuild].[P2ReplDbScheme]
--set value =0  where name ='Filter1Pos:term_Filter1Pos' and "key" like 'lifenum'
--update [FUTURES_HOPE].[rpl_postls].[P2ReplDbScheme]
--set value =0  where name ='Filter1Part:term_Filter1Part' and "key" like 'lifenum'
--update [OPTIONS_HOPE].[rpl_volat].[P2ReplDbScheme]
--set value =0  where name ='IntVOLATBLACK:term_IntVOLATBLACK' and "key" like 'lifenum'
--update [OPTIONS_HOPE].[rpl_volat].[P2ReplDbScheme]
--set value =0  where name ='IntVOLATBACH:term_IntVOLATBACH' and "key" like 'lifenum'
--UPDATE  [FUTURES_HOPE].[rpl_locks].[P2ReplDbScheme]
--set value =0  where name ='LOCKS:term_LOCKS' and "key" like 'lifenum'
--UPDATE  [FUTURES_HOPE].[rpl_common].[P2ReplDbScheme]
--set value =0  where name ='SF_COMMON_INT_REPL:term_SF_COMMON_INT_REPL' and "key" like 'lifenum'