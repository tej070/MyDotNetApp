
/**********************tblCostingTerm******************************/
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'tblCostingTerm') 
create table tblCostingTerm
(
ADID varchar(25) not null, 
[Name] varchar(250) not null, 
ACID varchar(25) not null, 
CostingMethod varchar(25) not null, 
BasedOn varchar(25) not null, 
[Action] varchar(25) not null , 
includeInStock bit , 
[User] varchar(30) not null, 
Stamp float,
HASTRANSACTION int default 0
CONSTRAINT PK_tblCostingTerm_ADID PRIMARY KEY (ADID),
CONSTRAINT FK_tblCostingTerm_Aclist_ACID FOREIGN KEY (ACID) REFERENCES RMD_ACLIST (ACID),
CONSTRAINT FK_tblCostingTerm_UserProfiles_User FOREIGN KEY([User]) REFERENCES USERPROFILES(UNAME)
);

/**********************tblAdditionalCost******************************/
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'tblAdditionalCost') 
create table tblAdditionalCost
(
Vchrno varchar(25) not null, 
CompanyId varchar(25) not null, 
Guid UNIQUEIDENTIFIER,
Sno int , 
Ref_Billno varchar(250) not null, 
Ref_BillDate datetime , 
SupplierAcid varchar(25) not null, 
ADID varchar(25) not null, 
creditAcid varchar(25) not null, 
Amount numeric(32,2) , 
Vat numeric(32,2) , 
TdsAcid varchar(25) not null, 
TdsAmount numeric(32,2) , 
Remarks varchar(250) , 
DoAccountPosting tinyint , 
costingMethod varchar(25) not null,
VoucherType varchar(2) not null,
CONSTRAINT PK_tblAdditionalCost_guid PRIMARY KEY (guid),
CONSTRAINT FK_tblAdditionalCost_Accmain_Vchrno_VoucherType FOREIGN KEY (Vchrno,VoucherType) REFERENCES ACCMAIN (VCHRNO,VoucherType) , 
CONSTRAINT FK_tblAdditionalCost_Aclist_supplierAcid FOREIGN KEY (supplierAcid) REFERENCES RMD_ACLIST (ACID) , 
CONSTRAINT FK_tblAdditionalCost_tblCostingTerm_ADID FOREIGN KEY (ADID) REFERENCES tblCostingTerm(ADID) , 
CONSTRAINT FK_tblAdditionalCost_Aclist_creditAcid FOREIGN KEY (creditAcid) REFERENCES RMD_ACLIST (ACID) , 
CONSTRAINT FK_tblAdditionalCost_Aclist_tdsAcid FOREIGN KEY (tdsAcid) REFERENCES RMD_ACLIST (ACID) , 
);

/**********************tblAdditionalCost_ProductWise******************************/
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'tblAdditionalCost_ProductWise') 
WITH CTE AS (
SELECT ROW_NUMBER() OVER(PARTITION BY MCODE , BATCHCODE ORDER BY STAMP) SN , MCODE , BATCHCODE FROM BATCHPRICE_MASTER) 

DELETE fROM CTE WHERE SN>1

alter table batchprice_master add constraint PK_BATCHPRICE_MASTER_MCODE_BATCH PRIMARY KEY (MCODE , BATCHCODE)
create table tblAdditionalCost_ProductWise
(
Guid UNIQUEIDENTIFIER , 
Mcode varchar(25) not null,
Batch varchar(100) not null , 
BatchId varchar(50) not null,
Amount numeric(32,12), 
CONSTRAINT FK_tblAdditionalCost_ProductWise_MenuItem_Mcode FOREIGN KEY(Mcode) REFERENCES MenuItem(Mcode),
CONSTRAINT FK_tblAdditionalCost_ProductWise_batchPriceMaster_Mcode_Batch FOREIGN KEY(Batch,Mcode) REFERENCES batchprice_master(BatchCode,Mcode)
);


IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = '_Log_tblAdditionalCost') 
CREATE TABLE [dbo].[_Log_tblAdditionalCost](
	[VCHRNO] [varchar](25) NOT NULL,
	[CompanyId] [varchar](25) NOT NULL,
	[Guid] [varchar](max) NULL,
	[Sno] [int] NULL,
	[Ref_Billno] [varchar](250) NOT NULL,
	[Ref_BillDate] [datetime] NULL,
	[SupplierAcid] [varchar](25) NOT NULL,
	[ADID] [varchar](25) NOT NULL,
	[creditAcid] [varchar](25) NOT NULL,
	[Amount] [numeric](32, 2) NULL,
	[Vat] [numeric](32, 2) NULL,
	[TdsAcid] [varchar](25) NULL,
	[TdsAmount] [numeric](32, 2) NULL,
	[Remarks] [varchar](250) NULL,
	[DoAccountPosting] [tinyint] NULL,
	[costingMethod] [varchar](25) NOT NULL,
	[VoucherType] [varchar](2) NOT NULL,
	Stamp float,
) 

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = '_log_tblAdditionalCost_ProductWise') 
CREATE TABLE [dbo].[_log_tblAdditionalCost_ProductWise](
	[Guid] [varchar](max) NULL,
	[Mcode] [varchar](25) NOT NULL,
	[Batch] [varchar](100) NOT NULL,
	[BatchId] [varchar](50) NOT NULL,
	[Amount] [numeric](32, 12) NULL,
	Stamp float,
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]


 IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS  WHERE TABLE_NAME = 'SETTING'  AND COLUMN_NAME = 'enableNewAccountApproach')
BEGIN
    ALTER TABLE SETTING
    ADD enableNewAccountApproach INT DEFAULT 0;
END

IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'RMD_TRNMAIN_ADDITIONALINFO' AND COLUMN_NAME = 'dataorigin')
ALTER TABLE RMD_TRNMAIN_ADDITIONALINFO Add  dataorigin varchar (25);
IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'DIVISION' AND COLUMN_NAME = 'COMID')
ALTER TABLE DIVISION ALTER COLUMN COMID varchar (200);
--2024/08/22 
IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'enablesmsfeatures' AND TABLE_NAME = 'Setting')
Alter table Setting Add enablesmsfeatures tinyint DEFAULT 0 WITH VALUES
IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'isDefault' AND TABLE_NAME = 'BANKNAMELIST')
Alter table BANKNAMELIST Add isDefault tinyint;
IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'ACID' AND TABLE_NAME = 'BANKNAMELIST')
Alter table BANKNAMELIST Add ACID varchar(25);
IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'BankAccountNumber' AND TABLE_NAME = 'BANKNAMELIST')
Alter table BANKNAMELIST Add BankAccountNumber  varchar(20);
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'tblDirectAccountValidationLog') 
CREATE TABLE [dbo].[tblDirectAccountValidationLog](
	id int IDENTITY(1,1) NOT NULL,
	user_id nvarchar(50) NOT NULL,
	client_id varchar(50) NOT NULL,
	code nvarchar(10) NOT NULL,
	message nvarchar(100) NOT NULL,
	account_number varchar(40) NULL,
	swift_code varchar(20) NULL,
	requested_name varchar(50) NULL,
	unique_id varchar(50) NULL,
	created_on datetime NOT NULL  Default GetDate())
IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'enableOnlinePayment' AND TABLE_NAME = 'Setting')
ALTER TABLE SETTING ADD enableOnlinePayment tinyint default 0 with values

IF  EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'enableOnlinePayment' AND TABLE_NAME = 'Setting')
BEGIN
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Online_Bulk_Payment' ) AND  NOT EXISTS (SELECT 1 FROM SETTING WHERE enableOnlinePayment = 1)
CREATE TABLE Online_Bulk_Payment(
ACNAME varchar(250),
 ACID varchar(250),
 BANKNAME varchar(250),
 BANKID varchar(250),
DestinationBankCode varchar(250),
 DUEAMOUNT decimal ,
 PAYMENTDATE_AD varchar(250),
 PAYMENTDATE_BS varchar(250),
 NARRATION varchar(250),
 VCHRNO varchar(250),
TOTAMNT  decimal,
 NETAMNT  decimal,
 TRNMODE varchar(250),
 TRNUSER varchar(250),
 PHISCALID varchar(50),
 COMPANYID varchar(250),
 DIVISION varchar(250),
 VOUCHERTTYPE varchar(250),
 MODE varchar(250),
 TRNDATE datetime,
 TRN_DATE datetime,
 BS_DATE varchar(250),
 BSDATE varchar(250),
 guid varchar(max),
 BANKACNO varchar(250),
 ChequeDate varchar(250),
 ChequeDateBS varchar(250),
 BATCHNO varchar(250),
 STAMP FLOAT,
 CreateTransactionStatus varchar(50) Null,
 VerifyTransactionStatus varchar(50) Null,
 ISVALIDATEDDESTINATIONACCOUNT BIT Null,
 PaymentStatus bit Null,
 TransactionCode varchar(50) null,
 SourceBankName  varchar(250),
 SourceBankAccount varchar(250),
 SourceBankId varchar(250),
 SourceBankCode varchar(250),
 PRIMARY KEY (VCHRNO)
)
END
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS  WHERE TABLE_NAME = 'SETTING'  AND COLUMN_NAME = 'ENABLEOFFLINESALE')
BEGIN
    ALTER TABLE SETTING
    ADD ENABLEOFFLINESALE INT DEFAULT 0;
END

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Online_Payment_App_Users')
BEGIN
    
    CREATE TABLE Online_Payment_App_Users (
        [user_id] NVARCHAR(50) NOT NULL,
        CompanyId NVARCHAR(50) NOT NULL,
        ClientId NVARCHAR(50) NOT NULL,
        UserName NVARCHAR(100),
        [Password] NVARCHAR(100),
        CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),
        CONSTRAINT PK_Online_Payment_App_Users PRIMARY KEY (user_id, CompanyId, ClientId)
    );

  
    --INSERT INTO Online_Payment_App_Users (user_id, CompanyId, ClientId, UserName, [Password])
    --VALUES ('', '', 'CP0006004', 'makerchecker', 'Hello@123');
END

IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'ACCMAIN' AND COLUMN_NAME = 'isOnlineTransaction')
ALTER TABLE ACCMAIN ADD   isOnlineTransaction int

IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'ACCTRAN' AND COLUMN_NAME = 'BANKACNO')
ALTER TABLE ACCTRAN ADD   BANKACNO VARCHAR(250)

IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'ACCMAIN' AND COLUMN_NAME = 'SourceBankAC')
ALTER TABLE ACCMAIN ADD   SourceBankAC VARCHAR(250)

IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'AccTran_PostDir' AND COLUMN_NAME = 'BANKACNO')
ALTER TABLE AccTran_PostDir ADD   BANKACNO VARCHAR(250)

IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'rmd_journal' AND COLUMN_NAME = 'BANKACNO')
ALTER TABLE rmd_journal ADD   BANKACNO VARCHAR(250)

IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'USERPROFILES' AND COLUMN_NAME = 'AllowBackDateEntry')
 ALTER TABLE  USERPROFILES  ADD AllowBackDateEntry INT DEFAULT 0 WITH VALUES
IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'ReportColumnFormat' AND COLUMN_NAME = 'PROJECT')
 ALTER TABLE ReportColumnFormat ADD PROJECT VARCHAR(200);
 IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'DefaultReportFormat' AND COLUMN_NAME = 'PROJECT')
 ALTER TABLE DefaultReportFormat ADD PROJECT VARCHAR(200);
 IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'REPORTCONTEXTMENU' AND COLUMN_NAME = 'PROJECT')
 ALTER TABLE REPORTCONTEXTMENU ADD PROJECT VARCHAR(200);
 --END
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'log_RenumRMDJournal') 
CREATE TABLE [dbo].[log_RenumRMDJournal](
	[VCHRNO] [varchar](25) NULL,
	[ACID] [varchar](25) NULL,
	[FILONO] [varchar](50) NULL,
	[DRAMNT] [numeric](18, 0) NULL,
	[CRAMNT] [numeric](18, 0) NULL,
	[DIVISION] [char](3) NULL,
	[SNO] [int] NULL,
	[NARRATION] [varchar](1000) NULL,
	[VoucherType] [varchar](2) NULL,
	[ChequeNo] [varchar](20) NULL,
	[ChequeDate] [varchar](20) NULL,
	[FCurrency] [varchar](20) NULL,
	[FCurAmount] [numeric](18, 0) NULL,
	[CostCenter] [varchar](100) NULL,
	[MultiJournalSno] [numeric](18, 0) NULL,
	[OppAcid] [varchar](20) NULL,
	[OppRemarks] [varchar](200) NULL,
	[OppChequeNo] [varchar](50) NULL,
	[OppChequeDate] [varchar](20) NULL,
	[OppCostCenter] [varchar](50) NULL,
	[PhiscalID] [varchar](20) NULL,
	[VTRACKID] [float] NULL,
	[TOACID] [varchar](25) NULL,
	[STAMP] [float] NULL,
	[guid] [varchar](100) NULL,
	[companyid] [varchar](25) NULL,
	[NARATION1] [varchar](1000) NULL,
	[SL_ACID] [varchar](25) NULL,
	[ChequeDateBS] [varchar](20) NULL,
	[OPPNAME] [varchar](100) NULL,
	[ISTAXABLE] [tinyint] NULL,
	[CPTYPE] [tinyint] NULL,
	[DISAMNT] [numeric](18, 0) NULL,
	[SALESMAN] [varchar](500) NULL,
	[BUDGETNAME] [varchar](200) NULL,
	[COSTCENTERGROUP_NAME] [varchar](100) NULL,
	[CCG_ID] [varchar](10) NULL,
	[old_vchrno] [varchar](100) NULL,
	[SUBDIVIDED_BY] [varchar](50) NULL,
	[Bankname] [varchar](100) NULL
) 

IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'log_RenumRMDJournal' AND COLUMN_NAME = 'Bankname')
 ALTER TABLE log_RenumRMDJournal ADD Bankname VARCHAR(100);
IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'DisableBackDateEntry' AND TABLE_NAME = 'Setting')
Alter table Setting Add DisableBackDateEntry tinyint DEFAULT 0 WITH VALUES
IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'salesman' AND TABLE_NAME = 'purtran_lpost')
alter table purtran_lpost add salesman  varchar(50)
IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'BANKNAME' AND TABLE_NAME = 'purtran_lpost')
alter table purtran_lpost add BANKNAME varchar(100)
IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'BANKCODE' AND TABLE_NAME = 'purtran_lpost')
alter table purtran_lpost add BANKCODE varchar(100)
IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'BANKID' AND TABLE_NAME = 'purtran_lpost')
alter table purtran_lpost add BANKID varchar(30)
IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'ISTAXABLE' AND TABLE_NAME = 'purtran_lpost')
alter table purtran_lpost add ISTAXABLE tinyint default 0 with values
IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'CPTYPE' AND TABLE_NAME = 'purtran_lpost')
alter table purtran_lpost add CPTYPE tinyint default 0 with values
IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'ChequeDateBS' AND TABLE_NAME = 'purtran_lpost')
alter table purtran_lpost add ChequeDateBS varchar(20)

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'RMD_BILLTRACK_LPOST') 
CREATE TABLE [dbo].[RMD_BILLTRACK_LPOST](
	[TRNDATE] [datetime] NULL,
	[VCHRNO] [varchar](25) NULL,
	[CHALANNO] [varchar](25) NULL,
	[AMOUNT] [numeric](18, 2) NULL,
	[REFBILL] [varchar](25) NULL,
	[DIVISION] [char](3) NULL,
	[ACID] [varchar](25) NULL,
	[PhiscalID] [varchar](20) NULL,
	[REFDIVISION] [varchar](3) NULL,
	[ID] [varchar](100) NULL,
	[TBillNo] [varchar](30) NULL,
	[VOUCHERTYPE] [varchar](2) NOT NULL,
	[STAMP] [float] NULL,
	[BillFrom] [varchar](250) NULL
) ON [PRIMARY]




IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'LOG_RMD_BILLTRACK') 
CREATE TABLE [dbo].[LOG_RMD_BILLTRACK](
	[TRNDATE] [datetime] NULL,
	[VCHRNO] [varchar](25) NULL,
	[CHALANNO] [varchar](25) NULL,
	[AMOUNT] [numeric](18, 2) NULL,
	[REFBILL] [varchar](25) NULL,
	[DIVISION] [char](3) NULL,
	[ACID] [varchar](25) NULL,
	[PhiscalID] [varchar](20) NULL,
	[REFDIVISION] [varchar](3) NULL,
	[ID] [varchar](100) NULL,
	[TBillNo] [varchar](30) NULL,
	[VOUCHERTYPE] [varchar](2) NOT NULL,
	[STAMP] [float] NULL,
	[BillFrom] [varchar](250) NULL
) ON [PRIMARY]





IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'IsSplitedDatabase' AND TABLE_NAME = 'Setting')
Alter table Setting Add IsSplitedDatabase tinyint DEFAULT 0 WITH VALUES

IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'PhiscalId' AND TABLE_NAME = 'Setting')
Alter table Setting Add PhiscalId varchar(25) NULL;

IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'EnableCarryDownFromSplitTable' AND TABLE_NAME = 'Setting')
Alter table Setting Add EnableCarryDownFromSplitTable bit not null default 0
IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'BillFrom' AND TABLE_NAME = 'RMD_BILLTRACK')
alter table  RMD_BILLTRACK add BillFrom varchar(250)

IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'DeletedBy' AND TABLE_NAME = 'RMD_BILLTRACK_DELETED')
alter table  RMD_BILLTRACK_DELETED add DeletedBy varchar(250)

IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'BillFrom' AND TABLE_NAME = 'RMD_BILLTRACK_DELETED')
alter table  RMD_BILLTRACK_DELETED add BillFrom varchar(250)

ALTER TABLE RMD_BILLTRACK DROP CONSTRAINT IF EXISTS FK_RMD_BILLTRACK_ACCMAIN

IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'COSTCENTER' AND TABLE_NAME = 'LOG_PARTYOPENING_DETAIL')
alter table LOG_PARTYOPENING_DETAIL add COSTCENTER varchar(50)

IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'COSTCENTER' AND TABLE_NAME = 'PARTYOPENING_DETAIL')
alter table PARTYOPENING_DETAIL add COSTCENTER varchar(50)

IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'BATCHID' AND TABLE_NAME = 'ADDITIONALCOST_INDIVIDUAL')
alter table ADDITIONALCOST_INDIVIDUAL add BATCHID varchar(100)

IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'Bankname' AND TABLE_NAME = 'RMD_JOURNAL_DELETED')
alter table RMD_JOURNAL_DELETED add Bankname varchar(100)
IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'Bankname' AND TABLE_NAME = 'LOGRMDJOURNAL')
alter table LOGRMDJOURNAL add Bankname varchar(100)

IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'Bankname' AND TABLE_NAME = 'rmd_journal')
alter table rmd_journal add Bankname varchar(100)

IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'Bankname' AND TABLE_NAME = 'RMD_JOURNAL_FOR_DNCN')
alter table RMD_JOURNAL_FOR_DNCN add Bankname varchar(100)

IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'enablebatchidwise_ad' AND TABLE_NAME = 'SETTING')
alter table SETTING ADD enablebatchidwise_ad TINYINT DEFAULT 0 WITH VALUES

IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'DoReverseJournalEntry' AND TABLE_NAME = 'SETTING')
alter table SETTING ADD DoReverseJournalEntry TINYINT DEFAULT 0 WITH VALUES

DECLARE @TableName NVARCHAR(255) = 'RMD_SUBLEDGER_ACLIST';
DECLARE @ForeignKeyName NVARCHAR(255);

SELECT @ForeignKeyName = CONSTRAINT_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE TABLE_NAME = @TableName AND COLUMN_NAME = 'MainLedgerId';

IF @ForeignKeyName IS NOT NULL
BEGIN
    DECLARE @sql NVARCHAR(MAX);
    SET @sql = 'ALTER TABLE ' + QUOTENAME(@TableName) + ' DROP CONSTRAINT ' + QUOTENAME(@ForeignKeyName);
    EXEC sp_executesql @sql;
    PRINT 'Foreign key constraint ' + @ForeignKeyName + ' dropped successfully for table ' + @TableName + '.';
END
ELSE
BEGIN
    PRINT 'Foreign key constraint does not exist for ' + @TableName;
END;

IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'RMD_SUBLEDGER_ACLIST' AND COLUMN_NAME = 'MainLedgerId')
alter table RMD_SUBLEDGER_ACLIST  ADD MainLedgerId varchar(25)

IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'RMD_SUBLEDGER_ACLIST' AND COLUMN_NAME = 'hasMainGroup')
alter table RMD_SUBLEDGER_ACLIST ADD hasMainGroup tinyint

IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'PARTYOPENING_DETAIL' AND COLUMN_NAME = 'REFDATE')
alter table PARTYOPENING_DETAIL alter column REFDATE datetime

IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'PARTYOPENING_DETAIL' AND COLUMN_NAME = 'DUEDATE')
alter table PARTYOPENING_DETAIL alter column DUEDATE datetime

IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'AOPMAIN' AND COLUMN_NAME = 'OrderMode')
ALTER TABLE AOPMAIN  ADD OrderMode  VARCHAR(25)

IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'PURMAIN' AND COLUMN_NAME = 'OrderMode')
ALTER TABLE PURMAIN  ADD OrderMode  VARCHAR(25)

IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'GRNMAIN' AND COLUMN_NAME = 'OrderMode')
ALTER TABLE GRNMAIN  ADD OrderMode  VARCHAR(25)

IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'OPMAIN' AND COLUMN_NAME = 'OrderMode')
ALTER TABLE OPMAIN  ADD OrderMode  VARCHAR(25)

IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'TRNMAIN' AND COLUMN_NAME = 'OrderMode')
ALTER TABLE TRNMAIN  ADD OrderMode  VARCHAR(25)

IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'LOGMAIN' AND COLUMN_NAME = 'OrderMode')
ALTER TABLE LOGMAIN  ADD OrderMode  VARCHAR(25)

IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'ABBMAIN' AND COLUMN_NAME = 'OrderMode')
ALTER TABLE ABBMAIN  ADD OrderMode  VARCHAR(25)

IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'ACCMAIN' AND COLUMN_NAME = 'OrderMode')
ALTER TABLE ACCMAIN  ADD OrderMode  VARCHAR(25)

IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'AOPMAIN' AND COLUMN_NAME = 'SALESMANID')
ALTER TABLE AOPMAIN  ADD SALESMANID  VARCHAR(25)

IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'INVMAIN' AND COLUMN_NAME = 'OrderMode')
ALTER TABLE INVMAIN  ADD OrderMode  VARCHAR(25)

IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'Enablecapitalpurchase' AND TABLE_NAME = 'SETTING')
alter table SETTING ADD Enablecapitalpurchase TINYINT DEFAULT 0 WITH VALUES 

IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'RMD_JOURNAL_FOR_DNCN' AND COLUMN_NAME= 'SUBDIVIDED_BY')
ALTER TABLE RMD_JOURNAL_FOR_DNCN  ADD SUBDIVIDED_BY VARCHAR(200)


IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'RMD_JOURNAL' AND COLUMN_NAME = 'SUBDIVIDED_BY')
ALTER TABLE RMD_JOURNAL  ADD SUBDIVIDED_BY  VARCHAR(50)


IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'LOGRMDJOURNAL' AND COLUMN_NAME = 'SUBDIVIDED_BY')
ALTER TABLE LOGRMDJOURNAL  ADD SUBDIVIDED_BY  VARCHAR(50)

IF NOT EXISTS(SELECT * FROM RMD_TAXCHARGES_CONFIG WHERE PARTICULARS = 'DEPRECIATIONAC')
INSERT INTO RMD_TAXCHARGES_CONFIG (PARTICULARS,Caption,TRNAC,DEFAULT_TRNAC)Values('DEPRECIATIONAC','DEPRECIATIONAC','AG453', 'AG453')


IF NOT EXISTS(SELECT * FROM RMD_TAXCHARGES_CONFIG WHERE PARTICULARS = 'DEPRECIATIONAC')
INSERT INTO RMD_TAXCHARGES_CONFIG (PARTICULARS,Caption)Values('DEPRECIATIONAC','DEPRECIATIONAC')

IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'nestlePaySlip' AND TABLE_NAME = 'SETTING')
alter table setting add nestlePaySlip tinyint default 0 with values 

IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'showSORefBill' AND TABLE_NAME = 'SETTING') --Added on 2023-07-27
alter table SETTING ADD showSORefBill TINYINT DEFAULT 1 WITH VALUES

if exists (select 1 from RMD_JOURNAL a with(nolock) join costcenter b with(nolock) on a.CostCenter = b.COSTCENTERNAME where b.CostCenterName not in (select cast(ccid as varchar(50)) from CostCenter with(nolock)))
update b set CostCenter = a.CCID from COSTCENTER a join RMD_JOURNAL b on a.COSTCENTERNAME = b.CostCenter

IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'PANNO' AND TABLE_NAME = 'RMD_SUBLEDGER_ACLIST') --Added on 2023-07-27
alter table RMD_SUBLEDGER_ACLIST ADD PANNO varchar(50)

IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'enableMaster_AddEdit' AND TABLE_NAME = 'SETTING') --Added on 2023-07-27
alter table SETTING ADD enableMaster_AddEdit TINYINT DEFAULT 1 WITH VALUES

IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'RMD_JOURNAL' AND COLUMN_NAME = 'BUDGETNAME') 
alter table RMD_JOURNAL add BUDGETNAME varchar(200)

IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'RMD_JOURNAL' AND COLUMN_NAME = 'COSTCENTERGROUP_NAME') 
alter table RMD_JOURNAL add COSTCENTERGROUP_NAME varchar(100)

IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'RMD_JOURNAL' AND COLUMN_NAME = 'CCG_ID') 
alter table RMD_JOURNAL add CCG_ID varchar(10)

IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'rmd_Aclist' AND COLUMN_NAME = 'TDS_TYPE') 
alter table rmd_Aclist add TDS_TYPE varchar(100)

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'BUDGETMAIN') --Added on 2023-07-30
CREATE TABLE [dbo].[BUDGETMAIN](
	[VCHRNO] [varchar](25) NOT NULL PRIMARY KEY,
	[TRNDATE] [smalldatetime] NOT NULL,
	[BSDATE] [varchar](50) NULL,
	[BUDGET_NAME] [varchar](500) NOT NULL,
	[BUDGET_TYPE] [varchar](25) NULL,
	[BUDGET_INTERVAL] [varchar](25) NOT NULL,
	[INTERVAL_ON_AD_OR_BS] [varchar](25) NULL,
	[SUBDIVIDED_BY] [varchar](25) NULL,
	[ACTION] [varchar](25) NOT NULL,
	[ACTION_TYPE] [varchar](25) NULL,
	[DIVISION] [varchar](3) NOT NULL,
	[PHISCALID] [varchar](20) NOT NULL,
	[COMPANYID] [varchar](25) NULL,
	[STAMP] [float] NULL,
	[STATUS] [tinyint] null default 1,
	[CREATED_BY] [varchar](50) NULL,
	[EDITED_BY] [varchar](50) NULL,
	[DELETED_BY] [varchar](50) NULL,
	[FROM_DATE] [smalldatetime] NULL,
	[FROM_BSDATE] [varchar](50) NULL,
	[TO_DATE] [smalldatetime] NULL,
	[TO_BSDATE] [varchar](50) NULL,
	[TOTAL_BUDGET] [numeric](32, 2) NULL,
	[CREATED_ON] [smalldatetime] NULL,
	[UPDATED_ON] [smalldatetime] NULL,
	PREFILL_DATA varchar(500)
)

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'BUDGET_DETAIL') --Added on 2023-07-30
CREATE TABLE [BUDGET_DETAIL] (
	[VCHRNO] [varchar](25) NOT NULL,
	[FROMDATE_AD] [smalldatetime] NOT NULL,
	[TODATE_AD] [smalldatetime] NOT NULL,
	[FROMDATE_BS] [varchar](50) NOT NULL,
	[TODATE_BS] [varchar](50) NOT NULL,
	[BUDGET] [numeric](32, 2) NULL,
	[ACID] [varchar](25) NOT NULL,
	[QUARTER_TYPE] [tinyint] NULL,
	[QUARTER_NAME] [varchar](50) NULL,
	[MONTH_NAME] [varchar](50) NULL,
	[CCID] [int] NULL,
	[COSTCENTER_CATEGORYID] [varchar](50) NULL,
	[COSTCENTER_CATEGORYNAME] [varchar](200) NULL,
	[COSTCENTER_NAME] [varchar](200) NULL,
	[ACCOUNTGROUP_ID] [varchar](50) NULL,
	[ACCOUNTGROUP_NAME] [varchar](200) NULL,
	[ACNAME] [varchar](200) NULL,
	[DIVISION] [varchar](3) NOT NULL,
	[PHISCALID] [varchar](20) NOT NULL,
	[COMPANYID] [varchar](25) NULL,
	[STAMP] [float] NULL,
	[DEPARTMENT_ID] [int] NULL
	FOREIGN KEY ([VCHRNO]) REFERENCES BUDGETMAIN ([VCHRNO]),
	FOREIGN KEY ([ACID]) REFERENCES RMD_ACLIST ([ACID])
	);

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'LOG_BUDGETMAIN') --Added on 2023-07-30
CREATE TABLE [dbo].LOG_BUDGETMAIN(
	[VCHRNO] [varchar](25) NOT NULL,
	[TRNDATE] [smalldatetime] NOT NULL,
	[BSDATE] [varchar](50) NULL,
	[BUDGET_NAME] [varchar](500) NOT NULL,
	[BUDGET_TYPE] [varchar](25) NULL,
	[BUDGET_INTERVAL] [varchar](25) NOT NULL,
	[INTERVAL_ON_AD_OR_BS] [varchar](25) NULL,
	[SUBDIVIDED_BY] [varchar](25) NULL,
	[ACTION] [varchar](25) NOT NULL,
	[ACTION_TYPE] [varchar](25) NULL,
	[DIVISION] [varchar](3) NOT NULL,
	[PHISCALID] [varchar](20) NOT NULL,
	[COMPANYID] [varchar](25) NULL,
	[STAMP] [float] NULL,
	[STATUS] [tinyint] null default 1,
	[CREATED_BY] [varchar](50) NULL,
	[EDITED_BY] [varchar](50) NULL,
	[DELETED_BY] [varchar](50) NULL,
	[FROM_DATE] [smalldatetime] NULL,
	[FROM_BSDATE] [varchar](50) NULL,
	[TO_DATE] [smalldatetime] NULL,
	[TO_BSDATE] [varchar](50) NULL,
	[TOTAL_BUDGET] [numeric](32, 2) NULL,
	[CREATED_ON] [smalldatetime] NULL,
	[UPDATED_ON] [smalldatetime] NULL,
	PREFILL_DATA varchar(500)
)

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'LOG_BUDGET_DETAIL') --Added on 2023-07-30
CREATE TABLE LOG_BUDGET_DETAIL (
	[VCHRNO] [varchar](25) NOT NULL,
	[FROMDATE_AD] [smalldatetime] NOT NULL,
	[TODATE_AD] [smalldatetime] NOT NULL,
	[FROMDATE_BS] [varchar](50) NOT NULL,
	[TODATE_BS] [varchar](50) NOT NULL,
	[BUDGET] [numeric](32, 2) NULL,
	[ACID] [varchar](25) NOT NULL,
	[QUARTER_TYPE] [tinyint] NULL,
	[QUARTER_NAME] [varchar](50) NULL,
	[MONTH_NAME] [varchar](50) NULL,
	[CCID] [int] NULL,
	[COSTCENTER_CATEGORYID] [varchar](50) NULL,
	[COSTCENTER_CATEGORYNAME] [varchar](200) NULL,
	[COSTCENTER_NAME] [varchar](200) NULL,
	[ACCOUNTGROUP_ID] [varchar](50) NULL,
	[ACCOUNTGROUP_NAME] [varchar](200) NULL,
	[ACNAME] [varchar](200) NULL,
	[DIVISION] [varchar](3) NOT NULL,
	[PHISCALID] [varchar](20) NOT NULL,
	[COMPANYID] [varchar](25) NULL,
	[STAMP] [float] NULL,
	[DEPARTMENT_ID] [int] NULL
	);

IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'ENABLE_BUDGETCONTROL' AND TABLE_NAME = 'SETTING') --Added on 2023-07-27
alter table SETTING ADD ENABLE_BUDGETCONTROL TINYINT DEFAULT 0 WITH VALUES


IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'PARTYOPENING_DETAIL' AND COLUMN_NAME = 'DUEDAYS') --Added on 2023-07-25
ALTER TABLE PARTYOPENING_DETAIL ADD DUEDAYS varchar(20)

IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'IS_DATABASE_SPLIT' AND TABLE_NAME = 'SETTING') --Added on 2023-07-21
alter table SETTING ADD IS_DATABASE_SPLIT TINYINT DEFAULT 0 WITH VALUES

IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'DIVISIONWISE_OPENING' AND TABLE_NAME = 'SETTING') --Added on 2023-07-21
alter table SETTING ADD DIVISIONWISE_OPENING TINYINT DEFAULT 0 WITH VALUES

IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'EnableCompulsoryCostCategory' AND TABLE_NAME = 'SETTING') --Added on 2023-07-21
alter table SETTING ADD EnableCompulsoryCostCategory TINYINT DEFAULT 0 WITH VALUES


IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'SHOW_CASHCOLLECTION_MENU' AND TABLE_NAME = 'SETTING') --Added on 2023-07-12
alter table SETTING ADD SHOW_CASHCOLLECTION_MENU TINYINT DEFAULT 0 WITH VALUES

IF not EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'CASHCOLLECTION') --Added on 2023-07-11
CREATE TABLE CASHCOLLECTION (
CC_VCHRNO varchar(25),
RV_VCHRNO varchar(25),
ENTRYDATE smalldatetime,
ENTRY_BSDATE varchar(50),
DATE1 smalldatetime,
BSDATE1 varchar(50),
DATE2 smalldatetime,
BSDATE2 varchar(50),
CUSTOMER_ACID varchar(50),
CUSTOMER_ACNAME varchar(200),
BILL_NO varchar(25),
BILL_DATE smalldatetime,
BILL_BSDATE varchar(50),
DUE_DATE smalldatetime,
BILL_AMOUNT numeric(20,12),
DUE_AMOUNT numeric(20,12),
BALANCE numeric(20,12),
CASH_COLLECTION numeric(20,12),
TOTAL_CASHCOLLECTION numeric(20,12),
RECEIPT_NO varchar(100),
CASHBANK_ACID varchar(100),
CASHBANK_ACNAME varchar(100),
CUS_ACID varchar(50),
CUS_ACNAME varchar(200),
RECEIPT_MODE varchar(50),
DAYS_BASIS varchar(50),
SALESMAN_ID varchar(100),
SALESMAN_NAME varchar(100),
REMARKS varchar(100),
DIVISION varchar(3),
PHISCALID varchar(20),
COMPANYID varchar(25),
STAMP float,
)

IF not EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'costcentergroup') --Added on 2023-07-10
create  table costcentergroup(
ccgid int not null, 
costcentergroupname varchar(100) not null,
division varchar(100) not null,
type varchar(30),
stamp datetime,
companyid varchar(30)
primary key (ccgid),
)
IF not EXISTS(SELECT * FROM costcentergroup WHERE costcentergroupname = 'Default')
insert into costcentergroup (costcentergroupname,division,type,stamp,ccgid) values('Default','','A',CONVERT(float,getdate()),0)

IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'costcenter' AND COLUMN_NAME = 'ccgid') --Added on 2023-07-10
alter table costcenter add  ccgid int foreign key (ccgid) references costcentergroup(ccgid)

IF not EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'LOG_PARTYOPENING_DETAIL') --Added on 2023-07-07 after Bijudai's merge
CREATE TABLE [dbo].[LOG_PARTYOPENING_DETAIL](
	[VCHRNO] [varchar](25) NULL,
	[DIVISION] [char](3) NULL,
	[REFVNO] [varchar](25) NULL,
	[ACID] [varchar](25) NULL,
	[REFDATE] [varchar](20) NULL,
	[AMOUNT] [numeric](23, 8) NULL,
	[CLRAMOUNT] [numeric](23, 8) NULL,
	[DUEDATE] [varchar](20) NULL,
	[REFSNO] [int] NULL,
	[PHISCALID] [varchar](20) NULL,
	[STAMP] [datetime] NULL,
	[DUEAMT] [decimal](18, 6) NULL,
	[VOUCHERTYPE] [varchar](2) NULL,
	[COMPANYID] [varchar](25) NULL,
	[REF_BSDATE] [varchar](20) NULL,
	[DUE_BSDATE] [varchar](20) NULL
)

IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'PARTYOPENING_DETAIL' AND COLUMN_NAME = 'REF_BSDATE') --Added on 2023-07-07 after Bijudai's merge
ALTER TABLE PARTYOPENING_DETAIL ADD REF_BSDATE varchar(20)

IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'PARTYOPENING_DETAIL' AND COLUMN_NAME = 'DUE_BSDATE') --Added on 2023-07-07 after Bijudai's merge
ALTER TABLE PARTYOPENING_DETAIL ADD DUE_BSDATE varchar(20)

IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'ENABLECOMPULSORY_PAYTO' AND TABLE_NAME = 'SETTING') --Added on 2023-07-07 after Bijudai's merge
alter table SETTING ADD ENABLECOMPULSORY_PAYTO TINYINT DEFAULT 0 WITH VALUES

IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'StockAgeingLimit' AND TABLE_NAME = 'userprofiles') --Added on 2023-07-07 after Bijudai's merge
alter table userprofiles ADD StockAgeingLimit tinyint

IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'TDS_TYPE') --Added on 2023-07-07 after Bijudai's merge
CREATE TABLE TDS_TYPE(
TDS_TYPE varchar(100)
)

IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'Is_Account_Independent' AND TABLE_NAME = 'SETTING') --Added on 2023-07-07 after Bijudai's merge
alter table SETTING ADD Is_Account_Independent TINYINT DEFAULT 0 WITH VALUES


IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'TakeDefaultDate' AND TABLE_NAME = 'SETTING')
alter table SETTING ADD TakeDefaultDate TINYINT DEFAULT 0 WITH VALUES

IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'ENABLELATEPOSTINPURCHASE' AND TABLE_NAME = 'SETTING')
alter table SETTING ADD ENABLELATEPOSTINPURCHASE TINYINT DEFAULT 0 WITH VALUES

IF not EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'SETTING' AND COLUMN_NAME = 'SHOW_IMPORT_DOC_ITEM')
ALTER TABLE SETTING ADD SHOW_IMPORT_DOC_ITEM TINYINT DEFAULT 0 WITH VALUES

IF not EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'LOG_PURTRAN_ROWWISE')
CREATE TABLE [dbo].[LOG_PURTRAN_ROWWISE](
	[VCHRNO] [varchar](25) NOT NULL,
	[CHALANNO] [varchar](50) NULL,
	[DIVISION] [char](3) NULL,
	[A_ACID] [varchar](25) NULL,
	[DRAMNT] [numeric](20, 12) NULL,
	[CRAMNT] [numeric](20, 12) NULL,
	[B_ACID] [varchar](25) NULL,
	[NARATION] [nvarchar](500) NULL,
	[TOACID] [varchar](15) NULL,
	[NARATION1] [varchar](250) NULL,
	[VoucherType] [varchar](2) NOT NULL,
	[ChequeNo] [varchar](20) NULL,
	[ChequeDate] [varchar](20) NULL,
	[FCurrency] [varchar](20) NULL,
	[FCurAmount] [numeric](18, 2) NULL,
	[CostCenter] [varchar](100) NULL,
	[MultiJournalSno] [numeric](18, 0) NULL,
	[PhiscalID] [varchar](20) NULL,
	[BANKDATE] [varchar](25) NULL,
	[SNO] [int] NULL,
	[STAMP] [float] NULL,
	[COMPANYID] [varchar](25) NULL,
	[guid] [varchar](100) NULL,
	[SL_ACID] [varchar](25) NULL,
	[ISTAXABLE] [tinyint] NULL,
	[CPTYPE] [tinyint] NULL,
	[ChequeDateBS] [varchar](20) NULL,
	[BANKNAME] [varchar](100) NULL,
	[BANKCODE] [varchar](50) NULL,
	[MCODE] [varchar](50) NULL,
	[BATCH] [varchar](50) NULL,
	[BATCHID] [varchar](50) NULL
) 

IF not EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'PURTRAN_ROWWISE')
CREATE TABLE [dbo].[PURTRAN_ROWWISE](
	[VCHRNO] [varchar](25) NOT NULL,
	[CHALANNO] [varchar](50) NULL,
	[DIVISION] [char](3) NULL,
	[A_ACID] [varchar](25) NULL,
	[DRAMNT] [numeric](20, 12) NULL,
	[CRAMNT] [numeric](20, 12) NULL,
	[B_ACID] [varchar](25) NULL,
	[NARATION] [nvarchar](500) NULL,
	[TOACID] [varchar](15) NULL,
	[NARATION1] [varchar](250) NULL,
	[VoucherType] [varchar](2) NOT NULL,
	[ChequeNo] [varchar](20) NULL,
	[ChequeDate] [varchar](20) NULL,
	[FCurrency] [varchar](20) NULL,
	[FCurAmount] [numeric](18, 2) NULL,
	[CostCenter] [varchar](100) NULL,
	[MultiJournalSno] [numeric](18, 0) NULL,
	[PhiscalID] [varchar](20) NULL,
	[BANKDATE] [varchar](25) NULL,
	[SNO] [int] NULL,
	[STAMP] [float] NULL,
	[COMPANYID] [varchar](25) NULL,
	[guid] [varchar](100) NULL,
	[SL_ACID] [varchar](25) NULL,
	[ISTAXABLE] [tinyint] NULL,
	[CPTYPE] [tinyint] NULL,
	[ChequeDateBS] [varchar](20) NULL,
	[BANKNAME] [varchar](100) NULL,
	[BANKCODE] [varchar](50) NULL,
	[MCODE] [varchar](50) NULL,
	[BATCH] [varchar](50) NULL,
	[BATCHID] [varchar](50) NULL
) 

IF not EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'LOG_BATCHPRICE_IMPORT')
CREATE TABLE LOG_BATCHPRICE_IMPORT(
	[MCODE] [varchar](25) NULL,
	[BATCH] [varchar](100) NULL,
	[BATCHID] [varchar](100) NULL,
	[PriceId] [varchar](100) NULL,
	[Stock] [numeric](38, 3) NULL,
	[COSTPRICE_IMPORT] [numeric](32, 18) NULL,
	[LANDINGCOST_IMPORT] [numeric](32, 18) NULL,
	[STAMP] [datetime] NULL,
	[VOUCHERNO] [varchar](100) NULL
)

IF not EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'PURPROD_TDS')
CREATE TABLE [dbo].[PURPROD_TDS](
	[VCHRNO] [varchar](25) NOT NULL,
	[ACID] [varchar](25) NULL,
	[FILONO] [varchar](50) NULL,
	[DRAMNT] [numeric](18, 2) NULL,
	[CRAMNT] [numeric](18, 2) NULL,
	[DIVISION] [char](3) NULL,
	[SNO] [int] NULL,
	[NARRATION] [varchar](1000) NULL,
	[VoucherType] [varchar](2) NOT NULL,
	[ChequeNo] [varchar](500) NULL,
	[ChequeDate] [varchar](20) NULL,
	[FCurrency] [varchar](20) NULL,
	[FCurAmount] [numeric](18, 2) NULL,
	[CostCenter] [varchar](100) NULL,
	[MultiJournalSno] [numeric](18, 0) NULL,
	[OppAcid] [varchar](20) NULL,
	[OppRemarks] [varchar](200) NULL,
	[OppChequeNo] [varchar](50) NULL,
	[OppChequeDate] [varchar](20) NULL,
	[OppCostCenter] [varchar](50) NULL,
	[PhiscalID] [varchar](20) NULL,
	[VTRACKID] [float] NULL,
	[TOACID] [varchar](25) NULL,
	[STAMP] [float] NULL,
	[guid] [varchar](100) NULL,
	[companyid] [varchar](25) NULL,
	[NARATION1] [varchar](1000) NULL,
	[SL_ACID] [varchar](25) NULL,
	[SALESMAN] [varchar](50) NULL,
	[ISTAXABLE] [tinyint] NULL,
	[DISAMNT] [numeric](18, 8) NULL,
	[CPTYPE] [tinyint] NULL,
	[OPPNAME] [nvarchar](max) NULL
)

if not exists(select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME  = 'Setting' and COLUMN_NAME ='AUTOSUPCODE')
alter table SETTING  ADD  AUTOSUPCODE tinyint  DEFAULT 0 WITH VALUES
if not exists(select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME  = 'Setting' and COLUMN_NAME ='AUTOACCODE')
alter table SETTING  ADD  AUTOACCODE tinyint  DEFAULT 0 WITH VALUES

IF not EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'SETTING' AND COLUMN_NAME = 'SHOWALL_PI_ON_AD')
alter table SETTING  ADD  SHOWALL_PI_ON_AD tinyint  DEFAULT 0 WITH VALUES

IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'LOG_PURTRAN')
CREATE TABLE [dbo].[LOG_PURTRAN](
	[VCHRNO] [varchar](25) NOT NULL,
	[CHALANNO] [varchar](50) NULL,
	[DIVISION] [char](3) NULL,
	[A_ACID] [varchar](25) NULL,
	[DRAMNT] [numeric](20, 12) NULL,
	[CRAMNT] [numeric](20, 12) NULL,
	[B_ACID] [varchar](25) NULL,
	[NARATION] [nvarchar](500) NULL,
	[TOACID] [varchar](15) NULL,
	[NARATION1] [varchar](250) NULL,
	[VoucherType] [varchar](2) NOT NULL,
	[ChequeNo] [varchar](20) NULL,
	[ChequeDate] [varchar](20) NULL,
	[FCurrency] [varchar](20) NULL,
	[FCurAmount] [numeric](18, 2) NULL,
	[CostCenter] [varchar](100) NULL,
	[MultiJournalSno] [numeric](18, 0) NULL,
	[PhiscalID] [varchar](20) NULL,
	[BANKDATE] [varchar](25) NULL,
	[SNO] [int] NULL,
	[STAMP] [float] NULL,
	[COMPANYID] [varchar](25) NULL,
	[guid] [varchar](100) NULL,
	[SL_ACID] [varchar](25) NULL,
	[ISTAXABLE] [tinyint] NULL,
	[CPTYPE] [tinyint] NULL,
	[ChequeDateBS] [varchar](20) NULL,
	[BANKNAME] [varchar](100) NULL,
	[BANKCODE] [varchar](50) NULL
) 

--IF not EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'PURTRAN' AND COLUMN_NAME = 'MCODE')
--ALTER TABLE PURTRAN ADD MCODE VARCHAR(50)

--IF not EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'PURTRAN' AND COLUMN_NAME = 'BATCH')
--ALTER TABLE PURTRAN ADD BATCH VARCHAR(50)

--IF not EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'PURTRAN' AND COLUMN_NAME = 'BATCHID')
--ALTER TABLE PURTRAN ADD BATCHID VARCHAR(50)

--IF not EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'LOG_PURTRAN' AND COLUMN_NAME = 'MCODE')
--ALTER TABLE LOG_PURTRAN ADD MCODE VARCHAR(50)

--IF not EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'LOG_PURTRAN' AND COLUMN_NAME = 'BATCH')
--ALTER TABLE LOG_PURTRAN ADD BATCH VARCHAR(50)

--IF not EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'LOG_PURTRAN' AND COLUMN_NAME = 'BATCHID')
--ALTER TABLE LOG_PURTRAN ADD BATCHID VARCHAR(5

IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'LOG_PURMAIN_IMPORTDETAIL')
CREATE TABLE [dbo].[LOG_PURMAIN_IMPORTDETAIL](
	[VCHRNO] [varchar](25) NULL,
	[DIVISION] [char](3) NULL,
	[PPNO] [varchar](50) NULL,
	[LCNO] [varchar](50) NULL,
	[SUPPLIER] [varchar](25) NULL,
	[TAXABLEVALUE] [numeric](24, 10) NULL,
	[NTAXABLEVALUE] [numeric](24, 10) NULL,
	[VATVALUE] [numeric](24, 10) NULL,
	[NETVALUE] [numeric](24, 10) NULL,
	[VOUCHERETYPE] [varchar](2) NULL,
	[PHISCALID] [varchar](25) NULL,
	[STAMP] [float] NULL,
	[COMPANYID] [varchar](25) NULL,
	[ITEMNAME] [varchar](100) NULL,
	[QUANTITY] [numeric](18, 8) NULL,
	[MCODE] [varchar](25) NULL,
	[BATCH]  [varchar](25) NULL,
	[BATCHID]  [varchar](25) NULL
)

IF not EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'PURMAIN_IMPORTDETAIL' AND COLUMN_NAME = 'MCODE')
ALTER TABLE PURMAIN_IMPORTDETAIL ADD MCODE varchar(25)

IF not EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'PURMAIN_IMPORTDETAIL' AND COLUMN_NAME = 'BATCH')
ALTER TABLE PURMAIN_IMPORTDETAIL ADD BATCH varchar(25)

IF not EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'PURMAIN_IMPORTDETAIL' AND COLUMN_NAME = 'BATCHID')
ALTER TABLE PURMAIN_IMPORTDETAIL ADD BATCHID varchar(25)

IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'LOG_IMPORTER_PRICECALCULATOR')
CREATE TABLE LOG_IMPORTER_PRICECALCULATOR(
TotalInvoiceData_ImporterRate numeric(18,3),
ExciseDuty_ImporterRate numeric(18,3),
Insurance_ImporterRate numeric(18,3),
AssesableCustomDuty_ImporterRate numeric(18,3),
CustomDuty_ImporterRate numeric(18,3),
AssesableAntaShulka_ImporterRate numeric(18,3),
AntaShulka_ImporterRate numeric(18,3),
ServiceCharge_ImporterRate numeric(18,3),
Others_ImporterRate numeric(18,3),
CostBeforeVAT_ImporterRate numeric(18,3),
VAT_ImporterRate numeric(18,3),
InvoiceQty_ImporterRate numeric(18,3),
LandedCostPerRate_ImporterRate numeric(18,3),
MCODE varchar(25),
ITEMDESC varchar(200),
BATCH varchar(50),
BATCHID varchar(50),
VCHRNO varchar(25),
STAMP float,
)

IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'IMPORTER_PRICECALCULATOR')
CREATE TABLE IMPORTER_PRICECALCULATOR(
TotalInvoiceData_ImporterRate numeric(18,3),
ExciseDuty_ImporterRate numeric(18,3),
Insurance_ImporterRate numeric(18,3),
AssesableCustomDuty_ImporterRate numeric(18,3),
CustomDuty_ImporterRate numeric(18,3),
AssesableAntaShulka_ImporterRate numeric(18,3),
AntaShulka_ImporterRate numeric(18,3),
ServiceCharge_ImporterRate numeric(18,3),
Others_ImporterRate numeric(18,3),
CostBeforeVAT_ImporterRate numeric(18,3),
VAT_ImporterRate numeric(18,3),
InvoiceQty_ImporterRate numeric(18,3),
LandedCostPerRate_ImporterRate numeric(18,3),
MCODE varchar(25),
ITEMDESC varchar(200),
BATCH varchar(50),
BATCHID varchar(50),
VCHRNO varchar(25),
STAMP float,
)

IF not EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'IMPORTER_PRICECALCULATOR' AND COLUMN_NAME = 'Unit_ImporterRate')
ALTER TABLE IMPORTER_PRICECALCULATOR ADD Unit_ImporterRate varchar(100)

IF not EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'IMPORTER_PRICECALCULATOR' AND COLUMN_NAME = 'InvoiceQty_UnitWise')
ALTER TABLE IMPORTER_PRICECALCULATOR ADD InvoiceQty_UnitWise numeric(18,3)

IF not EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'LOG_IMPORTER_PRICECALCULATOR' AND COLUMN_NAME = 'Unit_ImporterRate')
ALTER TABLE LOG_IMPORTER_PRICECALCULATOR ADD Unit_ImporterRate varchar(100)

IF not EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'LOG_IMPORTER_PRICECALCULATOR' AND COLUMN_NAME = 'InvoiceQty_UnitWise')
ALTER TABLE LOG_IMPORTER_PRICECALCULATOR ADD InvoiceQty_UnitWise numeric(18,3)

IF not EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'IMPORTER_PRICECALCULATOR' AND COLUMN_NAME = 'PPNO')
ALTER TABLE IMPORTER_PRICECALCULATOR ADD PPNO varchar(100)

IF not EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'IMPORTER_PRICECALCULATOR' AND COLUMN_NAME = 'LCNO')
ALTER TABLE IMPORTER_PRICECALCULATOR ADD LCNO varchar(100)

IF not EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'LOG_IMPORTER_PRICECALCULATOR' AND COLUMN_NAME = 'PPNO')
ALTER TABLE LOG_IMPORTER_PRICECALCULATOR ADD PPNO varchar(100)

IF not EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'LOG_IMPORTER_PRICECALCULATOR' AND COLUMN_NAME = 'LCNO')
ALTER TABLE LOG_IMPORTER_PRICECALCULATOR ADD LCNO varchar(100)

IF not EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'IMPORTER_PRICECALCULATOR' AND COLUMN_NAME = 'TaxableValue_VATWise')
ALTER TABLE IMPORTER_PRICECALCULATOR ADD TaxableValue_VATWise numeric(18,3)

IF not EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'LOG_IMPORTER_PRICECALCULATOR' AND COLUMN_NAME = 'TaxableValue_VATWise')
ALTER TABLE LOG_IMPORTER_PRICECALCULATOR ADD TaxableValue_VATWise numeric(18,3)

IF not EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'SETTING' AND COLUMN_NAME = 'CentralDatabase')
alter table SETTING  ADD  CentralDatabase varchar(50) 

IF not EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'LOG_VEHICLECOST_TRACKING')
CREATE TABLE LOG_VEHICLECOST_TRACKING(
VT_NO varchar(200),
PI_VOUCHERNO varchar(100),
ACID varchar(100),
ACNAME varchar(500),
AMOUNT numeric(18,3),
STAMP float,
)

IF not EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'VEHICLECOST_TRACKING')
CREATE TABLE VEHICLECOST_TRACKING(
VT_NO varchar(200),
PI_VOUCHERNO varchar(100),
ACID varchar(100),
ACNAME varchar(500),
AMOUNT numeric(18,3),
STAMP float,
)

IF not EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'LOG_VEHICLECOST_TRACKING' AND COLUMN_NAME = 'CAPITALPURCHASE_VCHRNO')
ALTER TABLE LOG_VEHICLECOST_TRACKING ADD CAPITALPURCHASE_VCHRNO varchar(50)

IF not EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'VEHICLECOST_TRACKING' AND COLUMN_NAME = 'CAPITALPURCHASE_VCHRNO')
ALTER TABLE VEHICLECOST_TRACKING ADD CAPITALPURCHASE_VCHRNO varchar(50)

IF not EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'LOG_VEHICLECOST_TRACKING' AND COLUMN_NAME = 'PHISCALID')
ALTER TABLE LOG_VEHICLECOST_TRACKING ADD PHISCALID varchar(10)

IF not EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'VEHICLECOST_TRACKING' AND COLUMN_NAME = 'PHISCALID')
ALTER TABLE VEHICLECOST_TRACKING ADD PHISCALID varchar(10)

IF not EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'LOG_VEHICLECOST_TRACKING' AND COLUMN_NAME = 'SL_ACID')
ALTER TABLE LOG_VEHICLECOST_TRACKING ADD SL_ACID varchar(50)

IF not EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'LOG_VEHICLECOST_TRACKING' AND COLUMN_NAME = 'SL_ACNAME')
ALTER TABLE LOG_VEHICLECOST_TRACKING ADD SL_ACNAME varchar(200)

IF not EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'VEHICLECOST_TRACKING' AND COLUMN_NAME = 'SL_ACID')
ALTER TABLE VEHICLECOST_TRACKING ADD SL_ACID varchar(50)

IF not EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'VEHICLECOST_TRACKING' AND COLUMN_NAME = 'SL_ACNAME')
ALTER TABLE VEHICLECOST_TRACKING ADD SL_ACNAME varchar(200)

IF not EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'SETTING' AND COLUMN_NAME = 'EnableManualStockValuation')
alter table SETTING  ADD  EnableManualStockValuation tinyint  DEFAULT 0 WITH VALUES

IF not EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'SETTING' AND COLUMN_NAME = 'SHOW_PURCHASE_MENU')
alter table SETTING  ADD  SHOW_PURCHASE_MENU tinyint  DEFAULT 0 WITH VALUES

IF not EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'LOG_PARTY_ADDITIONALINFO')
CREATE TABLE [dbo].[LOG_PARTY_ADDITIONALINFO](
	[ACID] [varchar](25) NOT NULL,
	[CNAME] [varchar](100) NULL,
	[ONAME] [varchar](100) NULL,
	[OCONTACT] [varchar](100) NULL,
	[ODESIGNATION] [varchar](50) NULL,
	[CONTACTNAME] [varchar](199) NULL,
	[CCONTACT_A] [varchar](100) NULL,
	[CCONTACT_B] [varchar](100) NULL,
	[CDESIGNATION] [varchar](100) NULL,
	[RELATEDSPERSON_A] [varchar](100) NULL,
	[RELATEDSPERSON_B] [varchar](100) NULL,
	[NOTES] [varchar](500) NULL,
	[EDATE] [varchar](15) NULL,
	[STAMP] [decimal](32, 18) NULL DEFAULT (CONVERT([float],getdate()))
)




IF not EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'RMD_BILLTRACK_DELETED')
CREATE TABLE [dbo].[RMD_BILLTRACK_DELETED](
	[TRNDATE] [datetime] NULL,
	[VCHRNO] [varchar](25) NULL,
	[CHALANNO] [varchar](25) NULL,
	[AMOUNT] [numeric](18, 2) NULL,
	[REFBILL] [varchar](25) NULL,
	[DIVISION] [char](3) NULL,
	[ACID] [varchar](25) NULL,
	[PhiscalID] [varchar](20) NULL,
	[REFDIVISION] [varchar](3) NULL,
	[ID] [varchar](100) NULL,
	[TBillNo] [varchar](30) NULL,
	[VOUCHERTYPE] [varchar](2) NOT NULL,
	[STAMP] [float] NULL
)

IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'RMD_SUBLEDGER_ACLIST' AND COLUMN_NAME = 'SL_TYPE')
ALTER TABLE RMD_SUBLEDGER_ACLIST ADD SL_TYPE VARCHAR(150)

IF not EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'SETTING' AND COLUMN_NAME = 'DivisionWiseBillTracking')
ALTER TABLE SETTING ADD DivisionWiseBillTracking tinyint  DEFAULT 0 with values

IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'AccTran_PostDir' AND COLUMN_NAME = 'BANKCODE')
ALTER TABLE AccTran_PostDir  ADD BANKCODE VARCHAR(50)

IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'AccTran_PostDir' AND COLUMN_NAME = 'BANKNAME')
ALTER TABLE AccTran_PostDir  ADD BANKNAME VARCHAR(100)

IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'AccTran_PostDir' AND COLUMN_NAME = 'BankId ')
ALTER TABLE AccTran_PostDir  ADD BankId  VARCHAR(30)

IF not EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'ErrorJsonLog')
create  table ErrorJsonLog(FormName nvarchar(100),JSON nvarchar(MAX),UserName nvarchar(MAX),Stamp datetime)

IF not EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'ADDITIONALCOST_INDIVIDUAL')
                        CREATE TABLE ADDITIONALCOST_INDIVIDUAL(
                        VCHRNO varchar(25),
                        PhiscalID varchar(20),
                        DIVISION varchar(3),
                        MCODE varchar(25),
                        MENUCODE varchar(25),
                        PRODUCTNAME varchar(200),
                        BATCH varchar(100),
                        RATE numeric(18,2),
                        AMOUNT numeric(18,2),
                        INDIVIDUAL_AMOUNT numeric(18,2),
                        ADDITIONALCOSTAC varchar(100),
                        STAMP float
                        ) 
IF not EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'SETTING' AND COLUMN_NAME = 'VATNOTCOMPULSORY')
ALTER TABLE SETTING ADD VATNOTCOMPULSORY TINYINT DEFAULT 0 WITH VALUES

 IF not EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'RMD_journal' AND COLUMN_NAME = 'OPPNAME')
ALTER TABLE RMD_journal add OPPNAME nvarchar(max)

 IF not EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'AdditionalCost_Costing')
 CREATE TABLE AdditionalCost_Costing (
 VCHRNO varchar(25),
 CHALANNO varchar(50),
 DIVISION varchar(3),
 VoucherType varchar(100),
 PhiscalID varchar(20),
 SNO int,
 STAMP float,
 COMPANYID varchar(25),
 guid varchar(100),
 REF_BILLNO varchar(100),
 REF_BILLDATE smalldatetime,
 DR_ACCOUNT varchar(500),
 DESCRIPTION varchar(500),
 AMOUNT numeric(18,2),
 VAT numeric(18,2),
 REMARKS varchar(500),
 CR_ACCOUNT varchar(100),
 TDS_AMOUNT numeric(18,2),
 TDS_AC varchar(500),
 SUPPLIERNAME varchar(500),
 DO_ACPOSTING tinyint,
 IS_TAXABLE_ADDITIONAL_BILL tinyint
)  

IF not EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'ADDITIONALCOST_JSON_DELETED')
CREATE TABLE [dbo].ADDITIONALCOST_JSON_DELETED(
	[Vchrno] [varchar](25) NOT NULL,
	[Division] [char](3) NULL,
	[PhiscalId] [varchar](20) NULL,
	[VoucherType] [varchar](2) NULL,
	[CompanyId] [varchar](25) NULL,
	[JsonAdditionalCost] [nvarchar](max) NULL,
	[PIVchrno] [varchar](25) NULL,
	[stamp] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

IF not EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'SETTING' AND COLUMN_NAME = 'DONOT_TAKE_DB_BACKUP')
ALTER TABLE SETTING ADD DONOT_TAKE_DB_BACKUP  TINYINT DEFAULT 0 WITH VALUES

IF not EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'ACCTRAN_POSTDIR' AND COLUMN_NAME = 'IS_PDC_TO_RVPV')
ALTER TABLE ACCTRAN_POSTDIR ADD IS_PDC_TO_RVPV TINYINT DEFAULT 0 WITH VALUES

IF not EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'RMD_ACLIST' AND COLUMN_NAME = 'IS_OVERSEAS_PARTY')
ALTER TABLE RMD_ACLIST ADD IS_OVERSEAS_PARTY TINYINT DEFAULT 0 WITH VALUES

IF not EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'SETTING' AND COLUMN_NAME = 'isOverSeas')
ALTER TABLE SETTING ADD isOverSeas TINYINT DEFAULT 0 WITH VALUES

 IF not EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'PURPROD_TDS' AND COLUMN_NAME = 'OPPNAME')
ALTER TABLE PURPROD_TDS add OPPNAME nvarchar(max)

IF not EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'RMD_JOURNAL_FOR_DNCN')
CREATE TABLE [dbo].[RMD_JOURNAL_FOR_DNCN](
	[VCHRNO] [varchar](25) NOT NULL,
	[ACID] [varchar](25) NULL,
	[FILONO] [varchar](50) NULL,
	[DRAMNT] [numeric](18, 2) NULL,
	[CRAMNT] [numeric](18, 2) NULL,
	[DIVISION] [char](3) NULL,
	[SNO] [int] NULL,
	[NARRATION] [varchar](1000) NULL,
	[VoucherType] [varchar](2) NOT NULL,
	[ChequeNo] [varchar](20) NULL,
	[ChequeDate] [varchar](20) NULL,
	[FCurrency] [varchar](20) NULL,
	[FCurAmount] [numeric](18, 2) NULL,
	[CostCenter] [varchar](100) NULL,
	[MultiJournalSno] [numeric](18, 0) NULL,
	[OppAcid] [varchar](20) NULL,
	[OppRemarks] [varchar](200) NULL,
	[OppChequeNo] [varchar](50) NULL,
	[OppChequeDate] [varchar](20) NULL,
	[OppCostCenter] [varchar](50) NULL,
	[PhiscalID] [varchar](20) NULL,
	[VTRACKID] [float] NULL,
	[TOACID] [varchar](25) NULL,
	[STAMP] [float] NULL,
	[guid] [varchar](100) NULL,
	[companyid] [varchar](25) NULL,
	[NARATION1] [varchar](1000) NULL,
	[SL_ACID] [varchar](25) NULL,
	[SALESMAN] [varchar](50) NULL,
	[ISTAXABLE] [tinyint] NULL,
	[CPTYPE] [tinyint] NULL,
	[DISAMNT] [numeric](18, 8) NULL,
	[OPPNAME] [nvarchar](max) NULL,
	[ChequeDateBS] [varchar](20) NULL
)

IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'RMD_JOURNAL_FOR_DNCN' AND COLUMN_NAME = 'COSTCENTERGROUP_NAME') 
alter table RMD_JOURNAL_FOR_DNCN add COSTCENTERGROUP_NAME varchar(100)

IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'RMD_JOURNAL_FOR_DNCN' AND COLUMN_NAME = 'CCG_ID') 
alter table RMD_JOURNAL_FOR_DNCN add CCG_ID varchar(10)

IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'RMD_JOURNAL_FOR_DNCN' AND COLUMN_NAME = 'BUDGETNAME') 
alter table RMD_JOURNAL_FOR_DNCN add BUDGETNAME varchar(200)