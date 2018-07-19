local szPluginName = "吃鸡助手1.0"

--颜色表
local tColor = {
["灰"] = { 169, 169, 169,  1.0 },			--红，绿，蓝，缩放
["白"] = { 250, 250, 250,  1.0 },
["绿"] = {   0, 210,  75,  1.0 },
["蓝"] = {   0, 126, 255,  1.2 },
["紫"] = { 255,  45, 255,  1.4 },
["橙"] = { 255, 165,   0,  1.6 },
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

["OnDebug"] = function()
	s_util.OutputSysMsg(szPluginName.." OnDebug 被调用")
end,
}

--向插件管理系统返回定义的表
return tPlugin
