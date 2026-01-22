-- BMD-FusionExtras - Additional tools to improve fusion's functionality
-- Copyright (c) 2025 Karto
--
-- Licensed under the MIT License. See LICENSE file in the project root.

local flow = comp:GetViewList().FlowView
local selectedToolList = comp:GetToolList(true)


function filter(inputTable, conditionFunction)
    local filteredResults = {}
    for index, value in ipairs(inputTable) do
        if conditionFunction(value, index) then
            table.insert(filteredResults, value)
        end
    end
    return filteredResults
end

function GetDistance(tool1, tool2)
    local x1, y1 = flow:GetPos(tool1)
    local x2, y2 = flow:GetPos(tool2)
    return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
end

function GetDirection(tool1, tool2)
    local x1, y1 = flow:GetPos(tool1)
    local x2, y2 = flow:GetPos(tool2)

    local dx = x2 - x1
    local dy = y2 - y1

    local length = math.sqrt(dx * dx + dy * dy)

    if length == 0 then
        return { x = 0, y = 0 }  -- Avoid division by zero, return a neutral direction
    end

    return { x = dx / length, y = dy / length }  -- Return normalized direction as a table
end


function Start()
    comp:StartUndo("AutoMerge")

    table.sort(selectedToolList, function(a, b)
        local aX, _ = flow:GetPos(a)
        local bX, _ = flow:GetPos(b)
        return aX < bX  -- Sort by X position in ascending order (left to right)
    end)
    
    for _, tool in ipairs(selectedToolList) do
        PerformMerge(tool)
    end

    comp:EndUndo()
end

function PerformMerge(toolInContext)
    local targetToolList = comp:GetToolList()
    
    -- Filter out tools without position property
    targetToolList = filter(targetToolList, function(tool)
        return flow:GetPos(tool) ~= nil
    end)
    
    -- Filter out tools above the tool in context
    targetToolList = filter(targetToolList, function(tool)
        print(tool.ClassName)
        local _, toolInContextY = flow:GetPos(toolInContext)
        local _, toolY = flow:GetPos(tool)
        
        return toolY > toolInContextY
    end)

    -- Sort the filtered list by distance from the tool in context (based on X position, you can adjust to 2D distance if needed)
    table.sort(targetToolList, function(a, b)
        local distanceA = GetDistance(toolInContext, a)
        local distanceB = GetDistance(toolInContext, b)
        return distanceA < distanceB  -- Sort by distance in ascending order (closer tools first)
    end)

    for _, targetTool in ipairs(targetToolList) do
        local out = targetTool:FindMainOutput(1)
        local connectedInputs = out:GetConnectedInputs()

        local closestConnectedTool = nil
        local closestDistance = math.huge
        for _, input in ipairs(connectedInputs) do
            local connectedTool = input:GetTool()
            if connectedTool ~= nil then -- Possible optimization, this is just to block all the non main inputs manually. 
                local distToConnectedTool = GetDistance(targetTool, connectedTool)
                if distToConnectedTool < closestDistance then
                    closestConnectedTool = connectedTool
                    closestDistance = distToConnectedTool
                end
            end
        end

        if closestConnectedTool ~= nil then
            -- print("Checking: " .. targetTool.Name .. ". Connected to: " .. closestConnectedTool.Name)
            local directionToTarget = GetDirection(toolInContext, targetTool)
            local directionToConnected = GetDirection(toolInContext, closestConnectedTool)

            -- print("Direction to Target: " .. directionToTarget.x)
            -- print("Direction to Connected: " .. directionToConnected.x)
            if (directionToTarget.x < 0 and directionToConnected.x > 0) or (directionToTarget.x > 0 and directionToConnected.x < 0) then
                -- print("Closest Connection Found: " .. targetTool.Name .. " -> " .. closestConnectedTool.Name)
                CreateMergeNodeAtIntersection(toolInContext, targetTool, closestConnectedTool)
                return
            end
        else
            -- print("Checking: " .. targetTool.Name .. ". Not connected.")
        end
    end
    -- print("No valid connection found.")
end

function CreateMergeNodeAtIntersection(toolInContext, tool1, tool2)
    -- Step 1: Get the positions of tool1 and tool2
    local x1, y1 = flow:GetPos(tool1)
    local x2, y2 = flow:GetPos(tool2)
    -- Get the position of toolInContext
    local x0, y0 = flow:GetPos(toolInContext)

    -- print("toolInContext: x = " .. x0 .. ", y = " .. y0)

    local x_intersection = x0
    local y_intersection = 0

    -- Step 2: Calculate the slope (m) of the line between tool1 and tool2
    if x2 - x1 ~= 0 then
        local m = (y2 - y1) / (x2 - x1)  -- Slope of the line
        -- Step 3: Calculate the y-intercept (b) of the line
        local b = y1 - m * x1
        
        -- Step 4: Find the y-coordinate of the intersection point by plugging x0 into the line's equation
        y_intersection = m * x0 + b
    else
        -- If the line between tool1 and tool2 is vertical (x1 == x2), handle it separately
        -- print("The line between tool1 and tool2 is vertical: x = " .. x1)
        
        -- Perpendicular line will be horizontal at toolInContext's y-coordinate
        y_intersection = y0  -- y-coordinate from toolInContext
    end
    
    -- print("Intersection Point: x = " .. x_intersection .. ", y = " .. y_intersection)
    local merge = comp:AddTool('Merge')
    flow:SetPos(merge, x_intersection, y_intersection)

    -- Disconnect tools
    tool2:FindMainInput(1):ConnectTo()

    -- Connect the tools to the merge node
    merge.Foreground:ConnectTo(toolInContext:FindMainOutput(1))
    merge.Background:ConnectTo(tool1:FindMainOutput(1))
    tool2:FindMainInput(1):ConnectTo(merge:FindMainOutput(1))
    -- print("Merged: " .. toolInContext.Name .. " onto -> " .. tool1.Name)
end

-- Execution starts here. 
Start()
