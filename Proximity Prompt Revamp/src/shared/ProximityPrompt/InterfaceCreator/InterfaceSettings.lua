local InterfaceSettings = {}

InterfaceSettings.PrincipalFrame = {
   Properties = {
      Name = 'Principal Frame';
      BackgroundColor3 = Color3.fromRGB(88, 88, 88);
      BorderSizePixel = 0;
      ZIndex = 0;
      Size = UDim2.fromScale(1,1);
      AnchorPoint = Vector2.new(.5,.5);
      Position = UDim2.fromScale(.5,.5);
   };
   Descendants = {
      Border = {
         Name = 'Border';
         CornerRadius = UDim.new(0,5)
      };
      InputKey = {
         Name = 'Input Label';
         BackgroundTransparency = 1;
         TextScaled = true;
         TextColor3 = Color3.fromRGB(255, 255, 255);
         Font = Enum.Font.Garamond;
         
         Size = UDim2.fromScale(1,1);
         AnchorPoint = Vector2.new(.5,.5);
         Position = UDim2.fromScale(.5,.5);
         ZIndex = 2;
      };
      SlideBar = {
         Name = 'Slide Bar';
         BorderSizePixel = 0;
         Position = UDim2.fromScale(0,0);
         BackgroundColor3 = Color3.fromRGB(186, 124, 124);
         Size = UDim2.fromScale(0,1)
      }
   }
}

return InterfaceSettings