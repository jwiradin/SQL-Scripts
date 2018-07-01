/****** Object:  UserDefinedFunction [dbo].[ufn_Split]    Script Date: 07/30/2015 10:59:34 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ufn_Split]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[ufn_Split]
GO

/****** Object:  UserDefinedFunction [dbo].[ufn_Split]    Script Date: 07/30/2015 10:59:34 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- Not mine downloaded from stackoverflow
CREATE FUNCTION [dbo].[ufn_Split]
(   
 @String varchar(max)
,@Delimiter char
)
RETURNS @Results table
(
 Ordinal int
,StringValue varchar(max)
)
as
begin

    set @String = isnull(@String,'')
    set @Delimiter = isnull(@Delimiter,',') -- default ','

    declare
     @TempString varchar(max) = @String
    ,@Ordinal int = 0
    ,@CharIndex int = 0

    set @CharIndex = charindex(@Delimiter, @TempString)
    while @CharIndex != 0 begin     
        set @Ordinal += 1       
        insert @Results values
        (
         @Ordinal
        ,substring(@TempString, 0, @CharIndex)
        )       
        set @TempString = substring(@TempString, @CharIndex + 1, len(@TempString) - @CharIndex)     
        set @CharIndex = charindex(@Delimiter, @TempString)
    end

    if @TempString != '' begin
        set @Ordinal += 1 
        insert @Results values
        (
         @Ordinal
        ,@TempString
        )
    end

    return
end
GO

Grant Select on [dbo].[ufn_Split] to public -- not on production environment
Go
