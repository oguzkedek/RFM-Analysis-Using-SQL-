SELECT * FROM Transactions_Data

/*
Cardholder_Name	    Transaction_Date	Transaction_Amount	Merchant_Category_Code_Description
DONNA MARIE HEPP	2016-01-06	        55.04	            STATIONERY STORE/SUPPLIES
DONNA MARIE HEPP	2016-01-06	        62.45	            STATIONERY STORE/SUPPLIES
DONNA MARIE HEPP	2016-01-08	        94.5	            STATIONERY STORE/SUPPLIES
*/

--1
INSERT INTO RFM (Customer)
SELECT DISTINCT [Cardholder_Name] FROM Transactions_Data

/*
Customer	        LastTransactionDate	  Recency   	Frequency	   Monetary    Recency_Scale    Frequency_Scale     	Monetary_Scale
DONNA MARIE HEPP	    NULL	              NULL	    NULL	    NULL	    NULL	        NULL	        NULL
STAYCEE DAINS	            NULL	              NULL	    NULL	    NULL	    NULL	        NULL	        NULL
JEANETTE MONDALA	    NULL	              NULL	    NULL	    NULL	    NULL	        NULL	        NULL
...
(1015 Customers)
*/

--2
UPDATE RFM SET LastTransactionDate=(SELECT MAX(Transaction_Date) 
FROM Transactions_Data WHERE [Cardholder_Name]=RFM.Customer)

/*

Customer	          LastTransactionDate	  	Recency   Frequency	Monetary    Recency_Scale	Frequency_Scale     Monetary_Scale
DONNA MARIE HEPP	   2016-12-19 00:00:00.000	NULL	    NULL	    NULL    	    NULL	        NULL	        NULL
STAYCEE DAINS	      	 2016-12-30 00:00:00.000	NULL	    NULL	    NULL	    NULL	        NULL	        NULL
JEANETTE MONDALA	    2016-12-15 00:00:00.000	NULL	    NULL	    NULL	    NULL	        NULL	        NULL
...
*/

--3
UPDATE RFM SET Recency = DATEDIFF (DAY, LastTransactionDate, '20170102')

/*

Customer	        LastTransactionDate	    Recency.   Frequency	Monetary	Recency_Scale	Frequency_Scale	    Monetary_Scale
DONNA MARIE HEPP	2016-12-19 00:00:00.000	    14	        NULL	    	NULL	   	NULL	        	NULL	        NULL
STAYCEE DAINS	        2016-12-30 00:00:00.000	    3	        NULL	    	NULL	    	NULL	        	NULL	        NULL
JEANETTE MONDALA	2016-12-15 00:00:00.000	    18	        NULL	    	NULL	    	NULL	        	NULL	        NULL
...
*/

--4
UPDATE RFM SET Frequency=(SELECT COUNT(Distinct Transaction_Date) 
FROM Transactions_Data WHERE Cardholder_Name=RFM.Customer)

/*

Customer	        LastTransactionDate	        Recency	    Frequency	  Monetary	Recency_Scale	Frequency_Scale	Monetary_Scale
DONNA MARIE HEPP	2016-12-19 00:00:00.000	       14	     108	     NULL	        NULL	        NULL	     NULL
STAYCEE DAINS	    	2016-12-30 00:00:00.000	       3	     111	     NULL	        NULL	        NULL	     NULL
JEANETTE MONDALA	2016-12-15 00:00:00.000	       18	      19	     NULL	        NULL	        NULL	     NULL
...
*/

--5
UPDATE RFM SET Monetary=(SELECT SUM(Transaction_Amount)  
FROM Transactions_Data WHERE Cardholder_Name=RFM.Customer)

/*

Customer	           LastTransactionDate	            Recency	    Frequency	    Monetary	 Recency_Scale	 Frequency_Scale	 Monetary_Scale
DONNA MARIE HEPP	    2016-12-19 00:00:00.000	        14	        108	       23065	    NULL	        NULL	         NULL
STAYCEE DAINS	            2016-12-30 00:00:00.000	        3	        111	       129016	    NULL	        NULL	         NULL
JEANETTE MONDALA	    2016-12-15 00:00:00.000	        18	        19	       6722	    NULL	        NULL	         NULL
...
*/


--6
UPDATE RFM SET Recency_Scale= 
(
 SELECT RANK FROM
(
SELECT  *,
       NTILE(5) OVER(
       ORDER BY Recency DESC) RANK
FROM RFM
) T WHERE  Customer=RFM.Customer)

/*

Customer	        LastTransactionDate	            Recency	    Frequency	Monetary	Recency_Scale	Frequency_Scale	Monetary_Scale
DONNA MARIE HEPP	    2016-12-19 00:00:00.000	        14	    108	        23065	        4	            NULL	        NULL
STAYCEE DAINS	            2016-12-30 00:00:00.000	        3	    111	        129016	        5	            NULL	        NULL
JEANETTE MONDALA	    2016-12-15 00:00:00.000	        18	    19	        6722	        3	            NULL	        NULL
...
*/


--7
UPDATE RFM SET Frequency_Scale= 
(
 SELECT RANK FROM
(
SELECT  *,
       NTILE(5) OVER(
       ORDER BY Frequency ) RANK
FROM RFM
) T WHERE  Customer=RFM.Customer)

/*

Customer	        LastTransactionDate	            Recency    Frequency	Monetary	Recency_Scale	Frequency_Scale
DONNA MARIE HEPP	    2016-12-19 00:00:00.000	    14	         108	        23065	        4	            5
STAYCEE DAINS	            2016-12-30 00:00:00.000	    3	         111	        129016      	5	            5
JEANETTE MONDALA	    2016-12-15 00:00:00.000	    18	         19	        6722	        3	            3
...
*/


--8
UPDATE RFM SET Monetary_Scale= 
(
 SELECT RANK FROM
(
SELECT  *,
       NTILE(5) OVER(
       ORDER BY Monetary ) RANK
FROM RFM
) T WHERE  Customer=RFM.Customer)

/*

Customer	        LastTransactionDate	        Recency	    Frequency	Monetary	Recency_Scale	Frequency_Scale	Monetary_Scale
DONNA MARIE HEPP	2016-12-19 00:00:00.000	       14	    108	        23065	        4	            5	            5
STAYCEE DAINS	        2016-12-30 00:00:00.000	        3	    111	        129016	        5	            5	            5
JEANETTE MONDALA	2016-12-15 00:00:00.000	       18	    19	        6722	        3	            3	            3
...
*/

--9
UPDATE RFM SET Segment ='Hibernating' 
WHERE Recency_Scale LIKE  '[1-2]%' AND Frequency_Scale LIKE '[1-2]%'  
UPDATE RFM SET Segment ='At_Risk' 
WHERE Recency_Scale LIKE  '[1-2]%' AND Frequency_Scale LIKE '[3-4]%'  
UPDATE RFM SET Segment ='Cant_Loose' 
WHERE Recency_Scale LIKE  '[1-2]%' AND Frequency_Scale LIKE '[5]%'  
UPDATE RFM SET Segment ='About_to_Sleep' 
WHERE Recency_Scale LIKE  '[3]%' AND Frequency_Scale LIKE '[1-2]%'  
UPDATE RFM SET Segment ='Need_Attention' 
WHERE Recency_Scale LIKE  '[3]%' AND Frequency_Scale LIKE '[3]%' 
UPDATE RFM SET Segment ='Loyal_Customers' 
WHERE Recency_Scale LIKE  '[3-4]%' AND Frequency_Scale LIKE '[4-5]%' 
UPDATE RFM SET Segment ='Promising' 
WHERE Recency_Scale LIKE  '[4]%' AND Frequency_Scale LIKE '[1]%' 
UPDATE RFM SET Segment ='New_Customers' 
WHERE Recency_Scale LIKE  '[5]%' AND Frequency_Scale LIKE '[1]%' 
UPDATE RFM SET Segment ='Potential_Loyalists' 
WHERE Recency_Scale LIKE  '[4-5]%' AND Frequency_Scale LIKE '[2-3]%' 
UPDATE RFM SET Segment ='Champions' 
WHERE Recency_Scale LIKE  '[5]%' AND Frequency_Scale LIKE '[4-5]%'

/*

Customer	        LastTransactionDate	   Receny  Frequency	Monetary	Recency_Scale	Frequency_Scale	    Monetary_Scale	   Segment
DONNA MARIE HEPP	2016-12-19 00:00:00.000	    14	    108	        23065	        4	            5	              5	                Loyal_Customers
STAYCEE DAINS	        2016-12-30 00:00:00.000	    3	    111	        129016	        5	            5	              5	                Champions
JEANETTE MONDALA	2016-12-15 00:00:00.000	    18	    19	        6722	        3	            3	              3	                Need_Attention
...

*/

--10
SELECT Segment, COUNT(*) AS Count_ FROM RFM 
GROUP BY Segment 
ORDER BY COUNT_ DESC

/*

    Segment	               Count_
    Hibernating	            	277
    Loyal_Customers	        209
    Champions	            	145
    At_Risk	                121
    Potential_Loyalists	    	115
    Need_Attention	        61
    About_to_Sleep	        56
    Promising	            	13
    New_Customers	        10
    Cant_Loose	            	8

*/

--11
SELECT Segment, AVG(Recency) AS Recency_Avg FROM RFM 
GROUP BY Segment
ORDER BY Recency_Avg 

/*
    Segment	            Recency_Avg
    Champions	             	 5
    New_Customers	         8
    Potential_Loyalists	     	 9
    Promising	            	13
    Loyal_Customers	        15
    Need_Attention	        20
    About_to_Sleep	        21
    At_Risk	                65
    Cant_Loose	            	75
    Hibernating	            	137
*/

--12
SELECT Segment, AVG(Frequency) AS Frequency_Avg FROM RFM 
GROUP BY SEGMENT 
ORDER BY Frequency_Avg DESC

/*

    Segment	        Frequency_Avg
    Champions	            81
    Cant_Loose	            66
    Loyal_Customers	    58
    At_Risk	            29
    Need_Attention	    23
    Potential_Loyalists	    19
    About_to_Sleep	    10
    Hibernating	            7
    New_Customers	    4
    Promising	            4
*/

--13
SELECT Segment, AVG(Monetary) AS Monetary_Avg FROM RFM 
GROUP BY Segment
ORDER BY Monetary_Avg DESC

/*

    Segment	            Monetary_Avg
    Champions	            40034
    Cant_Loose	            35582
    Loyal_Customers	    23107
    At_Risk	            9901
    Potential_Loyalists	    7846
    Need_Attention	    7795
    About_to_Sleep	    4047
    Hibernating	            2910
    New_Customers	    1189
    Promising	            1186

*/