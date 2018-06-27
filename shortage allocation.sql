if object_ID('tempdb..#tmp') is not null
begin
	drop table #tmp
end

if object_ID('tempdb..#fund') is not null
begin
	drop table #fund
end

create table #tmp (accId int, fundId int, shortage money, fulfilled money)
insert into #tmp values(1, 1, 500, 0)
insert into #tmp values(2, 1, 700, 0)
insert into #tmp values(4, 1, 1000, 0)
insert into #tmp values(3, 3, 1000, 0)
insert into #tmp values(5, 3, 1000, 0)
insert into #tmp values(6, 3, 1000, 0)
insert into #tmp values(7, 4, 1000, 0)
insert into #tmp values(8, 4, 1000, 0)

create table #fund (fundId int, fundAmt money)
insert into #fund values(1,1700)
insert into #fund values(3,300)
insert into #fund values(4,5000)

update	t
set	    fulfilled = (select case when f.fundAmt - sum(t1.shortage) > 0 
							then	t.shortage 
							else case	when f.fundAmt - (sum(t1.shortage) - t.shortage) > 0 
										then  f.fundAmt - (sum(t1.shortage) - t.shortage) 
										else 0 
								 end 
							end 
					 from	#tmp t1 
					 where	t.fundId = t1.fundId 
					 and	t.accId >= t1.accId)
from	#tmp t
		join #fund f on t.fundId = f.fundId

select	t.*, 
		t.shortage - t.fulfilled 'outstanding shortage',
		f.fundAmt,
		case when f.fundAmt - (select sum(t1.fulfilled) from #tmp t1 where t1.accId <= t.accId and t1.fundId = t.fundId) > 0 
			then f.fundAmt - (select sum(t1.fulfilled) from #tmp t1 where t1.accId <= t.accId and t1.fundId = t.fundId) 
			else 0 
		end 'remainder fund'
from	#tmp t
		join #fund f on t.fundId = f.fundId

