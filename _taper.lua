-- a new a tape
--
--
-- play/rev/rec/echo
-- loop start/ loop end
-- loop active
-- loop playhead indicator
-- erase_strength selector
--
-- TODO 
-- everything
-- will like to refactor alot of this
-- to do more iterative and indexed 
-- functions (see bottom of script for more info)
-- many functions perform the same exact
-- operations, just on different parameters
-- there should be a way to make it all
-- less verbose


With = 1      -- can be 1 or 2 determines which W/ gets commands

wWith = {1,0} -- to check if key is selcted
bCast = 0     -- 0 or 1 detrmines if calls are sent to both W/s
w1 = 0        -- to check state of W/1 select key, 1 = pressed
w2 = 0        -- to check state of W/2 select key, 1 = pressed
-- to keep track of W/'s states 1 or 0
wPlay = {0,0}
wRev = {0,0}
wRec = {0,0}
wEcho = {0,0}
wStart = {0,0}
wEnd = {0,0}
wLoop = {0,0}
-- to keep track of W/s data floats and int
wErase = {15,15}-- holds x position of grid, converted to useful float in erase()
lStime = {0,0}  -- to hold timestamp
lEtime = {0,0}  -- to hold timestamp
lPos = {1,1}    -- to hold loop position on grid
dir = {1,1}     -- 1 = forward, -1 = reverse

g = grid.connect()


function init()
  -- initialize startup state for W/'s
  -- TODO 
  -- define with params. saved states and resetable
  for i = 1, 2 do
    crow.ii.wtape[i].loop_active(0)
    crow.ii.wtape[i].speed(1)
    crow.ii.wtape[i].play(0)
    crow.ii.wtape[i].record(0)
    crow.ii.wtape[i].echo_mode(0)
    crow.ii.wtape[i].erase_strength(0.2)
  end
  -- initiate grid rows for loop indicators
  for j = 1, 2 do
    for k = 1, 16 do
      g:led(k,j,1) 
    end
  end

  Lights()
end



----------
---------
--- gridding

g.key = function(x,y,z)
  if w1 == 1 and w2 == 1 then
    bCast = 1
    Lights()
    print('bCast ' .. bCast)
  end
  
  if z == 0 then
    if y == 8 then
      if x == 1 then
        w1 = 0
        
      elseif x == 2 then
        w2 = 0
        
      end
    end
  end
  
  
  if z == 1 then
   
    if y== 8 then
      -- to determine which w/ is receiving calls
      -- xxxxTODO add logic to accommodate both w/ at same time
      if x == 1 then
        wWith[1] = 1 
        wWith[2] = 0
        w1 = 1
        if bCast then
          bCast = 0
        end
      elseif x == 2 then
        wWith[1] = 0
        wWith[2] = 1
        w2 = 1
        if bCast then
          bCast = 0
        end
      end
      With = x
      print('bCast ' .. bCast)
      print("With = " .. With)
    end
    
    
    if y == 7 then
    -- play current w/
      if x == 1 then
        wPlay[With] = 1 - wPlay[With]
        play(With, wPlay[With])
        print("W/" .. With .. " playing " .. wPlay[With] )
    -- reverse current w/
      elseif x == 2 then
        wRev[With] = 1 - wRev[With]
        rev(With) -- reverse is a bang
        dir[With] = dir[With] * (-1)
        print("W/" .. With .. " reversed " .. wRev[With] )
      end
    end
    
    if y == 6 then
    -- record current w/  
      if x == 1 then
        wRec[With] = 1 - wRec[With]
        rec(With, wRec[With])
        print("W/" .. With .. " recording " .. wRec[With] )
      elseif x == 2 then
    -- switch for echo mode
        wEcho[With] = 1 - wEcho[With]
        echo(With,wEcho[With])
        print("W/" .. With .. " echo " .. wEcho[With] )
      end
      
      if x > 5 then
        wErase[With] = x
        erase(With,x)
        print(wErase[With])
      end
      
    end
    
    if y == 5 then
    -- set loop in/out
      if x == 1 then
        wStart[With] = 1
        lStart(With, 1)
        print("W/ " .. With )
      elseif x == 2 then
        wEnd[With] = 1
        lEnd(With, 1)
        wLoop[With] = 1
      elseif x == 3 then
        wStart[With] = 1 - wStart[With]
        wEnd[With] = 1 - wEnd[With]
        wLoop[With] = 1 - wLoop[With]
        lActive(With,wLoop[With])
      end
      
    end
    
   
    -- call to update grid lights
    Lights()
    
    print(x,y)
  end

end

function Lights()
-- illuminate the grid based on current status of w/
-- which w/
  if bCast == 1 then
    g:led(1,8,14+1)  
    g:led(2,8,14+1)  
  else
    g:led(1,8,wWith[1]*14+1)  
    g:led(2,8,wWith[2]*14+1)  
  end
-- who is playing???
  g:led(1,7,wPlay[With]*14+1)
-- is it reversed???
  g:led(2,7,wRev[With]*14+1)
-- who is recording???
  g:led(1,6,wRec[With]*14+1)
-- is it in echo mode???
  g:led(2,6, wEcho[With]*14+1)
-- erase strength?
-- iterate through erase strength indicator and zero it out
  for i = 1, 11 do 
    g:led(5+i,6,1)
  end
-- then write the current value
  if wErase[1] == wErase[2] then --check if value is equal/stacked and display full brightness
    g:led(wErase[2],6, 1*12+3)
  else
    g:led(wErase[2],6, wWith[2]*12+3) -- display brightness based on With when not stacked
    g:led(wErase[1],6, wWith[1]*12+3)
  end
-- is loop set????
  g:led(1,5, wStart[With]*14+1)
  g:led(2,5, wEnd[With]*14+1)
-- illuminate key for loop activation
  g:led(3,5, 1)

  
-- will start creating indicators for both W/s current state. active W/ will be displayed brighter than inactive W/   
-- see handling of erase strength above for how this can work
-- to refresh the lights
  g:refresh()
end

----------
---------
-- w/ functions
-- crow.ii.wtape.help() 
-- call this to see list of actual functions

function play(w,p)
  if bCast == 1 then
    for i = 1, 2 do
      wPlay[i] = p
      crow.ii.wtape[i].play(p)
    end
  else
    crow.ii.wtape[w].play(p)
  end
end

function rec(w,p)
  if bCast == 1 then
    for i = 1, 2 do
      wRec[i] = p
      crow.ii.wtape[i].record(p)
    end
  else
    crow.ii.wtape[w].record(p)
  end
end

function erase(w,p)
  if bCast == 1 then
    wErase[1] = p
    wErase[2] = p
    p = (10 -(p-16) -10)/ 10
    for i = 1, 2 do
      
     
      crow.ii.wtape[i].erase_strength(p)
    end
  else
    p = (10 -(p-16) -10)/ 10
    crow.ii.wtape[w].erase_strength(p)
  end
end

function echo(w,p)
  if bCast == 1 then
    for i = 1, 2 do
      wEcho[i] = p
      crow.ii.wtape[i].echo_mode(p)
    end
  else
    crow.ii.wtape[w].echo_mode(p)
  end
end

function rev(w)
  if bCast == 1 then
    for i = 1, 2 do
      wRev[i] = p
      crow.ii.wtape[i].reverse()
    end
  else
    crow.ii.wtape[w].reverse()
  end
end

function lStart(w,p)
  if bCast == 1 then
    for i = 1, 2 do
      wStart[i] = p
      crow.ii.wtape[i].loop_start(p)
      crow.ii.wtape[i].get('loop_start')
    end
  else
    crow.ii.wtape[w].loop_start(p)
    crow.ii.wtape[w].get('loop_start')
  end
end

function lEnd(w,p)
  if bCast == 1 then
    for i = 1, 2 do
      wEnd[i] = p
      crow.ii.wtape[i].loop_end(p)
      crow.ii.wtape[i].get('loop_end')
      --l1:start()
      --l2:start()
    end
  else
    crow.ii.wtape[w].loop_end(p)
    crow.ii.wtape[w].get('loop_end')
    
  end
end

function lActive(w,p)
  if bCast == 1 then
    for i = 1, 2 do
      wLoop[i] = p

      crow.ii.wtape[i].loop_active(p)
      if p == 0 then
        l1:stop()
        l2:stop()
      elseif p == 1 then
        crow.ii.wtape[i].timestamp(lStime[i])
        crow.ii.wtape[i].loop_active(p)
        l1:start()
        l2:start()
      end
      lPos[i] = 1
    end
  else
   
    crow.ii.wtape[w].loop_active(p)
    lPos[w] = 1
    if w == 1 then
      if p == 0 then
        l1:stop()
      elseif p == 1 then
        crow.ii.wtape[w].timestamp(lStime[w])
        crow.ii.wtape[w].loop_active(p)
        l1:start()
      end
    elseif w == 2 then
      if p == 0 then
        l2:stop()
      elseif p == 1 then
        crow.ii.wtape[w].timestamp(lStime[w])
        l2:start()
      end
    end
  end
end



-- to determine getter calls!!!!!


crow.ii.wtape.event = function( e, value )
	if e.name == 'loop_start' then
	 -- lS[e.device] = value
	  lStime[e.device] = value
    print('loop_start ' .. value)
    print(e.device)-- will print the time stamp of loop start
	elseif e.name == 'loop_end' then
    lEtime[e.device] = value
    if e.device == 1 then
      l1.time = math.abs((lEtime[1]-lStime[1])/16)
      print('time ' .. l1.time)
      l1:start()
    elseif e.device == 2 then
      l2.time = math.abs((lEtime[2]-lStime[2])/16)
      l2:start()
    end
    print('loop_end ' .. value) -- will print value of loop end
  elseif e.name == 'timestamp' then
    print('timestamp ' .. value) -- will print current playhead timestamp
     -- we can do more than just print the value here
     -- we can also save it in a previously defined variable
      -- wTime = value  -- now wTime will be filled with the current timestamp
	end
end

l1 = metro.init()
l1.time = 1
l1.event = function()
  lPos[1] = (lPos[1] + dir[1]) % 16
  g:led(lPos[1]-dir[1],1,1)
  g:led(lPos[1],1,15)
  Lights()
end

l2 = metro.init()
l2.time = 1
l2.event = function()
  lPos[2] = (lPos[2] + dir[2]) % 16
  g:led(lPos[2]-dir[2],2,1)
  g:led(lPos[2],2,15)
  Lights()
end

-- below is 1a test for storing metros in a list and calling them programatically.
-- to start the below metro
-- loop[1]:start()
-- 
-- this would allow iterative ability to start and stop any number of clocks from a single function.
-- could also be applied to normal functions I think. so, all the above functions for play/record/etc.
-- could be consolidated into a single function just called with a different index, or some such...
-- I'm still trying to work out the details... but this could simplify many repetitive functions.
tester = 0
loop = {}
loop[1] = metro.init()
loop[1].time = 1
loop[1].event = function()
  tester = tester + 1
  print(tester)
end

