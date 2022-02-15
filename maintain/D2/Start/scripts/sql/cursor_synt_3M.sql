declare @client_id  VARCHAR (7)
declare @br_code  varchar (4)
declare @cl_code  varchar (3)


declare  @ord_type int
set @ord_type = 1

declare @Login VARCHAR (30)
declare @rev int
set @rev=0
DECLARE @CURSOR CURSOR
SET @CURSOR  = CURSOR SCROLL
FOR

select Code  from FUTURES_HOPE.CoreDictionaries.Investor
where Code like '90%' or Code like 'A7%'  or Code like '82%'
--where rev = 5673


  --SET IDENTITY_INSERT [ROBOFEEDER2].[dbo].Actions_20210322_synt_money off
   SET IDENTITY_INSERT [ROBOFEEDER2].[dbo].Actions_20210322_synt_2 ON

/*Открываем курсор*/
OPEN @CURSOR
/*Выбираем первую строку*/
FETCH NEXT FROM @CURSOR INTO @client_id 
  
 WHILE @@FETCH_STATUS = 0
BEGIN
set @Login = (SELECT top (1) n_user
FROM [FUTURES_HOPE].[dbo].[tp_user]
where kod like SUBSTRING(@client_id,1,2)+'00000'  and access_flags != 0)

set @br_code = SUBSTRING(@client_id,1,4)
set @cl_code = SUBSTRING(@client_id,5,3)


INSERT INTO [ROBOFEEDER2].[dbo].Actions_20210322_synt_2 (
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
@rev, 'FutAddOrderFix', 'AddOrderLegacy', 201513289720, 1869179, 1869179, 0, @client_id, '0x3e9491400515b85', 
'2021.03.22 10:59:59.996601401', 1616399999996572, 6200281215, 1, 'Future', '0x1401', 'MSAddOrderSingleSuper', 1, 
@Login, @br_code, 'LKOH-6.21', @cl_code, 1, @ord_type, 10, '57951.00000', 'AddOrde: Add', NULL, 120003009, '181510$1110309', 
NULL, '1900/01/01 00:00:00.000000', 0, NULL, NULL, 0, 57951.00000, 0, 0, 0, @client_id, 'NO', 120003009, 0, 0, 
'1900/01/01 00:00:00.000000', 10, 1869179, 1, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1869179, 
NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
 	
	--SELECT count (*)FROM [ROBOFEEDER2].[dbo].[Actions_20210322_synt_money]
  set @rev+=1
  IF @ord_type=1
       set @ord_type=2;
ELSE 
       set @ord_type=1;
/*Выбираем следующую строку*/
FETCH NEXT FROM @CURSOR INTO @client_id 
END
CLOSE @CURSOR 
  
  select count ( * ) from [ROBOFEEDER2].[dbo].[Actions_20210322_synt_2] 
  --select * from [ROBOFEEDER2].[dbo].[Actions_20210322_synt_2] 
 
  select Login, count(Login) as num
from [ROBOFEEDER2].[dbo].[Actions_20210322_synt_2]
group by Login
having count(Login)>100000
order by num desc

select [client_id], count([client_id])
from [ROBOFEEDER2].[dbo].[Actions_20210322_synt_2]
group by [client_id]
having count([client_id])>1