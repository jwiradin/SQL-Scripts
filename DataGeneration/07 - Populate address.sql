-- Populate address
-- first pass create main address - home for person street address for company
-- long running scripts running for 16 minutes
if OBJECT_ID('t_addressline') is null
	create table t_addressLine (addressLineId int identity not null,addressline varchar(100))
else
	truncate table t_addressline
	
if OBJECT_ID('t_suburb') is null
	create table t_suburb (t_suburbID UNIQUEIDENTIFIER default newid(), customerID int, addressTypeID int, suburb varchar(50), postCode varchar(4), [state] varchar(3))
else
	truncate table t_suburb

if OBJECT_ID('t_address') is null
begin
	create table t_address (addressID int, customerID int, addressTypeID int, addressline1 varchar(100), suburb varchar(50), postcode varchar(4), [state] varchar(3))
	create index i_t_address_1 on t_address(addressline1, postcode)
end
else
	truncate table t_address

declare @startTime datetime

set @startTime = GETDATE()

print 'on developers machine running for 100 seconds'
print 'Starting generating addressline ' + convert(varchar(20), @startTime, 113)

insert into t_addressLine(addressline)
select	top 300000 n.streetnumber + ' ' + s.streetname + ' ' + a.streetType 'addressLine'
from	t_street s
		cross join (values ('Court'), ('Street'), ('Drive'), ('Way'), ('Road'), ('Parade'), ('Avenue'), ('Place'), ('Crescent'), ('Esplanade'), ('Highway'), ('Lane'), ('Boulevard'), ('Terrace'), ('Walk')) as a(streetType)
		cross join (select convert(varchar(5),ABS(CHECKSUM(NewId())) % 1000) streetNumber from (select top 300 * from t_street) a) n
order by NEWID()
print 'Ending generating addressline ' + convert(varchar(20), getdate(), 113) + ' duration:'+ convert(varchar(10), datediff(ss, @startTime, getdate()))
print 'Looping -- populate the address to reduce load on the server'

declare @maxID int,
		@MinID int

select @MinID = min(addresslineID) from t_addressLine

set @maxID = @minID + 10000
set @startTime = GETDATE()

print 'on developers machine running for 104 seconds'
print 'Starting generating addressline ' + convert(varchar(20), @startTime, 113)
	
while @maxID <= @minID + 300000
begin
	begin tran
	insert into [address] (addressline1, suburb, postcode, [state])
	select top 40000 a.addressline, p.suburb, p.postcode, p.[state]
			from (select addressline from t_addressLine where addressLineId < @maxid and addressLineId >= @maxID - 10000) a
			cross join (select top 500 * from t_postcode order by newid()) p
	order by NEWID()
	commit tran
	set @maxID = @maxID + 10000
end
print 'time to generate 1.2 mill address ' + convert(varchar(10), datediff(ss, @startTime, getdate()))

-- Remove duplicate addresses
delete a
from	[address] a
join	(select addressline1, postcode, MIN(addressID) 'addressID' from [address] group by addressline1, postcode having COUNT(*) > 1) t on a.addressline1 = t.addressline1 and a.postcode = t.postcode and a.addressid <> t.addressid

select COUNT(*) from [address] with (nolock)

-- Populate default address
declare @defAddress int

select @defAddress = addressTypeID from addressType where addresstypedesc = 'Street'
set @startTime = GETDATE()
print 'on developers machine running for 25 seconds'
print 'Starting generating customeraddress ' + convert(varchar(20), @startTime, 113)

insert into customerAddress (customerID, addressID, addressTypeID)
select	a.customerID, b.addressID, @defAddress
from	(select ROW_NUMBER() over(order by newID()) row, customerID from customer) a
		join (select ROW_NUMBER() over(order by newID()) row, addressID from [address]) b on a.row = b.row
print 'time to generate customeraddress ' + convert(varchar(10), datediff(ss, @startTime, getdate()))

-- delete unused address
delete	a
from	[address] a
	left join customerAddress ca on a.addressID = ca.addressID
where	ca.addressID is null

-- populate secondary address (random postal -- ind/company and registered Office address-- company only)

-- regenerate addressline
truncate table t_addressLine
select @startTime = GETDATE()

print 'on developers machine running for 79 seconds'
print 'Starting generating customeraddress ' + convert(varchar(20), @startTime, 113)
insert into t_addressLine(addressline)
select	top 500000 n.streetnumber + ' ' + s.streetname + ' ' + a.streetType 'addressLine'
from	t_street s
		cross join (values ('Court'), ('Street'), ('Drive'), ('Way'), ('Road'), ('Parade'), ('Avenue'), ('Place'), ('Crescent'), ('Esplanade'), ('Highway'), ('Lane'), ('Boulevard'), ('Terrace'), ('Walk')) as a(streetType)
		cross join (select convert(varchar(5),ABS(CHECKSUM(NewId())) % 1000) streetNumber from (select top 300 * from t_street) a) n
order by NEWID()
print 'time to generate customeraddress ' + convert(varchar(10), datediff(ss, @startTime, getdate()))

-- set post code based on existing one

declare @postAddress int,
		@regAddress int
		
select @startTime = GETDATE()

print 'on developers machine running for 202 seconds'
print 'Starting generating related suburb ' + convert(varchar(20), @starttime, 113)

select	@postAddress = addressTypeID from addressType where addressTypeDesc = 'Postal'
select	@regAddress = addressTypeID from addressType where addressTypeDesc = 'Registered Office'

insert into t_suburb (customerID, addressTypeID, postCode, suburb, [state])
select	distinct c.customerid, 
		case when isnull(c.ACN ,'') <> '' then case when CHECKSUM(newID()) % 2 = 1 then @postAddress else @regAddress end else @postAddress end 'addressTypeID',
		p.postcode, p.suburb, p.[state]
from	customer c
		join customerAddress ca on c.customerID = ca.customerID
		join [address] a on ca.addressID = a.addressID
		join t_postcode p on p.postcode > right('000'  + convert(varchar(5),CONVERT(int,a.postcode) - 2),4) and p.postcode < right('000'  + convert(varchar(5),CONVERT(int,a.postcode) + 2),4) and a.[state] = p.[state]

print 'Finish generating related suburb ' + convert(varchar(20), getdate(), 113) + ' duration:'+ convert(varchar(10), datediff(ss, @startTime, getdate()))
-- keep only one suburb/customer

delete	s
from	t_suburb s
		join (select customerID, max(a.t_suburbID) 't_suburbID' from t_suburb a group by customerID) a on s.customerID = a.customerID and s.t_suburbID <> a.t_suburbID
		
select @startTime = GETDATE()
print 'on developers machine running for 50 seconds'
print 'Starting generating t_address ' + convert(varchar(20), @starttime, 113)

insert into t_address(customerID, addressTypeID, addressline1, suburb, postcode, [state])
select	s.customerID, s.addressTypeID, a.addressline, s.suburb, s.postCode, s.[state]
from (	select	ROW_NUMBER() over(order by newid()) 'row', a.addressline
		from	t_addressLine a
				cross join (values(1),(2),(3),(4) ) as b(c)) a
		join (	select ROW_NUMBER() over(order by t_suburbID) 'row', t_suburbID
				from t_suburb) c on a.row = c.row
		join t_suburb s on c.t_suburbID = s.t_suburbID

print 'Finish generating t_address ' + convert(varchar(20), getdate(), 113) + ' duration:'+ convert(varchar(10), datediff(ss, @startTime, getdate()))

declare @id int

select @id = MAX(addressID) from [address]

update t_address
set	@id = addressID = @id + 1

delete a
from	t_address a
join	(select addressline1, postcode, MIN(addressID) 'addressID' from [t_address] group by addressline1, postcode having COUNT(*) > 1) t on a.addressline1 = t.addressline1 and a.postcode = t.postcode and a.addressid <> t.addressid

set identity_insert [address] on 
insert into [address] (addressID, addressline1, suburb, postcode, [state])
select	a.addressID, a.addressline1, a.suburb, a.postcode, a.[state]
from	t_address a
		join (	select	b.addressID
				from (	select	ROW_NUMBER() over(partition by customerid order by newID()) 'row', a.addressID
						from	t_address a) b
				where	b.row = 1) c on a.addressID = c.addressID
set identity_insert [address] off
				
insert into customerAddress(addressTypeID, customerID, addressID)
select	a.addressTypeID, a.customerID, a.addressID
from	t_address a
		join [address] b on a.addressID = b.addressID

drop table t_address
drop table t_addressLine
drop table t_postcode
drop table t_street
drop table t_suburb
drop table t_person

