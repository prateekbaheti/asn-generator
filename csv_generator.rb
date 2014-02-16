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

    CSV.foreach(@packing_list_file.path) do |csv_row|
      index += 1
      if !indices_found then
        indices_found = find_indices csv_row
        index += 1
        next
      end
      
      if ( !indices_found || csv_row[$article_no_index].nil? || csv_row[$article_no_index].empty?) then 
       next
     end
     
      if articles[csv_row[$article_no_index]].nil? 
      articles[csv_row[$article_no_index]] = Article.new(find_size(csv_row), find_color(csv_row), csv_row[$total_index], csv_row[$carton_no_index])
    else 
     update_article_quantity(articles, csv_row)

     index += 1
   end
 end

final_csv = ""
total_quantity = 0
total_amount = 0
 
 articles.keys.sort.each do |article_number|
  article = articles[article_number]
  amount = Integer(article.quantity) * Integer(price)
  total_amount += amount
  total_quantity += article.quantity.to_i
  final_csv += ",COTTON TROUSERS,#{article_number},,,#{article.quantity},#{article.quantity},,#{price},#{tax_amount amount},#{amount},#{article.carton_no}"  
end

 if final_csv.strip.empty?
   return ""
 end
 tax_amount = tax_amount(total_amount) 
 amount_including_tax = total_amount + tax_amount
 
 @params[:total_quantity] = total_quantity 
 @params[:total_value] = amount_including_tax

 final_csv += "\n,,,,,,,,#{total_quantity},,Tax,#{tax_amount}"
 final_csv += "\n,,,,,,,,,,Total,#{amount_including_tax}"
return final_csv
end

 def price
    return params['price'] || 0
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
  tax_amount.round
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

def update_article_quantity(articles, row)
 article = articles[row[$article_no_index]]
 new_total_quantity = article.quantity.to_i + row[$total_index].to_i
 article.set_quantity(new_total_quantity)
 articles[row[$article_no_index]] = article 
end
end

