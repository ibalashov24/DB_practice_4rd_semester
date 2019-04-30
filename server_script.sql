-------------------------------------
-------- Процедуры и функции --------
-------------------------------------

------------------------------------------------
--- Обработка нового заказа на сырьё
------------------------------------------------

CREATE OR REPLACE FUNCTION PlaceRawMaterialOrder
(
	material CHARACTER VARYING, 
	supplier_name CHARACTER VARYING, 
	volume NUMERIC, 
	supply_deadline DATE
)
RETURNS void AS $$
BEGIN
INSERT INTO Material_Order(material_order_id, supplier_id, volume, is_done, deadline)
	VALUES 
	(
		(SELECT MAX(material_order_id)+1 FROM Material_Order),
		(SELECT supplier_id FROM Supplier, Material_Type 
			WHERE Supplier.Name = supplier_name
			AND Material_Type.Material_Type_ID = Supplier.Material_Type_ID
			AND Material_Type.Name = material
			LIMIT 1),
		volume,
		0,
		supply_deadline
	);
END;
$$ LANGUAGE plpgsql;

--------- Пример вызова ---------

SELECT PlaceRawMaterialOrder
(
	CAST('Клубничный джем' AS CHARACTER VARYING), 
	CAST('Совхоз им. Ленина' AS CHARACTER VARYING),
	10.0, 
	CAST('02-02-1999' AS DATE)
);


------------------------------------------------
--- Среднее количество заказываемого сырья каждого типа
------------------------------------------------

CREATE OR REPLACE FUNCTION GetAvgOrderNumber()
RETURNS TABLE (
	Material_Name	CHARACTER VARYING,
	Avg_Volume 	NUMERIC
) AS $$
BEGIN
RETURN QUERY
	SELECT Material_Type.name, AVG(COALESCE(Orders.Volume, 0)) AS Avg_Volume 
	FROM 
	Material_Type, 
		(SELECT * FROM Supplier LEFT JOIN Material_Order
		ON Supplier.Supplier_ID = Material_Order.Supplier_ID) AS Orders
	WHERE Material_Type.Material_Type_ID = Orders.Material_Type_ID
	GROUP BY Material_Type.name
	ORDER BY Avg_Volume DESC;
END;
$$ LANGUAGE plpgsql;

--------- Пример вызова ---------

SELECT * FROM GetAvgOrderNumber();

------------------------------------------------
--- Получение поставщика, который сможет продать нужное сырьё дешевле всех
------------------------------------------------

CREATE OR REPLACE FUNCTION GetCheapestSupplier(material_name CHARACTER VARYING)
RETURNS TABLE (
	Supplier_ID 	INT,
	Supplier_Name 	CHARACTER VARYING,
	Offer_Name 	CHARACTER VARYING,
	Price		NUMERIC
) AS $$
BEGIN
RETURN QUERY
	SELECT Supplier.Supplier_ID, Supplier.Name, Material_Type.Name, Supplier.Price FROM Supplier, Material_Type
	WHERE Material_Type.Material_Type_ID = Supplier.Material_Type_ID 
	AND Material_Type.Name = material_name
	ORDER BY Supplier.Price LIMIT 1;
END;
$$ LANGUAGE plpgsql;

--------- Пример вызова ---------

SELECT * FROM GetCheapestSupplier('Молоко сырое');


------------------------------------------------
--- Является ли поставщик добросовестным
------------------------------------------------

CREATE OR REPLACE FUNCTION IsPartnerTrustworthy(partner_name CHARACTER VARYING)
RETURNS INT
AS $$
DECLARE is_partner_trustworthy INT;
BEGIN
SELECT COUNT(*) INTO is_partner_trustworthy FROM
	(SELECT Supplier.Name AS Name
	FROM Supplier JOIN Material_Order
	ON Material_Order.Supplier_ID = Supplier.Supplier_ID
	AND Material_Order.Deadline < CURRENT_DATE
	AND Material_Order.Is_Done = 0
	GROUP BY Supplier.Name
	HAVING COUNT(*) < 2
	
	UNION	
	SELECT Client.Name AS Name FROM Client
	WHERE Client.Is_Regular = 1) AS Trustworthy
WHERE Trustworthy.Name = partner_name;

IF is_partner_trustworthy > 0 THEN
	RETURN 1;
ELSE
	RETURN 0;
END IF;

END;
$$ LANGUAGE plpgsql;

--------- Пример вызова ---------

SELECT IsPartnerTrustworthy('Андреевский'); 		-- 1
SELECT IsPartnerTrustworthy('Ферма "Ласточка"'); 	-- 1
SELECT IsPartnerTrustworthy('Совхоз им. Ленина'); 	-- 0

--------------------------
-------- Триггеры --------
--------------------------

------------------------------------------------
--- Делаем клиента постоянным
------------------------------------------------


CREATE OR REPLACE FUNCTION Mark_Regular_Client()
RETURNS TRIGGER
AS $$
DECLARE
	client_orders 	INT;
	client_quantity INT;
	client_regular	INT;
BEGIN

SELECT COUNT(*), SUM(quantity) INTO client_orders, client_quantity FROM Product_Order 
WHERE Client_ID = NEW.Client_ID;

SELECT Is_Regular INTO client_regular FROM Client
WHERE Client_ID = NEW.Client_ID;

IF (client_orders > 3 OR client_quantity > 200) AND (client_regular = 0) THEN
	UPDATE Client SET Is_Regular = 1 WHERE Client_ID = NEW.Client_ID;
END IF;

RETURN NEW;

END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER Tr_Mark_Regular_Client AFTER INSERT OR UPDATE ON Product_Order
FOR EACH ROW EXECUTE PROCEDURE Mark_Regular_Client();

--------- Пример вызова ---------

INSERT INTO Product_Order(product_type_id, client_id, quantity, is_done)
VALUES(2, 2, 200, 0);


------------------------------------------------
--- Проверка на наличие заказываемого сырья у поставщика
------------------------------------------------

CREATE OR REPLACE FUNCTION Check_Material_Availability()
RETURNS TRIGGER
AS $$
BEGIN
IF NEW.Volume > (SELECT maximal_volume FROM Supplier 
			WHERE Supplier_ID = NEW.Supplier_ID) THEN
	RAISE EXCEPTION 'Ordered volume % from supplier % is higher than possible', 
		NEW.Volume, NEW.Supplier_ID;
END IF;

RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER Tr_Check_Material_Availability BEFORE INSERT OR UPDATE ON Material_Order
FOR EACH ROW EXECUTE PROCEDURE Check_Material_Availability();

--------- Пример вызова ---------

INSERT INTO Material_Order(Supplier_ID, Volume, Is_Done, Deadline)
VALUES(2, 250, 0, '2048-02-02');


------------------------------------------------
--- Проверка на наличие заказываемого сырья у поставщика
------------------------------------------------

CREATE OR REPLACE FUNCTION Mark_Unavailable()
RETURNS TRIGGER
AS $$
BEGIN
UPDATE Product_Type SET Is_Available = 0 WHERE Product_Type_ID = OLD.Product_Type_ID;

RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER Tr_Mark_Unavailable BEFORE DELETE ON Product_Type
FOR EACH ROW EXECUTE PROCEDURE Mark_Unavailable();

--------- Пример вызова ---------

DELETE FROM Product_Type WHERE Name = 'Творог 5%';


-------------------------------
-------- Представления --------
-------------------------------

------------------------------------------------
--- Невыполненные заказы на готовую продукцию
------------------------------------------------

CREATE VIEW UnfulfilledProductOrders AS 
	SELECT
		Product_Order.Product_Order_Id, 
		Product_Type.Name AS Product_Name, 
		Client.Client_ID AS Client_ID,
		Client.Name AS Client_Name, 
		Product_Order.quantity 
	FROM Product_Order, Client, Product_Type
	WHERE Product_Order.Is_Done = 0
	AND Client.Client_ID = Product_Order.Client_ID
	AND Product_Type.Product_Type_ID = Product_Order.Product_Type_ID;

--------- Пример вызова ---------

SELECT MAX(quantity) FROM UnfulfilledProductOrders;


------------------------------------------------
--- Невыполненные заказы на сырьё
------------------------------------------------

CREATE VIEW UnfulfilledMaterialOrders AS
	SELECT 
		Material_Order.Material_Order_ID,
		Supplier.Name AS Supplier_Name,
		Material_Order.Volume,
		Material_Order.Deadline
	FROM Material_Order JOIN Supplier
	ON Material_Order.Supplier_ID = Supplier.Supplier_ID
	WHERE Material_Order.Is_Done = 0;

--------- Пример вызова ---------	

SELECT MAX(volume) FROM UnfulfilledMaterialOrders;


------------------------------------------------
--- Доступные виды тары и товары, которые можно в эту тару упаковать
------------------------------------------------

CREATE VIEW AvailablePackageOptions AS
	SELECT
		Package_Type.name AS Package,
		Package_Type.Volume AS Volume,
		Product_Type.name AS Product
	FROM Package_Type LEFT JOIN Product_Type
	ON Package_Type.Package_Type_ID = Product_Type.Package_Type_ID;

--------- Пример вызова ---------

SELECT * FROM AvailablePackageOptions;


------------------------------------------------
--- Список всех, с кем работает молокозавод
------------------------------------------------

CREATE VIEW PartnerList AS
	SELECT 
		Supplier.Name AS Name,
		Supplier.Address AS Address
	FROM Supplier JOIN Material_Order
	ON Material_Order.Supplier_ID = Supplier.Supplier_ID
	UNION	
	SELECT 
		Client.Name AS Name,
		Client.Address AS Address 
	FROM Client

--------- Пример вызова ---------

SELECT * FROM PartnerList WHERE LEFT(Name, 1) = 'П';


-----------------------------------------
--- Удаление представлений
-----------------------------------------

/*
DROP VIEW PartnerList;
DROP VIEW AvailablePackageOptions;
DROP VIEW UnfulfilledMaterialOrders;
DROP VIEW UnfulfilledProductOrders;
*/
