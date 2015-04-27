/****** Object:  StoredProcedure [dbo].[ZPV_JourpostSp]    Script Date: 16/01/2015 03:13:03 p.m. ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ZPV_JourpostSp]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[ZPV_JourpostSp]
GO

/****** Object:  StoredProcedure [dbo].[ZPV_JourpostSp]    Script Date: 16/01/2015 03:13:03 p.m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






-- lib/jourpost.p -- POST a transaction to a G/L Distribution Journal.
--
-- IMPORTANT NOTE: If original call to jourpost.p went through jourpost.i
-- make sure to call JourpostISp rather than JourpostSp directly.

/* $Header: /ApplicationDB/Stored Procedures/JourpostSp.sp 28    12/11/13 10:19a Cajones $ */
/*
***************************************************************
*                                                             *
*                           NOTICE                            *
*                                                             *
*   THIS SOFTWARE IS THE PROPERTY OF AND CONTAINS             *
*   CONFIDENTIAL INFORMATION OF INFOR AND/OR ITS AFFILIATES   *
*   OR SUBSIDIARIES AND SHALL NOT BE DISCLOSED WITHOUT PRIOR  *
*   WRITTEN PERMISSION. LICENSED CUSTOMERS MAY COPY AND       *
*   ADAPT THIS SOFTWARE FOR THEIR OWN USE IN ACCORDANCE WITH  *
*   THE TERMS OF THEIR SOFTWARE LICENSE AGREEMENT.            *
*   ALL OTHER RIGHTS RESERVED.                                *
*                                                             *
*   (c) COPYRIGHT 2010 INFOR.  ALL RIGHTS RESERVED.           *
*   THE WORD AND DESIGN MARKS SET FORTH HEREIN ARE            *
*   TRADEMARKS AND/OR REGISTERED TRADEMARKS OF INFOR          *
*   AND/OR ITS AFFILIATES AND SUBSIDIARIES. ALL RIGHTS        *
*   RESERVED.  ALL OTHER TRADEMARKS LISTED HEREIN ARE         *
*   THE PROPERTY OF THEIR RESPECTIVE OWNERS.                  *
*                                                             *
*************************************************************** 
*/

CREATE PROCEDURE [dbo].[ZPV_JourpostSp] (
   @id           JournalIdType,
   @trans_num    MatlTransNumType = 0,
   @trans_date   DateType,
   @acct         AcctType,
   @acct_unit1   UnitCode1Type = NULL,
   @acct_unit2   UnitCode2Type = NULL,
   @acct_unit3   UnitCode3Type = NULL,
   @acct_unit4   UnitCode4Type = NULL,
   @amount       AmountType,
   @ref          ReferenceType = NULL,
   @vend_num     VendNumType = NULL,
   @inv_num      VendInvNumType = NULL,
   @voucher      InvNumVoucherType = '0',
   @check_num    GlCheckNumType = 0,
   @check_date   DateType = NULL,
   @from_site    SiteType = NULL,
   @ref_type     AnyRefTypeType = NULL,
   @ref_num      AnyRefNumType = NULL,
   @ref_line_suf AnyRefLineType = 0,
   @ref_release  AnyRefReleaseType = 0,
   @vouch_seq    VouchSeqType = 0,
   @bank_code    BankCodeType = NULL,
   @curr_code    CurrCodeType = NULL,
   @for_amount   AmountType = @amount,
   @exch_rate    ExchRateType = 1,
   @reverse      ListYesNoType = 0,
     @ControlPrefix JourControlPrefixType = null
   , @ControlSite SiteType = null
   , @ControlYear FiscalYearType = null
   , @ControlPeriod FinPeriodType = null
   , @ControlNumber LastTranType = null
   , @last_seq     JournalSeqType = null OUTPUT
   , @Infobar      InfobarType   OUTPUT
, @BufferJournal RowPointerType = null
, @DomCurrCode CurrCodeType = NULL
, @DomCurrPlaces DecimalPlacesType = NULL
, @proj_trans_num ProjTransNumType = NULL
)
AS

if @BufferJournal is null
   SET @BufferJournal = dbo.DefinedValue('JournalDeferred')


DECLARE
   @Severity          INT,
   @places            DecimalPlacesType,
   @comp_level        JournalCompLevelType,
   @compress          ListYesNoType,
   @t_comp_level      ListYesNoType,
   @prm_curr_code     CurrCodeType

declare
  @RefControlPrefix JourControlPrefixType
, @RefControlSite SiteType
, @RefControlYear FiscalYearType
, @RefControlPeriod FinPeriodType
, @RefControlNumber LastTranType
, @GetDate  DateType
, @InvNumLength	InvNumLength

SELECT TOP 1
  @InvNumLength	= coparms.inv_num_length 
FROM coparms with (readuncommitted)

SET @GetDate = getdate()

SET @Infobar = NULL
set @Severity = 0
set @places = @DomCurrPlaces
set @prm_curr_code = @DomCurrCode

IF @curr_code IS NULL
   SELECT TOP 1
   @curr_code = curr_code
   FROM currparms with (readuncommitted)
-- don't create zero amount journal records
IF @amount = 0
   return 0

if @places is null or @prm_curr_code is null
   SELECT
      @places            = cur.places,
      @prm_curr_code     = prm.curr_code
   FROM currparms prm with (readuncommitted), currency cur with (readuncommitted)
   WHERE cur.curr_code = prm.curr_code AND prm.parm_key = 0

   SELECT @amount = round(@amount, @places)
   -- check to see if the amount rounded to zero
   IF @amount = 0
      return 0

   IF @curr_code IS NULL
      SELECT @curr_code = @prm_curr_code

   SET @comp_level = NULL
   set @compress = 0

   IF @id = 'SF Dist'
      select @comp_level = case when sfcparms.sfdist_comp_level != 'N' then sfcparms.sfdist_comp_level end
      , @compress = sfcparms.sfdist_comp
      , @ref = case when sfcparms.sfdist_comp = 1 then 'SF' else @ref end
      from sfcparms with (readuncommitted)
   else if @id = 'IC Dist'
      select @comp_level = case when invparms.icdist_comp_level != 'N' then invparms.icdist_comp_level end
      , @compress = invparms.icdist_comp
      , @ref = case when invparms.icdist_comp = 1 then 'IC' else @ref end
      from invparms with (readuncommitted)
   else if @id = 'CO Dist'
      select @comp_level = case when coparms.codist_comp_level != 'N' then coparms.codist_comp_level end
      , @compress = coparms.codist_comp
      , @ref = case when coparms.codist_comp = 1 then 'CO' else @ref end
      from coparms with (readuncommitted)
   else if @id = 'PO Dist'
      select @comp_level = case when poparms.podist_comp_level != 'N' then poparms.podist_comp_level end
      , @compress = poparms.podist_comp
      , @ref = case when poparms.podist_comp = 1 then 'PO' else @ref end
      from poparms with (readuncommitted)
   else IF @id = 'PR Dist'
      SELECT @comp_level = case when prparms.prdist_comp_level != 'N' then prparms.prdist_comp_level end
      , @compress = prparms.compress
      FROM prparms WITH (READUNCOMMITTED)
      WHERE prparms_key = 0

   SET @last_seq = -1            -- @last_seq = -1 indicates that a new record must be inserted into journal


BEGIN
   select top(1) @last_seq = seq + 1 from journal_mst where id = @id order by seq desc

   if @last_seq is null or @last_seq = 0 or @last_seq = -1
   set @last_seq = 1

   INSERT INTO journal
      (id,
       seq,
       trans_date,
       acct ,
       acct_unit1,
       acct_unit2,
       acct_unit3,
       acct_unit4,
       dom_amount,
       ref,
       vend_num ,
       inv_num ,
       voucher ,
       check_num ,
       check_date ,
       from_site ,
       matl_trans_num,
       ref_type ,
       ref_num ,
       ref_line_suf ,
       ref_release ,
       vouch_seq ,
       bank_code ,
       curr_code ,
       for_amount ,
       exch_rate,
       reverse
     , control_prefix
     , control_site
     , control_year
     , control_period
     , control_number
     , ref_control_prefix
     , ref_control_site
     , ref_control_year
     , ref_control_period
     , ref_control_number
     , proj_trans_num 
       )
   VALUES
      (@id,
       @last_seq,
       @trans_date,
       @acct,
       CASE WHEN @compress <> 1 OR (@compress =1 AND @t_comp_level =1)  THEN @acct_unit1 ELSE NULL END,
       CASE WHEN @compress <> 1 OR (@compress =1 AND @t_comp_level =1)  THEN @acct_unit2 ELSE NULL END,
       CASE WHEN @compress <> 1 OR (@compress =1 AND @t_comp_level =1)  THEN @acct_unit3 ELSE NULL END,
       CASE WHEN @compress <> 1 OR (@compress =1 AND @t_comp_level =1)  THEN @acct_unit4 ELSE NULL END,
       @amount,
       @ref,
       @vend_num ,
       @inv_num ,
       case when @id = 'AP Dist' OR @id = 'PO Dist' then dbo.ExpandKy(@InvNumLength, @voucher) else @voucher end,
       @check_num ,
       @check_date ,
       @from_site ,
       @trans_num,
       @ref_type ,
       @ref_num ,
       @ref_line_suf ,
       @ref_release ,
       @vouch_seq ,
       @bank_code ,
       CASE WHEN @compress=1 THEN @Prm_curr_code ELSE @curr_code END,
       CASE WHEN @compress=1 THEN @amount ELSE @for_amount END,
       CASE WHEN @compress=1 THEN 1 ELSE @exch_rate END,
       @reverse
   , @ControlPrefix
   , @ControlSite
   , @ControlYear
   , @ControlPeriod
   , @ControlNumber
   , @ControlPrefix
   , @ControlSite
   , @ControlYear
   , @ControlPeriod
   , @ControlNumber
   , @proj_trans_num 
       )
    SET @Severity = @@ERROR
    IF @Severity <> 0
       RETURN @Severity
END  -- end create new journal entry

-- Still TODO : add code for notes

RETURN @Severity





GO

