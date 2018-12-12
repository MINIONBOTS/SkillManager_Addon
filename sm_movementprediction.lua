local table = _G["table"]
local math = _G["math"]
local RayCast = _G["RayCast"]

sm_movementprediction = class("sm_movementprediction")
sm_movementprediction.currenttarget = {id = nil, lastpos = nil, activationtime = nil, predictedpos = nil, lastupdate = nil}
sm_movementprediction.enabled = false

function sm_movementprediction:Enabled(e)
	sm_movementprediction.enabled = e
end

function sm_movementprediction:GetPosDistance(target)
	local currenttarget = self.currenttarget
	
	if(target) then
		if(self.enabled and target.id == currenttarget.id) then
			return currenttarget.predictedpos,currenttarget.predictedposdistance
		end
		
		return target.pos,target.distance
	end
end

function sm_movementprediction:SetActivationTime(target,activationtime)
	if(target) then
		if(target.id == self.currenttarget.id) then
			self.currenttarget.activationtime = activationtime
		end
	end
end

function sm_movementprediction:Update(target,activationtime)
	local ppos = ml_global_information.Player_Position

	if(target) then
		local pos = target.pos
		--gw2_gui_manager.AddMarker("target pos", {pos = pos, color = {r = 0, g = 0, b = 1, a = 1}})
		if(self.enabled and target.alive and target.los and target.movementstate ~= 1) then
			if(self.currenttarget.id == target.id and self.currenttarget.lastupdate and table.valid(self.currenttarget.lastpos)) then
				local v = math.vectorize(self.currenttarget.lastpos,pos)
				local m = math.magnitude(v)
				local t = (ml_global_information.Now-self.currenttarget.lastupdate) / 3
				local distanceTraveled = m*t

				if(distanceTraveled > 0) then
					-- Add some extra based on the current skill activation time
					if(self.currenttarget.activationtime) then
						distanceTraveled = distanceTraveled+(distanceTraveled*self.currenttarget.activationtime)
					end
					
					local newpos = {
						x = pos.x + (distanceTraveled*pos.hx);
						y = pos.y + (distanceTraveled*pos.hy);
						z = pos.z + (distanceTraveled*pos.hz);			
					}
					local reachable = NavigationManager:IsReachable(ppos,newpos)	
					local hit, hitx, hity, hitz = RayCast(ppos.x,ppos.y,ppos.z-25, newpos.x, newpos.y, newpos.z-25)
					if(not hit and reachable) then
						pos = newpos
					end
					--gw2_gui_manager.AddMarker("predicted pos", {pos = newpos, color = {r = 1, g = 0, b = 1, a = 1}})
				end	
			end
		end
		self.currenttarget.id = target.id
		self.currenttarget.lastpos = target.pos
		self.currenttarget.lastupdate = ml_global_information.Now
		self.currenttarget.predictedpos = pos
		self.currenttarget.predictedposdistance = math.distance3d(ppos,pos)
		
	end
end
