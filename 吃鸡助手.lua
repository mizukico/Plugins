local szPluginName = "吃鸡助手1.1"

--上次拾取时的游戏帧
local lastpicktime = GetLogicFrameCount()

--附件物品表
local NearDoodad = {}

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
[6872] = "棕",      --风化的石马
[6873] = "棕",      --鬼黄藤

[6858] = "白",		--灌木
[6857] = "白",		--砂石
[6859] = "白",		--瓦罐
[6833] = "白",		--叹息风碑

[6822] = "灰",		--绷带
}

--拾取函数，参数:物品模板ID，返回：该模板下有物品存在于6尺内，返回该物品。否则返回nil
local function = PickUp(TemplateID)
	for dwTemplateID, dooded in pairs(NearDoodad) do
		if dwTemplateID == TemplateID then
			for dwID, _  in pairs(dooded) do
				local dooded = GetDoodad(dwID)
				local dis = s_util.GetDistance(player, dooded)	
				local player = GetClientPlayer()
				if dooded and dis <=6 then
					return dooded
				end
			end
		end
	end
	return nil
end

--判断是否施放某个技能
--参数(施放者id，施放技能ID，需确认的技能ID，距离，是否不需判定对自己释放)
local function UpdateSkill (ID,dwSkillID,SkillID,Dis,bol)
	local wanjia = GetPlayer(ID)
	local target, targetClass = s_util.GetTarget(wanjia)
	local player = GetClientPlayer()
	local distance = s_util.GetDistance(player,wanjia)
	if not bol then
		if SkillID == dwSkillID and distance<=Dis and target.dwID==player.dwID then
			return true
		else
			return false
		end
	else
		if SkillID == dwSkillID and distance<=Dis then
			return true
		else
			return false
		end
	end
end
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
	local player = GetClientPlayer()
	if(IsAltKeyDown() and IsKeyDown("F")) then --按下“Alt”+“F” 顺序交互
		--橙武 橙装 紫武 紫装 蓝武 蓝装 金创 行气 马草 坐骑
		local treasures = PickUp(6883) or PickUp(6884) or PickUp(6956) or PickUp(6955) or PickUp(6821) or PickUp(6953) or PickUp(6954) or PickUp(6820) or PickUp(6819) or PickUp(6951) or PickUp(6818) or PickUp(6952) or PickUp(6824) or PickUp(6875) or PickUp(6873) or PickUp(6863)
		if treasures and GetLogicFrameCount() - lastpicktime >= 3 and player.nMoveState == MOVE_STATE.ON_STAND then
			lastpicktime = GetLogicFrameCount()
			OpenDoodad(player, treasures)
		end
	end
end,

--Doodad进入场景，1个参数：DoodadID
["OnDoodadEnter"] = function(dwID)
	local doodad = GetDoodad(dwID)
	if doodad then
		local szColor = tTempID[doodad.dwTemplateID]
		NearDoodad[dwTemplateID][dwID] = true
		if szColor then
			local t = tColor[szColor]
			if t then
				local r, g, b, s = unpack(t)
				--在游戏对象脚下添加文本
				s_util.AddText(TARGET.DOODAD, doodad.dwID, r, g, b, 255, doodad.szName, s, true)		--对象类型，对象ID, 红，绿，蓝，透明度，文本，文字大小缩放，是否显示距离
			end
		end
	end
	s_Output(doodad.szName)
	s_Output("ID"..doodad.dwID)
	s_Output("模板ID"..doodad.dwTemplateID)
	s_Output("类型"..doodad.nKind)
	s_Output(doodad.CanDialog)
	s_Output(doodad.IsSelectable)
end,

--Doodad离开场景，1个参数：DoodadID
["OnDoodadLeave"] = function(dwID)
	NearDoodad[dwID] = nil
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

--施放技能调用， 参数：对象ID， 技能ID， 技能等级
["OnCastSkill"] = function(dwID, dwSkillID, dwLevel)
	local player = GetClientPlayer()
	if not IsPlayer(dwID) or not IsEnemy(player.dwID,dwID) then return end	--过滤掉非敌对玩家
	--撼地 20尺，千斤坠 20尺，疾 15尺
	if UpdateSkill(dwID,dwSkillID,13424,20) or UpdateSkill(dwID,dwSkillID,18604,20) or UpdateSkill(dwID,dwSkillID,424,15) then 
		s_util.SetTimer("tkongzhi1")
		s_Output("tkongzhi1")
	end
	--盾猛 12尺，龙跃于渊 20尺，龙战于野 20尺，棒打狗头 20尺，割据秦宫 10尺，断魂刺 27尺，破坚阵 4尺
	if UpdateSkill(dwID,dwSkillID,13046,12) or UpdateSkill(dwID,dwSkillID,5262,20) or UpdateSkill(dwID,dwSkillID,5266,20) or UpdateSkill(dwID,dwSkillID,5259,20) or UpdateSkill(dwID,dwSkillID,16479,10) or UpdateSkill(dwID,dwSkillID,428,27) or UpdateSkill(dwID,dwSkillID,426,4) then 
		s_util.SetTimer("tkongzhi2")
		s_Output("tkongzhi2")
	end
	--浮光掠影 30尺，冥月度心 12尺，紫气东来 20尺，擒龙诀 6尺，乱洒 20尺，梵音 20尺
	if UpdateSkill(dwID,dwSkillID,3112,30) or UpdateSkill(dwID,dwSkillID,18629,12) or UpdateSkill(dwID,dwSkillID,2681,20) or UpdateSkill(dwID,dwSkillID,260,6) or UpdateSkill(dwID,dwSkillID,2645,20) or UpdateSkill(dwID,dwSkillID,568,20) then 
		s_util.SetTimer("tbaofa1")
		s_Output("tbaofa1")
	end
end,

["OnDebug"] = function()
	s_util.OutputSysMsg(szPluginName.." OnDebug 被调用")
end,
}

--向插件管理系统返回定义的表
return tPlugin
