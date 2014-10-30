#download daily and weekly prices of 50 stocks.
require 'open-uri'
require 'date'
require 'CSV'
require './config'
require 'net/http'

@weekly_gain = Hash.new
BASE_URL = "http://real-chart.finance.yahoo.com/table.csv?"


def url_builder(stock_sym,start_date,end_date,daily_or_weekly)
  base_url = BASE_URL
  base_url = base_url + "s=" + stock_sym + "&"
end


def build_file_name(stock_sym,no_of_days,daily_or_weekly)
  base_dir = ""
end

def save_to_file(file,res)
  if res.code == '200'
    puts "Saved to file"
    file << res.body
    return 200
  else
      return 400
  end
end

def get_res(file,uri)
  i =0
  while i < 5
    puts "Retrying " + i.to_s
    res = Net::HTTP.get_response(uri)
    save_to_file(file,res)
    i+=1
    if res.code == '200' || i > 5
      break
    end

  end

end

#build the file name
#build the url
def download_csv(stock_url,filename)
  uri = URI(stock_url)
  sleep(1)
  open(filename, 'wb') do |file|
      get_res(file,uri)

  end
  #open(filename, 'wb') do |file|
  #  file << open(stock_url).read
  #end
end

def read_csv(file_name)

  puts "calculating for " + file_name

  first_val = true
  i=0

 start_val =0
 CSV.foreach(file_name,:headers=>true) do |row|
    if(first_val)
      first_val = false
      start_val = row[4]
      puts "start_val" + start_val
    elsif(i==4)
      end_val = row[4]
      puts "end_val" + end_val

      percent_change = ((start_val.to_f - end_val.to_f) * 100)/end_val.to_f
      puts "percent change : " + percent_change.round(2).to_s
      @weekly_gain[file_name]=percent_change
      puts "----------------------------"
      puts ""

      break
    end#end if
    i=i+1

 end #end CSV

end #end def

def analyze(s_file,isBottom)
  #puts "analyzing ........." + s_file
  avg=0
  noPositives=0
  noNegatives=0
  highOpp=0
  lowOpp=10000
  total =0
  prev_high =0
  prev_low =0
  sum =0
  CSV.foreach(s_file,:headers=>true) do |row|
    cur_close = row[4]
    if prev_high == 0
      prev_high = row[2]
      next
    end

     if prev_low == 0
      prev_low = row[3]
      next
    end


    if !isBottom
      opp = prev_high.to_f - cur_close.to_f
      puts row[0] + " , " + prev_high.to_s + "  -  " + cur_close.to_s + "=" + opp.round(2).to_s

    else
     # puts s_file + " , " + row[0].to_s + " , " + opp.round(2).to_s
      opp = prev_low.to_f - cur_close.to_f
    end
    #puts s_file + " , " + row[0].to_s + " , " + opp.round(2).to_s

    sum += opp
    total += 1
    if opp > 0
      noPositives += 1
    else
      noNegatives += 1
    end

    if opp > highOpp
      highOpp = opp
    end

    if opp < lowOpp
      lowOpp = opp
    end
    prev_high = row[2]
  end

  avg = sum.to_f/ total
  csv_str = s_file + "," + noPositives.to_s + ","  + noNegatives.to_s + "," + avg.round(2).to_s + "," + highOpp.round(2).to_s + "," + lowOpp.round(2).to_s
  return csv_str
end

def write_csv_file(lines_arr,is_bottom)
  if is_bottom
    file_name = "loosers"
  else
    file_name = "gainers"
  end
  t = Time.now

  file_name = file_name + t.day.to_s + "-" + t.month.to_s + "-" +t.year.to_s + ".csv"
    open(file_name, 'wb') do |f|
      f.puts "Stock,noPositives,noNegatives,average,highOpp,lowOpp"
    end

    open(file_name, 'a') do |f|
      lines_arr.each { |l|
      f.puts l
    }
  end
  #write to file
end

def analyze_st(sts,isBottom)
  sts_files = sts.keys
  puts "analyzing stocks" + sts.keys.to_s
  csv_lines_arr = Array.new
  sts_files.each { |s_file|
    csv_lines_arr.push(analyze(s_file,isBottom))
    exit
  }
  write_csv_file(csv_lines_arr,isBottom)

end

def get_Highest_Lowest
  @weekly_gain_top = @weekly_gain.sort_by {|k,v| v}.reverse
  @weekly_gain_bot = @weekly_gain.sort_by {|k,v| v}

  top5 = Hash.new
  bottom5 = Hash.new
  i=0
  @weekly_gain_top.each { |w|
    top5[w[0]] = w[1]
    i=i+1
    if i==5
      break
    end

  }

 i=0
   @weekly_gain_bot.each { |w|
    bottom5[w[0]] = w[1]
    i=i+1
    if i==5
      break
    end

  }

  puts "5 top stocks"

  puts top5

    puts "5 bottom stocks"

  puts bottom5
  analyze_st(top5,false)
  #analyze_st(bottom5,true)


end

def get_date_url
  ##to date
  t= Time.new
  #
  d = t.month - 1
  e = t.day
  f = t.year

  a = d
  b = e
  c = f - 1

  #STOCK_DATE_URL = "&a=06&b=20&c=2013&d=08&e=01&f=2014&g=d&ignore=.csv"
  from_date_url = "&a=" + a.to_s + "&b=" + b.to_s + "&c=" + c.to_s
  to_date_url = "&d=" + d.to_s + "&e=" + e.to_s + "&f=" + f.to_s
  date_url = from_date_url + to_date_url + "&g=d&ignore=.csv"
  return date_url

end

def main
  stock_sym_list_str = ""
  print ALL_STOCK_SYMBOLS
  stock_arr = ALL_STOCK_SYMBOLS.split()
  puts ""
  #got all the symbols
  date_url = get_date_url()
  download_url_arr = Array.new()
  stock_arr.each { |st|
    download_url = BASE_URL + "s=" + st + date_url
    download_url_arr.push(download_url)
    file_name = "data/" + st
    puts download_url
    download_csv(download_url,file_name)
  }

  stock_arr.each { |st|
    file_name = "data/" + st
    read_csv(file_name)
  }
  #print stock_arr
  get_Highest_Lowest

end

main()

