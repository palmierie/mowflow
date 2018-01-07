class ReportPdf < Prawn::Document
  def initialize(jobs, business_name)
    super()
    @jobs = jobs
    @business_name = business_name
    text_content
    table_content
  end

  def text_content
    y_position = cursor - 50
    @day = Date.today.strftime("%A")
    @date = Date.today.strftime("%F")
    text "#{@day}'s Schedule - #{@date} - #{@business_name}", size: 18, style: :bold
  end

  def table_content
    # This makes a call to product_rows and gets back an array of data that will populate the columns and rows of a table
    table product_rows do
      row(0).font_style = :bold
      self.header = true
      self.row_colors = ['DDDDDD', 'FFFFFF']
      self.column_widths = [100, 220, 185, 35]
      self.cell_style = {:size => 10}
    end
  end

  def product_rows
    [['Job Name', 'Address', 'Notes','Done']] +
      @jobs.map do |job|
      [job.location_desc, "#{job.street_address}, #{job.city}, #{job.state}", job.user_notes,""]
    end
  end
end