module AsnGenerator
  def generate_details_xls(template, csv_data, params)
    sheet = template.worksheet 0
    addFixedDetails sheet, params
    template.write "final.xls"
    File.open "final.xls"
  end
  
  def addFixedDetails(sheet, params)
     sheet[7,3] = params[:po_no] || ''
     sheet[8,3] = params[:total_quantity] || ''
     sheet[9,3] = params[:total_value] || ''
     sheet[10,3] = params[:quality_check_date] || ''
     sheet[11,3] = params[:bill_no] || ''
     sheet[12,3] = params[:way_bill_no] || ''
     sheet[13,3] = params[:dispatch_date] || ''
     sheet[14,3] = params[:arrival_date] || ''
  end
end

