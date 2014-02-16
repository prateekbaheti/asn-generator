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
    packing_list_file = params[:asn_file][:tempfile]
  #begin
    puts "params are #{params}"
    generator = CsvDataGenerator.new(packing_list_file, params)
    csv_rows = generator.generate_asn_data
    details_xls = AsnGenerator::generate_details_xls(template, csv_rows, params)
    send_file details_xls , :filename => "filename_final.xls"
  #rescue Exception => e
  #  "Error genertaing details file, Exception:" + e.message
  #end
  else
    "No file selected or Price not entered!!"
 end
end

