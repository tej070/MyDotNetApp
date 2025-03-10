CREATE OR ALTER PROCEDURE WSP_getCostPerUnit_AdditionalCost
--declare 
	@pi_vchrno varchar(50)

AS

DROP TABLE IF EXISTS #adVoucherListing

select VCHRNO
into #adVoucherListing
from ACCMAIN
where REFBILL = @pi_vchrno


DROP TABLE IF EXISTS #piData

CREATE TABLE #piData
	(MCODE VARCHAR(25) , BATCH VARCHAR(100) , BATCHID VARCHAR(50) , QUANTITY FLOAT , AMOUNT FLOAT)


DECLARE @PCL VARCHAR(10),@QUERY NVARCHAR(MAX)

SELECT @PCL = ISNULL(PCL,'~') FROM PURMAIN WHERE VCHRNO = @pi_vchrno


IF @PCL <> 'PC002'
	SET @QUERY = ' SELECT MCODE , BATCH , BATCHID , SUM(QUANTITY) QUANTITY , SUM(TAXABLE + NONTAXABLE) AMOUNT FROM RMD_TRNPROD WITH (NOLOCK) WHERE VCHRNO = '''+@pi_vchrno+''' GROUP BY MCODE , BATCH , BATCHID '
ELSE
	SET @QUERY = ' SELECT MCODE , BATCH , NBATCHID , SUM(QUANTITY) QUANTITY , SUM(TAXABLE + NONTAXABLE) AMOUNT FROM PURPROD WITH (NOLOCK) WHERE VCHRNO = '''+@pi_vchrno+''' GROUP BY MCODE , BATCH , NBATCHID '


INSERT INTO #piData
	EXECUTE (@QUERY)


DROP TABLE IF EXISTS #adData

CREATE TABLE #adData
	(MCODE VARCHAR(25) , BATCH VARCHAR(100) , BATCHID VARCHAR(50) , AMOUNT FLOAT)


INSERT INTO #adData

	SELECT D.MCODE , D.BATCH , D.BATCHID , SUM( IIF( C.Action = 'Subtraction' , -1 , 1 ) * D.Amount) AMOUNT
	FROM #adVoucherListing A
	JOIN tblAdditionalCost B ON A.VCHRNO = B.VCHRNO
	JOIN tblCostingTerm C ON B.ADID = C.ADID
	JOIN tblAdditionalCost_ProductWise D ON B.Guid = D.Guid
	WHERE ISNULL(C.includeInStock,0) <> 0
	group by D.MCODE , D.BATCH , D.BATCHID


SELECT @pi_vchrno VCHRNO , A.MCODE , A.BATCH , isnull(A.BATCHID,'') BATCHID , (A.AMOUNT + ISNULL(B.AMOUNT,0)) / A.QUANTITY COST_PER_UNIT
FROM #piData A
LEFT JOIN #adData B ON A.MCODE = B.MCODE AND A.BATCH = B.BATCH AND ISNULL(A.BATCHID,'') = ISNULL(B.BATCHID,'')