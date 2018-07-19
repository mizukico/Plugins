--插件名字
local szPluginName = "技能监控插件v0.1.2"

--------------------------插件数据（非自定义）--------------------------
local SkillList = {
	[10002] = {},	--洗髓
	[10003] = {},	--易筋
	[10014] = {},	--紫霞
	[10015] = {},	--太虚
	[10021] = {},	--花间
	[10026] = {},	--傲血
	[10028] = {},	--离经
	[10062] = {},	--铁牢
	[10080] = {},	--云裳
	[10081] = {},	--冰心
	[10144] = {},	--问水
	[10145] = {},	--山居
	[10175] = {},	--毒经
	[10176] = {},	--补天
	[10224] = {},	--惊羽
	[10225] = {},	--天罗
	[10242] = {},	--焚影
	[10243] = {},	--明尊
	[10268] = {},	--笑尘
	[10389] = {},	--铁骨
	[10390] = {},	--分山
	[10447] = {},	--莫问
	[10448] = {},	--相知
	[10464] = {},	--北傲
}
local Cache_Skill = {[1] = {}}
local Cache_Caster = {[1]="N"}
local PlayerList = {}


--------------------------用户数据（自定义）--------------------------
SkillList[10026] = {	--10026 傲血
	--[技能名] = {技能类型(普通技能为1,充能技能为充能次数,透支技能为透支次数的负数), 单次技能CD}
	["守如山"] = {dwType = 1, dwCDTime = 120},
	["疾如风"] = {dwType = 1, dwCDTime = 50},
	["任驰骋"] = {dwType = 1, dwCDTime = 45},
	["御"] = {dwType = 1, dwCDTime = 20},
	["战八方"] = {dwType = 1, dwCDTime = 6}
}
SkillList[10081] = {	--10081 冰心
	--[技能名] = {技能类型(普通技能为1,充能技能为充能次数,透支技能为透支次数的负数), 单次技能CD}
	
}

--------------------------函数声明--------------------------
local function OnCastSkill(dwCaster,dwSkillID,dwLevel)
	--s_Output(dwCaster,dwSkillID,dwLevel)
	local isPlayer 
	--判断释放者是否是为玩家，判断结果放入Cache_Caster，以后都从缓存读取
	if Cache_Caster[dwCaster] == "P" then
		isPlayer = true
	elseif Cache_Caster[dwCaster] == "N" then
		isPlayer = false
	else 
		isPlayer = IsPlayer(dwCaster)
		Cache_Caster[dwCaster] = isPlayer and "P" or "N"
	end
	--如果不是玩家就直接返回
	if not isPlayer then return end
	--如果是玩家并且PlayerList未记录，则初始化一次，放入PlayerList
	if not PlayerList[dwCaster] then
		local castPlayer = GetPlayer(dwCaster)
		PlayerList[dwCaster] = {}
		PlayerList[dwCaster].szName = castPlayer.szName
		PlayerList[dwCaster].dwKungFu = castPlayer.GetKungfuMount().dwSkillID
		PlayerList[dwCaster].tSkill = {}
		outputTable(PlayerList)
	end
	local kungFu = PlayerList[dwCaster].dwKungFu
	local skillName
	--获取技能的名字，放入Cache_Skill，以后都从缓存读取
	if not Cache_Skill[dwSkillID] then
		skillName = Table_GetSkillName(dwSkillID,dwLevel)
		Cache_Skill[dwSkillID]={}
		Cache_Skill[dwSkillID].szSkillName = skillName
		--判断技能是否是需要记录的，是则获取技能的图标放入Cache_Skill，否则返回
		if SkillList[kungFu][skillName] then
			Cache_Skill[dwSkillID].dwIconID = Table_GetSkillIconID(dwSkillID,dwLevel)
		else
			return
		end
	else
		skillName = Cache_Skill[dwSkillID].szSkillName
		--判断技能是否是需要记录的，否则返回
		if not SkillList[kungFu][skillName] then
			return
		end
	end
	local frameCount = GetLogicFrameCount()
	local skillType = SkillList[kungFu][skillName].dwType
	if skillType == 1 then	--普通技能
		--将当前帧计数保存到该角色该技能的释放帧中
		if not PlayerList[dwCaster].tSkill[skillName] then PlayerList[dwCaster].tSkill[skillName] = {} end
		PlayerList[dwCaster].tSkill[skillName].dwCastframeCount = frameCount
		s_Output(frameCount..":["..PlayerList[dwCaster].szName.."]cast["..skillName.."]")
	elseif skillType > 1 then	--充能技能（待实现）
	
	elseif skillType < 0 then	--透支技能（待实现）
	
	else	--0其他（待实现）
	
	end
end
local function RefreshCD(dwFrm)
	local skillCDMsg = ""
	for dwCastID,tCastInfo in pairs(PlayerList) do
		for szSkillName,tSkillInfo in pairs(PlayerList[dwCastID].tSkill) do
			local dwSkillCD = SkillList[PlayerList[dwCastID].dwKungFu][szSkillName].dwCDTime - (dwFrm - tSkillInfo.dwCastframeCount)/16
			if dwSkillCD < 0 then 
				dwSkillCD = 0 
			else
				dwSkillCD = string.format("%.1f",dwSkillCD)
				skillCDMsg = skillCDMsg.."["..szSkillName.."]="..dwSkillCD.."s;"
			end
		end
		if string.len(skillCDMsg) > 1 then
			skillCDMsg = "["..PlayerList[dwCastID].szName.."]:"..skillCDMsg
			skillCDMsg = skillCDMsg.."\n"
		end
	end
	if string.len(skillCDMsg) > 1 then
		s_Output(skillCDMsg)
		s_util.OutputTip(skillCDMsg)
		s_util.OutputSysMsg(skillCDMsg)
	end
	
end
local function UpdateCDData()--将CD数据上传至UI（待实现）

end
------------------------------------------------插件表，设置插件信息和回调函数------------------------------------------------
local tPlugin = {
--插件在菜单中显示的名字。必须设置
["szName"] = szPluginName,

--插件类型。  1(5人副本)， 2(10人副本)， 3(25人副本)，4(竞技场)，5(其他)。必须设置
["nType"] = 4,

--绑定的地图ID。进入对应地图自动启用。这个是可选的，注意不要重复。如果没有设置，也可以在游戏中手动开启插件
["dwMapID"] = 0,

--初始化函数，启用插件会调用。没有参数。返回一个bool值，指示插件是否初始化成功。如果返回false，插件不会启用。可以在这里检查插件使用的必要条件（比如地图ID对不对之类的）
["OnInit"] = function()
	local player = GetClientPlayer()
	s_util.OutputSysMsg("插件 "..szPluginName.." 已启用")
	s_util.OutputSysMsg("欢迎 "..player.szName.." 使用本插件")
	s_util.OutputSysMsg("插件作者：(°—°〃)")
	s_util.OutputSysMsg("目前只实现普通技能监控，测试用")
	return true
end,

--每帧都会调用（1秒16帧)。没有参数。由于调用频繁，如果实现复杂，对性能有一定影响。
["OnTick"] = function()
	local dwFrm = GetLogicFrameCount()
	if dwFrm % 16 == 0 then	--每秒16帧，可以自定义
		RefreshCD(dwFrm)
		--UpdateCDData()
	end
end,

--有警告信息会调用，参数：类型，内容
["OnWarning"] = function(szType, szText)
	s_Output("OnWarning: "..szText)
end,

--有聊天信息会调用，参数： 对象ID，内容，名字，频道
["OnTalk"] = function(dwID, szText, szName, nChannel)
	
end,

--施放技能调用， 参数：对象ID， 技能ID， 技能等级
["OnCastSkill"] = function(dwID, dwSkillID, dwLevel)
	OnCastSkill(dwID,dwSkillID,dwLevel)
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
