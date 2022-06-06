--Services
local TweenService = game:GetService('TweenService')
local Players = game:GetService('Players')

local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
--Modules
local InterfaceSettings = require(script.InterfaceSettings)
local SignalService = require(script.Parent.SignalService)

--Functions
function SetPropertiesToInstance(Object: Instance, ArrayOfValues:{[string|number]: any}):()
   warn("Setting properties to", Object, ArrayOfValues)
   for PropertieName: string|number, PropertieValue: any in next, ArrayOfValues do
      Object[PropertieName] = PropertieValue
   end
end

function InstanceObject(ClassName, Properties):Instance
   local Object = Instance.new(ClassName)
   SetPropertiesToInstance(Object, Properties)

   return Object
end

function Play(self):()
   print("Played Animation", self)

   for _, Tween: Tween in next, self do
      Tween:Play()
   end
end

function Completed(self):()
   for _, Tween: Tween in next, self do
      return Tween.Completed:Wait()
   end
end

-- Interface Creator
local InterfaceCreator = {}
InterfaceCreator.__index = InterfaceCreator

function InterfaceCreator.Create(InputKey: string, ProximityParamters)
   print('New Prompt gui created.')
  
   local HoldTweenInfo: TweenInfo = TweenInfo.new(ProximityParamters.HoldDuration, ProximityParamters.TweenParamters.EasingStyle, ProximityParamters.TweenParamters.EasingDirection)
   local UnHoldTweenInfo: TweenInfo = TweenInfo.new(ProximityParamters.HoldDuration/1.5, ProximityParamters.TweenParamters.EasingStyle, ProximityParamters.TweenParamters.EasingDirection)

   local ScreenGui = InstanceObject("BillboardGui", {
      Size = UDim2.fromScale(0,0);
      Name = 'Prompt gui';
      AlwaysOnTop = true;
      ResetOnSpawn = false;
      MaxDistance = 40;
   })
   local SizeCompletedCicle = SignalService()
   local PrincipalFrame = InstanceObject("Frame", InterfaceSettings.PrincipalFrame.Properties)
   PrincipalFrame.Parent =ScreenGui
   local UiCorner = InstanceObject("UICorner", InterfaceSettings.PrincipalFrame.Descendants.Border)
   UiCorner.Parent = PrincipalFrame
   local TextLabel = InstanceObject("TextLabel", InterfaceSettings.PrincipalFrame.Descendants.InputKey)
   TextLabel.Text = InputKey
   TextLabel.Parent = PrincipalFrame
   local SlideBar = InstanceObject("Frame", InterfaceSettings.PrincipalFrame.Descendants.SlideBar)
   SlideBar.Parent = PrincipalFrame
   UiCorner:Clone().Parent = SlideBar

   SlideBar:GetPropertyChangedSignal("Size"):Connect(function()
      if SlideBar.Size.X.Scale == 1 then
         SizeCompletedCicle:Fire()
      end
   end)

   ScreenGui.Parent = PlayerGui
   return ScreenGui, {
      Open = TweenService:Create(ScreenGui, HoldTweenInfo, {Size = UDim2.fromScale(.8,.8)}),
      Close = TweenService:Create(ScreenGui, UnHoldTweenInfo, {Size = UDim2.fromScale(0,0)}),

      Hold = TweenService:Create(SlideBar, HoldTweenInfo, {Size = UDim2.fromScale(1,1)}), 
      UnHold = TweenService:Create(SlideBar, UnHoldTweenInfo, {Size = UDim2.fromScale(0,1)})
   }, SizeCompletedCicle
end

return InterfaceCreator :: {
   Create: (InputKey: string)-> any
}