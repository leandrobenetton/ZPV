DECLARE	@return_value int,
		@Infobar InfobarType

EXEC	@return_value = [dbo].[TriggerIupCodeWrapperSp]
		@StartingTableName = null,
		@EndingTableName = null,
		@Infobar = @Infobar OUTPUT

SELECT	@Infobar as N'@Infobar'

SELECT	'Return Value' = @return_value

GO

