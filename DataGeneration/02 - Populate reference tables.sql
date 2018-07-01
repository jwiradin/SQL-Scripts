-- Populate role table
insert into [role] (roleDesc) values ('Administrator')
insert into [role] (roleDesc) values ('Client')
insert into [role] (roleDesc) values ('Manager Responsible')
insert into [role] (roleDesc) values ('Acting Manager')
insert into [role] (roleDesc) values ('Secretary')

-- populate contact type
insert into contactType (contactTypeDesc) values ('Home')
insert into contactType (contactTypeDesc) values ('Business')
insert into contactType (contactTypeDesc) values ('Office')
insert into contactType (contactTypeDesc) values ('Other')

-- populate address type
insert into addressType (addressTypeDesc) values ('Street')
insert into addressType (addressTypeDesc) values ('Postal')
insert into addressType (addressTypeDesc) values ('Registered Office')

-- populate category
insert into category (categoryDesc) values ('Security door')
insert into category (categoryDesc) values ('Video surveillance')
insert into category (categoryDesc) values ('Security window')
insert into category (categoryDesc) values ('Security access')
