require 'secureRandom'

module FileGenerator 
  def self.generateCsvFile contents
    fileName = SecureRandom.uuid + ".csv"
    filePath = "generated_csv/#{fileName}"
    File.open(filePath, 'w') {|f| f.write(contents)}
    return File.open(filePath);
  end
end
