
CREATE OR ALTER PROCEDURE BRONZE.LOAD_BRONZE AS 
BEGIN
truncate table Bronze.crm_cust_info;
bulk insert Bronze.crm_cust_info
from 'C:\Users\Rajesh\Downloads\sql-data-warehouse-project-main\sql-data-warehouse-project-main\datasets\source_crm\cust_info.csv'
with(
firstrow=2,
fieldterminator = ',',
tablock
);


truncate table Bronze.crm_prd_info;
bulk insert Bronze.crm_prd_info
from 'C:\Users\Rajesh\Downloads\sql-data-warehouse-project-main\sql-data-warehouse-project-main\datasets\source_crm\prd_info.csv'
with(
firstrow=2,
fieldterminator = ',',
tablock
);
select * from Bronze.crm_sales_details;
truncate table Bronze.crm_sales_details;
bulk insert Bronze.crm_sales_details
from 'C:\Users\Rajesh\Downloads\sql-data-warehouse-project-main\sql-data-warehouse-project-main\datasets\source_crm\sales_details.csv'
with(
firstrow=2,
fieldterminator = ',',
tablock
);
;



select * from Bronze.crm_cust_info;
select count(*) from Bronze.crm_cust_info;




truncate table Bronze.erp_cust_az12;
bulk insert Bronze.erp_cust_az12
from 'C:\Users\Rajesh\Downloads\sql-data-warehouse-project-main\sql-data-warehouse-project-main\datasets\source_erp\cust_az12.csv'
with(
firstrow=2,
fieldterminator = ',',
tablock
);

truncate table Bronze.erp_loc_a101;
bulk insert Bronze.erp_loc_a101
from 'C:\Users\Rajesh\Downloads\sql-data-warehouse-project-main\sql-data-warehouse-project-main\datasets\source_erp\loc_a101.csv'
with(
firstrow=2,
fieldterminator = ',',
tablock
);

truncate table Bronze.erp_px_cat_g1v2;
bulk insert Bronze.erp_px_cat_g1v2
from 'C:\Users\Rajesh\Downloads\sql-data-warehouse-project-main\sql-data-warehouse-project-main\datasets\source_erp\px_cat_g1v2.csv'
with(
firstrow=2,
fieldterminator = ',',
tablock
);
END 
