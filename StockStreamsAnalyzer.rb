require 'open-uri'
require 'date'
require './config'
require 'net/http'

require './StockStream.rb'
BASE_URL = "http://real-chart.finance.yahoo.com/table.csv?"


class StockStreamsAnalyzer
  attr_reader :stock_list, :top5,:bottom5,:stock_stream_arr

  def initialize
    @stock_list = ALL_STOCK_SYMBOLS.split()
    @stock_stream_arr = Array.new
    @stock_list.each { |s|
      st = StockStream.new(s,get_file(s))
      @stock_stream_arr.push(st)
    }
    build_top5_bottom5
  end

  def to_s
    puts "All Stocks"
    puts @stock_list
    puts "Top Gainers"
    puts @top5
    puts "Bottom Loosers"
    puts @bottom5
  end

  def disp_stock_prices
    @stock_stream_arr.each { |s|
      puts s
    }
  end

  def get_file(sym)
    file = "data/" + sym
  end

  def build_top5_bottom5
    @weekly_gain = Hash.new
    @stock_stream_arr.each { |stream|
      @weekly_gain[stream] = stream.cur_weekly_gain.round(2)
    }
    #puts @weekly_gain
    @top5 = Hash[@weekly_gain.sort_by {|k,v| v}.reverse.take(5)]
    @bottom5 = Hash[@weekly_gain.sort_by {|k,v| v}.take(5)]
  end

  def analyze_st(sts,isBottom)
  sts_files = sts.keys
  puts "analyzing stocks" + sts.keys.to_s
  csv_lines_arr = Array.new
  sts_files.each { |s_file|
    csv_lines_arr.push(analyze(s_file,isBottom))
  }
  write_csv_file(csv_lines_arr,isBottom)

end

  def analyze

    puts "Top 5 Stocks"
    puts "======================"

    csv_arr = Array.new()
    @top5.keys.each { |k|
      csv_arr.push(k.analyze(false))
    }

    write_csv_file(csv_arr,false)

    csv_arr = Array.new()

    puts "Bottom 5 Stocks"
    puts "======================"
    @bottom5.keys.each { |k|
      csv_arr.push( k.analyze(true))
    }

    write_csv_file(csv_arr,true)

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
        f.puts "Stock,noPositives,noNegatives,average,highOpp,lowOpp,Streak_num,STreak_gain"
      end

      open(file_name, 'a') do |f|
        lines_arr.each { |l|
        f.puts l
      }
    end
  #write to file
  end


end
