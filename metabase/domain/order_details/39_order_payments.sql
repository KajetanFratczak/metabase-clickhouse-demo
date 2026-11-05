-- Płatności za zamówienie: kolejne płatności z metodą, liczbą rat i kwotą.
-- Zmienne: zamowienie (Text, wymagana, domyślnie fb662b5ba362e72d75d486ca4d29c9e4).
SELECT
	olist_raw.payments.payment_sequential AS numer_platnosci,
	olist_raw.payments.payment_type AS metoda_platnosci,
	olist_raw.payments.payment_installments AS liczba_rat,
	olist_raw.payments.payment_value AS wartosc_platnosci
FROM 
	olist_raw.payments
WHERE olist_raw.payments.order_id = {{zamowienie}}
ORDER BY numer_platnosci;