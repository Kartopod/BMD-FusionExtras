-- BMD-FusionExtras - Additional tools to improve fusion's functionality
-- Copyright (c) 2025 Karto
--
-- Licensed under the MIT License. See LICENSE file in the project root.


-- Depends on Tween, EasingFunctions scriptlib files

local saveDeletedToClipboard = true -- Set to false to not save deleted tools to clipboard
local flow = comp:GetViewList().FlowView
local selectedToolList = comp:GetToolList(true)

local toolStartPositionTable = {}

local function Start()
  math.randomseed(os.clock())

  for _, tool in ipairs(selectedToolList) do
      local x, y = flow:GetPos(tool)

      table.insert(toolStartPositionTable, {x, y})
  end

  function RandomFloat(min, max)
    return min + (max - min) * math.random()
  end

  if saveDeletedToClipboard then
    comp:Copy()
  end

  comp:StartUndo("Tool deletion")
  for i, tool in pairs(selectedToolList) do
      local xOffset = RandomFloat(-3, 3)
      local yOffset = RandomFloat(8, 15)
      local randomDuration = RandomFloat(0.40, .55)
      local startOffset = 0

      local tween = Tween.new()
      tween:TweenInterval(startOffset)
      tween:TweenPosition(tool, nil, {xOffset, yOffset}, randomDuration, {Linear, EaseInBack})
      tween:TweenCallback(function() tool:Delete() end)
  end

  flow:Select()

  Tween.Start()
  comp:EndUndo(true)
end

-- Execution starts here. 
Start()