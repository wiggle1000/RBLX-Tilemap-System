--[[
	This file (along with Map.lua and Game.lua) is from part of a 2D engine implemented using Roblox UI objects.
	It's very performant; a sample implementation that refreshes on renderstep only takes an average of .844ms to fully execute! (according to the microprofiler)

	In this ModuleScript, we define the TileScreen type, as used by Game.lua. It's the main graphical controller for the game,
	and is responsible for creating, maintaining, and updating the visible tiles.
]]

local Map = require(game.ReplicatedStorage.Modules.Map);
local TileLookup = require(game.ReplicatedStorage.Modules.TileLookup);

local TileScreen = {}
TileScreen.__index = TileScreen;


type self = 
	{
		__index: TileScreen;
		
		spriteSheet 	: string;
		H_TILES 		: number;
		V_TILES 		: number;
		camX 			: number;
		map 			: Map.Map;
		mapTileParent 	: Instance?;
		_MapImages		: {[number] : {[number] : ImageLabel}}; -- 2D array of ImageLabels

		new 		:	(map : Map.Map, H_TILES : number, V_TILES : number, spriteSheet : string, mapTileParent : Instance) -> TileScreen,
		Construct 	:	(self : TileScreen) -> (),
		Cleanup   	:	(self : TileScreen) -> (),
		LoadMap 	:	(self : TileScreen, map : Map.Map) -> (),
		SetCamX 	:	(self : TileScreen, x : number) -> (),
		Refresh   	:	(self : TileScreen) -> (),
	};

export type TileScreen = typeof( setmetatable({} :: self, {} :: TileScreen) );

function TileScreen.new(map : Map.Map, H_TILES : number, V_TILES : number, spriteSheet : string, mapTileParent : Instance?)
	local self = setmetatable({}, TileScreen);
	self.map = map;
	self.H_TILES = H_TILES;
	self.V_TILES = V_TILES;
	self.spriteSheet = spriteSheet;
	self.mapTileParent = mapTileParent;
	return self;
end

--- Builds visual tiles as children of the "parent" object (specified in constructor)
function TileScreen:Construct()
	self._MapImages = {};
	for x = -1, self.H_TILES do
		self._MapImages[x] = {};
		for y = 0, self.V_TILES do
			local inst = Instance.new("ImageLabel");
			inst.Parent = self.mapTileParent;
			inst.Position = UDim2.new((x+0.5)/self.H_TILES,0,y/self.V_TILES,0);
			inst.Size = UDim2.new(1/self.H_TILES,0,1/self.V_TILES,0);
			inst.Image = self.spriteSheet;
			inst.ImageRectSize = Vector2.new(16,16);
			inst.AnchorPoint = Vector2.new(0.5,0.5);
			inst.ResampleMode = Enum.ResamplerMode.Pixelated;
			inst.BackgroundTransparency = 1;
			inst.ImageTransparency = 1;
			inst.Name = "TILE_"..tostring(x).."_"..tostring(y);
			self._MapImages[x][y] = inst;
		end
	end
	self:LoadMap();
end

--- Destroys all visual tiles
function TileScreen:Cleanup()
	for x = -1, self.H_TILES do
		for y = 0, self.V_TILES do
			self._MapImages[x][y]:Destroy();
		end
	end
end

--- Sets a new Map object as the displayed map
function TileScreen:LoadMap(map : Map.Map)
	for x = -1, self.H_TILES do
		for y = 0, self.V_TILES do
			local tileId : number = self.map:GetTile(x, y);
			if tileId ~= 0 then
				local tileType = TileLookup:GetTile(tileId);
				if tileType ~= nil then
					self.ImageRectOffset = tileType.UV * 16;
					self.ImageTransparency = 0;
				end
			end
		end
	end
end

--- Sets camX, used for scrolling.
function TileScreen:SetCamX(x: number)
	self.camX = x;
end

--- Updates the visual tiles from the map object and scroll value
function TileScreen:Refresh()
	local cxf = math.floor(self.camX);
	local hMod : number = self.camX - cxf;
	for x = -1, self.H_TILES do
		for y = 0, self.V_TILES do
			self._MapImages[x][y].ImageTransparency = 1;
			self._MapImages[x][y].Position = UDim2.new(((x+0.5) - hMod)/self.H_TILES,0,y/self.V_TILES,0);

			local tileId : number = self.map:GetTile(x + cxf ,y);
			if tileId ~= 0 then
				local tileType = TileLookup:GetTile(tileId);
				if tileType ~= nil then
					self._MapImages[x][y].ImageRectOffset = tileType.UV * 16;
					self._MapImages[x][y].ImageTransparency = 0;
				end
			end
		end
	end
end

return TileScreen;