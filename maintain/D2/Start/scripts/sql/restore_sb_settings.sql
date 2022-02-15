-- 20190415 FOSQL-4659 ������ ��������������

USE master
go

SET NOCOUNT ON
SET XACT_ABORT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  


------------------------------------
declare @main_db_list table (name sysname)
	
insert into @main_db_list (name)
values ('CLEARING_CLR')
	, ('FUTURES_HOPE')

declare @noret tinyint = 0		-- 1 = �� �������� ��������� ���������� �������

------------------------------------

declare @dbname sysname
	, @is_broker_enabled bit
	, @command varchar(2000)
	, @access_mode sql_variant

declare _c_restore_settings cursor
for select d.name, d.is_broker_enabled
from sys.databases d
inner join @main_db_list m
on d.name = m.name

open _c_restore_settings
fetch next from _c_restore_settings into @dbname, @is_broker_enabled

while @@fetch_status=0 
begin

	if @is_broker_enabled = 0
	begin
		select @access_mode = DATABASEPROPERTYEX(@dbname,'UserAccess')
		if @access_mode != 'SINGLE_USER'
		begin
			select @command = FORMATMESSAGE('ALTER DATABASE %s SET SINGLE_USER WITH ROLLBACK IMMEDIATE;', @dbname)
			exec (@command)
		end

		select @command = FORMATMESSAGE('ALTER DATABASE %s SET ENABLE_BROKER;', @dbname)
		begin try
			exec (@command)
		end try 
		begin catch
			/* Msg 9772, Level 16, State 1, Line 2
			   The Service Broker in database % cannot be enabled because there is already an enabled Service Broker with the same ID.
			   ��� ���� SB � ����� guid-��, ���� �������� ������������� ������� � ��������������� ����.
			   ��� ���� ����� ������� ������������ ���������.
			   ������: ���� CLEARING_CLR ����������������� � CLEARING_CLR_old �� ��� �� ��������, ��� ���� �������� CLEARING_CLR,
			   � �� ��������������� ���� ���� �������� Service Broker.   
			 */
			select @command = FORMATMESSAGE('ALTER DATABASE %s SET NEW_BROKER;', @dbname)
			exec (@command)
		end catch
	
		if @access_mode != 'SINGLE_USER'
		begin
			select @command = FORMATMESSAGE('ALTER DATABASE %s SET %s', @dbname, cast(@access_mode as varchar(100))) 
			exec (@command)
		end

	end  -- SB enable

	select @command = FORMATMESSAGE('ALTER DATABASE %s SET TRUSTWORTHY ON;', @dbname)
	exec (@command)

fetch next from _c_restore_settings into @dbname, @is_broker_enabled
end


close _c_restore_settings
deallocate _c_restore_settings


if @noret = 0
select d.name, d.is_broker_enabled, d.is_trustworthy_on
from sys.databases d
inner join @main_db_list m
on d.name = m.name
order by d.name


go

UPDATE [CLEARING_CLR].[rpl_core_trades].[P2ReplDbScheme]
set value =66001  where name ='IntFUTTRADE_BIG_DELAY:term_IntFUTTRADE_BIG_DELAY' and "key" like 'lifenum'
UPDATE  [CLEARING_CLR].[rpl_abacus_opt].[P2ReplDbScheme]
set value =0  where name ='Filter1OPT2:term_Filter1OPT2' and "key" like 'lifenum'
UPDATE  [CLEARING_CLR].[rpl_abacus].[P2ReplDbScheme]
set value =0  where name ='Filter1FUT3:term_Filter1FUT3' and "key" like 'lifenum'
UPDATE  [CLEARING_CLR].[rpl_abacus].[P2ReplDbScheme]
set value =0  where name ='ConvFO:term_ConvFO' and "key" like 'lifenum'
UPDATE  [CLEARING_CLR].[rpl_billing].[P2ReplDbScheme]
set value =0  where name ='Filter1FEERATE:term_Filter1FEERATE' and "key" like 'lifenum'
UPDATE  [CLEARING_CLR].[rpl_billing].[P2ReplDbScheme]
set value =0  where name ='FEE_CL:term_FEE_CL' and "key" like 'lifenum'

update [FUTURES_HOPE].[rpl_core_trades].[P2ReplDbScheme]
set value =0  where name ='IntFUTTRADE_BIG_DELAY:term_IntFUTTRADE_BIG_DELAY' and "key" like 'lifenum'
update [FUTURES_HOPE].[rpl_posbuild].[P2ReplDbScheme]
set value =0  where name ='Filter1Pos:term_Filter1Pos' and "key" like 'lifenum'
update [FUTURES_HOPE].[rpl_postls].[P2ReplDbScheme]
set value =0  where name ='Filter1Part:term_Filter1Part' and "key" like 'lifenum'
update [OPTIONS_HOPE].[rpl_volat].[P2ReplDbScheme]
set value =0  where name ='IntVOLATBLACK:term_IntVOLATBLACK' and "key" like 'lifenum'
update [OPTIONS_HOPE].[rpl_volat].[P2ReplDbScheme]
set value =0  where name ='IntVOLATBACH:term_IntVOLATBACH' and "key" like 'lifenum'
UPDATE  [FUTURES_HOPE].[rpl_locks].[P2ReplDbScheme]
set value =0  where name ='LOCKS:term_LOCKS' and "key" like 'lifenum'
UPDATE  [FUTURES_HOPE].[rpl_common].[P2ReplDbScheme]
set value =0  where name ='SF_COMMON_INT_REPL:term_SF_COMMON_INT_REPL' and "key" like 'lifenum'