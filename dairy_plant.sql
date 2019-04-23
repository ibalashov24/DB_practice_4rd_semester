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
	Package_Type_ID		INTEGER		NOT NULL,
	Is_Available		INTEGER		DEFAULT 1 CHECK(Is_Available in (0, 1)),

	CONSTRAINT Product_Type_PK PRIMARY KEY(Product_Type_ID)
)
;
CREATE TABLE Client(
	Client_ID		SERIAL,
	Name			VARCHAR(30)	NOT NULL,
	Address			VARCHAR(50)	NOT NULL,
	Is_Regular		INTEGER		DEFAULT 0 CHECK(Is_Regular in (0, 1)),

	CONSTRAINT Client_PK PRIMARY KEY(Client_ID)
)
;
CREATE TABLE Supplier(
	Supplier_ID		INTEGER 	NOT NULL,
	Name			VARCHAR(30)	NOT NULL,
	Address			VARCHAR(50),
	Material_Type_ID	INTEGER		NOT NULL,
	Maximal_Volume		DECIMAL 	NOT NULL,
	Price			DECIMAL 	NOT NULL,
	Next_Supply		DATE		DEFAULT CURRENT_DATE NOT NULL,

	CONSTRAINT Supplier_PK PRIMARY KEY(Supplier_ID)
)
;
CREATE TABLE Material_Order(
	Material_Order_ID	SERIAL,
	Supplier_ID		INTEGER 	NOT NULL,
	Volume			DECIMAL		NOT NULL,
	Is_Done			INTEGER		CHECK(Is_Done in (0, 1)),
	Deadline		DATE		DEFAULT CURRENT_DATE NOT NULL,

	CONSTRAINT Material_Order_PK PRIMARY KEY(Material_Order_ID)
)
;
CREATE TABLE Product_Order(
	Product_Order_ID	SERIAL,
	Product_Type_ID		INTEGER		NOT NULL,
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
	Volume			DECIMAL,

	CONSTRAINT Used_Material_PK PRIMARY KEY(Used_Material_ID)
)
;
CREATE TABLE Package_Type(
	Package_Type_ID		SERIAL,
	Name			VARCHAR(30),
	Volume			DECIMAL		NOT NULL,
	Is_Available		INTEGER		DEFAULT 1 CHECK(Is_Available in (0, 1)),

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
REFERENCES Client(Client_ID) ON DELETE CASCADE
;
ALTER TABLE Material_Order ADD CONSTRAINT FK_Material_Order_Supplier
FOREIGN KEY (Supplier_ID)
REFERENCES Supplier(Supplier_ID) ON DELETE CASCADE
;
ALTER TABLE Used_Material ADD CONSTRAINT FK_Used_Material_Product_Order
FOREIGN KEY (Product_Order_ID)
REFERENCES Product_Order(Product_Order_ID) ON DELETE CASCADE
;
ALTER TABLE Used_Material ADD CONSTRAINT FK_Used_Material_Supplier
FOREIGN KEY (Supplier_ID)
REFERENCES Supplier(Supplier_ID) ON DELETE CASCADE
;
ALTER TABLE Product_Type ADD CONSTRAINT FK_Product_Type_Package_Type
FOREIGN KEY (Package_Type_ID)
REFERENCES Package_Type(Package_Type_ID) ON DELETE CASCADE
;
ALTER TABLE Supplier ADD CONSTRAINT FK_Supplier_Material_Type
FOREIGN KEY (Material_Type_ID)
REFERENCES Material_Type(Material_Type_ID) ON DELETE CASCADE
;

----------------------------------------
--- Создание индексов
----------------------------------------

CREATE INDEX Supplier_Index ON Supplier(Material_Type_ID, Price, Next_Supply);
CREATE INDEX Product_Order_Index ON Product_Order(Product_Type_ID, Quantity);
CREATE INDEX Material_Order_Index ON Material_Order(Supplier_ID, Volume, Deadline);

CREATE INDEX Product_Type_Index ON Product_Type(Package_Type_ID);	
CLUSTER Product_Type USING Product_Type_Index;

----------------------------------------
--- Заполнение данными
----------------------------------------

INSERT INTO Material_Type(Material_Type_ID, Name) VALUES (1, 'Молоко сырое');
INSERT INTO Material_Type(Material_Type_ID, Name) VALUES (2, 'Клубничный джем');
INSERT INTO Material_Type(Material_Type_ID, Name) VALUES (3, 'Сахар');
INSERT INTO Material_Type(Material_Type_ID, Name) VALUES (4, 'Эмульгатор');
INSERT INTO Material_Type(Material_Type_ID, Name) VALUES (5, 'Ванилин');
INSERT INTO Material_Type(Material_Type_ID, Name) VALUES (6, 'Изюм');
INSERT INTO Material_Type(Material_Type_ID, Name) VALUES (7, 'Закваска');

INSERT INTO Supplier(Supplier_ID, Name, Address, Material_Type_Id, Maximal_Volume, Price, Next_Supply) 
	VALUES (1, 'Совхоз им. Ленина', 'Гатчинский район', 1, 100, 30, '2019-07-20');
INSERT INTO Supplier(Supplier_ID, Name, Address, Material_Type_Id, Maximal_Volume, Price, Next_Supply) 
	VALUES (2, 'Совхоз им. Ленина', 'Гатчинский район', 2, 231, 70, '2019-06-15');
INSERT INTO Supplier(Supplier_ID, Name, Address, Material_Type_Id, Maximal_Volume, Price, Next_Supply) 
	VALUES (3, 'Ферма "Ласточка"', 'Волосовский район', 2, 122, 69, '2019-05-10');
INSERT INTO Supplier(Supplier_ID, Name, Address, Material_Type_Id, Maximal_Volume, Price, Next_Supply) 
	VALUES (4, 'ИП Петрович А.А.', 'Кингисеппский район', 4, 1000, 10, '2019-06-01');
INSERT INTO Supplier(Supplier_ID, Name, Address, Material_Type_Id, Maximal_Volume, Price, Next_Supply) 
	VALUES (5, 'Совхоз №15', 'Тихвинский район', 1, 1321, 31, '2019-05-31');
INSERT INTO Supplier(Supplier_ID, Name, Address, Material_Type_Id, Maximal_Volume, Price, Next_Supply) 
	VALUES (6, 'Совхоз им. Ленина', 'Гатчинский район', 5, 12312, 12, '2019-05-31');
INSERT INTO Supplier(Supplier_ID, Name, Address, Material_Type_Id, Maximal_Volume, Price, Next_Supply) 
	VALUES (7, 'ООО "Легион"', 'Всеволжский район', 3, 1333, 35, '2019-06-01');
INSERT INTO Supplier(Supplier_ID, Name, Address, Material_Type_Id, Maximal_Volume, Price, Next_Supply) 
	VALUES (8, 'ООО "Легион"', 'Всеволжский район', 5, 666, 12, '2019-05-30');
INSERT INTO Supplier(Supplier_ID, Name, Address, Material_Type_Id, Maximal_Volume, Price, Next_Supply) 
	VALUES (9, 'Ферма "Ласточка"', 'Волосовский район', 7, 23, 67, '2019-05-08');

INSERT INTO Package_Type(Name, Volume) VALUES ('Тетра пак', 1.0);
INSERT INTO Package_Type(Name, Volume) VALUES ('Пюр пак', 0.97);
INSERT INTO Package_Type(Name, Volume) VALUES ('Фольга оберточная', 0.180);
INSERT INTO Package_Type(Name, Volume) VALUES ('Полиэтиленовая пленка', 0.25);
INSERT INTO Package_Type(Name, Volume, Is_Available) VALUES ('Стаканчик пластиковый', 0.2, 0);
INSERT INTO Package_Type(Name, Volume) VALUES ('Стаканчик пластиковый', 0.5);

INSERT INTO Product_Type(Product_Type_ID, Name, Package_Type_ID) VALUES (0, 'Молоко 1.5%', 1);
INSERT INTO Product_Type(Product_Type_ID, Name, Package_Type_ID) VALUES (1, 'Молоко 1.5%', 2);
INSERT INTO Product_Type(Product_Type_ID, Name, Package_Type_ID) VALUES (2, 'Молоко 2.5%', 1);
INSERT INTO Product_Type(Product_Type_ID, Name, Package_Type_ID) VALUES (3, 'Молоко 3%', 2);
INSERT INTO Product_Type(Product_Type_ID, Name, Package_Type_ID) VALUES (4, 'Творог обезжиренный', 3);
INSERT INTO Product_Type(Product_Type_ID, Name, Package_Type_ID) VALUES (5, 'Творог обезжиренный', 4);
INSERT INTO Product_Type(Product_Type_ID, Name, Package_Type_ID) VALUES (6, 'Творог 5%', 4);
INSERT INTO Product_Type(Product_Type_ID, Name, Package_Type_ID) VALUES (7, 'Творог 5% c джемом', 5);
INSERT INTO Product_Type(Product_Type_ID, Name, Package_Type_ID) VALUES (8, 'Творожная масса с изюмом', 4);

INSERT INTO Client(Client_ID, Name, Address, Is_Regular) VALUES (1, 'Андреевский', 'Петергоф, Ботаническая 66к.3', 1);
INSERT INTO Client(Client_ID, Name, Address) VALUES (2, 'Лента', 'Петергоф, Гостилицкое шоссе 58');
INSERT INTO Client(Client_ID, Name, Address) VALUES (3, 'Перекрёсток', 'СПб, Лиговский проспект 30А');
INSERT INTO Client(Client_ID, Name, Address) VALUES (4, 'Перекрёсток', 'Петергоф, Гостилицкая улица 2А');
INSERT INTO Client(Client_ID, Name, Address) VALUES (5, 'Пятерочка', 'Петергоф, Чичеринская улица 2');
INSERT INTO Client(Client_ID, Name, Address, Is_Regular) VALUES (6, 'Кафе "Яма"', 'Петергоф, Ульяновская улица 28', 1);

INSERT INTO Product_Order(Product_Type_ID, Client_ID, Quantity, Is_Done)
	VALUES (3, 3, 50, 0);
INSERT INTO Product_Order(Product_Type_ID, Client_ID, Quantity, Is_Done)
	VALUES (6, 5, 100, 1);
INSERT INTO Product_Order(Product_Type_ID, Client_ID, Quantity, Is_Done)
	VALUES (4, 3, 75, 0);
INSERT INTO Product_Order(Product_Type_ID, Client_ID, Quantity, Is_Done)
	VALUES (3, 2, 100, 0);
INSERT INTO Product_Order(Product_Type_ID, Client_ID, Quantity, Is_Done)
	VALUES (2, 1, 42, 1);

INSERT INTO Material_Order(Supplier_ID, Volume, Is_Done, Deadline) -- 1
	VALUES (4, 100, 0, '2019-04-15');
INSERT INTO Material_Order(Supplier_ID, Volume, Is_Done, Deadline) -- 2
	VALUES (1, 1000, 1, '2019-05-21');
INSERT INTO Material_Order(Supplier_ID, Volume, Is_Done, Deadline) -- 3
	VALUES (1, 100, 0, '2019-06-01');
INSERT INTO Material_Order(Supplier_ID, Volume, Is_Done, Deadline) -- 4
	VALUES (3, 100, 0, '2019-04-20');
INSERT INTO Material_Order(Supplier_ID, Volume, Is_Done, Deadline) -- 5
	VALUES (2, 230, 1, '2018-10-10');
INSERT INTO Material_Order(Supplier_ID, Volume, Is_Done, Deadline) -- 6
	VALUES (2, 130, 0, '2019-04-15');
INSERT INTO Material_Order(Supplier_ID, Volume, Is_Done, Deadline) -- 7
	VALUES (2, 130, 0, '2019-04-14');

INSERT INTO Used_Material(Used_Material_ID, Product_Order_ID, Supplier_ID, Volume)
	VALUES (1, 1, 1, 50);
INSERT INTO Used_Material(Used_Material_ID, Product_Order_ID, Supplier_ID, Volume)
	VALUES (2, 2, 1, 900);
INSERT INTO Used_Material(Used_Material_ID, Product_Order_ID, Supplier_ID, Volume)
	VALUES (3, 2, 9, 100);
INSERT INTO Used_Material(Used_Material_ID, Product_Order_ID, Supplier_ID, Volume)
	VALUES (4, 3, 5, 70);
INSERT INTO Used_Material(Used_Material_ID, Product_Order_ID, Supplier_ID, Volume)
	VALUES (5, 3, 9, 5);
INSERT INTO Used_Material(Used_Material_ID, Product_Order_ID, Supplier_ID, Volume)
	VALUES (6, 4, 1, 100);
INSERT INTO Used_Material(Used_Material_ID, Product_Order_ID, Supplier_ID, Volume)
	VALUES (7, 5, 1, 42);
	
----------------------------------------
--- Удаление таблиц
----------------------------------------

/*
DROP TABLE Material_Order;
DROP TABLE Used_Material;
DROP TABLE Product_Order;
DROP TABLE Product_Type;
DROP TABLE Client;
DROP TABLE Supplier;
DROP TABLE Material_Type;
DROP TABLE Package_Type;
*/
