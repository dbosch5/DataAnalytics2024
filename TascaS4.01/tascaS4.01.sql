# Nivell 1

/** Descàrrega els arxius CSV, estudia'ls i dissenya una base de dades amb un esquema d'estrella que contingui, 
almenys 4 taules de les quals puguis realitzar les següents consultes: **/

-- Creem la base de dades i les taules
CREATE DATABASE IF NOT EXISTS database_1;
USE database_1;

-- M´ha sembla més senzill crear primer les taules secundàries
-- i després la taula principal amb les claus foranes
-- així m'estalvio haver de crear els índex

-- Taula companyies
CREATE TABLE IF NOT EXISTS database_1.company (
	id VARCHAR(15) PRIMARY KEY,
	company_name VARCHAR(255),
	phone VARCHAR(15),
	email VARCHAR(100),
	country VARCHAR(100),
	website VARCHAR(255)
    );

-- Taula usuaris
CREATE TABLE IF NOT EXISTS database_1.user (
        id INT PRIMARY KEY,
        name VARCHAR(100),
        surname VARCHAR(100),
        phone VARCHAR(150),
        email VARCHAR(150),
        birth_date VARCHAR(100),
        country VARCHAR(150),
        city VARCHAR(150),
        postal_code VARCHAR(100),
        address VARCHAR(255)
    );
   
-- Taula tarjetes
CREATE TABLE IF NOT EXISTS database_1.credit_card (
	id VARCHAR(15) PRIMARY KEY,
    user_id INT REFERENCES user(id),
	iban VARCHAR(50),
	pan VARCHAR(30),
	pin VARCHAR(4),
	cvv VARCHAR(3),
    track1 VARCHAR(255),
    track2 VARCHAR(255),
	expiring_date DATE -- He hagut de modificar el CSV per ajuustar les dates a YYYY-MM-DD
    );


-- Taula productes
CREATE TABLE IF NOT EXISTS database_1.product (
	id INT PRIMARY KEY,
    product_name VARCHAR(100),
    price DECIMAL(10, 2),
    colour VARCHAR(10),
    weight DECIMAL(5,2),
    warehouse_id VARCHAR(10)
);

-- Taula principal: transaccions
CREATE TABLE IF NOT EXISTS database_1.transaction (
	id VARCHAR(255) PRIMARY KEY,
	credit_card_id VARCHAR(15),
	company_id VARCHAR(20), 
    timestamp TIMESTAMP,
    amount DECIMAL(10, 2),
    declined BOOLEAN,
    product_id INT,
	user_id INT,
	lat FLOAT,
	longitude FLOAT,
    FOREIGN KEY (credit_card_id) REFERENCES credit_card(id),
    FOREIGN KEY (company_id) REFERENCES company(id),
    FOREIGN KEY (product_id) REFERENCES product(id),
    FOREIGN KEY (user_id) REFERENCES user(id)
    );

-- Introduïr dades

/**  
Introduïm les dades des dels CSV

No em deixa carregar arxius des d'una altra carpeta que no sigui la de:
SHOW VARIABLES LIKE "secure_file_priv";

Copio els arxius a C:\ProgramData\MySQL\MySQL Server 8.0\Uploads\
Tampoc em deixa...

Utilitzo el meu estimat editor de text Vim i modifico els arxius CSV
L'ordre per l'arxiu "companies" és la següent. La primera introdueix INSERT.. al principi de cada línia
:%s/^/INSERT INTO company (id, company_name, phone, email, country, website) VALUES ( /
I la següent afegeix el tancament de parèntesis i punt i coma al final de cada línia.
:%s/$/);/
Guardo el CSV modificat com a SQL

Finalment, calia modificar més coses i he utilitzat un script en línia 
(https://www.convertsimple.com/convert-csv-to-sql-insert-statement/)

Executo els scripts per introduïr dades.

En el cas de les dades de producte, utilitzo el Vim per eliminar el símbol de dòlar
També al CSV de transaction, canvio els punts i comes per comes i altres modificacions.
En el cas de les targetes, he utilitzat el Sed de GNU des de bash amb la següent ordre per adaptar la data al format DATE:
cat introduir_credit_card.sql | sed -E 's/([0-9]{2})\/([0-9]{2})\/([0-9]{2})/20\3\-\1\-\2/' > introduir_credit_card_date_mod.sql
De manera que MM/DD/YY ha passat a YYYY-MM-DD. No he trobat cap altra manera des de SQL.
**/

## Exercici 1

/** Realitza una subconsulta que mostri tots els usuaris amb més de 30 transaccions utilitzant almenys 2 taules. **/

-- Transaccions per user
SELECT user_id, COUNT(user_id) AS num_transactions FROM transaction
GROUP BY user_id;

-- No hi ha usaris amb més de 30 transaccions.
SELECT user.id, user.name, user.surname, COUNT(transaction.user_id) AS num_transactions FROM database_1.user
INNER JOIN database_1.transaction
ON user.id = transaction.user_id
GROUP BY user_id
ORDER BY num_transactions DESC;

-- Si busquessim més de 25 transaccions...
SELECT user.id, user.name, user.surname, COUNT(transaction.user_id) AS num_transactions FROM database_1.user
INNER JOIN database_1.transaction
ON user.id = transaction.user_id
GROUP BY user_id
HAVING num_transactions > 25
ORDER BY num_transactions DESC;

-- En cas que la base de dades fos modificada, canviant el 25 pel 30 trobariem els resultats.

## Exercici 2

/** Mostra la mitjana de la suma de transaccions per IBAN de les targetes de crèdit en la companyia Donec Ltd. 
utilitzant almenys 2 taules. **/

-- Busco la companyia
SELECT * FROM company
WHERE company_name LIKE "Donec Ltd"; -- l'id és b-2242

-- Busco les transaccions i targetes
SELECT * FROM transaction
WHERE company_id = "b-2242"; -- Només en tenen una, la CcU-2973

-- Busco l'iban
SELECT * FROM credit_card
WHERE id = "CcU-2973"; -- És el 'PT87806228135092429456346'

-- La mitjana de les transaccions de la targeta
SELECT AVG(amount) AS avg_amount FROM transaction
WHERE credit_card_id = "CcU-2973";

-- La mitjana de la companyia Donec Ltd
SELECT AVG(amount) AS avg_amount FROM transaction
INNER JOIN company
ON company.id = transaction.company_id
WHERE company_id = (
SELECT id FROM company
WHERE company_name LIKE "Donec Ltd");


# Nivell 2

/** Crea una nova taula que reflecteixi l'estat de les targetes de crèdit basat en si les últimes tres transaccions 
van ser declinades i genera la següent consulta: **/

-- Targetes declinades i la seva data de caducitat
SELECT credit_card_id, declined, timestamp, expiring_date
FROM transaction
INNER JOIN credit_card
ON credit_card.id = transaction.credit_card_id
WHERE declined = 1
ORDER BY timestamp DESC;

-- Creem la taula
CREATE TABLE credit_card_state AS
SELECT credit_card_id, declined, timestamp, expiring_date
FROM transaction
INNER JOIN credit_card
ON credit_card.id = transaction.credit_card_id
WHERE declined = 1;

SELECT * FROM credit_card_state; -- Comprovem

## Exercici 1

/** Quantes targetes estan actives? **/

SELECT credit_card_id, expiring_date FROM credit_card_state;
SELECT CURRENT_DATE(); -- Millor que NOW(), ja que ens retorna la data en YYYY-MM-DD

-- Comparo la data de caducitat amb la data actual i mostro les que caduquen avui o més endavant
SELECT credit_card_id, expiring_date FROM credit_card_state
WHERE  expiring_date >= (SELECT CURRENT_DATE());

-- Faig recompte de les que estan actives
SELECT COUNT(*) AS num_cards_active
FROM (SELECT credit_card_id FROM credit_card_state
WHERE  expiring_date >= (SELECT CURRENT_DATE())) AS subconsulta;
-- No entenc molt bé perquè no funciona amb un sol àlias

-- Com explico més amunt, he hagut de convertir les dates a format DATE per poder comparar amb la data actual 

# Nivell 3

/** Crea una taula amb la qual puguem unir les dades del nou arxiu products.csv amb la base de dades creada, 
tenint en compte que des de transaction tens product_ids. Genera la següent consulta: **/

-- Ja ho he fet des del principi. 

## Exercici 1

/** Necessitem conèixer el nombre de vegades que s'ha venut cada producte. **/

SELECT product.id, product_name, COUNT(product_id) AS num_sales FROM transaction
INNER JOIN product
ON product.id = transaction.product_id
GROUP BY product_id
ORDER BY num_sales DESC;