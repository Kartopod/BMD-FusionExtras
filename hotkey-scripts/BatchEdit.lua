-- BMD-FusionExtras - Additional tools to improve fusion's functionality
-- Copyright (c) 2025 Karto
--
-- Licensed under the MIT License. See LICENSE file in the project root.


msg = 
    "1. Select a control from the dropdown, or enter the name of the property manually in the field below.\n" ..
    "Tip: Hover over the name of a control in the inspector to see it's name at the bottom left of the screen.\n\n" ..
    "2. If the control is a point control (Like Center), use the 'Point Value' field. Otherwise, use the 'Value' field. The one you don't use can be ignored.\n\n" ..
    "3. Click OK to apply the changes."

presetControls = {
    "None",
    "Center",
    "Angle",
    "Size",
    "Width",
    "Height",
}


function Start()
    ret = composition:AskUser("Batch Edit Selected Tools", 
        {
            {"How to use", "Text", Name = "Instructions", Default = msg, ReadOnly = true, Wrap = true, Lines = 5},
            {"PresetControl", Name = "Select A Control", "Dropdown", Options = presetControls, Default = 0},
            {"ControlName", "Text", Name = "or enter name manually", Lines = 1},
            {"Value", "Text", Name = "Value", Lines = 1},
            {"PointValue", "Position", Name = "or Point Value", Default = {0, 0}, Lines = 1},
        } )

    if ret == nil then
        print("User cancelled the operation.")
        return
    end

    local controlName = presetControls[ret.PresetControl + 1]
    local value = ret.Value
    local pointValue = ret.PointValue

    local selectedTools = comp:GetToolList(true)

    print("ControlName: " .. controlName)
    print("Value: " .. value)

    if controlName == "None" then
        controlName = ret.ControlName
    end


    comp:StartUndo("Batch Edit Selected Tools")

    -- Check if is number
    -- dump((selectedTools[2]:GetInput(controlName)))
    print(selectedTools[1]:GetInput(controlName))
    if type(selectedTools[1]:GetInput(controlName)) == "number" then
        print(controlName .. " Is Number")
        value = tonumber(value)
    end

    if type(selectedTools[1]:GetInput(controlName)) == "table" then
        print(controlName .. " Is Point")
        value = pointValue
    end

    -- print("--------")

    for index, currentTool in ipairs(selectedTools) do
        print("Editing: " .. currentTool.Name)

        currentTool:SetInput(controlName, value, comp.CurrentTime)
    end

    comp:EndUndo()
    
end

-- Execution starts here. 
Start()