require "rubygems"
require "sinatra"
require File.join File.dirname(__FILE__), 'asn_generator'

get "/" do
  send_file File.join(settings.public_folder, 'asn.html')
end

post "/upload" do
  if params[:asn_file]
      filename = params[:asn_file][:filename]
      file = params[:asn_file][:tempfile]
      params.keys.each do |k|
           puts "#{k} - #{params[k]}"
      end
  begin
    generator = AsnGenerator.new(file, params[:price])
    generator.generate_asn_data()
  rescue Exception => e
    "Error in processing the csv file. Ensure valid csv file was selected with correct table values. Exception:" + e.message
  end
   else 
    "No file selected !!"
end
end
