require 'csv'

$article_no_index
$index_28
$index_30 
$index_32
$index_34
$index_36
$total_index
$carton_no_index

TAX_PERCENTAGE = 2

class Article
 
  def initialize(size, colour, total_quantity, carton_no)
    @size = size
    @colour= colour
    @quantity = total_quantity
    @carton_no = carton_no
  end

  def size
   @size
  end

  def colour
   @colour
  end

  def quantity
   @quantity
  end

  def set_quantity(new_quantity)
    @quantity = new_quantity
  end

  def carton_no()
    @carton_no
  end
end


class CsvDataGenerator

  def initialize(packing_list, params)
    @packing_list_file = packing_list
    @params = params
  end

  def generate_asn_data()
    articles = Hash.new
    index = 0;
    indices_found = false;
    last_carton_no = nil;

    CSV.foreach(@packing_list_file.path) do |csv_row|
      index += 1
      if !indices_found
        indices_found = find_indices csv_row
        index += 1
        next
      end

      current_carton_no = csv_row[$carton_no_index] 
      current_article_no = csv_row[$article_no_index] 
      
      if current_carton_no.nil? || current_carton_no.empty?
        current_carton_no = last_carton_no
      end
     
      if ( !indices_found || current_article_no.nil? || current_article_no.empty?) 
       next
      end
     
      if articles[current_article_no].nil?
        articles[current_article_no] = Article.new(find_size(csv_row), find_color(csv_row), csv_row[$total_index], current_carton_no)
      else 
        update_article_quantity(articles[current_article_no], csv_row)
      end

     index += 1
     last_carton_no = current_carton_no
   end

   final_csv_rows = Array.new
   total_quantity = 0
   total_amount = 0
 
   articles.keys.sort.each do |article_number|
    article = articles[article_number]
    amount = Integer(article.quantity) * Integer(price)
    total_amount += amount
    total_quantity += article.quantity.to_i
    final_csv_rows.push ["", "", "112010001  ML_T_CASUAL_TROUSER", article_number, pack_size, "", article.quantity, article.quantity, po_delivery_date, price, tax_rate, amount ,article.carton_no]  
   end

   tax = tax_amount total_amount
   total_amount += tax

   @params[:total_quantity] = total_quantity 
   @params[:total_value] = total_amount 
 
   final_row = Array.new 13, ""
   final_row[7] = total_quantity
   final_row[11] = total_amount

   final_csv_rows.push final_row
   return final_csv_rows
end

def price
    @params[:price] || 0
end

def pack_size
  @params[:pack_size] || ""
end

def po_delivery_date
  @params[:po_delivery_date] || ""
end

def tax_rate
  @params[:tax_rate] || 2
end

def find_indices row
  if (row.nil?)
    return false
  end
 
  i=0
  while i<6 do
    if ((row[i].nil? || row[i+1].nil? || row[i+2].nil?)) then
      i += 1
      next 
    end
    if (row[i].downcase.include? "article") && (row[i+1].include? "28") && (row[i+2].include? "30") 
      puts "Article no column number found is #{i}"
      $article_no_index = i;
      $index_28 = i+1
      $index_30 = i+2
      $index_32 = i+3
      $index_34 = i+4
      $index_36 = i+5
      $total_index = i+6
      $carton_no_index = i-1
      return true
    end
    i += 1
  end
  return false
end

def tax_amount(amount)
  tax_amount = (amount * TAX_PERCENTAGE)/100
  tax_amount.round.to_i
end

def find_size(row)
  if row[$index_28] != "0" then 
    return "28"
  elsif row[$index_30] != "0"
    return "30"
  elsif row[$index_32] != "0"
    return "32"
  elsif row[$index_34] != "0"
    return "34"
  elsif row[$index_36] != "0"
    return "36"
  else return ""
  end
end

def find_color(row)
  return "black "
end

def update_article_quantity(article, row)
 new_total_quantity = article.quantity.to_i + row[$total_index].to_i
 article.set_quantity(new_total_quantity)
end
end

