-- Szczegóły zamówienia: dane zamówienia, klient, daty oraz czas dostawy (od zakupu) i opóźnienie w dniach. Wizualizacja Detail.
-- Zmienne: zamowienie (Text, wymagana, domyślnie fb662b5ba362e72d75d486ca4d29c9e4).
SELECT
	olist_raw.orders.order_id AS id_zamowienia,
	olist_raw.customers.customer_unique_id AS osoba,
	olist_raw.orders.order_status AS status,
	olist_raw.orders.order_purchase_timestamp AS data_zakupu,
	olist_raw.customers.customer_city AS miasto,
	olist_raw.customers.customer_state AS stan,
	olist_raw.orders.order_approved_at AS data_zatwierdzenia,
	olist_raw.orders.order_delivered_carrier_date AS przekazanie_przewoznikowi,
	olist_raw.orders.order_delivered_customer_date AS data_dostarczenia,
	olist_raw.orders.order_estimated_delivery_date AS planowana_dostawa,
	dateDiff('day', data_zakupu, data_dostarczenia) AS czas_dostawy,
	dateDiff('day', planowana_dostawa, data_dostarczenia) AS opoznienie_dni 
FROM 
	olist_raw.orders
LEFT JOIN olist_raw.customers
	ON olist_raw.orders.customer_id = olist_raw.customers.customer_id
WHERE olist_raw.orders.order_id = {{zamowienie}};