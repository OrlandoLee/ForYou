require "csv"
require 'date'
require "nokogiri"
require "open-uri"

def processLowestLevelPage(url)

  page = Nokogiri::HTML(open(url))
  releaseDate = ""
 
    podcastInfo = page.css("div").select{|podcastId| podcastId['podcast-id']}[0]
    contentBox = page.css("div[class=tracklist-content-box]")
    lastestEntryArray = contentBox.css("tbody").css("tr")
    unless lastestEntryArray.nil?
    lastestEntryArray = lastestEntryArray[0..[lastestEntryArray.size,15].min]
    lastestEntry = lastestEntryArray[0]

   	 unless lastestEntry.nil?
		releaseDateEntry = lastestEntry.css("td[class=release-date]")
	    unless releaseDateEntry.nil? 
		releaseDate = releaseDateEntry.text.gsub(/[\r,\n,\"]/,'').strip.gsub(/[年月]/,'-').chop
	    end	
   	 end
    end 
end

f2 = File.new("crawl_data_table_1.csv", "w")
CSV.foreach("crawl_data_table.csv","r") do |row|
  date = CSV.parse(row[3])[0][0]
  id = row[0]
  parentUrl = row[1]
  recentRelease = processLowestLevelPage(parentUrl)
  flag = "0"
  lastUpdateDate = ""
  unless recentRelease.nil?
    if(Date.parse(date)>=Date.parse(recentRelease))
	lastUpdateDate =  date
	flag = "0" 
    else
	lastUpdateDate = recentRelease
	flag = "1" 
    end
  else
    lastUpdateDate =  date
	flag = "0" 
  end
  puts row[0]

  f2.puts '"'+row[0]+'"'+","+'"'+row[1]+'"'+","+'"'+row[2]+'"'+","+'"'+lastUpdateDate+'"'+","+flag
end 
f2.close
File.rename("crawl_data_table_1.csv","crawl_data_table.csv")
