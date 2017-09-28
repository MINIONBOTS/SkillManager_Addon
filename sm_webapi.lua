sm_webapi = {}
sm_webapi.json = _G["json"]
sm_webapi.queue = {}
sm_webapi.ready = true

function sm_webapi.getimage( skillid, imagedestination )	
	if (skillid and not sm_webapi.queue[skillid] ) then
		sm_webapi.queue[skillid] = { status = 0, path = imagedestination}
	end
end

-- Update even handler.
function sm_webapi.Update(Event, ticks)
	if (GetGameState() == GW2.GAMESTATE.GAMEPLAY ) then
		if (sm_webapi.ready and not sm_webapi.lasttick or ticks - sm_webapi.lasttick > 2000) then
			sm_webapi.lasttick = ticks
			local count = 0
			local idstring = ""
			local processed = {}
			for i,k in pairs (sm_webapi.queue) do
				if ( k.status == 0 ) then
					count = count + 1
					processed[i] = i					
					if ( idstring == "" ) then
						idstring = tostring(i)
					else
						idstring = idstring..","..tostring(i)
					end
				end
			end
			
			if ( count > 0 ) then
				local result = false
				if ( count == 1 ) then
					result = WebAPI:Get("sm_data_req",'/v2/skills/'..idstring)
				else
					result = WebAPI:Get("sm_data_req",'/v2/skills?ids='..idstring)
				end
				if ( result ) then
					for i,k in pairs (processed) do
						sm_webapi.queue[k].status = 1
					end					
					d("Requesting skill infos for  "..'/v2/skills?ids='..idstring)				
					sm_webapi.ready = false
				end
				
			else
			 -- get images for the urls we gathered			 
				 for i,k in pairs(sm_webapi.queue) do
					if (k.status == 2 and k.url ) then												
						if ( WebAPI:GetImage("sm_image_req", k.url, k.path)) then
							d("Requesting skill Icon from  "..tostring(k.url))
							k.status = 3
							sm_webapi.ready = false
							break
						end
					end				 
				 end			
			end
		end
	end
end

RegisterEventHandler("Gameloop.Update",sm_webapi.Update)

-- API callback eventhandler.
function sm_webapi.ApiCallback(Event, ID, Data)
	d("sm_webapi.ApiCallback()")
	if (Data and type(Data) == "string" and ID and type(ID) == "string") then
		--d("Check if it is a skilldata table or the folderpath the image got saved under")		
		if ( ID == "sm_data_req" ) then			
			local decodedData = sm_webapi.json.decode(Data)
			if (decodedData and type(decodedData) == "table") then
				if ( not decodedData.id ) then -- the result table has multiple entries
					-- check for valid result
					for i,k in pairs(decodedData) do				
						if(k.icon and k.id and sm_webapi.queue[k.id]) then
							sm_webapi.queue[k.id].status = 2
							sm_webapi.queue[k.id].url = k.icon
						end
					end
				else
					d("Icon for "..tostring(decodedData.id) .. " is "..tostring(decodedData.icon))
					if(decodedData.icon and decodedData.id and sm_webapi.queue[decodedData.id]) then
						sm_webapi.queue[decodedData.id].status = 2
						sm_webapi.queue[decodedData.id].url = decodedData.icon
					end
				end
			end
			sm_webapi.ready = true
		
		elseif ( ID == "sm_image_req" ) then -- image should be downloaded now
			for i,k in pairs(sm_webapi.queue) do
				if (k.status == 3 and k.path and k.path == Data) then
					d("Sucessfully loaded image, removing it from queue "..tostring(data))
					sm_webapi.queue[i] = nil
					sm_webapi.lasttick = sm_webapi.lasttick - 2000
				end
			end			
			sm_webapi.ready = true
		end
	end
end
RegisterEventHandler("API.Callback",sm_webapi.ApiCallback)