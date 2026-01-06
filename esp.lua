--thx k0nkx

local BoxESPLib = {}

if getgenv()._BoxESP then
    for _, c in ipairs(getgenv()._BoxESP.Connections) do
        pcall(function() c:Disconnect() end)
    end
    
    for _, guis in pairs(getgenv()._BoxESP.GUIs) do
        for _, gui in pairs(guis) do
            if type(gui) == 'table' then
                for _, tag in ipairs(gui) do
                    pcall(function() tag:Destroy() end)
                end
            else
                pcall(function() gui:Destroy() end)
            end
        end
    end
    
    if game.CoreGui:FindFirstChild('BoxESPScreenGui') then
        pcall(function() game.CoreGui.BoxESPScreenGui:Destroy() end)
    end
    
    getgenv()._BoxESP = nil
end

local ESP = {
    Connections = {},
    GUIs = {},
    HealthStates = {},
    HealthChanges = {},
    PlayerHealthConnections = {},
    Enabled = false,
    
    Settings = {
        Keybind = Enum.KeyCode.End,
        LocalDebug = false,
        IgnoreTeam = false,
        SimpleBoxMode = true,

        Box = {
            Enabled = false,
            Color = Color3.fromRGB(255, 255, 255),
            Thickness = 1.5,
            Transparency = 0,
            Filled = false,
            FilledTransparency = 0.75,
            MaxSize = 300,
            ColorTeam = true,
            Scale = 1.5,
        },

        Outline = {
            Enabled = false,
            Color = Color3.fromRGB(0, 0, 0),
            Thickness = 1,
            Transparency = 0,
        },

        Healthbar = {
            Enabled = false,
            Width = 3,
            Background = Color3.fromRGB(40, 40, 40),
            BackgroundTransparency = 0,
            OutlineColor = Color3.fromRGB(0, 0, 0),
            OutlineTransparency = 0,

            Gradient = {
                Colors = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 97, 242)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(137, 87, 255)),
                }),
                LerpAnimation = true,
                LerpSpeed = 0.028,
            },
        },

        HealthChange = {
            Enabled = false,
            Font = Enum.Font.DenkOne,
            Size = 11,
            Color = Color3.fromRGB(255, 255, 255),
            Transparency = 0,
            ShowOutline = true,
            OutlineColor = Color3.fromRGB(0, 0, 0),
            Duration = 2.3,
            FadeSpeed = 1,
            StackOffset = 11,
        },

        Nametag = {
            Enabled = false,
            Font = Enum.Font.SourceSansBold,
            Size = 13,
            Color = Color3.fromRGB(255, 255, 255),
            Transparency = 0,
            UseDisplayName = false,
            Offset = Vector2.new(0, -15),
            ShowOutline = true,
            OutlineColor = Color3.fromRGB(0, 0, 0),
        },

        Distance = {
            Enabled = false,
            Font = Enum.Font.SourceSansBold,
            Size = 13,
            Color = Color3.fromRGB(255, 255, 255),
            Transparency = 0,
            Offset = Vector2.new(0, 0),
            ShowOutline = true,
            OutlineColor = Color3.fromRGB(0, 0, 0),
        },

        Velocity = {
            Enabled = false,
            Font = Enum.Font.SourceSansBold,
            Size = 13,
            Color = Color3.fromRGB(255, 255, 255),
            Transparency = 0,
            ShowOutline = true,
            OutlineColor = Color3.fromRGB(0, 0, 0),
        },

        Highlight = {
            Enabled = false,
            Color = Color3.fromRGB(255, 255, 255),
            Transparency = 0.5,
            OutlineColor = Color3.fromRGB(255, 255, 255),
            OutlineTransparency = 0.08,
        },

        Character = {
            MaxPartDistance = 5,
            R6Parts = {
                'Head',
                'Torso',
                'Left Arm',
                'Right Arm',
                'Left Leg',
                'Right Leg',
            },
            R15Parts = {
                'UpperTorso',
                'LowerTorso',
                'Head',
                'LeftUpperArm',
                'LeftLowerArm',
                'LeftHand',
                'RightUpperArm',
                'RightLowerArm',
                'RightHand',
                'LeftUpperLeg',
                'LeftLowerLeg',
                'LeftFoot',
                'RightUpperLeg',
                'RightLowerLeg',
                'RightFoot',
            },
        },
    }
}

getgenv()._BoxESP = ESP

local ScreenGui
local RunService = game:GetService('RunService')
local Players = game:GetService('Players')
local UserInputService = game:GetService('UserInputService')
local Camera = workspace.CurrentCamera

local function Get3DBounds(char)
    local parts = {}
    for _, name in ipairs(ESP.Settings.Character.R6Parts) do
        local p = char:FindFirstChild(name)
        if p and p:IsA('BasePart') then
            table.insert(parts, p)
        end
    end
    for _, name in ipairs(ESP.Settings.Character.R15Parts) do
        local p = char:FindFirstChild(name)
        if p and p:IsA('BasePart') then
            table.insert(parts, p)
        end
    end
    if #parts == 0 then
        return
    end

    local min, max = Vector3.new(math.huge, math.huge, math.huge), Vector3.new(-math.huge, -math.huge, -math.huge)

    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA('BasePart') and not part.Parent:IsA('Accessory') then
            local include = false
            for _, mp in ipairs(parts) do
                if (part.Position - mp.Position).Magnitude <= ESP.Settings.Character.MaxPartDistance then
                    include = true
                    break
                end
            end
            if not include then
                continue
            end

            local size = part.Size / 2
            local cf = part.CFrame
            local corners = {
                cf * Vector3.new(size.X, size.Y, size.Z),
                cf * Vector3.new(size.X, size.Y, -size.Z),
                cf * Vector3.new(size.X, -size.Y, size.Z),
                cf * Vector3.new(size.X, -size.Y, -size.Z),
                cf * Vector3.new(-size.X, size.Y, size.Z),
                cf * Vector3.new(-size.X, size.Y, -size.Z),
                cf * Vector3.new(-size.X, -size.Y, size.Z),
                cf * Vector3.new(-size.X, -size.Y, -size.Z),
            }
            for _, c in ipairs(corners) do
                min = Vector3.new(math.min(min.X, c.X), math.min(min.Y, c.Y), math.min(min.Z, c.Z))
                max = Vector3.new(math.max(max.X, c.X), math.max(max.Y, c.Y), math.max(max.Z, c.Z))
            end
        end
    end
    return min, max
end

local function GetSimpleBoxSize(char)
    local head = char:FindFirstChild("Head")
    local root = char:FindFirstChild("HumanoidRootPart")
    
    if not head or not root then
        return nil
    end
    
    local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
    local footPos = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 2.5, 0))
    
    if headPos.Z <= 0 or footPos.Z <= 0 then
        return nil
    end
    
    local rawHeight = footPos.Y - headPos.Y
    local height = rawHeight * ESP.Settings.Box.Scale
    local width = (height / 2) * ESP.Settings.Box.Scale
    
    local x = headPos.X - width / 2
    local y = headPos.Y - (height - rawHeight) / 2
    
    local w, h = math.min(width, ESP.Settings.Box.MaxSize), math.min(height, ESP.Settings.Box.MaxSize)
    
    local centerX = headPos.X
    x = centerX - w / 2
    
    return x, y, w, h
end

local function GetBoxCorners(char)
    if ESP.Settings.SimpleBoxMode then
        local x, y, width, height = GetSimpleBoxSize(char)
        if not x then
            local min3D, max3D = Get3DBounds(char)
            if not min3D or not max3D then
                return
            end
            
            local points = {
                Vector3.new(min3D.X, max3D.Y, min3D.Z),
                Vector3.new(min3D.X, max3D.Y, max3D.Z),
                Vector3.new(max3D.X, max3D.Y, min3D.Z),
                Vector3.new(max3D.X, max3D.Y, max3D.Z),
                Vector3.new(min3D.X, min3D.Y, min3D.Z),
                Vector3.new(min3D.X, min3D.Y, max3D.Z),
                Vector3.new(max3D.X, min3D.Y, min3D.Z),
                Vector3.new(max3D.X, min3D.Y, max3D.Z),
            }
            
            local minX, maxX, minY, maxY = math.huge, -math.huge, math.huge, -math.huge
            for _, p in ipairs(points) do
                local screen = Camera:WorldToViewportPoint(p)
                if screen.Z > 0 then
                    minX, maxX = math.min(minX, screen.X), math.max(maxX, screen.X)
                    minY, maxY = math.min(minY, screen.Y), math.max(maxY, screen.Y)
                end
            end
            if minX == math.huge then
                return
            end
            
            local w, h = math.min(maxX - minX, ESP.Settings.Box.MaxSize), math.min(maxY - minY, ESP.Settings.Box.MaxSize)
            local cx, cy = (minX + maxX) / 2, (minY + maxY) / 2
            local hw, hh = w / 2, h / 2
            
            return Vector2.new(cx - hw, cy - hh),
                   Vector2.new(cx + hw, cy - hh),
                   Vector2.new(cx + hw, cy + hh),
                   Vector2.new(cx - hw, cy + hh),
                   w,
                   h
        end
        
        return Vector2.new(x, y),
               Vector2.new(x + width, y),
               Vector2.new(x + width, y + height),
               Vector2.new(x, y + height),
               width,
               height
    else
        local min3D, max3D = Get3DBounds(char)
        if not min3D or not max3D then
            return
        end

        local points = {
            Vector3.new(min3D.X, max3D.Y, min3D.Z),
            Vector3.new(min3D.X, max3D.Y, max3D.Z),
            Vector3.new(max3D.X, max3D.Y, min3D.Z),
            Vector3.new(max3D.X, max3D.Y, max3D.Z),
            Vector3.new(min3D.X, min3D.Y, min3D.Z),
            Vector3.new(min3D.X, min3D.Y, max3D.Z),
            Vector3.new(max3D.X, min3D.Y, min3D.Z),
            Vector3.new(max3D.X, min3D.Y, max3D.Z),
        }

        local minX, maxX, minY, maxY = math.huge, -math.huge, math.huge, -math.huge
        for _, p in ipairs(points) do
            local screen = Camera:WorldToViewportPoint(p)
            if screen.Z > 0 then
                minX, maxX = math.min(minX, screen.X), math.max(maxX, screen.X)
                minY, maxY = math.min(minY, screen.Y), math.max(maxY, screen.Y)
            end
        end
        if minX == math.huge then
            return
        end

        local w, h = math.min(maxX - minX, ESP.Settings.Box.MaxSize), math.min(maxY - minY, ESP.Settings.Box.MaxSize)
        local cx, cy = (minX + maxX) / 2, (minY + maxY) / 2
        local hw, hh = w / 2, h / 2

        return Vector2.new(cx - hw, cy - hh),
               Vector2.new(cx + hw, cy - hh),
               Vector2.new(cx + hw, cy + hh),
               Vector2.new(cx - hw, cy + hh),
               w,
               h
    end
end

local function CreateESP(player)
    if ESP.GUIs[player] then
        return
    end

    local boxFrame = Instance.new('Frame', ScreenGui)
    boxFrame.BackgroundTransparency = 1
    boxFrame.BorderSizePixel = 0
    boxFrame.Visible = false
    boxFrame.ZIndex = 1

    local boxStroke = Instance.new('UIStroke', boxFrame)
    boxStroke.Color = ESP.Settings.Box.Color
    boxStroke.Thickness = ESP.Settings.Box.Thickness
    boxStroke.Transparency = ESP.Settings.Box.Transparency

    local outlineFrame = Instance.new('Frame', ScreenGui)
    outlineFrame.BackgroundTransparency = 1
    outlineFrame.BorderSizePixel = 0
    outlineFrame.Visible = false
    outlineFrame.ZIndex = 0

    local outlineStroke = Instance.new('UIStroke', outlineFrame)
    outlineStroke.Color = ESP.Settings.Outline.Color
    outlineStroke.Thickness = ESP.Settings.Outline.Thickness
    outlineStroke.Transparency = ESP.Settings.Outline.Transparency

    local fillFrame = Instance.new('Frame', ScreenGui)
    fillFrame.BackgroundColor3 = ESP.Settings.Box.Color
    fillFrame.BackgroundTransparency = ESP.Settings.Box.FilledTransparency
    fillFrame.BorderSizePixel = 0
    fillFrame.Visible = false
    fillFrame.ZIndex = -1

    local healthbarOutline = Instance.new('Frame', ScreenGui)
    healthbarOutline.BackgroundColor3 = ESP.Settings.Healthbar.OutlineColor
    healthbarOutline.BackgroundTransparency = ESP.Settings.Healthbar.OutlineTransparency
    healthbarOutline.BorderSizePixel = 0
    healthbarOutline.Visible = false
    healthbarOutline.ZIndex = 2

    local barBG = Instance.new('Frame', healthbarOutline)
    barBG.BackgroundColor3 = ESP.Settings.Healthbar.Background
    barBG.BackgroundTransparency = ESP.Settings.Healthbar.BackgroundTransparency
    barBG.BorderSizePixel = 0
    barBG.Position = UDim2.fromOffset(1, 1)

    local barFill = Instance.new('Frame', barBG)
    barFill.BorderSizePixel = 0
    local gradient = Instance.new('UIGradient', barFill)
    gradient.Color = ESP.Settings.Healthbar.Gradient.Colors
    gradient.Rotation = 90

    local healthChangeTags = {}
    for i = 1, 3 do
        local healthChangeTag = Instance.new('TextLabel', ScreenGui)
        healthChangeTag.Font = ESP.Settings.HealthChange.Font
        healthChangeTag.TextSize = ESP.Settings.HealthChange.Size
        healthChangeTag.TextColor3 = ESP.Settings.HealthChange.Color
        healthChangeTag.TextTransparency = 1
        healthChangeTag.TextStrokeTransparency = 1
        healthChangeTag.TextStrokeColor3 = ESP.Settings.HealthChange.OutlineColor
        healthChangeTag.TextXAlignment = Enum.TextXAlignment.Right
        healthChangeTag.BackgroundTransparency = 1
        healthChangeTag.Visible = false
        healthChangeTag.ZIndex = 3
        table.insert(healthChangeTags, healthChangeTag)
    end

    local nameTag = Instance.new('TextLabel', ScreenGui)
    nameTag.Font = ESP.Settings.Nametag.Font
    nameTag.TextSize = ESP.Settings.Nametag.Size
    nameTag.TextColor3 = ESP.Settings.Nametag.Color
    nameTag.TextTransparency = ESP.Settings.Nametag.Transparency
    nameTag.TextStrokeTransparency = ESP.Settings.Nametag.ShowOutline and 0 or 1
    nameTag.TextStrokeColor3 = ESP.Settings.Nametag.OutlineColor
    nameTag.TextXAlignment = Enum.TextXAlignment.Center
    nameTag.BackgroundTransparency = 1
    nameTag.Visible = false
    nameTag.ZIndex = 3

    local distanceTag = Instance.new('TextLabel', ScreenGui)
    distanceTag.Font = ESP.Settings.Distance.Font
    distanceTag.TextSize = ESP.Settings.Distance.Size
    distanceTag.TextColor3 = ESP.Settings.Distance.Color
    distanceTag.TextTransparency = ESP.Settings.Distance.Transparency
    distanceTag.TextStrokeTransparency = ESP.Settings.Distance.ShowOutline and 0 or 1
    distanceTag.TextStrokeColor3 = ESP.Settings.Distance.OutlineColor
    distanceTag.TextXAlignment = Enum.TextXAlignment.Center
    distanceTag.BackgroundTransparency = 1
    distanceTag.Visible = false
    distanceTag.ZIndex = 3

    local velocityTag = Instance.new('TextLabel', ScreenGui)
    velocityTag.Font = ESP.Settings.Velocity.Font
    velocityTag.TextSize = ESP.Settings.Velocity.Size
    velocityTag.TextColor3 = ESP.Settings.Velocity.Color
    velocityTag.TextTransparency = ESP.Settings.Velocity.Transparency
    velocityTag.TextStrokeTransparency = ESP.Settings.Velocity.ShowOutline and 0 or 1
    velocityTag.TextStrokeColor3 = ESP.Settings.Velocity.OutlineColor
    velocityTag.TextXAlignment = Enum.TextXAlignment.Left
    velocityTag.BackgroundTransparency = 1
    velocityTag.Visible = false
    velocityTag.ZIndex = 3

    local highlight = Instance.new('Highlight')
    highlight.FillColor = ESP.Settings.Highlight.Color
    highlight.FillTransparency = ESP.Settings.Highlight.Transparency
    highlight.OutlineColor = ESP.Settings.Highlight.OutlineColor
    highlight.OutlineTransparency = ESP.Settings.Highlight.OutlineTransparency
    highlight.Enabled = false
    highlight.Parent = ScreenGui

    ESP.GUIs[player] = {
        boxFrame = boxFrame,
        boxStroke = boxStroke,
        outlineFrame = outlineFrame,
        outlineStroke = outlineStroke,
        fillFrame = fillFrame,
        healthbarOutline = healthbarOutline,
        barBG = barBG,
        barFill = barFill,
        healthChangeTags = healthChangeTags,
        nameTag = nameTag,
        distanceTag = distanceTag,
        velocityTag = velocityTag,
        highlight = highlight,
    }
    ESP.HealthStates[player] = 1
    ESP.HealthChanges[player] = {}
end

local function RemoveESP(player)
    if ESP.PlayerHealthConnections[player] then
        if type(ESP.PlayerHealthConnections[player]) == "table" then
            pcall(function() ESP.PlayerHealthConnections[player].health:Disconnect() end)
            pcall(function() ESP.PlayerHealthConnections[player].maxHealth:Disconnect() end)
        else
            pcall(function() ESP.PlayerHealthConnections[player]:Disconnect() end)
        end
        ESP.PlayerHealthConnections[player] = nil
    end

    if ESP.GUIs[player] then
        for _, gui in pairs(ESP.GUIs[player]) do
            if type(gui) == 'table' then
                for _, tag in ipairs(gui) do
                    pcall(function() tag:Destroy() end)
                end
            else
                pcall(function() gui:Destroy() end)
            end
        end
        ESP.GUIs[player] = nil
    end
    ESP.HealthStates[player] = nil
    ESP.HealthChanges[player] = nil
end

local function CleanupAllESP()
    for player, _ in pairs(ESP.GUIs) do
        RemoveESP(player)
    end

    ESP.Connections = {}
    ESP.GUIs = {}
    ESP.HealthStates = {}
    ESP.HealthChanges = {}
    ESP.PlayerHealthConnections = {}
end

local function IsSameTeam(player)
    if not ESP.Settings.IgnoreTeam then
        return false
    end
    local localPlayer = Players.LocalPlayer
    return player.Team and localPlayer.Team and player.Team == localPlayer.Team
end

local function ShouldShowESP(player)
    if player == Players.LocalPlayer then
        return ESP.Settings.LocalDebug
    end
    return not IsSameTeam(player)
end

local function UpdateNameTag(player, nameTag)
    if not nameTag then
        return
    end
    nameTag.Text = ESP.Settings.Nametag.UseDisplayName and player.DisplayName or player.Name
end

local function UpdateHealthbar(player, barFill, height, healthPerc)
    if not ESP.HealthStates[player] then
        ESP.HealthStates[player] = healthPerc
    end

    local targetHeight = height * healthPerc

    if ESP.Settings.Healthbar.Gradient.LerpAnimation then
        ESP.HealthStates[player] = ESP.HealthStates[player] + (healthPerc - ESP.HealthStates[player]) * ESP.Settings.Healthbar.Gradient.LerpSpeed
        targetHeight = height * ESP.HealthStates[player]
    else
        ESP.HealthStates[player] = healthPerc
    end

    barFill.Size = UDim2.fromOffset(ESP.Settings.Healthbar.Width, targetHeight)
    barFill.Position = UDim2.fromOffset(0, height - targetHeight)
end

local function SetupHealthChangeTracking(player, humanoid)
    if ESP.PlayerHealthConnections[player] then
        if type(ESP.PlayerHealthConnections[player]) == "table" then
            pcall(function() ESP.PlayerHealthConnections[player].health:Disconnect() end)
            pcall(function() ESP.PlayerHealthConnections[player].maxHealth:Disconnect() end)
        else
            pcall(function() ESP.PlayerHealthConnections[player]:Disconnect() end)
        end
    end
    
    local lastHealth = humanoid.Health
    local lastMaxHealth = humanoid.MaxHealth
    
    local healthConnection = humanoid:GetPropertyChangedSignal("Health"):Connect(function()
        if not ESP.HealthChanges[player] then
            ESP.HealthChanges[player] = {}
        end
        
        local currentHealth = humanoid.Health
        local maxHealth = humanoid.MaxHealth
        local healthChange = math.floor(currentHealth - lastHealth)
        
        if math.abs(healthChange) >= 1 then
            if not ESP.HealthChanges[player] then
                ESP.HealthChanges[player] = {}
            end
            
            table.insert(ESP.HealthChanges[player], 1, {
                text = healthChange > 0 and '+' .. healthChange or tostring(healthChange),
                startTime = tick(),
                transparency = 0,
                color = healthChange > 0 and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0),
            })

            if #ESP.HealthChanges[player] > 3 then
                table.remove(ESP.HealthChanges[player], 4)
            end
        end
        
        lastHealth = currentHealth
    end)
    
    local maxHealthConnection = humanoid:GetPropertyChangedSignal("MaxHealth"):Connect(function()
        lastMaxHealth = humanoid.MaxHealth
    end)
    
    ESP.PlayerHealthConnections[player] = {
        health = healthConnection,
        maxHealth = maxHealthConnection
    }
end

local function UpdateHealthChange(player, healthChangeTags, healthbarX, healthbarY, healthbarHeight)
    if not ESP.HealthChanges[player] then
        return
    end

    local currentTime = tick()
    local activeChanges = {}

    for i = #ESP.HealthChanges[player], 1, -1 do
        local healthChange = ESP.HealthChanges[player][i]
        local elapsed = currentTime - healthChange.startTime

        if elapsed > ESP.Settings.HealthChange.Duration then
            table.remove(ESP.HealthChanges[player], i)
        else
            local progress = elapsed / ESP.Settings.HealthChange.Duration
            healthChange.transparency = progress * ESP.Settings.HealthChange.FadeSpeed
            table.insert(activeChanges, 1, healthChange)
        end
    end

    for i, tag in ipairs(healthChangeTags) do
        if i <= #activeChanges then
            local healthChange = activeChanges[i]
            local verticalOffset = (i - 1) * ESP.Settings.HealthChange.StackOffset

            tag.Text = healthChange.text
            tag.TextColor3 = healthChange.color
            tag.TextTransparency = healthChange.transparency
            tag.TextStrokeTransparency = ESP.Settings.HealthChange.ShowOutline and healthChange.transparency or 1
            tag.Visible = true

            tag.Position = UDim2.fromOffset(healthbarX - 48, healthbarY - 6 + verticalOffset)
            tag.Size = UDim2.fromOffset(45, 20)
        else
            tag.Visible = false
        end
    end
end

local function UpdateFill(player, fillFrame, tl, tr, br, bl)
    fillFrame.Visible = ESP.Settings.Box.Filled and ESP.Enabled
    fillFrame.Position = UDim2.fromOffset(tl.X, tl.Y)
    fillFrame.Size = UDim2.fromOffset(tr.X - tl.X, bl.Y - tl.Y)
    fillFrame.BackgroundTransparency = ESP.Settings.Box.FilledTransparency

    local fillColor = ESP.Settings.Box.ColorTeam and player.Team and player.TeamColor.Color or ESP.Settings.Box.Color
    fillFrame.BackgroundColor3 = fillColor
end

local function HandlePlayerAdded(player)
    RemoveESP(player)

    if not ShouldShowESP(player) then
        return
    end

    CreateESP(player)
    local guis = ESP.GUIs[player]
    if guis then
        UpdateNameTag(player, guis.nameTag)
    end

    local function characterAdded(character)
        if not ESP.Enabled then
            return
        end
        
        local humanoid
        repeat
            humanoid = character:FindFirstChildOfClass('Humanoid')
            if not humanoid then
                task.wait(0.1)
            end
        until humanoid or not character.Parent
        
        if humanoid then
            SetupHealthChangeTracking(player, humanoid)
            ESP.HealthStates[player] = humanoid.Health / humanoid.MaxHealth
        end
    end

    local function characterRemoving()
        if ESP.PlayerHealthConnections[player] then
            if type(ESP.PlayerHealthConnections[player]) == "table" then
                pcall(function() ESP.PlayerHealthConnections[player].health:Disconnect() end)
                pcall(function() ESP.PlayerHealthConnections[player].maxHealth:Disconnect() end)
            else
                pcall(function() ESP.PlayerHealthConnections[player]:Disconnect() end)
            end
            ESP.PlayerHealthConnections[player] = nil
        end
        
        local guis = ESP.GUIs[player]
        if guis then
            guis.boxFrame.Visible = false
            guis.outlineFrame.Visible = false
            guis.fillFrame.Visible = false
            guis.healthbarOutline.Visible = false
            for _, tag in ipairs(guis.healthChangeTags) do
                tag.Visible = false
            end
            guis.nameTag.Visible = false
            guis.distanceTag.Visible = false
            guis.velocityTag.Visible = false
            guis.highlight.Enabled = false
        end
    end

    local function teamChanged()
        if ShouldShowESP(player) then
            if not ESP.GUIs[player] then
                CreateESP(player)
                local guis = ESP.GUIs[player]
                if guis then
                    UpdateNameTag(player, guis.nameTag)
                end
            end
        else
            RemoveESP(player)
        end
    end

    if player.Character then
        characterAdded(player.Character)
    end

    table.insert(ESP.Connections, player.CharacterAdded:Connect(characterAdded))
    table.insert(ESP.Connections, player.CharacterRemoving:Connect(characterRemoving))
    table.insert(ESP.Connections, player:GetPropertyChangedSignal('Team'):Connect(teamChanged))
end

local function HandlePlayerRemoving(player)
    RemoveESP(player)
end

local function InitializeESP()
    if game.CoreGui:FindFirstChild('BoxESPScreenGui') then
        pcall(function() game.CoreGui.BoxESPScreenGui:Destroy() end)
    end

    ScreenGui = Instance.new('ScreenGui')
    ScreenGui.Name = 'BoxESPScreenGui'
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = game.CoreGui

    CleanupAllESP()

    local localPlayer = Players.LocalPlayer

    table.insert(ESP.Connections, localPlayer:GetPropertyChangedSignal('Team'):Connect(function()
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= localPlayer then
                HandlePlayerAdded(player)
            end
        end
    end))

    for _, player in pairs(Players:GetPlayers()) do
        HandlePlayerAdded(player)
    end

    if ESP.Settings.LocalDebug then
        HandlePlayerAdded(localPlayer)
    end

    table.insert(ESP.Connections, Players.PlayerAdded:Connect(function(player)
        HandlePlayerAdded(player)
    end))

    table.insert(ESP.Connections, Players.PlayerRemoving:Connect(function(player)
        HandlePlayerRemoving(player)
    end))
    
    table.insert(ESP.Connections, UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == ESP.Settings.Keybind then
            BoxESPLib:Toggle()
        end
    end))
    
    table.insert(ESP.Connections, RunService.RenderStepped:Connect(function()
        if not ESP.Enabled then
            for _, guis in pairs(ESP.GUIs) do
                guis.boxFrame.Visible = false
                guis.outlineFrame.Visible = false
                guis.fillFrame.Visible = false
                guis.healthbarOutline.Visible = false
                for _, tag in ipairs(guis.healthChangeTags) do
                    tag.Visible = false
                end
                guis.nameTag.Visible = false
                guis.distanceTag.Visible = false
                guis.velocityTag.Visible = false
                guis.highlight.Enabled = false
            end
            return
        end

        for player, guis in pairs(ESP.GUIs) do
            if not ShouldShowESP(player) then
                guis.boxFrame.Visible = false
                guis.outlineFrame.Visible = false
                guis.fillFrame.Visible = false
                guis.healthbarOutline.Visible = false
                for _, tag in ipairs(guis.healthChangeTags) do
                    tag.Visible = false
                end
                guis.nameTag.Visible = false
                guis.distanceTag.Visible = false
                guis.velocityTag.Visible = false
                guis.highlight.Enabled = false
                continue
            end

            if not player.Character then
                guis.boxFrame.Visible = false
                guis.outlineFrame.Visible = false
                guis.fillFrame.Visible = false
                guis.healthbarOutline.Visible = false
                for _, tag in ipairs(guis.healthChangeTags) do
                    tag.Visible = false
                end
                guis.nameTag.Visible = false
                guis.distanceTag.Visible = false
                guis.velocityTag.Visible = false
                guis.highlight.Enabled = false
                continue
            end

            local hrp = player.Character:FindFirstChild('HumanoidRootPart')
            if not hrp then
                guis.boxFrame.Visible = false
                guis.outlineFrame.Visible = false
                guis.fillFrame.Visible = false
                guis.healthbarOutline.Visible = false
                for _, tag in ipairs(guis.healthChangeTags) do
                    tag.Visible = false
                end
                guis.nameTag.Visible = false
                guis.distanceTag.Visible = false
                guis.velocityTag.Visible = false
                guis.highlight.Enabled = false
                continue
            end

            local screenPos = Camera:WorldToViewportPoint(hrp.Position)
            if screenPos.Z <= 0 then
                guis.boxFrame.Visible = false
                guis.outlineFrame.Visible = false
                guis.fillFrame.Visible = false
                guis.healthbarOutline.Visible = false
                for _, tag in ipairs(guis.healthChangeTags) do
                    tag.Visible = false
                end
                guis.nameTag.Visible = false
                guis.distanceTag.Visible = false
                guis.velocityTag.Visible = false
                guis.highlight.Enabled = false
                continue
            end

            local tl, tr, br, bl, width, height = GetBoxCorners(player.Character)
            if tl then
                local boxColor = ESP.Settings.Box.ColorTeam and player.Team and player.TeamColor.Color or ESP.Settings.Box.Color
                
                guis.boxFrame.Position = UDim2.fromOffset(tl.X, tl.Y)
                guis.boxFrame.Size = UDim2.fromOffset(width, height)
                guis.boxStroke.Color = boxColor
                guis.boxStroke.Thickness = ESP.Settings.Box.Thickness
                guis.boxStroke.Transparency = ESP.Settings.Box.Transparency
                guis.boxFrame.Visible = ESP.Settings.Box.Enabled
                
                local outlineOffset = ESP.Settings.Outline.Thickness
                guis.outlineFrame.Position = UDim2.fromOffset(tl.X - outlineOffset, tl.Y - outlineOffset)
                guis.outlineFrame.Size = UDim2.fromOffset(width + (outlineOffset * 2), height + (outlineOffset * 2))
                guis.outlineStroke.Color = ESP.Settings.Outline.Color
                guis.outlineStroke.Thickness = ESP.Settings.Outline.Thickness
                guis.outlineStroke.Transparency = ESP.Settings.Outline.Transparency
                guis.outlineFrame.Visible = ESP.Settings.Outline.Enabled
                
                UpdateFill(player, guis.fillFrame, tl, tr, br, bl)

                local hum = player.Character:FindFirstChildOfClass('Humanoid')
                local healthPerc = hum and math.clamp(hum.Health / hum.MaxHealth, 0, 1) or 0

                local healthbarX = tl.X - ESP.Settings.Healthbar.Width - 4
                guis.healthbarOutline.Visible = ESP.Settings.Healthbar.Enabled
                guis.healthbarOutline.Position = UDim2.fromOffset(healthbarX, tl.Y - 1)
                guis.healthbarOutline.Size = UDim2.fromOffset(ESP.Settings.Healthbar.Width + 2, height + 2)

                guis.barBG.Size = UDim2.fromOffset(ESP.Settings.Healthbar.Width, height)

                UpdateHealthbar(player, guis.barFill, height, healthPerc)

                if ESP.Settings.HealthChange.Enabled then
                    UpdateHealthChange(player, guis.healthChangeTags, healthbarX, tl.Y, height)
                end

                guis.nameTag.Visible = ESP.Settings.Nametag.Enabled
                UpdateNameTag(player, guis.nameTag)
                guis.nameTag.Position = UDim2.fromOffset((tl.X + tr.X) / 2 - 30, tl.Y + ESP.Settings.Nametag.Offset.Y)
                guis.nameTag.Size = UDim2.fromOffset(60, 14)

                guis.distanceTag.Visible = ESP.Settings.Distance.Enabled
                local distance = math.floor((Players.LocalPlayer.Character.HumanoidRootPart.Position - hrp.Position).Magnitude)
                guis.distanceTag.Text = '[' .. distance .. 'm]'
                guis.distanceTag.Position = UDim2.fromOffset((bl.X + br.X) / 2 - 30, bl.Y + ESP.Settings.Distance.Offset.Y)
                guis.distanceTag.Size = UDim2.fromOffset(60, 14)

                guis.velocityTag.Visible = ESP.Settings.Velocity.Enabled
                if ESP.Settings.Velocity.Enabled then
                    local velocity = math.floor(hrp.Velocity.Magnitude)
                    guis.velocityTag.Text = 'V:' .. velocity
                    guis.velocityTag.Position = UDim2.fromOffset(tr.X + 5, tr.Y - 3)
                    guis.velocityTag.Size = UDim2.fromOffset(35, 14)
                end

                guis.highlight.Enabled = ESP.Settings.Highlight.Enabled
                guis.highlight.Adornee = player.Character
                guis.highlight.FillColor = ESP.Settings.Highlight.Color
                guis.highlight.FillTransparency = ESP.Settings.Highlight.Transparency
                guis.highlight.OutlineColor = ESP.Settings.Highlight.OutlineColor
                guis.highlight.OutlineTransparency = ESP.Settings.Highlight.OutlineTransparency
            else
                guis.boxFrame.Visible = false
                guis.outlineFrame.Visible = false
                guis.fillFrame.Visible = false
                guis.healthbarOutline.Visible = false
                for _, tag in ipairs(guis.healthChangeTags) do
                    tag.Visible = false
                end
                guis.nameTag.Visible = false
                guis.distanceTag.Visible = false
                guis.velocityTag.Visible = false
                guis.highlight.Enabled = false
            end
        end
    end))
end

function BoxESPLib:Toggle()
    ESP.Enabled = not ESP.Enabled

    for _, guis in pairs(ESP.GUIs) do
        guis.boxFrame.Visible = ESP.Enabled and ESP.Settings.Box.Enabled
        guis.outlineFrame.Visible = ESP.Enabled and ESP.Settings.Outline.Enabled
        guis.fillFrame.Visible = ESP.Enabled and ESP.Settings.Box.Filled
        guis.healthbarOutline.Visible = ESP.Enabled and ESP.Settings.Healthbar.Enabled
        guis.nameTag.Visible = ESP.Enabled and ESP.Settings.Nametag.Enabled
        guis.distanceTag.Visible = ESP.Enabled and ESP.Settings.Distance.Enabled
        guis.velocityTag.Visible = ESP.Enabled and ESP.Settings.Velocity.Enabled
        guis.highlight.Enabled = ESP.Enabled and ESP.Settings.Highlight.Enabled
        
        for _, tag in ipairs(guis.healthChangeTags) do
            tag.Visible = ESP.Enabled and ESP.Settings.HealthChange.Enabled
        end
    end
    
    return ESP.Enabled
end

function BoxESPLib:SetEnabled(state)
    if ESP.Enabled ~= state then
        return self:Toggle()
    end
    return ESP.Enabled
end

function BoxESPLib:GetEnabled()
    return ESP.Enabled
end

function BoxESPLib:SetKeybind(keycode)
    ESP.Settings.Keybind = keycode
    return true
end

function BoxESPLib:GetKeybind()
    return ESP.Settings.Keybind
end

function BoxESPLib:SetSetting(category, setting, value)
    if ESP.Settings[category] and ESP.Settings[category][setting] ~= nil then
        ESP.Settings[category][setting] = value
        return true
    end
    return false
end

function BoxESPLib:GetSetting(category, setting)
    if ESP.Settings[category] then
        return ESP.Settings[category][setting]
    end
    return nil
end

function BoxESPLib:GetAllSettings()
    return ESP.Settings
end

function BoxESPLib:Destroy()
    CleanupAllESP()
    
    if ScreenGui then
        pcall(function() ScreenGui:Destroy() end)
    end
    
    for _, c in ipairs(ESP.Connections) do
        pcall(function() c:Disconnect() end)
    end
    
    getgenv()._BoxESP = nil
    BoxESPLib = nil
    
    return true
end

function BoxESPLib:CreateUI(Tab)
    
    local espEnabled = Tab:Toggle("Enable ESP", ESP.Enabled, function(state)
        self:SetEnabled(state)
    end)
    Tab:Spliter()
    local boxEnabled = Tab:Toggle("Box ESP", ESP.Settings.Box.Enabled, function(state)
        self:SetSetting("Box", "Enabled", state)
    end)
    
    local boxColor = Tab:Colorpicker("Box Color", ESP.Settings.Box.Color, function(color)
        self:SetSetting("Box", "Color", color)
    end)
    
    --[[local boxTeamColor = Tab:Toggle("Team Color", ESP.Settings.Box.ColorTeam, function(state)
        self:SetSetting("Box", "ColorTeam", state)
    end)]]
    Tab:Spliter()
    local boxFill = Tab:Toggle("Box Fill", ESP.Settings.Box.Filled, function(state)
        self:SetSetting("Box", "Filled", state)
    end)
    
    local outlineEnabled = Tab:Toggle("Outline", ESP.Settings.Outline.Enabled, function(state)
        self:SetSetting("Outline", "Enabled", state)
    end)
    
    local outlineColor = Tab:Colorpicker("Outline Color", ESP.Settings.Outline.Color, function(color)
        self:SetSetting("Outline", "Color", color)
    end)
    Tab:Spliter()
    local healthbarEnabled = Tab:Toggle("Health Bar", ESP.Settings.Healthbar.Enabled, function(state)
        self:SetSetting("Healthbar", "Enabled", state)
    end)
    
    local gradientColors = ESP.Settings.Healthbar.Gradient.Colors
    local color1 = gradientColors.Keypoints[1].Value
    local color2 = gradientColors.Keypoints[2].Value
    
    local healthbarColor = Tab:Colorpicker("Health Bar Gradient", 2, {
        color1,
        color2
    }, function(colors)
        ESP.Settings.Healthbar.Gradient.Colors = ColorSequence.new({
            ColorSequenceKeypoint.new(0, colors[1]),
            ColorSequenceKeypoint.new(1, colors[2]),
        })
        
        for _, guis in pairs(ESP.GUIs) do
            if guis.barFill and guis.barFill:FindFirstChild("UIGradient") then
                guis.barFill.UIGradient.Color = ESP.Settings.Healthbar.Gradient.Colors
            end
        end
    end)

    local healthChangeEnabled = Tab:Toggle("Health Changes", ESP.Settings.HealthChange.Enabled, function(state)
        self:SetSetting("HealthChange", "Enabled", state)
    end)
    Tab:Spliter()
    local nametagEnabled = Tab:Toggle("Nametags", ESP.Settings.Nametag.Enabled, function(state)
        self:SetSetting("Nametag", "Enabled", state)
    end)
    
    local useDisplayName = Tab:Toggle("Use Display Name", ESP.Settings.Nametag.UseDisplayName, function(state)
        self:SetSetting("Nametag", "UseDisplayName", state)
    end)
    Tab:Spliter()
    local distanceEnabled = Tab:Toggle("Distance", ESP.Settings.Distance.Enabled, function(state)
        self:SetSetting("Distance", "Enabled", state)
    end)
    
    local velocityEnabled = Tab:Toggle("Velocity Indicator", ESP.Settings.Velocity.Enabled, function(state)
        self:SetSetting("Velocity", "Enabled", state)
    end)
    Tab:Spliter()
    local highlightEnabled = Tab:Toggle("Highlight", ESP.Settings.Highlight.Enabled, function(state)
        self:SetSetting("Highlight", "Enabled", state)
    end)
    
    --[[local ignoreTeam = Tab:Toggle("Ignore Team", ESP.Settings.IgnoreTeam, function(state)
        self:SetSetting("IgnoreTeam", state)
    end)
    
    local keybindText = Tab:Label("Current Keybind: " .. tostring(ESP.Settings.Keybind))
    
    Tab:Button("Change Keybind", function()
        local listening = true
        keybindText:SetText("Press any key...")
        
        local connection
        connection = UserInputService.InputBegan:Connect(function(input)
            if listening then
                if input.KeyCode ~= Enum.KeyCode.Unknown then
                    self:SetKeybind(input.KeyCode)
                    keybindText:SetText("Current Keybind: " .. tostring(input.KeyCode))
                    listening = false
                    connection:Disconnect()
                end
            end
        end)
        
        task.delay(5, function()
            if listening then
                listening = false
                connection:Disconnect()
                keybindText:SetText("Current Keybind: " .. tostring(ESP.Settings.Keybind))
            end
        end)
    end)
    
    Tab:Button("Reset to Defaults", function()
        local defaultSettings = {
            Keybind = Enum.KeyCode.End,
            LocalDebug = false,
            IgnoreTeam = false,
            SimpleBoxMode = true,

            Box = {
                Enabled = true,
                Color = Color3.fromRGB(255, 255, 255),
                Thickness = 1.5,
                Transparency = 0,
                Filled = false,
                FilledTransparency = 0.75,
                MaxSize = 300,
                ColorTeam = true,
                Scale = 1.5,
            },

            Outline = {
                Enabled = true,
                Color = Color3.fromRGB(0, 0, 0),
                Thickness = 1,
                Transparency = 0,
            },

            Healthbar = {
                Enabled = true,
                Width = 3,
                Background = Color3.fromRGB(40, 40, 40),
                BackgroundTransparency = 0,
                OutlineColor = Color3.fromRGB(0, 0, 0),
                OutlineTransparency = 0,
            },

            HealthChange = {
                Enabled = true,
                Font = Enum.Font.DenkOne,
                Size = 11,
                Color = Color3.fromRGB(255, 255, 255),
                Transparency = 0,
                ShowOutline = true,
                OutlineColor = Color3.fromRGB(0, 0, 0),
                Duration = 2.3,
                FadeSpeed = 1,
                StackOffset = 11,
            },

            Nametag = {
                Enabled = true,
                Font = Enum.Font.SourceSansBold,
                Size = 13,
                Color = Color3.fromRGB(255, 255, 255),
                Transparency = 0,
                UseDisplayName = false,
                Offset = Vector2.new(0, -15),
                ShowOutline = true,
                OutlineColor = Color3.fromRGB(0, 0, 0),
            },

            Distance = {
                Enabled = true,
                Font = Enum.Font.SourceSansBold,
                Size = 13,
                Color = Color3.fromRGB(255, 255, 255),
                Transparency = 0,
                Offset = Vector2.new(0, 0),
                ShowOutline = true,
                OutlineColor = Color3.fromRGB(0, 0, 0),
            },

            Velocity = {
                Enabled = true,
                Font = Enum.Font.SourceSansBold,
                Size = 13,
                Color = Color3.fromRGB(255, 255, 255),
                Transparency = 0,
                ShowOutline = true,
                OutlineColor = Color3.fromRGB(0, 0, 0),
            },

            Highlight = {
                Enabled = true,
                Color = Color3.fromRGB(255, 255, 255),
                Transparency = 0.5,
                OutlineColor = Color3.fromRGB(255, 255, 255),
                OutlineTransparency = 0.08,
            }
        }
        
        for category, settings in pairs(defaultSettings) do
            if type(settings) == "table" then
                for setting, value in pairs(settings) do
                    self:SetSetting(category, setting, value)
                end
            else
                ESP.Settings[category] = settings
            end
        end
        
        espEnabled:SetValue(true)
        boxEnabled:SetValue(true)
        boxColor:SetColor(Color3.fromRGB(255, 255, 255))
        boxTeamColor:SetValue(true)
        boxThickness:SetValue(15)
        boxFill:SetValue(false)
        outlineEnabled:SetValue(true)
        outlineColor:SetColor(Color3.fromRGB(0, 0, 0))
        healthbarEnabled:SetValue(true)
        healthChangeEnabled:SetValue(true)
        nametagEnabled:SetValue(true)
        useDisplayName:SetValue(false)
        distanceEnabled:SetValue(true)
        velocityEnabled:SetValue(true)
        highlightEnabled:SetValue(true)
        ignoreTeam:SetValue(false)
        keybindText:SetText("Current Keybind: End")
    end)]]
    
    return {
        Toggles = {
            espEnabled = espEnabled,
            boxEnabled = boxEnabled,
            boxTeamColor = boxTeamColor,
            boxFill = boxFill,
            outlineEnabled = outlineEnabled,
            healthbarEnabled = healthbarEnabled,
            healthChangeEnabled = healthChangeEnabled,
            nametagEnabled = nametagEnabled,
            useDisplayName = useDisplayName,
            distanceEnabled = distanceEnabled,
            velocityEnabled = velocityEnabled,
            highlightEnabled = highlightEnabled,
            ignoreTeam = ignoreTeam,
        },
        Colorpickers = {
            boxColor = boxColor,
            outlineColor = outlineColor,
        },
        Sliders = {
            boxThickness = boxThickness,
        },
        Labels = {
            keybindText = keybindText,
        }
    }
end

InitializeESP()

return BoxESPLib
