# Readable is the helper module for more readable result.
module Readable
  
  GIGA_SIZE = 1073741824.0
  MEGA_SIZE = 1048576.0
  KILO_SIZE = 1024.0
  
  # Return the file size with a readable style.
  def readable_file_size(size, precision)
    case
      when size == 1 : "1 Byte"
      when size < KILO_SIZE : "%d Bytes" % size
      when size < MEGA_SIZE : "%.#{precision}f KB" % (size / KILO_SIZE)
      when size < GIGA_SIZE : "%.#{precision}f MB" % (size / MEGA_SIZE)
      else "%.#{precision}f GB" % (size / GIGA_SIZE)
    end
  end  
  
  # Return the size splitted with comma each 3 digits.
  def readable_size(size)
    parts = size.to_s.split(".")
    parts[0].gsub!(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1,")
    parts.join(".")
  end
  
  def number_to_percentage(number, precision)
    number_precision(number, precision) + '%'
  end
  
  # Return the number with precision after a dot.
  def number_precision(number, precision)
    "%0.#{precision}f" % number
  rescue
    number
  end
end