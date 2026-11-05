-- Przejdź do osoby: osoba (customer_unique_id) z zamówienia. Karta Table, bo kliknięcie pojedynczej kolumny działa tylko w tabelach; otwiera zamówienia tej osoby.
-- Zmienne: zamowienie (Text, wymagana, domyślnie fb662b5ba362e72d75d486ca4d29c9e4).
SELECT
	olist_raw.customers.customer_unique_id AS osoba
FROM 
	olist_raw.orders
LEFT JOIN olist_raw.customers
	ON olist_raw.orders.customer_id = olist_raw.customers.customer_id
WHERE olist_raw.orders.order_id = {{zamowienie}};