local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local Screen = workspace.Map.Functional.Screen
local QuestionText = Screen.SurfaceGui.MainFrame.MainGameContainer.MainTxtContainer.QuestionText
local TypingText = Screen.SurfaceGui.MainFrame.MainGameContainer.MainTxtContainer.TypingText
local Fill = Screen.SurfaceGui.MainFrame.MainGameContainer.TimerbarContainer.Fill
local CurrentSpeller = ReplicatedStorage.GameValues.CurrentSpeller
local ClickSound = ReplicatedStorage.Assets.SFX.Click
local GameEvent = ReplicatedStorage.Events.GameEvent

if getgenv().MathSolverGlobalRef then
    if getgenv().MathSolverGlobalRef.MainGui and getgenv().MathSolverGlobalRef.MainGui.Parent then
        getgenv().MathSolverGlobalRef.MainGui:Destroy()
    end
    if getgenv().MathSolverGlobalRef.ToggleButton and getgenv().MathSolverGlobalRef.ToggleButton.Parent then
        getgenv().MathSolverGlobalRef.ToggleButton:Destroy()
    end
end

if getgenv().script_connections_mathsolver then
  for _, Connection in ipairs(getgenv().script_connections_mathsolver) do
    if typeof(Connection) == "RBXScriptConnection" then Connection:Disconnect() end
  end
  table.clear(getgenv().script_connections_mathsolver)
end
local Connections = {}
getgenv().script_connections_mathsolver = Connections

local Settings = getgenv().MathSolverSettings or {
    ScriptEnabled = true,
    HUDVisible = true,

    EasyMaxOperand = 10,
    EasyMaxResult = 20,
    EasyOnlyPlusMinus = true,

    EasyMinInitialWait = 0.1,
    EasyMaxInitialWait = 0.3,
    EasyMinTypingSpeedPerChar = 0.03,
    EasyMaxTypingSpeedPerChar = 0.08,
    EasyPreSubmitDelay = 0.05,

    HardMinInitialWait = 0.6,
    HardMaxInitialWait = 1.2,
    HardMinTypingSpeedPerChar = 0.15,
    HardMaxTypingSpeedPerChar = 0.3,
    HardBackspaceDelay = 0.08,
    HardMinMistakeWaitAfterTyping = 0.2,
    HardMaxMistakeWaitAfterTyping = 0.5,
    HardMinMistakeWaitAfterCorrecting = 0.1,
    HardMaxMistakeWaitAfterCorrecting = 0.3,
    HardChanceOfMistake = 4,
    HardChanceOfRandomPause = 7,
    HardMinRandomPauseDuration = 0.3,
    HardMaxRandomPauseDuration = 0.7,
    HardPreSubmitDelay = 0.15,
}
getgenv().MathSolverSettings = Settings

local MainGui = Instance.new("ScreenGui")
MainGui.Name = "MathSolverHUD"
MainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
MainGui.ResetOnSpawn = false

local AccentColor = Color3.fromRGB(0, 122, 204)
local BGColor = Color3.fromRGB(30, 32, 36)
local LightBGColor = Color3.fromRGB(45, 48, 52)
local TextColor = Color3.fromRGB(220, 220, 220)
local MutedTextColor = Color3.fromRGB(150, 150, 150)
local ErrorColor = Color3.fromRGB(200, 70, 70)
local SuccessColor = Color3.fromRGB(70, 200, 70)

local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleHUDButton"
ToggleButton.Size = UDim2.new(0, 160, 0, 35)
ToggleButton.Position = UDim2.new(1, -170, 0, 10)
ToggleButton.AnchorPoint = Vector2.new(0, 0)
ToggleButton.BackgroundColor3 = LightBGColor
ToggleButton.BorderColor3 = AccentColor
ToggleButton.BorderSizePixel = 1
ToggleButton.TextColor3 = TextColor
ToggleButton.Text = "Toggle Solver HUD"
ToggleButton.Font = Enum.Font.GothamSemibold
ToggleButton.TextSize = 14
local tbCorner = Instance.new("UICorner", ToggleButton)
tbCorner.CornerRadius = UDim.new(0, 6)
ToggleButton.Parent = MainGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 420, 0, 0) 
MainFrame.ClipsDescendants = true
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = BGColor
MainFrame.BorderColor3 = AccentColor
MainFrame.BorderSizePixel = 2
MainFrame.Draggable = true
MainFrame.Active = true
MainFrame.Selectable = true
MainFrame.Visible = Settings.HUDVisible
local mfCorner = Instance.new("UICorner", MainFrame)
mfCorner.CornerRadius = UDim.new(0, 8)
MainFrame.Parent = MainGui

local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = LightBGColor
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local Title = Instance.new("TextLabel", Header)
Title.Name = "Title"
Title.Size = UDim2.new(1, -80, 1, 0)
Title.Position = UDim2.new(0, 40, 0, 0)
Title.BackgroundTransparency = 1
Title.TextColor3 = TextColor
Title.Text = "Math Solver Settings"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Center

local ScriptEnabledButton = Instance.new("TextButton", Header)
ScriptEnabledButton.Name = "ScriptEnabledButton"
ScriptEnabledButton.Size = UDim2.new(0, 30, 0, 30)
ScriptEnabledButton.Position = UDim2.new(0, 5, 0, 5)
ScriptEnabledButton.Text = ""
local seCorner = Instance.new("UICorner", ScriptEnabledButton)
seCorner.CornerRadius = UDim.new(0, 4)

local ScriptEnabledIcon = Instance.new("ImageLabel", ScriptEnabledButton)
ScriptEnabledIcon.Size = UDim2.new(1, -8, 1, -8)
ScriptEnabledIcon.Position = UDim2.new(0, 4, 0, 4)
ScriptEnabledIcon.BackgroundTransparency = 1
ScriptEnabledIcon.ScaleType = Enum.ScaleType.Fit

local CloseButton = Instance.new("TextButton", Header)
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0, 5)
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Text = "X"
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 16
local cbCorner = Instance.new("UICorner", CloseButton)
cbCorner.CornerRadius = UDim.new(0, 4)

local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, 0, 1, -40)
ContentFrame.Position = UDim2.new(0,0,0,40)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Size = UDim2.new(1, -10, 1, -10)
ScrollingFrame.Position = UDim2.new(0, 5, 0, 5)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.BorderSizePixel = 0
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollingFrame.ScrollBarThickness = 8
ScrollingFrame.ScrollBarImageColor3 = AccentColor
ScrollingFrame.Parent = ContentFrame

local UIListLayout = Instance.new("UIListLayout", ScrollingFrame)
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function UpdateScriptEnabledVisuals()
    ScriptEnabledButton.BackgroundColor3 = Settings.ScriptEnabled and SuccessColor or ErrorColor
    ScriptEnabledIcon.Image = Settings.ScriptEnabled and "rbxassetid://13518619827" or "rbxassetid://13518620044" -- Tick / Cross
end
UpdateScriptEnabledVisuals()

local function CreateSectionLabel(text, order)
    local label = Instance.new("TextLabel")
    label.Name = text:gsub("%s+", "") .. "Section"
    label.Size = UDim2.new(1, -10, 0, 30)
    label.BackgroundColor3 = LightBGColor
    label.TextColor3 = TextColor
    label.Text = "  " .. text
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 16
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.LayoutOrder = order
    local lCorner = Instance.new("UICorner", label)
    lCorner.CornerRadius = UDim.new(0, 5)
    label.Parent = ScrollingFrame
    return label
end

local function CreateSettingInput(labelText, settingKey, order, isToggle, isInt)
    local container = Instance.new("Frame")
    container.Name = settingKey .. "Container"
    container.Size = UDim2.new(1, -10, 0, 35)
    container.BackgroundTransparency = 1
    container.LayoutOrder = order
    container.Parent = ScrollingFrame

    local label = Instance.new("TextLabel", container)
    label.Name = "Label"
    label.Size = UDim2.new(0.6, -5, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = MutedTextColor
    label.Text = " " .. labelText .. ":"
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left

    if isToggle then
        local switchTrack = Instance.new("Frame", container)
        switchTrack.Name = "SwitchTrack"
        switchTrack.Size = UDim2.new(0.35, 0, 0, 20)
        switchTrack.Position = UDim2.new(0.65, 0, 0.5, -10)
        switchTrack.BackgroundColor3 = Settings[settingKey] and AccentColor or Color3.fromRGB(80,80,80)
        local stCorner = Instance.new("UICorner", switchTrack)
        stCorner.CornerRadius = UDim.new(0, 10)

        local switchNub = Instance.new("TextButton", switchTrack)
        switchNub.Name = "SwitchNub"
        switchNub.Size = UDim2.new(0, 16, 0, 16)
        switchNub.Position = Settings[settingKey] and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        switchNub.AnchorPoint = Vector2.new(0,0.5)
        switchNub.BackgroundColor3 = Color3.fromRGB(240,240,240)
        switchNub.Text = ""
        switchNub.BorderSizePixel = 0
        local snCorner = Instance.new("UICorner", switchNub)
        snCorner.CornerRadius = UDim.new(1, 0)
        
        local clickRegion = Instance.new("TextButton", container)
        clickRegion.Name = "ClickRegion"
        clickRegion.Size = UDim2.new(0.35, 0, 1, 0)
        clickRegion.Position = UDim2.new(0.65, 0, 0, 0)
        clickRegion.BackgroundTransparency = 1
        clickRegion.Text = ""

        clickRegion.MouseButton1Click:Connect(function()
            Settings[settingKey] = not Settings[settingKey]
            switchTrack.BackgroundColor3 = Settings[settingKey] and AccentColor or Color3.fromRGB(80,80,80)
            local targetPos = Settings[settingKey] and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
            TweenService:Create(switchNub, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = targetPos}):Play()
        end)
    else
        local textbox = Instance.new("TextBox", container)
        textbox.Name = "Input"
        textbox.Size = UDim2.new(0.35, 0, 1, -5)
        textbox.Position = UDim2.new(0.65, 0, 0.5, 0)
        textbox.AnchorPoint = Vector2.new(0, 0.5)
        textbox.BackgroundColor3 = Color3.fromRGB(55, 58, 64)
        textbox.BorderColor3 = Color3.fromRGB(70, 70, 70)
        textbox.TextColor3 = TextColor
        textbox.Text = tostring(Settings[settingKey])
        textbox.Font = Enum.Font.Gotham
        textbox.TextSize = 14
        textbox.ClearTextOnFocus = false
        local tbCorner = Instance.new("UICorner", textbox)
        tbCorner.CornerRadius = UDim.new(0, 4)
        
        textbox.FocusLost:Connect(function(enterPressed)
            if enterPressed or textbox.Text ~= tostring(Settings[settingKey]) then
                local num = tonumber(textbox.Text)
                if num then
                    Settings[settingKey] = isInt and math.floor(num) or num
                    textbox.Text = tostring(Settings[settingKey])
                else
                    textbox.Text = tostring(Settings[settingKey])
                end
            end
        end)
    end
    return container
end

local currentOrder = 1
CreateSectionLabel("Easy Question Criteria", currentOrder); currentOrder = currentOrder + 1
CreateSettingInput("Max Operand", "EasyMaxOperand", currentOrder, false, true); currentOrder = currentOrder + 1
CreateSettingInput("Max Result", "EasyMaxResult", currentOrder, false, true); currentOrder = currentOrder + 1
CreateSettingInput("Plus/Minus Only?", "EasyOnlyPlusMinus", currentOrder, true); currentOrder = currentOrder + 1

CreateSectionLabel("Easy Question Speed", currentOrder); currentOrder = currentOrder + 1
CreateSettingInput("Min Initial Wait (s)", "EasyMinInitialWait", currentOrder); currentOrder = currentOrder + 1
CreateSettingInput("Max Initial Wait (s)", "EasyMaxInitialWait", currentOrder); currentOrder = currentOrder + 1
CreateSettingInput("Min Typing/Char (s)", "EasyMinTypingSpeedPerChar", currentOrder); currentOrder = currentOrder + 1
CreateSettingInput("Max Typing/Char (s)", "EasyMaxTypingSpeedPerChar", currentOrder); currentOrder = currentOrder + 1
CreateSettingInput("Pre-Submit Delay (s)", "EasyPreSubmitDelay", currentOrder); currentOrder = currentOrder + 1

CreateSectionLabel("Hard Question Speed", currentOrder); currentOrder = currentOrder + 1
CreateSettingInput("Min Initial Wait (s)", "HardMinInitialWait", currentOrder); currentOrder = currentOrder + 1
CreateSettingInput("Max Initial Wait (s)", "HardMaxInitialWait", currentOrder); currentOrder = currentOrder + 1
CreateSettingInput("Min Typing/Char (s)", "HardMinTypingSpeedPerChar", currentOrder); currentOrder = currentOrder + 1
CreateSettingInput("Max Typing/Char (s)", "HardMaxTypingSpeedPerChar", currentOrder); currentOrder = currentOrder + 1
CreateSettingInput("Backspace Delay (s)", "HardBackspaceDelay", currentOrder); currentOrder = currentOrder + 1
CreateSettingInput("Min Post-Mistake Wait (s)", "HardMinMistakeWaitAfterTyping", currentOrder); currentOrder = currentOrder + 1
CreateSettingInput("Max Post-Mistake Wait (s)", "HardMaxMistakeWaitAfterTyping", currentOrder); currentOrder = currentOrder + 1
CreateSettingInput("Min Post-Correction Wait (s)", "HardMinMistakeWaitAfterCorrecting", currentOrder); currentOrder = currentOrder + 1
CreateSettingInput("Max Post-Correction Wait (s)", "HardMaxMistakeWaitAfterCorrecting", currentOrder); currentOrder = currentOrder + 1
CreateSettingInput("Mistake Chance (1 in X)", "HardChanceOfMistake", currentOrder, false, true); currentOrder = currentOrder + 1
CreateSettingInput("Random Pause Chance (1 in X)", "HardChanceOfRandomPause", currentOrder, false, true); currentOrder = currentOrder + 1
CreateSettingInput("Min Random Pause (s)", "HardMinRandomPauseDuration", currentOrder); currentOrder = currentOrder + 1
CreateSettingInput("Max Random Pause (s)", "HardMaxRandomPauseDuration", currentOrder); currentOrder = currentOrder + 1
CreateSettingInput("Pre-Submit Delay (s)", "HardPreSubmitDelay", currentOrder); currentOrder = currentOrder + 1

task.wait(0.1)
local requiredHeight = UIListLayout.AbsoluteContentSize.Y + 20 + Header.AbsoluteSize.Y
-- LINHA CORRIGIDA ABAIXO:
local screenHeight = workspace.CurrentCamera.ViewportSize.Y
MainFrame.Size = UDim2.new(0, 420, 0, math.min(requiredHeight, screenHeight - 100))
-- FIM DA CORREÇÃO
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 10)

ScriptEnabledButton.MouseButton1Click:Connect(function()
    Settings.ScriptEnabled = not Settings.ScriptEnabled
    UpdateScriptEnabledVisuals()
end)

local hudTween
local function SetHudVisible(visible)
    Settings.HUDVisible = visible
    MainFrame.Visible = true 

    if hudTween then hudTween:Cancel() end
    local targetTransparency = visible and 0 or 1
    -- USA A MESMA LÓGICA CORRIGIDA AQUI TAMBÉM:
    local targetSize = visible and UDim2.new(0, 420, 0, math.min(requiredHeight, screenHeight - 100)) or UDim2.new(0, 420, 0, 0)
    
    hudTween = TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = targetTransparency,
        Size = targetSize
    })
    hudTween:Play()
    
    hudTween.Completed:Connect(function()
        if not visible then MainFrame.Visible = false end
    end)
end


ToggleButton.MouseButton1Click:Connect(function()
    SetHudVisible(not Settings.HUDVisible)
end)
CloseButton.MouseButton1Click:Connect(function()
    SetHudVisible(false)
end)

if not Settings.HUDVisible then
    MainFrame.BackgroundTransparency = 1
    MainFrame.Size = UDim2.new(0, 420, 0, 0)
    MainFrame.Visible = false
else
    SetHudVisible(true) 
end


MainGui.Parent = CoreGui
getgenv().MathSolverGlobalRef = { MainGui = MainGui, ToggleButton = ToggleButton }

local function SetTyping(text)
  if Settings.ScriptEnabled then
    ClickSound:Play()
    TypingText.Text = text
    GameEvent:FireServer("updateAnswer", text)
  end
end

local function IsQuestionEasy(num1Str, operator, num2Str, resultStr)
    local n1, n2, res
    local success1, val1 = pcall(function() return tonumber(num1Str) end)
    local success2, val2 = pcall(function() return tonumber(num2Str) end)
    local success3, val3 = pcall(function() return tonumber(resultStr) end)

    if not (success1 and success2 and success3) then return false end
    n1, n2, res = val1, val2, val3
    if not n1 or not n2 or not res then return false end

    local isPlusMinus = (operator == "+" or operator == "-")
    if Settings.EasyOnlyPlusMinus and not isPlusMinus then return false end

    local operandsOk = (math.abs(n1) <= Settings.EasyMaxOperand and math.abs(n2) <= Settings.EasyMaxOperand)
    local resultOk = (math.abs(res) <= Settings.EasyMaxResult)

    return operandsOk and resultOk and (isPlusMinus or not Settings.EasyOnlyPlusMinus)
end

table.insert(Connections, Fill:GetPropertyChangedSignal("Size"):Connect(function()
  if not Settings.ScriptEnabled then return end
  if Fill:GetAttribute("Answer") then
    if Fill.Size.X.Scale <= Fill:GetAttribute("UhunAnswer") and not Fill:GetAttribute("TweenEnabled") then
      Fill:SetAttribute("TweenEnabled", true)
    elseif Fill.Size.X.Scale >= Fill:GetAttribute("UhunAnswer") then
      Fill:SetAttribute("TweenEnabled", nil)
    end
  end
end))

table.insert(Connections, QuestionText:GetPropertyChangedSignal("Text"):Connect(function()
  if not Settings.ScriptEnabled or CurrentSpeller.Value ~= Player then
    if TypingText.Text ~= "" then TypingText.Text = "" end
    return
  end
  
  local Character = Player.Character or Player.CharacterAdded:Wait()
  
  local questionFull = QuestionText.Text
  if questionFull == "" or not string.find(questionFull, "=") then return end

  local questionParts = string.split(questionFull, "=")
  local question = questionParts[1]
  
  local success, result_or_error = pcall(function()
      return tostring(loadstring("return " .. string.gsub(question, "x", "*"))())
  end)

  if not success or not result_or_error then
      warn("Error calculating question:", question, "Error:", result_or_error)
      return
  end
  local result = result_or_error
  
  local num1Str, operator, num2Str = string.match(string.gsub(question, "%s+", ""), "([%-]?%d+[%.]?%d*)([%+%-%*/x])([%-]?%d+[%.]?%d*)")
  if operator and string.lower(operator) == "x" then operator = "*" end

  local isEasy = false
  if num1Str and operator and num2Str then
      isEasy = IsQuestionEasy(num1Str, operator, num2Str, result)
  end

  local currentSettingsProfile
  if isEasy then
      currentSettingsProfile = {
          MinInitialWait = Settings.EasyMinInitialWait,
          MaxInitialWait = Settings.EasyMaxInitialWait,
          MinTypingSpeedPerChar = Settings.EasyMinTypingSpeedPerChar,
          MaxTypingSpeedPerChar = Settings.EasyMaxTypingSpeedPerChar,
          PreSubmitDelay = Settings.EasyPreSubmitDelay,
          MakeMistakes = false
      }
  else
      currentSettingsProfile = {
          MinInitialWait = Settings.HardMinInitialWait,
          MaxInitialWait = Settings.HardMaxInitialWait,
          MinTypingSpeedPerChar = Settings.HardMinTypingSpeedPerChar,
          MaxTypingSpeedPerChar = Settings.HardMaxTypingSpeedPerChar,
          BackspaceDelay = Settings.HardBackspaceDelay,
          MinMistakeWaitAfterTyping = Settings.HardMinMistakeWaitAfterTyping,
          MaxMistakeWaitAfterTyping = Settings.HardMaxMistakeWaitAfterTyping,
          MinMistakeWaitAfterCorrecting = Settings.HardMinMistakeWaitAfterCorrecting,
          MaxMistakeWaitAfterCorrecting = Settings.HardMaxMistakeWaitAfterCorrecting,
          ChanceOfMistake = Settings.HardChanceOfMistake,
          ChanceOfRandomPause = Settings.HardChanceOfRandomPause,
          MinRandomPauseDuration = Settings.HardMinRandomPauseDuration,
          MaxRandomPauseDuration = Settings.HardMaxRandomPauseDuration,
          PreSubmitDelay = Settings.HardPreSubmitDelay,
          MakeMistakes = true
      }
  end
  
  Fill:SetAttribute("Answer", math.random(1, 2) == 1 and result)
  Fill:SetAttribute("UhunAnswer", math.random(3, 6) / 10)
  
  task.wait(math.random(currentSettingsProfile.MinInitialWait * 100, currentSettingsProfile.MaxInitialWait * 100) / 100)
  
  if not Settings.ScriptEnabled then return end

  local targetText = tostring(result)
  if TypingText.Text ~= "" then TypingText.Text = "" end

  for i = 1, #targetText do
    if not Settings.ScriptEnabled then if TypingText.Text ~= "" then TypingText.Text = "" end; return end
    
    if currentSettingsProfile.MakeMistakes and #TypingText.Text > 0 and Fill.Size.X.Scale >= 0.3 and
       currentSettingsProfile.ChanceOfMistake > 0 and math.random(1, currentSettingsProfile.ChanceOfMistake) == 1 then
      
      SetTyping(TypingText.Text .. tostring(math.random(0, 9)))
      task.wait(math.random(currentSettingsProfile.MinMistakeWaitAfterTyping * 100, currentSettingsProfile.MaxMistakeWaitAfterTyping * 100) / 100)
      if not Settings.ScriptEnabled then if TypingText.Text ~= "" then TypingText.Text = "" end; return end

      SetTyping(string.sub(TypingText.Text, 1, #TypingText.Text - 1))
      task.wait(math.random(currentSettingsProfile.MinMistakeWaitAfterCorrecting * 100, currentSettingsProfile.MaxMistakeWaitAfterCorrecting * 100) / 100)
      if not Settings.ScriptEnabled then if TypingText.Text ~= "" then TypingText.Text = "" end; return end
    end

    SetTyping(TypingText.Text .. string.sub(targetText, i, i))
    
    local typingSpeedPerChar = math.random(currentSettingsProfile.MinTypingSpeedPerChar * 100, currentSettingsProfile.MaxTypingSpeedPerChar * 100) / 100
    local speedMultiplier = math.clamp(Fill.Size.X.Scale, 0.25, 1)
    task.wait(typingSpeedPerChar * speedMultiplier)
    if not Settings.ScriptEnabled then if TypingText.Text ~= "" then TypingText.Text = "" end; return end

    if currentSettingsProfile.MakeMistakes and currentSettingsProfile.ChanceOfRandomPause > 0 and 
       math.random(1, currentSettingsProfile.ChanceOfRandomPause) == 1 and Fill.Size.X.Scale >= 0.25 then
      task.wait(math.random(currentSettingsProfile.MinRandomPauseDuration * 100, currentSettingsProfile.MaxRandomPauseDuration * 100) / 100)
    end
    if not Settings.ScriptEnabled then if TypingText.Text ~= "" then TypingText.Text = "" end; return end
  end
  
  if TypingText.Text == targetText then
    task.wait(currentSettingsProfile.PreSubmitDelay)
    if Settings.ScriptEnabled and CurrentSpeller.Value == Player and TypingText.Text == targetText then
      GameEvent:FireServer("submitAnswer", targetText)
    end
  else
    if TypingText.Text ~= "" then TypingText.Text = "" end
  end
end))

print("Math Solver HUD & Logic Loaded. Adjust settings in the HUD.")
if MainGui.Parent ~= CoreGui and MainGui.Parent ~= PlayerGui then
    MainGui.Parent = CoreGui
    warn("Math Solver HUD parented to CoreGui as a fallback.")
end
