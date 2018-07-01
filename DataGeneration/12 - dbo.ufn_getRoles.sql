/****** Object:  UserDefinedFunction [dbo].[ufn_getRoles]    Script Date: 07/30/2015 10:59:34 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ufn_getRoles]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[ufn_getRoles]
GO

/****** Object:  UserDefinedFunction [dbo].[ufn_getRoles]    Script Date: 07/30/2015 10:59:34 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[ufn_getRoles]
(   
	@userID int
)
RETURNS @Results table
(
	roleID int
)
as
begin

	if (select count(*) from [user] u join userRole ur on u.userId = ur.userID join [role] r on r.roleID = ur.RoleID where r.roleDesc = 'Administrator' and u.userID = @UserID) = 1
		insert into @results
		select	roleID
		from	[role]
	else
		insert into @results
		select	roleID
		from	userRole
		where	userID = @UserID
	
    return
end
GO

Grant Select on [dbo].[ufn_getRoles] to public -- not in production environment
Go
