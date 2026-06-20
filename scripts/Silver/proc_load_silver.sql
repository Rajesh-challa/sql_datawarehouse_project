
# Silver Layer Data Cleaning and Transformation

## Introduction

The Silver Layer is the second layer in the Medallion Architecture. Its primary purpose is to transform raw data from the Bronze Layer into clean, standardized, and validated data that can be trusted for analytics and reporting.

The major objectives of the Silver Layer are:

* Data Cleansing
* Data Standardization
* Data Validation
* Duplicate Removal
* Business Rule Enforcement
* Data Quality Improvement

All Silver tables include the following audit column:

```sql
dwh_create_date DATETIME2 DEFAULT GETDATE()
```

This column records when the data was loaded into the warehouse.

---

# 1. Customer Information Cleaning (crm_cust_info)

## Business Objective

Customer records may contain duplicates, inconsistent gender values, and abbreviated marital status values. The objective is to keep the latest customer record and standardize attributes.

## Transformations Applied

### Remove Duplicate Customers

```sql
ROW_NUMBER() OVER(
    PARTITION BY cst_id
    ORDER BY cst_create_date DESC
)
```

Keeps only the latest customer record.

### Remove Extra Spaces

```sql
TRIM(cst_firstname)
TRIM(cst_lastname)
```

### Standardize Marital Status

| Source | Target  |
| ------ | ------- |
| S      | Single  |
| M      | Married |
| Others | n/a     |

### Standardize Gender

| Source | Target |
| ------ | ------ |
| M      | Male   |
| F      | Female |
| Others | n/a    |

## SQL Code

```sql

  
INSERT INTO Silver.crm_cust_info
(
    cst_id,
    cst_key,
    cst_firstname,
    cst_lastname,
    cst_marital_status,
    cst_gndr,
    cst_create_date
)
SELECT
    cst_id,
    cst_key,
    TRIM(cst_firstname),
    TRIM(cst_lastname),

    CASE
        WHEN UPPER(TRIM(cst_marital_status))='S' THEN 'Single'
        WHEN UPPER(TRIM(cst_marital_status))='M' THEN 'Married'
        ELSE 'n/a'
    END,

    CASE
        WHEN UPPER(TRIM(cst_gndr))='F' THEN 'Female'
        WHEN UPPER(TRIM(cst_gndr))='M' THEN 'Male'
        ELSE 'n/a'
    END,

    cst_create_date

FROM(
    SELECT *,
           ROW_NUMBER() OVER(
           PARTITION BY cst_id
           ORDER BY cst_create_date DESC) flag_last
    FROM Bronze.crm_cust_info
    WHERE cst_id IS NOT NULL
)t
WHERE flag_last=1;
```

---

# 2. Product Information Cleaning (crm_prd_info)

## Business Objective

Product information contains encoded keys, inconsistent product lines, and historical versions of products.

## Transformations Applied

### Extract Product Category

```sql
REPLACE(SUBSTRING(prd_key,1,4),'-','_')
```

Example:

```text
CO-RF-FR-R92R-58
```

becomes

```text
cat_id = CO_RF
```

### Extract Product Key

```sql
SUBSTRING(prd_key,7,LEN(prd_key))
```

### Standardize Product Line

| Source | Target      |
| ------ | ----------- |
| M      | Mountain    |
| R      | Road        |
| S      | Other Sales |
| T      | Touring     |
| Others | n/a         |

### Handle Missing Product Cost

```sql
ISNULL(prd_cost,0)
```

### Implement SCD Logic

```sql
LEAD(prd_start_dt)
```

Used to calculate product end dates.

## SQL Code

```sql
INSERT INTO Silver.crm_prd_info
(
    prd_id,
    cat_id,
    prd_key,
    prd_nm,
    prd_cost,
    prd_line,
    prd_start_dt,
    prd_end_dt
)
SELECT
    prd_id,
    REPLACE(SUBSTRING(prd_key,1,4),'-','_'),
    SUBSTRING(prd_key,7,LEN(prd_key)),
    TRIM(prd_nm),
    ISNULL(prd_cost,0),

    CASE
        WHEN TRIM(UPPER(prd_line))='M' THEN 'Mountain'
        WHEN TRIM(UPPER(prd_line))='R' THEN 'Road'
        WHEN TRIM(UPPER(prd_line))='S' THEN 'Other Sales'
        WHEN TRIM(UPPER(prd_line))='T' THEN 'Touring'
        ELSE 'n/a'
    END,

    CAST(prd_start_dt AS DATE),

    CAST(
        LEAD(prd_start_dt)
        OVER(PARTITION BY prd_key ORDER BY prd_start_dt)-1
        AS DATE
    )
FROM Bronze.crm_prd_info;
```

---

# 3. Sales Information Cleaning (crm_sales_details)

## Business Objective

Sales data contains invalid dates, negative sales amounts, and incorrect pricing information.

## Transformations Applied

### Date Validation

Convert integer dates to SQL DATE.

Invalid values:

```text
0
Invalid Length
```

are converted to NULL.

### Sales Validation

Business Rule:

```text
Sales = Quantity × Price
```

If the rule is violated, sales are recalculated.

### Price Validation

Negative or NULL prices are recalculated.

## SQL Code

```sql
INSERT INTO Silver.crm_sales_details
(
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt,
    sls_sales,
    sls_quantity,
    sls_price
)
SELECT

    sls_ord_num,
    sls_prd_key,
    sls_cust_id,

    CASE
        WHEN LEN(sls_order_dt)!=8 OR sls_order_dt=0
        THEN NULL
        ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
    END,

    CASE
        WHEN LEN(sls_ship_dt)!=8 OR sls_ship_dt=0
        THEN NULL
        ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
    END,

    CASE
        WHEN LEN(sls_due_dt)!=8 OR sls_due_dt=0
        THEN NULL
        ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
    END,

    CASE
        WHEN ISNULL(sls_sales,0)<0
             OR sls_sales!=sls_quantity*ABS(sls_price)
        THEN sls_quantity*ABS(sls_price)

        ELSE ISNULL(
             sls_sales,
             sls_quantity*ABS(sls_price)
        )
    END,

    sls_quantity,

    CASE
        WHEN sls_price<0 OR sls_price IS NULL
        THEN ISNULL(sls_sales,0)/NULLIF(sls_quantity,0)
        ELSE sls_price
    END

FROM Bronze.crm_sales_details;
```

---

# 4. ERP Customer Information Cleaning (erp_cust_az12)

## Business Objective

Customer IDs contain unwanted prefixes and gender values are inconsistent.

## Transformations Applied

### Remove NAS Prefix

```sql
SUBSTRING(cid,4,LEN(cid))
```

### Remove Future Birth Dates

Future dates are considered invalid.

### Standardize Gender

| Source | Target |
| ------ | ------ |
| M      | Male   |
| Male   | Male   |
| F      | Female |
| Female | Female |
| NULL   | N/A    |
| Blank  | N/A    |

## SQL Code

```sql
INSERT INTO Silver.erp_cust_az12
(
    cid,
    bdate,
    gen
)
SELECT

    CASE
        WHEN cid LIKE 'NAS%'
        THEN SUBSTRING(cid,4,LEN(cid))
        ELSE cid
    END,

    CASE
        WHEN bdate>GETDATE()
        THEN NULL
        ELSE bdate
    END,

    CASE
        WHEN gen IN ('M','Male') THEN 'Male'
        WHEN gen IN ('F','Female') THEN 'Female'
        WHEN TRIM(gen)='' THEN 'N/A'
        WHEN gen IS NULL THEN 'N/A'
        ELSE 'N/A'
    END

FROM Bronze.erp_cust_az12;
```

---

# 5. ERP Location Cleaning (erp_loc_a101)

## Business Objective

Country names are inconsistent and customer IDs contain unnecessary symbols.

## SQL Code

```sql
INSERT INTO Silver.erp_loc_a101
(
    cid,
    cntry
)
SELECT

    REPLACE(cid,'-',''),

    CASE
        WHEN cntry IS NULL THEN 'N/A'
        WHEN TRIM(cntry)='' THEN 'N/A'
        WHEN cntry='US' THEN 'United States'
        WHEN cntry='USA' THEN 'United States'
        WHEN cntry='DE' THEN 'Germany'
        ELSE cntry
    END

FROM Bronze.erp_loc_a101;
```

---

# 6. ERP Product Category (erp_px_cat_g1v2)

## Business Objective

This is a reference table used for product categorization. No significant data quality issues were found.

## SQL Code

```sql
INSERT INTO Silver.erp_px_cat_g1v2
(
    id,
    cat,
    subcat,
    maintenance
)
SELECT
    id,
    cat,
    subcat,
    maintenance
FROM Bronze.erp_px_cat_g1v2;
```

---

# Conclusion

The Silver Layer transformed raw Bronze data into a clean, consistent, and analytics-ready dataset by:

* Removing duplicates
* Standardizing gender and marital status
* Cleaning text fields
* Validating dates
* Correcting sales calculations
* Standardizing countries
* Removing invalid prefixes
* Creating historical product records using SCD logic

The cleaned Silver Layer serves as the foundation for building Gold Layer dimensions, fact tables, and Power BI dashboards.
