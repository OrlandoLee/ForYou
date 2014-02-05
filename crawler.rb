require "rubygems"
require "nokogiri"
require "open-uri"

count = 0

def processLowestLevelPage(url)

  page = Nokogiri::HTML(open(url))
  leftStack = page.css("div[id=left-stack]")
  topicEntry = leftStack.css("li[class=genre]")
  language = ""
  topic = ""
  podcastId = ""
  podcastName = ""
  artist = ""
  link = ""
  discription = ""
  unless topicEntry.nil?
    topic = topicEntry.css("a")[0].text.gsub(/[,]/, ',' => ' ') 
  end
  languageEntry = leftStack.css("li[class=language]")
  unless languageEntry.nil?
    language = languageEntry[0].text
  end
  if language == "语言: 中文"
    podcastInfo = page.css("div").select{|podcastId| podcastId['podcast-id']}[0]
    unless podcastInfo['podcast-id'].nil?
    podcastId = podcastInfo['podcast-id']
    end
    unless podcastInfo['podcast-name'].nil?
    podcastName = podcastInfo['podcast-name'].gsub(/[,]/, ',' => ' ') 
    end
    print podcastId+","
    print podcastName+","
    print topic+","
    print language+","

#link should compare with last time
#if same do not update
#if not update and also flag
    discriptionEntry = page.css("div[metrics-loc=Titledbox_描述]").css("p")
    unless discriptionEntry.nil?
	discription = '"'+discriptionEntry.text+'"'
	#puts discription
    end
    contentBox = page.css("div[class=tracklist-content-box]")
   
    lastestEntryArray = contentBox.css("tbody").css("tr")
    unless lastestEntryArray.nil?
    lastestEntryArray = lastestEntryArray[0..[lastestEntryArray.size,15].min]
    lastestEntry = lastestEntryArray[0]
    result = ""

   	 unless lastestEntry.nil?
	   unless lastestEntry['preview-artist'].nil?
   	   	artist = lastestEntry['preview-artist'].gsub(/[,]/, ',' => ' ') 
           end
   	   unless lastestEntry['audio-preview-url'].nil?
   	   	link = lastestEntry['audio-preview-url']
           end
   	 end
    	print artist+","
    	print link
	puts 
   
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
	end 
	releaseDate = '"'
	lastestEntryArray.each do |row|
	    releaseDateEntry = row.css("td[class=release-date]")
	    unless releaseDateEntry.nil? 
		releaseDate =releaseDate + releaseDateEntry.text.strip+','
	    end	
	end
	releaseDate = releaseDate.chop + '"' 
	#puts releaseDate  

   	result+","+releaseDate +","+discription  
        else
	
	end

end

def processThirdLevel( topic,thirdLevelUrl)
	thirdLevelPage =  Nokogiri::HTML(open(thirdLevelUrl))
	File.open('result.txt', 'a') do |f2|  
         
 	  firstColumn = thirdLevelPage.css("div[class='column first']").css("li")
  	  firstColumn.each do |singlePage|
		#puts singlePage.text
		url = 	singlePage.css("a")[0]["href"]
		result = processLowestLevelPage(url)
		if topic.nil? 
		  f2.puts "topic.nil"
		elsif result.nil?
		  
		else	
		  f2.puts result+","+topic
		end
	  end
	  f2.close
	end

	File.open('result.txt', 'a') do |f2| 
	  secondColumn = thirdLevelPage.css("div[class='column']").css("li")
          secondColumn.each do |singlePage|
		#puts singlePage.text
		url = 	singlePage.css("a")[0]["href"]
		result = processLowestLevelPage(url)
		if topic.nil? 
		  f2.puts "topic.nil"
		elsif result.nil?
		  
		else	
		  f2.puts result+","+topic
		end
	  end
	  f2.close
	end

	File.open('result.txt', 'a') do |f2|
	 lastColumn = thirdLevelPage.css("div[class='column last']").css("li")  
	 lastColumn.each do |singlePage|
		#puts singlePage.text
		url = 	singlePage.css("a")[0]["href"]
		result = processLowestLevelPage(url)
		if topic.nil? 
		  f2.puts "topic.nil"
		elsif result.nil?
		  
		else	
		  f2.puts result+","+topic
		end
	  end
	 f2.close
	end
end


rootUrl = "https://itunes.apple.com/cn/genre/podcast/id26?mt=2"
page = Nokogiri::HTML(open(rootUrl))
topLevelTopics = page.css("a[class=top-level-genre]")
topLevelTopics.each do |topLevelTopic|#each
###  puts topLevelTopic.text
#  puts topLevelTopic["href"]

##TO-DO
#need to more encapsulated for each part we need to print out OK when it has finished

  nextPage = Nokogiri::HTML(open(topLevelTopic["href"]))
  children = nextPage.css("ul[class='list top-level-subgenres']")
  thirdLevelUrl =""
  if children.size>0
        children.css("a").each do |lowerTopic|
	  topic = topLevelTopic.text+","+lowerTopic.text
          #puts lowerTopic["href"]
	  thirdLevelUrl = lowerTopic["href"]
	  
          processThirdLevel(topic,thirdLevelUrl)
	end
  else
	lowerLevel = nextPage.css("a[class='selected top-level-genre']")
	topic =  lowerLevel.text
	#puts lowerLevel[0]["href"]
	thirdLevelUrl = lowerLevel[0]["href"]

	processThirdLevel(topic,thirdLevelUrl)
 	
	
  end

end




