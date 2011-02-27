'********************************************************************
'**  Library rlRSS 
'**  Febuary 2011
'**  Provides Functions do the following
'**		Parse an RSS 2 compliant feed (GetFeed)
'**		Populate the metadata for a content list from a parsed feed (CreateContentListRSS2)
'**		Provide a UI to select content Item (GetContent, GetNext)
'**		Present Content item(s) (PlayText, PlaySlideShow, PlayAudio, and PlayVideo)
'**  Copyright (c) 2011 Kirk Terrell. All Rights Reserved.
'********************************************************************


'********************************************************************
'**  Function GetFeed
'**  Febuary 2011
'**  Copyright (c) 2011 Kirk Terrell. All Rights Reserved.
'********************************************************************

Function GetFeed(rss as object, url as string) as boolean
	
	'Create One Line Dialog to let user know that processing is occuring
	old=CreateObject("roOneLineDialog")
	old.SetTitle("Retrieving")
	old.ShowBusyAnimation()
	old.Show()
   

	'Get source from designated website. Similar to lynx -dump url
	ut=CreateObject("roUrlTransfer")
	ut.SetUrl(url)
	sed1=CreateObject("roRegEx",":","")			'BrightSign does not process : will replace with _
	sed2=CreateObject("roRegEx","http_","")		'This turns urls into http_\\...  will convert back to http:

		if rss.Parse(sed2.ReplaceAll(sed1.ReplaceAll(ut.GetToString(),"_"),"http:"))	
			print "Succesful Feed Retrieval"	
			old.Close()
			return true
		else
			old.SetTitle("Retrieval Failed")
			print "Retrieval Failed"
			sleep(2000)
			old.Close()
			return false
		end if

End Function
  

'********************************************************************
'**  Function CreateContentListRSS2
'**  Populates Meta-Data based on minimal RSS 2.0 specification
'**  Febuary 2011
'**  Copyright (c) 2011 Kirk Terrell. All Rights Reserved.
'********************************************************************

Function CreateContentListRSS2(content_list as object, rss as object) as boolean

	n=rss.channel.item.Count()-1

	for i=0 to n
			o=CreateObject("roAssociativeArray")
			o.ReleaseDate=StdPubDate(rss.channel.item[i].pubDate.gettext())
			o.Title=rss.channel.item[i].title.gettext()
			o.Description=rss.channel.item[i].description.gettext()
			o.ShortDescriptionLine1=rss.channel.item[i].title.gettext()
			o.ShortDescriptionLine2=Mid(rss.channel.item[i].pubDate.gettext(),1,16)
			o.EpisodeNumber=Str(i+1)
			o.Director=""
			
			if rss.channel.item[i].enclosure <> invalid

				if rss.channel.item[i].enclosure@type = "image/jpeg"
					o.Url=rss.channel.item[i].enclosure@url
				end if 	

				if rss.channel.item[i].enclosure@type = "audio/mpeg"
					o.Url=rss.channel.item[i].enclosure@url
					o.StreamFormat="mp3"
				end if 
				
				if rss.channel.item[i].enclosure@type = "video/mp4"
					myUrl=rss.channel.item[i].enclosure@url
					myUrl=Left(MyUrl,Len(MyUrl)-4)
					myUrl=MyUrl+"_480.mp4"
					o.StreamUrls=[myUrl]
					o.StreamQualities=["SD"]
					o.streamformat=["mp4"]
					o.StreamBitRates=["394"]
				end if 	
			
				if rss.channel.item[i].enclosure@type = "video/quicktime"
					o.StreamUrls=[rss.channel.item[i].enclosure@url]
					o.StreamQualities=["SD"]
					o.streamformat=["mov"]
					o.StreamBitRates=["394"]
				end if 	

			end if 
			content_list.Push(o)
		
	end for	
	
	print "Metadata populated for"; n+1 ;" items "

end Function





'********************************************************************
'**  Function GetContent
'**  Uses Poster Screen to provide user with choice of content.
'**  Febuary 2011
'**  Copyright (c) 2011 Kirk Terrell. All Rights Reserved.
'********************************************************************

Function GetContent(X as object, p as object, i as integer) as integer

	ss1=CreateObject("roPosterScreen")
	ss1.SetMessagePort(p)

	indx=0

	ss1.SetContentList(X)
	if X[0].SDPosterUrl="" or X[0].SDPosterUrl=X[1].SDPosterUrl then ss1.SetListStyle("flat-episodic")
	ss1.SetFocusedListItem(i)
	ss1.show()

'	Main Loop

	while true
		msg=wait(0,p)

 		if msg.isScreenClosed() 
			print "GetContent screen is closed"
			goto out
		end if
	
 		if msg.isListItemSelected() 
			print "msg : ";msg.GetMessage(); "idx : ";msg.GetIndex()
			indx=msg.GetIndex()
			exit while
		end if
	end while

	out:
	print "Item" ;indx+1;" is selected"
	return indx

End Function


'********************************************************************
'**  Function GetNext
'**  Updates Focus Item for Poster Screen based on Released Date
'**  Febuary 2011
'**  Copyright (c) 2011 Kirk Terrell. All Rights Reserved.
'********************************************************************


Function getNext(X as Object, Y as string) as integer

	n=X.Count()-1

	j=0

	for i=n to 0 step -1
		j=i
			if X[i].ReleaseDate > Y 
				print "item ";j;" selected"
				return j
			end if

		next

	print "Item 0 selected"
	return 0

end Function


'*************************************************************
'** Present Content
'** Collection of Subroutines for presnting content
'*************************************************************


'********************************************************************
'**  Sub PlayText
'**  Febuary 2011
'**  Copyright (c) 2011 Kirk Terrell. All Rights Reserved.
'********************************************************************


Sub PlayText(content_item as object, port as object) 

	sbs1=CreateObject("roSpringboardScreen")
	sbs1.SetMessagePort(port)
	sbs1.AddButton(1,"Quit")
	sbs1.SetStaticRatingEnabled(false)
	sbs1.SetDescriptionStyle("generic")
	sbs1.SetContent(content_item)
	sbs1.Show()
	

	while true
			
		msg=wait(0,port)
	
		 if type(msg) = "roSpringboardScreen"
            if msg.isScreenClosed()
                print "PlayText screen closed"
                exit while		
			end if
		end if 
		

'	Only process messages from the keys on the SpringboardScreen
		
		if msg.isButtonPressed() 

			print "msg : ";msg.GetMessage(); "idx : ";msg.GetIndex()
	
			if msg.GetIndex()=1 then exit while
			
			
		end if 
		


	end while
	
	
	sbs1.Close()

end Sub

'********************************************************************
'**  Sub PlaySlideShow
'**  Febuary 2011
'**  Copyright (c) 2011 Kirk Terrell. All Rights Reserved.
'********************************************************************

Sub PlaySlideShow(content_list as object, p as object)

	ss1=CreateObject("roSlideShow")

	ss1.SetMessagePort(p)

	ss1.ClearContent()

	ss1.SetPeriod(3)

	ss1.SetContentList(content_list)

	ss1.Show()

	while true

		msg=wait(0,p)
		
		if msg.isRequestFailed() 
			Print "Request Failed"
			exit while
		end if

		if msg.isScreenClosed()
			print "PlaySlideShow screen closed"
			exit while
		end if

	end while 
	
	ss1.Close()

end sub


'********************************************************************
'**  Sub PlayAudio
'**  Febuary 2011
'**  Copyright (c) 2011 Kirk Terrell. All Rights Reserved.
'********************************************************************


Sub PlayAudio(Song as object, port as object)

	sbs1=CreateObject("roSpringboardScreen")
	sbs1.SetMessagePort(port)
	sbs1.AddButton(1,"Play/Pause")
	sbs1.AddButton(2,"Quit")
	sbs1.SetStaticRatingEnabled(false)
	sbs1.SetDescriptionStyle("generic")
	sbs1.SetContent(Song)
	sbs1.Show()
	ap1 = CreateObject("roAudioPlayer")
	ap1.SetMessagePort(port)

	print Song.url
  	ap1.AddContent(Song)
	ap1.Play()
	if StreamBuffer(port) 
		print "Acquired Signal"
		else
		print "fail to Acquire Signal"
		goto out
	end if

 	isPlay=-1

	while true
			
		msg=wait(0,port)
		
		 if type(msg) = "roAudioPlayerEvent"
            if msg.isFullResult()
                print "Audio Completed"
                goto out	
			end if
		end if 

		 if type(msg) = "roSpringboardScreen"
            if msg.isScreenClosed()
                print "PlayAudio screen closed "
                goto out		
			end if
		end if 
		

'	Only process messages from the keys on the SpringboardScreen
		
		if msg.isButtonPressed() 

			print "msg : ";msg.GetMessage(); "idx : ";msg.GetIndex()
	
			if msg.GetIndex()=1 then
						
				isPlay=-1*isPlay

				if isPlay=-1 then
					ap1.Resume()
					if StreamBuffer(port) then
						print "Acquired Signal"
					else
						print "fail to Acquire Signal"
						goto out
					end if
				else
					ap1.Pause()
				end if
		end if 
		
		if msg.GetIndex()=2 then goto out
			
		end if

	end while
	
	out:
	ap1.Stop()
	sbs1.Close()
end Sub





'********************************************************************
'**  Sub PlayVideo
'**  Febuary 2011
'**  Copyright (c) 2011 Kirk Terrell. All Rights Reserved.
'********************************************************************

Sub playVideo(clip as object, p as object) 

	vs1=CreateObject("roVideoScreen")
	vs1.SetMessagePort(p)

	vs1.SetContent(clip)

	vs1.Show()

    while true

        msg = wait(0, vs1.GetMessagePort())
        if type(msg) = "roVideoScreenEvent"
            if msg.isScreenClosed() 
                print "PlayVideo screen closed"
                exit while
            end if
		end if
        
		if type(msg) = "roVideoScreenEvent"
            if msg.isFullResult() 
                print "Video Completed"
                exit while
            end if
		end if



    end while
	
	vs1.Close()
end Sub

'*************************************************************
'** Utilities
'** Used to support user previous functions
'*************************************************************

'********************************************************************
'**  Function StreamBuffer
'**  Febuary 2011
'**  Copyright (c) 2011 Kirk Terrell. All Rights Reserved.
'********************************************************************


Function StreamBuffer(port as object) as boolean

'	StreamBuffer provides visual feedback to the user that the feed is buffering, and verifies that the signal is acquired

	doReturn=true			' true is returned if the signal is succesfullu acquired
	OLD=CreateObject("roOneLineDialog")
	OLD.SetTitle("Please Wait ")
	OLD.SetMessagePort(port)
	OLD.ShowBusyAnimation()
	OLD.Show()

	doBuffer=1
	while doBuffer=1
		oldMsg=wait(0,port)
		'print oldMsg.GetMessage();" ";oldMsg.GetIndex()
		if oldMsg.GetMessage() = "start of play" then doBuffer=0
	 if oldMsg.GetIndex() <0 then goto out
	end while

	out:
 	if oldMsg.GetIndex()<0 then
		
		OLD.SetTitle("Failed to Acquire Signal")
		OLD.Show()
		Sleep(1000)
		doReturn=false	
	end if

	OLD.Close()
	return doReturn
end Function


'********************************************************************
'**  Function StdPubDate
'**  Febuary 2011
'**  Copyright (c) 2011 Kirk Terrell. All Rights Reserved.
'********************************************************************


Function StdPubDate(X$ as String) as String


	' Converts Pub Date format from NPR podcast to one that allows for string compare to 
	'provide proper order YYYY/MM/DD
	month$="00"	

	if Mid(X$,9,3) ="Jan" then month$="01" 
	if Mid(X$,9,3) ="Feb" then month$="02" 
	if Mid(X$,9,3) ="Mar" then month$="03" 
	if Mid(X$,9,3) ="Apr" then month$="04" 
	if Mid(X$,9,3) ="May" then month$="05" 
	if Mid(X$,9,3) ="Jun" then month$="06" 
	if Mid(X$,9,3) ="Jul" then month$="07" 
	if Mid(X$,9,3) ="Aug" then month$="08" 
	if Mid(X$,9,3) ="Sep" then month$="09" 
	if Mid(X$,9,3) ="Oct" then month$="10" 
	if Mid(X$,9,3) ="Nov" then month$="11" 
	if Mid(X$,9,3) ="Dec" then month$="12" 
	

	
	date$=  Mid(X$,13,4) + "/" + month$ + "/" +Mid(X$,6,2)
		
	return date$


END Function
