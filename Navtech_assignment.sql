/* user table which will maintain the customer/user related info */

create table pmuser (
id int primary key identity(1,1),
code varchar(15) NOT NULL,
name varchar(100),
semail varchar(50),
saddr1 varchar(80),
saddr2 varchar(80),
scity varchar(20),
szipcode varchar(30),
CONSTRAINT ui_pmusercode UNIQUE (code)
)

/*
create Table Size(
id int primary key identity(1,1),
code varchar(15) NOT NULL,
name varchar(100),
CONSTRAINT ui_aizecode UNIQUE (code)
)

create Table Color(
id int primary key identity(1,1),
code varchar(15) NOT NULL,
name varchar(100),
CONSTRAINT ui_colorcode UNIQUE (code)
)
*/

/* Product table which will maintain the Product related info 
also primary key has inbuilt clustered indexes and unique contrainst has default non clustered indexes
*/

create table Product(
id int primary key identity(1,1),
code varchar(15) NOT NULL,
Productname varchar(50) not NULL,
ProductDescription varchar(200),
ProductCost DOUBLE PRECISION,
isavailable bit not Null,
UnitsinStock int
CONSTRAINT ui_productcode UNIQUE (code)
)

/* Attributes table will contain attributes like size, color, material etc
Creating these seperate table because attributes can be dyanamic and can be added runtime.
*/

create table Attributes (
id int identity(1,1) primary key,
attribute varchar(50) NOT NULL
CONSTRAINT ui_ProductAttribute UNIQUE (attribute)
)

/* Attribute_value this table will have the values defined for the above*/
create table Attribute_value(
value_id int identity(1,1) primary key, 
Attribute_id int FOREIGN KEY REFERENCES Attributes(id),
value varchar(50)
)

/* this table will have the product related and attribute related names. This table will be helpul for view which is created in later section  */
create table product_Attribute( product_attr_id int  identity(1,1) primary key,
                            product_id int FOREIGN KEY REFERENCES product(id),
                            productAttributeName varchar(50),
                            price float
                            );

/* this product_details table will hold the information related to product_Attribute and Attribute_value tables*/
create table product_details(product_detail_id int identity(1,1) primary key,
                             product_attribute_id int FOREIGN KEY REFERENCES product_Attribute(product_attr_id),
                             value_id int FOREIGN KEY REFERENCES Attribute_value(value_id)
                             );


/* order table will hold the order user related info*/
Create table OrderTable (
id int primary key identity(1,1),
userid int FOREIGN KEY REFERENCES pmuser(id),
orderdate datetime
)

/*OrderDetail this table will hold the details of the order*/

Create table OrderDetail(
id int primary key identity(1,1),
orderid int FOREIGN KEY REFERENCES OrderTable(id),
Productid int FOREIGN KEY REFERENCES Product(id),
attributeid int FOREIGN KEY REFERENCES Attribute_value(value_id),
quantityOrder int
)

/*Creating a view for product and attributes related details to help find out the details quickly*/

DECLARE 
    @columns NVARCHAR(MAX) = '', 
    @sql     NVARCHAR(MAX) = '';

-- select the category names
SELECT 
    @columns+=QUOTENAME(attribute) + ','
FROM 
    Attributes;

-- remove the last comma
SET @columns = LEFT(@columns, LEN(@columns) - 1);

-- construct dynamic SQL
SET @sql ='alter VIEW dbo.ProductAttributeDetail AS
SELECT * FROM (
 select  p.product_id productname,pv.productattributeName,pv.price,v.attribute attribute ,vv.value_id attributevalue
from attributes v
inner join attribute_value vv on vv.Attribute_id = v.id
inner join product_details pd on pd.value_id  = vv.value_id 
inner join product_attributes pv on pv.product_attributes_id = pd.product_attributes_id
inner join products p on p.product_id = pv.product_id
) productdetails
PIVOT (
  max(attributevalue) 
  FOR attribute IN ('+ @columns +')
) AS pivot_table;';

-- execute the dynamic SQL
EXECUTE sp_executesql @sql;


----------------------------------------------------------------------------------------------------------------------------------------------

/* QUESTION 2 */


/* Administrator shall be able to manage products,attributes,price*/
/* if the web application has original attribute name and to have its updated value in other column then we can have the update statements using where condition of original names.
also the web application should be designed with respect to values stored in DB to avoid further issues.
*/

/*example for updating the price

*/

declare @newprice money
set @newprice = 12 /* (inputing the value stored on frontend via .net code or other) */

declare @productid money
set @productid = 1 /* (inputing the value stored on frontend via .net code or other) */

update pa set pa.price = @newprice
from product p
inner join product_Attribute pa on pa.product_id = p.id
where p.id = 1

----------------------------------------------------------------------------------------------------------------------------------------------
/* QUESTION 3 */

/*
To upload 1000 of records into DB */

/* 
For this we can use SSIS packages.
And using the  MERGE SQL command, it will insert the new data and can update the data if already exists
*/


----------------------------------------------------------------------------------------------------------------------------------------------
/* QUESTION 4 */

/* Can create an SSRS report with the below query*/

select p.name productName,pd.price,pd.quantity, o.orderdate , pd.*
from OrderTable o
inner join OrderDetail od on od.orderid = o.id
inner join product p  
inner join ProductAttributeDetail pd on pd.productname = p.id
where 1=1
order by 6 desc