local szPluginName = "技能测试"

--自己的角色ID
local meID = 0


local tPlugin = {
--插件在菜单中显示的名字。必须设置
["szName"] = szPluginName,

--插件类型。  1(5人副本)， 2(10人副本)， 3(25人副本)，4(竞技场)，5(其他)。必须设置
["nType"] = 5,

--初始化函数，启用插件会调用
["OnInit"] = function()
local player = GetClientPlayer()
if not player then return false end

meID = player.dwID	--记录自己的角色ID

s_util.OutputSysMsg("插件 "..szPluginName.." 已启用")
s_util.OutputSysMsg("欢迎 "..player.szName.." 使用本插件")
s_util.OutputSysMsg("插件作者：xxxx")
return true
end,

--开始读条，参数：释放技能的角色ID（玩家或者NPC），技能ID，技能等级，剩余帧数，目标类型，目标ID或者x，y，z
["OnSkillPrepare"] = function(dwID, dwSkillID, dwLevel, nLeftFrame, targetClass, tidOrx, y, z)
if dwID == meID then
s_Output("开始读条", dwID, dwSkillID, dwLevel, nLeftFrame, targetClass, tidOrx, y, z)
end
end,

--释放技能，参数：释放技能的角色ID（玩家或者NPC），技能ID，技能等级，目标类型，目标ID或者x，y，z
--这个回调函数也包括子技能，所以会很频繁的调用，注意下性能问题，如果不加条件找人少的地方测试
--可以精确判定通道技能（比如玳弦急曲）释放到第几段，因为它每段都是另外的技能（开始通道技能计数置0，每释放一段，计数+1），这个可能PVE有点用，可以精确打断
--也可以判断技能前摇，某些技能从释放到产生效果，有几十毫秒的间隔
["OnSkillCast"] = function(dwID, dwSkillID, dwLevel, targetClass, tidOrx, y, z)
--
if dwID == meID and not IsCommonSkill(dwSkillID) then
local szSkillName = Table_GetSkillName(dwSkillID, dwLevel)
if szSkillName and szSkillName ~= "" then
s_Output("服务端释放技能", szSkillName, dwID, dwSkillID, dwLevel, targetClass, tidOrx, y, z)
end
end
--]]
end,

--开始蓄力技能，参数：释放技能的角色ID（玩家或者NPC），技能ID，技能等级，目标类型，目标ID或者x，y，z
["OnStartHoardSkill"] = function(dwID, dwSkillID, dwLevel, targetClass, tidOrx, y, z)
--s_Output("OnStartHoardSkill", dwID, dwSkillID, dwLevel, targetClass, tidOrx, y, z)
end,

--开始通道技能（就是倒着读条的技能），参数：释放技能的角色ID（玩家或者NPC），技能ID，技能等级，剩余帧数，目标类型，目标ID或者x，y，z
["OnSkillChannel"] = function(dwID, dwSkillID, dwLevel, nLeftFrame, targetClass, tidOrx, y, z)
if dwID == meID then
s_Output("通道技能", dwID, dwSkillID, dwLevel, nLeftFrame, targetClass, tidOrx, y, z)
end
end,

--服务端技能错误，参数：文本，代码
["OnSkillError"] = function(text, code)
s_Output("服务端施放技能失败 "..tostring(text).." ,代码 "..tostring(code))
end,

--自己buff更新，参数：是否移除(true是移除，false是添加)，是否能取消，buffID，等级，层数，结束帧，造成这个buff的对象ID
["OnMyBuff"] = function(bDelete, bCanCancel, dwBuffID, nLevel, nStackNum, nEndframe, dwSkillSrcID)
--[[
if bDelete then return end	--如果是移除不处理
local buffName = Table_GetBuffName(dwBuffID, nLevel)
if buffName and buffName ~= "" then
s_Output("自己添加Buff: "..buffName..", ID: "..dwBuffID..", 等级: "..nLevel..", 层数: "..nStackNum..", 剩余时间(秒): "..((nEndframe - GetLogicFrameCount()) / 16)..", 源ID: "..dwSkillSrcID)
end
--]]
end,

["OnTick"] = function()
end,

}

--向插件管理系统返回定义的表
return tPlugin