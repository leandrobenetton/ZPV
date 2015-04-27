/****** Object:  StoredProcedure [dbo].[ZPV_CLM_RetailCOCustomerDataSp]    Script Date: 19/02/2015 15:50:20 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ZPV_CLM_RetailCOCustomerDataSp]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[ZPV_CLM_RetailCOCustomerDataSp]
GO

/****** Object:  StoredProcedure [dbo].[ZPV_CLM_RetailCOCustomerDataSp]    Script Date: 19/02/2015 15:50:20 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[ZPV_CLM_RetailCOCustomerDataSp](
	@pPathFile		varchar(500)	= null
,	@pCustNum		CustNumType		= null
,	@Infobar		InfobarType		= null OUTPUT)
 
AS
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

EXEC sp_configure 'Show Advanced Options', 1
RECONFIGURE

EXEC sp_configure 'Ad Hoc Distributed Queries', 1
RECONFIGURE

DECLARE 
	@Site SiteType
	
SELECT @Site = site FROM site
EXEC [dbo].[SetSiteSp] @Site, @Infobar OUTPUT

declare
	@Severity		int
,	@Path			varchar(255)
,	@PathCompleto	varchar(255)

set @Severity = 0

declare @tt_info table(
	tt_f12				numeric(20) 
,	tt_ocompra			varchar(100)
,	tt_asesor			varchar(100)
,	tt_sucursal			varchar(100)
,	tt_nombre			varchar(100)
,	tt_nit				varchar(100)
,	tt_telefono1		varchar(100)
,	tt_telefono2		varchar(100)
,	tt_direccion		varchar(100)
,	tt_barrio			varchar(100)
,	tt_indicaciones		varchar(100)
,	tt_ciudad			varchar(100)
,	tt_zona				varchar(100)
,	tt_depto			varchar(100)
,	tt_email			varchar(100)
,	tt_fecha_ent		DateType
,	tt_obsequio			varchar(4000)
,	tt_obs				varchar(4000))
	
declare
	@SQL				LongListType
,	@File				LongListType
,	@File1				LongListType
,	@File2				LongListType
,	@File3				LongListType
,	@TB2BF12			numeric(20)	 
,	@TB2BOCompra		varchar(100)
,	@TB2BAsesor			varchar(100)
,	@TB2BSucursal		varchar(100)
,	@TB2BNombre			varchar(100)
,	@TB2BNit			varchar(100)
,	@TB2BTelefono1		varchar(100)
,	@TB2BTelefono2		varchar(100)
,	@TB2BDireccion		varchar(100)
,	@TB2BBarrio			varchar(100)
,	@TB2BIndicaciones	varchar(100)
,	@TB2BCiudad			varchar(100)
,	@TB2BZona			varchar(100)
,	@TB2BDepto			varchar(100)
,	@TB2BEmail			varchar(100)
,	@TB2BFechaEnt		DateType
,	@TB2BObsequio		varchar(4000)
,	@TB2BObs			varchar(4000)
-------------------------------------
,	@CoCustSeq			CustSeqType
,	@CoCustNum			CustNumType
,	@CoCoNum			CoNumType
,	@CoWhse				WhseType

declare
	@CoBlnCoNum				CoNumType
,	@CoBlnCoLine			CoLineType
,	@CoBlnItem				ItemType
,	@CoBlnDescription		DescriptionType
,	@CoBlnCustItem			CustItemType
,	@CoBlnBlanketQty		QtyUnitType
,	@CoBlnContPrice			AmountType
,	@CoBlnStat				varchar(1)
,	@CoBlnPromiseDate		DateType
,	@CoBlnUM				UMType
,	@CoBlnBlanketQtyConv	QtyUnitType
,	@CoBlnContPriceConv		AmountType
,	@CoBlnShipSite			SiteType
,	@CoBlnCostConv			AmountType
,	@CoBlnZpvTotal			AmountType
,	@CoBlnZpvTotalDisc		AmountType
,	@CoBlnZpvTaxCode1		TaxCodeType
,	@CoBlnZpvTaxCode2		TaxCodeType
,	@CoBlnZpvQtyShipped		QtyUnitType
,	@CoBlnZpvQtyReturned	QtyUnitType
,	@CoBlnZpvQtyInvoiced	QtyUnitType
,	@CoBlnZpvUnitPrice		AmountType
,	@CoBlnZpvCoDisc			AmountType
,	@CoBlnZpvSalesTax		AmountType
,	@CoBlnZpvSalesTax2		AmountType
	
select 
	@Path = par.data_import_path
from zpv_parms par
where par.parms_key = 0

if @pPathFile is not null and @Path is not null
begin

	BEGIN TRANSACTION;

	BEGIN TRY
		set @PathCompleto = @Path + @pPathFile
		
		set @File1 = '''Microsoft.ACE.OLEDB.12.0'''
		set @File2 = '''Excel 12.0 Xml;HDR=YES;Database=' + @PathCompleto + ''''
		set @File3 = '''SELECT * FROM [b2bprom$]'''

		set @File = @File1 + ',' + @File2 + ',' + @File3
 
		-- Process
		BEGIN
 			set @SQL = 'select * from OPENROWSET(' + @File + ')'
			
			insert into @tt_info(
						tt_f12			
					,	tt_ocompra
					,	tt_asesor
					,	tt_sucursal
					,	tt_nombre
					,	tt_nit
					,	tt_telefono1
					,	tt_telefono2
					,	tt_direccion
					,	tt_barrio	
					,	tt_indicaciones
					,	tt_ciudad
					,	tt_zona
					,	tt_depto
					,	tt_email
					,	tt_fecha_ent
					,	tt_obsequio
					,	tt_obs)
				
  
			EXECUTE sp_executesql @SQL
	
		END

		declare CurB2B cursor for
		select
			tt_f12			
		,	tt_ocompra
		,	tt_asesor
		,	tt_sucursal
		,	tt_nombre
		,	tt_nit
		,	tt_telefono1
		,	tt_telefono2
		,	tt_direccion
		,	tt_barrio	
		,	tt_indicaciones
		,	tt_ciudad
		,	tt_zona
		,	tt_depto
		,	tt_email
		,	tt_fecha_ent
		,	tt_obsequio
		,	tt_obs
		from @tt_info where tt_f12 is not null
		open CurB2B
		fetch next from CurB2B
		into
			@TB2BF12			 
		,	@TB2BOcompra
		,	@TB2BAsesor
		,	@TB2BSucursal
		,	@TB2BNombre	
		,	@TB2BNit
		,	@TB2BTelefono1
		,	@TB2BTelefono2
		,	@TB2BDireccion
		,	@TB2BBarrio	
		,	@TB2BIndicaciones
		,	@TB2BCiudad	
		,	@TB2BZona
		,	@TB2BDepto	
		,	@TB2BEmail	
		,	@TB2BFechaEnt
		,	@TB2BObsequio
		,	@TB2BObs			

		while @@FETCH_STATUS = 0
		begin
			select 
					@CoCustSeq	= co.cust_seq
				,	@CoCustNum	= co.cust_num
				,	@CoCoNum	= co.co_num
				,	@CoWhse		= co.whse
			from co
			where co.zpv_f12 = @TB2BF12 and co.zpv_stat = 'E00'

			if @CoCustNum is not null
			begin
				
				update co	
					set co.zpv_bill_addr1	= substring(@TB2BDireccion,0,50)
					,	co.zpv_bill_addr2	= substring(@TB2BBarrio,0,50)
					,	co.zpv_bill_addr3	= substring(@TB2BIndicaciones,0,50)
					,	co.zpv_bill_city	= substring(@TB2BCiudad,0,30)
					,	co.zpv_bill_county	= substring(@TB2BZona,0,30)
					,	co.zpv_bill_state	= substring(@TB2BDepto,0,30)
					,	co.zpv_bill_email	= substring(@TB2BEmail,0,100)
					,	co.zpv_bill_fiscal_name = substring(@TB2BNombre,0,100)
					,	co.zpv_bill_cuit	= substring(@TB2BNit,0,13)
					,	co.zpv_phone		= substring(@TB2BTelefono1,0,25)
					,	co.zpv_slsman		= substring(@TB2BAsesor,0,8)
					,	co.zpv_pos			= substring(@TB2BSucursal,0,15)
					,	co.zpv_stat				= 'R00'
					,	co.zpv_stat_internal	= 'R00'
				where co.co_num = @CoCoNum 

				if exists(select 1 from custaddr cad where  cad.cust_num = @CoCustNum and cad.cust_seq =  @CoCustSeq)
				begin
					update custaddr
						set	custaddr.addr##1	= substring(@TB2BDireccion,0,50)
						,	custaddr.addr##2	= substring(@TB2BBarrio,0,50)
						,	custaddr.addr##3	= substring(@TB2BIndicaciones,0,50)
						,	custaddr.city		= substring(@TB2BCiudad,0,30)
						,	custaddr.county		= substring(@TB2BZona,0,30)
						,	custaddr.state		= substring(@TB2BDepto,0,30)
						,	custaddr.internal_email_addr	= substring(@TB2BEmail,0,100)
						,	custaddr.zpv_obs	= @TB2BObs
					where	custaddr.cust_num	= @CoCustNum
						and	custaddr.cust_seq	= @CoCustSeq

					update customer
						set	customer.phone##1	= substring(@TB2BTelefono1,0,25)
						,	customer.phone##2	= substring(@TB2BTelefono2,0,25)
						,	customer.tax_reg_num1 = substring(@TB2BNit,0,13)
					where	customer.cust_num	= @CoCustNum
						and	customer.cust_seq	= @CoCustSeq
				end
				else
				begin
					exec @Severity = [dbo].[ZPV_GenerateShipToSp]
						@pCoNum		= @CoCoNum
					,	@Infobar    = @Infobar        OUTPUT

					select
						@CoCustSeq = co.cust_seq
					from co
					where co.co_num = @CoCoNum

					update custaddr
						set	custaddr.addr##1	= substring(@TB2BDireccion,0,50)
						,	custaddr.addr##2	= substring(@TB2BBarrio,0,50)
						,	custaddr.addr##3	= substring(@TB2BIndicaciones,0,50)
						,	custaddr.city		= substring(@TB2BCiudad,0,30)
						,	custaddr.county		= substring(@TB2BZona,0,30)
						,	custaddr.state		= substring(@TB2BDepto,0,30)
						,	custaddr.internal_email_addr	= substring(@TB2BEmail,0,100)
						,	custaddr.zpv_obs	= @TB2BObs
					where	custaddr.cust_num	= @CoCustNum
						and	custaddr.cust_seq	= @CoCustSeq

					update customer
						set	customer.phone##1	= substring(@TB2BTelefono1,0,25)
						,	customer.phone##2	= substring(@TB2BTelefono2,0,25)
						,	customer.tax_reg_num1 = substring(@TB2BNit,0,13)
					where	customer.cust_num	= @CoCustNum
						and	customer.cust_seq	= @CoCustSeq

				end
				if @TB2BObsequio IS NOT NULL
				begin
					select 
						@CoBlnItem			= item.item
					,	@CoBlnDescription	= item.description
					,	@CoBlnZpvTaxCode1	= item.tax_code1
					,	@CoBlnZpvTaxCode2	= item.tax_code2
					,	@CoBlnUM			= item.u_m
					from item 
					where	item.item		= @TB2BObsequio
					
					if @CoBlnItem is not null
					begin
						
						select top 1
							@CoBlnCoLine = cob.co_line + 1
						from co_bln cob
						where cob.co_num = @CoCoNum
						order by cob.co_line desc

						if @CoBlnCoLine is null set @CoBlnCoLine = 1

						select
							@CoBlnZpvSalesTax		= 0
						,	@CoBlnZpvSalesTax2		= 0
						,	@CoBlnCoNum				= @CoCoNum	
						,	@CoBlnCustItem			= null	
						,	@CoBlnBlanketQty		= 1
						,	@CoBlnContPrice			= 0
						,	@CoBlnStat				= 'P'
						,	@CoBlnPromiseDate		= @TB2BFechaEnt
						,	@CoBlnBlanketQtyConv	= 1
						,	@CoBlnContPriceConv		= 0
						,	@CoBlnShipSite			= @Site
						,	@CoBlnCostConv			= 0
						,	@CoBlnZpvTotal			= 0
						,	@CoBlnZpvTotalDisc		= 0
						,	@CoBlnZpvTaxCode1		= null
						,	@CoBlnZpvTaxCode2		= null
						,	@CoBlnZpvQtyShipped		= 0
						,	@CoBlnZpvQtyReturned	= 0
						,	@CoBlnZpvQtyInvoiced	= 0
						,	@CoBlnZpvUnitPrice		= (@CoBlnContPrice + @CoBlnZpvSalesTax + @CoBlnZpvSalesTax2)
						,	@CoBlnZpvCoDisc			= 0
						
		
						insert into co_bln(
							co_num
						,	co_line
						,	item
						,	description
						,	cust_item
						,	blanket_qty
						,	cont_price
						,	stat
						,	promise_date
						,	u_m
						,	blanket_qty_conv
						,	cont_price_conv
						,	ship_site
						,	cost_conv
						,	zpv_total
						,	zpv_total_disc
						,	zpv_tax_code1
						,	zpv_tax_code2
						,	zpv_qty_shipped
						,	zpv_qty_returned
						,	zpv_qty_invoiced
						,	zpv_unit_price
						,	zpv_co_disc
						,	zpv_sales_tax
						,	zpv_sales_tax2
						,	zpv_res_whse
						,	zpv_ship_whse)
						values(
							@CoBlnCoNum				
						,	@CoBlnCoLine			
						,	@CoBlnItem				
						,	@CoBlnDescription	
						,	@CoBlnCustItem			
						,	@CoBlnBlanketQty		
						,	@CoBlnContPrice			
						,	@CoBlnStat				
						,	@CoBlnPromiseDate		
						,	@CoBlnUM				
						,	@CoBlnBlanketQtyConv	
						,	@CoBlnContPriceConv		
						,	@CoBlnShipSite			
						,	@CoBlnCostConv			
						,	@CoBlnZpvTotal			
						,	@CoBlnZpvTotalDisc		
						,	@CoBlnZpvTaxCode1		
						,	@CoBlnZpvTaxCode2		
						,	@CoBlnZpvQtyShipped		
						,	@CoBlnZpvQtyReturned	
						,	@CoBlnZpvQtyInvoiced	
						,	@CoBlnZpvUnitPrice		
						,	@CoBlnZpvCoDisc			
						,	@CoBlnZpvSalesTax		
						,	@CoBlnZpvSalesTax2
						,	@CoWhse
						,	@CoWhse)
					end	
				end
			end
			else
			begin
				set @Infobar = 'El Pedido no fue previamente cargado, no se encuentra F12. O no tiene estado de Cotizacion'
				break 
			end
			
			fetch next from CurB2B
			into
				@TB2BF12			 
			,	@TB2BOcompra
			,	@TB2BAsesor
			,	@TB2BSucursal
			,	@TB2BNombre	
			,	@TB2BNit
			,	@TB2BTelefono1
			,	@TB2BTelefono2
			,	@TB2BDireccion
			,	@TB2BBarrio	
			,	@TB2BIndicaciones
			,	@TB2BCiudad	
			,	@TB2BZona
			,	@TB2BDepto	
			,	@TB2BEmail	
			,	@TB2BFechaEnt
			,	@TB2BObsequio
			,	@TB2BObs
		end
		close CurB2B
		deallocate CurB2B

	END TRY
	BEGIN CATCH
		SET @Infobar = 'No se encuentra el archivo, este está abierto o existe un problema con el formato del mismo'
		SELECT 
			 ERROR_NUMBER() AS ErrorNumber
			,ERROR_SEVERITY() AS ErrorSeverity
			,ERROR_STATE() AS ErrorState
			,ERROR_PROCEDURE() AS ErrorProcedure
			,ERROR_LINE() AS ErrorLine
			,ERROR_MESSAGE() AS ErrorMessage;

		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;
	END CATCH;

	IF @@TRANCOUNT > 0
		COMMIT TRANSACTION;
end


GO
