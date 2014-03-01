require "rubygems"
require "spreadsheet"
require "sinatra"
require File.join File.dirname(__FILE__), 'csv_generator'
require File.join File.dirname(__FILE__), 'asn_generator'
require File.join File.dirname(__FILE__), 'file_generator'
require File.join File.dirname(__FILE__), 'po_text_reader'

include AsnGenerator
include PoTextReader

template = Spreadsheet.open 'template/asn_template.xls'
puts "Got the template****"

get "/" do
  send_file File.join(settings.public_folder, 'asn_complete.html')
end

post "/po_details" do
  if params[:asn_file] && params[:po_text_file]
  #begin
    puts "params are #{params}"
    PoTextReader::read_po_text(params)
    generator = CsvDataGenerator.new(params)
    csv_rows = generator.generate_asn_data
    if (csv_rows.nil?)
      return "No CSV data correspondong to PO data found. Check files added."
    end
    details_xls = AsnGenerator::generate_details_xls(template, csv_rows, params)
    send_file details_xls , :filename => "details_#{params[:po_number]}"
  #rescue Exception => e
  #  "Error genertaing details file, Exception:" + e.message
  #end
  else
    "No CSV file or PO text file selected"
 end
end

