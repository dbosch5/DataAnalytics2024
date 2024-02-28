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

-- FALTA ACABAR / NO ESTÁ BÉ
SELECT company_id 
FROM transactions.transaction
INNER JOIN transactions.company
ON transaction.company_id = company.id
WHERE NOT EXISTS (SELECT id FROM transaction.transaction);

# Nivell 2

## Exercici 1

/** En la teva empresa, es planteja un nou projecte per a llançar algunes campanyes publicitàries per a fer competència 
a la companyia senar institute. Per a això, et demanen la llista de totes les transaccions realitzades per empreses 
que estan situades en el mateix país que aquesta companyia. **/

## Exercici 2

/** El departament de comptabilitat necessita que trobis l'empresa que ha realitzat la transacció de major suma en la base de dades. **/

# Nivell 3
## Exercici 1

/** S'estan establint els objectius de l'empresa per al següent trimestre, per la qual cosa necessiten una base sòlida per a 
avaluar el rendiment i mesurar l'èxit en els diferents mercats. Per a això, necessiten el llistat dels països la mitjana de transaccions 
dels quals sigui superior a la mitjana general. **/

## Exercici 2

/** Necessitem optimitzar l'assignació dels recursos i dependrà de la capacitat operativa que es requereixi, per la qual cosa et 
demanen la informació sobre la quantitat de transaccions que realitzen les empreses, però el departament de recursos humans és 
exigent i vol un llistat de les empreses on especifiquis si tenen més de 4 transaccions o menys. **/
