/*
		--------------------------------------------
        CHINOOK DIGITAL MUSIC STORE REVENUE ANALYSIS
        --------------------------------------------
*/


-- Revenue Consistency Check
WITH revenue_validation AS(
	SELECT 
		i.InvoiceId,
        ROUND(i.Total,2) AS Total_Invoice,
        ROUND(SUM(il.UnitPrice*il.Quantity),2) AS Total_InvoiceLine
	FROM Invoice AS i
    JOIN InvoiceLine AS il
		ON i.InvoiceId = il.InvoiceId
	GROUP BY
		i.InvoiceId,
        i.Total    
)
SELECT
	COUNT(*) AS TotalInvoices,
    SUM(CASE
			WHEN Total_Invoice = Total_InvoiceLine
			THEN 1
			ELSE 0
		END
		) AS Matched_Invoices,
	SUM(CASE
			WHEN Total_Invoice <> Total_InvoiceLine
            THEN 1
            ELSE 0
		END
        ) AS Mismatched_Invoices
FROM revenue_validation;



-- Invoice–InvoiceLine Integrity Check
WITH invoiceline_check AS(
	SELECT i.InvoiceId, il.InvoiceLineId AS invoice_check
	FROM Invoice AS i
	LEFT JOIN InvoiceLine AS il
		ON i.InvoiceId = il.InvoiceId
)
SELECT COUNT(*) AS Problem_Invoice
FROM invoiceline_check
WHERE invoice_check IS NULL;
	


-- Checking the validity for UnitPrice and Quantity
SELECT
	COUNT(*) AS Total_InvoiceLine,
	SUM(CASE
			WHEN Quantity <= 0
            THEN 1
            ELSE 0
		END
        ) AS invalid_quantity_rows,
	SUM(CASE
			WHEN UnitPrice <= 0
            THEN 1
            ELSE 0
		END
        ) AS invalid_unitprice_rows
FROM InvoiceLine;



-- Checking Invoice without Customer
SELECT 
	COUNT(*) AS total_invoice,
	SUM(CASE 
			WHEN c.CustomerId IS NULL 
            THEN 1 
            ELSE 0
		END
	) AS invoice_without_customer
FROM Invoice AS i
LEFT JOIN Customer AS c
	ON i.CustomerId = c.CustomerId;
    


-- Checking Customer without Invoice
WITH customer_without_invoice AS(
	SELECT c.CustomerId, COUNT(i.InvoiceId) AS invoice_per_cust
    FROM Customer AS c
    LEFT JOIN Invoice AS i
		ON c.CustomerId = i.CustomerId
	GROUP BY c.CustomerId
)
SELECT 
	COUNT(*) AS total_customer,
	SUM(CASE 
			WHEN invoice_per_cust = 0
            THEN 1 
            ELSE 0
		END
	) AS customer_without_invoice
FROM customer_without_invoice;



-- Revenue Analysis
WITH invoice_info AS(
	SELECT
        ROUND(SUM(Total),2) AS total_revenue,
		COUNT(InvoiceId) AS total_invoice
	FROM Invoice
),
invoiceline_info AS(
	SELECT 
        SUM(Quantity) AS total_quantity_sold
	FROM InvoiceLine AS il
)
SELECT 
	total_revenue,
    total_invoice,
    total_quantity_sold,
    ROUND(total_revenue/total_invoice,2) AS avg_revenue_per_invoice,
    ROUND(total_quantity_sold/total_invoice,2) AS avg_quantity_per_invoice
FROM invoice_info
CROSS JOIN invoiceline_info;

    

-- total revenue per cust, total invoice per cust, avg revenue per invoice per cust
WITH rev_inv_per_cust AS(
	SELECT
		c.CustomerId,
        CONCAT(c.FirstName, ' ',c.LastName) AS full_name,
        SUM(i.Total) AS total_revenue_per_cust,
        COUNT(i.InvoiceId) AS total_invoice_per_cust
	FROM Customer AS c
    JOIN Invoice AS i
		ON c.CustomerId = i.CustomerId
	GROUP BY
		c.CustomerId,
        full_name
)
SELECT *,
	ROUND(total_revenue_per_cust/total_invoice_per_cust,2) AS avg_revenue_per_invoice_per_cust
FROM rev_inv_per_cust
ORDER BY
	total_revenue_per_cust DESC,
	total_invoice_per_cust DESC;
    


-- Customer Contribution
WITH rev_inv_per_cust AS(
	SELECT
		c.CustomerId,
        CONCAT(c.FirstName, ' ',c.LastName) AS full_name,
        SUM(i.Total) AS total_revenue_per_cust
	FROM Customer AS c
    JOIN Invoice AS i
		ON c.CustomerId = i.CustomerId
	GROUP BY
		c.CustomerId,
        full_name
),
total_revenue AS(
	SELECT SUM(Total) AS total_revenue
    FROM Invoice
)
SELECT 
	CustomerId,
	full_name,
    ROUND((total_revenue_per_cust/total_revenue)*100,2) AS customer_contribution
FROM 
	rev_inv_per_cust,
	total_revenue
ORDER BY customer_contribution DESC;



-- Cumulative contribution
WITH rev_inv_per_cust AS(
	SELECT
		c.CustomerId,
        CONCAT(c.FirstName, ' ',c.LastName) AS full_name,
        SUM(i.Total) AS total_revenue_per_cust
	FROM Customer AS c
    JOIN Invoice AS i
		ON c.CustomerId = i.CustomerId
	GROUP BY
		c.CustomerId,
        full_name
),
total_revenue AS(
	SELECT SUM(Total) AS total_revenue
    FROM Invoice
),
customer_contribution AS(
	SELECT 
		CustomerId,
		full_name,
		(total_revenue_per_cust/total_revenue)*100 AS customer_contribution
	FROM 
		rev_inv_per_cust,
		total_revenue
)
SELECT *,
	ROUND(SUM(customer_contribution) OVER(ORDER BY customer_contribution DESC, CustomerId),2) AS cumulative_sum,
    RANK() OVER(ORDER BY customer_contribution DESC, CustomerId) AS contribution_rank
FROM customer_contribution;



-- Country Analysis
WITH total_revenue AS(
	SELECT 
		SUM(Total) AS total_revenue
    FROM Invoice
),
info_per_country AS(
	SELECT
		c.Country,
		SUM(i.Total) AS total_revenue_per_country,
		COUNT(i.InvoiceId) AS total_invoice_per_country,
		COUNT(DISTINCT c.CustomerId) AS total_customer_per_country
	FROM Customer AS c
	JOIN Invoice AS i
		ON c.CustomerId = i.CustomerId
	GROUP BY Country
)
SELECT
	Country,
    total_revenue_per_country,
    total_invoice_per_country,
    total_customer_per_country,
    total_revenue_per_country/total_invoice_per_country AS avg_rev_per_invoice,
    ROUND((total_revenue_per_country/total_revenue)*100,2) AS revenue_contribution_per_country,
	ROUND(total_revenue_per_country/total_customer_per_country,2) AS revenue_per_customer,
    ROUND(total_invoice_per_country / total_customer_per_country,2) AS invoice_per_customer
FROM total_revenue
CROSS JOIN info_per_country
ORDER BY
	total_revenue_per_country DESC;
    


-- Genre Analysis
WITH total_revenue AS(
	SELECT 
		SUM(Total) AS total_revenue
    FROM Invoice
),
genre_stats AS(
	SELECT
		g.Name AS genre,
		SUM(il.UnitPrice*il.Quantity) AS total_revenue_per_genre,
		SUM(il.Quantity) AS total_quantity_sold_per_genre
	FROM InvoiceLine AS il
	JOIN Track AS t
		ON il.TrackId = t.TrackId
	JOIN Genre AS g
		ON g.GenreId = t.GenreId
	GROUP BY g.Name
)
SELECT
	genre,
    ROUND(total_revenue_per_genre,2) AS total_revenue_per_genre,
    total_quantity_sold_per_genre,
	ROUND(total_revenue_per_genre/total_quantity_sold_per_genre,2) AS avg_revenue_per_unit,
	ROUND(total_revenue_per_genre/total_revenue*100,2) AS genre_contribution
FROM genre_stats
CROSS JOIN total_revenue
ORDER BY total_revenue_per_genre DESC;



-- Artist Analysis
WITH total_revenue AS(
	SELECT 
		SUM(Total) AS total_revenue
    FROM Invoice
),
artist_stats AS(
	SELECT
		a.Name AS artist,
		SUM(il.UnitPrice*il.Quantity) AS total_revenue_per_artist,
		SUM(il.Quantity) AS total_quantity_sold_per_artist
	FROM InvoiceLine AS il
	JOIN Track AS t
		ON il.TrackId = t.TrackId
	JOIN Album AS al
		ON al.AlbumId = t.AlbumId
	JOIN Artist AS a
		ON al.ArtistId = a.ArtistId
	GROUP BY a.Name
)
SELECT
	artist,
    ROUND(total_revenue_per_artist,2) AS total_revenue_per_artist,
    total_quantity_sold_per_artist,
	ROUND(total_revenue_per_artist/total_quantity_sold_per_artist,2) AS avg_revenue_per_unit,
	ROUND(total_revenue_per_artist/total_revenue*100,2) AS artist_contribution
FROM artist_stats
CROSS JOIN total_revenue
ORDER BY total_revenue_per_artist DESC;



-- Basket Size
WITH basket_size AS(
	SELECT
		i.InvoiceId,
		i.Total AS invoice_total,
		SUM(il.Quantity) AS total_quantity_per_invoice
	FROM Invoice AS i
	JOIN InvoiceLine AS il
		ON i.InvoiceId = il.InvoiceId
	GROUP BY i.InvoiceId, i.Total
	ORDER BY invoice_total DESC
)
SELECT
	SUM(invoice_total) AS total_invoice,
    AVG(invoice_total) AS avg_invoice_total,
    MIN(invoice_total) AS min_invoice_total,
    MAX(invoice_total) AS max_invoice_total,
    AVG(total_quantity_per_invoice) AS avg_quantity_per_invoice,
    MIN(total_quantity_per_invoice) AS min_invoice_quantity,
    MAX(total_quantity_per_invoice) AS max_invoice_quantity
FROM basket_size;