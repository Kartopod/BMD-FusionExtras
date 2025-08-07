-- BMD-FusionExtras - Additional tools to improve fusion's functionality
-- Copyright (c) 2025 Karto
--
-- Licensed under the MIT License. See LICENSE file in the project root.


--Depends on UpdateLoop, PersistentData scriptlib files

-- This script has an issue: It tries to duplicate tools at the point that was last clicked, this might cause issues if other nodes are too close to this position. 
-- To reproduce: Click on a single tool to select it, then run the script. Fusion may try to duplicate at that position, causing it to automatically create a merge tool and mess things up. 

isGrabActiveData = PersistentData.Flow_BlenderGrab .. ".IsActive"
isDuplicateGrabActiveData = PersistentData.Flow_BlenderDuplicateGrab .. ".IsActive"

local flow = comp:GetViewList().FlowView
local selectedToolList = comp:GetToolList(true)

local toolStartPositionTable = {}

-- Initialize the grab state
local grabbedToolInitialPositions = {}
local lastFrameMouseX, lastFrameMouseY


function flowToMouse(flowPosX, flowPosY)
    local scale = flow:GetScale()
    return flowPosX * 166 * scale, flowPosY * 55 * scale
end

function mouseToFlow(mousePosX, mousePosY)
    local scale = flow:GetScale()
    return mousePosX / (166 * scale), mousePosY / (55 * scale)
end

local function getMousePosition()
    local mouse = fu:GetMousePos()
    return mouse[1], mouse[2]
end

local function PopulateToolInitialPositions(toolList)
    -- Calculate the offsets for each tool based on the initial mouse position
    for _, tool in ipairs(toolList) do
        local toolX, toolY = flow:GetPos(tool)
        grabbedToolInitialPositions[tool] = {toolX, toolY}
    end
end

local function QueueToolPositions(mouseDelta)
    for tool, startingPosition in pairs(grabbedToolInitialPositions) do

        local flowDeltaX, flowDeltaY = mouseToFlow(mouseDelta[1], mouseDelta[2])

        flow:QueueSetPos(tool, startingPosition[1] + flowDeltaX, startingPosition[2] + flowDeltaY)
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
        fu:SetData(isDuplicateGrabActiveData, false)
        comp:EndUndo(true)
    end

    if mouseButtons.RightButton then -- Cancel action and revert original state
        UpdateLoop.DeregisterFunction(Update)
        fu:SetData(isDuplicateGrabActiveData, false)
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

    fu:SetData(isDuplicateGrabActiveData, true)
    comp:StartUndo("Duplicate Grab")

    -- Set initial mouse position
    lastFrameMouseX, lastFrameMouseY = getMousePosition()
    
    local firstTool = selectedToolList[1]
    
    -- Store initial positions of selected tools
    for _, tool in ipairs(selectedToolList) do
        local x, y = flow:GetPos(tool)
        table.insert(toolStartPositionTable, {tool, x, y})
    end
    
    -- Dupe tools
    local toolsToDupe = comp:CopySettings()
    comp:Paste(toolsToDupe)
    
    
    -- Get new selection after duplication
    local dupedToolList = comp:GetToolList(true)
    
    -- Ensure the new tools are positioned at the original tool locations
    for i, tool in ipairs(dupedToolList) do
        local sourceData = toolStartPositionTable[i]
        if sourceData then
            local _, x, y = table.unpack(sourceData)
            flow:QueueSetPos(tool, x, y)
        end
    end
    
    flow:FlushSetPosQueue()
    
    if firstTool then
        PopulateToolInitialPositions(dupedToolList)
        UpdateLoop.RegisterFunction(Update)
    end
end


-- Execution starts here. 
Start()

