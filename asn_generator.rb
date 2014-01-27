require 'csv'

ARTICLE_NO_INDEX = 1
TOTAL_INDEX = 7
CARTON_NO_INDEX = 0

class Article
 
  def initialize(size, colour, totalQuantity)
    @size = size
    @acolour= colour
    @total = totalQuantity
  end

  def size
   @size
  end

  def colour
   @colour
  end

  def total
   @total
  end

  def setTotal(newTotal)
    @total = newTotal
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
    puts "index is #{index} and article = #{csv_row[1]} "
     if articles[csv_row[ARTICLE_NO_INDEX]].nil? 
      articles[csv_row[ARTICLE_NO_INDEX]] = Article.new(findSize(csv_row), findColor(csv_row), csv_row[TOTAL_INDEX])
    else 
     updateArticleQuantity(articles, csv_row)
   end
 end

finalCsv = ""
 articles.keys.sort.each do |article_number|
  article = articles[article_number]
  amount = Integer(article.total) * Integer(@price)
  finalCsv += "208441,COTTON TROUSERS,2%,READYMADE GARMENT,#{article_number},#{@price},,#{article.size},#{article.total},YES,YES,#{amount} \n"  
end

return finalCsv
end

def findSize(row)
  return 34
end

def findColor(row)
  return "black "
end

def updateArticleQuantity(articles, row)
 article = articles[row[ARTICLE_NO_INDEX]]
 puts "old size is #{article.total}"
 newTotalQuantity = article.total.to_i + row[TOTAL_INDEX].to_i
 article.setTotal(newTotalQuantity)
 puts "new size is #{article.total}"
 articles[row[ARTICLE_NO_INDEX]] = article 
end
end

