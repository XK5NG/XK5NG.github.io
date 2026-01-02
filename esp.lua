--thx k0nkx
local BoxESPLib = {}

if not getgenv().ESPConnection then
    getgenv().ESPConnection = {
        Connections = {},
        GUIs = {},
        HealthStates = {},
        HealthChanges = {},
        LastHealthCheck = {},
        ScreenGui = nil
    }
end

BoxESPLib.Settings = {
    LocalDebug = false,
    IgnoreTeam = false,
    Box = {
        Enabled = false,
        Color = Color3.fromRGB(255, 255, 255),
        Thickness = 1.5,
        Transparency = 0,
        Filled = false,
        FilledTransparency = 0.25,
        MaxSize = 300,
        ColorTeam = true,
    },
    Outline = {
        Enabled = false,
        Color = Color3.fromRGB(0, 0, 0),
        Thickness = 3,
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
        CheckInterval = 0.18,
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
        Transparency = 1,
        OutlineColor = Color3.fromRGB(255, 255, 255),
        OutlineTransparency = 0.92,
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
            'HumanoidRootPart',
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

BoxESPLib.Enabled = false

local function CleanupExistingESP()
    for i, connection in ipairs(getgenv().ESPConnection.Connections or {}) do
        if connection and typeof(connection) == "RBXScriptConnection" then
            pcall(function() connection:Disconnect() end)
        end
    end
    
    getgenv().ESPConnection.Connections = {}
    
    for player, guis in pairs(getgenv().ESPConnection.GUIs or {}) do
        if guis then
            for _, element in pairs(guis) do
                if element then
                    if typeof(element) == "Instance" then
                        pcall(element.Destroy, element)
                    elseif type(element) == "table" then
                        for _, item in ipairs(element) do
                            if item and typeof(item) == "Instance" then
                                pcall(item.Destroy, item)
                            end
                        end
                    end
                end
            end
        end
    end
    
    getgenv().ESPConnection.GUIs = {}
    getgenv().ESPConnection.HealthStates = {}
    getgenv().ESPConnection.HealthChanges = {}
    getgenv().ESPConnection.LastHealthCheck = {}
    
    if getgenv().ESPConnection.ScreenGui then
        pcall(getgenv().ESPConnection.ScreenGui.Destroy, getgenv().ESPConnection.ScreenGui)
        getgenv().ESPConnection.ScreenGui = nil
    end
end

CleanupExistingESP()

BoxESPLib.Connections = getgenv().ESPConnection.Connections
BoxESPLib.GUIs = getgenv().ESPConnection.GUIs
BoxESPLib.HealthStates = getgenv().ESPConnection.HealthStates
BoxESPLib.HealthChanges = getgenv().ESPConnection.HealthChanges
BoxESPLib.LastHealthCheck = getgenv().ESPConnection.LastHealthCheck
BoxESPLib.ScreenGui = getgenv().ESPConnection.ScreenGui

function BoxESPLib:GetSettings()
    return self.Settings
end

function BoxESPLib:SetSettings(newSettings)
    for category, settings in pairs(newSettings) do
        if self.Settings[category] then
            for key, value in pairs(settings) do
                if self.Settings[category][key] ~= nil then
                    self.Settings[category][key] = value
                end
            end
        end
    end
end

function BoxESPLib:Toggle()
    self.Enabled = not self.Enabled
    self:UpdateAllVisibility()
end

function BoxESPLib:Enable()
    self.Enabled = true
    self:UpdateAllVisibility()
end

function BoxESPLib:Disable()
    self.Enabled = false
    self:UpdateAllVisibility()
end

function BoxESPLib:IsEnabled()
    return self.Enabled
end

function BoxESPLib:Destroy()
    CleanupExistingESP()
    self.Connections = getgenv().ESPConnection.Connections
    self.GUIs = getgenv().ESPConnection.GUIs
    self.HealthStates = getgenv().ESPConnection.HealthStates
    self.HealthChanges = getgenv().ESPConnection.HealthChanges
    self.LastHealthCheck = getgenv().ESPConnection.LastHealthCheck
    self.ScreenGui = getgenv().ESPConnection.ScreenGui
end

function BoxESPLib:Get3DBounds(char)
    if not char or not char:IsA("Model") then return end
    
    local parts = {}
    for _, name in ipairs(self.Settings.Character.R6Parts) do
        local p = char:FindFirstChild(name)
        if p and p:IsA('BasePart') then
            table.insert(parts, p)
        end
    end
    for _, name in ipairs(self.Settings.Character.R15Parts) do
        local p = char:FindFirstChild(name)
        if p and p:IsA('BasePart') then
            table.insert(parts, p)
        end
    end
    if #parts == 0 then
        return
    end

    local min, max =
        Vector3.new(math.huge, math.huge, math.huge),
        Vector3.new(-math.huge, -math.huge, -math.huge)

    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA('BasePart') and not part.Parent:IsA('Accessory') then
            local include = false
            for _, mp in ipairs(parts) do
                if
                    (part.Position - mp.Position).Magnitude
                    <= self.Settings.Character.MaxPartDistance
                then
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
                min = Vector3.new(
                    math.min(min.X, c.X),
                    math.min(min.Y, c.Y),
                    math.min(min.Z, c.Z)
                )
                max = Vector3.new(
                    math.max(max.X, c.X),
                    math.max(max.Y, c.Y),
                    math.max(max.Z, c.Z)
                )
            end
        end
    end
    return min, max
end

function BoxESPLib:GetBoxCorners(char)
    local min3D, max3D = self:Get3DBounds(char)
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
        local screen = workspace.CurrentCamera:WorldToViewportPoint(p)
        if screen.Z > 0 then
            minX, maxX = math.min(minX, screen.X), math.max(maxX, screen.X)
            minY, maxY = math.min(minY, screen.Y), math.max(maxY, screen.Y)
        end
    end
    if minX == math.huge then
        return
    end

    local w, h =
        math.min(maxX - minX, self.Settings.Box.MaxSize),
        math.min(maxY - minY, self.Settings.Box.MaxSize)
    local cx, cy = (minX + maxX) / 2, (minY + maxY) / 2
    local hw, hh = w / 2, h / 2

    return Vector2.new(cx - hw, cy - hh),
        Vector2.new(cx + hw, cy - hh),
        Vector2.new(cx + hw, cy + hh),
        Vector2.new(cx - hw, cy + hh),
        w,
        h
end

function BoxESPLib:CreateFrameBox(parent, props)
    local frame = Instance.new('Frame')
    frame.BackgroundTransparency = 1
    frame.BorderSizePixel = 0
    frame.ClipsDescendants = false
    frame.Parent = parent
    
    local uiStroke = Instance.new('UIStroke')
    uiStroke.Thickness = props.Thickness or 1
    uiStroke.Color = props.Color or Color3.fromRGB(255, 255, 255)
    uiStroke.Transparency = props.Transparency or 0
    uiStroke.LineJoinMode = Enum.LineJoinMode.Miter
    uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    uiStroke.Parent = frame
    
    return frame
end

function BoxESPLib:CreateESP(player)
    if self.GUIs[player] then return end

    if not self.ScreenGui then return end

    local boxFrame = self:CreateFrameBox(self.ScreenGui, {
        Thickness = self.Settings.Box.Thickness,
        Color = self.Settings.Box.Color,
        Transparency = self.Settings.Box.Transparency,
    })

    local outlineFrame = self:CreateFrameBox(self.ScreenGui, {
        Thickness = self.Settings.Outline.Thickness,
        Color = self.Settings.Outline.Color,
        Transparency = self.Settings.Outline.Transparency,
    })

    local fillFrame = Instance.new('Frame', self.ScreenGui)
    fillFrame.BackgroundColor3 = self.Settings.Box.Color
    fillFrame.BackgroundTransparency = self.Settings.Box.FilledTransparency
    fillFrame.BorderSizePixel = 0
    fillFrame.Visible = self.Settings.Box.Filled

    local healthbarOutline = Instance.new('Frame', self.ScreenGui)
    healthbarOutline.BackgroundColor3 = self.Settings.Healthbar.OutlineColor
    healthbarOutline.BackgroundTransparency = self.Settings.Healthbar.OutlineTransparency
    healthbarOutline.BorderSizePixel = 0

    local barBG = Instance.new('Frame', healthbarOutline)
    barBG.BackgroundColor3 = self.Settings.Healthbar.Background
    barBG.BackgroundTransparency = self.Settings.Healthbar.BackgroundTransparency
    barBG.BorderSizePixel = 0
    barBG.Position = UDim2.fromOffset(1, 1)

    local barFill = Instance.new('Frame', barBG)
    barFill.BorderSizePixel = 0
    local gradient = Instance.new('UIGradient', barFill)
    gradient.Color = self.Settings.Healthbar.Gradient.Colors
    gradient.Rotation = 90

    local healthChangeTags = {}
    for i = 1, 3 do
        local healthChangeTag = Instance.new('TextLabel', self.ScreenGui)
        healthChangeTag.Font = self.Settings.HealthChange.Font
        healthChangeTag.TextSize = self.Settings.HealthChange.Size
        healthChangeTag.TextColor3 = self.Settings.HealthChange.Color
        healthChangeTag.TextTransparency = 1
        healthChangeTag.TextStrokeTransparency = 1
        healthChangeTag.TextStrokeColor3 = self.Settings.HealthChange.OutlineColor
        healthChangeTag.TextXAlignment = Enum.TextXAlignment.Right
        healthChangeTag.BackgroundTransparency = 1
        healthChangeTag.Visible = false
        table.insert(healthChangeTags, healthChangeTag)
    end

    local nameTag = Instance.new('TextLabel', self.ScreenGui)
    nameTag.Font = self.Settings.Nametag.Font
    nameTag.TextSize = self.Settings.Nametag.Size
    nameTag.TextColor3 = self.Settings.Nametag.Color
    nameTag.TextTransparency = self.Settings.Nametag.Transparency
    nameTag.TextStrokeTransparency = self.Settings.Nametag.ShowOutline and 0 or 1
    nameTag.TextStrokeColor3 = self.Settings.Nametag.OutlineColor
    nameTag.TextXAlignment = Enum.TextXAlignment.Center
    nameTag.BackgroundTransparency = 1

    local distanceTag = Instance.new('TextLabel', self.ScreenGui)
    distanceTag.Font = self.Settings.Distance.Font
    distanceTag.TextSize = self.Settings.Distance.Size
    distanceTag.TextColor3 = self.Settings.Distance.Color
    distanceTag.TextTransparency = self.Settings.Distance.Transparency
    distanceTag.TextStrokeTransparency = self.Settings.Distance.ShowOutline and 0 or 1
    distanceTag.TextStrokeColor3 = self.Settings.Distance.OutlineColor
    distanceTag.TextXAlignment = Enum.TextXAlignment.Center
    distanceTag.BackgroundTransparency = 1

    local velocityTag = Instance.new('TextLabel', self.ScreenGui)
    velocityTag.Font = self.Settings.Velocity.Font
    velocityTag.TextSize = self.Settings.Velocity.Size
    velocityTag.TextColor3 = self.Settings.Velocity.Color
    velocityTag.TextTransparency = self.Settings.Velocity.Transparency
    velocityTag.TextStrokeTransparency = self.Settings.Velocity.ShowOutline and 0 or 1
    velocityTag.TextStrokeColor3 = self.Settings.Velocity.OutlineColor
    velocityTag.TextXAlignment = Enum.TextXAlignment.Left
    velocityTag.BackgroundTransparency = 1

    local highlight = Instance.new('Highlight')
    highlight.FillColor = self.Settings.Highlight.Color
    highlight.FillTransparency = self.Settings.Highlight.Transparency
    highlight.OutlineColor = self.Settings.Highlight.OutlineColor
    highlight.OutlineTransparency = self.Settings.Highlight.OutlineTransparency
    highlight.Enabled = false
    highlight.Adornee = nil
    highlight.Parent = self.ScreenGui

    self.GUIs[player] = {
        boxFrame = boxFrame,
        outlineFrame = outlineFrame,
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
    self.HealthStates[player] = 1
    self.HealthChanges[player] = {}
    self.LastHealthCheck[player] = {
        health = 1,
        time = tick(),
    }
end

function BoxESPLib:RemoveESP(player)
    if self.GUIs[player] then
        for _, v in pairs(self.GUIs[player]) do
            if type(v) == 'table' then
                for _, obj in ipairs(v) do
                    pcall(obj.Destroy, obj)
                end
            else
                pcall(v.Destroy, v)
            end
        end
        self.GUIs[player] = nil
    end
    self.HealthStates[player] = nil
    self.HealthChanges[player] = nil
    self.LastHealthCheck[player] = nil
end

function BoxESPLib:CleanupAllESP()
    for player, _ in pairs(self.GUIs) do
        self:RemoveESP(player)
    end
    self.GUIs = {}
    self.HealthStates = {}
    self.HealthChanges = {}
    self.LastHealthCheck = {}
end

function BoxESPLib:UpdateAllVisibility()
    for player, guis in pairs(self.GUIs) do
        local shouldShow = self:ShouldShowESP(player) and self.Enabled
        
        pcall(function()
            guis.boxFrame.Visible = shouldShow and self.Settings.Box.Enabled
            guis.outlineFrame.Visible = shouldShow and self.Settings.Outline.Enabled
            guis.fillFrame.Visible = shouldShow and self.Settings.Box.Filled
            guis.healthbarOutline.Visible = shouldShow and self.Settings.Healthbar.Enabled
            
            for _, tag in ipairs(guis.healthChangeTags) do
                tag.Visible = shouldShow and self.Settings.HealthChange.Enabled
            end
            
            guis.nameTag.Visible = shouldShow and self.Settings.Nametag.Enabled
            guis.distanceTag.Visible = shouldShow and self.Settings.Distance.Enabled
            guis.velocityTag.Visible = shouldShow and self.Settings.Velocity.Enabled
            guis.highlight.Enabled = shouldShow and self.Settings.Highlight.Enabled
        end)
    end
end

function BoxESPLib:UpdateBoxFrames(player, tl, tr, br, bl, width, height)
    local guis = self.GUIs[player]
    if not guis then return end

    local boxFrame = guis.boxFrame
    local outlineFrame = guis.outlineFrame
    local fillFrame = guis.fillFrame
    
    pcall(function()
        boxFrame.Position = UDim2.fromOffset(tl.X, tl.Y)
        boxFrame.Size = UDim2.fromOffset(width, height)
        
        outlineFrame.Position = UDim2.fromOffset(tl.X, tl.Y)
        outlineFrame.Size = UDim2.fromOffset(width, height)
        
        fillFrame.Position = UDim2.fromOffset(tl.X, tl.Y)
        fillFrame.Size = UDim2.fromOffset(width, height)
        
        local boxColor = self.Settings.Box.ColorTeam and player.Team and player.TeamColor.Color or self.Settings.Box.Color
        
        if boxFrame.UIStroke then
            boxFrame.UIStroke.Color = boxColor
            boxFrame.UIStroke.Transparency = self.Settings.Box.Transparency
        end
        
        fillFrame.BackgroundColor3 = boxColor
        
        if self.Settings.Outline.Enabled then
            outlineFrame.Visible = true
            if outlineFrame.UIStroke then
                outlineFrame.UIStroke.Color = self.Settings.Outline.Color
                outlineFrame.UIStroke.Thickness = self.Settings.Outline.Thickness
                outlineFrame.UIStroke.Transparency = self.Settings.Outline.Transparency
            end
            
            local outlineOffset = self.Settings.Outline.Thickness
            outlineFrame.Position = UDim2.fromOffset(tl.X - outlineOffset/2, tl.Y - outlineOffset/2)
            outlineFrame.Size = UDim2.fromOffset(width + outlineOffset, height + outlineOffset)
            
            boxFrame.ZIndex = 2
            outlineFrame.ZIndex = 1
        else
            outlineFrame.Visible = false
        end
        
        fillFrame.Visible = self.Settings.Box.Filled
        fillFrame.BackgroundTransparency = self.Settings.Box.FilledTransparency
    end)
end

function BoxESPLib:UpdateNameTag(player, nameTag)
    if not nameTag then return end
    pcall(function()
        nameTag.Text = self.Settings.Nametag.UseDisplayName and player.DisplayName or player.Name
    end)
end

function BoxESPLib:UpdateHealthbar(player, barFill, height, healthPerc)
    if not self.HealthStates[player] then
        self.HealthStates[player] = healthPerc
    end

    local targetHeight = height * healthPerc

    if self.Settings.Healthbar.Gradient.LerpAnimation then
        self.HealthStates[player] = self.HealthStates[player]
            + (healthPerc - self.HealthStates[player]) * self.Settings.Healthbar.Gradient.LerpSpeed
        targetHeight = height * self.HealthStates[player]
    else
        self.HealthStates[player] = healthPerc
    end

    pcall(function()
        barFill.Size = UDim2.fromOffset(self.Settings.Healthbar.Width, targetHeight)
        barFill.Position = UDim2.fromOffset(0, height - targetHeight)
    end)

    local currentTime = tick()
    local lastCheck = self.LastHealthCheck[player]

    if lastCheck and (currentTime - lastCheck.time) >= self.Settings.HealthChange.CheckInterval then
        local healthChange = math.floor((healthPerc - lastCheck.health) * 100)

        if math.abs(healthChange) >= 1 then
            self:ShowHealthChange(player, healthChange)
        end

        self.LastHealthCheck[player] = {
            health = healthPerc,
            time = currentTime,
        }
    end
end

function BoxESPLib:ShowHealthChange(player, change)
    if not self.HealthChanges[player] then
        self.HealthChanges[player] = {}
    end

    table.insert(self.HealthChanges[player], 1, {
        text = change > 0 and '+' .. change or tostring(change),
        startTime = tick(),
        transparency = 0,
        color = change > 0 and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0),
    })

    if #self.HealthChanges[player] > 3 then
        table.remove(self.HealthChanges[player], 4)
    end
end

function BoxESPLib:UpdateHealthChange(player, healthChangeTags, healthbarX, healthbarY, healthbarHeight)
    if not self.HealthChanges[player] then return end

    local currentTime = tick()
    local activeChanges = {}

    for i = #self.HealthChanges[player], 1, -1 do
        local healthChange = self.HealthChanges[player][i]
        local elapsed = currentTime - healthChange.startTime

        if elapsed > self.Settings.HealthChange.Duration then
            table.remove(self.HealthChanges[player], i)
        else
            local progress = elapsed / self.Settings.HealthChange.Duration
            healthChange.transparency = progress * self.Settings.HealthChange.FadeSpeed
            table.insert(activeChanges, 1, healthChange)
        end
    end

    for i, tag in ipairs(healthChangeTags) do
        pcall(function()
            if i <= #activeChanges then
                local healthChange = activeChanges[i]
                local verticalOffset = (i - 1) * self.Settings.HealthChange.StackOffset

                tag.Text = healthChange.text
                tag.TextColor3 = healthChange.color
                tag.TextTransparency = healthChange.transparency
                tag.TextStrokeTransparency = self.Settings.HealthChange.ShowOutline and healthChange.transparency or 1
                tag.Visible = true

                tag.Position = UDim2.fromOffset(healthbarX - 48, healthbarY - 6 + verticalOffset)
                tag.Size = UDim2.fromOffset(45, 20)
            else
                tag.Visible = false
            end
        end)
    end
end

function BoxESPLib:IsSameTeam(player)
    if not self.Settings.IgnoreTeam then return false end
    local localPlayer = game:GetService('Players').LocalPlayer
    return player.Team and localPlayer.Team and player.Team == localPlayer.Team
end

function BoxESPLib:ShouldShowESP(player)
    if player == game:GetService('Players').LocalPlayer then
        return self.Settings.LocalDebug
    end
    return not self:IsSameTeam(player)
end

function BoxESPLib:HandlePlayerAdded(player)
    self:RemoveESP(player)

    if not self:ShouldShowESP(player) then return end

    self:CreateESP(player)
    local guis = self.GUIs[player]
    if guis then
        self:UpdateNameTag(player, guis.nameTag)
    end

    local function characterAdded(character)
        if not self.Enabled then return end
        local hum = character:FindFirstChildOfClass('Humanoid')
        if hum then
            self.LastHealthCheck[player] = {
                health = hum.Health / hum.MaxHealth,
                time = tick(),
            }
        end
    end

    local function characterRemoving()
        local guis = self.GUIs[player]
        if guis then
            pcall(function()
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
                guis.highlight.Adornee = nil
            end)
        end
    end

    local function teamChanged()
        if self:ShouldShowESP(player) then
            if not self.GUIs[player] then
                self:CreateESP(player)
                local guis = self.GUIs[player]
                if guis then
                    self:UpdateNameTag(player, guis.nameTag)
                end
            end
        else
            self:RemoveESP(player)
        end
    end

    if player.Character then
        characterAdded(player.Character)
    end

    local charAddedConn = player.CharacterAdded:Connect(characterAdded)
    local charRemovingConn = player.CharacterRemoving:Connect(characterRemoving)
    local teamChangedConn = player:GetPropertyChangedSignal('Team'):Connect(teamChanged)
    
    table.insert(getgenv().ESPConnection.Connections, charAddedConn)
    table.insert(getgenv().ESPConnection.Connections, charRemovingConn)
    table.insert(getgenv().ESPConnection.Connections, teamChangedConn)
end

function BoxESPLib:HandlePlayerRemoving(player)
    self:RemoveESP(player)
end

function BoxESPLib:Initialize()
    self.ScreenGui = Instance.new('ScreenGui')
    self.ScreenGui.Name = 'BoxESPScreenGui'
    self.ScreenGui.IgnoreGuiInset = true
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.ScreenGui.Parent = game.CoreGui
    getgenv().ESPConnection.ScreenGui = self.ScreenGui

    local players = game:GetService('Players')
    local localPlayer = players.LocalPlayer
    local camera = workspace.CurrentCamera

    local teamChangedConn = localPlayer:GetPropertyChangedSignal('Team'):Connect(function()
        for _, player in pairs(players:GetPlayers()) do
            if player ~= localPlayer then
                self:HandlePlayerAdded(player)
            end
        end
    end)
    table.insert(getgenv().ESPConnection.Connections, teamChangedConn)

    for _, player in pairs(players:GetPlayers()) do
        self:HandlePlayerAdded(player)
    end

    if self.Settings.LocalDebug then
        self:HandlePlayerAdded(localPlayer)
    end

    local playerAddedConn = players.PlayerAdded:Connect(function(player)
        self:HandlePlayerAdded(player)
    end)
    table.insert(getgenv().ESPConnection.Connections, playerAddedConn)

    local playerRemovingConn = players.PlayerRemoving:Connect(function(player)
        self:HandlePlayerRemoving(player)
    end)
    table.insert(getgenv().ESPConnection.Connections, playerRemovingConn)

    local renderLoopConn = game:GetService('RunService').Stepped:Connect(function()
        if not self.Enabled then
            for player, guis in pairs(self.GUIs) do
                pcall(function()
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
                end)
            end
            return
        end

        for player, guis in pairs(self.GUIs) do
            if not self:ShouldShowESP(player) then
                pcall(function()
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
                end)
                continue
            end

            local character = player.Character
            if not character or not character:IsA("Model") then
                pcall(function()
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
                end)
                continue
            end

            local hrp = character:FindFirstChild('HumanoidRootPart')
            local hum = character:FindFirstChildOfClass('Humanoid')
            
            if not hrp or not hum then
                pcall(function()
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
                end)
                continue
            end

            local screenPos = camera:WorldToViewportPoint(hrp.Position)
            if screenPos.Z <= 0 then
                pcall(function()
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
                end)
                continue
            end

            local tl, tr, br, bl, width, height = self:GetBoxCorners(character)
            if tl then
                self:UpdateBoxFrames(player, tl, tr, br, bl, width, height)
                
                pcall(function()
                    guis.boxFrame.Visible = self.Settings.Box.Enabled
                    guis.outlineFrame.Visible = self.Settings.Outline.Enabled
                    guis.fillFrame.Visible = self.Settings.Box.Filled

                    local healthPerc = math.clamp(hum.Health / hum.MaxHealth, 0, 1)

                    guis.healthbarOutline.Visible = self.Settings.Healthbar.Enabled
                    local healthbarX = tl.X - self.Settings.Healthbar.Width - 3 - 1
                    guis.healthbarOutline.Position = UDim2.fromOffset(healthbarX, tl.Y - 1)
                    guis.healthbarOutline.Size = UDim2.fromOffset(self.Settings.Healthbar.Width + 2, height + 2)

                    guis.barBG.Size = UDim2.fromOffset(self.Settings.Healthbar.Width, height)

                    self:UpdateHealthbar(player, guis.barFill, height, healthPerc)

                    if self.Settings.HealthChange.Enabled then
                        self:UpdateHealthChange(player, guis.healthChangeTags, healthbarX, tl.Y, height)
                    end

                    guis.nameTag.Visible = self.Settings.Nametag.Enabled
                    self:UpdateNameTag(player, guis.nameTag)
                    guis.nameTag.Position = UDim2.fromOffset((tl.X + tr.X) / 2 - 30, tl.Y + self.Settings.Nametag.Offset.Y)
                    guis.nameTag.Size = UDim2.fromOffset(60, 14)

                    guis.distanceTag.Visible = self.Settings.Distance.Enabled
                    local localHRP = localPlayer.Character and localPlayer.Character:FindFirstChild('HumanoidRootPart')
                    local distance = localHRP and math.floor((localHRP.Position - hrp.Position).Magnitude) or 0
                    guis.distanceTag.Text = '[' .. distance .. 'm]'
                    guis.distanceTag.Position = UDim2.fromOffset((bl.X + br.X) / 2 - 30, bl.Y + self.Settings.Distance.Offset.Y)
                    guis.distanceTag.Size = UDim2.fromOffset(60, 14)

                    if self.Settings.Velocity.Enabled then
                        guis.velocityTag.Visible = true
                        local velocity = math.floor(hrp.Velocity.Magnitude)
                        guis.velocityTag.Text = 'V:' .. velocity
                        guis.velocityTag.Position = UDim2.fromOffset(tr.X + 5, tr.Y - 3)
                        guis.velocityTag.Size = UDim2.fromOffset(35, 14)
                    else
                        guis.velocityTag.Visible = false
                    end

                    guis.highlight.Enabled = self.Settings.Highlight.Enabled
                    guis.highlight.Adornee = character
                    guis.highlight.FillColor = self.Settings.Highlight.Color
                    guis.highlight.FillTransparency = self.Settings.Highlight.Transparency
                    guis.highlight.OutlineColor = self.Settings.Highlight.OutlineColor
                    guis.highlight.OutlineTransparency = self.Settings.Highlight.OutlineTransparency
                end)
            else
                pcall(function()
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
                end)
            end
        end
    end)
    table.insert(getgenv().ESPConnection.Connections, renderLoopConn)
end

getgenv().DestroyBoxESP = function()
    if BoxESPLib and BoxESPLib.Destroy then
        BoxESPLib:Destroy()
    else
        for i, connection in ipairs(getgenv().ESPConnection.Connections or {}) do
            pcall(function() connection:Disconnect() end)
        end
        getgenv().ESPConnection.Connections = {}
        
        if getgenv().ESPConnection.ScreenGui then
            pcall(getgenv().ESPConnection.ScreenGui.Destroy, getgenv().ESPConnection.ScreenGui)
            getgenv().ESPConnection.ScreenGui = nil
        end
    end
end

BoxESPLib:Initialize()

return BoxESPLib
