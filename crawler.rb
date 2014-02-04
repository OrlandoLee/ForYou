require "rubygems"
require "nokogiri"
require "open-uri"

count = 0

def processLowestLevelPage(url)

  page = Nokogiri::HTML(open(url))
  leftStack = page.css("div[id=left-stack]")
  topic = leftStack.css("li[class=genre]").css("a")[0].text
  language = leftStack.css("li[class=language]")[0].text
  if language == "语言: 中文"
    podcastInfo = page.css("div").select{|podcastId| podcastId['podcast-id']}[0]
    podcastId = podcastInfo['podcast-id']
    podcastName = podcastInfo['podcast-name']
    puts podcastId
  # puts podcastName
    puts topic
    puts language

#link should compare with last time
#if same do not update
#if not update and also flag

    contentBox = page.css("div[class=tracklist-content-box]")
    lastestEntry = contentBox.css("tbody").css("tr")[0]
    result = ""
    unless lastestEntry.nil?
   	 artist = lastestEntry['preview-artist']
   	 link = lastestEntry['audio-preview-url']
    	puts artist
    	puts link
     	
#    puts
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
	     result    
end
end

def processThirdLevel( topic,thirdLevelUrl)
	File.open('result.txt', 'w') do |f2|  
          thirdLevelPage =  Nokogiri::HTML(open(thirdLevelUrl))
 	  firstColumn = thirdLevelPage.css("div[class='column first']").css("li")
  	  secondColumn = thirdLevelPage.css("div[class='column']").css("li")
  	  lastColumn = thirdLevelPage.css("div[class='column last']").css("li")
  	  firstColumn.each do |singlePage|
		puts singlePage.text
		url = 	singlePage.css("a")[0]["href"]
		result = processLowestLevelPage(url)
		if topic.nil? 
		  f2.puts "topic.nil"
		elsif result.nil?
		  
		else	
		  f2.puts result+","+topic
		end
	  end
	
          secondColumn.each do |singlePage|
		puts singlePage.text
		url = 	singlePage.css("a")[0]["href"]
		result = processLowestLevelPage(url)
		if topic.nil? 
		  f2.puts "topic.nil"
		elsif result.nil?
		  
		else	
		  f2.puts result+","+topic
		end
	  end

	 lastColumn.each do |singlePage|
		puts singlePage.text
		url = 	singlePage.css("a")[0]["href"]
		result = processLowestLevelPage(url)
		if topic.nil? 
		  f2.puts "topic.nil"
		elsif result.nil?
		  
		else	
		  f2.puts result+","+topic
		end
	  end
	end
end


begin
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


end

