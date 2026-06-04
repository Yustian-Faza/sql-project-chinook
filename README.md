# Chinook Revenue Analysis

## Project Overview

This project explores one main business question:

**What factors most influence revenue in a digital music store?**

The analysis uses the **Chinook Database** and focuses on understanding revenue from several angles: data quality, customer contribution, market performance, product mix, and transaction behavior. The goal is not just to write SQL queries, but to build a clear business story from the data.

From the overall analysis, the strongest pattern is that revenue is shaped more by **product mix and purchase volume** than by a few dominant customers. Genre plays the biggest role, country helps explain market size, and basket size shows how revenue is formed at the transaction level.

---

## Business Question

The project was designed to answer the following question:

> **What factors most influence revenue in a digital music store?**

To answer that, the analysis was broken down into several supporting questions:

- Is the revenue data reliable enough to analyze?
- Is revenue concentrated in a few customers, or spread across many?
- Which countries contribute the most to revenue?
- Which genres and artists drive the largest share of sales?
- Is revenue driven more by high-value items or by quantity sold?
- Do customers generate more revenue because they buy more often, or because they buy more items per transaction?

---

## Dataset

This project uses the **Chinook sample database**, which simulates a digital media store.

Main tables used in the analysis:

- **Invoice**: transaction-level information
- **InvoiceLine**: item-level transaction details
- **Customer**: customer profile and country information
- **Track**: product-level data
- **Genre**: product category
- **Album** and **Artist**: artist hierarchy for track-level analysis

---

## Analysis Structure

The analysis was organized into the following sections:

1. Business Understanding  
2. Data Understanding  
3. Data Quality Assessment  
4. Revenue Overview  
5. Customer Analysis  
6. Country Analysis  
7. Product Analysis  
8. Customer Behavior Analysis  
9. Executive Summary  
10. Business Recommendations  

---

## Data Quality Checks

Before exploring revenue drivers, the first step was to validate whether the transactional data was internally consistent.

The checks included:

- validating `Invoice.Total` against the sum of `InvoiceLine.UnitPrice * Quantity`
- checking whether any invoice had no invoice lines
- checking for invalid values such as `Quantity <= 0` or `UnitPrice <= 0`
- checking whether every invoice had a valid customer
- checking whether any customer had no invoice

### Main takeaway

The core transaction data was structurally consistent and suitable for further analysis. Invoice totals matched invoice line totals, no empty invoices were found, and there were no invalid quantities or unit prices. This gave confidence that downstream revenue analysis was built on reliable data.

---

## Revenue Overview

A revenue baseline was created to understand how the store generates income at the highest level.

### Key metrics

- **Total revenue:** 2328.60
- **Total invoices:** 412
- **Total quantity sold:** 2240
- **Average revenue per invoice:** 5.65
- **Average quantity per invoice:** 5.44

### Interpretation

Revenue in Chinook is not formed by a small number of very large transactions. Instead, it is built from many relatively small transactions that contain multiple items. This was an early signal that **volume of items sold** may matter more than large ticket values.

---

## Customer Analysis

Customer-level analysis was used to see whether revenue depended heavily on a few buyers.

The analysis included:

- total revenue per customer
- total invoices per customer
- average revenue per invoice per customer
- customer revenue contribution
- cumulative customer contribution

### Main takeaway

Revenue at the customer level was relatively spread out. No single customer dominated sales. The top customer contributed only around **2.13%** of total revenue, and around **80% of revenue** was reached only after accumulating the contribution of **47 out of 59 customers**.

### Interpretation

This suggests that **customer-level concentration is low**. Revenue does not depend on a few “whale” customers, so customer identity alone is not the strongest explanation for revenue differences.

---

## Country Analysis

Country analysis was used to understand whether revenue differences were more visible at the market level than at the individual customer level.

The analysis covered:

- total revenue per country
- total invoices per country
- average revenue per invoice
- revenue contribution per country
- total customers per country
- revenue per customer
- invoice per customer

### Main takeaway

Revenue was much more concentrated at the country level than at the customer level.

- **USA** contributed **22.46%**
- **Canada** contributed **13.05%**
- **Top 5 countries** contributed around **58.77%** of total revenue

### Interpretation

Country matters more than customer identity in explaining revenue variation. However, the largest markets did not stand out because each customer spent dramatically more. Instead, they stood out mostly because they had **more active customers and more invoices**. In other words, **market size** played an important role.

---

## Product Analysis

Product analysis was the strongest part of the project because it showed the clearest revenue pattern.

### Genre Analysis

The analysis measured:

- total revenue per genre
- total quantity sold per genre
- average revenue per unit
- genre revenue contribution

### Main takeaway

Revenue was highly concentrated at the genre level.

- **Rock** contributed **35.5%**
- **Latin** contributed **16.41%**
- **Metal** contributed **11.22%**
- **Alternative & Punk** contributed **10.37%**

Together, the **top 4 genres** contributed around **73.5%** of total revenue.

### Interpretation

Genre was the clearest revenue driver in the dataset. The difference in revenue across genres was explained mainly by **quantity sold**, not by large differences in revenue per unit.

---

### Artist Analysis

The artist layer was used to see whether genre dominance was actually driven by just a few artists.

The analysis measured:

- total revenue per artist
- total quantity sold per artist
- average revenue per unit
- artist contribution

### Main takeaway

Some artists clearly contributed more than others, but artist concentration was not as strong as genre concentration.

Examples of top artists:

- Iron Maiden
- U2
- Metallica
- Led Zeppelin

### Interpretation

Artist performance helped explain product detail, but it did not replace genre as the main driver. Revenue was still more clearly shaped by **genre-level product mix** than by a few superstar artists.

---

## Customer Behavior Analysis

Customer behavior analysis focused on how revenue was formed at the transaction level.

### Basket Size Analysis

This section measured:

- invoice total
- total quantity per invoice
- average basket size
- minimum and maximum invoice size

### Key metrics

- **Average invoice total:** 5.65
- **Average quantity per invoice:** 5.44
- **Minimum quantity per invoice:** 1
- **Maximum quantity per invoice:** 14

### Interpretation

Transactions in Chinook are generally **multi-item purchases**, even though invoice values remain relatively small. This supports the idea that revenue is strongly tied to **purchase volume**, especially when prices per unit are fairly consistent.

---

## Final Conclusion

From the full analysis, the strongest conclusion is:

> **Revenue in Chinook is influenced most by product mix and purchase volume.**

More specifically:

- **Genre** is the strongest revenue driver, especially high-volume genres like Rock, Latin, Metal, and Alternative & Punk.
- **Country** matters because larger markets contribute more revenue through a bigger active customer base.
- **Basket size** matters because revenue is built from transactions containing multiple items.
- **Customer concentration is low**, so a few individual customers do not explain most of the revenue.

In short, Chinook revenue is not mainly driven by a handful of customers or unusually expensive transactions. It is driven by **what people buy**, **how much they buy**, and **which markets generate the most activity**.

---

## Business Recommendations

Based on the findings, the business recommendations are as follows:

### 1. Prioritize high-performing genres

Genres such as Rock, Latin, Metal, and Alternative & Punk should be treated as core revenue categories. These genres deserve stronger placement in recommendations, featured collections, and promotional visibility.

### 2. Focus on increasing basket size

Since revenue is built through multi-item transactions, strategies such as bundling, related-item recommendations, and curated playlists may help increase the number of items purchased per invoice.

### 3. Strengthen large markets

Countries such as USA and Canada should remain key targets because they contribute the largest share of revenue through market size and transaction volume.

### 4. Monitor high-value niche markets

Some smaller countries show relatively strong revenue per customer. These markets may not be large yet, but they may represent niche opportunities worth observing.

### 5. Use product-based strategy more than customer-based strategy

Because customer revenue is relatively spread out, strategies built around **product preference** are likely to be more effective than strategies focused only on a small set of individual customers.

---

## Limitations

This project has several limitations that should be acknowledged:

- Chinook is a sample database, not a live commercial dataset.
- The analysis is based on transaction history only.
- There is no information about marketing campaigns, discounts, promotions, acquisition channels, or churn.
- The analysis shows patterns and associations in the data, but it does not prove strict causality.
- Product prices in Chinook appear relatively uniform, so price effects are limited.

---

## Tools Used

- **SQL**
- **Chinook Database**

---

## Files

Suggested project files:

- `README.md` — project summary and findings
- `chinook_revenue_analysis.sql` — complete SQL queries used in the analysis

---

## Why This Project Matters

This project was built as a portfolio piece for a Data Analyst track. The focus was not only on writing SQL queries, but also on:

- translating business questions into analysis steps
- validating data before interpreting results
- connecting technical output to business meaning
- presenting insights in a way that supports decision-making

