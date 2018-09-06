local szPluginName = "浩气明教攻防前置插件"

--大轻功函数
--明教大轻功函数CatFlyTo (x, y, z, h, pass)
--参数：目的地X坐标,目的地Y坐标,目的地Z坐标,飞行高度Z坐标(缺省为Z坐标+10000),是否为路径点(用于调整路线规避障碍，经过时不会下降高度)
--返回：到达目的地坐标后返回true
function CatFlyTo (x, y, z ,h ,pass)
	if not h or type(h) == "boolean" then h, pass = (z+10000), h end
	local player = GetClientPlayer()
	s_util.TurnTo(x, y, z)
	if pass then 
		if	math.abs(player.nX-x)<1200 and math.abs(player.nY-y)<1200 then return true end
	end
	if math.abs(player.nX-x)<32 and math.abs(player.nY-y)<32 and math.abs(player.nZ-z)<32 then return true end
	if math.abs(player.nX-x)<1000 and math.abs(player.nY-y)<1000 then
		if math.abs(player.nZ-z)<1000 then
			s_cmd.MoveTo(x, y, z)
			return
		end
		if math.abs(player.nX-x)<360 and math.abs(player.nY-y)<360 and math.abs(player.nZ-z)<1000 then
			if player.nMoveState == 4 or player.nMoveState == 25 then
				player.PitchTo(-64)
			else
				s_cmd.MoveTo(x, y, z)
				return
			end
		else
			player.PitchTo(-44)
		end
	else
		if player.nZ < h then
			player.PitchTo(64)
		else
			player.PitchTo(0)
		end
	end
	if player.nMoveState ~= 25 and player.nSprintPower > 5 then
		StartSprint()
		Jump()
	else
		if s_util.Cast(9003, false) then return end
		if s_util.Cast(9005, false) then return end
		if s_util.Cast(9006, false) then return end
		if s_util.Cast(9004, false) then return end
	end
end
----------------------------------插件表，设置插件信息和回调函数--------------------------------------
local tPlugin = {
--插件在菜单中显示的名字。必须设置
["szName"] = szPluginName,

--插件类型。  1(5人副本)， 2(10人副本)， 3(25人副本)，4(竞技场)，5(其他)。必须设置
["nType"] = 5,

--绑定地图，单个地图设置为地图ID，多个地图，设置为表。可以不设置，在游戏中手动开启
["dwMapID"] ={22, 30},

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
local nFrame, me = GetLogicFrameCount(), GetClientPlayer()
if not me.IsInParty() or (nFrame % 4) ~= 0 then return end  --每秒处理4次

if GetClientTeam().GetAuthorityInfo(TEAM_AUTHORITY_TYPE.LEADER) == me.dwID then
	--ConvertToRaid() --转换为团队
	for k, v in ipairs(GetClientTeam().GetTeamMemberList()) do
		if v ~= me.dwID then
			GetClientTeam().SetAuthorityInfo(TEAM_AUTHORITY_TYPE.LEADER, v) --移交队长，省的组人
			break
		end
	end
end
--GetClientTeam().RespondTeamApply(arg0, 1)--同意组队
--GetClientTeam().RespondTeamApply(arg0, 0)--拒绝组队
if not g_MacroVars.QianzhiTeam then 
	GetClientTeam().RequestLeaveTeam()
end
end,

--Doodad进入场景，1个参数：DoodadID
["OnDoodadEnter"] = function(dwID)
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
["OnCastSkill"] = function(dwID, dwSkillID, dwLevel, targetClass, tidOrx, y, z)
end,

--有聊天信息会调用，参数： 对象ID，内容，名字，频道
["OnTalk"] = function(dwID, szText, szName, nChannel)
if string.find(szText, "深入虎穴") and g_MacroVars.QianzhiTeam == 1 then
	player = GetPlayer(dwID)
	if player then
		GetClientTeam().InviteJoinTeam(player.szName) 
		g_MacroVars.QianzhiTeam = 0
	end
end
if string.find(szText, "四处出击") and g_MacroVars.QianzhiTeam == 2 then
	player = GetPlayer(dwID)
	if player then
		GetClientTeam().InviteJoinTeam(player.szName) 
		g_MacroVars.QianzhiTeam = 0
	end
end
end,

["OnDebug"] = function()
end,
}

--向插件管理系统返回定义的表
return tPlugin
