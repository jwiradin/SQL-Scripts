declare @startTime datetime
declare @max int, @cnt int, @curRole int
-- run time 30 seconds
/*
	-- restart
	drop table #t_role
	truncate table accessrole	
*/
begin try
select @startTime = GETDATE()

select roleID
into #t_role
from	[role]

select @max = COUNT(*) from #t_role
set @cnt = 1

print 'Starting generating access role ' + convert(varchar(20), @starttime, 113)
while @cnt <= @max
begin
	set @curRole = (select top 1 roleID from #t_role)
	delete #t_role where roleID = @curRole
	
	insert into accessRole(customerID, roleID)
	select	a.customerID, @curRole
	from	(	select	customerID, ABS(CHECKSUM(newID())) % 2 'flag'
				from	customer) a
	where	a.flag = 1
	
	set @cnt = @cnt + 1
end
-- assign the last access role to unassigned customers
	insert into accessRole(customerID, roleID)
	select	c.customerID, @curRole
	from	customer c
			left join accessRole cc on c.customerID = cc.customerID
	where	cc.customerID is null
	
print 'Finish generating access role ' + convert(varchar(20), getdate(), 113) + ' duration:'+ convert(varchar(10), datediff(ss, @startTime, getdate()))

--select COUNT(*) from (select distinct customerid from accessRole) a

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


