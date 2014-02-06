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
 
  def initialize(size, colour, totalQuantity)
    @size = size
    @acolour= colour
    @quantity = totalQuantity
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

  def setQuantity(newQuantity)
    @quantity = newQuantity
  end
end


class CsvDataGenerator

  def initialize(packing_list, params)
    @packing_list_file = packing_list
    @price = params['price'] || 0
    @params = params
  end

  def generate_asn_data()
    articles = Hash.new
    index = 0;
    indicesFound = false;

    CSV.foreach(@packing_list_file.path) do |csv_row|
      index += 1
      if !indicesFound then
        indicesFound = findIndices csv_row
        index += 1
        next
      end
      
      if ( !indicesFound || csv_row[$article_no_index].nil? || csv_row[$article_no_index].empty?) then 
       next
     end
     
      if articles[csv_row[$article_no_index]].nil? 
      articles[csv_row[$article_no_index]] = Article.new(findSize(csv_row), findColor(csv_row), csv_row[$total_index])
    else 
     updateArticleQuantity(articles, csv_row)

     index += 1
   end
 end

finalCsv = ""
totalQuantity = 0
totalAmount = 0
 
 articles.keys.sort.each do |article_number|
  article = articles[article_number]
  amount = Integer(article.quantity) * Integer(@price)
  totalAmount += amount
  totalQuantity += article.quantity.to_i
  finalCsv += "208441,COTTON TROUSERS,2%,READYMADE GARMENT,#{article_number},#{@price},,#{article.size},#{article.quantity},YES,YES,#{amount} \n"  
end

 if finalCsv.strip.empty?
   return ""
 end
 taxAmount = getTaxAmount(totalAmount) 
 amountIncludingTax = totalAmount + taxAmount
 
 @params[:total_quantity] = totalQuantity 
 @params[:total_value] = amountIncludingTax

 finalCsv += "\n,,,,,,,,#{totalQuantity},,Tax,#{taxAmount}"
 finalCsv += "\n,,,,,,,,,,Total,#{amountIncludingTax}"
return finalCsv
end

def findIndices row
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
  false
end

def getTaxAmount(amount)
  taxAmount = (amount * TAX_PERCENTAGE)/100
  taxAmount.round
end

def findSize(row)
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

def findColor(row)
  return "black "
end

def updateArticleQuantity(articles, row)
 article = articles[row[$article_no_index]]
 newTotalQuantity = article.quantity.to_i + row[$total_index].to_i
 article.setQuantity(newTotalQuantity)
 articles[row[$article_no_index]] = article 
end
end

