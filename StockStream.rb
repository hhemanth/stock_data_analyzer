require_relative './DailyQuote'
require 'csv'

class StockStream
  attr_reader :sym, :daily_quotes_arr, :cur_weekly_gain, :no_positives, :no_negatives,:streak_num,:streak_gain

  def doSkip(row)
    volume=row[5].to_i
    return true if volume == 0
    return false
  end

  def initialize(sym,file_name)
    @sym=sym

    #read csv file
    @daily_quotes_arr = Array.new
    cur_dq = nil
    CSV.foreach(file_name,:headers=>true) do |row|
      #todo1
      #skip if it is weekend
      next if doSkip(row)
      dq = DailyQuote.new(sym,row)
      @daily_quotes_arr.push(dq)
      #the array itself is in reverse chronological order,
      #so cur row is actually prev row
      cur_dq.populate_prev_close(dq) if cur_dq != nil
      cur_dq=dq
    end

    calc_weekly_gain
  end

  def to_s
    @daily_quotes_arr.each { |dq|
      puts dq.to_s
    }
  end

  def calc_weekly_gain
    puts @daily_quotes_arr[0].to_s
    cur_close = @daily_quotes_arr[0].close
    prev_close = @daily_quotes_arr[4].close
    @cur_weekly_gain = (cur_close - prev_close)  * 100  / prev_close
  end



  def get_streak()

    puts "calculating streak for " + sym
    break_loop = false
    init_gain = @daily_quotes_arr[0].daily_gain

    init_gain > 0 ? isPositive = true : isPositive=false

    @streak_num = 0
    @streak_gain = 0

    @daily_quotes_arr.each { |d|
      gain = d.daily_gain
      gain > 0 ? cur_isPositive = true : cur_isPositive = false

      if(cur_isPositive == isPositive)

        @streak_num +=1
        @streak_gain += gain
        puts sym + " | " + gain.round(2).to_s + " | " + @streak_num.to_s
      else
        break_loop = true
      end
      break if break_loop
    }


  end


  def analyze(isBottom)
    #count no of positives,
    avg=0
    noPositives=0
    noNegatives=0
    highOpp=0
    lowOpp=10000
    total =0
    sum = 0
    puts "================"
    @daily_quotes_arr.each { |d|
      #d.debug_opp
      opp=d.get_opp(isBottom)
      puts d.sym + " , " + opp.round(2).to_s
      sum += opp
      total += 1
      opp > 0 ? (noPositives += 1) : (noNegatives += 1)
      highOpp = opp if opp > highOpp
      lowOpp = opp if opp < lowOpp
    }

    get_streak()

    avg = sum.to_f/ total
    csv_str = sym + "," + noPositives.to_s + ","  + noNegatives.to_s + "," + avg.round(2).to_s + "," + highOpp.round(2).to_s + "," + lowOpp.round(2).to_s + "," + @streak_num.to_s + " , " + @streak_gain.round(2).to_s
    return csv_str

  end


end
