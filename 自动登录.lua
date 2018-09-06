local szPluginName = "自动登录"

Plugins_AutoLogin = {}

Plugins_AutoLogin.frame = Station.Lookup("Normal/LoginPassword")
--Plugins_AutoLogin.frame.OnFrameBreathe = function()
--	s_Output("登录界面呼吸")
--end

if Plugins_AutoLogin.frame then
	local frame = Station.Lookup("Normal/LoginPassword/WndPassword")
	--frame:Lookup("Wnd_PasswordContent/Edit_Account"):SetText("mizukicoen")
	frame:Lookup("Wnd_PasswordContent/Edit_Password"):SetText("mizuki1980")
	--local btn = Station.Lookup("Normal/LoginPassword/WndPassword/Wnd_PasswordContent/Btn_OK")
	--local btn = Station.Lookup("Normal/LoginServerPanel/Wnd_ServerPanel/Btn_ChangeServer")
	--s_Output(type(btn))
	--s_util.UICall(btn, LoginServerPanel.OnLButtonClick)
	--local btn1 = Station.Lookup("Topmost/LoginServerList/Wnd_Button/Btn_Ok")
	--s_util.UICall(btn1, LoginServerList.OnLButtonClick)
	--Login.RequestLogin(g_tGlue.tLoginString["CONNECTING"], true)
	--Login.BeginWait(g_tGlue.tLoginString["ENTERING_GAME"])
end

----------------------------------插件表，设置插件信息和回调函数--------------------------------------
local tPlugin = {
--插件在菜单中显示的名字。必须设置
["szName"] = szPluginName,

--插件类型。  1(5人副本)， 2(10人副本)， 3(25人副本)，4(竞技场)，5(其他)。必须设置
["nType"] = 5,

--绑定地图，单个地图设置为地图ID，多个地图，设置为表。可以不设置，在游戏中手动开启
["dwMapID"] = 0,

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
end,

["OnDebug"] = function()
end,
}

--向插件管理系统返回定义的表
return tPlugin
