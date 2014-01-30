require 'tempfile'

module FileGenerator 
  def self.generateCsvFile contents
    tempCsvFile = Tempfile.new(["details", ".csv"])
    File.open(tempCsvFile.path, 'w') {|f| f.write(contents)}
    return tempCsvFile;
  end
end
