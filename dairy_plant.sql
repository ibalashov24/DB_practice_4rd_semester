-- Database: dairy_plant

----------------------------------------
--- Создание базы данных
----------------------------------------

/*
CREATE DATABASE dairy_plant
  WITH OWNER = postgres
       ENCODING = 'UTF8'
       TABLESPACE = pg_default
       LC_COLLATE = 'ru_RU.UTF-8'
       LC_CTYPE = 'ru_RU.UTF-8'
       CONNECTION LIMIT = -1;
*/

-- DROP DATABASE dairy_plant;

----------------------------------------
--- Создание таблиц и PK
----------------------------------------

CREATE TABLE Material_Type(
	Material_Type_ID	INTEGER		NOT NULL,
	Name 			VARCHAR(30)	NOT NULL,
	
	CONSTRAINT Material_Type_PK PRIMARY KEY(Material_Type_ID)
)
;
CREATE TABLE Product_Type(
	Product_Type_ID		INTEGER		NOT NULL,
	Name 			VARCHAR(30)	NOT NULL,

	CONSTRAINT Product_Type_PK PRIMARY KEY(Product_Type_ID)
)
;
CREATE TABLE Client(
	Client_ID		INTEGER	 	NOT NULL,
	Name			VARCHAR(30)	NOT NULL,
	Address			VARCHAR(50)	NOT NULL,

	CONSTRAINT Client_PK PRIMARY KEY(Client_ID)
)
;
CREATE TABLE Supplier(
	Supplier_ID		INTEGER 	NOT NULL,
	Name			VARCHAR(30),
	Address			VARCHAR(50),

	CONSTRAINT Supplier_PK PRIMARY KEY(Supplier_ID)
)
;
CREATE TABLE Supply_Option(
	Supply_Option_ID	INTEGER		NOT NULL,
	Supplier_ID		INTEGER		NOT NULL,
	Material_Type_ID	INTEGER		NOT NULL,
	Maximal_Volume		DECIMAL 	NOT NULL,
	Price			DECIMAL 	NOT NULL,
	Next_Supply		DATE		NOT NULL,

	CONSTRAINT Supply_Option_PK PRIMARY KEY(Supply_Option_ID)
)
;
CREATE TABLE Material_Order(
	Material_Order_ID	INTEGER		NOT NULL,
	Material_Type_ID	INTEGER		NOT NULL,
	Supplier_ID		INTEGER 	NOT NULL,
	Volume			DECIMAL		NOT NULL,
	Is_Done			INTEGER		CHECK(Is_Done in (0, 1)),
	Deadline		DATE		DEFAULT CURRENT_DATE NOT NULL,

	CONSTRAINT Material_Order_PK PRIMARY KEY(Material_Order_ID)
)
;
CREATE TABLE Product_Order(
	Product_Order_ID	INTEGER		NOT NULL,
	Product_Type_ID		INTEGER		NOT NULL,
	Package_Type_ID		INTEGER		NOT NULL,
	Client_ID		INTEGER		NOT NULL,
	Quantity		DECIMAL		NOT NULL,
	Is_Done			INTEGER		CHECK(Is_Done in (0, 1)),
	
	CONSTRAINT Product_Order_PK PRIMARY KEY(Product_Order_ID)
) 
;
CREATE TABLE Used_Material(
	Used_Material_ID	INTEGER		NOT NULL,
	Product_Order_ID	INTEGER		NOT NULL,
	Supplier_ID		INTEGER		NOT NULL,
	Material_Type_ID	INTEGER		NOT NULL,
	Volume			DECIMAL,

	CONSTRAINT Used_Material_PK PRIMARY KEY(Used_Material_ID)
)
;
CREATE TABLE Package_Type(
	Package_Type_ID		INTEGER		NOT NULL,
	Name			VARCHAR(30),
	Volume			DECIMAL		NOT NULL,

	CONSTRAINT Package_Type_PK PRIMARY KEY(Package_Type_ID)
)
;

----------------------------------------
--- Создание FK
----------------------------------------

ALTER TABLE Product_Order ADD CONSTRAINT FK_Product_Order_Type
FOREIGN KEY (Product_Type_ID)
REFERENCES Product_Type(Product_Type_ID)
;
ALTER TABLE Product_Order ADD CONSTRAINT FK_Product_Order_Client
FOREIGN KEY (Client_ID)
REFERENCES Client(Client_ID)
;
ALTER TABLE Material_Order ADD CONSTRAINT FK_Material_Order_Supplier
FOREIGN KEY (Supplier_ID)
REFERENCES Supplier(Supplier_ID)
;
ALTER TABLE Material_Order ADD CONSTRAINT FK_Material_Order_Type
FOREIGN KEY (Material_Type_ID)
REFERENCES Material_Type(Material_Type_ID)
;
ALTER TABLE Supply_Option ADD CONSTRAINT FK_Supply_Option_Supplier
FOREIGN KEY (Supplier_ID)
REFERENCES Supplier(Supplier_ID)
;
ALTER TABLE Supply_Option ADD CONSTRAINT FK_Supply_Option_Material_Type
FOREIGN KEY (Material_Type_ID)
REFERENCES Material_Type(Material_Type_ID)
;
ALTER TABLE Used_Material ADD CONSTRAINT FK_Used_Material_Product_Order
FOREIGN KEY (Product_Order_ID)
REFERENCES Product_Order(Product_Order_ID)
;
ALTER TABLE Used_Material ADD CONSTRAINT FK_Used_Material_Supplier
FOREIGN KEY (Supplier_ID)
REFERENCES Supplier(Supplier_ID)
;
ALTER TABLE Used_Material ADD CONSTRAINT FK_Used_Material_Material_Type
FOREIGN KEY (Material_Type_ID)
REFERENCES Material_Type(Material_Type_ID)
;
ALTER TABLE Product_Order ADD CONSTRAINT FK_Product_Order_Package_Type
FOREIGN KEY (Package_Type_ID)
REFERENCES Package_Type(Package_Type_ID)
;

----------------------------------------
--- Заполнение данными
----------------------------------------

INSERT INTO Supplier(Supplier_ID, Name, Address) VALUES (1, 'Совхоз им. Ленина', 'Гатчинский район');
INSERT INTO Supplier(Supplier_ID, Name, Address) VALUES (2, 'Ферма "Ласточка"', 'Волосовский район');
INSERT INTO Supplier(Supplier_ID, Name, Address) VALUES (3, 'ИП Петрович А.А.', 'Кингисеппский район');
INSERT INTO Supplier(Supplier_ID, Name, Address) VALUES (4, 'Совхоз №15', 'Тихвинский район');
INSERT INTO Supplier(Supplier_ID, Name, Address) VALUES (5, 'ООО "Легион"', 'Всеволжский район');

INSERT INTO Material_Type(Material_Type_ID, Name) VALUES (1, 'Молоко сырое');
INSERT INTO Material_Type(Material_Type_ID, Name) VALUES (2, 'Клубничный джем');
INSERT INTO Material_Type(Material_Type_ID, Name) VALUES (3, 'Сахар');
INSERT INTO Material_Type(Material_Type_ID, Name) VALUES (4, 'Эмульгатор');
INSERT INTO Material_Type(Material_Type_ID, Name) VALUES (5, 'Ванилин');
INSERT INTO Material_Type(Material_Type_ID, Name) VALUES (6, 'Изюм');

INSERT INTO Product_Type(Product_Type_ID, Name) VALUES (1, 'Молоко 1.5%');
INSERT INTO Product_Type(Product_Type_ID, Name) VALUES (2, 'Молоко 2.5%');
INSERT INTO Product_Type(Product_Type_ID, Name) VALUES (3, 'Молоко 3%');
INSERT INTO Product_Type(Product_Type_ID, Name) VALUES (4, 'Творог обезжиренный');
INSERT INTO Product_Type(Product_Type_ID, Name) VALUES (5, 'Творог 5%');
INSERT INTO Product_Type(Product_Type_ID, Name) VALUES (6, 'Творог 5% c джемом');
INSERT INTO Product_Type(Product_Type_ID, Name) VALUES (7, 'Творожная масса с изюмом');

INSERT INTO Package_Type(Package_Type_ID, Name, Volume) VALUES (1, 'Тетра пак', 1.0);
INSERT INTO Package_Type(Package_Type_ID, Name, Volume) VALUES (2, 'Пюр пак', 0.97);
INSERT INTO Package_Type(Package_Type_ID, Name, Volume) VALUES (3, 'Фольга оберточная', 0.180);
INSERT INTO Package_Type(Package_Type_ID, Name, Volume) VALUES (4, 'Полиэтиленовая пленка', 0.25);
INSERT INTO Package_Type(Package_Type_ID, Name, Volume) VALUES (5, 'Стаканчик пластиковый', 0.2);

INSERT INTO Client(Client_ID, Name, Address) VALUES (1, 'Андреевский', 'Петергоф, Ботаническая 66к.3');
INSERT INTO Client(Client_ID, Name, Address) VALUES (2, 'Лента', 'Петергоф, Гостилицкое шоссе 58');
INSERT INTO Client(Client_ID, Name, Address) VALUES (3, 'Перекрёсток', 'СПб, Лиговский проспект 30А');
INSERT INTO Client(Client_ID, Name, Address) VALUES (4, 'Перекрёсток', 'Петергоф, Гостилицкая улица 2А');
INSERT INTO Client(Client_ID, Name, Address) VALUES (5, 'Пятерочка', 'Петергоф, Чичеринская улица 2');

INSERT INTO Product_Order(Product_Order_ID, Product_Type_ID, Client_ID, Quantity, Is_Done, Package_Type_ID)
	VALUES (1, 3, 3, 50, 0, 2);
INSERT INTO Product_Order(Product_Order_ID, Product_Type_ID, Client_ID, Quantity, Is_Done, Package_Type_ID)
	VALUES (2, 6, 5, 100, 1, 5);
INSERT INTO Product_Order(Product_Order_ID, Product_Type_ID, Client_ID, Quantity, Is_Done, Package_Type_ID)
	VALUES (3, 4, 3, 75, 0, 3);
INSERT INTO Product_Order(Product_Order_ID, Product_Type_ID, Client_ID, Quantity, Is_Done, Package_Type_ID)
	VALUES (4, 3, 2, 100, 0, 1);
INSERT INTO Product_Order(Product_Order_ID, Product_Type_ID, Client_ID, Quantity, Is_Done, Package_Type_ID)
	VALUES (5, 2, 1, 42, 1, 2);

----------------------------------------
--- Удаление таблиц
----------------------------------------

/*
DROP TABLE Material_Order;
DROP TABLE Used_Material;
DROP TABLE Supply_Option;
DROP TABLE Material_Type;
DROP TABLE Product_Order;
DROP TABLE Product_Type;
DROP TABLE Client;
DROP TABLE Supplier;
DROP TABLE Package_Type
*/
