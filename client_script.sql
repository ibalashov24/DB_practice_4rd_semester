--- (1) Показать только тех, у которых есть невыполненный заказ

SELECT Client_Data.Name, Orders.Unfulfilled_Count, Client.Is_Regular 
FROM 
	Client,
	(SELECT Client_ID, Name, Is_Regular FROM Client) AS Client_Data,
	(SELECT Client_ID, COUNT(*) AS Unfulfilled_Count 
		FROM UnfulfilledProductOrders GROUP BY Client_ID) AS Orders
WHERE Client_Data.Client_ID = Client.Client_ID
AND Orders.Client_ID = Client_Data.Client_ID;

--- (2) Новый заказ на готовую продукцию (на сервере сработает триггер)

INSERT INTO Product_Order(product_type_id, client_id, quantity, is_done)
	VALUES(2, 3, 240, 0);

--- (3) Среднее число упаковок в заказе (в целом)

SELECT AVG(Avg_Volume) FROM GetAvgOrderNumber();

--- (4) Отложить дедлайн на неделю после текущей даты

UPDATE Material_Order SET Deadline = CURRENT_DATE + INTERVAL '1 week'
	WHERE Material_Order_ID = 7;

--- (5) Показать добросоветсных партнеров и тех поставщиков, кто в "зоне риска"

SELECT * FROM Supplier 
WHERE IsPartnerTrustworthy(Supplier.Name) = 1
OR Supplier.Supplier_ID IN (SELECT Supplier.Supplier_ID AS ID
	FROM Supplier JOIN Material_Order
	ON Material_Order.Supplier_ID = Supplier.Supplier_ID
	AND Material_Order.Deadline < CURRENT_DATE
	AND Material_Order.Is_Done = 0
	GROUP BY Supplier.Supplier_ID
	HAVING COUNT(*) >= 2 AND COUNT(*) <= 3);

--- (6) Получить информацию о самом выгодном предложении по каждому типу сырья
CREATE OR REPLACE FUNCTION GetCheapestOffers(material_ids INT[])
RETURNS TABLE (
	Offer_ID	INT,
	Offer_Supplier	CHARACTER VARYING,
	Offer_Name	CHARACTER VARYING,
	Offer_Price	NUMERIC
)
AS $$
DECLARE
	element	INT;
BEGIN
FOREACH element IN ARRAY material_ids LOOP
	RETURN QUERY SELECT Supplier_ID, Supplier_Name, Material, Price
		FROM GetCheapestSupplier((SELECT Name FROM Material_Type WHERE Material_Type_ID = element)) LIMIT 1;
END LOOP;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM GetCheapestOffers(ARRAY(SELECT Material_Type_ID FROM Material_Type));

--- (7) Показать самую популярную тару
SELECT Package_Type.Package_Type_ID, Package_Type.Name, COUNT(*)
	FROM Package_Type, Product_Type, Product_Order
	WHERE Product_Type.Product_Type_ID = Product_Order.Product_Type_ID
	AND Package_Type.Package_Type_ID = Product_Type.Package_Type_ID
	GROUP BY Package_Type.Package_Type_ID, Package_Type.Name
	ORDER BY COUNT(*) DESC
	LIMIT 1;

--- (8) Изменить статус доступности упаковки
UPDATE Package_Type SET Is_Available = 0
	WHERE Package_Type.Package_Type_ID = (SELECT Package_Type_ID FROM Package_Type WHERE Name = 'Тетра пак');

--- (9) Показать типы товаров (без учета тары), на которые нет текущих заказов
SELECT * FROM Product_Type 
WHERE Product_Type.Name NOT IN (SELECT Product_Name FROM UnfulfilledProductOrders);

--- (10) Удалить тип товара (задействуется триггер и вместо удаление пометит товар недоступным)
DELETE FROM Product_Type WHERE Name = 'Творог 5%';
/* Без триггера запрос был бы некорректным из-за наличия внешних ключей,
   ссылающихся на строку */

--- (11) Список постоянных клиентов и добросовестных поставщиков, 
--- 	 кроме покупателей, у которых нет текущих заказов
SELECT DISTINCT Name FROM PartnerList WHERE IsPartnerTrustworthy(PartnerList.Name) = 1
EXCEPT
SELECT DISTINCT Name FROM Client
WHERE Client.Client_ID NOT IN (SELECT UnfulfilledProductOrders.Client_ID FROM UnfulfilledProductOrders);

--- (12) Добросовестным клиентам поставить в соответствие 
---	 наименование в самом крупном (по количеству) заказе
SELECT 
	Client.Name, 
	(SELECT Product_Type.Name FROM Product_Order, Product_Type 
		WHERE Product_Order.Client_ID = Client.Client_ID 
		AND Product_Type.Product_Type_ID = Product_Order.Product_Type_ID  
		ORDER BY Product_Order.Quantity DESC
		LIMIT 1) AS Biggest_Order 
FROM Client
WHERE IsPartnerTrustworthy(Client.Name) = 1
