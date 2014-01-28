require 'csv'

ARTICLE_NO_INDEX = 1
TOTAL_INDEX = 7
CARTON_NO_INDEX = 0
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


class AsnGenerator

  def initialize(packing_list, price)
    @packing_list_file = packing_list
    @price = price
  end

  def generate_asn_data()
    articles = Hash.new
    index = 0;

    CSV.foreach(@packing_list_file.path) do |csv_row|
      index += 1
      if ( index ==1 || index == 2 || csv_row[1].nil? || csv_row[1].empty?) then 
       next
     end
     if articles[csv_row[ARTICLE_NO_INDEX]].nil? 
      articles[csv_row[ARTICLE_NO_INDEX]] = Article.new(findSize(csv_row), findColor(csv_row), csv_row[TOTAL_INDEX])
    else 
     updateArticleQuantity(articles, csv_row)
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
 taxAmount = getTaxAmount(totalAmount) 
 amountIncludingTax = totalAmount + taxAmount
 
 finalCsv += "\n,,,,,,,,#{totalQuantity},,Tax,#{taxAmount}"
 finalCsv += "\n,,,,,,,,,,Total,#{amountIncludingTax}"
return finalCsv
end

def getTaxAmount(amount)
  taxAmount = (amount * TAX_PERCENTAGE)/100
  taxAmount.round
end

def findSize(row)
  if row[2] != "0" then 
    return "28"
  elsif row[3] != "0"
    return "30"
  elsif row[4] != "0"
    return "32"
  elsif row[5] != "0"
    return "34"
  elsif row[6] != "0"
    return "36"
  else return ""
  end
end

def findColor(row)
  return "black "
end

def updateArticleQuantity(articles, row)
 article = articles[row[ARTICLE_NO_INDEX]]
 newTotalQuantity = article.quantity.to_i + row[TOTAL_INDEX].to_i
 article.setQuantity(newTotalQuantity)
 articles[row[ARTICLE_NO_INDEX]] = article 
end
end

