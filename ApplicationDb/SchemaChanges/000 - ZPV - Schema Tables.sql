SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

GO

IF NOT (EXISTS(SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[zpv_ar_payments]') AND type in (N'U')))
BEGIN
	CREATE TABLE [dbo].[zpv_ar_payments](
		[CreatedBy] [dbo].[UsernameType] NOT NULL CONSTRAINT [DF_zpv_ar_payments_CreatedBy]  DEFAULT (suser_sname()),
		[UpdatedBy] [dbo].[UsernameType] NOT NULL CONSTRAINT [DF_zpv_ar_payments_UpdatedBy]  DEFAULT (suser_sname()),
		[CreateDate] [dbo].[CurrentDateType] NOT NULL CONSTRAINT [DF_zpv_ar_payments_CreateDate]  DEFAULT (getdate()),
		[RecordDate] [dbo].[CurrentDateType] NOT NULL CONSTRAINT [DF_zpv_ar_payments_RecordDate]  DEFAULT (getdate()),
		[RowPointer] [dbo].[RowPointerType] NOT NULL CONSTRAINT [DF_zpv_ar_payments_RowPointer]  DEFAULT (newid()),
		[NoteExistsFlag] [dbo].[FlagNyType] NOT NULL CONSTRAINT [DF_zpv_ar_payments_NoteExistsFlag]  DEFAULT ((0)),
		[InWorkflow] [dbo].[FlagNyType] NOT NULL CONSTRAINT [DF_zpv_ar_payments_InWorkflow]  DEFAULT ((0)),
		[ar_pay_id] [dbo].[ZlaArPayIdType] NULL,
		[pay_seq] [int] NOT NULL,
		[pay_type] [varchar](30) NULL,
		[pay_date] [dbo].[DateType] NULL,
		[due_date] [dbo].[DateType] NULL,
		[amount] [dbo].[AmountType] NULL,
		[curr_code] [dbo].[CurrCodeType] NULL,
		[bank_code] [dbo].[BankCodeType] NULL,
		[check_num] [numeric](10, 0) NULL,
		[exch_rate] [dbo].[ExchRateType] NULL,
		[for_amount] [dbo].[AmountType] NULL,
		[site_ref] [dbo].[SiteType] NULL CONSTRAINT [DF_zpv_ar_payments_site_ref]  DEFAULT (rtrim(CONVERT([nvarchar](8),context_info(),(0)))),
		[cc_name] [dbo].[NameType] NULL,
		[cc_due_date] [dbo].[DateType] NULL,
		[cc_number] [varchar](30) NULL,
		[cc_auth_code] [varchar](10) NULL,
		[cc_phone] [varchar](30) NULL,
		[cc_emit] [varchar](50) NULL,
		[cc_bank] [varchar](50) NULL,
		[pay_cc] [dbo].[ListYesNoType] NULL CONSTRAINT [DF_zpv_ar_payments_pay_cc]  DEFAULT ((0)),
		[ck_order_by] [dbo].[FlagNyType] NULL,
		[ck_bank] [dbo].[BankCodeType] NULL,
		[ck_check_date] [dbo].[DateType] NULL,
		[ck_cuit] [varchar](30) NULL,
		[ck_description] [varchar](60) NULL,
		[ck_check_3ros] [dbo].[FlagNyType] NULL,
		[ck_due_date] [dbo].[DateType] NULL,
		[cc_cupon] [varchar](30) NULL,
		[cc_quotes] [int] NULL,
		[tax_document] [varchar](30) NULL,
		[posted] [dbo].[FlagNyType] NULL CONSTRAINT [DF_zpv_ar_payments_posted]  DEFAULT ((0)),
		[drawer] [varchar](15) NULL,
		[cust_num] [dbo].[CustNumType] NOT NULL,
		[apply] [dbo].[FlagNyType] NULL CONSTRAINT [DF_zpv_ar_payments_apply]  DEFAULT ((0)),
	 CONSTRAINT [PK_zpv_ar_payments] PRIMARY KEY NONCLUSTERED 
	(
		[cust_num] ASC,
		[pay_seq] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
	 CONSTRAINT [IX_zpv_ar_payments_RowPointer] UNIQUE NONCLUSTERED 
	(
		[RowPointer] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
	) ON [PRIMARY]
END
--------------------------------------------------------------------------------------------------------------------------------------------------------------
IF NOT (EXISTS(SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[zpv_bank_ptype]') AND type in (N'U')))
BEGIN
	CREATE TABLE [dbo].[zpv_bank_ptype](
		[CreatedBy] [dbo].[UsernameType] NOT NULL CONSTRAINT [DF_zpv_bank_ptype_CreatedBy]  DEFAULT (suser_sname()),
		[UpdatedBy] [dbo].[UsernameType] NOT NULL CONSTRAINT [DF_zpv_bank_ptype_UpdatedBy]  DEFAULT (suser_sname()),
		[CreateDate] [dbo].[CurrentDateType] NOT NULL CONSTRAINT [DF_zpv_bank_ptype_CreateDate]  DEFAULT (getdate()),
		[RecordDate] [dbo].[CurrentDateType] NOT NULL CONSTRAINT [DF_zpv_bank_ptype_RecordDate]  DEFAULT (getdate()),
		[RowPointer] [dbo].[RowPointerType] NOT NULL CONSTRAINT [DF_zpv_bank_ptype_RowPointer]  DEFAULT (newid()),
		[NoteExistsFlag] [dbo].[FlagNyType] NOT NULL CONSTRAINT [DF_zpv_bank_ptype_NoteExistsFlag]  DEFAULT ((0)),
		[InWorkflow] [dbo].[FlagNyType] NOT NULL CONSTRAINT [DF_zpv_bank_ptype_InWorkflow]  DEFAULT ((0)),
		[bank_id] [dbo].[BankCodeType] NOT NULL,
		[posm_pay_type] [dbo].[POSMPayTypeType] NOT NULL,
		[credit_memo] [dbo].[BankCodeType] NULL,
		[zla_ar_type_id] [dbo].[ZlaArTypeIdType] NULL,
		[term_disc] [dbo].[FlagNyType] NULL CONSTRAINT [DF_zpv_bank_ptype_term_disc]  DEFAULT ((0)),
		[disc] [dbo].[TaxRateType] NULL CONSTRAINT [DF_zpv_bank_ptype_disc]  DEFAULT ((0)),
		[ret_code] [varchar](10) NULL,
		[from_date] [dbo].[DateType] NOT NULL,
		[to_date] [dbo].[DateType] NULL,
		[zla_doc_id] [dbo].[ZlaDocumentIdType] NULL,
	 CONSTRAINT [PK_zpv_bank_ptype] PRIMARY KEY NONCLUSTERED 
	(
		[bank_id] ASC,
		[posm_pay_type] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
	 CONSTRAINT [IX_zpv_bank_ptype_RowPointer] UNIQUE NONCLUSTERED 
	(
		[RowPointer] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
	) ON [PRIMARY]

END
-------------------------------------------------------------------------------------------------------------------------------------------------------------------
IF NOT (EXISTS(SELECT * FROM sys.objects WHERE [object_id] = OBJECT_ID(N'[dbo].[zpv_business_code]') AND [type]='U'))
BEGIN
	CREATE TABLE [dbo].[zpv_business_code](
		[CreatedBy] [dbo].[UsernameType] NOT NULL,
		[UpdatedBy] [dbo].[UsernameType] NOT NULL,
		[CreateDate] [dbo].[CurrentDateType] NOT NULL,
		[RecordDate] [dbo].[CurrentDateType] NOT NULL,
		[RowPointer] [dbo].[RowPointerType] NOT NULL,
		[NoteExistsFlag] [dbo].[FlagNyType] NOT NULL,
		[InWorkflow] [dbo].[FlagNyType] NOT NULL,
		[ApplyTo] [varchar](3) NOT NULL,
		[BusinessCode] [varchar](15) NOT NULL,
		[Description] [varchar](60) NULL,
		[ApplyUnitCode] [int] NULL,
		[UnitCode] [varchar](5) NULL,
	 CONSTRAINT [PK_zpv_business_code] PRIMARY KEY NONCLUSTERED 
	(
		[ApplyTo] ASC,
		[BusinessCode] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
	 CONSTRAINT [IX_zpv_business_code_RowPointer] UNIQUE NONCLUSTERED 
	(
		[RowPointer] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
	) ON [PRIMARY]

	ALTER TABLE [dbo].[zpv_business_code] ADD  CONSTRAINT [DF_zpv_business_code_CreatedBy]  DEFAULT (suser_sname()) FOR [CreatedBy]
	ALTER TABLE [dbo].[zpv_business_code] ADD  CONSTRAINT [DF_zpv_business_code_UpdatedBy]  DEFAULT (suser_sname()) FOR [UpdatedBy]
	ALTER TABLE [dbo].[zpv_business_code] ADD  CONSTRAINT [DF_zpv_business_code_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
	ALTER TABLE [dbo].[zpv_business_code] ADD  CONSTRAINT [DF_zpv_business_code_RecordDate]  DEFAULT (getdate()) FOR [RecordDate]
	ALTER TABLE [dbo].[zpv_business_code] ADD  CONSTRAINT [DF_zpv_business_code_RowPointer]  DEFAULT (newid()) FOR [RowPointer]
	ALTER TABLE [dbo].[zpv_business_code] ADD  CONSTRAINT [DF_zpv_business_code_NoteExistsFlag]  DEFAULT ((0)) FOR [NoteExistsFlag]
	ALTER TABLE [dbo].[zpv_business_code] ADD  CONSTRAINT [DF_zpv_business_code_InWorkflow]  DEFAULT ((0)) FOR [InWorkflow]
END
----------------------------------------------------------------------------------------------------------------------------------------------------------------------

IF NOT (EXISTS(SELECT * FROM sys.objects WHERE [object_id] = OBJECT_ID(N'[dbo].[zpv_co_codes]') AND [type]='U'))
BEGIN
	CREATE TABLE [dbo].[zpv_co_codes](
		[CreatedBy] [dbo].[UsernameType] NOT NULL CONSTRAINT [DF_zpv_co_codes_CreatedBy]  DEFAULT (suser_sname()),
		[UpdatedBy] [dbo].[UsernameType] NOT NULL CONSTRAINT [DF_zpv_co_codes_UpdatedBy]  DEFAULT (suser_sname()),
		[CreateDate] [dbo].[CurrentDateType] NOT NULL CONSTRAINT [DF_zpv_co_codes_CreateDate]  DEFAULT (getdate()),
		[RecordDate] [dbo].[CurrentDateType] NOT NULL CONSTRAINT [DF_zpv_co_codes_RecordDate]  DEFAULT (getdate()),
		[RowPointer] [dbo].[RowPointerType] NOT NULL CONSTRAINT [DF_zpv_co_codes_RowPointer]  DEFAULT (newid()),
		[NoteExistsFlag] [dbo].[FlagNyType] NOT NULL CONSTRAINT [DF_zpv_co_codes_NoteExistsFlag]  DEFAULT ((0)),
		[InWorkflow] [dbo].[FlagNyType] NOT NULL CONSTRAINT [DF_zpv_co_codes_InWorkflow]  DEFAULT ((0)),
		[end_user_type] [dbo].[EndUserTypeType] NOT NULL,
		[cust_type] [dbo].[CustTypeType] NOT NULL,
		[ret_code] [varchar](10) NOT NULL,
		[credit_limit] [dbo].[FlagNyType] NOT NULL,
		[doc_id] [varchar](10) NOT NULL,
	 CONSTRAINT [IX_zpv_co_codes_RowPointer] UNIQUE NONCLUSTERED 
	(
		[RowPointer] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
	) ON [PRIMARY]
END
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
IF NOT (EXISTS(SELECT * FROM sys.objects WHERE [object_id] = OBJECT_ID(N'[dbo].[zpv_co_payments]') AND [type]='U'))
BEGIN
	CREATE TABLE [dbo].[zpv_co_payments](
		[CreatedBy] [dbo].[UsernameType] NOT NULL CONSTRAINT [DF_zpv_co_payments_CreatedBy]  DEFAULT (suser_sname()),
		[UpdatedBy] [dbo].[UsernameType] NOT NULL CONSTRAINT [DF_zpv_co_payments_UpdatedBy]  DEFAULT (suser_sname()),
		[CreateDate] [dbo].[CurrentDateType] NOT NULL CONSTRAINT [DF_zpv_co_payments_CreateDate]  DEFAULT (getdate()),
		[RecordDate] [dbo].[CurrentDateType] NOT NULL CONSTRAINT [DF_zpv_co_payments_RecordDate]  DEFAULT (getdate()),
		[RowPointer] [dbo].[RowPointerType] NOT NULL CONSTRAINT [DF_zpv_co_payments_RowPointer]  DEFAULT (newid()),
		[NoteExistsFlag] [dbo].[FlagNyType] NOT NULL CONSTRAINT [DF_zpv_co_payments_NoteExistsFlag]  DEFAULT ((0)),
		[InWorkflow] [dbo].[FlagNyType] NOT NULL CONSTRAINT [DF_zpv_co_payments_InWorkflow]  DEFAULT ((0)),
		[co_num] [dbo].[CoNumType] NOT NULL,
		[pay_seq] [int] NOT NULL,
		[pay_type] [varchar](30) NULL,
		[pay_date] [dbo].[DateType] NULL,
		[due_date] [dbo].[DateType] NULL,
		[amount] [dbo].[AmountType] NULL,
		[curr_code] [dbo].[CurrCodeType] NULL,
		[bank_code] [dbo].[BankCodeType] NULL,
		[check_num] [numeric](10, 0) NULL,
		[exch_rate] [dbo].[ExchRateType] NULL,
		[for_amount] [dbo].[AmountType] NULL,
		[site_ref] [dbo].[SiteType] NULL CONSTRAINT [DF_zpv_co_payments_site_ref]  DEFAULT (rtrim(CONVERT([nvarchar](8),context_info(),(0)))),
		[cc_name] [dbo].[NameType] NULL,
		[cc_due_date] [dbo].[DateType] NULL,
		[cc_number] [varchar](30) NULL,
		[cc_auth_code] [varchar](10) NULL,
		[cc_phone] [varchar](30) NULL,
		[cc_emit] [varchar](50) NULL,
		[cc_bank] [varchar](50) NULL,
		[pay_cc] [dbo].[ListYesNoType] NULL CONSTRAINT [DF_zpv_co_payments_pay_cc]  DEFAULT ((0)),
		[ck_order_by] [dbo].[FlagNyType] NULL,
		[ck_bank] [dbo].[BankCodeType] NULL,
		[ck_check_date] [dbo].[DateType] NULL,
		[ck_cuit] [varchar](30) NULL,
		[ck_description] [varchar](60) NULL,
		[ck_check_3ros] [dbo].[FlagNyType] NULL,
		[ck_due_date] [dbo].[DateType] NULL,
		[cc_cupon] [varchar](30) NULL,
		[cc_quotes] [int] NULL,
		[tax_document] [varchar](30) NULL,
		[posted] [dbo].[FlagNyType] NULL,
		[drawer] [varchar](15) NULL,
		[ar_pay_id] [dbo].[ZlaArPayIdType] NULL,
	 CONSTRAINT [PK_zpv_co_payments] PRIMARY KEY NONCLUSTERED 
	(
		[co_num] ASC,
		[pay_seq] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
	 CONSTRAINT [IX_zpv_co_payments_RowPointer] UNIQUE NONCLUSTERED 
	(
		[RowPointer] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
	) ON [PRIMARY]

END
-----------------------------------------------------------------------------------------------------------------------------------------------------------------
IF NOT (EXISTS(SELECT * FROM sys.objects WHERE [object_id] = OBJECT_ID(N'[dbo].[zpv_co_pos]') AND [type]='U'))
BEGIN
	CREATE TABLE [dbo].[zpv_co_pos](
		[CreatedBy] [dbo].[UsernameType] NOT NULL CONSTRAINT [DF_zpv_co_pos_CreatedBy]  DEFAULT (suser_sname()),
		[UpdatedBy] [dbo].[UsernameType] NOT NULL CONSTRAINT [DF_zpv_co_pos_UpdatedBy]  DEFAULT (suser_sname()),
		[CreateDate] [dbo].[CurrentDateType] NOT NULL CONSTRAINT [DF_zpv_co_pos_CreateDate]  DEFAULT (getdate()),
		[RecordDate] [dbo].[CurrentDateType] NOT NULL CONSTRAINT [DF_zpv_co_pos_RecordDate]  DEFAULT (getdate()),
		[RowPointer] [dbo].[RowPointerType] NOT NULL CONSTRAINT [DF_zpv_co_pos_RowPointer]  DEFAULT (newid()),
		[NoteExistsFlag] [dbo].[FlagNyType] NOT NULL CONSTRAINT [DF_zpv_co_pos_NoteExistsFlag]  DEFAULT ((0)),
		[InWorkflow] [dbo].[FlagNyType] NOT NULL CONSTRAINT [DF_zpv_co_pos_InWorkflow]  DEFAULT ((0)),
		[pos_code] [varchar](15) NOT NULL,
		[description] [dbo].[DescriptionType] NULL,
	 CONSTRAINT [PK_zpv_co_pos] PRIMARY KEY NONCLUSTERED 
	(
		[pos_code] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
	 CONSTRAINT [IX_zpv_co_pos_RowPointer] UNIQUE NONCLUSTERED 
	(
		[RowPointer] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
	) ON [PRIMARY]

END
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
IF NOT (EXISTS(SELECT * FROM sys.objects WHERE [object_id] = OBJECT_ID(N'[dbo].[zpv_co_ret_code]') AND [type]='U'))
BEGIN
	CREATE TABLE [dbo].[zpv_co_ret_code](
		[CreatedBy] [dbo].[UsernameType] NOT NULL CONSTRAINT [DF_zpv_co_ret_code_CreatedBy]  DEFAULT (suser_sname()),
		[UpdatedBy] [dbo].[UsernameType] NOT NULL CONSTRAINT [DF_zpv_co_ret_code_UpdatedBy]  DEFAULT (suser_sname()),
		[CreateDate] [dbo].[CurrentDateType] NOT NULL CONSTRAINT [DF_zpv_co_ret_code_CreateDate]  DEFAULT (getdate()),
		[RecordDate] [dbo].[CurrentDateType] NOT NULL CONSTRAINT [DF_zpv_co_ret_code_RecordDate]  DEFAULT (getdate()),
		[RowPointer] [dbo].[RowPointerType] NOT NULL CONSTRAINT [DF_zpv_co_ret_code_RowPointer]  DEFAULT (newid()),
		[NoteExistsFlag] [dbo].[FlagNyType] NOT NULL CONSTRAINT [DF_zpv_co_ret_code_NoteExistsFlag]  DEFAULT ((0)),
		[InWorkflow] [dbo].[FlagNyType] NOT NULL CONSTRAINT [DF_zpv_co_ret_code_InWorkflow]  DEFAULT ((0)),
		[ret_code] [varchar](10) NOT NULL,
		[type] [varchar](20) NULL,
		[description] [varchar](50) NULL,
		[days] [int] NULL,
		[site_ref] [dbo].[SiteType] NULL CONSTRAINT [DF_zpv_co_ret_code_site_ref]  DEFAULT (rtrim(CONVERT([nvarchar](8),context_info(),(0)))),
		[reservation] [dbo].[FlagNyType] NULL CONSTRAINT [DF_zpv_co_ret_code_reservation]  DEFAULT ((0)),
		[stop_tranfer] [dbo].[FlagNyType] NULL CONSTRAINT [DF_zpv_co_ret_code_stop_tranfer]  DEFAULT ((0)),
		[GroupId] [dbo].[TokenType] NULL,
	 CONSTRAINT [PK_zpv_co_ret_code] PRIMARY KEY NONCLUSTERED 
	(
		[ret_code] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
	 CONSTRAINT [IX_zpv_co_ret_code_RowPointer] UNIQUE NONCLUSTERED 
	(
		[RowPointer] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
	) ON [PRIMARY]
END
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
IF NOT (EXISTS(SELECT * FROM sys.objects WHERE [object_id] = OBJECT_ID(N'[dbo].[zpv_co_retentions]') AND [type]='U'))
BEGIN
	CREATE TABLE [dbo].[zpv_co_retentions](
		[CreatedBy] [dbo].[UsernameType] NOT NULL CONSTRAINT [DF_zpv_co_retentions_CreatedBy]  DEFAULT (suser_sname()),
		[UpdatedBy] [dbo].[UsernameType] NOT NULL CONSTRAINT [DF_zpv_co_retentions_UpdatedBy]  DEFAULT (suser_sname()),
		[CreateDate] [dbo].[CurrentDateType] NOT NULL CONSTRAINT [DF_zpv_co_retentions_CreateDate]  DEFAULT (getdate()),
		[RecordDate] [dbo].[CurrentDateType] NOT NULL CONSTRAINT [DF_zpv_co_retentions_RecordDate]  DEFAULT (getdate()),
		[RowPointer] [dbo].[RowPointerType] NOT NULL CONSTRAINT [DF_zpv_co_retentions_RowPointer]  DEFAULT (newid()),
		[NoteExistsFlag] [dbo].[FlagNyType] NOT NULL CONSTRAINT [DF_zpv_co_retentions_NoteExistsFlag]  DEFAULT ((0)),
		[InWorkflow] [dbo].[FlagNyType] NOT NULL CONSTRAINT [DF_zpv_co_retentions_InWorkflow]  DEFAULT ((0)),
		[co_num] [dbo].[CoNumType] NOT NULL,
		[ret_seq] [int] NOT NULL,
		[ret_code] [varchar](10) NOT NULL,
		[ret_type] [varchar](30) NULL,
		[ret_date] [dbo].[DateType] NULL,
		[site_ref] [dbo].[SiteType] NULL CONSTRAINT [DF_zpv_co_retentions_site_ref]  DEFAULT (rtrim(CONVERT([nvarchar](8),context_info(),(0)))),
		[active] [int] NULL CONSTRAINT [DF_zpv_co_retentions_active]  DEFAULT ((1)),
	 CONSTRAINT [PK_zpv_co_retentions] PRIMARY KEY NONCLUSTERED 
	(
		[co_num] ASC,
		[ret_seq] ASC,
		[ret_code] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
	 CONSTRAINT [IX_zpv_co_retentions_RowPointer] UNIQUE NONCLUSTERED 
	(
		[RowPointer] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
	) ON [PRIMARY]

END
------------------------------------------------------------------------------------------------------------------------------------------------------------------
IF NOT (EXISTS(SELECT * FROM sys.objects WHERE [object_id] = OBJECT_ID(N'[dbo].[zpv_co_stat]') AND [type]='U'))
BEGIN
	CREATE TABLE [dbo].[zpv_co_stat](
		[CreatedBy] [dbo].[UsernameType] NOT NULL CONSTRAINT [DF_zpv_co_stat_CreatedBy]  DEFAULT (suser_sname()),
		[UpdatedBy] [dbo].[UsernameType] NOT NULL CONSTRAINT [DF_zpv_co_stat_UpdatedBy]  DEFAULT (suser_sname()),
		[CreateDate] [dbo].[CurrentDateType] NOT NULL CONSTRAINT [DF_zpv_co_stat_CreateDate]  DEFAULT (getdate()),
		[RecordDate] [dbo].[CurrentDateType] NOT NULL CONSTRAINT [DF_zpv_co_stat_RecordDate]  DEFAULT (getdate()),
		[RowPointer] [dbo].[RowPointerType] NOT NULL CONSTRAINT [DF_zpv_co_stat_RowPointer]  DEFAULT (newid()),
		[NoteExistsFlag] [dbo].[FlagNyType] NOT NULL CONSTRAINT [DF_zpv_co_stat_NoteExistsFlag]  DEFAULT ((0)),
		[InWorkflow] [dbo].[FlagNyType] NOT NULL CONSTRAINT [DF_zpv_co_stat_InWorkflow]  DEFAULT ((0)),
		[description] [varchar](60) NULL,
		[sl_stat] [varchar](1) NULL,
		[hidden] [varchar](1) NULL CONSTRAINT [DF_zpv_co_stat_hidden]  DEFAULT ((0)),
		[stat] [varchar](3) NULL,
		[site_ref] [dbo].[SiteType] NULL CONSTRAINT [DF_zpv_co_stat_site_ref]  DEFAULT (rtrim(CONVERT([nvarchar](8),context_info(),(0)))),
	 CONSTRAINT [IX_zpv_co_stat_RowPointer] UNIQUE NONCLUSTERED 
	(
		[RowPointer] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
	) ON [PRIMARY]

END
-----------------------------------------------------------------------------------------------------------------------------------------------------------------
IF NOT (EXISTS(SELECT * FROM sys.objects WHERE [object_id] = OBJECT_ID(N'[dbo].[zpv_cobln_res]') AND [type]='U'))
BEGIN
	CREATE TABLE [dbo].[zpv_cobln_res](
		[CreatedBy] [dbo].[UsernameType] NOT NULL,
		[UpdatedBy] [dbo].[UsernameType] NOT NULL,
		[CreateDate] [dbo].[CurrentDateType] NOT NULL,
		[RecordDate] [dbo].[CurrentDateType] NOT NULL,
		[RowPointer] [dbo].[RowPointerType] NOT NULL,
		[NoteExistsFlag] [dbo].[FlagNyType] NOT NULL,
		[InWorkflow] [dbo].[FlagNyType] NOT NULL,
		[co_num] [dbo].[CoNumType] NOT NULL,
		[co_line] [dbo].[CoLineType] NOT NULL,
		[whse] [dbo].[WhseType] NULL,
		[lot] [dbo].[LotType] NULL,
		[qty_reserved] [decimal](10, 6) NULL,
		[trans_date] [dbo].[DateType] NULL,
		[item] [dbo].[ItemType] NOT NULL,
	 CONSTRAINT [IX_zpv_cobln_res_RowPointer] UNIQUE NONCLUSTERED 
	(
		[RowPointer] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
	) ON [PRIMARY]

	ALTER TABLE [dbo].[zpv_cobln_res] ADD  CONSTRAINT [DF_zpv_cobln_res_CreatedBy]  DEFAULT (suser_sname()) FOR [CreatedBy]
	ALTER TABLE [dbo].[zpv_cobln_res] ADD  CONSTRAINT [DF_zpv_cobln_res_UpdatedBy]  DEFAULT (suser_sname()) FOR [UpdatedBy]
	ALTER TABLE [dbo].[zpv_cobln_res] ADD  CONSTRAINT [DF_zpv_cobln_res_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
	ALTER TABLE [dbo].[zpv_cobln_res] ADD  CONSTRAINT [DF_zpv_cobln_res_RecordDate]  DEFAULT (getdate()) FOR [RecordDate]
	ALTER TABLE [dbo].[zpv_cobln_res] ADD  CONSTRAINT [DF_zpv_cobln_res_RowPointer]  DEFAULT (newid()) FOR [RowPointer]
	ALTER TABLE [dbo].[zpv_cobln_res] ADD  CONSTRAINT [DF_zpv_cobln_res_NoteExistsFlag]  DEFAULT ((0)) FOR [NoteExistsFlag]
	ALTER TABLE [dbo].[zpv_cobln_res] ADD  CONSTRAINT [DF_zpv_cobln_res_InWorkflow]  DEFAULT ((0)) FOR [InWorkflow]
END

-------------------------------------------------------------------------------------------------------------------------------------------------------------
IF NOT (EXISTS(SELECT * FROM sys.objects WHERE [object_id] = OBJECT_ID(N'[dbo].[zpv_cobln_retention]') AND [type]='U'))
BEGIN
	CREATE TABLE [dbo].[zpv_cobln_retention](
		[CreatedBy] [dbo].[UsernameType] NOT NULL CONSTRAINT [DF_zpv_cobln_retention_CreatedBy]  DEFAULT (suser_sname()),
		[UpdatedBy] [dbo].[UsernameType] NOT NULL CONSTRAINT [DF_zpv_cobln_retention_UpdatedBy]  DEFAULT (suser_sname()),
		[CreateDate] [dbo].[CurrentDateType] NOT NULL CONSTRAINT [DF_zpv_cobln_retention_CreateDate]  DEFAULT (getdate()),
		[RecordDate] [dbo].[CurrentDateType] NOT NULL CONSTRAINT [DF_zpv_cobln_retention_RecordDate]  DEFAULT (getdate()),
		[RowPointer] [dbo].[RowPointerType] NOT NULL CONSTRAINT [DF_zpv_cobln_retention_RowPointer]  DEFAULT (newid()),
		[NoteExistsFlag] [dbo].[FlagNyType] NOT NULL CONSTRAINT [DF_zpv_cobln_retention_NoteExistsFlag]  DEFAULT ((0)),
		[InWorkflow] [dbo].[FlagNyType] NOT NULL CONSTRAINT [DF_zpv_cobln_retention_InWorkflow]  DEFAULT ((0)),
		[co_num] [dbo].[CoNumType] NOT NULL,
		[ret_code] [varchar](10) NOT NULL,
		[ret_date] [dbo].[DateType] NULL,
		[ret_seq] [int] NOT NULL,
		[ret_type] [varchar](30) NULL,
		[site_ref] [dbo].[SiteType] NULL CONSTRAINT [DF_zpv_cobln_retention_site_ref]  DEFAULT (rtrim(CONVERT([nvarchar](8),context_info(),(0)))),
		[co_line] [dbo].[CoLineType] NOT NULL,
		[active] [int] NULL CONSTRAINT [DF_zpv_cobln_retention_active]  DEFAULT ((1)),
	 CONSTRAINT [PK_zpv_cobln_retention] PRIMARY KEY NONCLUSTERED 
	(
		[co_num] ASC,
		[co_line] ASC,
		[ret_seq] ASC,
		[ret_code] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
	 CONSTRAINT [IX_zpv_cobln_retention_RowPointer] UNIQUE NONCLUSTERED 
	(
		[RowPointer] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
	) ON [PRIMARY]

END

----------------------------------------------------------------------------------------------------------------------------------------------------------------
IF NOT (EXISTS(SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[zpv_convenio]') AND type in (N'U')))
BEGIN
	CREATE TABLE [dbo].[zpv_convenio](
		[convenio]	varchar(10) NOT NULL,
		[description] [dbo].[DescriptionType] NULL,
		[CreatedBy] [dbo].[UsernameType] NOT NULL CONSTRAINT [DF_zpv_convenio_CreatedBy]  DEFAULT (suser_sname()),
		[UpdatedBy] [dbo].[UsernameType] NOT NULL CONSTRAINT [DF_zpv_convenio_UpdatedBy]  DEFAULT (suser_sname()),
		[CreateDate] [dbo].[CurrentDateType] NOT NULL CONSTRAINT [DF_zpv_convenio_CreateDate]  DEFAULT (getdate()),
		[RecordDate] [dbo].[CurrentDateType] NOT NULL CONSTRAINT [DF_zpv_convenio_RecordDate]  DEFAULT (getdate()),
		[RowPointer] [dbo].[RowPointerType] NOT NULL CONSTRAINT [DF_zpv_convenio_RowPointer]  DEFAULT (newid()),
		[NoteExistsFlag] [dbo].[FlagNyType] NOT NULL CONSTRAINT [DF_zpv_convenio_NoteExistsFlag]  DEFAULT ((0)),
		[InWorkflow] [dbo].[FlagNyType] NOT NULL CONSTRAINT [DF_zpv_convenio_InWorkflow]  DEFAULT ((0)),
	 CONSTRAINT [PK_zpv_convenio] PRIMARY KEY NONCLUSTERED 
	(
		[convenio] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
	 CONSTRAINT [IX_zpv_convenio_RowPointer] UNIQUE NONCLUSTERED 
	(
		[RowPointer] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
	) ON [PRIMARY]

END

-------------------------------------------------------------------------------------------------------------------------------------------------------------
IF NOT (EXISTS(SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[zpv_follow]') AND type in (N'U')))
BEGIN
	CREATE TABLE [dbo].[zpv_follow](
		[follow_code]	varchar(10) NOT NULL,
		[description] [dbo].[DescriptionType] NULL,
		[CreatedBy] [dbo].[UsernameType] NOT NULL CONSTRAINT [DF_zpv_follow_CreatedBy]  DEFAULT (suser_sname()),
		[UpdatedBy] [dbo].[UsernameType] NOT NULL CONSTRAINT [DF_zpv_follow_UpdatedBy]  DEFAULT (suser_sname()),
		[CreateDate] [dbo].[CurrentDateType] NOT NULL CONSTRAINT [DF_zpv_follow_CreateDate]  DEFAULT (getdate()),
		[RecordDate] [dbo].[CurrentDateType] NOT NULL CONSTRAINT [DF_zpv_follow_RecordDate]  DEFAULT (getdate()),
		[RowPointer] [dbo].[RowPointerType] NOT NULL CONSTRAINT [DF_zpv_follow_RowPointer]  DEFAULT (newid()),
		[NoteExistsFlag] [dbo].[FlagNyType] NOT NULL CONSTRAINT [DF_zpv_follow_NoteExistsFlag]  DEFAULT ((0)),
		[InWorkflow] [dbo].[FlagNyType] NOT NULL CONSTRAINT [DF_zpv_follow_InWorkflow]  DEFAULT ((0)),
	 CONSTRAINT [PK_zpv_follow] PRIMARY KEY NONCLUSTERED 
	(
		[follow_code] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
	 CONSTRAINT [IX_zpv_follow_RowPointer] UNIQUE NONCLUSTERED 
	(
		[RowPointer] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
	) ON [PRIMARY]

END

-------------------------------------------------------------------------------------------------------------------------------------------------------------
IF NOT (EXISTS(SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[zpv_drawer]') AND type in (N'U')))
BEGIN
	CREATE TABLE [dbo].[zpv_drawer](
		[CreatedBy] [dbo].[UsernameType] NOT NULL CONSTRAINT [DF_zpv_drawer_CreatedBy]  DEFAULT (suser_sname()),
		[UpdatedBy] [dbo].[UsernameType] NOT NULL CONSTRAINT [DF_zpv_drawer_UpdatedBy]  DEFAULT (suser_sname()),
		[CreateDate] [dbo].[CurrentDateType] NOT NULL CONSTRAINT [DF_zpv_drawer_CreateDate]  DEFAULT (getdate()),
		[RecordDate] [dbo].[CurrentDateType] NOT NULL CONSTRAINT [DF_zpv_drawer_RecordDate]  DEFAULT (getdate()),
		[RowPointer] [dbo].[RowPointerType] NOT NULL CONSTRAINT [DF_zpv_drawer_RowPointer]  DEFAULT (newid()),
		[NoteExistsFlag] [dbo].[FlagNyType] NOT NULL CONSTRAINT [DF_zpv_drawer_NoteExistsFlag]  DEFAULT ((0)),
		[InWorkflow] [dbo].[FlagNyType] NOT NULL CONSTRAINT [DF_zpv_drawer_InWorkflow]  DEFAULT ((0)),
		[drawer] [varchar](15) NOT NULL,
		[description] [dbo].[DescriptionType] NULL,
		[closed] [dbo].[FlagNyType] NULL,
		[bank_code] [dbo].[BankCodeType] NULL,
		[bank_code_draft] [dbo].[BankCodeType] NULL,
		[pos] [varchar](15) NULL,
		[check_in] [dbo].[FlagNyType] NULL,
		[check_in_date] [dbo].[CurrentDateType] NULL,
		[check_in_user] [dbo].[UsernameType] NULL,
		[locked] [dbo].[FlagNyType] NULL,
	 CONSTRAINT [PK_zpv_drawer] PRIMARY KEY NONCLUSTERED 
	(
		[drawer] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
	 CONSTRAINT [IX_zpv_drawer_RowPointer] UNIQUE NONCLUSTERED 
	(
		[RowPointer] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
	) ON [PRIMARY]

END
----------------------------------------------------------------------------------------------------------------------------------------------------------------
IF NOT (EXISTS(SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[zpv_drawer_pos]') AND type in (N'U')))
BEGIN
	CREATE TABLE [dbo].[zpv_drawer_pos](
		[CreatedBy] [dbo].[UsernameType] NOT NULL CONSTRAINT [DF_zpv_drawer_pos_CreatedBy]  DEFAULT (suser_sname()),
		[UpdatedBy] [dbo].[UsernameType] NOT NULL CONSTRAINT [DF_zpv_drawer_pos_UpdatedBy]  DEFAULT (suser_sname()),
		[CreateDate] [dbo].[CurrentDateType] NOT NULL CONSTRAINT [DF_zpv_drawer_pos_CreateDate]  DEFAULT (getdate()),
		[RecordDate] [dbo].[CurrentDateType] NOT NULL CONSTRAINT [DF_zpv_drawer_pos_RecordDate]  DEFAULT (getdate()),
		[RowPointer] [dbo].[RowPointerType] NOT NULL CONSTRAINT [DF_zpv_drawer_pos_RowPointer]  DEFAULT (newid()),
		[NoteExistsFlag] [dbo].[FlagNyType] NOT NULL CONSTRAINT [DF_zpv_drawer_pos_NoteExistsFlag]  DEFAULT ((0)),
		[InWorkflow] [dbo].[FlagNyType] NOT NULL CONSTRAINT [DF_zpv_drawer_pos_InWorkflow]  DEFAULT ((0)),
		[pos] [varchar](15) NOT NULL,
		[drawer] [varchar](15) NOT NULL,
	 CONSTRAINT [IX_zpv_drawer_pos_RowPointer] UNIQUE NONCLUSTERED 
	(
		[RowPointer] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
	) ON [PRIMARY]
END
----------------------------------------------------------------------------------------------------------------------------------------------------------------
IF NOT (EXISTS(SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[zpv_drawer_ptype]') AND type in (N'U')))
BEGIN
	CREATE TABLE [dbo].[zpv_drawer_ptype](
		[CreatedBy] [dbo].[UsernameType] NOT NULL CONSTRAINT [DF_zpv_drawer_paytype_CreatedBy]  DEFAULT (suser_sname()),
		[UpdatedBy] [dbo].[UsernameType] NOT NULL CONSTRAINT [DF_zpv_drawer_paytype_UpdatedBy]  DEFAULT (suser_sname()),
		[CreateDate] [dbo].[CurrentDateType] NOT NULL CONSTRAINT [DF_zpv_drawer_paytype_CreateDate]  DEFAULT (getdate()),
		[RecordDate] [dbo].[CurrentDateType] NOT NULL CONSTRAINT [DF_zpv_drawer_paytype_RecordDate]  DEFAULT (getdate()),
		[RowPointer] [dbo].[RowPointerType] NOT NULL CONSTRAINT [DF_zpv_drawer_paytype_RowPointer]  DEFAULT (newid()),
		[NoteExistsFlag] [dbo].[FlagNyType] NOT NULL CONSTRAINT [DF_zpv_drawer_paytype_NoteExistsFlag]  DEFAULT ((0)),
		[InWorkflow] [dbo].[FlagNyType] NOT NULL CONSTRAINT [DF_zpv_drawer_paytype_InWorkflow]  DEFAULT ((0)),
		[drawer] [varchar](15) NOT NULL,
		[posm_pay_type] [dbo].[POSMPayTypeType] NOT NULL,
	 CONSTRAINT [IX_zpv_drawer_paytype_RowPointer] UNIQUE NONCLUSTERED 
	(
		[RowPointer] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
	) ON [PRIMARY]

END
-----------------------------------------------------------------------------------------------------------------------------------------------------------------
IF NOT (EXISTS(SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[zpv_drawer_trans]') AND type in (N'U')))
BEGIN
	CREATE TABLE [dbo].[zpv_drawer_trans](
		[CreatedBy] [dbo].[UsernameType] NOT NULL CONSTRAINT [DF_zpv_drawer_trans_CreatedBy]  DEFAULT (suser_sname()),
		[UpdatedBy] [dbo].[UsernameType] NOT NULL CONSTRAINT [DF_zpv_drawer_trans_UpdatedBy]  DEFAULT (suser_sname()),
		[CreateDate] [dbo].[CurrentDateType] NOT NULL CONSTRAINT [DF_zpv_drawer_trans_CreateDate]  DEFAULT (getdate()),
		[RecordDate] [dbo].[CurrentDateType] NOT NULL CONSTRAINT [DF_zpv_drawer_trans_RecordDate]  DEFAULT (getdate()),
		[RowPointer] [dbo].[RowPointerType] NOT NULL CONSTRAINT [DF_zpv_drawer_trans_RowPointer]  DEFAULT (newid()),
		[NoteExistsFlag] [dbo].[FlagNyType] NOT NULL CONSTRAINT [DF_zpv_drawer_trans_NoteExistsFlag]  DEFAULT ((0)),
		[InWorkflow] [dbo].[FlagNyType] NOT NULL CONSTRAINT [DF_zpv_drawer_trans_InWorkflow]  DEFAULT ((0)),
		[trans_num] [dbo].[MatlTransNumType] NOT NULL,
		[type] [varchar](1) NULL,
		[relief_num] [dbo].[MatlTransNumType] NULL CONSTRAINT [DF_zpv_drawer_trans_relief_num]  DEFAULT ((0)),
		[trans_date] [dbo].[DateType] NULL,
		[packet] [varchar](15) NULL,
		[drawer] [varchar](15) NULL,
		[glbank_rowpointer] [dbo].[RowPointerType] NULL,
		[copay_rowpointer] [dbo].[RowPointerType] NULL,
		[amount] [dbo].[AmountType] NULL,
		[curr_code] [dbo].[CurrCodeType] NULL,
		[exch_rate] [dbo].[ExchRateType] NULL,
		[for_amount] [dbo].[AmountType] NULL,
		[apply_date] [dbo].[DateType] NULL,
		[ar_type_id] [dbo].[ZlaArTypeIdType] NULL,
		[co_num] [dbo].[CoNumType] NULL,
		[zla_bank_type] [dbo].[ZlaBankType] NULL,
		[pending] [dbo].[ListYesNoType] NULL CONSTRAINT [DF_zpv_drawer_trans_pending]  DEFAULT ((0)),
		[from_drawer] [varchar](15) NULL,
		[from_relief_num] [dbo].[MatlTransNumType] NULL CONSTRAINT [DF_zpv_drawer_trans_from_relief_num]  DEFAULT ((0)),
	 CONSTRAINT [IX_zpv_drawer_trans_RowPointer] UNIQUE NONCLUSTERED 
	(
		[RowPointer] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
	) ON [PRIMARY]

END
---------------------------------------------------------------------------------------------------------------------------------------------------------------
IF NOT (EXISTS(SELECT * FROM sys.objects WHERE [object_id] = OBJECT_ID(N'[dbo].[zpv_group_desc]') AND [type]='U'))
BEGIN
	CREATE TABLE [dbo].[zpv_group_desc](
		[CreatedBy] [dbo].[UsernameType] NOT NULL,
		[UpdatedBy] [dbo].[UsernameType] NOT NULL,
		[CreateDate] [dbo].[CurrentDateType] NOT NULL,
		[RecordDate] [dbo].[CurrentDateType] NOT NULL,
		[RowPointer] [dbo].[RowPointerType] NOT NULL,
		[NoteExistsFlag] [dbo].[FlagNyType] NOT NULL,
		[InWorkflow] [dbo].[FlagNyType] NOT NULL,
		[zpv_group_desc] [varchar](10) NOT NULL,
		[terms_code] [dbo].[TermsCodeType] NULL,
		[promotion_code] [dbo].[PromotionCodeType] NOT NULL,
		[rank] [int] NULL,
	 CONSTRAINT [PK_zpv_group_desc] PRIMARY KEY NONCLUSTERED 
	(
		[zpv_group_desc] ASC,
		[promotion_code] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
	 CONSTRAINT [IX_zpv_group_desc_RowPointer] UNIQUE NONCLUSTERED 
	(
		[RowPointer] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
	) ON [PRIMARY]

	ALTER TABLE [dbo].[zpv_group_desc] ADD  CONSTRAINT [DF_zpv_group_desc_CreatedBy]  DEFAULT (suser_sname()) FOR [CreatedBy]
	ALTER TABLE [dbo].[zpv_group_desc] ADD  CONSTRAINT [DF_zpv_group_desc_UpdatedBy]  DEFAULT (suser_sname()) FOR [UpdatedBy]
	ALTER TABLE [dbo].[zpv_group_desc] ADD  CONSTRAINT [DF_zpv_group_desc_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
	ALTER TABLE [dbo].[zpv_group_desc] ADD  CONSTRAINT [DF_zpv_group_desc_RecordDate]  DEFAULT (getdate()) FOR [RecordDate]
	ALTER TABLE [dbo].[zpv_group_desc] ADD  CONSTRAINT [DF_zpv_group_desc_RowPointer]  DEFAULT (newid()) FOR [RowPointer]
	ALTER TABLE [dbo].[zpv_group_desc] ADD  CONSTRAINT [DF_zpv_group_desc_NoteExistsFlag]  DEFAULT ((0)) FOR [NoteExistsFlag]
	ALTER TABLE [dbo].[zpv_group_desc] ADD  CONSTRAINT [DF_zpv_group_desc_InWorkflow]  DEFAULT ((0)) FOR [InWorkflow]
END

---------------------------------------------------------------------------------------------------------------------------------------------------------------
IF NOT (EXISTS(SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[zpv_parms]') AND type in (N'U')))
BEGIN
	CREATE TABLE [dbo].[zpv_parms](
		[CreatedBy] [dbo].[UsernameType] NOT NULL CONSTRAINT [DF_zpv_parms_CreatedBy]  DEFAULT (suser_sname()),
		[UpdatedBy] [dbo].[UsernameType] NOT NULL CONSTRAINT [DF_zpv_parms_UpdatedBy]  DEFAULT (suser_sname()),
		[CreateDate] [dbo].[CurrentDateType] NOT NULL CONSTRAINT [DF_zpv_parms_CreateDate]  DEFAULT (getdate()),
		[RecordDate] [dbo].[CurrentDateType] NOT NULL CONSTRAINT [DF_zpv_parms_RecordDate]  DEFAULT (getdate()),
		[RowPointer] [dbo].[RowPointerType] NOT NULL CONSTRAINT [DF_zpv_parms_RowPointer]  DEFAULT (newid()),
		[NoteExistsFlag] [dbo].[FlagNyType] NOT NULL CONSTRAINT [DF_zpv_parms_NoteExistsFlag]  DEFAULT ((0)),
		[InWorkflow] [dbo].[FlagNyType] NOT NULL CONSTRAINT [DF_zpv_parms_InWorkflow]  DEFAULT ((0)),
		[parms_key] [dbo].[ParmKeyType] NOT NULL,
		[ref_site] [dbo].[SiteType] NOT NULL,
		[inv_to_ship_acct] [dbo].[AcctType] NULL,
		[inv_to_ship_acct_unit1] [dbo].[UnitCode1Type] NULL,
		[inv_to_ship_acct_unit2] [dbo].[UnitCode2Type] NULL,
		[inv_to_ship_acct_unit3] [dbo].[UnitCode3Type] NULL,
		[inv_to_ship_acct_unit4] [dbo].[UnitCode4Type] NULL,
		[purch_disc_acct] [dbo].[AcctType] NULL,
		[purch_disc_acct_unit1] [dbo].[UnitCode1Type] NULL,
		[purch_disc_acct_unit2] [dbo].[UnitCode2Type] NULL,
		[purch_disc_acct_unit3] [dbo].[UnitCode3Type] NULL,
		[purch_disc_acct_unit4] [dbo].[UnitCode4Type] NULL,
		[rcpt_disc_acct] [dbo].[AcctType] NULL,
		[rcpt_disc_acct_unit1] [dbo].[UnitCode1Type] NULL,
		[rcpt_disc_acct_unit2] [dbo].[UnitCode2Type] NULL,
		[rcpt_disc_acct_unit3] [dbo].[UnitCode3Type] NULL,
		[rcpt_disc_acct_unit4] [dbo].[UnitCode4Type] NULL,
		[cost_variation_acct] [dbo].[AcctType] NULL,
		[cost_variation_acct_unit1] [dbo].[UnitCode1Type] NULL,
		[cost_variation_acct_unit2] [dbo].[UnitCode2Type] NULL,
		[cost_variation_acct_unit3] [dbo].[UnitCode3Type] NULL,
		[cost_variation_acct_unit4] [dbo].[UnitCode4Type] NULL,
		[lasttran_id] [varchar](10) NULL,
		[freight_amt] [dbo].[AmountType] NULL,
		[sum_credit_memo] [dbo].[FlagNyType] NULL,
		[generic_cust_type] [dbo].[CustTypeType] NULL,
		[cgs_acct] [dbo].[AcctType] NULL,
		[cgs_acct_unit1] [dbo].[UnitCode1Type] NULL,
		[cgs_acct_unit2] [dbo].[UnitCode2Type] NULL,
		[cgs_acct_unit3] [dbo].[UnitCode3Type] NULL,
		[cgs_acct_unit4] [dbo].[UnitCode4Type] NULL,
		[ctrl_fiscal] [dbo].[FlagNyType] NULL,
		[on_account_type] [dbo].[POSMPayTypeType] NULL,
		[check_tax] [decimal](10, 6) NULL,
		[iibb_tax] [decimal](10, 6) NULL,
		[com_tax] [decimal](10, 6) NULL,
		[opcost_tax] [decimal](10, 6) NULL,
		[prq_prefix] [dbo].[PreqPrefixType] NULL,
		[ret_code_customer_hold] [varchar](5) NULL,
		[ret_code_terms] [varchar](5) NULL,
		[ret_code_credit_limit] [varchar](5) NULL,
		[ret_code_balance_due] [varchar](5) NULL,
		[ret_code_freight] [varchar](5) NULL,
		[credit_hold_reason] [dbo].[ReasonCodeType] NULL,
		[ret_code_wait_check] [varchar](5) NULL,
		[time_res_temp] [numeric](3, 0) NULL CONSTRAINT [DF_zpv_parms_time_res_temp]  DEFAULT ((0)),
		[time_reserve] [numeric](3, 0) NULL CONSTRAINT [DF_zpv_parms_time_reserve]  DEFAULT ((0)),
		[ship_code] [dbo].[ShipCodeType] NULL,
		[prepaid_ar_type_id_inv] [dbo].[ZlaArTypeIdType] NULL,
		[prepaid_ar_type_id_nc] [dbo].[ZlaArTypeIdType] NULL,
	 CONSTRAINT [PK_zpv_parms] PRIMARY KEY NONCLUSTERED 
	(
		[ref_site] ASC,
		[parms_key] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
	 CONSTRAINT [IX_zpv_parms_RowPointer] UNIQUE NONCLUSTERED 
	(
		[RowPointer] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
	) ON [PRIMARY]

END

----------------------------------------------------------------------------------------------------------------------------------------------------------------
IF NOT (EXISTS(SELECT * FROM sys.objects WHERE [object_id] = OBJECT_ID(N'[dbo].[zpv_pos_enduser]') AND [type]='U'))
BEGIN
	CREATE TABLE [dbo].[zpv_pos_enduser](
		[CreatedBy] [dbo].[UsernameType] NOT NULL CONSTRAINT [DF_zpv_pos_enduser_CreatedBy]  DEFAULT (suser_sname()),
		[UpdatedBy] [dbo].[UsernameType] NOT NULL CONSTRAINT [DF_zpv_pos_enduser_UpdatedBy]  DEFAULT (suser_sname()),
		[CreateDate] [dbo].[CurrentDateType] NOT NULL CONSTRAINT [DF_zpv_pos_enduser_CreateDate]  DEFAULT (getdate()),
		[RecordDate] [dbo].[CurrentDateType] NOT NULL CONSTRAINT [DF_zpv_pos_enduser_RecordDate]  DEFAULT (getdate()),
		[RowPointer] [dbo].[RowPointerType] NOT NULL CONSTRAINT [DF_zpv_pos_enduser_RowPointer]  DEFAULT (newid()),
		[NoteExistsFlag] [dbo].[FlagNyType] NOT NULL CONSTRAINT [DF_zpv_pos_enduser_NoteExistsFlag]  DEFAULT ((0)),
		[InWorkflow] [dbo].[FlagNyType] NOT NULL CONSTRAINT [DF_zpv_pos_enduser_InWorkflow]  DEFAULT ((0)),
		[pos_code] [varchar](15) NULL,
		[end_user_type] [dbo].[EndUserTypeType] NULL,
	 CONSTRAINT [IX_zpv_pos_enduser_RowPointer] UNIQUE NONCLUSTERED 
	(
		[RowPointer] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
	) ON [PRIMARY]

END

------------------------------------------------------------------------------------------------------------------------------------------------------------------
IF NOT (EXISTS(SELECT * FROM sys.objects WHERE [object_id] = OBJECT_ID(N'[dbo].[zpv_rg1817]') AND [type]='U'))
BEGIN
	CREATE TABLE [dbo].[zpv_rg1817](
		[CreatedBy] [dbo].[UsernameType] NOT NULL CONSTRAINT [DF_zpv_rg1817_CreatedBy]  DEFAULT (suser_sname()),
		[UpdatedBy] [dbo].[UsernameType] NOT NULL CONSTRAINT [DF_zpv_rg1817_UpdatedBy]  DEFAULT (suser_sname()),
		[CreateDate] [dbo].[CurrentDateType] NOT NULL CONSTRAINT [DF_zpv_rg1817_CreateDate]  DEFAULT (getdate()),
		[RecordDate] [dbo].[CurrentDateType] NOT NULL CONSTRAINT [DF_zpv_rg1817_RecordDate]  DEFAULT (getdate()),
		[RowPointer] [dbo].[RowPointerType] NOT NULL CONSTRAINT [DF_zpv_rg1817_RowPointer]  DEFAULT (newid()),
		[NoteExistsFlag] [dbo].[FlagNyType] NOT NULL CONSTRAINT [DF_zpv_rg1817_NoteExistsFlag]  DEFAULT ((0)),
		[InWorkflow] [dbo].[FlagNyType] NOT NULL CONSTRAINT [DF_zpv_rg1817_InWorkflow]  DEFAULT ((0)),
		[cuit] [varchar](11) NOT NULL,
		[denominacion] [varchar](30) NOT NULL,
		[imp_ganancias] [varchar](2) NULL,
		[imp_iva] [varchar](2) NULL,
		[monotributo] [varchar](2) NULL,
		[int_soc] [varchar](1) NULL,
		[empleador] [varchar](1) NULL,
		[mono_act] [varchar](2) NULL,
	 CONSTRAINT [PK_zpv_rg1817] PRIMARY KEY NONCLUSTERED 
	(
		[cuit] ASC,
		[denominacion] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
	 CONSTRAINT [IX_zpv_rg1817_RowPointer] UNIQUE NONCLUSTERED 
	(
		[RowPointer] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
	) ON [PRIMARY]
END

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
IF NOT (EXISTS(SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[zpv_terms_ptype]') AND type in (N'U')))
BEGIN
	CREATE TABLE [dbo].[zpv_terms_ptype](
		[CreatedBy] [dbo].[UsernameType] NOT NULL CONSTRAINT [DF_zpv_terms_ptype_CreatedBy]  DEFAULT (suser_sname()),
		[UpdatedBy] [dbo].[UsernameType] NOT NULL CONSTRAINT [DF_zpv_terms_ptype_UpdatedBy]  DEFAULT (suser_sname()),
		[CreateDate] [dbo].[CurrentDateType] NOT NULL CONSTRAINT [DF_zpv_terms_ptype_CreateDate]  DEFAULT (getdate()),
		[RecordDate] [dbo].[CurrentDateType] NOT NULL CONSTRAINT [DF_zpv_terms_ptype_RecordDate]  DEFAULT (getdate()),
		[RowPointer] [dbo].[RowPointerType] NOT NULL CONSTRAINT [DF_zpv_terms_ptype_RowPointer]  DEFAULT (newid()),
		[NoteExistsFlag] [dbo].[FlagNyType] NOT NULL CONSTRAINT [DF_zpv_terms_ptype_NoteExistsFlag]  DEFAULT ((0)),
		[InWorkflow] [dbo].[FlagNyType] NOT NULL CONSTRAINT [DF_zpv_terms_ptype_InWorkflow]  DEFAULT ((0)),
		[terms_code] [dbo].[TermsCodeType] NULL,
		[posm_pay_type] [dbo].[POSMPayTypeType] NULL,
		[cust_type] [dbo].[CustTypeType] NULL,
	 CONSTRAINT [IX_zpv_terms_ptype_RowPointer] UNIQUE NONCLUSTERED 
	(
		[RowPointer] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
	) ON [PRIMARY]
END

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
IF NOT (EXISTS(SELECT * FROM sys.objects WHERE [object_id] = OBJECT_ID(N'[dbo].[zpv_tt_arpmtd]') AND [type]='U'))
BEGIN
	CREATE TABLE [dbo].[zpv_tt_arpmtd](
		[CreatedBy] [dbo].[UsernameType] NOT NULL,
		[UpdatedBy] [dbo].[UsernameType] NOT NULL,
		[CreateDate] [dbo].[CurrentDateType] NOT NULL,
		[RecordDate] [dbo].[CurrentDateType] NOT NULL,
		[RowPointer] [dbo].[RowPointerType] NOT NULL,
		[NoteExistsFlag] [dbo].[FlagNyType] NOT NULL,
		[InWorkflow] [dbo].[FlagNyType] NOT NULL,
		[cust_num] [dbo].[CustNumType] NOT NULL,
		[inv_num] [dbo].[InvNumType] NOT NULL,
		[dom_amt_applied] [dbo].[AmountType] NULL,
		[co_num] [dbo].[CoNumType] NULL,
		[for_amt_applied] [dbo].[AmountType] NULL,
		[exch_rate] [dbo].[ExchRateType] NULL,
	 CONSTRAINT [IX_zpv_tt_arpmtd_RowPointer] UNIQUE NONCLUSTERED 
	(
		[RowPointer] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
	) ON [PRIMARY]

	ALTER TABLE [dbo].[zpv_tt_arpmtd] ADD  CONSTRAINT [DF_zpv_tt_arpmtd_CreatedBy]  DEFAULT (suser_sname()) FOR [CreatedBy]
	ALTER TABLE [dbo].[zpv_tt_arpmtd] ADD  CONSTRAINT [DF_zpv_tt_arpmtd_UpdatedBy]  DEFAULT (suser_sname()) FOR [UpdatedBy]
	ALTER TABLE [dbo].[zpv_tt_arpmtd] ADD  CONSTRAINT [DF_zpv_tt_arpmtd_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
	ALTER TABLE [dbo].[zpv_tt_arpmtd] ADD  CONSTRAINT [DF_zpv_tt_arpmtd_RecordDate]  DEFAULT (getdate()) FOR [RecordDate]
	ALTER TABLE [dbo].[zpv_tt_arpmtd] ADD  CONSTRAINT [DF_zpv_tt_arpmtd_RowPointer]  DEFAULT (newid()) FOR [RowPointer]
	ALTER TABLE [dbo].[zpv_tt_arpmtd] ADD  CONSTRAINT [DF_zpv_tt_arpmtd_NoteExistsFlag]  DEFAULT ((0)) FOR [NoteExistsFlag]
	ALTER TABLE [dbo].[zpv_tt_arpmtd] ADD  CONSTRAINT [DF_zpv_tt_arpmtd_InWorkflow]  DEFAULT ((0)) FOR [InWorkflow]
	ALTER TABLE [dbo].[zpv_tt_arpmtd] ADD  CONSTRAINT [DF_zpv_tt_arpmtd_dom_amt_applied]  DEFAULT ((0)) FOR [dom_amt_applied]
	ALTER TABLE [dbo].[zpv_tt_arpmtd] ADD  CONSTRAINT [DF_zpv_tt_arpmtd_for_amt_applied]  DEFAULT ((0)) FOR [for_amt_applied]
	ALTER TABLE [dbo].[zpv_tt_arpmtd] ADD  CONSTRAINT [DF_zpv_tt_arpmtd_exch_rate]  DEFAULT ((1)) FOR [exch_rate]
END

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
IF NOT (EXISTS(SELECT * FROM sys.objects WHERE [object_id] = OBJECT_ID(N'[dbo].[zpv_user_pos]') AND [type]='U'))
BEGIN
	CREATE TABLE [dbo].[zpv_user_pos](
		[CreatedBy] [dbo].[UsernameType] NOT NULL CONSTRAINT [DF_zpv_user_pos_CreatedBy]  DEFAULT (suser_sname()),
		[UpdatedBy] [dbo].[UsernameType] NOT NULL CONSTRAINT [DF_zpv_user_pos_UpdatedBy]  DEFAULT (suser_sname()),
		[CreateDate] [dbo].[CurrentDateType] NOT NULL CONSTRAINT [DF_zpv_user_pos_CreateDate]  DEFAULT (getdate()),
		[RecordDate] [dbo].[CurrentDateType] NOT NULL CONSTRAINT [DF_zpv_user_pos_RecordDate]  DEFAULT (getdate()),
		[RowPointer] [dbo].[RowPointerType] NOT NULL CONSTRAINT [DF_zpv_user_pos_RowPointer]  DEFAULT (newid()),
		[NoteExistsFlag] [dbo].[FlagNyType] NOT NULL CONSTRAINT [DF_zpv_user_pos_NoteExistsFlag]  DEFAULT ((0)),
		[InWorkflow] [dbo].[FlagNyType] NOT NULL CONSTRAINT [DF_zpv_user_pos_InWorkflow]  DEFAULT ((0)),
		[Username] [dbo].[UsernameType] NULL,
		[pos_code] [varchar](15) NULL,
		[EndUserType] [dbo].[EndUserTypeType] NULL,
	 CONSTRAINT [IX_zpv_user_pos_RowPointer] UNIQUE NONCLUSTERED 
	(
		[RowPointer] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
	) ON [PRIMARY]
END

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
IF NOT (EXISTS(SELECT * FROM sys.objects WHERE [object_id] = OBJECT_ID(N'[dbo].[zpv_tt_invitem]') AND [type]='U'))
BEGIN
	CREATE TABLE [dbo].[zpv_tt_invitem](
		[CreatedBy] [dbo].[UsernameType] NOT NULL CONSTRAINT [DF_zpv_tt_invitem_CreatedBy]  DEFAULT (suser_sname()),
		[UpdatedBy] [dbo].[UsernameType] NOT NULL CONSTRAINT [DF_zpv_tt_invitem_UpdatedBy]  DEFAULT (suser_sname()),
		[CreateDate] [dbo].[CurrentDateType] NOT NULL CONSTRAINT [DF_zpv_tt_invitem_CreateDate]  DEFAULT (getdate()),
		[RecordDate] [dbo].[CurrentDateType] NOT NULL CONSTRAINT [DF_zpv_tt_invitem_RecordDate]  DEFAULT (getdate()),
		[RowPointer] [dbo].[RowPointerType] NOT NULL CONSTRAINT [DF_zpv_tt_invitem_RowPointer]  DEFAULT (newid()),
		[NoteExistsFlag] [dbo].[FlagNyType] NOT NULL CONSTRAINT [DF_zpv_tt_invitem_NoteExistsFlag]  DEFAULT ((0)),
		[InWorkflow] [dbo].[FlagNyType] NOT NULL CONSTRAINT [DF_zpv_tt_invitem_InWorkflow]  DEFAULT ((0)),
		[co_num] [dbo].[CoNumType] NULL,
		[co_line] [dbo].[CoLineType] NULL,
		[item] [dbo].[ItemType] NULL,
		[description] [dbo].[DescriptionType] NULL,
		[qty_invoiced] [dbo].[QtyUnitType] NULL,
		[qty_nulled] [dbo].[QtyUnitType] NULL,
		[total_invoiced] [dbo].[AmountType] NULL,
		[total_nulled] [dbo].[AmountType] NULL
	 CONSTRAINT [IX_zpv_tt_invitem_RowPointer] UNIQUE NONCLUSTERED 
	(
		[RowPointer] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
	) ON [PRIMARY]
END
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
IF NOT (EXISTS(SELECT * FROM sys.objects WHERE [object_id] = OBJECT_ID(N'[dbo].[zpv_tt_cobill]') AND [type]='U'))
BEGIN
	CREATE TABLE [dbo].[zpv_tt_cobill](
		[cust_num] [dbo].[CustNumType] NULL,
		[co_num] [dbo].[CoNumType] NULL,
		[CreatedBy] [dbo].[UsernameType] NOT NULL CONSTRAINT [DF_zpv_tt_cobill_CreatedBy]  DEFAULT (suser_sname()),
		[UpdatedBy] [dbo].[UsernameType] NOT NULL CONSTRAINT [DF_zpv_tt_cobill_UpdatedBy]  DEFAULT (suser_sname()),
		[CreateDate] [dbo].[CurrentDateType] NOT NULL CONSTRAINT [DF_zpv_tt_cobill_CreateDate]  DEFAULT (getdate()),
		[RecordDate] [dbo].[CurrentDateType] NOT NULL CONSTRAINT [DF_zpv_tt_cobill_RecordDate]  DEFAULT (getdate()),
		[RowPointer] [dbo].[RowPointerType] NOT NULL CONSTRAINT [DF_zpv_tt_cobill_RowPointer]  DEFAULT (newid()),
		[NoteExistsFlag] [dbo].[FlagNyType] NOT NULL CONSTRAINT [DF_zpv_tt_cobill_NoteExistsFlag]  DEFAULT ((0)),
		[InWorkflow] [dbo].[FlagNyType] NOT NULL CONSTRAINT [DF_zpv_tt_cobill_InWorkflow]  DEFAULT ((0)),
	 CONSTRAINT [IX_zpv_tt_cobill_RowPointer] UNIQUE NONCLUSTERED 
	(
		[RowPointer] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
	) ON [PRIMARY]
END
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
IF NOT (EXISTS(SELECT * FROM sys.objects WHERE [object_id] = OBJECT_ID(N'[dbo].[zpv_ar_clearing]') AND [type]='U'))
BEGIN
	CREATE TABLE [dbo].[zpv_ar_clearing](
		[clearing_date]		[dbo].[DateType] NOT NULL DEFAULT(getdate())
	,	[clearing]			[dbo].[ZpvClearingType] NOT NULL
	,	[cust_num]			[dbo].[CustNumType] NULL
	,	[name]				[dbo].[NameType] NULL
	,	[tax_reg_num1]		[dbo].[TaxRegNumType] NULL
	,	[amount]			[dbo].[AmountType] NULL
	,	[CreatedBy] [dbo].[UsernameType] NOT NULL CONSTRAINT [DF_zpv_ar_clearing_CreatedBy]  DEFAULT (suser_sname())
	,	[UpdatedBy] [dbo].[UsernameType] NOT NULL CONSTRAINT [DF_zpv_ar_clearing_UpdatedBy]  DEFAULT (suser_sname())
	,	[CreateDate] [dbo].[CurrentDateType] NOT NULL CONSTRAINT [DF_zpv_ar_clearing_CreateDate]  DEFAULT (getdate())
	,	[RecordDate] [dbo].[CurrentDateType] NOT NULL CONSTRAINT [DF_zpv_ar_clearing_RecordDate]  DEFAULT (getdate())
	,	[RowPointer] [dbo].[RowPointerType] NOT NULL CONSTRAINT [DF_zpv_ar_clearing_RowPointer]  DEFAULT (newid())
	,	[NoteExistsFlag] [dbo].[FlagNyType] NOT NULL CONSTRAINT [DF_zpv_ar_clearing_NoteExistsFlag]  DEFAULT ((0))
	,	[InWorkflow] [dbo].[FlagNyType] NOT NULL CONSTRAINT [DF_zpv_ar_clearing_InWorkflow]  DEFAULT ((0))
	 CONSTRAINT [PK_zpv_ar_clearing] PRIMARY KEY NONCLUSTERED 
	(
		[clearing] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],

	 CONSTRAINT [IX_zpv_ar_clearing_RowPointer] UNIQUE NONCLUSTERED 
	(
		[RowPointer] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
	) ON [PRIMARY]
END

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
IF NOT (EXISTS(SELECT * FROM sys.objects WHERE [object_id] = OBJECT_ID(N'[dbo].[zpv_ar_clearing_expenses]') AND [type]='U'))
BEGIN
	CREATE TABLE [dbo].[zpv_ar_clearing_expenses](
		[clearing_date]		[dbo].[DateType] NOT NULL DEFAULT(getdate())
	,	[clearing]			[dbo].[ZpvClearingType] NOT NULL
	,	[seq]				int NOT NULL
	,	[acct]				[dbo].[AcctType] NULL
	,	[acct_unit1]		[dbo].[UnitCode1Type] NULL
	,	[acct_unit2]		[dbo].[UnitCode1Type] NULL
	,	[acct_unit3]		[dbo].[UnitCode1Type] NULL
	,	[acct_unit4]		[dbo].[UnitCode1Type] NULL
	,	[description]		[dbo].[DescriptionType] NULL
	,	[obs]				varchar(5000) NULL
	,	[amount]			[dbo].[AmountType] NULL
	,	[CreatedBy] [dbo].[UsernameType] NOT NULL CONSTRAINT [DF_zpv_ar_clearing_expenses_CreatedBy]  DEFAULT (suser_sname())
	,	[UpdatedBy] [dbo].[UsernameType] NOT NULL CONSTRAINT [DF_zpv_ar_clearing_expenses_UpdatedBy]  DEFAULT (suser_sname())
	,	[CreateDate] [dbo].[CurrentDateType] NOT NULL CONSTRAINT [DF_zpv_ar_clearing_expenses_CreateDate]  DEFAULT (getdate())
	,	[RecordDate] [dbo].[CurrentDateType] NOT NULL CONSTRAINT [DF_zpv_ar_clearing_expenses_RecordDate]  DEFAULT (getdate())
	,	[RowPointer] [dbo].[RowPointerType] NOT NULL CONSTRAINT [DF_zpv_ar_clearing_expenses_RowPointer]  DEFAULT (newid())
	,	[NoteExistsFlag] [dbo].[FlagNyType] NOT NULL CONSTRAINT [DF_zpv_ar_clearing_expenses_NoteExistsFlag]  DEFAULT ((0))
	,	[InWorkflow] [dbo].[FlagNyType] NOT NULL CONSTRAINT [DF_zpv_ar_clearing_expenses_InWorkflow]  DEFAULT ((0))
	 CONSTRAINT [PK_zpv_ar_clearing_expenses] PRIMARY KEY NONCLUSTERED 
	(
		[clearing] ASC,
		[seq]	ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],

	 CONSTRAINT [IX_zpv_ar_clearing_expenses_RowPointer] UNIQUE NONCLUSTERED 
	(
		[RowPointer] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
	) ON [PRIMARY]
END

GO


