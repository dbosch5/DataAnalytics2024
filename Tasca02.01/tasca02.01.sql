# Nivell 1

## Exercici 1

/** Mostra totes les transaccions realitzades per empreses d'Alemanya. **/

SELECT transaction.* 
FROM transactions.transaction
INNER JOIN transactions.company
ON  transaction.company_id = company.id
WHERE company.country = "Germany";

## Exercici 2

/** Màrqueting està preparant alguns informes de tancaments de gestió, et demanen que els passis un llistat 
de les empreses que han realitzat transaccions per una suma superior a la mitjana de totes les transaccions. **/

SELECT DISTINCT company_name FROM transactions.company
INNER JOIN transactions.transaction
ON  company.id = transaction.company_id
WHERE amount > 
(SELECT AVG(amount) FROM transactions.transaction)
ORDER BY company_name;

## Exercici 3

/** El departament de comptabilitat va perdre la informació de les transaccions realitzades per una empresa, 
però no recorden el seu nom, només recorden que el seu nom iniciava amb la lletra c. Com els pots ajudar? 
Comenta-ho acompanyant-ho de la informació de les transaccions. **/

SELECT company_name, transaction.* -- Mostrem el nom i la info de les transaccions.
FROM transactions.company
INNER JOIN transactions.transaction
ON  company.id = transaction.company_id
WHERE company_name LIKE "C%"; -- Empreses que el seu nom comença per c.
-- Entenc que és millor no usar DISTINCT, ja que la informació de cada transacció pot ser rellevant.

## Exercici 4

/** Van eliminar del sistema les empreses que no tenen transaccions registrades, lliura el llistat d'aquestes empreses. **/

-- He provat diferents coses:
SELECT DISTINCT company_name, company.id
FROM transactions.company
INNER JOIN transactions.transaction
ON transaction.company_id = company.id
WHERE NOT EXISTS (SELECT transaction.company_id FROM transactions.transaction);

SELECT id FROM transactions.company
WHERE NOT EXISTS (SELECT company_id FROM transactions.transaction
WHERE transaction.company_id = company.id);

SELECT company_id FROM transactions.transaction
INNER JOIN transactions.company
ON transaction.company_id = company.id
WHERE transaction.company_id != company.id;

-- Aquesta crec que és la correcta, però no dona resultats
SELECT DISTINCT company_name FROM transactions.company
INNER JOIN transactions.transaction
ON transaction.company_id = company.id
WHERE NOT EXISTS (SELECT id FROM transactions.company
WHERE transaction.company_id = company.id);

-- Entenc que si les empreses no tenen transaccions registrades i han estat esborrades del llistat "company" no es poden recuperar.

# Nivell 2

## Exercici 1

/** En la teva empresa, es planteja un nou projecte per a llançar algunes campanyes publicitàries per a fer competència 
a la companyia senar institute. Per a això, et demanen la llista de totes les transaccions realitzades per empreses 
que estan situades en el mateix país que aquesta companyia. **/

-- No apareix el, "Senar Institute", suposo que és una errada de traducció automàtica. Busco per "Institute".
SELECT DISTINCT country, company_name FROM transactions.company
WHERE company_name LIKE "%Institute";

-- Suposo que s'ha traduït "non" del castellà com a "senar"
SELECT transaction.*, company.country FROM transactions.transaction -- El "country" només per comprovar
INNER JOIN transactions.company
ON transaction.company_id = company.id
WHERE company.country = (SELECT company.country FROM transactions.company 
WHERE company_name = "Non Institute");

## Exercici 2

/** El departament de comptabilitat necessita que trobis l'empresa que ha realitzat la transacció de major suma en la base de dades. **/

-- Busco la transacció més gran
SELECT transaction.amount, transaction.company_id FROM transactions.transaction
ORDER BY amount DESC LIMIT 1;

-- Millor
SELECT MAX(transaction.amount) FROM transactions.transaction;

-- Ordre completa
SELECT company.company_name FROM transactions.transaction
INNER JOIN transactions.company
ON transaction.company_id = company.id
WHERE transaction.amount = (SELECT MAX(transaction.amount) FROM transactions.transaction);

# Nivell 3

## Exercici 1

/** S'estan establint els objectius de l'empresa per al següent trimestre, per la qual cosa necessiten una base sòlida per a 
avaluar el rendiment i mesurar l'èxit en els diferents mercats. Per a això, necessiten el llistat dels països la mitjana de transaccions 
dels quals sigui superior a la mitjana general. **/

-- Busco la mitjana de despesa
SELECT AVG(transaction.amount) AS avg_amount 
FROM transactions.transaction; -- 256.735520

-- Busco la mitjana dels països (de la Tasca 01.01)
SELECT AVG(transaction.amount) AS avg_country_amount, company.country
FROM transactions.transaction
INNER JOIN transactions.company
ON  transaction.company_id = company.id 
GROUP BY country ORDER BY avg_country_amount DESC;

-- Ordre completa
SELECT AVG(transaction.amount) AS avg_country_amount, company.country
FROM transactions.transaction
INNER JOIN transactions.company
ON  transaction.company_id = company.id 
GROUP BY country
HAVING avg_country_amount > (SELECT AVG(transaction.amount) FROM transactions.transaction);

## Exercici 2

/** Necessitem optimitzar l'assignació dels recursos i dependrà de la capacitat operativa que es requereixi, per la qual cosa et 
demanen la informació sobre la quantitat de transaccions que realitzen les empreses, però el departament de recursos humans és 
exigent i vol un llistat de les empreses on especifiquis si tenen més de 4 transaccions o menys. **/

-- Més de 4 transaccions
SELECT transaction.company_id, company.company_name FROM transactions.transaction
INNER JOIN transactions.company
ON  transaction.company_id = company.id 
GROUP BY company_id
HAVING COUNT(transaction.id) > 4;

-- Menys de 4
SELECT transaction.company_id, company.company_name FROM transactions.transaction
INNER JOIN transactions.company
ON  transaction.company_id = company.id 
GROUP BY company_id
HAVING COUNT(transaction.id) < 4;

-- Columna amb número de transaccions 
SELECT company.company_name, COUNT(transaction.id) AS num_trans FROM transactions.transaction
INNER JOIN transactions.company
ON  transaction.company_id = company.id 
GROUP BY company_id
ORDER BY num_trans DESC;

-- Ordre completa
SELECT company.company_name, IF (COUNT(transaction.id) > 4, "Yes", "No") AS greater_4
FROM transactions.transaction
INNER JOIN transactions.company
ON  transaction.company_id = company.id 
GROUP BY company_id
ORDER BY greater_4 DESC;