' ********************************************************************
' **  Super TED Talks
' **  Copyright (c) 2009 Roku Inc. All Rights Reserved.
' ********************************************************************
'Copyright 2011 Kirk Terrell


Sub Main() 


	p=CreateObject("roMessagePort")

	ic=CreateObject("roImageCanvas")	'This creates a screen to display the One Line Dialog in GetXML
	ic.SetMessagePort(p)
	ic.Show()

	i=0

	rsp=CreateObject("roXMLElement")


	if not GetFeed(rsp, "http://feeds.feedburner.com/tedtalks_video") 

		ic.Close()
		goto out
	end if


	n=rsp.channel.item.Count()-1

'	This takes the information from station.xml and populates a content list that drives the application

	station_list=CreateObject("roArray",n,true)  ' This associative array contains parameters for other objects used in this program

	CreateContentListRSS2(station_list,rsp)
	UpdateContentList(station_list,rsp) ' The Program will work without this, but provides improved meta-data

	i=0
	while true
		i=GetContent(station_list,p,i)
		print "item selected ";i;" ";station_list[i].ShortDescriptionLine1

		PlayVideo(station_list[i],p)


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
			

		' Populate Poster Screen
		' ChildElement 13 is media:thumbnail. Because the colon(:) can be used to seperate statements on a single line
		' BrightScript cant interpert it as a name like it does title or other child elements.
		' It is assumed that media:thumbnail is always 13. This can be verified for each item using .GetName()

		content_list[i].SDPosterUrl=rss.channel.item[i].GetChildElements()[13]@url  
		content_list[i].HDPosterUrl=rss.channel.item[i].GetChildElements()[13]@url
		
		indx=instr(rss.channel.item[i].title.gettext(),":")
		str1=right(rss.channel.item[i].title.gettext(),len(rss.channel.item[i].title.gettext())-indx-1)
		indx=instr(str1,":")
		str2=left(str1,indx-1)
		str3=right(str1,len(str1)-indx-1)
		content_list[i].ShortDescriptionLine1=str2
		content_list[i].ShortDescriptionLine2=str3
	end for
		
	return true

end function

