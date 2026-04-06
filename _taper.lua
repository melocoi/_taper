-- a new a tape
--
-- TODO 
-- finish face plate functionality
-- add musical speed controls
-- rec level controls
-- loop postion indicator
-- etc etc etc 

With = 1
wWith = {1,0}
bCast = 0
w1 = 1
w2 = 0
wPlay = {0,0}
wRev = {0,0}
wRec = {0,0}
wEcho = {0,0}
wErase = {0,0}
wStart = {0,0}
wEnd = {0,0}
wLoop = {0,0}

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

  Lights()
end



----------
---------
--- gridding
--------------------
-- can play / reverse / record / echo / loop start / loop end / loop active
-- for 2 W/s in tape mode
--------------------

g.key = function(x,y,z)
  
  if z == 1 then
   
    if y== 8 then
      -- to determine which w/ is receiving calls
      -- TODO add logic to accommodate both w/ at same time
      if x == 1 then
        wWith[1] = 1 
        wWith[2] = 0
      elseif x == 2 then
        wWith[1] = 0
        wWith[2] = 1
      end
      With = x
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
        crow.ii.wtape[With].loop_active(wLoop[With])
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
  g:led(1,8,wWith[1]*14+1)  
  g:led(2,8,wWith[2]*14+1)  
-- who is playing???
  g:led(1,7,wPlay[With]*14+1)
-- is it reversed???
  g:led(2,7,wRev[With]*14+1)
-- who is recording???
  g:led(1,6,wRec[With]*14+1)
-- is it in echo mode???
  g:led(2,6, wEcho[With]*14+1)
-- is loop set????
  g:led(1,5, wStart[With]*14+1)
  g:led(2,5, wEnd[With]*14+1)
-- illuminate key for loop activation
  g:led(3,5, 1)
-- to refresh the lights
  g:refresh()
end

----------
---------
-- w/ functions
-- crow.ii.wtape.help() 
-- > ii.wtape.get( 'play' )                                                        
-- ^^ii.wtape({name=[[play]], device=1, arg=0}, 1) 
-- call this to see list of actual functions

function play(w,p)
  if bCast == 1 then
    crow.ii.wtape[1].play(p)
    crow.ii.wtape[2].play(p)
  else
    crow.ii.wtape[w].play(p)
  end
end

function rec(w,p)
  if bCast == 1 then
    crow.ii.wtape[1].record(p)
    crow.ii.wtape[2].record(p)
  else
    crow.ii.wtape[w].record(p)
  end
end

function echo(w,p)
  if bCast == 1 then
    crow.ii.wtape[1].echo_mode(p)
    crow.ii.wtape[2].echo_mode(p)
  else
    crow.ii.wtape[w].echo_mode(p)
  end
end


function rev(w)
  if bCast == 1 then
    crow.ii.wtape[1].reverse()
    crow.ii.wtape[2].reverse()
  else
    crow.ii.wtape[w].reverse()
  end
end

function lStart(w,p)
  if bCast == 1 then
    crow.ii.wtape[1].loop_start(p)
    crow.ii.wtape[2].loop_start(p)
  else
    crow.ii.wtape[w].loop_start(p)
  end
end

function lEnd(w,p)
  if bCast == 1 then
    crow.ii.wtape[1].loop_end(p)
    crow.ii.wtape[2].loop_end(p)
  else
    crow.ii.wtape[w].loop_end(p)
  end
end

-- to determine getter calls!!!!!
crow.ii.wtape.event = function( e, value )
	if e.name == 'loop_start' then
-- handle record response
-- e.arg: first argument, ie channel
-- e.device: index of device
 
  print('loop_start ' .. value)
	end
end

