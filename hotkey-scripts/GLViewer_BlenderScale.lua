-- BMD-FusionExtras - Additional tools to improve fusion's functionality
-- Copyright (c) 2025 Karto
--
-- Licensed under the MIT License. See LICENSE file in the project root.

local compWidth = comp:GetPrefs("Comp.FrameFormat.Width")
local compHeight = comp:GetPrefs("Comp.FrameFormat.Height")

--Screen space coordinates of viewer
local viewerBottomLeft
local viewerTopRight

local initialMousePosition 
local initialScaledToolSizes = {}

local function mapRange(value, in_min, in_max, out_min, out_max)
    -- Ensure the input value is within the range
    if in_min == in_max then
        return out_min  -- Avoid division by zero, return the minimum of the output range
    end
    
    -- Map the value from the input range to the output range
    local mapped_value = (value - in_min) * (out_max - out_min) / (in_max - in_min) + out_min
    return mapped_value
end

local function distance(vec1, vec2)
    local dx = vec1[1] - vec2[1]
    local dy = vec1[2] - vec2[2]
    return math.sqrt(dx * dx + dy * dy)
end

function CalculateViewerScreenCoordinates()
    local view = comp.CurrentFrame.CurrentView

    local viewAttrs = view:GetAttrs()
    local viewerPos = view:GetPosTable()
    local viewerScale = view:GetScale()

    --In screen space
    local viewerWindowCenter = {(viewAttrs.VIEWN_Left + viewAttrs.VIEWN_Right)/2, (viewAttrs.VIEWN_Top + viewAttrs.VIEWN_Bottom)/2}

    --After scaling
    local viewerWidth = compWidth * viewerScale
    local viewerHeight = compHeight * viewerScale

    --In viewerWindow space
    local viewerPositionOffset = {viewerPos[1] * viewerScale, viewerPos[2] * viewerScale}

    local viewerCenter = {viewerWindowCenter[1] + viewerPositionOffset[1], viewerWindowCenter[2] - viewerPositionOffset[2]}

    viewerBottomLeft = {viewerCenter[1] - viewerWidth/2, viewerCenter[2] + viewerHeight/2}
    viewerTopRight = {viewerCenter[1] + viewerWidth/2, viewerCenter[2] - viewerHeight/2}
end

function ConvertScreenToViewerSpacePos(screenSpacePos)
    CalculateViewerScreenCoordinates()

    local mouseInViewerSpaceX = mapRange(screenSpacePos[1], viewerBottomLeft[1], viewerTopRight[1], 0, 1)
    local mouseInViewerSpaceY = mapRange(screenSpacePos[2], viewerBottomLeft[2], viewerTopRight[2], 0, 1)
    local mouseInViewerSpace = {mouseInViewerSpaceX, mouseInViewerSpaceY}

    return mouseInViewerSpace
end

function ConvertViewerToScreenSpacePos(viewerSpacePos)
    CalculateViewerScreenCoordinates()

    local screenSpaceX = mapRange(viewerSpacePos[1], 0, 1, viewerBottomLeft[1], viewerTopRight[1])
    local screenSpaceY = mapRange(viewerSpacePos[2], 0, 1, viewerBottomLeft[2], viewerTopRight[2])
    local screenSpacePos = {screenSpaceX, screenSpaceY}

    return screenSpacePos
end



function GetSizeInputNames(tool)
    --Handle each special case
    if IsToolType("Transform", tool) and not tool:GetInput("UseSizeAndAspect", comp.CurrentTime) then
        return {"XSize", "YSize"}
    end
    
    if IsToolType("RectangleMask", tool) or IsToolType("EllipseMask", tool) then
        return {"Width", "Height"}
    end
    
    --Handle default case if no special case was hit
    return {"Size", "Size"}
end

-- Pass in ID of tool as string
function IsToolType(regID, tool)
    return tool:GetAttrs().TOOLS_RegID == regID
end

local Update 
Update = function()
    ViewerScale(comp:GetToolList(true))

    local mouseButtons = fu:GetMouseButtons()
    if mouseButtons.LeftButton then -- Confirm action
        UpdateLoop.DeregisterFunction(Update) 

        comp:EndUndo()
    end

    if mouseButtons.RightButton then -- Cancel action and revert original state
        UpdateLoop.DeregisterFunction(Update) 
        comp:EndUndo()
        comp:Undo()
    end
end

function Start()
    local selectedTools = comp:GetToolList(true)

    initialMousePosition = fu:GetMousePos()
    for _, tool in ipairs(selectedTools) do
        local XName = GetSizeInputNames(tool)[1]
        local YName = GetSizeInputNames(tool)[2]
        initialScaledToolSizes[tool] = { tool:GetInput(XName, comp.CurrentTime), tool:GetInput(YName, comp.CurrentTime) }
    end

    comp:StartUndo("GLViewer_BlenderScale")
    UpdateLoop.RegisterFunction(Update)
end


function ViewerScale(toolList)
    local mousePosScreenSpace = fu:GetMousePos()

    local firstToolPos = toolList[1]:GetInput("Center", comp.CurrentTime)

    -- TODO: Change to use bounding box center
    local pivotPointScreenSpace = ConvertViewerToScreenSpacePos(firstToolPos)
    local distanceFromStartToPivot = distance(initialMousePosition, pivotPointScreenSpace)
    local currentDistanceToPivot = distance(mousePosScreenSpace, pivotPointScreenSpace)

    --Distance to pivot normalized
    local scaleFactor = mapRange(currentDistanceToPivot, 0, distanceFromStartToPivot, 0, 1)

    for _, tool in ipairs(toolList) do

        local XName = GetSizeInputNames(tool)[1]
        local YName = GetSizeInputNames(tool)[2]
        --Use setinput instead
        tool:SetInput(XName, initialScaledToolSizes[tool][1] * scaleFactor, comp.CurrentTime)
        tool:SetInput(YName, initialScaledToolSizes[tool][2] * scaleFactor, comp.CurrentTime)
    end
end

-- Execution starts here. 
Start()