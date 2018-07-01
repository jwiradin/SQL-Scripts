declare @startTime datetime
declare @max int, @cnt int, @curCategory int
-- total time  23 seconds
begin try
select @startTime = GETDATE()

select categoryID
into #t_category
from	category

select @max = COUNT(*) from #t_category
set @cnt = 1

print 'Starting generating customer category ' + convert(varchar(20), @starttime, 113)
while @cnt <= @max
begin
	set @curCategory = (select top 1 categoryID from #t_category)
	delete #t_category where categoryid = @curCategory
	
	insert into customerCategory(customerID, categoryID)
	select	a.customerID, @curCategory
	from	(	select	customerID, ABS(CHECKSUM(newID())) % 2 'flag'
				from	customer) a
	where	a.flag = 1
	
	set @cnt = @cnt + 1
end
-- assign the last category to unassigned customers
	insert into customerCategory(customerID, categoryID)
	select	c.customerID, @curCategory
	from	customer c
			left join customerCategory cc on c.customerID = cc.customerID
	where	cc.customerID is null
	
print 'Finish generating customer category ' + convert(varchar(20), getdate(), 113) + ' duration:'+ convert(varchar(10), datediff(ss, @startTime, getdate()))

--select COUNT(*) from (select distinct customerid from customerCategory) a

end try
begin catch
    SELECT 
        ERROR_NUMBER() AS ErrorNumber
        ,ERROR_SEVERITY() AS ErrorSeverity
        ,ERROR_STATE() AS ErrorState
        ,ERROR_PROCEDURE() AS ErrorProcedure
        ,ERROR_LINE() AS ErrorLine
        ,ERROR_MESSAGE() AS ErrorMessage;
end catch


