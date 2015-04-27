/****** Object:  UserDefinedFunction [dbo].[ZRT_ItemVendGetPriceSp]    Script Date: 09/29/2014 10:39:36 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ZPV_ItemVendGetPriceSp]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[ZPV_ItemVendGetPriceSp]
GO

/****** Object:  UserDefinedFunction [dbo].[ZPV_ItemVendGetPriceSp]    Script Date: 09/29/2014 10:39:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[ZPV_ItemVendGetPriceSp]
(
@Item	ItemType
)
RETURNS CostPrcType
AS
BEGIN

/*
Esta funcion no considera que el item/price puede ser diferente a la moneda local.
Asume siempre el monto en moneda local.

*/
DECLARE
@UnitPrice CostPrcType


SELECT TOP 1 @UnitPrice =  unit_price1
		FROM itemprice
		WHERE item = @Item
			AND effect_date <= dbo.MidnightOf (GetDate()) 
			ORDER BY effect_date DESC
			
SET @UnitPrice = ISNULL(@UnitPrice ,0)
       
RETURN @UnitPrice       
END
GO

