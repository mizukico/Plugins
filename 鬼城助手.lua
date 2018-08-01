local szPluginName = "鬼城助手1.0"

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
[60167] = "紫",		--风筝NPC
[60228] = "橙",		--尸罐NPC

--病毒样本
[7087] = "绿",		
[7088] = "绿",
[7089] = "绿",	
[7090] = "绿",		
[7091] = "绿",		
[7092] = "绿",		
[7093] = "绿",		
[7094] = "绿",		
[7095] = "绿",	
[7096] = "绿",	

[7084] = "棕",		--援助灵灯

[7063] = "白",		--可钻棺材
[7067] = "白",      --可钻棺材2
[7068] = "白",		--可钻棺材3
[7064] = "白",		--可钻水缸
[7062] = "白",		--可钻草堆
}

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
["dwMapID"] = 322,

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
	Minimap.bSearchRedName = false			--关闭小地图红名
	local player = GetClientPlayer()
end,

--Doodad进入场景，1个参数：DoodadID
["OnDoodadEnter"] = function(dwID)
	local doodad = GetDoodad(dwID)
	if doodad then 
		if tTempID[doodad.dwTemplateID] then
			local t = tColor[tTempID[doodad.dwTemplateID]]
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

--NPC进入场景会调用，参数：NPCID
["OnNpcEnter"] = function(dwID)
	local npc = GetNpc(dwID)
	if npc then
		if npc[npc.dwTemplateID] then
			local t = tColor[tTempID[npc.dwTemplateID]]
			if t then
				local r, g, b, s = unpack(t)
				--在游戏对象脚下添加文本
				--对象类型，对象ID, 红，绿，蓝，透明度，文本，文字大小缩放，是否显示距离
				s_util.AddText(TARGET.NPC, npc.dwID, r, g, b, 255, npc.szName, 1.5, true)
				--在游戏对象脚下添加圆圈
				--对象类型，对象ID, 红，绿，蓝，透明度，角度，半径（尺）
				s_util.AddShape(TARGET.NPC, npc.dwID, r, g, b, 80, 360, 2)
			end
		end
	end
end,

--NPC离开场景会调用，参数：NPCID。这里不要再获取对象，应该执行和这个ID有关的一些清理工作。
["OnNpcLeave"] = function(dwID)
end,

--施放技能调用， 参数：对象ID， 技能ID， 技能等级
["OnCastSkill"] = function(dwID, dwSkillID, dwLevel)
	local player = GetClientPlayer()
	if not IsPlayer(dwID) or not IsEnemy(player.dwID,dwID) then return end	--过滤掉非敌对玩家
	--撼地 20尺，千斤坠 20尺，疾 15尺
	if UpdateSkill(dwID,dwSkillID,13424,20) or UpdateSkill(dwID,dwSkillID,18604,20) or UpdateSkill(dwID,dwSkillID,424,15) then 
		s_util.SetTimer("tkongzhi1")
		s_Output(Table_GetSkillName(dwSkillID, dwLevel))
	end
	--盾猛 12尺，龙跃于渊 20尺，龙战于野 20尺，棒打狗头 20尺，割据秦宫 10尺，断魂刺 27尺，破坚阵 4尺
	if UpdateSkill(dwID,dwSkillID,13046,12) or UpdateSkill(dwID,dwSkillID,5262,20) or UpdateSkill(dwID,dwSkillID,5266,20) or UpdateSkill(dwID,dwSkillID,5259,20) or UpdateSkill(dwID,dwSkillID,16479,10) or UpdateSkill(dwID,dwSkillID,428,27) or UpdateSkill(dwID,dwSkillID,426,4) then 
		s_util.SetTimer("tkongzhi2")
		s_Output(Table_GetSkillName(dwSkillID, dwLevel))
	end
	--冥月度心 12尺，紫气东来 20尺，擒龙诀 6尺，乱洒 20尺
	if UpdateSkill(dwID,dwSkillID,18629,12) or UpdateSkill(dwID,dwSkillID,2681,20) or UpdateSkill(dwID,dwSkillID,260,6) or UpdateSkill(dwID,dwSkillID,2645,20) then 
		s_util.SetTimer("tbaofa1")
		s_Output(Table_GetSkillName(dwSkillID, dwLevel))
	end
	--梵音 20尺
	if UpdateSkill(dwID,dwSkillID,568,20,true) then
		s_util.SetTimer("tbaofa2")
		s_Output(Table_GetSkillName(dwSkillID, dwLevel))
	end
	--浮光掠影 30尺
	if UpdateSkill(dwID,dwSkillID,3112,30,true) then
		s_util.SetTimer("tbaofa3")
		s_Output(Table_GetSkillName(dwSkillID, dwLevel))
	end
	--盾立
	if dwSkillID==13067 and target and target.dwID==dwID then s_util.SetTimer("dunli") end
end,

["OnDebug"] = function()
	s_util.OutputSysMsg(szPluginName.." OnDebug 被调用")
end,
}

--向插件管理系统返回定义的表
return tPlugin
