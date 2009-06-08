class Output
  
  def self.to_excel(file_name, code_statistics)
    require 'win32ole'
    # Create an instance of the Excel application object
    xl = WIN32OLE.new('Excel.Application')
    #xl.Visible = 1
    # Add a new Workbook object
    wb = xl.Workbooks.Add
    # Get the first Worksheet
    ws1 = wb.Worksheets(1)
    # Set the name of the worksheet tab
    ws1.Name = 'Total count'
    ws1.Cells(1, 1).Value = 'Total files'
    ws1.Cells(1, 2).Value = 'Total size'
    ws1.Cells(1, 3).Value = 'Total lines'
    ws1.Cells(2, 1).Value = code_statistics.readable_total_files
    ws1.Cells(2, 2).Value = code_statistics.readable_total_size
    ws1.Cells(2, 3).Value = code_statistics.readable_total_lines
    
    ws1.Cells(4, 1).Value = 'Code lines'
    ws1.Cells(4, 2).Value = 'Comment lines'
    ws1.Cells(4, 3).Value = 'Blank lines'
    ws1.Cells(5, 1).Value = code_statistics.readable_code_lines
    ws1.Cells(5, 2).Value = code_statistics.readable_comment_lines
    ws1.Cells(5, 3).Value = code_statistics.readable_blank_lines
    
    ws1.Cells(7, 1).Value = 'Code line percentage'
    ws1.Cells(7, 2).Value = 'Comment line percentage'
    ws1.Cells(7, 3).Value = 'blank line percentage'
    ws1.Cells(8, 1).Value = code_statistics.code_line_percentage
    ws1.Cells(8, 2).Value = code_statistics.comment_line_percentage
    ws1.Cells(8, 3).Value = code_statistics.blank_line_percentage
    ws1.Columns.AutoFit
    
    ws2 = wb.Worksheets(2)
    ws2.Name = 'Each file count'
    ws2.Cells(1, 1).Value = 'File'
    ws2.Cells(1, 2).Value = 'Directory'
    ws2.Cells(1, 3).Value = 'Total lines'
    ws2.Cells(1, 4).Value = 'Code lines'
    ws2.Cells(1, 5).Value = 'Comment lines'
    ws2.Cells(1, 6).Value = 'Blank lines'
    ws2.Cells(1, 7).Value = 'File type'
    i = 2;
    code_statistics.results.each do |result|
      ws2.Cells(i, 1).Value = result.file_name
      ws2.Cells(i, 2).Value = result.dir_name
      ws2.Cells(i, 3).Value = result.readable_total_lines
      ws2.Cells(i, 4).Value = result.readable_code_lines
      ws2.Cells(i, 5).Value = result.readable_comment_lines
      ws2.Cells(i, 6).Value = result.readable_blank_lines
      ws2.Cells(i, 7).Value = result.file_type
      i+= 1
    end
    ws2.Columns.AutoFit
    # Save the workbook
    wb.SaveAs(file_name)
    # Close the workbook
    wb.Close
    # Quit Excel
    xl.Quit
  end
  
  def self.to_html(file_name, code_statistics)
    File.open(file_name, 'w') do |file|
      file.puts "<html>"
      file.puts "<head>"
      file.puts "<title>Code Line Statistics</title>"
      file.puts "<style type=\"text/css\">"
      file.puts "<!—"
      file.puts STYLE
      file.puts "-->"
      file.puts "</style>"
      file.puts "</head>"
      file.puts "<body>"
      file.puts "<h1>Code Line Statistics -- #{code_statistics.base_dir}</h1>"
      file.puts "<table class=\"details\" cellpadding=\"5\" cellspacing=\"2\" border=\"0\" width=\"95%\">"
      file.puts "<tr valign=\"top\">"
      file.puts "<th>Total files</th><th>Total size</th><th>Total lines</th><th>Code lines</th><th>Comment lines</th><th>Blank lines</th>"
      file.puts "</tr>"
      file.puts "<tr valign=\"top\">"
      file.puts "<td>#{code_statistics.readable_total_files}</td><td>#{code_statistics.readable_total_size}</td><td>#{code_statistics.readable_total_lines}</td><td>#{code_statistics.readable_code_lines}</td><td>#{code_statistics.readable_comment_lines}</td><td>#{code_statistics.readable_blank_lines}</td>"
      file.puts "</tr>"
      file.puts "</table>"
      file.puts "<br />"
      file.puts "<table class=\"details\" cellpadding=\"5\" cellspacing=\"2\" border=\"0\" width=\"95%\">"
      file.puts "<tr valign=\"top\">"
      file.puts "<th>Code Line Percentage</th><th>Comment Line Percentage</th><th>Blank Line Percentage</th>"
      file.puts "</tr>"
      file.puts "<tr valign=\"top\">"
      file.puts "<td>#{code_statistics.code_line_percentage}</td><td>#{code_statistics.comment_line_percentage}</td><td>#{code_statistics.blank_line_percentage}</td>"
      file.puts "</tr>"
      file.puts "</table>"
      file.puts "<br />"
      file.puts "<table class=\"details\" cellpadding=\"5\" cellspacing=\"2\" border=\"0\" width=\"95%\">"
      file.puts "<tr valign=\"top\">"
      file.puts "<th>File</th><th>Directory</th><th>Total lines</th><th>Code lines</th><th>Comment lines</th><th>Blank lines</th><th>File type</th>"
      file.puts "</tr>"
      code_statistics.results.each do |result|
        file.puts "<tr valign=\"top\">"
        file.puts "<td>#{result.file_name}</td><td>#{result.dir_name}</td><td>#{result.readable_total_lines}</td><td>#{result.readable_code_lines}</td><td>#{result.readable_comment_lines}</td><td>#{result.readable_blank_lines}</td><td>#{result.file_type}</td>"
        file.puts "</tr>"
      end
      file.puts "</table>"
      file.puts "</body>"
      file.puts "</html>"
    end
  end
  
  # html css style
  STYLE =<<END
body {
    font:normal 68% verdana,arial,helvetica;
    color:#000000;
}
table tr td, table tr th {
    font-size: 68%;
}
table.details tr th{
    font-weight: bold;
    text-align:left;
    background:#a6caf0;
}
table.details tr td{
    background:#eeeee0;
}

p {
    line-height:1.5em;
    margin-top:0.5em; margin-bottom:1.0em;
}
h1 {
    margin: 0px 0px 5px; font: 165% verdana,arial,helvetica
}
h2 {
    margin-top: 1em; margin-bottom: 0.5em; font: bold 125% verdana,arial,helvetica
}
h3 {
    margin-bottom: 0.5em; font: bold 115% verdana,arial,helvetica
}
h4 {
    margin-bottom: 0.5em; font: bold 100% verdana,arial,helvetica
}
h5 {
    margin-bottom: 0.5em; font: bold 100% verdana,arial,helvetica
}
h6 {
    margin-bottom: 0.5em; font: bold 100% verdana,arial,helvetica
}
.Error {
    font-weight:bold; color:red;
}
.Failure {
    font-weight:bold; color:purple;
}
.Properties {
  text-align:right;
}
END
  
end