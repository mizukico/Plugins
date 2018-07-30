--插件名字
local szPluginName = "刀轮海厅"

--不需要关注的NPC，用于过滤信息，省得无用信息太多
local tNotCareNpc = {
------------------------这部分是通用的------------------------
[4976] = "气场生太极",
[4977] = "气场破苍穹",
[4980] = "气场碎星辰",
[4982] = "气场镇山河",
[4981] = "气场吞日月",
[3080] = "气场化三清",
[57807] = "气场行天道",
[58294] = "气场剑出鸿蒙",
[16174] = "千机变底座",
[16175] = "千机变连弩",
[16176] = "千机变重弩",
[16177] = "千机变毒煞",
[9997] = "天蛛",
[9956] = "圣蝎",
[9996] = "风蜈",
[9998] = "灵蛇",
[9999] = "玉蟾",
[12944] = "碧蝶",

------------------------每个副本不同------------------------

}

--存放boss信息
local tBossID = {}

local UpdateBuffs = function(obj, tData)
	local tBuffInfo = s_util.GetBuffInfo(obj)
	for k,v in pairs(tBuffInfo) do
		if v.dwSkillSrcID == obj.dwID then			--如果是boss自己的buff
			--如果新添加的，输出消息
			if not tData.tBuff[k] then
				local buffName = Table_GetBuffName(v.dwID, v.nLevel)
				s_Output(obj.szName.." 添加Buff: "..buffName..", BuffID: "..v.dwID..", 剩余时间(秒): "..v.nLeftTime..", 等级:"..v.nLevel..", 层数:"..v.nStackNum)
			end
		end
	end
	tData.tBuff = tBuffInfo			--记录这次的buff表
end

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
["nType"] = 1,

--绑定的地图ID。进入对应地图自动启用。这个是可选的，注意不要重复。如果没有设置，也可以在游戏中手动开启插件
["dwMapID"] = 262,

--初始化函数，启用插件会调用。没有参数。返回一个bool值，指示插件是否初始化成功。如果返回false，插件不会启用。可以在这里检查插件使用的必要条件（比如地图ID对不对之类的）
["OnInit"] = function()
	local player = GetClientPlayer()
	s_util.OutputSysMsg("插件 "..szPluginName.." 已启用")
	s_util.OutputSysMsg("欢迎 "..player.szName.." 使用本插件")
	s_util.OutputSysMsg("插件作者：xxx")
	return true
end,

--每帧都会调用（1秒16帧)。没有参数。由于调用频繁，如果实现复杂，对性能有一定影响。
["OnTick"] = function()
	--记录boss的buff和读条
	for k,v in pairs(tBossID) do
		local boss = GetNpc(k)
		if boss then
			UpdateBuffs(boss, v)			--更新buff信息
			UpdatePrepare(boss, v)			--更新读条数据
		end
	end
	--倒计时
end,

--有警告信息会调用，参数：类型，内容
["OnWarning"] = function(szType, szText)
	s_Output("OnWarning: "..szText)
end,

--有聊天信息会调用，参数： 对象ID，内容，名字，频道
["OnTalk"] = function(dwID, szText, szName, nChannel)
	--if IsPlayer(dwID) then return end									--过滤掉玩家的聊天信息
	if tBossID[dwID] then				--只输出Boss说的话
		s_Output("OnTalk: "..szName.." 说 "..szText..", 频道: "..nChannel)
	end
end,

--施放技能调用， 参数：对象ID， 技能ID， 技能等级
["OnCastSkill"] = function(dwID, dwSkillID, dwLevel)
	--if IsPlayer(dwID) then return end				--过滤掉玩家
	local tData = tBossID[dwID]
	if tData then									--只输出Boss
		local boss = GetNpc(dwID)
		if boss then
			if not tData.tSkill[dwSkillID] then tData.tSkill[dwSkillID] = {} end
			local tSkillData = tData.tSkill[dwSkillID]
			local lastCastTime = tSkillData.lastCastTime or 0				--上次释放时间
			local currTime = GetTickCount()							--当前时间（毫秒）
			local skillName = Table_GetSkillName(dwSkillID, dwLevel)
			s_Output("OnCastSkill: "..boss.szName.." 施放技能: "..skillName..", ID: "..dwSkillID..", 等级: "..dwLevel..", 当前时间: "..currTime..", 和上次间隔: "..(currTime - lastCastTime))
			tSkillData.lastCastTime = currTime			--记录施放时间
		end
	end
end,

--NPC进入场景会调用，参数：NPCID
["OnNpcEnter"] = function(dwID)
	local npc = GetNpc(dwID)
	if npc then
		if GetNpcIntensity(npc) == 4 then			--如果是boss
			if not tBossID[dwID] then
				tBossID[dwID] = { tBuff = {}, tSkill = {} }			--boss数据插入表
			end
		end
		local dwTempID = npc.dwTemplateID
		if tNotCareNpc[dwTempID] then return end		--过滤掉不关注的NPC出现信息
		s_Output("OnNpcEnter: ".."名字: "..npc.szName..", 模板ID: "..dwTempID..", 对象ID: "..dwID)
	end
end,

--NPC离开场景会调用，参数：NPCID。这里不要再获取对象，应该执行和这个ID有关的一些清理工作。
["OnNpcLeave"] = function(dwID)
	tBossID[dwID] = nil
end,

--菜单点击调试当前插件会调用，可以在这里输出一些调试信息
["OnDebug"] = function()
	s_Output(szPluginName.." OnDebug 被调用")
end,
}


--向插件管理系统返回定义的表
return tPlugin
