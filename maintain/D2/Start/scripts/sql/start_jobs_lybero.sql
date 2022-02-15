USE msdb ;  
GO  
  
EXEC dbo.sp_start_job N'JobTrade2Deal' ;  
EXEC dbo.sp_start_job N'JobRunTasks' ;  
EXEC dbo.sp_start_job N'JobPRCLStartReport' ;  
EXEC dbo.sp_start_job N'JobMergeRepl' ;  
EXEC dbo.sp_start_job N'JobFixMxrepoCoeff' ;  
EXEC dbo.sp_start_job N'JobFixMxQuote' ;  
EXEC dbo.sp_start_job N'JobFixEquSecurities' ;  
EXEC dbo.sp_start_job N'JobEvenTrad' ;  
EXEC dbo.sp_start_job N'JobCheckClr' ;  
EXEC dbo.sp_start_job N'DBCC DBREINDEX' ;  
EXEC dbo.sp_start_job N'JobProcessCommandMessage';
EXEC dbo.sp_start_job N'JobProcessCommandMessage1';
EXEC dbo.sp_start_job N'JobProcessCommandMessage2';
EXEC dbo.sp_start_job N'JobProcessCommandMessage3';
EXEC dbo.sp_start_job N'JobProcessCommandMessage4';

update CLEARING_CLR..sl_registry
set value = 1800 where code = 'timeout_se_chk_download_part_limits_AMOUNT_END_complited'

USE [msdb]
GO
DECLARE @jobId BINARY(16)
EXEC  msdb.dbo.sp_add_job @job_name=N'ADD_Currency', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_page=2, 
		@delete_level=0, 
		@category_name=N'Data Collector', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
select @jobId
GO
EXEC msdb.dbo.sp_add_jobserver @job_name=N'ADD_Currency', @server_name = N'CBACUS-D01'
GO
USE [msdb]
GO
EXEC msdb.dbo.sp_add_jobstep @job_name=N'ADD_Currency', @step_name=N'1', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_fail_action=2, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'  use master
  exec [dbo].[Add_currency]', 
		@database_name=N'master', 
		@flags=0
GO
USE [msdb]
GO
EXEC msdb.dbo.sp_update_job @job_name=N'ADD_Currency', 
		@enabled=1, 
		@start_step_id=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_page=2, 
		@delete_level=0, 
		@description=N'', 
		@category_name=N'Data Collector', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'', 
		@notify_page_operator_name=N''
GO
USE [msdb]
GO
DECLARE @schedule_id int
EXEC msdb.dbo.sp_add_jobschedule @job_name=N'ADD_Currency', @name=N'1', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20201121, 
		@active_end_date=99991231, 
		@active_start_time=110000, 
		@active_end_time=235959, @schedule_id = @schedule_id OUTPUT
select @schedule_id
GO



--UPDATE [CLEARING_CLR].[rpl_core_trades].[P2ReplDbScheme]
--set value =66001  where name ='IntFUTTRADE_BIG_DELAY:term_IntFUTTRADE_BIG_DELAY' and "key" like 'lifenum'
--UPDATE  [CLEARING_CLR].[rpl_abacus_opt].[P2ReplDbScheme]
--set value =0  where name ='Filter1OPT2:term_Filter1OPT2' and "key" like 'lifenum'
--UPDATE  [CLEARING_CLR].[rpl_abacus].[P2ReplDbScheme]
--set value =0  where name ='Filter1FUT3:term_Filter1FUT3' and "key" like 'lifenum'
--UPDATE  [CLEARING_CLR].[rpl_abacus].[P2ReplDbScheme]
--set value =0  where name ='ConvFO:term_ConvFO' and "key" like 'lifenum'
--UPDATE  [CLEARING_CLR].[rpl_billing].[P2ReplDbScheme]
--set value =0  where name ='Filter1FEERATE:term_Filter1FEERATE' and "key" like 'lifenum'
--UPDATE  [CLEARING_CLR].[rpl_billing].[P2ReplDbScheme]
--set value =0  where name ='FEE_CL:term_FEE_CL' and "key" like 'lifenum'




