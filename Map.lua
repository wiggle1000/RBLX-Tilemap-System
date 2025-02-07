--[[
	This file (along with TileScreen.lua and Game.lua) is from part of a 2D engine implemented using Roblox UI objects.
	It's very performant; a sample implementation that refreshes on renderstep only takes an average of .844ms to fully execute! (according to the microprofiler)

	In this ModuleScript, we define the Map type, as used by TileScreen. It has several convenience features for getting and setting tiles.
]]

local TileLookup = require(script.Parent.TileLookup);

local Map = {};
Map.__index = Map;

type self = 
	{
		name 		: string;
		timeLimit 	: number?;
		width 		: number;
		height 		: number;
		tileData 	: { [number] : { [number] : number } }; --2D Array of numbers
	};

type MapImpl =
	{
		__index: Map;
		new				:	(name : string, timeLimit : number?, width : number, height : number) -> Map,
		CheckTileColl	:	(self : Map, x : number, y : number) -> boolean,
		IsWithinBounds	:	(self : Map, x : number, y : number) -> boolean,
		SetTile			:	(self : Map, x : number, y : number, t : number) -> boolean,
		SetTileByName	:	(self : Map, x : number, y : number, t : string) -> boolean,
		GetTile			:	(self : Map, x : number, y : number) -> number,
	}

export type Map = typeof( setmetatable({} :: self, {} :: MapImpl) );

function Map.new(name : string, timeLimit : number?, width : number, height : number)
	local self = setmetatable({}, Map);
	self.name = name;
	self.timeLimit = timeLimit;
	self.width = width;
	self.height = height;
	self.tileData = {};
	for x = 0, width do
		self.tileData[x] = {};
		for y = 0, height do
			self.tileData[x][y] = 0;
		end
	end
	return self;
end

function Map:CheckTileColl(x : number, y : number) : boolean
	if (not self:IsWithinBounds(x, y)) then return true; end
	
	--get tile (if nil, no collision)
	local t : number = self:GetTile(x, y);
	if (t == 0) then return false; end

	--get tileData (if nil, no collision)
	local tileData = TileLookup:GetTile(t);
	if(tileData == nil) then return false; end;
	
	return tileData.collides;
end

--- Check if specified tile coordinate is within the extents of the tilemap
function Map:IsWithinBounds(x : number, y : number) : boolean
	x = math.floor(x);
	y = math.floor(y);
	if (x > self.width or x < 0 or y > self.height or y < 0) then return false; end
	return true;
end

--- Set tile at specified location if possible
function Map:SetTile(x : number, y : number, t : number) : boolean
	if (not self:IsWithinBounds(x, y)) then return false; end
	self.tileData[x][y] = t;
	--print("Setting Tile at "..x..", "..y.." to "..t.."!");
	return true;
end

--- Set tile at specified location if possible, using TileLookup to get the TileID From name
--- (Convenience function for testing, do not use at runtime!)
function Map:SetTileByName(x : number, y : number, t_name : string) : boolean
	if (not self:IsWithinBounds(x, y)) then return false; end
	local t = TileLookup:GetTileIDByName(t_name);
	if( t == nil ) then return false; end;
	self:SetTile(x, y, t);
	return true;
end

--- Get the tile at specified location if possible, or 0 otherwise
function Map:GetTile(x : number, y : number) : number
	if (not self:IsWithinBounds(x, y)) then return 0; end
	return self.tileData[x][y];
end

return Map;