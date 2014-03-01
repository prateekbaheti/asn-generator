
module PoTextReader
  def read_po_text(params)
    data = Array.new
    po_file = params[:po_text_file][:tempfile]
    lines = po_file.read.split("\n")
    lines.each_with_index {|l,i| data[i] = l.split("\t").collect {|x| x.strip}  }
    params[:po_number] = data[0][0] || ""
    params[:po_data] = data
  end
end
