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

local function Start()

    -- if fu:GetData(isGrabActiveData) or fu:GetData(isDuplicateGrabActiveData) then
    --     print("Grab is already active")
    --     return
    -- end

    -- fu:SetData(isDuplicateGrabActiveData, true)
    comp:StartUndo("BlenderDuplicate")

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
        BlenderGrab.Start("FlowView", nil, false, nil)
    end
end


-- Execution starts here. 
Start()

