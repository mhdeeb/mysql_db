CALL add_person('John', 'Doe', 'here@there.com', '011-111-1111', @person_id);

CALL add_customer('2017-06-15', '123 Main St', 'Anytown', 'NY', '12345', @person_id, NULL, NULL, NULL, NULL, @customer_id);

CALL add_product_category('Electronics', 'Electronic devices');

-- NEEDS NORMALIZATION
CALL add_campaign('Summer Sale', '2017-06-15', '2017-09-15', 10000.00, 'Summer Sale Campaign', @campaign_id);

CALL add_sales_rep('North Region', @person2_id, 'John2', 'Doe2', 'here2@there.com', '022-111-1111', @sales_rep_id);

CALL add_connection(@person_id, @person2_id);

-- NEEDS NORMALIZATION
CALL add_product('Electronics', 'Laptop', 1000.00, 10, 0, 'Laptop description', @product_id);

-- NEEDS NORMALIZATION
CALL add_order(@customer_id, NULL, NULL, '2025-06-15 13:00:00', @order_id);

-- NEEDS NORMALIZATION
CALL add_customer_interaction(@customer_id, @sales_rep_id, NULL, 'phone call', 'Details', 'Outcome', @customer_interaction_id);

-- NEEDS NORMALIZATION
CALL add_purchase(@order_id, @product_id, 3);