--[[
	This file (along with TileScreen.lua and Game.lua) is from part of a 2D engine implemented using Roblox UI objects.
	It's very performant; this sample implementation only takes an average of .844ms to fully execute! (according to the microprofiler)

	In this LocalScript, we generate a demonstration map for testing purposes, then set up a simple implementation of TileScreen and scroll it around!
]]

local TileScreen = require(game.ReplicatedStorage.Modules.TileScreen);
local TileLookup = require(game.ReplicatedStorage.Modules.TileLookup);
local Map = require(game.ReplicatedStorage.Modules.Map);

local mapImageParent : Instance? = script.Parent.Blackbars.MainFrame;

--used for determining the visual tile screen size
local H_TILES = 16;
local V_TILES = 12;

--create map object, then create tilescreen from it
local map = Map.new("Test Map", nil, 128, 16);
local t = TileScreen.new(map, 16, 12, "rbxassetid://130508291424353", mapImageParent);

t:Construct(); -- Create visual tiles on the screen

--a bit hackish, but gets us something to display. Not production ready.
for x = 0, 128 do
	for y = 0, 12 do
		if (y == 8)then
			map:SetTileByName(x, y, "Grass_U");
		elseif (y > 8) then
			map:SetTileByName(x, y, "Dirt");
		end
		local m = math.floor(x)%10;
		if(m==1 and y == 7)then
			map:SetTileByName(x, y, "Grass_UL");
		elseif(m==1 and y == 8)then
			map:SetTileByName(x, y, "Grass_IUL");
		end
		if(m==2 and y == 7)then
			map:SetTileByName(x, y, "Grass_UR");
		elseif(m==2 and y == 8)then
			map:SetTileByName(x, y, "Grass_IUR");
		end
	end
end

--test

game:GetService("RunService"):BindToRenderStep("updateTilemap", Enum.RenderPriority.First.Value+1, 
	function(dt)
		t:SetCamX(64 + (math.sin(os.clock()/10) * 64)); --smoothly pan camera around as a test
		t:Refresh(); --update visual representation of map
	end
);