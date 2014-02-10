require "csv"
require 'date'
def group_value(a)
  a.group_by do |e|
    e
  end.values.max_by(&:size)
end

f2 = File.new("crawl_data_table.csv", "w")
CSV.foreach("result.csv") do |row|
  cycle=[]
  count=0
  date = CSV.parse(row[4])[0]
  id = row[0]
  parentUrl = row[6]
  lastUpdateDate = DateTime.now
  newDate =[]
  cycleNum=0
unless date.nil?
  for i in 0..date.size-1
    unless date[i].nil?
      newDate[i] = date[i].gsub(/[年月]/,'-').chop
    end
  end
 unless newDate[0].nil?
 if Date.parse(newDate[0])>Date.parse("13-12-1")
 #print newDate
 for i in 0..newDate.size-2
    cycle[count]=(Date.parse(newDate[i])-Date.parse(newDate[i+1])).to_i
    count = count+1
  end 
  #print cycle
  groupedValue = group_value(cycle)
  unless groupedValue.nil?
   puts id
    if groupedValue.first==0
       cycleNum = (cycle.instance_eval { reduce(:+) / size.to_f } ).to_i
       cycleNum = cycleNum==0 ? 1 : cycleNum
    else
       cycleNum = groupedValue.first
    end
  f2.puts '"'+id+'",'+'"'+parentUrl+'",'+'"'+cycleNum.to_s+'",' + '"'+lastUpdateDate.to_s+'"'
  end
  
  end
  end
end


end 
