/****** Object:  Trigger [co_mstDel]    Script Date: 28/12/2014 05:36:24 p.m. ******/
IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'co_mstDel' AND xtype = 'TR')
DROP TRIGGER [dbo].[co_mstDel]
GO

/****** Object:  Trigger [dbo].[co_mstDel]    Script Date: 28/12/2014 05:36:24 p.m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





/* $Header: /ApplicationDB/Triggers/co_mstDel.trg 32    11/25/13 9:50p Lqian2 $ */
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

/* $Archive: /ApplicationDB/Triggers/co_mstDel.trg $
 *
 * SL9.00 32 170456 Lqian2 Mon Nov 25 21:50:07 2013
 * Rows not being inserted into chart_mst_all table
 * Issue 170456, Fix multi-site in one DB.
 *
 * SL8.04 31 RS5183 Djackson Mon Jul 08 13:10:14 2013
 * RS5183 TriggerContractDeleteSync
 *
 * SL8.04 30 160293 btian Fri Apr 19 01:31:24 2013
 * Receive error:  The Specific Note Token entered is not valid.
 * 160293, add logic to delete NotesSiteMap before the delete of ObjectNotes.
 *
 * SL8.04 29 RS4615 Jmtao Thu Dec 06 21:41:57 2012
 * RS4615(Multi - Add Site within a Site Functionality).
 *
 * SL8.04 28 RS5566 Cliu Fri Oct 19 02:25:40 2012
 * Modified to add additional CCI functionality.
 * RS5566
 *
 * SL8.04 27 94565 Dlai Mon Jul 23 22:51:35 2012
 * RemoteMethodCallSp Clean-up
 * 94565-All objects that utilize RemoteMethodCallSp should pass in NULL for the IDO.
 *
 * SL8.03 26 146769 sturney Fri Apr 06 11:40:38 2012
 * Issue for RS 5183 AutoConnect Inegration
 * Issue 146769
 *
 * SL8.03 25 146769 sturney Thu Mar 29 15:07:50 2012
 * Issue for RS 5183 AutoConnect Inegration
 * Issue 146769  Added TriggerContractDeleteSp
 *
 * SL8.03 24 139739 djohnson Mon Jul 11 16:16:26 2011
 * Issue #139739 - add a delete of DocumentObjectReference above the delete of ObjectNotes.
 *
 * SL8.03 23 RS 1838 vanmmar Thu Jun 23 09:54:11 2011
 * RS 1838
 *
 * SL8.03 22 135437 pgross Thu Dec 23 16:27:12 2010
 * Accum CO Value in Customer Letter of Credit form not update correctly
 * deallocate amounts from LCR
 *
 * SL8.02 21 rs4588 Dahn Tue Mar 09 08:48:22 2010
 * rs4588 copyright header changes.
 *
 * SL8.01 20 rs3953 Dahn Tue Aug 26 10:14:13 2008
 * changing the copyright header (rs3953)
 *
 * SL8.01 19 rs3953 Dahn Mon Aug 18 14:08:54 2008
 * changing copyright information(RS3953)
 *
 * SL8.01 18 109473 Djackson1 Fri Jun 06 12:10:00 2008
 * Need to publish a BOD for deletes
 * 109473 SalseOrderDelete BOD
 *
 * SL8.01 17 109471 Djackson1 Thu Jun 05 16:44:18 2008
 * Need to publish a BOD for deletes
 * 109471 QuoteDelete BOD
 *
 * SL8.01 16 108501 nmannam Tue Mar 25 04:53:40 2008
 * Error message and not able to ship Reserved item: "Procedure or Function 'UpdResvSp' expects parameter '@SessionID', which was not supplied."
 * 108501- sessionid is passed to 'UpdResvSp'.
 *
 * SL8.00 15 RS2968 nkaleel Fri Feb 23 06:52:49 2007
 * changing copyright information(RS2968)
 *
 * SL8.00 14 87795 Clarsco Fri Oct 20 10:42:57 2006
 * Fixed Bug 87795:
 * @Infobar OUTPUT parameter required on DeleteKeySp call.
 *
 * SL8.00 13 RS2968 prahaladarao.hs Wed Jul 12 07:02:04 2006
 * RS 2968, Name change CopyRight Update.
 *
 * SL7.05 12 85244 hcl-tiwasun Thu Mar 10 06:47:25 2005
 * co_mstDel.trg does double work on co_all
 * Issue No: 85244
 * 
 * Duplicate delete statement has been removed.
 *
 * $NoKeywords: $
 */
CREATE TRIGGER [dbo].[co_mstDel]
on [dbo].[co_mst]
FOR DELETE
AS

IF @@ROWCOUNT = 0 RETURN

-- Skip trigger operations as required.
DECLARE @Site SiteType
SELECT @Site = prm.site
FROM parms AS prm with (readuncommitted)
WHERE prm.parm_key = 0

IF dbo.SkipBaseTrigger() = 1
  IF dbo.SkipAllUpdate() = 1
    RETURN
  ELSE
    GOTO DELETE_ALL

DECLARE
  @Severity INT
, @Infobar  InfobarType

SET @Severity = 0


/*========   CURSOR PROCESSING SECTION    ========*/
DECLARE
  @CoNum          CoNumType
, @OrigSite       SiteType
, @ParmsSite      SiteType
, @CustNum        CustNumType
, @Price          CostPrcType
, @Type           DefaultCharType
, @RowPointer     RowPointerType
, @RsiRowPointer  RowPointerType
, @RsiQtyRsvdConv QtyUnitType
, @CoLine         CoLineType
, @CoRelease      CoLineType
, @CoStatus       CoStatusType
, @Item           ItemType
, @RefType        UnknownRefTypeType
, @RefNum         CoNumType
, @RefLineSuf     CoLineType
, @RefRelease     CoLineType
, @DueDate        DateType
, @ItemStatus     CoStatusType
, @QtyOrdered     QtyUnitType
, @QtyShipped     QtyUnitType
, @QtyReturned    QtyUnitType
, @Adjust         AmountType
, @MiscCharges    AmountType
, @Freight        AmountType
, @SalesTax       AmountType
, @SalesTax2      AmountType
, @Avail_Cfg      ListYesNoType
, @ConfigId       ConfigIdType
, @LcrNum LcrNumType
, @ShipSite       SiteType
, @ShipSiteList   Infobar
, @iEntry         INT
, @iNumEntries    INT
, @CustItem       CustItemType          
, @SessionID      RowPointerType
, @Parm1Value     nvarchar(160)
, @IsExternal     ListYesNoType

SELECT @ParmsSite = @Site

DECLARE co_mstDelCrs CURSOR LOCAL STATIC READ_ONLY
FOR SELECT
  dd.co_num
, dd.stat
, dd.orig_site
, dd.cust_num
, dd.price
, dd.type
, dd.misc_charges
, dd.freight
, dd.sales_tax
, dd.sales_tax_2
, dd.config_id
, dd.lcr_num
, dd.is_external
FROM deleted dd

OPEN co_mstDelCrs
WHILE @Severity = 0
BEGIN /* cursor loop */
    IF dbo.VariableIsDefined('ChangeCoToHistory') = 1
    BEGIN
       --EXEC SLDevEnv_App.dbo.SQLTraceSp 'Skipping co_mstDel processing', 'thoblo'
       BREAK
    END

    FETCH co_mstDelCrs INTO
      @CoNum
    , @CoStatus
    , @OrigSite
    , @CustNum
    , @Price
    , @Type
    , @MiscCharges
    , @Freight
    , @SalesTax
    , @SalesTax2
    , @ConfigId
    , @LcrNum
    , @IsExternal

    IF @@FETCH_STATUS = -1
        BREAK

    -- Validate OrigSite is current site
    -- Removed this restriction. Prevent this at the form level.
    /*
    IF ISNULL(@OrigSite, CHAR(1)) <> ISNULL(@ParmsSite, CHAR(1))
    BEGIN
       EXEC @Severity =  MsgAppSp @Infobar OUTPUT, 'E=CmdFailed', '@%delete'
       EXEC @Severity =  MsgAppSp @Infobar OUTPUT, 'I=IsCompare1',
         '@co.orig_site', @OrigSite
       , '@co'
       , '@co.co_num', @CoNum
       IF @Severity <> 0
          BREAK
    END
    */

    -- Replace above with following (from as/rules/delete/co.p)
    IF @Type <> 'E'
    BEGIN
       SET @Adjust = 0
       SET @Adjust = @Adjust - (@MiscCharges + @Freight + @SalesTax + @SalesTax2)
       -- May hold this off until the bottom of the trigger
       IF @Adjust <> 0
       BEGIN
          EXEC @Severity = dbo.UpdObalSp @CustNum, @Adjust
          IF @Severity <> 0
             BREAK
       END
    END

    -- Delete blanket lines for Blanket orders
    -- (from co/del-co.i)
    IF @Type = 'B'
    BEGIN
   -- ESB BOD for Delete of a CO
   IF @IsExternal = 1
   BEGIN
     DECLARE CoBlnCrs CURSOR LOCAL STATIC READ_ONLY
     FOR SELECT
       co_line
       from co_bln as cob where
       cob.co_num = @CoNum
       
     OPEN CoBlnCrs
     WHILE 1 = 1
     BEGIN
        FETCH CoBlnCrs into
          @CoLine
                 
        IF @@fetch_status != 0
           BREAK   
           
        SET @Parm1Value = LTRIM(RTRIM(@CoNum)) + '~' + LTRIM(RTRIM(STR(@CoLine)))   
        EXEC @Severity   = dbo.RemoteMethodForReplicationTargetsSp
            @IdoName    = 'SP!'
            , @MethodName = 'TriggerContractDeleteSyncSp'
            , @Infobar    = @Infobar OUTPUT
            , @Parm1Value = @Parm1Value 
        
        IF @Severity > 0
           BREAK
     END 
     CLOSE CoBlnCrs
     DEALLOCATE CoBlnCrs        
   END
       
       DELETE co_bln
       WHERE  co_num = @CoNum
       SET @Severity = @@ERROR
       IF @Severity <> 0
          BREAK
    END

    -- Loop through CoItems

    DECLARE co_mstDelItemCrs CURSOR LOCAL STATIC READ_ONLY
    FOR SELECT
      coi.co_line
    , coi.co_release
    , coi.item
    , coi.ref_type
    , coi.ref_num
    , coi.ref_line_suf
    , coi.ref_release
    , coi.qty_ordered
    , coi.qty_shipped
    , coi.qty_returned
    , coi.due_date
    , coi.stat
    , coi.ship_site
    , coi.cust_item       
    FROM coitem coi
    WHERE coi.co_num = @CoNum

    OPEN co_mstDelItemCrs
    WHILE @Severity = 0
    BEGIN /* cursor loop */
       FETCH co_mstDelItemCrs INTO
         @CoLine
       , @CoRelease
       , @Item
       , @RefType
       , @RefNum
       , @RefLineSuf
       , @RefRelease
       , @QtyOrdered
       , @QtyShipped
       , @QtyReturned
       , @DueDate
       , @ItemStatus
       , @ShipSite
       , @CustItem    
  
       IF @@FETCH_STATUS = -1
          BREAK

       IF @@FETCH_STATUS = -2
          CONTINUE

       -- Check coitem and matltran status
       -- Do this only if on orig site
       IF ISNULL(@OrigSite, CHAR(1)) = ISNULL(@ParmsSite, CHAR(1)) AND @Type <> 'E'
       BEGIN
          EXEC @Severity = dbo.CoitmCdSp
            @CoNum
          , @CoLine
          , @CoRelease
          , NULL
          , NULL
          , NULL
          , NULL
          , @Infobar OUTPUT
          , @ShipSite

          IF @Severity <> 0
             BREAK
       END

       -- Delete inventory reservations

       DECLARE co_mstDelInvCrs2 CURSOR LOCAL STATIC READ_ONLY
       FOR SELECT
         rsi.RowPointer
       , rsi.qty_rsvd_conv
       FROM rsvd_inv AS rsi
       WHERE rsi.ref_num = @CoNum
       AND rsi.ref_line = @CoLine
       AND rsi.ref_release = @CoRelease

       OPEN co_mstDelInvCrs2
       WHILE @Severity = 0
       BEGIN
          FETCH co_mstDelInvCrs2 INTO
            @RsiRowPointer
          , @RsiQtyRsvdConv

          IF @@FETCH_STATUS = -1
             BREAK

          IF @@FETCH_STATUS = -2
             CONTINUE
          SET @SessionID     = dbo.SessionIDSp()
          -- (from co/del-co.i)
          EXEC @Severity = dbo.UpdResvSp
            1 -- @DelRsvd true
          , @RsiRowPointer
          , @RsiQtyRsvdConv
          , 1 -- @ConvFactor
          , 'From Base' -- @FromBase
          , @Infobar OUTPUT
          , @SessionID
          IF @Severity <> 0
             BREAK
       END -- End Delete inventory reservations
       CLOSE co_mstDelInvCrs2
       DEALLOCATE co_mstDelInvCrs2
       IF @Severity <> 0
          BREAK

       -- Remove X-REF in PO and JOB SHOP for deleted items
       -- (from co/del-co.i)

       IF ( @RefType <> 'I' AND @RefNum IS NOT NULL )
       BEGIN
          EXEC @Severity = dbo.ClrXrefSp
            @RefType
          , @RefNum
          , @RefLineSuf
          , @RefRelease
          , @CoNum
          , @CoLine
          , @CoRelease
          , @Infobar OUTPUT
          IF @Severity <> 0
             BREAK
       END

       -- Do the following if co type is not 'E'stimate
       -- (from co/del-co.i)
       IF @Type <> 'E'
       BEGIN
          -- Update itemcust quantities

          UPDATE itemcust
          SET purch_ytd = purch_ytd - 1
          ,   order_ytd = order_ytd - @QtyOrdered
          ,   order_ptd = order_ptd - @QtyOrdered
          WHERE itemcust.cust_num = @CustNum
          AND   itemcust.item = @Item
          AND   ISNULL(itemcust.cust_item, NCHAR(1)) = ISNULL(@CustItem, NCHAR(1))
          SET @Severity = @@ERROR
          IF @Severity <> 0
             BREAK

          -- Delete related co_ship records

          DELETE co_ship
          WHERE  co_num = @CoNum
          AND    co_line = @CoLine
          SET @Severity = @@ERROR
          IF @Severity <> 0
              BREAK

          -- Delete related progbill records

          DELETE progbill
          WHERE  co_num = @CoNum
          AND    co_line = @CoLine
          SET @Severity = @@ERROR
          IF @Severity <> 0
             BREAK
       END -- End Type <> 'E' processing

       -- Delete featqty records
       -- (from co/del-co.i)
       DELETE featqty
       WHERE  co_num = @CoNum
       AND    co_line = @CoLine
       SET @Severity = @@ERROR
       IF @Severity <> 0
          BREAK

      /* IF @Type <> 'E'
      ** No longer a need for this (5/9/02)
      ** BEGIN

          ** MRP stuff
          ** Run CoFcstSp
          */
          /*
          ** Run ConsForSp
       END */-- End Type <> 'E' processing
    END -- End loop through CoItems

    CLOSE co_mstDelItemCrs
    DEALLOCATE co_mstDelItemCrs
    IF @Severity <> 0
       BREAK

    -- Delete associated coitem records
    -- (from co/del-co.i)
    DELETE coitem
    WHERE  co_num = @CoNum
    SET @Severity = @@ERROR
    IF @Severity <> 0
       BREAK

	DELETE FROM zpv_co_retentions
		WHERE
			co_num  = @CoNum
	
	DELETE FROM zla_coitem_tax
		WHERE
			co_num = @CoNum		
			
	DELETE FROM zla_co_tax_mst
		WHERE
			co_num = @CoNum			

    IF @Type <> 'E'
    BEGIN
       -- Delete associated co_sls_comm records
       -- (from co/del-co.i)
       DELETE co_sls_comm
       WHERE  co_num = @CoNum
       SET @Severity = @@ERROR
       IF @Severity <> 0
          BREAK

       -- Delete associated shipco records
       -- (from co/del-co.i)
       DELETE shipco
       WHERE  co_num = @CoNum
       SET @Severity = @@ERROR
       IF @Severity <> 0
          BREAK
       --ESB BOD for Delete of a Customer Order
       EXEC @Severity  = dbo.RemoteMethodForReplicationTargetsSp
            @IdoName      = 'SP!'
          , @MethodName   = 'TriggerSalesOrderDeleteSyncSp'
          , @Infobar      = @Infobar OUTPUT
          , @Parm1Value   = @CoNum

    END -- End Type <> 'E' processing

    -- TPB Ask Dave Palmer about this???
    IF @Type = 'E'
    BEGIN
       -- Get Values of Session(Global) Variables
       -- to find whether Cfg module is part of the SL system
       EXEC @Severity = dbo.GetVariableSp
                        Avail_Cfg,
                        0, -- DefaultValueReturned
                        0, -- DeleteVariable
                        @Avail_Cfg OUTPUT,
                        @Infobar OUTPUT
       IF @Severity <> 0 BREAK

       IF @Avail_Cfg = 1 AND @ConfigId IS NOT NULL
       BEGIN
          -- run cfg-pp/del-cfg.p
          EXEC @Severity = dbo.CfgDelConfigSp
               @DeleteFrom = 'CO'
             , @PConfigId  = @ConfigId
             , @Infobar    = @Infobar OUTPUT
          IF @Severity <> 0
             BREAK
       END
       --ESB BOD for Delete of a Quote
       IF @CoStatus = 'Q'
       BEGIN
         SET @Parm1Value = 'SalesOrder~' + @CoNum
         EXEC @Severity  = dbo.RemoteMethodForReplicationTargetsSp
              @IdoName      = 'SP!'
            , @MethodName   = 'TriggerQuoteDeleteSyncSp'
            , @Infobar      = @Infobar OUTPUT
            , @Parm1Value   = @Parm1Value
         IF @Severity <> 0
             BREAK
       END
      
    END -- End Type = 'E' processing

    -- Check lib/audit.i - Not implemented in SyteLine on SQL

    IF @Severity != 0
    BEGIN
      EXEC dbo.RaiseErrorSp @Infobar, @Severity
      EXEC @Severity = dbo.RollbackTransactionSp
        @Severity
      IF @Severity != 0
      BEGIN
        ROLLBACK TRANSACTION
        RETURN
      END
    END
    ELSE
    -- Do deletes for other sites.
    BEGIN
       SET @ShipSiteList = dbo.GetSsl(@CoNum, @Type) -- Get Ship sites
       SET @iEntry = 1
       SET @iNumEntries = dbo.NumEntries(@ShipSiteList, ',')
       WHILE @iEntry <= @iNumEntries
       BEGIN
          SET @ShipSite = dbo.Entry(@iEntry, @ShipSiteList, ',')
          IF  @ShipSite IS NOT NULL AND @ShipSite <> @OrigSite AND
              @ParmsSite <> @ShipSite -- Check this out
          BEGIN
             EXEC @Severity = dbo.RemoteMethodCallSp
               @Site       = @ShipSite
             , @IdoName    = NULL
             , @MethodName = 'DeleteCoSp'
             , @Infobar    = @Infobar OUTPUT
             , @Parm1Value = @CoNum
             , @Parm2Value = 1           -- @RepFromTrigger
             , @Parm3Value = @ParmsSite  -- @RepFromSite

             IF @Severity <> 0
                BREAK
          END
          SET @iEntry = @iEntry + 1
       END
       IF @Severity <> 0
          BREAK
    END
   -- Update specified LCR
   IF @LcrNum IS NOT NULL
   BEGIN
      EXEC @Severity = dbo.UpdateLcrSp
        @CoNum    = @CoNum
      , @CustNum  = @CustNum
      , @AddAccum = 0
      , @LcrNum   = @LcrNum
      , @Infobar  = @Infobar OUTPUT
      , @OldTotalPrice = @Price
      IF @Severity != 0
         BREAK
   END
   --  Remove this key so it can be reused or in case it was accidentally
   -- entered too high and therefore removed.

   EXEC @Severity  = dbo.DeleteKeySp
     @TableName  = 'co'
   , @ColumnName = 'co_num'
   , @Key        = @CoNum
   , @Infobar    = @Infobar OUTPUT
    IF @Severity != 0
        break
END
CLOSE co_mstDelCrs
DEALLOCATE co_mstDelCrs

/*
** Delete associated Configuration records
*/
if @Severity = 0
BEGIN
   DELETE cfg_main
   FROM deleted AS dd
   WHERE cfg_main.config_id = dd.config_id
     AND dd.config_id IS NOT NULL
   SET @Severity = @@ERROR
END

/*
** Delete associated order priority records
*/
if @Severity = 0
BEGIN
   DELETE aps_seq
   FROM deleted AS dd
   WHERE aps_seq.rule_type = 3
     AND aps_seq.rule_value = LTRIM(dd.co_num)
   SET @Severity = @@ERROR
END

IF @Severity = 0
BEGIN
    /*
    ** Delete any notes attached to the deleted row(s).
    ** This code was not done in the cursor for performance reasons.
    */
    -- Delete any document references
    DELETE DocumentObjectReference
    FROM deleted dd
    INNER JOIN DocumentObjectReference dor ON
      dor.TableRowPointer = dd.RowPointer
    WHERE dor.TableName = 'co'

    -- Delete any NotesSiteMap record related to the ObjectNotes
    DELETE NotesSiteMap
    FROM deleted dd
       , ObjectNotes obn
       , NotesSiteMap nsm
    WHERE obn.RefRowPointer = dd.RowPointer AND
          obn.SpecificNoteToken = nsm.LocalNoteToken

    DELETE ObjectNotes
    FROM deleted dd
       , ObjectNotes obn
    WHERE obn.RefRowPointer = dd.RowPointer
    SELECT
      @Severity = @@ERROR
    IF @Severity = 0
    BEGIN
        DELETE UserDefinedFields
        FROM deleted dd
        , UserDefinedFields udf
        WHERE udf.RowId = dd.RowPointer
        SELECT
          @Severity = @@ERROR
    END
END

IF @Severity = 0
BEGIN
   --Delete any replicated authorizations if they exist 
   DELETE cci
   FROM cci_trans AS cci
   INNER JOIN deleted AS dd ON
     dd.co_num = cci.ref_num
   WHERE cci.ref_type = 'O' 
     AND cci.orig_site_ref <> @ParmsSite 
END

IF @Severity <> 0
BEGIN
    EXEC dbo.RaiseErrorSp @Infobar, @Severity, 3
 
    EXEC @Severity = dbo.RollbackTransactionSp
       @Severity
 
    IF @Severity != 0
    BEGIN
       ROLLBACK TRANSACTION
       RETURN
    END
END
 
--  Any record deleted must also be deleted for this site in the _All
-- table
DELETE_ALL:
DELETE dbo.co_all
FROM dbo.co_all
INNER JOIN deleted ON deleted.RowPointer = dbo.co_all.RowPointer
WHERE dbo.co_all.site_ref = @Site





GO

EXEC sp_settriggerorder @triggername=N'[dbo].[co_mstDel]', @order=N'First', @stmttype=N'DELETE'
GO

