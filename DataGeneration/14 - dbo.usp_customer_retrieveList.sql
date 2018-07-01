
/****** Object:  StoredProcedure [dbo].[usp_customer_retrieveList]    Script Date: 07/30/2015 10:58:37 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_customer_retrieveList]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[usp_customer_retrieveList]
GO

/****** Object:  StoredProcedure [dbo].[usp_customer_retrieveList]    Script Date: 07/30/2015 10:58:37 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create proc [dbo].[usp_customer_retrieveList]
	@user int,
	@sort int = 0,-- 0-ascending, 1-descending
	@customerType int = 0, -- 0-all, 1-individual, 2-company
	@filter varchar(max) = '', -- optional filters format #=1,2,3,4:#='1','2','3','4'  
									 -- # filter type 0- marketing; 1- substring in the name; 2-suburb; 3-state
									 -- = parameter values separators (comma delimited)
									 -- : filter separators
	@pageNumber int = 0, -- page number to be retrieved
	@pageRow int = 0 -- number of rows per page 0-no paging
as
begin
set nocount on

if OBJECT_ID('tempdb..#result') is null
	begin
	create table #result (customerID int, name varchar(200), lastName varChar(100))
	create table #finalResult (totalRow int, customerID int, name varchar(200), lastName varChar(100))
	create index i_tmpResult_customerID on #result(customerID)
	end
else
	truncate table #result
	
if OBJECT_ID('tempdb..#t_roles') is not null
	drop table #t_roles

if OBJECT_ID('tempdb..#parm') is null
	create table #parm  (Ordinal int ,StringValue varchar(max))
else
	truncate table #parm
	
if OBJECT_ID('tempdb..#category') is not null
	drop table #category

declare @nameFilter varchar(50),	
	@suburbFilter varchar(50),
	@stateFilter varchar(50),
	@tmpName varchar(max),
	@tmpSuburb varchar(max),
	@tmpState varchar(max)

insert into	#parm (Ordinal, StringValue)
select	Ordinal, StringValue
from	dbo.ufn_split(@filter,':')

if(select COUNT(*) from #parm where left(stringValue,1) = 1) = 1 -- any name substring filter?
begin
	-- get name
	select @nameFilter = STUFF(stringValue,1,CHARINDEX('=', stringValue,1),'') from #parm where left(stringValue,1) = 1
end

if(select COUNT(*) from #parm where left(stringValue,1) = 2) = 1 -- any suburb filter?
begin
	-- get suburb
	select @suburbFilter = STUFF(stringValue,1,CHARINDEX('=', stringValue,1),'') from #parm where left(stringValue,1) = 2
end

if(select COUNT(*) from #parm where left(stringValue,1) = 3) = 1 -- any state filter?
begin
	-- get state
	select	@stateFilter = STUFF(stringValue,1,CHARINDEX('=', stringValue,1),'') from #parm where left(stringValue,1) = 3
end

select *
into #t_roles
from [dbo].[ufn_getRoles](@user)

if (select COUNT(*) from #t_roles) = (select COUNT(*) from [role])
begin
	insert into #result (customerID, name, lastName)
	select	distinct 
			c.customerID,
			case when isnull(c.companyName,'') <> '' then c.companyName else c.firstName + ' ' + c.lastName end 'name',
			case when isnull(c.companyName,'') <> '' then c.companyName else c.lastName end 'lastName'
	from	customer c
			join customerAddress ca on ca.customerID = c.customerID
			join [address] a on ca.addressID = a.addressID
	where	((1 = case @customerType when 0 then 1 else 0 end) or 
			 (c.firstName = case @customerType when 1 then c.firstName else null end) or		-- 1 individual
			 (c.companyName = case @customerType when 2 then c.companyName else null end))      -- 2 company
			and 
			( case when isnull(c.companyName,'') <> '' then c.companyName else c.firstName + ' ' + c.lastName end like coalesce('%' + @nameFilter + '%','%'))
			and
			( a.suburb = coalesce(@suburbFilter,a.suburb))
			and
			( a.[state] = coalesce(@stateFilter, a.[state]))
end
else
begin
	insert into #result (customerID, name, lastName)
	select	distinct 
			c.customerID,
			case when isnull(c.companyName,'') <> '' then c.companyName else c.firstName + ' ' + c.lastName end 'name',
			case when isnull(c.companyName,'') <> '' then c.companyName else c.lastName end 'lastName'
	from	customer c
			join accessRole ar on c.customerID = ar.customerID
			join #t_roles r on ar.roleID = r.roleID 
			join customerAddress ca on ca.customerID = c.customerID
			join [address] a on ca.addressID = a.addressID
	where	((1 = case @customerType when 0 then 1 else 0 end) or 
			 (c.firstName = case @customerType when 1 then c.firstName else null end) or		-- 1 individual
			 (c.companyName = case @customerType when 2 then c.companyName else null end))      -- 2 company
			and 
			( case when isnull(c.companyName,'') <> '' then c.companyName else c.firstName + ' ' + c.lastName end like coalesce('%' + @nameFilter + '%','%'))
			and
			( a.suburb = coalesce(@suburbFilter,a.suburb))
			and
			( a.[state] = coalesce(@stateFilter, a.[state]))
end

if(select COUNT(*) from #parm where left(stringValue,1) = 0) = 1
begin
	-- apply marketing filter
	declare @marketing varchar(max)
	select @marketing = STUFF(stringValue,1,CHARINDEX('=', stringValue,1),'') from #parm where left(stringValue,1) = 0
	
	select	a.ordinal, convert(int,a.StringValue) 'stringValue'
	into	#category
	from	dbo.ufn_split(@marketing,',') a
	
	-- remove rows not in the list
	delete	r
	from	#result r
			left join (	select distinct r.customerID
					from	#result r
							join customerCategory cc on r.customerID = cc.customerID
							join #category c on c.stringValue = cc.categoryID) a on r.customerID = a.customerID
	where	a.customerID is null
end

if @pageRow > 0 
begin

	insert into #finalResult
	select	COUNT(*) over() totalRow, r.customerID, r.name, r.lastName
	from	#result r
	order by 	
		case when @sort = 0 then r.lastName end asc,
		case when @sort = 1 then r.lastName end desc
	OFFSET (@pageNumber - 1) * @PageRow ROW fetch next @pagerow ROW ONLY  -- deliberately no check @pageNumber > 0

end
else
begin
	insert into #finalResult
	select	COUNT(*) over() totalRow, r.customerID, r.name, r.lastName
	from	#result r
	order by 	
		case when @sort = 0 then r.lastName end asc, 
		case when @sort = 1 then r.lastName end desc
end
-- try to safe resources from populating emails, suburbs and phones on the final result in case of a page request
select	r.totalRow, r.customerID, r.name, r.lastName, 
		emails = convert(varchar(500),stuff((select ',' + emailAddress from email a where a.customerID = r.customerID for xml path('')),1,1,'')),
		suburbs = convert(varchar(500),stuff((select ',' + a.suburb + ' ' + a.[state] from customerAddress ca join [address] a on ca.addressID = a.addressID where ca.customerID = r.customerID for xml path('')),1,1,'')),
		phones = convert(varchar(500),stuff((select ',' + phoneNumber from phone a where a.customerID = r.customerID for xml path('')),1,1,''))
from	#finalResult r

end

go
grant execute on [dbo].[usp_customer_retrieveList] to public -- not on production environment
go