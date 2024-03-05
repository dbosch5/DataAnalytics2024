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

-- Taula tarjetes
CREATE TABLE IF NOT EXISTS database_1.credit_card (
	id VARCHAR(15) PRIMARY KEY,
	iban VARCHAR(50),
	pan VARCHAR(30),
	pin VARCHAR(4),
	cvv VARCHAR(3),
	expiring_date VARCHAR(10)
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

-- Introduïm les dades des dels CSV
-- No em deixa carregar arxius des d'una altra carpeta que no sigui la de:
SHOW VARIABLES LIKE "secure_file_priv";

-- Copio els arxius a C:\ProgramData\MySQL\MySQL Server 8.0\Uploads\
-- tampoc em deixa...

-- Companyies
LOAD DATA INFILE 'C:\ProgramData\MySQL\MySQL Server 8.0\Uploads\companies.csv'
INTO TABLE database_1.company
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


## Exercici 1

/** Realitza una subconsulta que mostri tots els usuaris amb més de 30 transaccions utilitzant almenys 2 taules. **/

## Exercici 2

/** Mostra la mitjana de la suma de transaccions per IBAN de les targetes de crèdit en la companyia Donec Ltd. 
utilitzant almenys 2 taules. **/

# Nivell 2

/** Crea una nova taula que reflecteixi l'estat de les targetes de crèdit basat en si les últimes tres transaccions 
van ser declinades i genera la següent consulta: **/

## Exercici 1

/** Quantes targetes estan actives? **/

# Nivell 3

/** Crea una taula amb la qual puguem unir les dades del nou arxiu products.csv amb la base de dades creada, 
tenint en compte que des de transaction tens product_ids. Genera la següent consulta: **/

## Exercici 1

/** Necessitem conèixer el nombre de vegades que s'ha venut cada producte. **/