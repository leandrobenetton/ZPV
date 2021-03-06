IF NOT (EXISTS(SELECT * FROM sys.types st JOIN sys.schemas ss ON st.schema_id = ss.schema_id WHERE st.name = N'ZlaProcessModeType' AND ss.name = N'dbo'))
CREATE TYPE [dbo].[ZlaProcessModeType]
	FROM [nchar](1)
	NULL
GO
IF NOT (EXISTS(SELECT * FROM sys.types st JOIN sys.schemas ss ON st.schema_id = ss.schema_id WHERE st.name = N'ZlaPostGroupType' AND ss.name = N'dbo'))
CREATE TYPE [dbo].[ZlaPostGroupType]
	FROM [nchar](1)
	NULL
GO
IF NOT (EXISTS(SELECT * FROM sys.types st JOIN sys.schemas ss ON st.schema_id = ss.schema_id WHERE st.name = N'zlaPostedType' AND ss.name = N'dbo'))
CREATE TYPE [dbo].[zlaPostedType]
	FROM [nchar](1)
	NULL
GO
IF NOT (EXISTS(SELECT * FROM sys.types st JOIN sys.schemas ss ON st.schema_id = ss.schema_id WHERE st.name = N'ZlaSeparatorCharType' AND ss.name = N'dbo'))
CREATE TYPE [dbo].[ZlaSeparatorCharType]
	FROM [nchar](1)
	NULL
GO
IF NOT (EXISTS(SELECT * FROM sys.types st JOIN sys.schemas ss ON st.schema_id = ss.schema_id WHERE st.name = N'ZlaRptGroupType' AND ss.name = N'dbo'))
CREATE TYPE [dbo].[ZlaRptGroupType]
	FROM [nvarchar](10)
	NULL
GO
IF NOT (EXISTS(SELECT * FROM sys.types st JOIN sys.schemas ss ON st.schema_id = ss.schema_id WHERE st.name = N'ZlaProcessTypeType' AND ss.name = N'dbo'))
CREATE TYPE [dbo].[ZlaProcessTypeType]
	FROM [nchar](1)
	NULL
GO
IF NOT (EXISTS(SELECT * FROM sys.types st JOIN sys.schemas ss ON st.schema_id = ss.schema_id WHERE st.name = N'ZlaPadronRetPctType' AND ss.name = N'dbo'))
CREATE TYPE [dbo].[ZlaPadronRetPctType]
	FROM [decimal](6, 3)
	NULL
GO
IF NOT (EXISTS(SELECT * FROM sys.types st JOIN sys.schemas ss ON st.schema_id = ss.schema_id WHERE st.name = N'ZlaPadronPerPctType' AND ss.name = N'dbo'))
CREATE TYPE [dbo].[ZlaPadronPerPctType]
	FROM [decimal](6, 3)
	NULL
GO
IF NOT (EXISTS(SELECT * FROM sys.types st JOIN sys.schemas ss ON st.schema_id = ss.schema_id WHERE st.name = N'ZlaPadronPeriodType' AND ss.name = N'dbo'))
CREATE TYPE [dbo].[ZlaPadronPeriodType]
	FROM [nvarchar](10)
	NULL
GO
IF NOT (EXISTS(SELECT * FROM sys.types st JOIN sys.schemas ss ON st.schema_id = ss.schema_id WHERE st.name = N'ZlaPayIdType' AND ss.name = N'dbo'))
CREATE TYPE [dbo].[ZlaPayIdType]
	FROM [nvarchar](10)
	NOT NULL
GO
IF NOT (EXISTS(SELECT * FROM sys.types st JOIN sys.schemas ss ON st.schema_id = ss.schema_id WHERE st.name = N'ZlaPayIdStatusType' AND ss.name = N'dbo'))
CREATE TYPE [dbo].[ZlaPayIdStatusType]
	FROM [nchar](1)
	NULL
GO
IF NOT (EXISTS(SELECT * FROM sys.types st JOIN sys.schemas ss ON st.schema_id = ss.schema_id WHERE st.name = N'ZlaPadronType' AND ss.name = N'dbo'))
CREATE TYPE [dbo].[ZlaPadronType]
	FROM [nvarchar](15)
	NULL
GO
IF NOT (EXISTS(SELECT * FROM sys.types st JOIN sys.schemas ss ON st.schema_id = ss.schema_id WHERE st.name = N'ZlaTaxJurType' AND ss.name = N'dbo'))
CREATE TYPE [dbo].[ZlaTaxJurType]
	FROM [nvarchar](10)
	NULL
GO
IF NOT (EXISTS(SELECT * FROM sys.types st JOIN sys.schemas ss ON st.schema_id = ss.schema_id WHERE st.name = N'ZlaTaxGroupIdType' AND ss.name = N'dbo'))
CREATE TYPE [dbo].[ZlaTaxGroupIdType]
	FROM [nvarchar](15)
	NULL
GO
IF NOT (EXISTS(SELECT * FROM sys.types st JOIN sys.schemas ss ON st.schema_id = ss.schema_id WHERE st.name = N'zlaTaxCodeSourceType' AND ss.name = N'dbo'))
CREATE TYPE [dbo].[zlaTaxCodeSourceType]
	FROM [nvarchar](6)
	NULL
GO
IF NOT (EXISTS(SELECT * FROM sys.types st JOIN sys.schemas ss ON st.schema_id = ss.schema_id WHERE st.name = N'ZlaTaxTypeId' AND ss.name = N'dbo'))
CREATE TYPE [dbo].[ZlaTaxTypeId]
	FROM [nvarchar](15)
	NULL
GO
IF NOT (EXISTS(SELECT * FROM sys.types st JOIN sys.schemas ss ON st.schema_id = ss.schema_id WHERE st.name = N'ZlaTaxPosType' AND ss.name = N'dbo'))
CREATE TYPE [dbo].[ZlaTaxPosType]
	FROM [nvarchar](10)
	NULL
GO
IF NOT (EXISTS(SELECT * FROM sys.types st JOIN sys.schemas ss ON st.schema_id = ss.schema_id WHERE st.name = N'ZlaTaxPosGroupType' AND ss.name = N'dbo'))
CREATE TYPE [dbo].[ZlaTaxPosGroupType]
	FROM [nvarchar](10)
	NULL
GO
IF NOT (EXISTS(SELECT * FROM sys.types st JOIN sys.schemas ss ON st.schema_id = ss.schema_id WHERE st.name = N'ZlaShipNumType' AND ss.name = N'dbo'))
CREATE TYPE [dbo].[ZlaShipNumType]
	FROM [nvarchar](30)
	NULL
GO
IF NOT (EXISTS(SELECT * FROM sys.types st JOIN sys.schemas ss ON st.schema_id = ss.schema_id WHERE st.name = N'ZlaShipLineType' AND ss.name = N'dbo'))
CREATE TYPE [dbo].[ZlaShipLineType]
	FROM [smallint]
	NULL
GO
IF NOT (EXISTS(SELECT * FROM sys.types st JOIN sys.schemas ss ON st.schema_id = ss.schema_id WHERE st.name = N'ZlaShipIdType' AND ss.name = N'dbo'))
CREATE TYPE [dbo].[ZlaShipIdType]
	FROM [nvarchar](10)
	NULL
GO
IF NOT (EXISTS(SELECT * FROM sys.types st JOIN sys.schemas ss ON st.schema_id = ss.schema_id WHERE st.name = N'ZlaStartNum' AND ss.name = N'dbo'))
CREATE TYPE [dbo].[ZlaStartNum]
	FROM [int]
	NULL
GO
IF NOT (EXISTS(SELECT * FROM sys.types st JOIN sys.schemas ss ON st.schema_id = ss.schema_id WHERE st.name = N'zlaSourceLineNoType' AND ss.name = N'dbo'))
CREATE TYPE [dbo].[zlaSourceLineNoType]
	FROM [int]
	NULL
GO
IF NOT (EXISTS(SELECT * FROM sys.types st JOIN sys.schemas ss ON st.schema_id = ss.schema_id WHERE st.name = N'ZlaShipTypeType' AND ss.name = N'dbo'))
CREATE TYPE [dbo].[ZlaShipTypeType]
	FROM [char](1)
	NOT NULL
GO
IF NOT (EXISTS(SELECT * FROM sys.types st JOIN sys.schemas ss ON st.schema_id = ss.schema_id WHERE st.name = N'ZlaMcItemTypeType' AND ss.name = N'dbo'))
CREATE TYPE [dbo].[ZlaMcItemTypeType]
	FROM [varchar](10)
	NOT NULL
GO
IF NOT (EXISTS(SELECT * FROM sys.types st JOIN sys.schemas ss ON st.schema_id = ss.schema_id WHERE st.name = N'ZlaDeductPctType' AND ss.name = N'dbo'))
CREATE TYPE [dbo].[ZlaDeductPctType]
	FROM [decimal](6, 3)
	NULL
GO
IF NOT (EXISTS(SELECT * FROM sys.types st JOIN sys.schemas ss ON st.schema_id = ss.schema_id WHERE st.name = N'zlaCurrCodeType' AND ss.name = N'dbo'))
CREATE TYPE [dbo].[zlaCurrCodeType]
	FROM [nchar](3)
	NULL
GO
IF NOT (EXISTS(SELECT * FROM sys.types st JOIN sys.schemas ss ON st.schema_id = ss.schema_id WHERE st.name = N'ZlaBankType' AND ss.name = N'dbo'))
CREATE TYPE [dbo].[ZlaBankType]
	FROM [nchar](1)
	NULL
GO
IF NOT (EXISTS(SELECT * FROM sys.types st JOIN sys.schemas ss ON st.schema_id = ss.schema_id WHERE st.name = N'ZlaFiscalIdentifier' AND ss.name = N'dbo'))
CREATE TYPE [dbo].[ZlaFiscalIdentifier]
	FROM [nvarchar](14)
	NULL
GO
IF NOT (EXISTS(SELECT * FROM sys.types st JOIN sys.schemas ss ON st.schema_id = ss.schema_id WHERE st.name = N'ZlaEndNum' AND ss.name = N'dbo'))
CREATE TYPE [dbo].[ZlaEndNum]
	FROM [int]
	NULL
GO
IF NOT (EXISTS(SELECT * FROM sys.types st JOIN sys.schemas ss ON st.schema_id = ss.schema_id WHERE st.name = N'ZlaDocumentIdType' AND ss.name = N'dbo'))
CREATE TYPE [dbo].[ZlaDocumentIdType]
	FROM [nvarchar](10)
	NULL
GO
IF NOT (EXISTS(SELECT * FROM sys.types st JOIN sys.schemas ss ON st.schema_id = ss.schema_id WHERE st.name = N'ZlaArReceiptType' AND ss.name = N'dbo'))
CREATE TYPE [dbo].[ZlaArReceiptType]
	FROM [varchar](20)
	NULL
GO
IF NOT (EXISTS(SELECT * FROM sys.types st JOIN sys.schemas ss ON st.schema_id = ss.schema_id WHERE st.name = N'ZlaArPayIdType' AND ss.name = N'dbo'))
CREATE TYPE [dbo].[ZlaArPayIdType]
	FROM [nvarchar](10)
	NOT NULL
GO
IF NOT (EXISTS(SELECT * FROM sys.types st JOIN sys.schemas ss ON st.schema_id = ss.schema_id WHERE st.name = N'zlaAPTypeIdType' AND ss.name = N'dbo'))
CREATE TYPE [dbo].[zlaAPTypeIdType]
	FROM [nvarchar](8)
	NULL
GO
IF NOT (EXISTS(SELECT * FROM sys.types st JOIN sys.schemas ss ON st.schema_id = ss.schema_id WHERE st.name = N'ZlaAuthCode' AND ss.name = N'dbo'))
CREATE TYPE [dbo].[ZlaAuthCode]
	FROM [nvarchar](50)
	NULL
GO
IF NOT (EXISTS(SELECT * FROM sys.types st JOIN sys.schemas ss ON st.schema_id = ss.schema_id WHERE st.name = N'ZlaArTypeIdType' AND ss.name = N'dbo'))
CREATE TYPE [dbo].[ZlaArTypeIdType]
	FROM [nvarchar](10)
	NULL
GO
IF NOT (EXISTS(SELECT * FROM sys.types st JOIN sys.schemas ss ON st.schema_id = ss.schema_id WHERE st.name = N'ZlaArType' AND ss.name = N'dbo'))
CREATE TYPE [dbo].[ZlaArType]
	FROM [nchar](1)
	NULL
GO
IF NOT (EXISTS(SELECT * FROM sys.types st JOIN sys.schemas ss ON st.schema_id = ss.schema_id WHERE st.name = N'ZlaMcCalcIdType' AND ss.name = N'dbo'))
CREATE TYPE [dbo].[ZlaMcCalcIdType]
	FROM [varchar](10)
	NULL
GO
IF NOT (EXISTS(SELECT * FROM sys.types st JOIN sys.schemas ss ON st.schema_id = ss.schema_id WHERE st.name = N'ZlaLastTranTypeType' AND ss.name = N'dbo'))
CREATE TYPE [dbo].[ZlaLastTranTypeType]
	FROM [nvarchar](3)
	NULL
GO
IF NOT (EXISTS(SELECT * FROM sys.types st JOIN sys.schemas ss ON st.schema_id = ss.schema_id WHERE st.name = N'ZlaLastTranSuffix' AND ss.name = N'dbo'))
CREATE TYPE [dbo].[ZlaLastTranSuffix]
	FROM [nvarchar](4)
	NULL
GO
IF NOT (EXISTS(SELECT * FROM sys.types st JOIN sys.schemas ss ON st.schema_id = ss.schema_id WHERE st.name = N'ZlaMcIndexType' AND ss.name = N'dbo'))
CREATE TYPE [dbo].[ZlaMcIndexType]
	FROM [nvarchar](10)
	NULL
GO
IF NOT (EXISTS(SELECT * FROM sys.types st JOIN sys.schemas ss ON st.schema_id = ss.schema_id WHERE st.name = N'ZlaMcCodeTypeType' AND ss.name = N'dbo'))
CREATE TYPE [dbo].[ZlaMcCodeTypeType]
	FROM [nvarchar](3)
	NOT NULL
GO
IF NOT (EXISTS(SELECT * FROM sys.types st JOIN sys.schemas ss ON st.schema_id = ss.schema_id WHERE st.name = N'ZlaMcCodeType' AND ss.name = N'dbo'))
CREATE TYPE [dbo].[ZlaMcCodeType]
	FROM [nvarchar](10)
	NULL
GO
IF NOT (EXISTS(SELECT * FROM sys.types st JOIN sys.schemas ss ON st.schema_id = ss.schema_id WHERE st.name = N'ZlaLastranType' AND ss.name = N'dbo'))
CREATE TYPE [dbo].[ZlaLastranType]
	FROM [int]
	NULL
GO
IF NOT (EXISTS(SELECT * FROM sys.types st JOIN sys.schemas ss ON st.schema_id = ss.schema_id WHERE st.name = N'ZlaInvPrefix' AND ss.name = N'dbo'))
CREATE TYPE [dbo].[ZlaInvPrefix]
	FROM [nvarchar](10)
	NULL
GO
IF NOT (EXISTS(SELECT * FROM sys.types st JOIN sys.schemas ss ON st.schema_id = ss.schema_id WHERE st.name = N'ZlaInvNumType' AND ss.name = N'dbo'))
CREATE TYPE [dbo].[ZlaInvNumType]
	FROM [nvarchar](30)
	NULL
GO
IF NOT (EXISTS(SELECT * FROM sys.types st JOIN sys.schemas ss ON st.schema_id = ss.schema_id WHERE st.name = N'ZlaLastTranPreffixType' AND ss.name = N'dbo'))
CREATE TYPE [dbo].[ZlaLastTranPreffixType]
	FROM [nvarchar](4)
	NULL
GO
IF NOT (EXISTS(SELECT * FROM sys.types st JOIN sys.schemas ss ON st.schema_id = ss.schema_id WHERE st.name = N'ZlaLastTranPlacesType' AND ss.name = N'dbo'))
CREATE TYPE [dbo].[ZlaLastTranPlacesType]
	FROM [smallint]
	NULL
GO
IF NOT (EXISTS(SELECT * FROM sys.types st JOIN sys.schemas ss ON st.schema_id = ss.schema_id WHERE st.name = N'ZlaLastTranIdType' AND ss.name = N'dbo'))
CREATE TYPE [dbo].[ZlaLastTranIdType]
	FROM [nvarchar](10)
	NULL
GO

IF NOT (EXISTS(SELECT * FROM sys.types st JOIN sys.schemas ss ON st.schema_id = ss.schema_id WHERE st.name = N'ZlaCreditCardExpDateType' AND ss.name = N'dbo'))
CREATE TYPE [dbo].[ZlaCreditCardExpDateType]
	FROM [nvarchar](5) 
	NULL
GO

IF NOT (EXISTS(SELECT * FROM sys.types st JOIN sys.schemas ss ON st.schema_id = ss.schema_id WHERE st.name = N'ZlaCreditCardPaymentType' AND ss.name = N'dbo'))
CREATE TYPE [dbo].[ZlaCreditCardPaymentType]
	FROM [smallint]
	NULL
GO

IF NOT (EXISTS(SELECT * FROM sys.types st JOIN sys.schemas ss ON st.schema_id = ss.schema_id WHERE st.name = N'ZlaDepositReceiptType' AND ss.name = N'dbo'))
CREATE TYPE [dbo].[ZlaDepositReceiptType]
	FROM [nvarchar] (10) 
	NULL
GO

