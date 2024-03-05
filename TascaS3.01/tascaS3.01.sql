# Nivell 1

##  Exercici 1

/** La teva tasca és dissenyar i crear una taula anomenada "credit_*card" que emmagatzemi detalls 
crucials sobre les targetes de crèdit. La nova taula ha de ser capaç d'identificar de manera única 
cada targeta i establir una relació adequada amb les altres dues taules ("transaction" i "company"). 
Després de crear la taula serà necessari que ingressis la informació del document denominat 
"dades_introduir_credit". Recorda mostrar el diagrama i realitzar una breu descripció d'aquest. **/

-- Estructura de la nova taula
 CREATE TABLE IF NOT EXISTS credit_card (
        id VARCHAR(15) PRIMARY KEY REFERENCES transaction(credit_card_id), -- credit_card_id from transaction
        iban VARCHAR(50),
        pan VARCHAR(30),
        pin VARCHAR(4),
        cvv VARCHAR(3),
        expiring_date VARCHAR(10) -- Entenc que les dates no segueixen el format ISO. Millor utilitzar VARCHAR que DATE?
    );
    
-- Introdueixo les dades del document "datos_introducir_user" i creo el diagrama. 
SELECT * FROM credit_card;

-- He intentat afegir "FOREIGN KEY (id) REFERENCES transaction(credit_card_id)", però donava error

-- Entenc que falta la clau forana i crear un índex a "transaction".
ALTER TABLE credit_card
ADD FOREIGN KEY (id) REFERENCES transaction(credit_card_id); -- Segueix donant error "missing index"

-- Correcció: creo l'índex i modifico la taula credit_card
CREATE INDEX idx_credit_card_id ON transaction(credit_card_id);
ALTER TABLE credit_card
ADD FOREIGN KEY (id) REFERENCES transaction(credit_card_id);

## Exercici 2

/** El departament de Recursos Humans ha identificat un error en el número de compte de l'usuari amb 
el: id CcU-2938. Es requereix actualitzar la informació que identifica un compte bancari a nivell 
internacional (identificat com "IBAN"): TR323456312213576817699999. Recorda mostrar que el canvi es va realitzar. **/

SELECT * FROM credit_card
WHERE id = "CcU-2938"; -- Busco l'id

UPDATE credit_card
SET iban = "TR323456312213576817699999"
WHERE id = "CcU-2938"; -- Faig el canvi i executo de nou l'ordre de dalt per comprovar-ho

## Exercici 3

/** En la taula "transaction" ingressa un nou usuari amb la següent informació:
Id 					108B1D1D-5B23-A76C-55EF-C568E49A99DD
credit_card_id 		CcU-9999
company_id 			b-9999
user_id 			9999
lat 				829.999
longitude 			-117.999
amount 				111.11
declined 			0
**/

INSERT INTO transaction(id, credit_card_id, company_id, user_id, lat, longitude, amount, declined) 
VALUES ('108B1D1D-5B23-A76C-55EF-C568E49A99DD', 'CcU-9999', 'b-9999', '9999', '829.999', '-117.999', '111.11', '0');
-- Dona error ja que hi ha una clau forana a "company_id"

SELECT * FROM company
WHERE id = "b-9999"; -- Entenc que el problema és que no existeix cap companyia b-9999

INSERT INTO company(id) 
VALUES ('b-9999'); -- Introdueixo la companyia a la taula "company" i torno a executar l'ordre de dalt. Ara funciona.

SELECT * FROM transaction
WHERE company_id = "b-9999";


## Exercici 4

/** Des de recursos humans et sol·liciten eliminar la columna "pan" de la taula credit_*card. 
Recorda mostrar el canvi realitzat. **/

SELECT * FROM credit_card;

ALTER TABLE credit_card
DROP COLUMN pan; -- Elimino la columna i torno a executar l'ordre de dalt per comprovar-ho.

# Nivell 2

## Exercici 1

/** Elimina el registre amb id  02C6201E-D90A-1859-B4EE-*88D2986D3B02 de la base de dades. **/

SELECT * FROM transaction
WHERE id LIKE "%02C6201E%"; -- Busco l'id

-- Elimino el registre
DELETE FROM transaction
WHERE id = "02C6201E-D90A-1859-B4EE-88D2986D3B02";
-- No deixa 
SET foreign_key_checks = 0; -- Elimino les resticcions de clau forana
DELETE FROM transaction
WHERE id = "02C6201E-D90A-1859-B4EE-88D2986D3B02"; -- Ara sí
SET foreign_key_checks = 1; -- Reestableixo les comprovacions

## Exercici 2

/** La secció de màrqueting desitja tenir accés a informació específica per a realitzar anàlisi 
i estratègies efectives. S'ha sol·licitat crear una vista que proporcioni detalls clau sobre les 
companyies i les seves transaccions. Serà necessària que creïs una vista anomenada VistaMarketing 
que contingui la següent informació: Nom de la companyia. Telèfon de contacte. País de residència. 
Mitjana de compra realitzat per cada companyia. Presenta la vista creada, ordenant les dades de 
major a menor mitjana de compra. **/


CREATE VIEW VistaMarketing AS
SELECT company_name, phone, country, AVG(amount) AS avg_comp_amount
FROM transactions.company
INNER JOIN transactions.transaction
ON  company.id = transaction.company_id
GROUP BY company_id
ORDER BY avg_comp_amount DESC;

SELECT * FROM VistaMarketing; -- Visualitzem els resultats.
-- També podria haver creat la vista sense ORDER BY i usar-lo després al SELECT

## Exercici 3

/** Filtra la vista VistaMarketing per a mostrar només les companyies que tenen el seu país de 
residència en "Germany" **/

SELECT *
FROM VistaMarketing
WHERE country = "Germany"; 

# Nivell 3

## Exercici 1

/** La setmana vinent tindràs una nova reunió amb els gerents de màrqueting. Un company del teu equip 
va realitzar modificacions en la base de dades, però no recorda com les va realitzar. Et demana que 
l'ajudis a deixar els comandos executats per a obtenir les següents modificacions (s'espera que 
realitzin 6 canvis): **/

-- Taula transaction: res
-- Taula company: eliminar camp website (1)
SELECT * FROM company;

ALTER TABLE company
DROP COLUMN website; -- Elimino columna i torno a fer SELECT per comprovar-ho.

-- Taula user: canviar nom taula a data_user (2), columna email a personal_email (3)

RENAME TABLE user TO data_user;

ALTER TABLE data_user 
RENAME COLUMN email TO personal_email;

-- Taula credit_card: canviar id a VARCHAR(20) en comptes de 15 -afecta altres taules? (4), cvv a INT (5) i afegir fecha_actual DATE (6)

ALTER TABLE credit_card
MODIFY COLUMN id VARCHAR(20); 

ALTER TABLE credit_card
MODIFY COLUMN cvv INT; 

ALTER TABLE company
ADD COLUMN fecha_actual DATE;  -- També es podria posar en una sola ordre ALTER TABLE etc.

-- Entenc que seria recomanable igualar els tipus de dades relacionades a diferents taules, per a no tenir problemes.

/** Recordatori
En aquesta activitat, és necessari que descriguis el "pas a pas" de les tasques realitzades. És important 
realitzar descripcions senzilles, simples i fàcils de comprendre. Per a realitzar aquesta activitat hauràs 
de treballar amb els arxius denominats "estructura_dades_user" i "dades_introduir_user" **/

## Exercici 2

/** L'empresa també et sol·licita crear una vista anomenada "InformeTecnico" que contingui la següent informació:

    ID de la transacció
    Nom de l'usuari/ària
    Cognom de l'usuari/ària
    IBAN de la targeta de crèdit usada.
    Nom de la companyia de la transacció realitzada.
    Assegura't d'incloure informació rellevant de totes dues taules i utilitza àlies per a canviar de nom columnes segons sigui necessari.

Mostra els resultats de la vista, ordena els resultats de manera descendent en funció de la variable ID de transaction. **/

CREATE VIEW InformeTecnico AS
SELECT transaction.id AS transaction_id, 
data_user.name AS user_name, 
data_user.surname AS user_surname, 
credit_card.iban AS credit_card_iban, 
company.company_name 
FROM transaction
INNER JOIN company
ON  transaction.company_id = company.id
INNER JOIN credit_card
ON transaction.credit_card_id = credit_card.id
INNER JOIN data_user
ON transaction.user_id = data_user.id;

SELECT * FROM InformeTecnico
ORDER BY transaction_id DESC;