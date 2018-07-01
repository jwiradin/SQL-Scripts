-- validate customer
set nocount on
print 'validating customer check'


begin try
	print '--insert company name. Expected result success.'
	insert into customer (companyName, firstName, lastName)
	values ('company', null, null)
	print '--insert company name. Success. ' + convert(varchar(2),@@rowcount) + ' created'

	print '--insert first name and last name. Expected result success.'
	insert into customer (companyName, firstName, lastName)
	values (null, 'firstname', 'lastname')
	print '--insert first name and last name. Success. ' + convert(varchar(2),@@rowcount) + ' created'
end try
begin catch
	print '** This message should not be displayed. failed test'
end catch

begin try
	print '--insert company name, first name and last name. Expected result failed'
	insert into customer (companyName, firstName, lastName)
	values ('company', 'firstname', 'lastname')
	print '**this message should not be displayed. insert company name, first name and last name. success. ' + convert(varchar(2),@@rowcount) + ' created'
end try
begin catch
	print '**insert company name, first name and last name. Failed'
end catch

begin try
	print '--insert last name. Expected result failed'
	insert into customer (companyName, firstName, lastName)
	values (null, null, 'lastname')
	print '**this message should not be displayed. insert last name. success. ' + convert(varchar(2),@@rowcount) + ' created'
end try
begin catch
	print '**insert last name. failed'
end catch

begin try
	print '--insert first name. Expected result failed'
	insert into customer (companyName, firstName, lastName)
	values (null, 'firstName', null)
	print '**this message should not be displayed. insert first name. success. ' + convert(varchar(2),@@rowcount) + ' created'
end try
begin catch
	print '**insert first name. failed'
end catch

print 'validating - address'
--	constraint u_customerAddress unique (customerID, addressTypeID),
begin try
	print '--Inserting a customerAddress expected result success'
	insert into customerAddress (customerID, addressTypeID, addressID)
	values ((select customerid from customer where companyName = 'company'),
			(select top 1 AddressTypeID from addressType order by addressTypeID),
			(select top 1 addressID from address order by NEWID()))
	print '--Inserting a customeraddress success. ' + convert(varchar(2),@@rowcount) + ' created'

	print '--Inserting a customerAddress with duplicate addressID but different addresstypeid expected result success'
	insert into customerAddress (customerID, addressTypeID, addressID)
	values ((select customerid from customer where companyName = 'company'),
			(select top 1 AddressTypeID from addressType order by addressTypeID desc),
			(select top 1 addressID from address order by NEWID()))
	print '--Inserting a customerAddress with duplicate addressID but different addresstypeid. success. ' + convert(varchar(2),@@rowcount) + ' created'
	
	print '--Inserting a customerAddress with duplicate addressTypeID expected result failed'
	insert into customerAddress (customerID, addressTypeID, addressID)
	values ((select customerid from customer where companyName = 'company'),
			(select top 1 AddressTypeID from addressType order by addressTypeID),
			(select top 1 addressID from address order by NEWID()))
	print '**this message should not be displayed. Inserting a customeraddress with duplicate addressTypeID. success.'
			
end try
begin catch
	print '**Inserting a customeraddress with duplicate addressTypeID failed.'
end catch

-- cleaning up
delete customeraddress
where	customerid = (select customerid from customer where companyName = 'company')

delete customer
where	companyName = 'company'

delete customer
where	firstname = 'firstname'
and		lastname = 'lastname'
