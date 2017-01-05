require_relative './StockStreamsAnalyzer'
require_relative './StockDataDownloader'

def main
  p "Starting downloading Historical stock data"
  p "*************" * 5
  sdd = StockDataDownloader.new
  sdd.download_stock_data
  st = StockStreamsAnalyzer.new
  st.analyze
end


main()
