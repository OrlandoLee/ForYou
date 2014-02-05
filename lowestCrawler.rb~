require "rubygems"
require "nokogiri"
require "open-uri"



def processLowestLevelPage(url)

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
    podcastName = '"'+podcastInfo['podcast-name'].gsub(/[\r,\n]/,'').strip+'"'
   end
  #  print podcastId+","
 #   print podcastName+","

    contentBox = page.css("div[class=tracklist-content-box]")
   if contentBox.nil?
	return
   end
    lastestEntry = contentBox.css("tbody").css("tr")[0]
  if lastestEntry.nil?
	return
   end
#TO-DO
#link should compare with last time
#if same do not update
#if not update and also flag


     episodeNameEntry = lastestEntry.css("td[class='name flexible-col']")
     unless episodeNameEntry.nil?
	episodeName = '"'+episodeNameEntry.text.gsub(/[\r,\n]/,'').strip+'"'
    end

    episodeDiscriptionEntry = lastestEntry.css("td[class='description flexible-col']")
    unless episodeDiscriptionEntry.nil?
	episodeDescription = '"'+episodeDiscriptionEntry.text.gsub(/[\r,\n]/,'').strip+'"'
    end

   	 unless lastestEntry.nil?
	   unless lastestEntry['preview-artist'].nil?
   	   	artist = '"'+lastestEntry['preview-artist'].gsub(/[\r,\n]/,'').strip+'"'
           end
   	   unless lastestEntry['audio-preview-url'].nil?
   	   	link = '"'+lastestEntry['audio-preview-url'].gsub(/[\r,\n]/,'').strip+'"' 
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

	result = result + ","+episodeName+","+episodeDescription
end

puts processLowestLevelPage("https://itunes.apple.com/cn/podcast/you-de-liao-bo-ke/id493254305?mt=2")

