require 'spreadsheet'

$article_no_index
$index_28
$index_30 
$index_32
$index_34
$index_36
$total_index
$carton_no_index

TAX_PERCENTAGE = 2
PO_LINE_NUMBER_INDEX=1
PO_ARTICLE_NO_INDEX=6

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


class PackingListDataGenerator

  def initialize( params)
    @params = params
    @packing_list_file = params[:packing_list_file][:tempfile]
  end

  def generate_packing_data()
    articles = Hash.new
    index = 0;
    indices_found = false;
    last_carton_no = nil;
    
    book = Spreadsheet.open @packing_list_file.path
    workbook = book.worksheet 0

    workbook.each do |csv_row|
      index += 1
      if !indices_found
        indices_found = find_indices csv_row
       puts "total index is #{$total_index}"
        index += 1
        next
      end

      current_carton_no = get_csv_row_value(csv_row, $carton_no_index).to_s 
      current_article_no = get_csv_row_value(csv_row, $article_no_index).to_i.to_s 
      
      if current_carton_no.nil? || current_carton_no.empty?
        current_carton_no = last_carton_no
      end
     
      if ( !indices_found || current_article_no.nil? || current_article_no.empty?) 
       next
      end
     
      if articles[current_article_no].nil?
        articles[current_article_no] = Article.new(find_size(csv_row), find_color(csv_row), get_csv_row_value(csv_row, $total_index), current_carton_no)
      else 
        update_article_quantity(articles[current_article_no], csv_row)
      end

     index += 1
     last_carton_no = current_carton_no
   end

   final_csv_rows = Array.new
   total_quantity = 0
   total_amount = 0

  po_data.each do |row|
    article_no = row[PO_ARTICLE_NO_INDEX]
    article = articles[article_no]
    line_no = row[PO_LINE_NUMBER_INDEX]
    puts articles
    if (!article.nil?)
      amount = Integer(article.quantity) * Integer(price)
      total_amount += amount
      total_quantity += article.quantity.to_i
      final_csv_rows.push ["", line_no, "112010001  ML_T_CASUAL_TROUSER", article_no, pack_size, "", article.quantity, article.quantity, po_delivery_date, price, tax_rate, amount ,article.carton_no]  
    end
  end
  
  if (final_csv_rows.size < 1)
    return
  end

   tax = tax_amount total_amount
   total_amount += tax

   @params[:total_quantity] = total_quantity 
   @params[:total_value] = total_amount 
   
   empty_row = Array.new 13, ""
   
   tax_row = Array.new 13, ""
   tax_row[7] = total_quantity
   tax_row[10] = "Tax"
   tax_row[11] = tax

 
   final_row = Array.new 13, ""
   final_row[10] = "Total"
   final_row[11] = total_amount

   final_csv_rows.push(empty_row, tax_row, final_row)
   return final_csv_rows
end

def get_csv_row_value(row, index)
  (row[index].class.name.downcase.include?("formula")) ? row[index].value : row[index]
end

def po_data
  @params[:po_data]
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
  @params[:tax_rate] || "2%"
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

    if (row[i].to_s.downcase.include? "article") && (row[i+1].to_s.include? "28") && (row[i+2].to_s.include? "30") 
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
 new_total_quantity = article.quantity.to_i + get_csv_row_value(row, $total_index).to_i
 article.set_quantity(new_total_quantity)
end
end

