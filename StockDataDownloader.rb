require_relative './config'
class StockDataDownloader

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

  def download_stock_data
    stock_arr = ALL_STOCK_SYMBOLS
    puts ""
  #got all the symbols
    date_url = get_date_url()
    download_url_arr = Array.new()

    stock_arr.each { |st|
      download_url = BASE_URL + "s=" + st + date_url
      download_url_arr.push(download_url)
      file_name = "#{BASE_PATH}/data/" + st
      puts download_url
      download_csv(download_url,file_name)
    }
  end

   def download_stock_data_new
    stock_arr = ALL_STOCK_SYMBOLS
    puts ""
  #got all the symbols
    date_url = get_date_url()
    download_url_arr = Array.new()

    stock_arr.each { |st|
      download_url = "https://www.quandl.com/api/v3/datasets/NSE/#{st.split('.')[0]}.csv?api_key=7xcyJqy5Nsrh2ZUieXxX"
      download_url_arr.push(download_url)
      file_name = "#{BASE_PATH}/data/" + st
      puts download_url
      download_csv(download_url,file_name)
    }
  end

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
      res = Net::HTTP.get_response(uri) rescue "rescued"
      i+=1
      p res
      next if res == "rescued"
      save_to_file(file,res)
      if res.code == '200' || i > 5
        break
      end

    end

  end

end
