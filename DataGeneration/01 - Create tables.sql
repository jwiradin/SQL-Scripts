/*
drop table customer
drop table category
drop table email
drop table phone
drop table address
drop table contacttype
drop table addresstype

*/

-- Customer information
create table customer(
	customerID int not null identity,
	companyName varchar(100) null,
	firstName varchar(50) null,
	lastName varchar(50) null, 
	ACN char(9) null,
	ABN char(11) null,
	constraint pk_customer Primary Key (customerID)
)

alter table customer add constraint c_requiredName check ( 
	(companyName is not null and firstName is null and lastName is null) 
	or (companyName is null and firstName is not null and lastName is not null) )

create table [address](
	addressID int not null identity,
	addressline1 varchar(100) not null,
	addressline2 varchar(100),
	suburb varchar(50) not null,
	postcode varchar(4) not null,
	[state] varchar(3) not null,
	constraint pk_address Primary Key nonclustered (AddressID) 
)
create clustered index ic_address_suburb on [address](suburb)
create index i_address_state on [address]([state]) include(addressID)

create table category(
	categoryID int not null identity,
	categoryDesc varchar(100) not null,
	constraint pk_category primary key (categoryID)
)

create table addressType(
	addressTypeID int not null identity,
	addressTypeDesc varchar(100) not null,
	constraint pk_addressType primary key (addressTypeID)
)

-- this table is used by email and phone home/personal/business. If required can create a separate table for email and phone.
create table contactType(
	contactTypeID int not null identity,
	contactTypeDesc varchar(100) not null,
	constraint pk_contactType primary key (contactTypeID)
)

create table email(
	emailID int not null identity,
	customerID int not null,
	contactTypeID int not null,
	emailAddress varchar(100) not null,
	constraint pk_email primary key (emailID),
	constraint fk_email_customer foreign key (customerID) references customer(customerID),
	constraint fk_email_contactType foreign key (contactTypeID) references contactType(contactTypeID)
)

create index i_email_customerID on email(customerID) include (emailAddress)

create table phone(
	phoneID int not null identity,
	customerID int not null,
	contactTypeID int not null,
	phoneNumber varchar(10) not null,
	constraint pk_phone primary key (phoneID),
	constraint fk_phone_customer foreign key (customerID) references customer(customerID),
	constraint fk_phone_contactType foreign key (contactTypeID) references contactType(contactTypeID)
)

create index i_phone_customerID on phone(customerID) include (phoneNumber)

-- joint table for customer address.  A customer can only have one address type.  reasoning for many to many to allow other address to be "same as home"
-- otherwise use one to many.
create table customerAddress(
	customerAddressID int not null identity,
	addressTypeID int not null,
	customerID int not null,
	addressID int not null,
	constraint pk_customerAddress primary key (customerAddressID),
	constraint u_customerAddress unique (customerID, addressTypeID),
	constraint fk_customerAddress_customer foreign key (customerID) references customer(customerID),
	constraint fk_customerAddress_address foreign key (addressID) references [address](addressID),
	constraint fk_customerAddress_addressType foreign key (addressTypeID) references addressType(addressTypeID)
)

CREATE NONCLUSTERED INDEX i_customerAddress_AddressID ON [dbo].[customerAddress] ([addressID]) INCLUDE ([customerID])

-- join table for customer Marketing category. a category can only be assigned once.
create table customerCategory(
	customerCategoryID int not null identity,
	customerID int not null,
	categoryID int not null,
	constraint pk_customerCategory primary key (customerCategoryID),
	constraint u_customerCategory unique (customerID, categoryID),
	constraint fk_customerCategory_customer foreign key (customerID) references customer(customerID),
	constraint fk_customerCategory_category foreign key (categoryID) references category(categoryID)
)

create table [user](
	userID int not null identity,
	userName varchar(100) not null,
	constraint pk_user primary key (userID)
)

create table [role](
	roleID int not null identity,
	roleDesc varchar(100) not null,
	constraint pk_role primary key (roleID)
)

create table userRole(
	userRoleID int not null identity,
	userID int not null,
	roleID int not null,
	constraint pk_userRole primary key (userRoleID),
	constraint u_userRole unique (userID, roleID),
	constraint fk_userRole_user foreign key (userID) references [user](userID),
	constraint fk_userRole_role foreign key (roleID) references [role](roleID) 
)

create table accessRole(
	accessRoleID int not null identity,
	customerID int not null,
	roleID int not null,
	constraint pk_accessRole primary key (accessRoleID),
	constraint u_accessRole unique (customerID, roleID),
	constraint fk_accessRole_customer foreign key (customerID) references [customer](customerID),
	constraint fk_accessRole_role foreign key (roleID) references [role](roleID) 
)