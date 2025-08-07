-- BMD-FusionExtras - Additional tools to improve fusion's functionality
-- Copyright (c) 2025 Karto
--
-- Licensed under the MIT License. See LICENSE file in the project root.


local flow = comp:GetViewList().FlowView
local runawayTween

function RandomFloat(min, max)
    return min + (max - min) * math.random()
end

local Update
Update = function()
    local selectedTools = comp:GetToolList(true)
    local firstSelectedTool = selectedTools[1]
    if (firstSelectedTool ~= nil) then
        flow:Select() -- Deselect tools
        for _, t in ipairs(selectedTools) do
            runawayTween = Tween.new()
            runawayTween:TweenPosition(t, nil, { RandomFloat(-2, 2), RandomFloat(-2, 2) }, .8,
                EaseOutElastic)
        end
        Tween.Start()
    end

    local mouseButtons = fu:GetMouseButtons()
    if mouseButtons.RightButton then
        print("Turning off -RunFromSelection-")

        UpdateLoop.DeregisterFunction(Update) 
        comp:EndUndo()
        comp:Undo()
    end
end

local function Start()
    print("Turning on -RunFromSelection-")
    math.randomseed(os.clock())

    comp:StartUndo("RunFromSelection")

    UpdateLoop.RegisterFunction(Update)
end

-- Execution starts here.
Start()

