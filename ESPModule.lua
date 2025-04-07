local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- ESP Variables
local ESPEnabled = false
local MaxDistance = 100
local ChamsColor = Color3.fromRGB(255, 0, 0)
local NameColor = Color3.fromRGB(255, 255, 255)
local HPColor = Color3.fromRGB(0, 255, 0)
local VehicleColor = Color3.fromRGB(0, 255, 255)
local InventoryColor = Color3.fromRGB(255, 255, 0)
local SkeletonColor = Color3.fromRGB(255, 0, 0)
local DistanceColor = Color3.fromRGB(255, 165, 0) -- Новый цвет для дистанции (оранжевый по умолчанию)
local ESPType = "Box3D"
local ShowNames = true
local ShowHP = true
local ShowVehicle = true
local ShowInventory = true
local ShowDistance = false -- Новое значение для отображения дистанции
local TeamCheck = true
local ScaleWithDistance = true

-- Функция перевода studs в метры
local function StudsToMeters(studs)
    return math.floor(studs * 0.28)
end

-- Создание ESP элементов
local function CreateESP(player)
    if player == LocalPlayer or not player.Character then return end
    local character = player.Character
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoidRootPart or not humanoid then return end

    local distance = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and 
        (humanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude) or 0
    if StudsToMeters(distance) > MaxDistance then return end

    if TeamCheck and player.Team == LocalPlayer.Team then return end

    local scaleFactor = ScaleWithDistance and math.clamp(1 - (distance / (MaxDistance / 0.28)), 0.3, 1) or 1

    local highlight = character:FindFirstChild("ESPHighlight")
    if not highlight then
        highlight = Instance.new("Highlight")
        highlight.Name = "ESPHighlight"
        highlight.Parent = character
        highlight.Adornee = character
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0
        highlight.FillColor = ChamsColor
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Enabled = ESPEnabled
    end

    local billboard = character:FindFirstChild("ESPBillboard")
    if not billboard then
        billboard = Instance.new("BillboardGui")
        billboard.Name = "ESPBillboard"
        billboard.Parent = character
        billboard.Adornee = humanoidRootPart
        billboard.Size = UDim2.new(0, 200 * scaleFactor, 0, 100 * scaleFactor)
        billboard.StudsOffset = Vector3.new(0, 4, 0)
        billboard.AlwaysOnTop = true
    else
        billboard.Size = UDim2.new(0, 200 * scaleFactor, 0, 100 * scaleFactor)
    end

    -- Name Label
    if ShowNames then
        local nameLabel = billboard:FindFirstChild("NameLabel")
        if not nameLabel then
            nameLabel = Instance.new("TextLabel")
            nameLabel.Name = "NameLabel"
            nameLabel.Parent = billboard
            nameLabel.Size = UDim2.new(1, 0, 0.25, 0)
            nameLabel.Position = UDim2.new(0, 0, 0, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.TextScaled = true
            nameLabel.TextStrokeTransparency = 0
            nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        end
        nameLabel.Text = player.Name
        nameLabel.TextColor3 = NameColor
    end

    -- HP Label
    if ShowHP then
        local hpLabel = billboard:FindFirstChild("HPLabel")
        if not hpLabel then
            hpLabel = Instance.new("TextLabel")
            hpLabel.Name = "HPLabel"
            hpLabel.Parent = billboard
            hpLabel.Size = UDim2.new(1, 0, 0.25, 0)
            hpLabel.Position = UDim2.new(0, 0, 0.25, 0)
            hpLabel.BackgroundTransparency = 1
            hpLabel.TextScaled = true
            hpLabel.TextStrokeTransparency = 0
            hpLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        end
        hpLabel.Text = math.floor(humanoid.Health) .. "/" .. humanoid.MaxHealth
        hpLabel.TextColor3 = HPColor
    end

    -- Vehicle Label
    if ShowVehicle and humanoid.SeatPart then
        local vehicleLabel = billboard:FindFirstChild("VehicleLabel")
        if not vehicleLabel then
            vehicleLabel = Instance.new("TextLabel")
            vehicleLabel.Name = "VehicleLabel"
            vehicleLabel.Parent = billboard
            vehicleLabel.Size = UDim2.new(1, 0, 0.25, 0)
            vehicleLabel.Position = UDim2.new(0, 0, 0.5, 0)
            vehicleLabel.BackgroundTransparency = 1
            vehicleLabel.TextScaled = true
            vehicleLabel.TextStrokeTransparency = 0
            vehicleLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        end
        vehicleLabel.Text = humanoid.SeatPart.Parent.Name
        vehicleLabel.TextColor3 = VehicleColor
    end

    -- Inventory Label
    if ShowInventory then
        local tool = character:FindFirstChildOfClass("Tool")
        if tool then
            local invLabel = billboard:FindFirstChild("InventoryLabel")
            if not invLabel then
                invLabel = Instance.new("TextLabel")
                invLabel.Name = "InventoryLabel"
                invLabel.Parent = billboard
                invLabel.Size = UDim2.new(1, 0, 0.25, 0)
                invLabel.Position = UDim2.new(0, 0, 0.75, 0)
                invLabel.BackgroundTransparency = 1
                invLabel.TextScaled = true
                invLabel.TextStrokeTransparency = 0
                invLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            end
            invLabel.Text = tool.Name
            invLabel.TextColor3 = InventoryColor
        end
    end

    -- Distance Label (новое)
    if ShowDistance then
        local distanceLabel = billboard:FindFirstChild("DistanceLabel")
        if not distanceLabel then
            distanceLabel = Instance.new("TextLabel")
            distanceLabel.Name = "DistanceLabel"
            distanceLabel.Parent = billboard
            distanceLabel.Size = UDim2.new(1, 0, 0.25, 0)
            distanceLabel.Position = UDim2.new(0, 0, ShowInventory and 1 or 0.75, 0) -- Сдвиг вниз, если есть инвентарь
            distanceLabel.BackgroundTransparency = 1
            distanceLabel.TextScaled = true
            distanceLabel.TextStrokeTransparency = 0
            distanceLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        end
        distanceLabel.Text = StudsToMeters(distance) .. " m"
        distanceLabel.TextColor3 = DistanceColor
    end

    -- ESP Types
    if ESPType == "Box3D" then
        local box = character:FindFirstChild("ESPBox")
        if not box then
            box = Instance.new("BoxHandleAdornment")
            box.Name = "ESPBox"
            box.Parent = character
            box.Adornee = humanoidRootPart
            box.Color3 = ChamsColor
            box.Transparency = 0.7
            box.AlwaysOnTop = true
        end
        local extents = character:GetExtentsSize() * scaleFactor
        box.Size = extents
        box.CFrame = humanoidRootPart.CFrame
    elseif ESPType == "Corner" then
        local head = character:FindFirstChild("Head")
        if head then
            local size = character:GetExtentsSize() * scaleFactor
            for i = 1, 8 do
                local corner = character:FindFirstChild("ESPCorner" .. i)
                if not corner then
                    corner = Instance.new("BoxHandleAdornment")
                    corner.Name = "ESPCorner" .. i
                    corner.Parent = character
                    corner.Adornee = head
                    corner.Color3 = ChamsColor
                    corner.Transparency = 0.5
                    corner.AlwaysOnTop = true
                end
                corner.Size = Vector3.new(size.X * 0.2, size.Y * 0.2, size.Z * 0.2)
                corner.CFrame = CFrame.new(
                    (i % 2 == 0 and -size.X/2 or size.X/2),
                    (i <= 4 and size.Y/2 or -size.Y/2),
                    (i % 4 < 2 and size.Z/2 or -size.Z/2)
                )
            end
        end
    elseif ESPType == "Skeleton" then
        local parts = {
            {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"},
            {"LowerTorso", "LeftUpperLeg"}, {"LowerTorso", "RightUpperLeg"},
            {"LeftUpperLeg", "LeftLowerLeg"}, {"RightUpperLeg", "RightLowerLeg"},
            {"UpperTorso", "LeftUpperArm"}, {"UpperTorso", "RightUpperArm"},
            {"LeftUpperArm", "LeftLowerArm"}, {"RightUpperArm", "RightLowerArm"}
        }
        for _, pair in pairs(parts) do
            local part1 = character:FindFirstChild(pair[1])
            local part2 = character:FindFirstChild(pair[2])
            if part1 and part2 then
                local line = character:FindFirstChild("ESPSkeleton" .. pair[1] .. pair[2])
                if not line then
                    line = Instance.new("CylinderHandleAdornment")
                    line.Name = "ESPSkeleton" .. pair[1] .. pair[2]
                    line.Parent = character
                    line.Adornee = part1
                    line.Color3 = SkeletonColor
                    line.Transparency = 0.5
                    line.AlwaysOnTop = true
                end
                local dist = (part1.Position - part2.Position).Magnitude
                line.Height = dist * scaleFactor
                line.Radius = 0.1 * scaleFactor
                line.CFrame = CFrame.new(part1.Position, part2.Position) * CFrame.new(0, 0, -dist/2)
            end
        end
    end
end

-- Удаление ESP
local function RemoveESP(player)
    if player.Character then
        local highlight = player.Character:FindFirstChild("ESPHighlight")
        if highlight then highlight:Destroy() end
        local billboard = player.Character:FindFirstChild("ESPBillboard")
        if billboard then billboard:Destroy() end
        local box = player.Character:FindFirstChild("ESPBox")
        if box then box:Destroy() end
        for _, child in pairs(player.Character:GetChildren()) do
            if child:IsA("BoxHandleAdornment") or child:IsA("CylinderHandleAdornment") then
                child:Destroy()
            end
        end
    end
end

-- Обновление ESP
local function UpdateESP()
    if not ESPEnabled then
        for _, player in pairs(Players:GetPlayers()) do
            RemoveESP(player)
        end
        return
    end
    for _, player in pairs(Players:GetPlayers()) do
        CreateESP(player)
        if ESPType == "Box3D" and player.Character then
            local character = player.Character
            local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
            local box = character:FindFirstChild("ESPBox")
            if humanoidRootPart and box then
                local distance = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and 
                    (humanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude) or 0
                local scaleFactor = ScaleWithDistance and math.clamp(1 - (distance / (MaxDistance / 0.28)), 0.3, 1) or 1
                local extents = character:GetExtentsSize() * scaleFactor
                box.Size = extents
                box.CFrame = humanoidRootPart.CFrame
            end
        end
    end
end
RunService.RenderStepped:Connect(UpdateESP)

-- Подключение событий игроков
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        if ESPEnabled then CreateESP(player) end
    end)
end)
Players.PlayerRemoving:Connect(RemoveESP)

-- Инициализация ESP для текущих игроков
for _, player in pairs(Players:GetPlayers()) do
    if player.Character then CreateESP(player) end
end

-- Экспорт функций модуля
return {
    ToggleESP = function(value)
        ESPEnabled = value
        if not value then
            for _, player in pairs(Players:GetPlayers()) do
                RemoveESP(player)
            end
        end
    end,
    SetMaxDistance = function(value) MaxDistance = value end,
    SetChamsColor = function(value)
        ChamsColor = value
        for _, player in pairs(Players:GetPlayers()) do
            if player.Character then
                local highlight = player.Character:FindFirstChild("ESPHighlight")
                if highlight then highlight.FillColor = value end
                local box = player.Character:FindFirstChild("ESPBox")
                if box then box.Color3 = value end
                for i = 1, 8 do
                    local corner = player.Character:FindFirstChild("ESPCorner" .. i)
                    if corner then corner.Color3 = value end
                end
            end
        end
    end,
    SetNameColor = function(value) NameColor = value end,
    SetHPColor = function(value) HPColor = value end,
    SetVehicleColor = function(value) VehicleColor = value end,
    SetInventoryColor = function(value) InventoryColor = value end,
    SetSkeletonColor = function(value)
        SkeletonColor = value
        for _, player in pairs(Players:GetPlayers()) do
            if player.Character then
                for _, child in pairs(player.Character:GetChildren()) do
                    if child:IsA("CylinderHandleAdornment") then
                        child.Color3 = value
                    end
                end
            end
        end
    end,
    SetESPType = function(value)
        ESPType = value
        for _, player in pairs(Players:GetPlayers()) do
            RemoveESP(player)
            if ESPEnabled then CreateESP(player) end
        end
    end,
    SetShowNames = function(value) ShowNames = value end,
    SetShowHP = function(value) ShowHP = value end,
    SetShowVehicle = function(value) ShowVehicle = value end,
    SetShowInventory = function(value) ShowInventory = value end,
    SetTeamCheck = function(value) TeamCheck = value end,
    SetScaleWithDistance = function(value) ScaleWithDistance = value end,
    -- Новые функции для дистанции
    SetShowDistance = function(value) ShowDistance = value end,
    SetDistanceColor = function(value)
        DistanceColor = value
        for _, player in pairs(Players:GetPlayers()) do
            if player.Character then
                local billboard = player.Character:FindFirstChild("ESPBillboard")
                if billboard then
                    local distanceLabel = billboard:FindFirstChild("DistanceLabel")
                    if distanceLabel then distanceLabel.TextColor3 = value end
                end
            end
        end
    end
}
