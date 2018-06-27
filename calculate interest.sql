--with modification:
-- the interest rate can varies during the month
-- interest amount can be accumulated to daily balance 

if OBJECT_ID('tempdb..#trans') is not null
	drop table #trans
go
if OBJECT_ID('tempdb..#work') is not null
	drop table #work
go
select	*
into	#trans
from (values('1 jan 2018',1000),('12 jan 2018',-100),('14 jan 2018',-100),('28 jan 2018',500)) as a(trdate, tramt)

;with cte as (
	select	convert(date, '1 jan 2018') dte
	union all
	select dateadd(d,1,dte) 
	from cte
	where	convert(char(6),dte,112) = convert(char(6),dateadd(d,1,dte),112)
)
select dte trdate, convert(money,0) bal , convert(money,0) tramt, convert(money,0) trint 
into #work
from cte;

declare @BegBal money,
		@IntRate money,
		@Multiplier money

select	@BegBal = 100, @IntRate = 0.005, @Multiplier = 100000

update #work
set		bal = @BegBal + (select sum(tramt) from #trans t where t.trdate <= #work.trdate),
		tramt = isnull((select tramt from #trans t where t.trdate = #work.trdate),0)

update	#work
set		trint = (@IntRate * @Multiplier / DATEDIFF(dd, '1 jan ' + convert(char(4), datepart(yy,trdate)), '1 jan ' + convert(char(4), datepart(yy,trdate)  +1))) * bal /@Multiplier


select * from #work

