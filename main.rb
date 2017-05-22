require_relative './StockStreamsAnalyzer'
require_relative './StockDataDownloader'

def main
  p "Starting downloading Historical stock data @ #{Time.now.localtime("+05:30").to_s}" 
  p "*************" * 5
  sdd = StockDataDownloader.new
  sdd.download_stock_data_new
  # st = StockStreamsAnalyzer.new
  # st.analyze
end


main()
