--插件名字
local szPluginName = "单刷防脱战"

--存放boss信息
local tBossID = {}

local UpdatePrepare = function(obj, tData)
	local bPrepare, dwSkillId, dwLevel, nProgress, nActionState =  GetSkillOTActionState(obj)
	if bPrepare then
		if not tData.bPrepare then		--如果上次不是读条状态
			local skillName = Table_GetSkillName(skillID, level)
			s_Output(obj.szName.." 开始读条: "..skillName..", 技能ID: "..skillID..", 技能等级: "..level..", 读条百分比: "..nProgress)
		end
		tData.bPrepare = true
	else
		tData.bPrepare = false
	end
end


------------------------------------------------插件表，设置插件信息和回调函数------------------------------------------------
local tPlugin = {
--插件在菜单中显示的名字。必须设置
["szName"] = szPluginName,

--插件类型。  1(5人副本)， 2(10人副本)， 3(25人副本)，4(竞技场)，5(其他)。必须设置
["nType"] = 5,

--绑定的地图ID。进入对应地图自动启用。这个是可选的，注意不要重复。如果没有设置，也可以在游戏中手动开启插件
["dwMapID"] = 0,

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
	if dwSkillID = 2645
end,

--NPC进入场景会调用，参数：NPCID
["OnNpcEnter"] = function(dwID)
end,

--NPC离开场景会调用，参数：NPCID。这里不要再获取对象，应该执行和这个ID有关的一些清理工作。
["OnNpcLeave"] = function(dwID)
end,

--菜单点击调试当前插件会调用，可以在这里输出一些调试信息
["OnDebug"] = function()
	s_Output(Marco_StarPointX)
	s_Output(Marco_StarPointY)
end,
}


--向插件管理系统返回定义的表
return tPlugin
