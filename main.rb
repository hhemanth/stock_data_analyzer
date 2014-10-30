require './StockStreamsAnalyzer'
require './StockDataDownloader'

def main
  sdd = StockDataDownloader.new
  sdd.download_stock_data
  st = StockStreamsAnalyzer.new
  st.analyze
end


main()
