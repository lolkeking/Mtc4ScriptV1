local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Teleport Variables
local TeleportEnabled = false
local TeleportBind = Enum.KeyCode.Q

-- Функция телепортации
local function TeleportToCursor()
    if not TeleportEnabled then return end
    
    local mouse = LocalPlayer:GetMouse()
    local ray = Camera:ScreenPointToRay(mouse.X, mouse.Y)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    
    local raycastResult = workspace:Raycast(ray.Origin, ray.Direction * 1000, raycastParams)
    
    if raycastResult then
        local humanoidRootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            local tweenInfo = TweenInfo.new(
                0.2,
                Enum.EasingStyle.Quad,
                Enum.EasingDirection.Out
            )
            local tween = TweenService:Create(humanoidRootPart, tweenInfo, {
                CFrame = CFrame.new(raycastResult.Position + Vector3.new(0, 3, 0))
            })
            tween:Play()
        end
    end
end

-- Подключение бинда для телепорта
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == TeleportBind then
        TeleportToCursor()
    end
end)

-- Экспорт функций модуля
return {
    ToggleTeleport = function(value) TeleportEnabled = value end,
    SetTeleportBind = function(value) TeleportBind = value end
}