insert into [user] (userName) values('jsmith')
insert into [user] (userName) values('jdoe')
insert into [user] (userName) values('jbrown')


insert into userrole (userID, roleid) values ((select userid from [user] where username = 'jsmith'), (select roleid from [role] where roleDesc = 'Administrator'))
insert into userrole (userID, roleid) values ((select userid from [user] where username = 'jdoe'), (select roleid from [role] where roleDesc = 'Client'))
insert into userrole (userID, roleid) values ((select userid from [user] where username = 'jdoe'), (select roleid from [role] where roleDesc = 'Secretary'))
insert into userrole (userID, roleid) values ((select userid from [user] where username = 'jbrown'), (select roleid from [role] where roleDesc = 'Manager Responsible'))
insert into userrole (userID, roleid) values ((select userid from [user] where username = 'jbrown'), (select roleid from [role] where roleDesc = 'Acting Manager'))
