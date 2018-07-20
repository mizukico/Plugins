local szPluginName = "吃鸡助手1.1"

--颜色表
local tColor = {
["灰"] = { 169, 169, 169,  1.0 },			--红，绿，蓝，缩放
["白"] = { 250, 250, 250,  1.0 },
["绿"] = {   0, 210,  75,  1.0 },
["蓝"] = {   0, 126, 255,  1.2 },
["紫"] = { 255,  45, 255,  1.4 },
["橙"] = { 255, 165,   0,  1.6 },
["黄"] = { 255, 255,   0,  1.0 },
["棕"] = {  94,  38,  18,  1.0 }
}

--需要显示的Doodad表
local tTempID = {
[6816] = "绿",		--一阶装备
[6950] = "绿",		--丢弃的装备·一
[6817] = "绿",		--一阶武器
[6949] = "绿",		--丢弃的武器·一

[6818] = "蓝",		--二阶装备
[6952] = "蓝",		--丢弃的装备·二
[6819] = "蓝",		--二阶武器
[6951] = "蓝",		--丢弃的武器·二

[6820] = "紫",		--三阶装备
[6954] = "紫",		--丢弃的装备·三
[6821] = "紫",		--三阶武器
[6953] = "紫",		--丢弃的武器·三

[6955] = "橙",		--丢弃的武器·天
[6884] = "橙",		--天阶装备
[6956] = "橙",		--丢弃的装备·天
[6883] = "橙",		--天阶武器

[6824] = "黄",		--金疮药
[6875] = "黄",		--行气散
[6937] = "黄",		--丢弃的金创药
[6943] = "黄",		--丢弃的行气散

[6973] = "棕",		--流萤魂返花
[6994] = "棕",		--驼铃
[6863] = "棕",		--匿踪宝盒

[6858] = "白",		--灌木
[6857] = "白",		--砂石
[6859] = "白",		--瓦罐
[6833] = "白",		--叹息风碑
}


------------------------------------------------插件表，设置插件信息和回调函数------------------------------------------------
local tPlugin = {
--插件在菜单中显示的名字。必须设置
["szName"] = szPluginName,

--插件类型。  1(5人副本)， 2(10人副本)， 3(25人副本)，4(竞技场)，5(其他)。必须设置
["nType"] = 5,

--绑定地图，单个地图设置为地图ID，多个地图，设置为表。可以不设置，在游戏中手动开启
["dwMapID"] = { 296, 297 },

--初始化函数，启用插件会调用
["OnInit"] = function()
	local player = GetClientPlayer()
	if not player then return false end
	s_util.OutputSysMsg("插件 "..szPluginName.." 已启用")
	s_util.OutputSysMsg("欢迎 "..player.szName.." 使用本插件")
	s_util.OutputSysMsg("插件作者：xxxx")
	return true
end,

["OnTick"] = function()
	Minimap.bSearchRedName = true			--打开小地图红名
end,

--Doodad进入场景，1个参数：DoodadID
["OnDoodadEnter"] = function(dwID)
	local doodad = GetDoodad(dwID)
	if doodad then
		local szColor = tTempID[doodad.dwTemplateID]
		if szColor then
			local t = tColor[szColor]
			if t then
				local r, g, b, s = unpack(t)
				--在游戏对象脚下添加文本
				s_util.AddText(TARGET.DOODAD, doodad.dwID, r, g, b, 255, doodad.szName, s, true)		--对象类型，对象ID, 红，绿，蓝，透明度，文本，文字大小缩放，是否显示距离
			end
		end
	end
end,

--Doodad离开场景，1个参数：DoodadID
["OnDoodadLeave"] = function(dwID)

end,

--玩家进入场景，1个参数：玩家ID 
["OnPlayerEnter"] = function(dwID)
	local me = GetClientPlayer()
	local player = GetPlayer(dwID)			--这返回的对象，只有ID之类的，名字等等都还没同步获取不到，和自己无关的人，也没法获取血量，返回都是255
	if player and player.dwID ~= me.dwID and IsEnemy(me.dwID, player.dwID) then			--如果有玩家，不是我，是敌人
		s_util.AddText(TARGET.PLAYER, player.dwID, 255, 0, 0, 200, "敌人", 1.2, true)
	end
end,

--玩家离开场景，1个参数：玩家ID
["OnPlayerLeave"] = function(dwID)

end,

["OnDebug"] = function()
	s_util.OutputSysMsg(szPluginName.." OnDebug 被调用")
end,
}

--向插件管理系统返回定义的表
return tPlugin
