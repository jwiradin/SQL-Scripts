
create table #t_cust (firstname varchar(50), lastname varchar(50), companyname varchar(100), acn varchar(9))

insert into #t_cust (firstname, lastname, companyname, acn)
select	top 650000 a.firstname, b.lastname, null, null
from (select distinct firstname from t_person) a
	cross join (select distinct lastname from t_person) b
order by NEWID()

insert into #t_cust (firstname, lastname, companyname, acn)
select	top 350000 null , null , s.streetname + ' ' + a.companyType companyname, left(convert(varchar(11),abs(CHECKSUM(newid()))) + '01',9) ACN
from	t_street s
	cross join (values ('Trading'), ('Farm'), ('Plumbers'), ('Electrician'), ('Tiler'), ('Concreting'), ('Corporation Pty Ltd'), ('Engineering Pty Ltd'), ('Pharmacy'), ('Consulting'),('Estate'), ('Associates'), ('Construction'), ('Marine'), ('Securities Pty Ltd'), ('Publishing')) as a(companyType) 
order by NEWID()

insert into customer( firstname, lastname, companyname, acn, abn)
select firstname, lastname, companyname, acn, '01' + acn
from 
#t_cust
order by NEWID()
