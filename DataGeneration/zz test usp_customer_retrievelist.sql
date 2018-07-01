set nocount on
if OBJECT_ID('tempdb..#t_finalResultNoFilter') is null
begin
	CREATE TABLE #t_finalResultNoFilter(
		[totalRow] [int] NULL,
		[customerID] [int] NULL,
		[name] [varchar](200) NULL,
		[lastName] [varchar](100) NULL,
		[emails] [varchar](500) NULL,
		[suburbs] [varchar](500) NULL,
		[phones] [varchar](500) NULL
	)
end

if OBJECT_ID('tempdb..#t_finalResult') is null
begin
CREATE TABLE #t_finalResult(
	[totalRow] [int] NULL,
	[customerID] [int] NULL,
	[name] [varchar](200) NULL,
	[lastName] [varchar](100) NULL,
	[emails] [varchar](500) NULL,
	[suburbs] [varchar](500) NULL,
	[phones] [varchar](500) NULL
)
end

truncate table #t_finalResultNoFilter
truncate table #t_finalResult

DECLARE @RC int
DECLARE @user int
DECLARE @sort int
DECLARE @customerType int
DECLARE @filter varchar(max)
DECLARE @pageNumber int
DECLARE @pageRow int
Declare @startTime datetime

select @user = 2, 
	@customerType = 0, -- all customer type
	@filter = '', -- no filter
	@pageNumber = 0,
	@pageRow = 0,
	@sort = 0

set @startTime = GETDATE()
print 'Start extracting data for user 2 with no filter - ' + convert(varchar(20), @startTime,113)

insert into #t_finalResultNoFilter
EXECUTE [dbo].[usp_customer_retrieveList] 
   @user
  ,@sort
  ,@customerType
  ,@filter
  ,@pageNumber
  ,@pageRow
print 'Finish extracting data for user 2 with no filter - ' + convert(varchar(20), getdate(),113) + ' run: ' + convert(varchar(10),datediff(ss,@startTime,getdate()))

print 'Validating condition:number of rows returned for user 2 - ' + convert(varchar(20), getdate(),113)
if (	select COUNT(*)
		from (	select	distinct c.customerid
				from	customer c
						join accessrole ar on c.customerid = ar.customerid
						join userrole ur on ar.roleid = ur.roleid
						join [user] u on ur.userid = u.userid
				where	u.userid = 2) a) =
	(select top 1 totalRow from #t_finalResultNoFilter)
begin
	print concat('Validation successful condition:number of rows returned for user 2 - ' , convert(varchar(20), getdate(),113))
end
else
begin
	print concat('*****Validation failed condition:number of rows returned for user 2 - ' , convert(varchar(20), getdate(),113))
end

/*
DECLARE @RC int
DECLARE @user int
DECLARE @sort int
DECLARE @customerType int
DECLARE @filter varchar(max)
DECLARE @pageNumber int
DECLARE @pageRow int
Declare @startTime datetime
*/

select @user = 2, 
	@customerType = 1, -- Individual Only
	@filter = '', -- no filter
	@pageNumber = 0,
	@pageRow = 0,
	@sort = 0

set @startTime = GETDATE()
print 'Start extracting data for user 2 filter - individual only ' + convert(varchar(20), @startTime,113)

insert into #t_finalResult
EXECUTE [dbo].[usp_customer_retrieveList] 
   @user
  ,@sort
  ,@customerType
  ,@filter
  ,@pageNumber
  ,@pageRow
  
print concat('Finish extracting data for user 2 filter - individual only ' , convert(varchar(20), getdate(),113) , ' run: ', datediff(ss,@startTime,getdate()))

print 'Validating condition:number of rows returned for user 2 filter - individual only ' + convert(varchar(20), getdate(),113)
if (	select COUNT(*)
		from (	select	distinct c.customerid
				from	customer c
						join accessrole ar on c.customerid = ar.customerid
						join userrole ur on ar.roleid = ur.roleid
						join [user] u on ur.userid = u.userid
				where	u.userid = 2
				and		c.companyName is null) a) =
	(select top 1 totalRow from #t_finalResult) 
		and 
	-- Compare with unfiltered result
	(	select COUNT(*)
		from	#t_finalResultNoFilter
		where	name <> lastName) =
	(select top 1 totalRow from #t_finalResult)
begin
	print concat('Validation successful condition:number of rows returned for user 2 - ' , convert(varchar(20), getdate(),113))
end
else
begin
	print concat('*****Validation failed condition:number of rows returned for user 2 - ' , convert(varchar(20), getdate(),113))
end

/*
DECLARE @RC int
DECLARE @user int
DECLARE @sort int
DECLARE @customerType int
DECLARE @filter varchar(max)
DECLARE @pageNumber int
DECLARE @pageRow int
Declare @startTime datetime
*/

select @user = 2, 
	@customerType = 2, -- Company Only
	@filter = '', -- no filter
	@pageNumber = 0,
	@pageRow = 0,
	@sort = 0

set @startTime = GETDATE()
print 'Start extracting data for user 2 filter - company only ' + convert(varchar(20), @startTime,113)
truncate table #t_finalResult

insert into #t_finalResult
EXECUTE [dbo].[usp_customer_retrieveList] 
   @user
  ,@sort
  ,@customerType
  ,@filter
  ,@pageNumber
  ,@pageRow
  
print concat('Finish extracting data for user 2 filter - company only ' , convert(varchar(20), getdate(),113) , ' run: ', datediff(ss,@startTime,getdate()))

print 'Validating condition:number of rows returned for user 2 filter - company only ' + convert(varchar(20), getdate(),113)
if (	select COUNT(*)
		from (	select	distinct c.customerid
				from	customer c
						join accessrole ar on c.customerid = ar.customerid
						join userrole ur on ar.roleid = ur.roleid
						join [user] u on ur.userid = u.userid
				where	u.userid = 2
				and		c.companyName is not null) a) =
	(select top 1 totalRow from #t_finalResult) 
		and 
	-- Compare with unfiltered result
	(	select COUNT(*)
		from	#t_finalResultNoFilter
		where	name = lastName) =
	(select top 1 totalRow from #t_finalResult)
begin
	print concat('Validation successful condition:number of rows returned for user 2 filter - company only ' , convert(varchar(20), getdate(),113))
end
else
begin
	print concat('*****Validation failed condition:number of rows returned for user 2 filter - company only ' , convert(varchar(20), getdate(),113))
end


/*
DECLARE @RC int
DECLARE @user int
DECLARE @sort int
DECLARE @customerType int
DECLARE @filter varchar(max)
DECLARE @pageNumber int
DECLARE @pageRow int
Declare @startTime datetime
*/

select @user = 2, 
	@customerType = 0, -- All customer type
	@filter = '3=NSW', -- NSW only
	@pageNumber = 0,
	@pageRow = 0,
	@sort = 0

set @startTime = GETDATE()
print 'Start extracting data for user 2 filter - NSW only ' + convert(varchar(20), @startTime,113)
truncate table #t_finalResult

insert into #t_finalResult
EXECUTE [dbo].[usp_customer_retrieveList] 
   @user
  ,@sort
  ,@customerType
  ,@filter
  ,@pageNumber
  ,@pageRow
  
print concat('Finish extracting data for user 2 filter - NSW only ' , convert(varchar(20), getdate(),113) , ' run: ', datediff(ss,@startTime,getdate()))

print 'Validating condition:number of rows returned for user 2 filter - NSW only ' + convert(varchar(20), getdate(),113)
if (	select COUNT(*)
		from (	select	distinct c.customerid
				from	customer c
						join accessrole ar on c.customerid = ar.customerid
						join userrole ur on ar.roleid = ur.roleid
						join [user] u on ur.userid = u.userid
						join customerAddress ca on c.customerid = ca.customerid
						join [address] a on a.addressid = ca.addressid 
				where	u.userid = 2
				and		a.[state] = 'NSW') a) =
	(select top 1 totalRow from #t_finalResult) 
		and 
	-- Compare with unfiltered result
	(	select COUNT(*)
		from	#t_finalResultNoFilter
		where	suburbs like '% NSW%') =
	(select top 1 totalRow from #t_finalResult)
begin
	print concat('Validation successful condition:number of rows returned for user 2 filter - NSW only ' , convert(varchar(20), getdate(),113))
end
else
begin
	print concat('*****Validation failed condition:number of rows returned for user 2 filter - NSW only ' , convert(varchar(20), getdate(),113))
end

/*
DECLARE @RC int
DECLARE @user int
DECLARE @sort int
DECLARE @customerType int
DECLARE @filter varchar(max)
DECLARE @pageNumber int
DECLARE @pageRow int
Declare @startTime datetime
*/

select @user = 2, 
	@customerType = 0, -- All customer type
	@filter = '1=Alfred', -- name filter
	@pageNumber = 0,
	@pageRow = 0,
	@sort = 0

set @startTime = GETDATE()
print 'Start extracting data for user 2 filter - Name Alfred only ' + convert(varchar(20), @startTime,113)
truncate table #t_finalResult

insert into #t_finalResult
EXECUTE [dbo].[usp_customer_retrieveList] 
   @user
  ,@sort
  ,@customerType
  ,@filter
  ,@pageNumber
  ,@pageRow
  
print concat('Finish extracting data for user 2 filter - Name Alfred only ' , convert(varchar(20), getdate(),113) , ' run: ', datediff(ss,@startTime,getdate()))

print 'Validating condition:number of rows returned for user 2 filter - Name Alfred only ' + convert(varchar(20), getdate(),113)
if (	select COUNT(*)
		from (	select	distinct c.customerid
				from	customer c
						join accessrole ar on c.customerid = ar.customerid
						join userrole ur on ar.roleid = ur.roleid
						join [user] u on ur.userid = u.userid
				where	u.userid = 2
				and		case when c.companyName is null then c.firstname + ' ' + c.lastname else c.companyname end like '%Alfred%') a) =
	(select top 1 totalRow from #t_finalResult) 
		and 
	-- Compare with unfiltered result
	(	select COUNT(*)
		from	#t_finalResultNoFilter
		where	name like '%Alfred%') =
	(select top 1 totalRow from #t_finalResult)
begin
	print concat('Validation successful condition:number of rows returned for user 2 filter - Name Alfred only ' , convert(varchar(20), getdate(),113))
end
else
begin
	print concat('*****Validation failed condition:number of rows returned for user 2 filter - Name Alfred only ' , convert(varchar(20), getdate(),113))
end

-- suburb filter
/*
DECLARE @RC int
DECLARE @user int
DECLARE @sort int
DECLARE @customerType int
DECLARE @filter varchar(max)
DECLARE @pageNumber int
DECLARE @pageRow int
Declare @startTime datetime
*/

select @user = 2, 
	@customerType = 0, -- All customer type
	@filter = '2=Sydney', -- suburb filter
	@pageNumber = 0,
	@pageRow = 0,
	@sort = 0

set @startTime = GETDATE()
print 'Start extracting data for user 2 filter - suburb Sydney only ' + convert(varchar(20), @startTime,113)
truncate table #t_finalResult

insert into #t_finalResult
EXECUTE [dbo].[usp_customer_retrieveList] 
   @user
  ,@sort
  ,@customerType
  ,@filter
  ,@pageNumber
  ,@pageRow
  
print concat('Finish extracting data for user 2 filter - suburb Sydney only ' , convert(varchar(20), getdate(),113) , ' run: ', datediff(ss,@startTime,getdate()))

print 'Validating condition:number of rows returned for user 2 filter - suburb Sydney only ' + convert(varchar(20), getdate(),113)
if (	select COUNT(*)
		from (	select	distinct c.customerid
				from	customer c
						join accessrole ar on c.customerid = ar.customerid
						join userrole ur on ar.roleid = ur.roleid
						join [user] u on ur.userid = u.userid
						join customerAddress ca on c.customerid = ca.customerid
						join [address] a on a.addressid = ca.addressid 	
				where	u.userid = 2
				and		a.suburb = 'Sydney') a) =
	(select top 1 totalRow from #t_finalResult) 
		and 
	-- Compare with unfiltered result
	(	select COUNT(*)
		from	#t_finalResultNoFilter
		where	suburbs like 'Sydney NSW%' or suburbs like '%,Sydney NSW%') =
	(select top 1 totalRow from #t_finalResult)
begin
	print concat('Validation successful condition:number of rows returned for user 2 filter - suburb Sydney only ' , convert(varchar(20), getdate(),113))
end
else
begin
	print concat('*****Validation failed condition:number of rows returned for user 2 filter - suburb Sydney only ' , convert(varchar(20), getdate(),113))
end


-- marketing category
/*
DECLARE @RC int
DECLARE @user int
DECLARE @sort int
DECLARE @customerType int
DECLARE @filter varchar(max)
DECLARE @pageNumber int
DECLARE @pageRow int
Declare @startTime datetime
*/

select @user = 2, 
	@customerType = 0, -- All customer type
	@filter = '0=' + STUFF((select	concat(',',categoryID)
							from	category
							where	categoryDesc in ('Security door', 'Security window')
							for xml path(''))
						,1,1,''), -- marketing filter
	@pageNumber = 0,
	@pageRow = 0,
	@sort = 0

set @startTime = GETDATE()
print 'Start extracting data for user 2 filter - Security door, Security window only ' + convert(varchar(20), @startTime,113)
truncate table #t_finalResult

insert into #t_finalResult
EXECUTE [dbo].[usp_customer_retrieveList] 
   @user
  ,@sort
  ,@customerType
  ,@filter
  ,@pageNumber
  ,@pageRow
  
print concat('Finish extracting data for user 2 filter - Security door, Security window only ' , convert(varchar(20), getdate(),113) , ' run: ', datediff(ss,@startTime,getdate()))

print 'Validating condition:number of rows returned for user 2 filter - Security door, Security window only ' + convert(varchar(20), getdate(),113)
if (	select COUNT(*)
		from (	select	distinct c.customerid
				from	customer c
						join accessrole ar on c.customerid = ar.customerid
						join userrole ur on ar.roleid = ur.roleid
						join [user] u on ur.userid = u.userid
						join customerCategory cc on c.customerid = cc.customerid
						join category ca on cc.categoryID = ca.categoryID 	
				where	u.userid = 2
				and		ca.categorydesc in ('Security door', 'Security window')) a) =
	(select top 1 totalRow from #t_finalResult) 
	-- Can't compare with unfiltered result as there is no marketing info in the result set
begin
	print concat('Validation successful condition:number of rows returned for user 2 filter - Security door, Security window only ' , convert(varchar(20), getdate(),113))
end
else
begin
	print concat('*****Validation failed condition:number of rows returned for user 2 filter - Security door, Security window only ' , convert(varchar(20), getdate(),113))
end

-- Paging
/*
DECLARE @RC int
DECLARE @user int
DECLARE @sort int
DECLARE @customerType int
DECLARE @filter varchar(max)
DECLARE @pageNumber int
DECLARE @pageRow int
Declare @startTime datetime
*/

select @user = 2, 
	@customerType = 0, -- All customer type
	@filter = '', 
	@pageNumber = 3,
	@pageRow = 30,
	@sort = 0

set @startTime = GETDATE()
print 'Start extracting data for user 2 filter - paging page 3/30 rows ' + convert(varchar(20), @startTime,113)
truncate table #t_finalResult

insert into #t_finalResult
EXECUTE [dbo].[usp_customer_retrieveList] 
   @user
  ,@sort
  ,@customerType
  ,@filter
  ,@pageNumber
  ,@pageRow
  
print concat('Finish extracting data for user 2 filter - paging page 3/30 rows ' , convert(varchar(20), getdate(),113) , ' run: ', datediff(ss,@startTime,getdate()))

print 'Validating condition:number of rows returned for user 2 filter - paging page 3/30 rows ' + convert(varchar(20), getdate(),113)
if ((select COUNT(*) from #t_finalResult) = 30) and
	30 =(	select	COUNT(*)
			from	#t_finalResult a
			join (	select totalRow,customerID,name,lastName,emails,suburbs,phones
					from (	select	ROW_NUMBER() over(order by lastName) 'row', * 
							from	#t_finalResultNoFilter) a
					where	a.row > 60 and a.row <= 90) b on a.totalRow = b.totalRow and a.customerID = b.customerID and a.name = b.name and a.lastName = b.lastName and a.emails = b.emails and a.suburbs = b.suburbs and a.phones = b.phones) 
begin
	print concat('Validation successful condition:number of rows returned for user 2 filter - paging page 3/30 rows ' , convert(varchar(20), getdate(),113))
end
else
begin
	print concat('*****Validation failed condition:number of rows returned for user 2 filter - Security door, Security window only ' , convert(varchar(20), getdate(),113))
end

-- combination
/*
DECLARE @RC int
DECLARE @user int
DECLARE @sort int
DECLARE @customerType int
DECLARE @filter varchar(max)
DECLARE @pageNumber int
DECLARE @pageRow int
Declare @startTime datetime
*/

select @user = 2, 
	@customerType = 1, -- Individual
	@filter = '1=Smith:3=VIC', 
	@pageNumber = 3,
	@pageRow = 10,
	@sort = 0

set @startTime = GETDATE()
print 'Start extracting data for user 2 filter - individual, name like smith and state = VIC paging page 3/10 rows ' + convert(varchar(20), @startTime,113)
truncate table #t_finalResult

insert into #t_finalResult
EXECUTE [dbo].[usp_customer_retrieveList] 
   @user
  ,@sort
  ,@customerType
  ,@filter
  ,@pageNumber
  ,@pageRow
  
print concat('Finish extracting data for user 2 filter - individual, name like smith and state = VIC paging page 3/10 rows ' , convert(varchar(20), getdate(),113) , ' run: ', datediff(ss,@startTime,getdate()))

print 'Validating condition:number of rows returned for user 2 filter - individual, name like smith and state = VIC paging page 3/10 rows ' + convert(varchar(20), getdate(),113)
-- cannot compare page for page as the sorting is by lastname only
if ((select COUNT(*) from #t_finalResult) = 10) and
	10 =(	select	COUNT(*)
			from	#t_finalResult a
			join (	select totalRow,customerID,name,lastName,emails,suburbs,phones
					from (	select	ROW_NUMBER() over(order by lastName) 'row', * 
							from	#t_finalResultNoFilter) a
							where	name like '%Smith%'
							and		name <> lastName
							and		(suburbs like '%VIC,%' or suburbs like '%VIC')) b 
					on a.customerID = b.customerID and a.name = b.name and a.lastName = b.lastName and a.emails = b.emails and a.suburbs = b.suburbs and a.phones = b.phones) 
begin
	print concat('Validation successful condition:number of rows returned for user 2 filter - individual, name like smith and state = VIC paging page 3/10 rows ' , convert(varchar(20), getdate(),113))
end
else
begin
	print concat('*****Validation failed condition:number of rows returned for user 2 filter - individual, name like smith and state = VIC paging page 3/10 rows ' , convert(varchar(20), getdate(),113))
end
