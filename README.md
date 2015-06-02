# ARLiteORM

Object-Relational Mapping using Ruby metaprogramming. Inspired by ActiveRecord.

## Current features include: 
* SQL object - table_name, all, find, insert, update and save methods
* Searchable - execute SQL WHERE queries while blocking SQL Injection
* Associations - belongs_to, has_many, has_one_through and has_many_through associations

## How to use:
* Clone or Extract ZIP file of this repo into your project
* In your code, require_relative './ARliteORM/arlite_orm'
* To load your SQLite3 Database, call 'DBConnection.open(PATH_TO_YOUR_DB_FILE)'
* Use the SQL object, Searchable and Association methods provided for manipulating and querying data.

Here's an example using the included test database:

```ruby
require 'arlite_orm'

class Cat < SQLObject
  belongs_to :human, foreign_key: :owner_id
  belongs_to :cat_house

  finalize!
end

# Save records to the database
house = CatHouse.new(color: "Brown")
house.save
cat = Cat.new(name: "Sennacy", owner_id: 1, cat_house_id: house.id)
cat.save

# Search by one or more columns
cats = Cat.where(name: "Sennacy")
cats = Cat.where(owner_id: 1, cat_house_id = house.id)
cat = Cat.find(1) #=>  <#Cat:0x007f9ba9897d98 @name="Chairman Meow", @owner_id=1, @cat_house_id=2>

# Retrieve table rows by association
cat.human #=> <#Human:0x007f9ba9897d98 @first_name="Fred", @last_name="Bloggs">

```

Enjoy!