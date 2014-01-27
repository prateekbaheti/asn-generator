require "rubygems"
require "sinatra"
require File.join File.dirname(__FILE__), 'asn'

get "/" do
  send_file File.join(settings.public_folder, 'asn.html')
end

post "/upload" do
  if params[:asn_file]
      filename = params[:asn_file][:filename]
      file = params[:asn_file][:tempfile]

      readCsv(file)
  else 
    "No file found oops !!"
end
end
