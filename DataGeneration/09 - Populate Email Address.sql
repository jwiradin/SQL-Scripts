declare @startTime datetime
-- total time 1:30 min
begin try

create table #t_domain (domainName varchar(100))

insert into #t_domain (domainName)
values ('yahoo.com'), ('hotmail.com'), ('outlook.com'), ('gmail.com'), ('ebay.com'), ('ebay.co.uk'), ('tpg.com.au'), ('iinet.com.au'), ('telstra.com'), ('optus.com.au'), ('internode.com.au'), ('exetel.com.au'), ('facebook.com')

declare @primaryInd int,
		@PrimaryCo int,
		@other int,
		@primaryAddr int

select @primaryInd = contacttypeid from contactType where contactTypeDesc = 'Home'
select @primaryCo = contacttypeid from contactType where contactTypeDesc = 'Office'
select @other = contacttypeid from contactType where contactTypeDesc = 'Other'

select @startTime = GETDATE()

print 'Starting generating empty rows for emails ' + convert(varchar(20), @starttime, 113)

insert into email (customerID, contactTypeID, emailaddress)
select	c.customerID,
		case when ISNULL(c.ACN,'') = '' then @primaryInd else @PrimaryCo end 'contactTypeID',
		''
from	customer c

print 'Finish generating empty rows for primary emails ' + convert(varchar(20), getdate(), 113) + ' duration:'+ convert(varchar(10), datediff(ss, @startTime, getdate()))

select @primaryInd = contacttypeid from contactType where contactTypeDesc = 'Home'
select @primaryCo = contacttypeid from contactType where contactTypeDesc = 'Office'
select @other = contacttypeid from contactType where contactTypeDesc = 'Other'

set @startTime = GETDATE()
print 'Starting generating empty rows for secondary emails ' + convert(varchar(20), @starttime, 113)

insert into email (customerID, contactTypeID, emailaddress)
select	c.customerID,
		@other 'contactTypeID',
		''
from	customer c
print 'Finish generating empty rows for secondary emails ' + convert(varchar(20), getdate(), 113) + ' duration:'+ convert(varchar(10), datediff(ss, @startTime, getdate()))

-- populate emails
declare @count int
set @count = 0

-- loop 10 times regardless
set @startTime = GETDATE()
print 'Starting generating emails ' + convert(varchar(20), @starttime, 113)

while @count < 10
begin
	-- remove duplicate and update again
	update	e
	set		emailaddress = ''
	from	email e
			join (select MAX(emailID) emailID from email where emailaddress <> '' group by emailaddress having COUNT(*) > 1) a on e.emailID = a.emailID

	-- set email address
	update	e
	set		emailAddress = case when isnull(c.firstName,'') <> '' then LEFT(c.firstname,1)+c.lastName else 'admin.' + REPLACE(c.companyname,' ','') end +
				right('000' + convert(varchar(3), abs(CHECKSUM(newID())) % 1000),3) + '@' + (select top 1 domainName from #t_domain order by NEWID())
	from	email e
			join customer c on c.customerID = e.customerID
	where	e.emailAddress = ''
	
	set @count = @count + 1
end
print 'Finish generating email address ' + convert(varchar(20), getdate(), 113) + ' duration:'+ convert(varchar(10), datediff(ss, @startTime, getdate()))

select emailAddress, COUNT(*) from email group by emailaddress having COUNT(*) > 1
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
