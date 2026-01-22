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
local initialRotatedToolRotations = {}

local cumulativeRotation = 0
local lastRawAngle = nil

local function mapRange(value, in_min, in_max, out_min, out_max)
    -- Ensure the input value is within the range
    if in_min == in_max then
        return out_min  -- Avoid division by zero, return the minimum of the output range
    end
    
    -- Map the value from the input range to the output range
    local mapped_value = (value - in_min) * (out_max - out_min) / (in_max - in_min) + out_min
    return mapped_value
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

local Update 
Update = function()
    ViewerRotate(comp:GetToolList(true))

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

function To0To360(angle)
    if angle < 0 then
        angle = angle * -1
    else
        angle = 360 - angle
    end
    return angle
end

function ViewerRotate(toolList)
    local mousePosScreenSpace = fu:GetMousePos()
    local firstToolPos = toolList[1]:GetInput("Center", comp.CurrentTime)
    local pivotPointScreenSpace = ConvertViewerToScreenSpacePos(firstToolPos)
    
    -- Calculate angle from pivot to initial mouse position (only on first call)
    if lastRawAngle == nil then
        local dx0 = initialMousePosition[1] - pivotPointScreenSpace[1]
        local dy0 = initialMousePosition[2] - pivotPointScreenSpace[2]
        local initialAngle = math.deg(math.atan2(dy0, dx0))
        lastRawAngle = initialAngle
        cumulativeRotation = 0
        print("Initial angle: " .. initialAngle)
    end
    
    -- Calculate angle from pivot to current mouse position
    local dx1 = mousePosScreenSpace[1] - pivotPointScreenSpace[1]
    local dy1 = mousePosScreenSpace[2] - pivotPointScreenSpace[2]
    local currentAngle = math.deg(math.atan2(dy1, dx1))
    
    -- Calculate the shortest angular distance
    local deltaAngleDeg = currentAngle - lastRawAngle
    
    -- Handle wrap-around (crossing 180/-180 boundary)
    if deltaAngleDeg > 180 then
        deltaAngleDeg = deltaAngleDeg - 360
    elseif deltaAngleDeg < -180 then
        deltaAngleDeg = deltaAngleDeg + 360
    end
    
    -- Accumulate the rotation
    cumulativeRotation = cumulativeRotation + deltaAngleDeg
    lastRawAngle = currentAngle
    
    -- print("Current angle: " .. currentAngle)
    -- print("Delta this frame: " .. deltaAngleDeg)
    -- print("Cumulative rotation: " .. cumulativeRotation)
    -- print("-----")
    
    for _, tool in ipairs(toolList) do
        tool:SetInput("Angle", initialRotatedToolRotations[tool][1] + -1 * cumulativeRotation, comp.CurrentTime)
    end
end

function Start()
    local selectedTools = comp:GetToolList(true)

    initialMousePosition = fu:GetMousePos()
    for _, tool in ipairs(selectedTools) do
        initialRotatedToolRotations[tool] = { tool:GetInput("Angle", comp.CurrentTime) }
    end

    comp:StartUndo("GLViewer_BlenderRotate")
    UpdateLoop.RegisterFunction(Update)
end

-- Execution starts here. 
Start()