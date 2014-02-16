module AsnGenerator

  DATA_START_INDEX = 20

  def generate_details_xls(template, csv_rows, params)
    sheet = template.worksheet 0
    add_fixed_details sheet, params
    add_csv_rows sheet, csv_rows
    template.write "final.xls"
    File.open "final.xls"
  end
  
  def add_fixed_details(sheet, params)
     sheet[7,3] = params[:po_no] || ''
     sheet[8,3] = params[:total_quantity] || ''
     sheet[9,3] = params[:total_value] || ''
     sheet[10,3] = params[:quality_check_date] || ''
     sheet[11,3] = params[:bill_no] || ''
     sheet[12,3] = params[:way_bill_no] || ''
     sheet[13,3] = params[:dispatch_date] || ''
     sheet[14,3] = params[:arrival_date] || ''
  end

  def add_csv_rows(sheet, csv_rows)
    index = DATA_START_INDEX
     csv_rows.each do |row|
       sheet.row(index).replace row
       index += 1
     end
  end
end


