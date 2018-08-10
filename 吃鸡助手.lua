local szPluginName = "吃鸡助手1.2"

--伪装记录
g_MacroVars.chijizhushou_WeiZhuangID = nil
g_MacroVars.chijizhushou_gouxuan = false

--扳手菜单
local chijimenu = {
	szOption = "吃鸡助手工具",
	{
	szOption = "重置伪装ID",
	fnAction =function() 
		g_MacroVars.chijizhushou_WeiZhuangID = nil
		s_util.OutputSysMsg("伪装最小ID已重置") 
	end,
	},
	{
	szOption = "确认伪装ID",
	fnAction =function() 
		s_util.OutputSysMsg("伪装最小ID为："..tostring(g_MacroVars.chijizhushou_WeiZhuangID)) 
	end,
	},
	{
	szOption = "勾选测试",
	bCheck = true, 
	bChecked = g_MacroVars.chijizhushou_gouxuan,
	fnAction =function() 
		g_MacroVars.chijizhushou_gouxuan = not g_MacroVars.chijizhushou_gouxuan
	end,
	},
}

--颜色表
local tColor = {
["灰"] = { 169, 169, 169,  1.0 },			--红，绿，蓝，缩放
["白"] = { 250, 250, 250,  1.0 },
["绿"] = {   0, 210,  75,  1.0 },
["蓝"] = {   0, 126, 255,  1.2 },
["紫"] = { 255,  45, 255,  1.4 },
["橙"] = { 255, 165,   0,  1.6 },
["黄"] = { 255, 255,   0,  1.2 },
["棕"] = {  94,  38,  18,  1.1 }
}

--需要显示的Doodad表
local tTempID = {
[6817] = "绿",		--一阶武器

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
[6863] = "棕",		--匿踪宝盒
[6872] = "棕",      --风化的石马
[6873] = "棕",      --鬼黄藤

[6858] = "白",		--灌木
[6857] = "白",		--砂石
[6859] = "白",		--瓦罐
[6833] = "白",		--叹息风碑

[6822] = "灰"		--绷带
}

--判断是否施放某个技能
--参数(施放者id，施放技能ID，需确认的技能ID，距离，是否不需判定对自己释放)
local function UpdateSkill (ID,dwSkillID,SkillID,Dis,bol)
	local wanjia = GetPlayer(ID)
	local target, targetClass = s_util.GetTarget(wanjia)
	local player = GetClientPlayer()
	local distance = s_util.GetDistance(player,wanjia)
	if not bol and target then
		if SkillID == dwSkillID and distance<=Dis and target.dwID==player.dwID then
			return true
		else
			return false
		end
	end
	if bol then
		if SkillID == dwSkillID and distance<=Dis then
			return true
		else
			return false
		end
	end
end

local tForceTitle = {
	[0] = "侠",
	[7] = "唐",
	[1] = "秃",
	[2] = "花",
	[4] = "咩",
	[8] = "叽",
	[9] = "丐",
	[5] = "秀",
	[10] = "喵",
	[22] = "歌",
	[3] = "策",
	[6] = "毒",
	[23] = "霸",
	[21] = "苍",
}
local tPlayerForce = {}
local tPlayer = {}

-- 获取玩家门派名称
local GetForceTitle = function(playerObject)
	local dwID = playerObject.dwID
	local nForce = playerObject.dwForceID
	if tPlayerForce[dwID] and tPlayerForce[dwID] > 0 then
		return tForceTitle[tPlayerForce[dwID]]
	end
	if nForce > 0 and tForceTitle[nForce] then
		tPlayerForce[dwID] = nForce
		return tForceTitle[nForce]
	end
	return tForceTitle[0]
end

------------------------------------------------插件表，设置插件信息和回调函数------------------------------------------------
local tPlugin = {
--插件在菜单中显示的名字。必须设置
["szName"] = szPluginName,

--插件类型。  1(5人副本)， 2(10人副本)， 3(25人副本)，4(竞技场)，5(其他)。必须设置
["nType"] = 5,

--绑定地图，单个地图设置为地图ID，多个地图，设置为表。可以不设置，在游戏中手动开启
["dwMapID"] = {296, 297},

--初始化函数，启用插件会调用
["OnInit"] = function()
	local me = GetClientPlayer()
	if not me then return false end
	s_util.OutputSysMsg("插件 "..szPluginName.." 已启用")
	s_util.OutputSysMsg("欢迎 "..me.szName.." 使用本插件")
	g_MacroVars.chijizhushou_WeiZhuangID = nil
	local menuisaction = false
	--判断菜单是否已加载
	for i,v in ipairs(TraceButton_GetAddonMenu()) do
		if type(v)=="table" then
			if v.szOption and v.szOption == "吃鸡助手工具" then
				menuisaction = true
				break
			end
		end
	end
	if not menuisaction then
		TraceButton_AppendAddonMenu({chijimenu})
	end
	return true
end,

["OnTick"] = function()
	Minimap.bSearchRedName = true			--打开小地图红名
	local nFrame, me = GetLogicFrameCount(), GetClientPlayer()
	if not me or (nFrame % 4) ~= 0 then return end
	for i,v in ipairs(GetAllPlayer()) do		--遍历
		if v and v.dwID ~= me.dwID then			--如果有玩家，不是我
			local dwForceTitle = GetForceTitle(v)
			if IsEnemy(me.dwID, v.dwID) and v.nMoveState ~= MOVE_STATE.ON_DEATH then	--如果是敌人
				local hpRatio, _ = math.modf(100 * v.nCurrentLife / v.nMaxLife)
				s_util.AddText(TARGET.PLAYER, v.dwID, 255, 0, 0, 200, dwForceTitle..hpRatio.."·", 1.3, true)
			end
		end
	end
	if g_MacroVars.chijizhushou_gouxuan then
		s_util.OutputSysMsg("已勾选") 
	end
end,

--Doodad进入场景，1个参数：DoodadID
["OnDoodadEnter"] = function(dwID)
	local doodad = GetDoodad(dwID)
	local me = GetClientPlayer()
	local WeiZhuangID = g_MacroVars.chijizhushou_WeiZhuangID
	if doodad then 
		if tTempID[doodad.dwTemplateID] then
			local t = tColor[tTempID[doodad.dwTemplateID]]
			if t then
				local r, g, b, s = unpack(t)
				--在游戏对象脚下添加文本
				s_util.AddText(TARGET.DOODAD, doodad.dwID, r, g, b, 255, doodad.szName, s, true)--对象类型，对象ID, 红，绿，蓝，透明度，文本，文字大小缩放，是否显示距离
			end
		end
		--将丢弃的装备记录为最小ID，大于此ID的判定为伪装
		if not WeiZhuangID and doodad.dwTemplateID >= 6949 and doodad.dwTemplateID <= 6954 then
			g_MacroVars.chijizhushou_WeiZhuangID, WeiZhuangID = doodad.dwID, doodad.dwID
		end
		--伪装标记黄圈
		if doodad.dwTemplateID >= 6857 and doodad.dwTemplateID <= 6859 and WeiZhuangID and doodad.dwID > WeiZhuangID then
			s_util.AddShape(TARGET.DOODAD, doodad.dwID, 255, 255, 0, 100, 360, 2)
		end
	end
end,

--Doodad离开场景，1个参数：DoodadID
["OnDoodadLeave"] = function(dwID)
end,

--玩家进入场景，1个参数：玩家ID 
["OnPlayerEnter"] = function(dwID)
end,

--玩家离开场景，1个参数：玩家ID
["OnPlayerLeave"] = function(dwID)
end,

--施放技能调用， 参数：对象ID， 技能ID， 技能等级
["OnCastSkill"] = function(dwID, dwSkillID, dwLevel)
	local player = GetClientPlayer()
	local target, targetClass = s_util.GetTarget(player)
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

--有聊天信息会调用，参数： 对象ID，内容，名字，频道
["OnTalk"] = function(dwID, szText, szName, nChannel)
end,

["OnDebug"] = function()
end,
}

--向插件管理系统返回定义的表
return tPlugin
