DELETE FROM BGTaskDefinitions WHERE TaskName like 'ZPV%'

INSERT INTO BGTaskDefinitions( TaskName,TaskTypeCode,TaskExecutable,MaxConcurrent)
VALUES('ZPV_InvoicingBGSp','SP','ZPV_InvoicingBGSp',20)

INSERT INTO BGTaskDefinitions( TaskName,TaskTypeCode,TaskExecutable,MaxConcurrent)
VALUES('ZPV_ArClearingReport','RPT','ZPV_ArClearing',20)



