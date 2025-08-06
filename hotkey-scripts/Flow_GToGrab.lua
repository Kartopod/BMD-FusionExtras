-- BMD-FusionExtras - Additional tools to improve fusion's functionality
-- Copyright (c) 2025 Karto
--
-- Licensed under the MIT License. See LICENSE file in the project root.


--Depends on UpdateLoop, PersistentData scriptlib files

isGrabActiveData = PersistentData.Flow_BlenderGrab .. ".IsActive"
isDuplicateGrabActiveData = PersistentData.Flow_BlenderDuplicateGrab .. ".IsActive"

local flow = comp:GetViewList().FlowView
local selectedToolList = comp:GetToolList(true)

local grabbedToolInitialPositions = {}
local lastFrameMouseX, lastFrameMouseY

-- Converts flow coordinates to mouse coordinates. The values were found by trial and error.
function flowToMouse(flowPosX, flowPosY)
    local scale = flow:GetScale()
    return { flowPosX * 166 * scale, flowPosY * 55 * scale }
end

--Converts mouse coordinates to flow coordinates. The values were found by trial and error.
function mouseToFlow(mousePosX, mousePosY)
    local scale = flow:GetScale()
    return { mousePosX / (166 * scale), mousePosY / (55 * scale) }
end

--Remove this. Just use fu:GetMousePos() everywhere
local function getMousePosition()
    local mouse = fu:GetMousePos()
    return mouse[1], mouse[2]
end


local function PopulateToolInitialPositions()
    for _, tool in ipairs(selectedToolList) do
        local toolX, toolY = flow:GetPos(tool)
        grabbedToolInitialPositions[tool] = {toolX, toolY}
    end
end

local function QueueToolPositions(mouseDelta)
    for tool, initialPosition in pairs(grabbedToolInitialPositions) do

        local flowMouseDelta = mouseToFlow(mouseDelta[1], mouseDelta[2])
        flow:QueueSetPos(tool, initialPosition[1] + flowMouseDelta[1], initialPosition[2] + flowMouseDelta[2])
    end
end

local Update 
Update = function()
    local mouseX, mouseY = getMousePosition()
    local mouseDelta = {mouseX - lastFrameMouseX, mouseY - lastFrameMouseY}
    local mouseButtons = fu:GetMouseButtons()
    
    QueueToolPositions(mouseDelta)
    if mouseButtons.LeftButton then -- Confirm action
        UpdateLoop.DeregisterFunction(Update) 
        
        bmd.wait(0.1) -- Reselecting doesn't work without waiting
        -- Select the tools again since clicking deselects them
        for tool, _ in pairs(grabbedToolInitialPositions) do
            flow:Select(tool, true)
        end
        fu:SetData(isGrabActiveData, false)
        comp:EndUndo(true)
    end
    
    if mouseButtons.RightButton then -- Cancel action and revert original state
        UpdateLoop.DeregisterFunction(Update) 
        fu:SetData(isGrabActiveData, false)
        comp:EndUndo(true)
        comp:Undo()
    end

    flow:FlushSetPosQueue()
end

local function Start()

    if fu:GetData(isGrabActiveData) or fu:GetData(isDuplicateGrabActiveData) then
        print("Grab is already active")
        return
    end

    local firstTool = selectedToolList[1]
    if not firstTool then
        print("No tools selected, cannot grab")
        return
    end

    fu:SetData(isGrabActiveData, true)
    -- Set initial mouse position
    lastFrameMouseX, lastFrameMouseY = getMousePosition()
    
    comp:StartUndo("Grab")
    
    if firstTool then
        PopulateToolInitialPositions()
        UpdateLoop.RegisterFunction(Update)
    end
end

-- Execution starts here. 
Start()
