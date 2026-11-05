-- Opinie z zamówienia: ocena i komentarz; daty to wysłanie ankiety i odpowiedź klienta. review_id nie jest unikalne między zamówieniami.
-- Zmienne: zamowienie (Text, wymagana, domyślnie fb662b5ba362e72d75d486ca4d29c9e4).
SELECT
	olist_raw.reviews.review_id AS id_opinii,
	olist_raw.reviews.review_score AS ocena,
	olist_raw.reviews.review_comment_title AS tytul,
	olist_raw.reviews.review_comment_message AS tresc,
	olist_raw.reviews.review_creation_date AS data_utworzenia,
	olist_raw.reviews.review_answer_timestamp AS data_odpowiedzi
FROM 
	olist_raw.reviews
WHERE olist_raw.reviews.order_id = {{zamowienie}}
ORDER BY data_utworzenia, id_opinii;