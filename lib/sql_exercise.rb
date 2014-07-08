require "database_connection"

class SqlExercise

  attr_reader :database_connection

  def initialize
    @database_connection = DatabaseConnection.new
  end

  def all_customers
    database_connection.sql("SELECT * from customers")
  end

  def limit_customers(id)
    id.to_s.gsub!(/;.*/,"")
    database_connection.sql("SELECT * FROM customers LIMIT #{id}")
  end

  def order_customers(order)
    order.gsub!(/;.*/,"")
    database_connection.sql("SELECT * FROM customers ORDER BY name #{order};")
  end

  def id_and_name_for_customers
    database_connection.sql("SELECT id, name FROM customers;")
  end

  def all_items
    database_connection.sql("SELECT * FROM items;")
  end

  def find_item_by_name(item)
    item.gsub!(/;.*/,"")
    item = nil if item == "'"
    database_connection.sql("SELECT * FROM items WHERE name = '#{item}'")[0]
  end

  def count_customers
    database_connection.sql("SELECT * FROM customers;").length
  end

  def sum_order_amounts
    database_connection.sql("SELECT SUM(amount) FROM orders;")[0]['sum'].to_f
  end

  def minimum_order_amount_for_customers
    database_connection.sql("SELECT customer_id, MIN(amount) FROM orders GROUP BY customer_id;")
  end

  def customer_order_totals
    string = <<-SQL
      SELECT orders.customer_id, customers.name, SUM(orders.amount)
      FROM orders
      JOIN customers
      ON  orders.customer_id = customers.id
      GROUP BY orders.customer_id, customers.name;
    SQL
    database_connection.sql(string)
  end

  def items_ordered_by_user(user)
    string = <<-SQL
      SELECT items.name
      FROM orderitems
      JOIN orders
      ON  orders.id = orderitems.order_id
      JOIN items
      ON items.id = orderitems.item_id
      WHERE orders.customer_id = #{user};
    SQL

    database_connection.sql(string).map {|value|
      value['name']
    }
  end

  def customers_that_bought_item(item)
    string = <<-SQL
      SELECT customers.name AS "customer_name", customers.id
      FROM orderitems
      JOIN orders
      ON  orders.id = orderitems.order_id
      JOIN items
      ON items.id = orderitems.item_id
      JOIN customers
      ON customers.id = orders.customer_id
      WHERE items.name = '#{item}'
      GROUP BY customers.name, customers.id;
    SQL
    database_connection.sql(string)
  end

  def customers_that_bought_item_in_state(item, state)
    string = <<-SQL
      SELECT customers.*
      FROM orderitems
      JOIN orders
      ON  orders.id = orderitems.order_id
      JOIN items
      ON items.id = orderitems.item_id
      JOIN customers
      ON customers.id = orders.customer_id
      WHERE items.name = '#{item}' AND state = '#{state}'
      LIMIT 1;
    SQL
    database_connection.sql(string).first
  end


end
