' ********************************************************************
' **  appMain
' **  Copyright Feb 2011 by Kirk Terrell
' **  Artwork in images folder is copyrighted under the Creative Commons License
'**   Provides a channel for the Vodcast "Feed Me Bubbe"
' ********************************************************************

Sub Main() 


	p=CreateObject("roMessagePort")

	ic=CreateObject("roImageCanvas")	'This creates a screen to display the One Line Dialog in GetXML
	ic.SetMessagePort(p)
	ic.Show()



	rss=CreateObject("roXMLElement")


	if not GetFeed(rss, "http://feeds.feedburner.com/blogspot/feedmebubbe") 
		ic.Close()
		goto out
	end if


	n=rss.channel.item.Count()

	content_list=CreateObject("roArray",n,true)

	CreateContentListRSS2(content_list,rss)
	UpdateContentList(content_list,rss) ' The Program will work without this, but provides improved meta-data
	
	j=0

	while true

		j=getContent(content_list,p,j)
	

		' load images and start show
		
		PlayVideo(content_list[j],p)
	
	end while

out:

end SUB



'********************************************************************
'**  Function UpdateContentList
'**  Febuary 2011
'**  Copyright (c) 2011 Kirk Terrell. All Rights Reserved.
'********************************************************************

Function UpdateContentList(content_list as object, rss as object) as boolean

	

	n=rss.channel.item.Count()-1

	for i=0 to n
			

		' Poulate Poster Screen
		content_list[i].SDPosterUrl="pkg:/images/SDPoster.png"
		content_list[i].HDPosterUrl="pkg:/images/HDPoster.png"
		content_list[i].Description=Left(content_list[i].Description, instr(1,content_list[i].Description,"<br")-1)
	
	end for
		
	return true

end function
