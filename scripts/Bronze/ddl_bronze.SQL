if OBJECT_ID('Bronze.crm_cust_info','U') is not null
drop table Bronze.crm_cust_info;
create table Bronze.crm_cust_info(
cst_id int,
cst_key nvarchar(20),
cst_firstname nvarchar(20),
cst_lastname nvarchar(20),
cst_marital_status  nvarchar(20),
cst_gndr nvarchar(10),
cst_create_date date
);
if OBJECT_ID('Bronze.crm_prd_info','U') is not null
drop table Bronze.crm_prd_info;
create table Bronze.crm_prd_info (
prd_id int ,
prd_key nvarchar(20),
prd_nm varchar(20),
prd_cost int,
prd_line nvarchar(20),
prd_start_dt datetime,
prd_end_dt datetime
);
if OBJECT_ID('Bronze.crm_sales_details','U') is not null
drop table Bronze.crm_sales_details;
create table Bronze.crm_sales_details(
sls_ord_num nvarchar(50),
sls_prd_key nvarchar(50),
sls_cust_id int,
sls_order_dt int,
sls_ship_dt int,
sls_due_dt int, 
sls_sales int, 
sls_quantity int,
sls_price int
);
if OBJECT_ID('Bronze.erp_cust_az12','U') is not null
drop table Bronze.erp_cust_az12;
create table Bronze.erp_cust_az12(
cid nvarchar(50),
bdate date,
gen nvarchar(20)
);
if OBJECT_ID('Bronze.erp_loc_a101','U') is not null
drop table Bronze.erp_loc_a101;
create table Bronze.erp_loc_a101(
cid nvarchar(20),
cntry nvarchar(20)
);
if OBJECT_ID('Bronze.erp_px_cat_g1v2','U') is not null
drop table Bronze.erp_px_cat_g1v2;
create table Bronze.erp_px_cat_g1v2(
id nvarchar(20),
cat nvarchar(20),
subcat nvarchar(20),
maintenance nvarchar(20)
);
