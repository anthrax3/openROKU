'Copyright 2011 Kirk Terrell


Sub Main() as Void

	backgroundurls=CreateObject("roArray")
	canvasItem=CreateObject("roAssociativeArray")
	canvas = CreateObject("roImageCanvas")

	port = CreateObject("roMessagePort")
	canvas.SetMessagePort(port)
	'Set opaque background

	myCollisions=CreateObject("roArray")
	myCollisions=[]		
	backgroundurls=["pkg://images/stars0.jpeg","pkg://images/stars1.jpeg","pkg://images/stars2.jpeg"]
	lvl=-1
	newlvl=0
	maxlvl=backgroundurls.Count() - 1
	
	canvasItem=[{url:"pkg://images/ship-big.png",TargetRect:{x:0,y:240,w:30,h:30},v:{x:5,y:0},a:{x:0,y:0}}]

	
	
	
		
		while true

			if lvl<>newlvl
				lvl=newlvl
				initializeLevel(canvas, backgroundurls,canvasItem,lvl)
				if lvl=0 then addStars(canvas,CanvasItem)
			end if



			updateRemote( port, canvas, canvasItem)

			updatePositions(canvas, canvasItem)

			findCollisions(canvasItem,myCollisions)

			newlvl = updateCollisions(canvas,canvasItem,myCollisions,newlvl)
			

			
			
			canvas.Show()

					
		if newlvl>maxlvl then exit while

		sleep(100)
	end while
			
			
print "GoodBye"
	


End Sub

Sub addStars(canvas as object, canvasItem as object)

	for i=0 to 10
	
		x=10+rnd(600)
		y=10+rnd(400)
		vx=0
		vy=0
		addThis={url:"pkg://images/star.gif",TargetRect:{x:x,y:y,w:10:h:10},v:{x:vx,y:vy}}
		canvasItem.Push(addThis)
	end for
	
	canvas.SetRequireAllImagesToDraw(true)
	canvas.SetLayer(1, canvasItem)

end sub
 
sub updateRemote(port as object,canvas as object , canvasItem as object)

	
	msg=Wait(10,port)
	if  msg = invalid then return

	
	
	if msg.isRemoteKeyPressed() <> invalid

		indx=msg.GetIndex()

		if indx=2 then canvasItem[0].v.y=canvasItem[0].v.y-5	'Up key
		if indx=3 then canvasItem[0].v.y=canvasItem[0].v.y+5    'Down key
		if indx=4 then canvasItem[0].v.x=canvasItem[0].v.x-5    'Left
		if indx=5 then canvasItem[0].v.x=canvasItem[0].v.x+5 	'Right
		
	end if
	canvas.SetRequireAllImagesToDraw(true)
	canvas.SetLayer(1, canvasItem)

return

end sub

function updateCollisions(canvas as object,canvasItem as object,myCollisions as object,newlvl as integer) as integer

	if myCollisions.Count()=0 then return newlvl

	for i=0 to myCollisions.Count()-1

		url_0=canvasItem[myCollisions.GetEntry(i).a].url
		

		if url_0="pkg://images/ship-big.png"

			if myCollisions.GetEntry(i).b = "pkg://images/star.gif" 
				newlvl=0
				print "Ouch"
				canvasItem[i].TargetRect.x=0
			end if

			if myCollisions.GetEntry(i).b = "Top"
				newlvl=0
				canvasItem[i].TargetRect.x=0
			end if

 			if myCollisions.GetEntry(i).b = "Bottom" 
				newlvl=0
				canvasItem[i].TargetRect.x=0
			end if

		    if myCollisions.GetEntry(i).b = "Left" 
				if newlvl>0 then newlvl=newlvl-1
			end if

			if myCollisions.GetEntry(i).b = "Right" 
				newlvl=newlvl+1
				print "go baby"
			end if

		end if
	next
	canvas.SetRequireAllImagesToDraw(true)
	canvas.SetLayer(1, canvasItem)
	return newlvl
end function
