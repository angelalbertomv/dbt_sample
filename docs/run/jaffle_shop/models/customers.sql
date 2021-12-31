
   
  USE [sqlsampledatastack];
  if object_id ('"dbo"."customers__dbt_tmp_temp_view"','V') is not null
      begin
      drop view "dbo"."customers__dbt_tmp_temp_view"
      end


   
   
  USE [sqlsampledatastack];
  if object_id ('"dbo"."customers__dbt_tmp"','U') is not null
      begin
      drop table "dbo"."customers__dbt_tmp"
      end


   USE [sqlsampledatastack];
   EXEC('create view "dbo"."customers__dbt_tmp_temp_view" as
    with customers as (

    select * from "sqlsampledatastack"."dbo"."stg_customers"

),

orders as (

    select * from "sqlsampledatastack"."dbo"."stg_orders"

),

payments as (

    select * from "sqlsampledatastack"."dbo"."stg_payments"

),

customer_orders as (

        select
        customer_id,

        min(order_date) as first_order,
        max(order_date) as most_recent_order,
        count(order_id) as number_of_orders
    from orders

    group by customer_id

),

customer_payments as (

    select
        orders.customer_id,
        sum(amount) as total_amount

    from payments

    left join orders on
         payments.order_id = orders.order_id

    group by orders.customer_id

),

final as (

    select
        customers.customer_id,
        customers.first_name,
        customers.last_name,
        customer_orders.first_order,
        customer_orders.most_recent_order,
        customer_orders.number_of_orders,
        customer_payments.total_amount as customer_lifetime_value

    from customers

    left join customer_orders
        on customers.customer_id = customer_orders.customer_id

    left join customer_payments
        on  customers.customer_id = customer_payments.customer_id

)

select * from final
    ');

   SELECT * INTO "sqlsampledatastack"."dbo"."customers__dbt_tmp" FROM
    "sqlsampledatastack"."dbo"."customers__dbt_tmp_temp_view"

   
   
  USE [sqlsampledatastack];
  if object_id ('"dbo"."customers__dbt_tmp_temp_view"','V') is not null
      begin
      drop view "dbo"."customers__dbt_tmp_temp_view"
      end

    
   use [sqlsampledatastack];
  if EXISTS (
        SELECT * FROM
        sys.indexes WHERE name = 'dbo_customers__dbt_tmp_cci'
        AND object_id=object_id('dbo_customers__dbt_tmp')
    )
  DROP index dbo.customers__dbt_tmp.dbo_customers__dbt_tmp_cci
  CREATE CLUSTERED COLUMNSTORE INDEX dbo_customers__dbt_tmp_cci
    ON dbo.customers__dbt_tmp

   

