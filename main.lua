local abs = math.abs
local rand = math.random

local r = 100
local maxScale = 1
local minScale = 0.1
local transferFactor = 0.20

local circles = {}

local function addCircle(e)
	local x = e.x
	local y = e.y
	
	local circle = display.newCircle(x,y,r)
	circle.speed = rand(3)*0.1
	circle.t = nil
	circle.direction = "expand"
	circle:setFillColor(rand(255),rand(255),rand(255))
	circle:scale(minScale,minScale)
	
	function circle:change(direction)
		if self.t ~= nil then
			transition.cancel(self.t)
			self.t = nil
		end
		if direction == "expand" then
			self.t = transition.to(self, {time =  1000 * (maxScale-self.xScale)/self.speed, xScale = maxScale, yScale = maxScale, onComplete=self.change})
			self.direction = "expand"
		elseif direction == "shrink" then
			self.t = transition.to(self, {time = 1000*(self.xScale-minScale)/self.speed, xScale = minScale, yScale = minScale, onComplete=self.change})
			self.direction = "shrink"
		else
			if self.direction == "shrink" then
				self.t = transition.to(self, {time =  1000 * (maxScale-self.xScale)/self.speed, xScale = maxScale, yScale = maxScale, onComplete=self.change})
				self.direction = "expand"
			elseif self.direction == "expand" then
				self.t = transition.to(self, {time = 1000*(self.xScale-minScale)/self.speed, xScale = minScale, yScale = minScale, onComplete=self.change, onComplete=self.change})
				self.direction = "shrink"
			end
		end
		self:setFillColor(rand(255),rand(255),rand(255))
	end
	
	function circle:tap(e)
		print("circle tapped")
		return true
	end
	circle:addEventListener("tap",circle)
	table.insert(circles , circle )
	circle:change("expand")
	print("no. of circles : " , #circles)
	
	return true
end

Runtime:addEventListener("tap",addCircle)

local function distanceBetween( point1, point2 )
 
        local xfactor = point2.x-point1.x ; local yfactor = point2.y-point1.y
        local distanceBetween = math.sqrt((xfactor*xfactor) + (yfactor*yfactor))
        return distanceBetween
end

local timers = {}

local function gameLoop(e)
	for i = 1, #circles do
		for j = i+1, #circles do 
			--print("dist", i, j, abs( (circles[i].xScale + circles[j].xScale)*r - distanceBetween(circles[i],circles[j])))
			if timers[tostring(i)..","..tostring(j)] == nil then 
				
				if abs( (circles[i].xScale + circles[j].xScale)*r - distanceBetween(circles[i],circles[j])) < 1 then
					
					local speeddif = circles[i].speed - circles[j].speed 
					circles[i].speed = circles[i].speed - speeddif * transferFactor
					circles[j].speed = circles[j].speed + speeddif * transferFactor
					circles[i]:change()
					circles[j]:change()
					timers[tostring(i)..","..tostring(j)] = e.time
				end
			elseif  e.time - timers[tostring(i)..","..tostring(j)] > 50 then
					
				if abs( (circles[i].xScale + circles[j].xScale)*r - distanceBetween(circles[i],circles[j])) < 1 then
				
					local speeddif = circles[i].speed - circles[j].speed 
					circles[i].speed = circles[i].speed - speeddif * transferFactor
					circles[j].speed = circles[j].speed + speeddif * transferFactor
					circles[i]:change()
					circles[j]:change()
					timers[tostring(i)..","..tostring(j)] = e.time
				end
			end		
		end
	end
end

Runtime:addEventListener("enterFrame",gameLoop)