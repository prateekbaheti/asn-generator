require 'csv'

class Article
  def initialize(cartonNo, articleNo, size, quantity)
    @cartonNo = cartonNo
    @articleNo = articleNo
    @size = size
    @quantity = quantity
  end
end


def getPrice()
  return  ENV['price'] || ""
end

def getAmount(quantity)
 price = getPrice().empty? ?  "" : Integer(getPrice())*Integer(quantity) 
 return price
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

def getTaxAmount(amount)
  taxAmount = (amount * 2)/100
  return taxAmount.round
end


def readCsv(fileName)
 articleQuantityHash = Hash.new()
 articleSizeHash = Hash.new()
 first = true

 CSV.foreach(fileName) do |row|
  #puts "#{i} times"

   if (first || row[1].nil? || row[1].empty?) then 
     first = false
     next
   end
   
   articleSizeHash[row[1]] = findSize(row)

   if articleQuantityHash[row[1]].nil?
    #puts "putting #{row[1]} value #{row[7]}"
     articleQuantityHash[row[1]] = Integer(row[7])
   else
     currentValue = articleQuantityHash[row[1]]
     newValue = currentValue + Integer(row[7]) 
     articleQuantityHash[row[1]] = newValue
    #puts "re entering #{row[1]} value #{newValue}"
   end
 end
 
finalCsv = ""
totalQuantity = 0
totalAmount = 0
 articleQuantityHash.keys.sort.each do |key|
  quantity = articleQuantityHash[key] 
  amount = getAmount(quantity)
  totalQuantity += quantity
  totalAmount += amount
  finalCsv += "208441,COTTON TROUSERS,2%,READYMADE GARMENT,#{key},#{getPrice()},,#{articleSizeHash[key]},#{quantity},YES,YES,#{amount} \n"
 end
 
 taxAmount = getTaxAmount(totalAmount)
 amountIncludingTax = totalAmount + taxAmount
 finalCsv += "\n,,,,,,,,#{totalQuantity},,Tax,#{taxAmount}"
 finalCsv += "\n,,,,,,,,,,Total,#{amountIncludingTax}"

 finalCsvFile = getFileName(fileName)
 File.open(finalCsvFile, "w") { |file| file.write(finalCsv) }
# puts finalCsv
 puts "\n\n*****Final CSV generation complete !!******\nOpen file: #{finalCsvFile}\n  --Don't forget to thank =>  Prateek Kumar Baheti"
end

def getFileName(originalFileName) 
extensionStripped = originalFileName.gsub '.csv',''
return extensionStripped + "_final.csv"
end
  
csvFile = ENV['file'];
if csvFile.nil?  
  puts "*******Error: File name not entered. Call with csv file name, example: price=325 file=sheet.csv ruby asn.rb"
  exit
end
puts "Using Csv file: #{csvFile}"
readCsv(csvFile)

