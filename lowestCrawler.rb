require "rubygems"
require "nokogiri"
require "open-uri"
require "csv"
require "date"


def processLowestLevelPage(url,f2)
  page = Nokogiri::HTML(open(url))
  leftStack = page.css("div[id=left-stack]")
  podcastId = ""
  podcastName = ""
  artist = ""
  link = ""
  episodeName = ""
  episodeDescription = ""
  result = ""
#TO-DO

   podcastInfo = page.css("div").select{|podcastId| podcastId['podcast-id']}[0]
   if podcastInfo.nil?
	return
   end
   unless podcastInfo['podcast-id'].nil?
    podcastId = podcastInfo['podcast-id']
   end
   unless podcastInfo['podcast-name'].nil?
    podcastName = '"'+podcastInfo['podcast-name'].gsub(/[\r,\n,"]/,'').strip+'"'
   end
  #  print podcastId+","
 #   print podcastName+","

    contentBox = page.css("div[class=tracklist-content-box]")
   if contentBox.nil?
	return
   end
    lastestEntryArray = contentBox.css("tbody").css("tr")
    size = 0 
    unless lastestEntryArray[size+1].nil?
      while lastestEntryArray[size].css("td[class=release-date]")==lastestEntryArray[size+1].css("td[class=release-date]")
   	size = size+1
      end 
    end
    for i in 0..size
    if i==1
      puts "duplicate!!"
    end
    result = ""
    lastestEntry = lastestEntryArray[i]
   if lastestEntry.nil?
	return
   end

     episodeNameEntry = lastestEntry.css("td[class='name flexible-col']")
     unless episodeNameEntry.nil?
	episodeName = '"'+episodeNameEntry.text.gsub(/[\r,\n,"]/,'').strip+'"'
    end

    episodeDiscriptionEntry = lastestEntry.css("td[class='description flexible-col']")
    unless episodeDiscriptionEntry.nil?
	episodeDescription = '"'+episodeDiscriptionEntry.text.gsub(/[\r,\n,"]/,'').strip+'"'
    end

   	 unless lastestEntry.nil?
	   unless lastestEntry['preview-artist'].nil?
   	   	artist = '"'+lastestEntry['preview-artist'].gsub(/[\r,\n,"]/,'').strip+'"'
           end
   	   unless lastestEntry['audio-preview-url'].nil?
   	   	link = '"'+lastestEntry['audio-preview-url'].gsub(/[\r,\n,"]/,'').strip+'"' 
           end
   	 end

    	    unless podcastId.nil? 
		result = result+podcastId+","
	    end
	    unless podcastName.nil?
		result = result+podcastName+","
	    end
	    unless artist.nil?
		result = result+artist+","
	    end
	    unless link.nil? 
		result = result+link
	    end

	result = result + ","+episodeName+","+'"'+DateTime.now.to_s+'"'+","+episodeDescription
	f2.puts result
        i = i+1
  end
end

f2 = File.new("dataForUser"+DateTime.now.to_s+".csv", "w")


count = 0
CSV.foreach("crawl_data_table.csv") do |row|
  if row[4]=="1"
    count = count +1
    print "processing num:"
    puts count
    processLowestLevelPage(row[1],f2)
  end
end
f2.close

