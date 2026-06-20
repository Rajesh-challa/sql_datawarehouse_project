
IF OBJECT_ID('Silver.crm_cust_info','U') IS NOT NULL
    DROP TABLE Silver.crm_cust_info;

CREATE TABLE Silver.crm_cust_info(
    cst_id INT,
    cst_key NVARCHAR(20),
    cst_firstname NVARCHAR(20),
    cst_lastname NVARCHAR(20),
    cst_marital_status NVARCHAR(20),
    cst_gndr NVARCHAR(10),
    cst_create_date DATE,
    dwh_create_date DATETIME2 DEFAULT SYSDATETIME()
);

IF OBJECT_ID('Silver.crm_prd_info','U') IS NOT NULL
    DROP TABLE Silver.crm_prd_info;

CREATE TABLE Silver.crm_prd_info(
    prd_id INT,
    prd_key NVARCHAR(20),
    prd_nm VARCHAR(20),
    prd_cost INT,
    prd_line NVARCHAR(20),
    prd_start_dt DATETIME,
    prd_end_dt DATETIME,
    dwh_create_date DATETIME2 DEFAULT SYSDATETIME()
);

IF OBJECT_ID('Silver.crm_sales_details','U') IS NOT NULL
    DROP TABLE Silver.crm_sales_details;

CREATE TABLE Silver.crm_sales_details(
    sls_ord_num NVARCHAR(50),
    sls_prd_key NVARCHAR(50),
    sls_cust_id INT,
    sls_order_dt DATE,
    sls_ship_dt DATE,
    sls_due_dt DATE,
    sls_sales INT,
    sls_quantity INT,
    sls_price INT,
    dwh_create_date DATETIME2 DEFAULT SYSDATETIME()
);

IF OBJECT_ID('Silver.erp_cust_az12','U') IS NOT NULL
    DROP TABLE Silver.erp_cust_az12;

CREATE TABLE Silver.erp_cust_az12(
    cid NVARCHAR(50),
    bdate DATE,
    gen NVARCHAR(20),
    dwh_create_date DATETIME2 DEFAULT SYSDATETIME()
);

IF OBJECT_ID('Silver.erp_loc_a101','U') IS NOT NULL
    DROP TABLE Silver.erp_loc_a101;

CREATE TABLE Silver.erp_loc_a101(
    cid NVARCHAR(20),
    cntry NVARCHAR(20),
    dwh_create_date DATETIME2 DEFAULT SYSDATETIME()
);

IF OBJECT_ID('Silver.erp_px_cat_g1v2','U') IS NOT NULL
    DROP TABLE Silver.erp_px_cat_g1v2;

CREATE TABLE Silver.erp_px_cat_g1v2(
    id NVARCHAR(20),
    cat NVARCHAR(20),
    subcat NVARCHAR(20),
    maintenance NVARCHAR(20),
    dwh_create_date DATETIME2 DEFAULT SYSDATETIME()
);
