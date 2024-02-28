# Nivell 1

## Exercici 1

/** A partir dels documents adjunts (estructura_dades i dades_introduir), importa les dues taules. 
Mostra les característiques principals de l'esquema creat i explica les diferents taules i variables que existeixen. 
Assegura't d'incloure un diagrama que il·lustri la relació entre les diferents taules i variables. **/

SHOW DATABASES;  -- Un cop executats els scripts adjunts, ens mostra que la base de dades existeix
SELECT * FROM transactions.company; -- Ens mostra la taula "company"
SELECT * FROM transactions.transaction; -- Ens mostra la taula "transaction"

## Exercici 2

/** Realitza la següent consulta: Has d'obtenir el nom, email i país de cada companyia, 
ordena les dades en funció del nom de les companyies. **/

SELECT company_name, email, country FROM transactions.company ORDER BY company_name;

## Exercici 3

/** Des de la secció de màrqueting et sol·liciten que els passis un llistat dels països que estan fent compres. **/

SELECT DISTINCT country FROM transactions.company 
INNER JOIN transactions.transaction
ON company.id = transaction.company_id
WHERE EXISTS (SELECT company_id FROM transactions.transaction); -- El where és redundant?

SELECT DISTINCT country FROM transactions.company 
INNER JOIN transactions.transaction
ON company.id = transaction.company_id; -- Millor?

## Exercici 4

/** Des de màrqueting també volen saber des de quants països es realitzen les compres. **/

SELECT COUNT(DISTINCT country) AS num_countries FROM transactions.company 
INNER JOIN transactions.transaction
ON company.id = transaction.company_id;

## Exercici 5

/** El teu cap identifica un error amb la companyia que té id 'b-2354'. Per tant, 
et sol·licita que li indiquis el país i nom de companyia d'aquest id. **/

SELECT country, company_name FROM transactions.company WHERE id = "b-2354";

## Exercici 6

/** A més, el teu cap et sol·licita que indiquis quina és la companyia amb major despesa mitjana. **/

SELECT AVG(amount) AS avg_comp_amount, company_id FROM transactions.transaction 
GROUP BY company_id ORDER BY avg_comp_amount DESC LIMIT 1; -- La companyia amb major despesa mitjana

SELECT DISTINCT company_name FROM transactions.company 
INNER JOIN transactions.transaction
ON company.id = transaction.company_id
WHERE company_id = "b-2398"; -- El nom d'aquesta companyia.

-- Millor en una sola consulta.
SELECT AVG(transaction.amount) AS avg_comp_amount, company.company_name 
FROM transactions.transaction 
INNER JOIN transactions.company
ON  transaction.company_id = company.id 
GROUP BY company_id ORDER BY avg_comp_amount DESC LIMIT 1; -- Potser es pot millorar.

# Nivell 2

## Exercici 1

/** El teu cap està redactant un informe de tancament de l'any i et sol·licita que li enviïs 
informació rellevant per al document. Per a això et sol·licita verificar si en la base de dades 
existeixen companyies amb identificadors (id) duplicats. **/

SELECT id, COUNT(id) FROM transactions.company
GROUP BY id
HAVING COUNT(id) > 1;

-- Per comprovar, ordeno les identificacions
SELECT id FROM transactions.company
ORDER BY id;
-- També puc comptar les id
SELECT COUNT(id) FROM transactions.company
ORDER BY id;
-- I veure si és diferent del resulta amb dictinct
SELECT DISTINCT COUNT(id) FROM transactions.company
ORDER BY id;
-- Per tant, no, no hi ha identificadors duplicats

## Exercici 2

/** En quin dia es van realitzar les cinc vendes més costoses? Mostra la data de la transacció i la 
sumatòria de la quantitat de diners. **/

SELECT timestamp, SUM(amount) AS sum_amount FROM transactions.transaction
GROUP BY timestamp
ORDER BY sum_amount DESC LIMIT 5;

## Exercici 3

/** En quin dia es van realitzar les cinc vendes de menor valor? Mostra la data de la transacció i la 
sumatòria de la quantitat de diners. **/

SELECT timestamp, SUM(amount) AS sum_amount FROM transactions.transaction
GROUP BY timestamp
ORDER BY sum_amount ASC LIMIT 5; -- Es pot treure l'ASC, ja que és el valor per defecte

## Exercici 4

/** Quina és la mitjana de despesa per país? Presenta els resultats ordenats de major a menor mitjà. **/

SELECT AVG(transaction.amount) AS avg_country_amount, company.country 
FROM transactions.transaction 
INNER JOIN transactions.company
ON  transaction.company_id = company.id 
GROUP BY country ORDER BY avg_country_amount DESC;

# Nivell 3

## Exercici 1

/** Presenta el nom, telèfon i país de les companyies, juntament amb la quantitat total gastada, 
d'aquelles que van realitzar transaccions amb una despesa compresa entre 100 i 200 euros. 
Ordena els resultats de major a menor quantitat gastada. **/

SELECT company_name, phone, country FROM transactions.company;

SELECT SUM(amount) AS total_amount, company_id FROM transactions.transaction
WHERE amount BETWEEN 100 AND 200
GROUP BY company_id
ORDER BY total_amount DESC;

-- En una sola consulta
SELECT company.company_name, company.phone, company.country, SUM(transaction.amount) AS total_amount 
FROM transactions.company
INNER JOIN transactions.transaction
ON  company.id = transaction.company_id
WHERE amount BETWEEN 100 AND 200
GROUP BY company_id
ORDER BY total_amount DESC;

## Exercici 2

/** Indica el nom de les companyies que van fer compres el 16 de març del 2022, 28 de febrer del 2022 i
13 de febrer del 2022. **/

SELECT company.company_name, transaction.timestamp FROM transactions.company 
INNER JOIN transactions.transaction
ON  company.id = transaction.company_id
WHERE transaction.timestamp LIKE "2022-03-16%" 
OR transaction.timestamp LIKE "2022-02-28%"
OR transaction.timestamp LIKE "2022-02-13%"
ORDER BY timestamp ASC; 

-- Si només volem el nom de les empreses (el que es demana)
SELECT DISTINCT company.company_name FROM transactions.company 
INNER JOIN transactions.transaction
ON  company.id = transaction.company_id
WHERE transaction.timestamp LIKE "2022-03-16%" 
OR transaction.timestamp LIKE "2022-02-28%"
OR transaction.timestamp LIKE "2022-02-13%"
ORDER BY company_name; 

