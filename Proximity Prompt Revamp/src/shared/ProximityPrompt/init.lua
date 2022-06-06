--First Tables to Global acess. -- Made by Dufex; Vai tomar no cu se for copiar essa porra, deu trabalho pra krl pra fazer essa bosta
local ProximityService = {}
local GlobalStorage: {[number]: Proximity} = {}

ProximityService.__index = ProximityService
ProximityService.PlayerIsOnMobile = false
--Roblox Services
local UserInputService = game:GetService('UserInputService')

--Any
local InterfaceCreator = require(script.InterfaceCreator)
local SignalService = require(script.SignalService)
local Settings = {UpdateFrequency = 1/30;}

local UserInputStart;
local UserInputStop;
local Character = nil;
local Defer = task.defer;

if not UserInputService.KeyboardEnabled and UserInputService.TouchEnabled then
   ProximityService.PlayerIsOnMobile = true
end

-- Another functions

local function OnInputStart(input: InputObject, gameProcessedEvent: boolean)
   if not gameProcessedEvent then
      if input.UserInputType == Enum.UserInputType.Keyboard then
         for _, Prompts: Proximity in next, GlobalStorage do
            if Prompts.IsOnArea then
               local KeyCode = Prompts.ProximityParamters.KeyCode
               if KeyCode == input.KeyCode then
                  Prompts.Holding = true
                  Prompts:Hold()
               end
            end
         end
      end
   end
end

local function OnInputStop(input: InputObject, gameProcessedEvent: boolean)
   if not gameProcessedEvent then
      if input.UserInputType == Enum.UserInputType.Keyboard then
         for _, Prompts: Proximity in next, GlobalStorage do
            if Prompts.Holding then
                Prompts:UnHold()
            end
         end
      end
   end
end

local function CompairDistances(Prompt: Proximity): ()
   local PlayerCharacter = Prompt.ProximityParamters.Character;
   local RelativePart = Prompt.ProximityParamters.RelativePart;
   local MinimalActionDistance = Prompt.ProximityParamters.MinimalActionDistance;

   if PlayerCharacter then
      local PlayerPrimaryPart: BasePart = PlayerCharacter.PrimaryPart
      local DistanceOfPrompt: number = (PlayerPrimaryPart.Position - RelativePart.Position).Magnitude

      if DistanceOfPrompt <= MinimalActionDistance then
         Prompt:Open()
         Prompt.OpenAnimationPlayed = true
         Prompt.IsOnArea = true
      else
         Prompt:Close()
         Prompt.IsOnArea = false
      end
   end
end

local function OnCharacterChange(NewCharacter: Instance & Model):()
   UserInputStart = UserInputService.InputBegan:Connect(OnInputStart)
   UserInputStop = UserInputService.InputBegan:Connect(OnInputStop)

   local Humanoid = NewCharacter:WaitForChild('Humanoid')
   Humanoid.Died:Wait()

   UserInputStart:Disconnect()
   UserInputStop:Disconnect()
end

--Proximity

function ProximityService.new(ProximityParamters: ProximityParamters):(Proximity)
   assert(ProximityParamters, 'Proximity Paramters is nil, send a valid value!')
   Character = Character or Defer(OnCharacterChange, ProximityParamters.Character)

   local Proximity = setmetatable({}, {
      ProximityStoreValues = {IsOnArea = false;CanContinue = false; CancelAction = SignalService()};
      __index = function(self, Name: string):any
         local ProximityMetable = getmetatable(self)
         local Result: any = (rawget(ProximityService, Name) or rawget(ProximityMetable.ProximityStoreValues, Name))
         return Result
      end,

      __newindex = function(self, Name: string, Value: any):()
         local ProximityMetable = getmetatable(self)
         rawset(ProximityMetable.ProximityStoreValues, Name, Value)
      end
   })

   Proximity.ProximityParamters = ProximityParamters
   Proximity.PromptGui, Proximity.Animations, Proximity.SizeCompletedCicle  = InterfaceCreator.Create(ProximityParamters.KeyCode.Name, ProximityParamters)

   Proximity.HoldStart = SignalService()
   Proximity.HoldStop = SignalService()

   Proximity.PlayerEnter = SignalService()
   Proximity.PlayerLeft = SignalService()
   Proximity.Completed = SignalService()

   Proximity.CancelAction:Connect(function()
      Proximity.CanContinue = false
      Proximity.HoldStop:Fire()
   end)

   Proximity.SizeCompletedCicle:Connect(function()
      Proximity.Completed:Fire()
      warn('Completed')
   end)

   print(getmetatable(Proximity).ProximityStoreValues)
   Proximity.PromptGui.Adornee = ProximityParamters.RelativePart
   table.insert(GlobalStorage, Proximity)
   return Proximity
end

function ProximityService:Open():()
   local Proximity: Proximity = self
   if not Proximity.OpenAnimationPlayed then
      Proximity.Animations.Open:Play()
      Proximity.PlayerEnter:Fire()
   end
end

function ProximityService:Close():()
   local Proximity: Proximity = self
   if Proximity.OpenAnimationPlayed then
      Proximity.PlayerLeft:Fire()
      Proximity.Animations.Close:Play()
      self.OpenAnimationPlayed = false
   end
end

function ProximityService:Hold():()
   local Proximity: Proximity = self
   local IsOnArea: boolean = Proximity.IsOnArea
   
   if IsOnArea then
      Proximity.Animations.Hold:Play()
   end
end

function ProximityService:UnHold():()
   local Proximity: Proximity = self
   Proximity.CancelAction:Fire()
   Proximity.Animations.UnHold:Play()
end

function ProximityService:Disconnect():()
   local Proximity: Proximity = self
   Proximity:Close()
   Proximity:UnHold()

   for _, Signal: SignalService.CustomSignal in next, Proximity do
      if tostring(Signal) then
         Signal:Disconnect()
      end
   end

   setmetatable(Proximity, nil)
   table.clear(Proximity)
end

task.defer(function()
   local UpdateFrequency: number = Settings.UpdateFrequency

   while (task.wait(UpdateFrequency)) do
      for _,Prompt: Proximity in next, GlobalStorage do
         Defer(CompairDistances, Prompt)
      end
   end
end)

UserInputStart = UserInputService.InputBegan:Connect(OnInputStart)
UserInputStop = UserInputService.InputEnded:Connect(OnInputStop)

Defer(function()
   repeat
      task.wait()
   until Character
end)

--Types
export type ProximityParamters = {
   MinimalActionDistance: number;
   HoldDuration: number;

   KeyCode: Enum.KeyCode;
   Character: Instance & Model;
   RelativePart: Instance & BasePart;

   TweenParamters: {EasingStyle: Enum.EasingStyle; EasingDirection: Enum.EasingDirection}
}

type Signal = {
   Connect: (...any) -> ...any;
   Disconnect: ()->();
   Wait: ()->();
}

type ProximityService = {
   PlayerIsOnMobile: boolean;

   new: (ProximityParamters) -> Proximity;
   Hold: ()->();
   UnHold:()->();
}

export type Proximity = {
   ProximityParamters: ProximityParamters;
   PromptGui: BillboardGui;
   Animations: {['string']: Tween};
   CanContinue: boolean;

   HoldStart: Signal;
   HoldStop: Signal;
   Completed: Signal;
   PlayerEnter: Signal;
   PlayerLeft: Signal;
}

return ProximityService :: ProximityService