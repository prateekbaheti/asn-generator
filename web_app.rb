require "rubygems"
require "spreadsheet"
require "sinatra"
require File.join File.dirname(__FILE__), 'csv_generator'
require File.join File.dirname(__FILE__), 'asn_generator'
require File.join File.dirname(__FILE__), 'file_generator'

include AsnGenerator

template = Spreadsheet.open 'template/asn_template.xls'
puts "Got the template****"

get "/" do
  send_file File.join(settings.public_folder, 'asn_complete.html')
end

post "/po_details" do
  if params[:asn_file] && params[:price]
    filename = params[:asn_file][:filename]
    file = params[:asn_file][:tempfile]
  #begin
    puts "params are #{params}"
    generator = CsvDataGenerator.new(file, params)
    csvData = generator.generate_asn_data
    details_xls = AsnGenerator::generate_details_xls(template, csvData, params)
    send_file details_xls , :filename => "filename_final.xls"
  #rescue Exception => e
  #  "Error genertaing details file, Exception:" + e.message
  #end
  else
    "No file selected or Price not entered!!"
end
end

post "/po_details" do
  if params[:asn_file] && params[:price]
    filename = params[:asn_file][:filename]
    file = params[:asn_file][:tempfile]
  begin
    generator = CsvDataGenerator.new(file, params[:price])
    csvData = generator.generate_asn_data
    details_xls = AsnGenerator::generate_details_xls(template, csvData, params)
    send_file details_xls, :filename => filename_final.xls
  rescue Exception => e
    "Error genertaing details file, Exception:" + e.message
  end
  else
    "No file selected or Price not entered!!"
end

post "/po_details" do
  if params[:asn_file] && params[:price]
    filename = params[:asn_file][:filename]
    file = params[:asn_file][:tempfile]
  begin
    generator = CsvDataGenerator.new(file, params[:price])
    csvData = generator.generate_asn_data
    details_xls = AsnGenerator::generate_details_xls(template, csvData, params)
    send_file details_xls, :filename => filename_final.xls
  rescue Exception => e
    "Error genertaing details file, Exception:" + e.message
  end
  else
    "No file selected or Price not entered!!"
end

post "/final_csv" do
  if params[:asn_file] && params[:price]
      filename = params[:asn_file][:filename]
      file = params[:asn_file][:tempfile]
  begin
    generator = CsvDataGenerator.new(file, params[:price])
    finalCsv = generator.generate_asn_data()
    if finalCsv.strip.empty?
      return "Invalid CSV could not find any Data"
    end
    finalCsvFile = FileGenerator.generateCsvFile(finalCsv)

    finalFileName = filename.gsub ".csv", ""
    finalFileName += "_final.csv"
    send_file finalCsvFile , :filename => finalFileName
    redirect '/'
  rescue Exception => e
    "Error in processing the csv file. Ensure valid csv file was selected with correct table values. Exception:" + e.message
  end
   else 
    "No file selected or Price not entered!!"
end
end
