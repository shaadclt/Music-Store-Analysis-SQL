/* Most employee based on job title */
SELECT * FROM employee
ORDER BY levels DESC
LIMIT 1

/* Countries with the most Invoices */
SELECT COUNT(*) AS c, billing_country from invoice
GROUP BY billing_country
ORDER BY c DESC

/* Top 3 values of total invoice */
SELECT total FROM invoice
ORDER BY total DESC
LIMIT 3

/* City which has the best customers for the store to throw a promotional Music Festival */
SELECT SUM(total) as invoice_total, billing_city FROM invoice
GROUP BY billing_city
ORDER BY invoice_total DESC

/* Best customer who has spent the most money. */
SELECT customer.customer_id, customer.first_name, customer.last_name, SUM(invoice.total) AS total 
FROM customer
JOIN invoice on customer.customer_id = invoice.customer_id
GROUP BY customer.customer_id
ORDER BY total DESC
LIMIT 1

/* Email, first name, last name, & Genre of all Rock Music listeners ordered alphabetically by email starting with A. */
SELECT DISTINCT email ,first_name, last_name, genre.name AS Genre
FROM customer
JOIN invoice ON invoice.customer_id = customer.customer_id
JOIN invoice_line ON invoice_line.invoice_id = invoice.invoice_id
JOIN track ON track.track_id = invoice_line.track_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
ORDER BY email;

/* Artists who have written the most rock music in our dataset. */
SELECT artist.artist_id, artist.name, COUNT(artist.artist_id) AS number_of_songs
FROM track
JOIN album ON album.album_id = track.album_id
JOIN artist ON artist.artist_id = album.artist_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
GROUP BY artist.artist_id
ORDER BY number_of_songs DESC
LIMIT 10

/* Track names that have a song length longer than the average song length. */
SELECT name, milliseconds FROM track
WHERE milliseconds > (
	SELECT AVG(milliseconds) AS avg_track_length FROM track)
ORDER BY milliseconds DESC

/* Amount spent by each customer on artists. */
WITH best_selling_artist AS (
	SELECT artist.artist_id AS artist_id, artist.name AS artist_name, SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
	FROM invoice_line
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN album ON album.album_id = track.album_id
	JOIN artist ON artist.artist_id = album.artist_id
	GROUP BY 1
	ORDER BY 3 DESC
	LIMIT 1)
	
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC

/* Most popular music Genre for each country. */
WITH popular_genre AS (
	SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id,
		ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity)DESC) AS RowNo
		FROM invoice_line
			JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
			JOIN customer ON customer.customer_id = invoice.customer_id
			JOIN track ON track.track_id = invoice_line.track_id
			JOIN genre ON genre.genre_id = track.genre_id
			GROUP BY 2,3,4
			ORDER BY 2 ASC, 1 DESC)
SELECT * FROM popular_genre WHERE RowNo <= 1

/* Customer who has spent the most on music for each country. */
WITH Customer_with_country AS (
	SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
	ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo
	FROM invoice
	JOIN customer ON customer.customer_id = invoice.customer_id
	GROUP BY 1,2,3,4
	ORDER BY 4 ASC,5 DESC)
SELECT * FROM Customer_with_country WHERE RowNo <= 1





