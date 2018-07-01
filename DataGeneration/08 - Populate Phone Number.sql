declare @startTime datetime

begin try
-- total time 2 minutes

if OBJECT_ID('t_areacode') is null
begin
	create table t_areacode (code char(2), [state] varchar(3))

	insert into t_areacode (code, [state])
	select	a.code, a.state
	from (values('02', 'NSW'),('02','ACT'),('03','VIC'),('03','TAS'),('04','MOB'),('07','QLD'),('08','WA'),('08','SA'),('08','NT')) as a(code,[state])
end

if OBJECT_ID('t_phonestart') is null
begin
	create table t_phonestart (part varchar(2))
	
	insert into t_phonestart (part)
	values ('2'), ('3'), ('7'), ('8'), ('9'), ('25'), ('26'), ('32'), ('33'), ('34'), ('37'), ('38'), ('39'), ('40'), ('41'), ('42'), ('43'), ('44'), ('45'), ('46'), ('47'), ('48'), ('49'), ('50'), ('51'), ('52'), ('53'), ('54'), ('55'), ('56'), ('57'), ('58'), ('59'), ('60'), ('61'), ('62'), ('63'), ('64'), ('65'), ('66'), ('67'), ('68'), ('69'), ('70'), ('71'), ('72'), ('73'), ('74'), ('75'), ('76')

	insert into t_phonestart (part)
	values ('77'), ('78'), ('79'), ('80'), ('81'), ('82'), ('83'), ('84'), ('85'), ('86'), ('87'), ('88'), ('89'), ('90'), ('91'), ('92'), ('93'), ('94'), ('95'), ('96'), ('97'), ('98'), ('99')
end

-- set up primary phone
/*
contactTypeID	contactTypeDesc
8	Home
9	Business
10	Office
*/

declare @primaryInd int,
		@PrimaryCo int,
		@other int,
		@primaryAddr int

select @primaryInd = contacttypeid from contactType where contactTypeDesc = 'Home'
select @primaryCo = contacttypeid from contactType where contactTypeDesc = 'Office'
select @other = contacttypeid from contactType where contactTypeDesc = 'Other'
select @primaryAddr = addresstypeid from addressType where addressTypeDesc = 'Street'

select @startTime = GETDATE()

print 'Starting generating empty rows for primary phones ' + convert(varchar(20), @starttime, 113)

insert into phone (customerID, contactTypeID, phoneNumber)
select	c.customerID,
		case when ISNULL(c.ACN,'') = '' then @primaryInd else @PrimaryCo end 'contactTypeID',
		''
from	customer c
	join customerAddress ca on c.customerID = ca.customerID
	join [address] a on ca.addressID = a.addressID
where	ca.addressTypeID = @primaryAddr

print 'Finish generating empty rows for primary phones ' + convert(varchar(20), getdate(), 113) + ' duration:'+ convert(varchar(10), datediff(ss, @startTime, getdate()))

select @primaryInd = contacttypeid from contactType where contactTypeDesc = 'Home'
select @primaryCo = contacttypeid from contactType where contactTypeDesc = 'Office'
select @other = contacttypeid from contactType where contactTypeDesc = 'Other'

set @startTime = GETDATE()
print 'Starting generating empty rows for secondary phones ' + convert(varchar(20), @starttime, 113)
insert into phone (customerID, contactTypeID, phoneNumber)
select	c.customerID,
		@other 'contactTypeID',
		''
from	customer c
	join customerAddress ca on c.customerID = ca.customerID
	join [address] a on ca.addressID = a.addressID
where	ca.addressTypeID <> @primaryAddr
print 'Finish generating empty rows for secondary phones ' + convert(varchar(20), getdate(), 113) + ' duration:'+ convert(varchar(10), datediff(ss, @startTime, getdate()))

-- populate phone numbers
declare @count int
set @count = 0

-- loop 10 times regardless
set @startTime = GETDATE()
print 'Starting generating phone numbers ' + convert(varchar(20), @starttime, 113)

while @count < 10
begin
	-- remove duplicate and update again
	update	p
	set		phoneNumber = ''
	from	phone p
			join (select MAX(phoneID) phoneID from phone where phonenumber <> '' group by phoneNumber having COUNT(*) > 1) a on p.phoneID = a.phoneID

	-- set phone numbers
	update	p
	set		phoneNumber = ac.code + left((select top 1 part from t_phonestart order by NEWID()) + convert(varchar(20),abs(CHECKSUM(newID()))),8)
	from	phone p
			join customerAddress ca on ca.customerID = p.customerID
			join [address] a on ca.addressID = a.addressID
			join t_areacode ac on a.[state] = ac.[state]
	where	p.phoneNumber = ''
	
	set @count = @count + 1
end
print 'Finish generating phone numbers ' + convert(varchar(20), getdate(), 113) + ' duration:'+ convert(varchar(10), datediff(ss, @startTime, getdate()))

select phonenumber, COUNT(*) from phone group by phoneNumber having COUNT(*) > 1
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

-- clean up
if OBJECT_ID('t_areaCode') is not null
	drop table t_areacode
	
if OBJECT_ID('t_phonestart') is not null
	drop table t_phonestart
