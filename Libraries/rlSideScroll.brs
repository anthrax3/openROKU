'********************************************************************
'**  Library rlRSS 
'**  April 2011
'**  Provides Functions to support Side Scroll game development
'**  The check for collisions is fairly slow
'**  Asteroids is a sample app 
'********************************************************************



'********************************************************************
'**  Function hasCollided
'**  March 2011
'**  Copyright (c) 2011 Kirk Terrell. All Rights Reserved.
'**  Determine if two images overlap
'********************************************************************


function hasCollided(obj0 as object, obj1 as object) as boolean

	'collide= obj0.TargetRect.x-obj1.TargetRect.w<obj1.TargetRect.x
	'collide=collide and obj1.TargetRect.x< obj0.TargetRect.x+obj0.TargetRect.w+obj1.TargetRect.w
	'collide=collide and obj0.TargetRect.y-obj1.TargetRect.h<obj1.TargetRect.y
	'collide=collide and obj1.TargetRect.y< obj0.TargetRect.y+obj0.TargetRect.h+obj1.TargetRect.h
	if (obj0.TargetRect.x-obj1.TargetRect.x)^2+(obj0.TargetRect.y-obj1.TargetRect.y)^2<obj0.TargetRect.w^2+obj1.TargetRect.w^2 
		print "smacko"
		return true
	end if
	return false

end function



'********************************************************************
'**  Function hasCollided
'**  March 2011
'**  Copyright (c) 2011 Kirk Terrell. All Rights Reserved.
'**  Returns boundary, if at wall
'********************************************************************


function hasCollidedWall(obj0 as object) as string

	if obj0.TargetRect.x <0 then return "Left"
	if obj0.TargetRect.x+obj0.TargetRect.w > 720 then return "Right"
	if obj0.TargetRect.y <0 then return "Top"
	if obj0.TargetRect.y + obj0.TargetRect.h >480  then return "Bottom"

	return ""

end function


'********************************************************************
'**  Function findCollisions
'**  March 2011
'**  Copyright (c) 2011 Kirk Terrell. All Rights Reserved.
'**  Look at all combinations of images for collisions
'********************************************************************

sub findCollisions(object as object, collisions as object) 

	collisions.Clear()
	N=object.Count()-1
		
	for i=0 to N
	for j=0 to N
		
		if i=j
			wall=hasCollidedWall(object[i])
			if wall<>"" then collisions.Push({a:i,b:wall})
			if wall<>"" then print wall
		else
			if hasCollided(object[i],object[j] )
				collisions.Push({a:i,b:object[j].url})
				
			end if
		end if
	end for
	end for


end sub

'********************************************************************
'**  Function updatePositions
'**  March 2011
'**  Copyright (c) 2011 Kirk Terrell. All Rights Reserved.
'**  Update position based on kinematics - might break up velocities and positions?
'********************************************************************
sub updatePositions(canvas as object,canvasItem as object)

	for i=0 to canvasItem.Count()-1

		canvasItem[i].TargetRect.x=canvasItem[i].TargetRect.x+canvasItem[i].v.x
		canvasItem[i].TargetRect.y=canvasItem[i].TargetRect.y+canvasItem[i].v.y
	end for
	canvas.SetRequireAllImagesToDraw(true)
	canvas.SetLayer(1, canvasItem)
return
end sub

'********************************************************************
'**  Function updateVelocities
'**  March 2011
'**  Copyright (c) 2011 Kirk Terrell. All Rights Reserved.
'**  Update position based on kinematics - might break up velocities and positions?
'********************************************************************
sub updateVelocities(canvasItem as object)

	for i=0 to canvasItem.Count()-1

		canvasItem[i].v.x=canvasItem[i].v.x+canvasItem[i].a.x
		canvasItem[i].v.y=canvasItem[i].v.y+canvasItem[i].a.y
	end for
return
end sub

Sub initializeLevel(canvas as object, backgrounds as object, canvasItem as object, lvl as integer)
	
	background={url:backgrounds[lvl],TargetRect:{x:0,y:0,w:720,h:480}}
	canvas.SetRequireAllImagesToDraw(true)
	canvas.SetLayer(0, background)

	for i=1 to canvasItem.Count()-1
		canvasItem.Pop()
	end for

	canvasItem[0].TargetRect.x=0

	return
end sub
