\set ON_ERROR_STOP on
BEGIN;

\i 'sql/schema_olist.sql'

\set csvdir 'C:/Users/nikak/OneDrive/Desktop/project/dataset'
\echo Using csvdir= :csvdir

\copy olist.customers  FROM 'C:/Users/nikak/OneDrive/Desktop/project/dataset/olist_customers_dataset.csv'  CSV HEADER ENCODING 'UTF8';
\copy olist.sellers    FROM 'C:/Users/nikak/OneDrive/Desktop/project/dataset/olist_sellers_dataset.csv'    CSV HEADER ENCODING 'UTF8';
\copy olist.geolocation FROM 'C:/Users/nikak/OneDrive/Desktop/project/dataset/olist_geolocation_dataset.csv' CSV HEADER ENCODING 'UTF8';
\copy olist.products   FROM 'C:/Users/nikak/OneDrive/Desktop/project/dataset/olist_products_dataset.csv'   CSV HEADER ENCODING 'UTF8';
\copy olist.product_category_name_translation FROM 'C:/Users/nikak/OneDrive/Desktop/project/dataset/product_category_name_translation.csv' CSV HEADER ENCODING 'UTF8';
\copy olist.orders     FROM 'C:/Users/nikak/OneDrive/Desktop/project/dataset/olist_orders_dataset.csv'     CSV HEADER ENCODING 'UTF8';
\copy olist.order_items FROM 'C:/Users/nikak/OneDrive/Desktop/project/dataset/olist_order_items_dataset.csv' CSV HEADER ENCODING 'UTF8';
\copy olist.order_payments FROM 'C:/Users/nikak/OneDrive/Desktop/project/dataset/olist_order_payments_dataset.csv' CSV HEADER ENCODING 'UTF8';

COMMIT;

