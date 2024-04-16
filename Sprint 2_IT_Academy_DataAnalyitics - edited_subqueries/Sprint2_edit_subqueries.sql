/* IT Academy - Data Analytics 
Josselyn Jumpa

--Sprint2 --

NIVEL 1

Ejercicio 1

Mostra totes les transaccions realitzades per empreses d'Alemanya. */

use transactions;
SELECT *
FROM transaction
WHERE company_id IN (

SELECT id
FROM company
WHERE country = "Germany");

/* 

Ejercicio 2

Màrqueting està preparant alguns informes de tancaments de gestió, 
et demanen que els passis un llistat de les empreses que han realitzat transaccions 
per una suma superior a la mitjana de totes les transaccions. */

-- Query principal para obtener el nombre de las compañías
SELECT company_name
FROM company
WHERE id IN(
-- Subquery 2: company_id de aquellas transacciones mayores a la media
SELECT company_id
FROM transaction
WHERE amount > 
-- Subquery 1: promedio importe transacciones de todas la compañías
(SELECT AVG(amount)
FROM transaction))
-- Ordenar alfabéticamente 
ORDER BY company_name ASC;

/* 

Ejercicio 3

El departament de comptabilitat va perdre la informació de les transaccions realitzades per una empresa, 
però no recorden el seu nom, només recorden que el seu nom iniciava amb la lletra c. 
Com els pots ajudar? Comenta-ho acompanyant-ho de la informació de les transaccions. */

-- CTE con información de las empresas cuyo nombre empieza por C
WITH companies_C AS (SELECT id, company_name
FROM company
WHERE company_name LIKE 'C%')
-- Seleccionamos toda la tabla transaction y la columna company_name de la CTE que hemos creado
SELECT transaction.*,companies_C.company_name
FROM transaction, companies_C
WHERE companies_C.id = transaction.company_id; -- filtramos para evitar duplicados


/*

Ejercicio 4

Van eliminar del sistema les empreses que no tenen transaccions registrades, 
lliura el llistat d'aquestes empreses. */

use transactions;

-- company_id presente en la tabla transaction que no se encuentra en la tabla company

SELECT DISTINCT company_id
FROM transaction
WHERE NOT EXISTS (SELECT id
FROM company);


-- Empresas en la tabla company que no tienen transacciones en la tabla transactions.

SELECT id, company_name
FROM company
WHERE id NOT IN (
SELECT DISTINCT company_id
FROM transaction);


/* NIVEL 2

Ejercicio 1

En la teva empresa, es planteja un nou projecte per a llançar algunes campanyes publicitàries 
per a fer competència a la companyia Non institute. 
Per a això, et demanen la llista de totes les transaccions realitzades per empreses 
que estan situades en el mateix país que aquesta companyia. */

use transactions;

-- Common table expression con dos subqueries
WITH country_company AS (
-- Subquery para encontrar los ID de empresas ubicadas en el mismo país que N.I.
SELECT id
FROM company
WHERE country = 
-- Subquery para averiguar el país de Non Institute
(SELECT country
FROM company
WHERE company_name = 'Non Institute'))
-- query principal con el inner join de la CTE y la tabla transaction
SELECT transaction.*
FROM transaction
INNER JOIN country_company
ON transaction.company_id = country_company.id;


-- Common table expression con dos subqueries
WITH country_company AS (
-- Subquery para encontrar los ID de empresas ubicadas en el mismo país que N.I.
SELECT id
FROM company
WHERE country = 
-- Subquery para averiguar el país de Non Institute
(SELECT country
FROM company
WHERE company_name = 'Non Institute'))
SELECT transaction.* -- query principal
FROM transaction, country_company
WHERE transaction.company_id = country_company.id;


/*Ejercicio 2

El departament de comptabilitat necessita que trobis l'empresa que ha realitzat 
la transacció de major suma en la base de dades.  */

use transactions;

-- Common Table Expression que incluye la subquery
WITH max_transaction AS (
-- localizamos la transacción de mayor importe y el company_id de la empresa
SELECT company_id, MAX(amount) as compra_mayor
FROM transaction
GROUP BY company_id
ORDER BY compra_mayor DESC
LIMIT 1)
-- Query principal para encontrar el nombre de la empresa. 
SELECT company_name, compra_mayor
FROM company, max_transaction
WHERE company.id = max_transaction.company_id;


/* NIVEL 3 

Ejercicio 1

S'estan establint els objectius de l'empresa per al següent trimestre, per la qual cosa necessiten 
una base sòlida per a avaluar el rendiment i mesurar l'èxit en els diferents mercats. 
Per a això, necessiten el llistat dels països la mitjana de transaccions dels quals 
sigui superior a la mitjana general. */


SELECT DISTINCT country, AVG(amount) AS promedio_país
FROM company, transaction
WHERE company.id = transaction.company_id
GROUP BY country
HAVING promedio_país > 
-- Subquery con la media general de las transacciones de todos los países
(SELECT AVG(amount)
FROM transaction)
ORDER BY promedio_país DESC;

/*Ejercicio 2

Necessitem optimitzar l'assignació dels recursos i dependrà de la capacitat operativa 
que es requereixi, per la qual cosa et demanen la informació sobre la quantitat de transaccions 
que realitzen les empreses, però el departament de recursos humans és exigent i vol 
un llistat de les empreses on especifiquis si tenen més de 4 transaccions o menys. */

use transactions;


-- Query para obtener el nombre de la compañía junto a su total de transacciones
SELECT company_name, total_transacciones,
-- Case statement para indicar 4 o más transacciones o menor o igual a 4
CASE WHEN total_transacciones > 4 THEN 'Más de 4 transacciones'
WHEN total_transacciones <= 4 THEN '4 transacciones o menos'
END AS indicador_transacciones
FROM company, 
-- Subquery donde contamos el total de transacciones por id de empresa
(SELECT company_id, COUNT(company_id) AS total_transacciones
FROM transaction
GROUP BY company_id
ORDER BY total_transacciones DESC) AS transacciones
WHERE company.id = transacciones.company_id;



