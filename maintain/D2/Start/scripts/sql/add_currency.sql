Declare @day Datetime
set @day = (select top 1 date
from CLEARING_CLR..currency 
ORDER
    BY date DESC)

	Declare @nextday Datetime
	set @nextday = (SELECT DATEADD(day, 1, @day) AS DateAdd)

--select top 30 date , code,rate,status,id_currency
--from CLEARING_CLR..currency 
--ORDER
--   BY date DESC

insert into CLEARING_CLR..currency (code,rate,status,id_currency,date)
select  code,rate,status,id_currency,
date= @nextday
from CLEARING_CLR..currency 
where date =(select top (1) date
from CLEARING_CLR..currency 
order by date desc) and  code != 'RUON' and code != 'MOEXREPO' and code != 'RUSFAR' and code != 'RUSFARUSD'

insert into CLEARING_CLR..currency (code,rate,status,id_currency,date)
select  top (1)  code,rate,status,id_currency,
date=@day 
from CLEARING_CLR..currency 
where  code = 'RUON' 
order by date desc

insert into CLEARING_CLR..currency (code,rate,status,id_currency,date)
select  top (1)  code,rate,status,id_currency,
date=@day  
from CLEARING_CLR..currency 
where  code = 'MOEXREPO' 
order by date desc

insert into CLEARING_CLR..currency (code,rate,status,id_currency,date)
select  top (1)  code,rate,status,id_currency,
date=@day 
from CLEARING_CLR..currency 
where  code = 'RUSFAR' 
order by date desc

insert into CLEARING_CLR..currency (code,rate,status,id_currency,date)
select  top (1)  code,rate,status,id_currency,
date=@day 
from CLEARING_CLR..currency 
where  code = 'RUSFARUSD' 
order by date desc

--select top 30 date , code,rate,status,id_currency
--from CLEARING_CLR..currency 
--ORDER
--   BY date DESC