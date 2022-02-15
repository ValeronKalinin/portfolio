
declare @client_id  VARCHAR (7)
declare @br_code  varchar (4)
declare @cl_code  varchar (3)

declare @Login VARCHAR (30)
declare @rev int
set @rev=0
DECLARE @CURSOR CURSOR
SET @CURSOR  = CURSOR SCROLL
FOR
SELECT  client_id,Login
  FROM [ROBOFEEDER2].[dbo].[Actions_20210322_synt_2]
  where client_id like '82%'

  --SET IDENTITY_INSERT [ROBOFEEDER2].[dbo].Actions_20210322_synt_money_1 off
   SET IDENTITY_INSERT [ROBOFEEDER2].[dbo].Actions_20210322_synt_money_3 ON

/*Открываем курсор*/
OPEN @CURSOR
/*Выбираем первую строку*/
FETCH NEXT FROM @CURSOR INTO @client_id ,@Login
  
 WHILE @@FETCH_STATUS = 0
BEGIN
set @br_code = SUBSTRING(@client_id,1,4)
set @cl_code = SUBSTRING(@client_id,5,3)

INSERT INTO [ROBOFEEDER2].[dbo].Actions_20210322_synt_money_3 (
[rev],[Act],[MSLegacy],[msg_rev],[isin_id],
[legacy_isin_id],[orig_ext_id],[client_id],[transaction_id],[server_time],
[timings],[match_id],[InstrMask],[InstrMaskEnum],[flags],
[MSOriginal],[PreLs_num],[Login],[BrokerCode],[Isin],
[ClientCode],[CotirContr],[OrderType],[Amount],[StrPrice],
[Comment],[ContraRTSCode],[ext_id],[fix_client_operation_id],
[is_check_limit],[StrDateExp],[DontCheckMoney],[LocalStamp],[MatchRef],
[NCCRequest],[Price],[IsIceberg],[IcebergAmount],[VarianceAmount],
[Account],[ClientFlags],[ClOrdLinkID],[DisplayQty],[DisplayVarianceQty],
[ExpireDate],[OrderQty],[SecurityID],[Side],[TimeInForce],
[OrderId],[OrderID],[BuySell],[Nosystem],[Code],
[KodVcb],[WorkMode],[Regime],[IsinId],[SecurityType],
[SecurityGroup],[pRegime],[pKod],[pAmountMN],[pAmountPL],
[pKfl],[pKgo],[pIsAutoUpdLimit],[pIsAutoUpdSpotLimit],[pBuySpotLimit],
[pNoFutDiscount],[Mode],[IMCoeff], [IsAutoUpdateLimit],[IsCheckMoney],
[LimitMoney]) 
VALUES (
@rev, 'ChangeClientMoney', 'ChangeClientMoneyNTA', NULL, NULL, NULL, NULL, @client_id, NULL, 
NULL,NULL, NULL, NULL, NULL, NULL, NULL, NULL, 
@Login, @br_code, NULL, @cl_code, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 
NULL, NULL,NULL , NULL, NULL, 0, NULL, 0, 0, 0,  @client_id, NULL, NULL, NULL, NULL, 
NULL, NULL,NULL, NULL, NULL, NULL, NULL, NULL, NULL,  @client_id, NULL, NULL, NULL, NULL, 
NULL, NULL, 13, NULL, '999999999999', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 12, 1, -1, 1, '999999999999')
 	
	--SELECT count (*)FROM [ROBOFEEDER2].[dbo].[Actions_20210322_synt_money]
  set @rev+=1
/*Выбираем следующую строку*/
FETCH NEXT FROM @CURSOR INTO @client_id ,@Login
END
CLOSE @CURSOR 
  
  select count (*) from [ROBOFEEDER2].[dbo].[Actions_20210322_synt_money_3] 

  

select [client_id], count([client_id])
from [ROBOFEEDER2].[dbo].[Actions_20210322_synt_money_3]
group by [client_id]
having count([client_id])>1