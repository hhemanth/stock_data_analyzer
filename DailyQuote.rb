class DailyQuote
  attr_reader :sym,:date,:open,:high,:low,:close,:volume,:adj_close,:daily_gain
  attr_accessor :prev_close

  #convert a row of csv to a dailyquote object
  def initialize(sym,row)
    @sym=sym
    @date=row[0]
    @open=row[1].to_f
    @high=row[2].to_f
    @low=row[3].to_f
    @close=row[4].to_f
    @volume=row[5].to_i

  end

  def populate_prev_close(dq)
    @prev_close = dq.close
    calc_opp_long
    calc_opp_short
    calc_daily_gain
  end

  def calc_opp_long
    (@opp_long = @high - @prev_close) if !@prev_close.nil?

  end

  def calc_opp_short
    (@opp_short = @low - @prev_close) if !@prev_close.nil?
  end

  def get_opp(isBottom)

    opp = isBottom ? @opp_short : @opp_long
    return 0 if opp.nil?
    return opp
  end

  def calc_daily_gain
    @daily_gain = ( @close - @prev_close ) *100 / @prev_close
  end

  def to_s
    print @sym + " : " + @close.to_s + " : " + @prev_close.to_s
  end

  def details
    puts "-----------------------"
    puts "sym : " + @sym
    puts "date : " + @date.to_s
    puts "open  : " + @open.to_s
    puts "high : " + @high.to_s
    puts "low : " + @low.to_s
    puts "close : " + @close.to_s
    puts "vol : " + @volume.to_s
    puts "adj close : "  + @adj_close.to_s
    puts "prev close : " + @prev_close.to_s
    opp = @opp_long.nil? ? @opp_short : @opp_long
    puts "opp1 : " + opp.to_s
  end
  def debug_opp
    opp = @opp_long.nil? ? @opp_short : @opp_long
    puts @date + " , " + @close.to_s + " , " + @high.to_s + " , " +  @prev_close.to_s + " , " + opp.round(2).to_s unless opp.nil?
  end

end
