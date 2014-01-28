require "rubygems"
require "sinatra"
require File.join File.dirname(__FILE__), 'asn_generator'
require File.join File.dirname(__FILE__), 'file_generator'

get "/" do
  send_file File.join(settings.public_folder, 'asn.html')
end

post "/final_csv" do
  if params[:asn_file]
      filename = params[:asn_file][:filename]
      file = params[:asn_file][:tempfile]
  begin
    generator = AsnGenerator.new(file, params[:price])
    finalCsv = generator.generate_asn_data()
    finalCsvFile = FileGenerator.generateCsvFile(finalCsv)

    finalFileName = filename.gsub ".csv", ""
    finalFileName += "_final.csv"
    send_file finalCsvFile , :filename => finalFileName
    redirect '/'
  rescue Exception => e
    "Error in processing the csv file. Ensure valid csv file was selected with correct table values. Exception:" + e.message
  end
   else 
    "No file selected !!"
end
end
