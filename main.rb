require_relative './StockStreamsAnalyzer'
require_relative './StockDataDownloader'

def main
  sdd = StockDataDownloader.new
  sdd.download_stock_data
  st = StockStreamsAnalyzer.new
  st.analyze
end


main()
