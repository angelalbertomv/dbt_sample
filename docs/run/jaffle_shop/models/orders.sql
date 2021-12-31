
   
  USE [sqlsampledatastack];
  if object_id ('"dbo"."orders__dbt_tmp_temp_view"','V') is not null
      begin
      drop view "dbo"."orders__dbt_tmp_temp_view"
      end


   
   
  USE [sqlsampledatastack];
  if object_id ('"dbo"."orders__dbt_tmp"','U') is not null
      begin
      drop table "dbo"."orders__dbt_tmp"
      end


   USE [sqlsampledatastack];
   EXEC('create view "dbo"."orders__dbt_tmp_temp_view" as
    

with orders as (

    select * from "sqlsampledatastack"."dbo"."stg_orders"

),

payments as (

    select * from "sqlsampledatastack"."dbo"."stg_payments"

),

order_payments as (

    select
        order_id,

        sum(case when payment_method = ''credit_card'' then amount else 0 end) as credit_card_amount,
        sum(case when payment_method = ''coupon'' then amount else 0 end) as coupon_amount,
        sum(case when payment_method = ''bank_transfer'' then amount else 0 end) as bank_transfer_amount,
        sum(case when payment_method = ''gift_card'' then amount else 0 end) as gift_card_amount,
        sum(amount) as total_amount

    from payments

    group by order_id

),

final as (

    select
        orders.order_id,
        orders.customer_id,
        orders.order_date,
        orders.status,

        order_payments.credit_card_amount,

        order_payments.coupon_amount,

        order_payments.bank_transfer_amount,

        order_payments.gift_card_amount,

        order_payments.total_amount as amount

    from orders


    left join order_payments
        on orders.order_id = order_payments.order_id

)

select * from final
    ');

   SELECT * INTO "sqlsampledatastack"."dbo"."orders__dbt_tmp" FROM
    "sqlsampledatastack"."dbo"."orders__dbt_tmp_temp_view"

   
   
  USE [sqlsampledatastack];
  if object_id ('"dbo"."orders__dbt_tmp_temp_view"','V') is not null
      begin
      drop view "dbo"."orders__dbt_tmp_temp_view"
      end

    
   use [sqlsampledatastack];
  if EXISTS (
        SELECT * FROM
        sys.indexes WHERE name = 'dbo_orders__dbt_tmp_cci'
        AND object_id=object_id('dbo_orders__dbt_tmp')
    )
  DROP index dbo.orders__dbt_tmp.dbo_orders__dbt_tmp_cci
  CREATE CLUSTERED COLUMNSTORE INDEX dbo_orders__dbt_tmp_cci
    ON dbo.orders__dbt_tmp

   

