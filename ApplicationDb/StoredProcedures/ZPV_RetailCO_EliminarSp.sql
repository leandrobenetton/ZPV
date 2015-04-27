/****** Object:  StoredProcedure [dbo].[ZPV_RetailCO_EliminarSp]    Script Date: 19/02/2015 15:50:20 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ZPV_RetailCO_EliminarSp]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[ZPV_RetailCO_EliminarSp]
GO

/****** Object:  StoredProcedure [dbo].[ZPV_RetailCO_EliminarSp]    Script Date: 19/02/2015 15:50:20 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[ZPV_RetailCO_EliminarSp](
	@pCustNum		CustNumType = null
,	@Infobar		InfobarType output)

AS

DECLARE 
	@Site SiteType
	
SELECT @Site = site FROM site
EXEC [dbo].[SetSiteSp] @Site, @Infobar OUTPUT

declare
	@Severity		int

set @Severity = 0

declare
	@CoCoNum		CoNumType

declare CurCoNumB2B cursor for
select
	co.co_num
from co
where	co.cust_num	= @pCustNum
	and	co.zpv_f12 is not null
	and co.stat = 'P'
	and co.zpv_stat = 'E00'
open CurCoNumB2B
fetch next from CurCoNumB2B 
into
	@CoCoNum
while @@FETCH_STATUS = 0
begin
	delete from coitem where co_num = @CoCoNum

	delete from co_bln where co_num = @CoCoNum

	delete from co where co_num = @CoCoNum

	fetch next from CurCoNumB2B 
	into
		@CoCoNum
end
close CurCoNumB2B
deallocate CurCoNumB2B


if @Severity = 0
	set @Infobar = 'Pedidos Eliminado'
else
	set @Infobar = 'Error al eliminar pedidos'


go