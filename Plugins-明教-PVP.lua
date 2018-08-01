--插件名字
local szPluginName = "明教-PVP"

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
------------------------------------------------插件表，设置插件信息和回调函数------------------------------------------------
local tPlugin = {
--插件在菜单中显示的名字。必须设置
["szName"] = szPluginName,

--插件类型。  1(5人副本)， 2(10人副本)， 3(25人副本)，4(竞技场)，5(其他)。必须设置
["nType"] = 5,

--绑定的地图ID。进入对应地图自动启用。这个是可选的，注意不要重复。如果没有设置，也可以在游戏中手动开启插件
["dwMapID"] =0,

--初始化函数，启用插件会调用。没有参数。返回一个bool值，指示插件是否初始化成功。如果返回false，插件不会启用。可以在这里检查插件使用的必要条件（比如地图ID对不对之类的）
["OnInit"] = function()
	local player = GetClientPlayer()
	s_util.OutputSysMsg("插件 "..szPluginName.." 已启用")
	s_util.OutputSysMsg("欢迎 "..player.szName.." 使用本插件")
	s_util.OutputSysMsg("插件作者：喵喵喵")
	return true
end,

--每帧都会调用（1秒16帧)。没有参数。由于调用频繁，如果实现复杂，对性能有一定影响。
["OnTick"] = function()
end,

--有警告信息会调用，参数：类型，内容
["OnWarning"] = function(szType, szText)
end,

--有聊天信息会调用，参数： 对象ID，内容，名字，频道
["OnTalk"] = function(dwID, szText, szName, nChannel)
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

--NPC进入场景会调用，参数：NPCID
["OnNpcEnter"] = function(dwID)
end,

--NPC离开场景会调用，参数：NPCID。这里不要再获取对象，应该执行和这个ID有关的一些清理工作。
["OnNpcLeave"] = function(dwID)
end,

--菜单点击调试当前插件会调用，可以在这里输出一些调试信息
["OnDebug"] = function()
end,
}


--向插件管理系统返回定义的表
return tPlugin
