require "rubygems"
require "sinatra"
require File.join File.dirname(__FILE__), 'packing_data_generator'
require File.join File.dirname(__FILE__), 'asn_generator'
require File.join File.dirname(__FILE__), 'file_generator'
require File.join File.dirname(__FILE__), 'po_text_reader'

include AsnGenerator
include PoTextReader

get "/" do
  send_file File.join(settings.public_folder, 'asn_complete.html')
end

post "/po_details" do
  if params[:packing_list_file] && params[:po_text_file]
  #begin
    puts "params are #{params}"
    PoTextReader::read_po_text(params)
    generator = PackingListDataGenerator.new(params)
    packing_rows = generator.generate_packing_data

    if (packing_rows.nil?)
      return "No Packing List data data correspondong to PO data found. Check files added."
    end

    details_xls = AsnGenerator::generate_details_xls(packing_rows, params)
    send_file details_xls , :filename => "details_#{params[:po_number]}"
  #rescue Exception => e
  #  "Error genertaing details file, Exception:" + e.message
  #end
  else
    "No Packing list file or PO text file selected"
 end
end

