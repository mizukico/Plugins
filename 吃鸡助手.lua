--更新UI样式，增加了装分显示，橙装判定和队伍标识，右键点击血条增加队伍标记选项。
--脚底文字增加队友标识，颜色为蓝色，与头顶文字同色
--脚底文字删除血量标识，替换为队伍标识。
--装分显示：装分高于自己的敌人，其名字及装分会标为紫色，脚底文字颜色同样变化
--橙装判定：有橙装的敌人，其名字及装分会标位橙色，脚底文字颜色同样变化
--队伍标识：点选目标后，根据目标的增益buff判断是否有队友，有队友就进行队伍编号标记，暂时无法判定的标记为“？”
--队伍标记：右键点击目标列表血条，会弹出队伍标记选项，点选后将对所选目标的队伍成员从剑开始依次标记。还未判定队伍的敌人就只单独标记一人

local szPluginName = "吃鸡助手1.6" 

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

local tForceTitle = {
	[0] = {"侠", 0,},
	[7] = {"唐", 7,},
	[1] = {"秃", 1,},
	[2] = {"花", 2,},
	[4] = {"咩", 4,},
	[8] = {"叽", 8,},
	[9] = {"丐", 9,},
	[5] = {"秀", 5,},
	[10] = {"喵", 10,},
	[22] = {"歌", 22,},
	[3] = {"策", 3,},
	[6] = {"毒", 6,},
	[23] = {"霸", 23,},
	[21] = {"苍", 21,},
	}

local KungfuList = {
	[10002] = {"洗", 10002,},
	[10003] = {"秃", 10003,},
	[10014] = {"气", 10014,},
	[10015] = {"剑", 10015,},
	[10021] = {"花", 10021,},
	[10028] = {"离", 10028,},
	[10026] = {"策", 10026,},
	[10062] = {"铁", 10062,},
	[10080] = {"云", 10080,},
	[10081] = {"冰", 10081,},
	[10144] = {"藏", 10144,},
	[10145] = {"藏", 10145,},
	[10175] = {"毒", 10175,},
	[10176] = {"补", 10176,},
	[10224] = {"鲸", 10224,},
	[10225] = {"螺", 10225,},
	[10242] = {"喵", 10242,},
	[10243] = {"尊", 10243,},
	[10389] = {"衣", 10389,},
	[10390] = {"苍", 10390,},
	[10447] = {"鸽", 10447,},
	[10448] = {"相", 10448,},
	[10464] = {"霸", 10464,},
	[10268] = {"丐", 10268,},
	}

--储存角色门派信息
local tPlayerForce = {}
--储存角色心法信息
local tPlayer = {}

local Party = {}

local teamnum = 0

-- 获取玩家心法门派名称
local function GetForceTitle (playerObject)
	local dwID = playerObject.dwID
	local nForce = playerObject.dwForceID
	local KungfuID = playerObject.dwMountKungfuID
	--优先返回内功心法
	if tPlayer[dwID] then
		return tPlayer[dwID][1], tPlayer[dwID][2], true
	end
	if KungfuID then
		if KungfuList[KungfuID] then
			tPlayer[dwID] = KungfuList[KungfuID]
			return tPlayer[dwID][1], tPlayer[dwID][2], true
		end
	else
		local kungfu = playerObject.GetKungfuMount()
		if kungfu and KungfuList[kungfu.dwSkillID] then
			tPlayer[dwID] = KungfuList[kungfu.dwSkillID]
			return tPlayer[dwID][1], tPlayer[dwID][2], true
		end
	end	
	--无内功显示门派
	if tPlayerForce[dwID] then
		return tPlayerForce[dwID][1], tPlayerForce[dwID][2], false
	end
	if nForce > 0 and tForceTitle[nForce] then
		tPlayerForce[dwID] = tForceTitle[nForce]
		return tPlayerForce[dwID][1], tPlayerForce[dwID][2], false
	end
	return tForceTitle[0][1], tForceTitle[0][2], false
end

--分配队伍函数
local function GetParty(ID1, ID2)
	local num = Party[ID1] or Party[ID2]
	if num then 
		Party[ID1], Party[ID2] = num , num
	else
		teamnum = teamnum + 1 
		Party[ID1], Party[ID2] = teamnum , teamnum
	end
end

local function UpdateSkill (ID,dwSkillID,SkillID,Dis)
	local wanjia = GetPlayer(ID)
	local target, targetClass = s_util.GetTarget(wanjia)
	local player = GetClientPlayer()
	local distance = s_util.GetDistance(player,wanjia)
	if SkillID == dwSkillID and distance<=Dis then
		return true
	else
		return false
	end
end
---------------------------------------↓目标列表插件↓-------------------------------------------
--目标列表插件参数表
if not Junefocus then
	Junefocus={
		y0n = true,			 			--窗口是否打开
		frame = nil,					--插件主窗口
		bShowFocus = true,				--是否显示列表
		frameSelf = nil,				
		frameTotal = nil,				
		frameList = nil,
		FocusList = {},					--目标列表
		IniFile = "interface\\SCD\\Junefocus.ini",		--界面ini文件路径
		Anchor={nX=500,nY=500},			--起始描点
	}
end

function Junefocus.OnFrameCreate()
	s_Output("界面创建")
end

function Junefocus.OnFrameBreathe()
	s_Output("界面呼吸")
end

function Junefocus.OnItemLButtonClick()
	s_Output("控件点击")
end

--开关窗口函数
function Junefocus.SwitchActive()
	if Junefocus.y0n then
		Junefocus.y0n=false
		Junefocus.frameSelf:Hide()
		Junefocus.ItemsTable = {}
		OutputMessage("MSG_SYS","目标列表 已关闭!\n")
	else
		Junefocus.y0n=true
		Junefocus.OpenPanel()
		OutputMessage("MSG_SYS","目标列表 已开启!\n")
	end
end

--开启面板，设置按键功能
function Junefocus.OpenPanel()
	local frame = Station.Lookup("Normal/Junefocus")
	if not frame then
		frame = Wnd.OpenWindow(Junefocus.IniFile, "Junefocus")
	end
	Junefocus.frameSelf = Station.Lookup("Normal/Junefocus")
	Junefocus.frameTotal = frame:Lookup("", "")
	Junefocus.frameList = Station.Lookup("Normal/Junefocus", "Handle_List")
	Junefocus.BtnSetting = frame:Lookup("Btn_Setting")
	Junefocus.BtnClose = frame:Lookup("Btn_Close")
	Junefocus.Minimize = frame:Lookup("CheckBox_Minimize")
	--齿轮键，弹出菜单
	Junefocus.BtnSetting.OnLButtonClick = function()
		PopupMenu(g_MacroVars.chijimenu)
	end
	--XX键，关闭UI界面
	Junefocus.BtnClose.OnLButtonClick = function()
		Junefocus.SwitchActive()
	end
	--最小化勾选，隐藏列表UI
	Junefocus.Minimize.OnCheckBoxCheck = function()
		Junefocus.bShowFocus = false
		Junefocus.frameList:Hide()
		Junefocus.frameSelf:SetSize(300, 32)
		Junefocus.frameTotal:SetSize(300, 32)
	end
	--最小化取消勾选，显示列表UI
	Junefocus.Minimize.OnCheckBoxUncheck = function()
		Junefocus.bShowFocus = true
		Junefocus.frameList:Show()
	end
	if Junefocus.y0n then
		frame:Show()
	else
		frame:Hide()
	end
	Junefocus.frameList:Clear()
end

--拖拽窗体函数
function Junefocus.OnFrameDragEnd()
	s_Output("界面拖拽")
	Junefocus.Anchor.nX, Junefocus.Anchor.nY = this:GetRelPos()
end

--将目标添加入目标列表
function Junefocus.addFocus(dwID)
	if not dwID then
		nType, dwID = GetClientPlayer().GetTarget()
	end
	local tar, tType=GetPlayer(dwID), TARGET.PLAYER
	if tar then
		--目标死亡移除记录
		if tar.nMoveState == MOVE_STATE.ON_DEATH then 
			Junefocus.RemoveFocus(dwID)
			return
		else
			local player = GetClientPlayer()
			local dis = s_util.GetDistance(player, tar)
			local szlife= tar.nCurrentLife/tar.nMaxLife
			local level --距离等级用于排序
			if dis < 20 then
				level = 1
			else
				level = 2
			end
			if not szlife then
				Junefocus.RemoveFocus(dwID)
				return
			end
			--插入列表末位，记录目标距离，目标ID，目标生命百分比,距离等级
			table.insert(Junefocus.FocusList, {[1]=dis, [2]=tar.dwID, [3]=szlife, [4]=level,})
		end
	end
end

--绘制列表handle（没有则添加创建）
function Junefocus.DrawFocus(dwID)
	local obj = GetPlayer(dwID)
	if obj then
		if obj.nMoveState == MOVE_STATE.ON_DEATH then
			Junefocus.RemoveFocus(dwID)
		else
			local szName = obj.szName
			if string.find(szName,"(.+)@(.+)") then
				szName=(string.gsub(szName, "(.+)%@(.+)", "%1"))
			end
			local nName = szName
			if #nName  > 8 then
				nName =string.sub(nName, 0, 8)
			end
			local weizhi = "未知"
			local dwType = TARGET.PLAYER
			local School1, School2, School3 = GetForceTitle(obj)
			local hList = Station.Lookup('Normal/Junefocus', 'Handle_List')
			local player = GetClientPlayer()
			local dis = math.floor(s_util.GetDistance(player, obj))
			if not (obj and hList) then
				return
			end
			--PeekOtherPlayer(obj.dwID) --获取玩家信息
			--添加Handle
			local hItem = Junefocus.GetHandle(dwID)
			if not hItem then
				hItem = hList:AppendItemFromIni(Junefocus.IniFile, 'Handle_Info')
				hItem:SetName('HI_'..dwID)
			end

			-- GPS定位
			-- 自身面向
			if player then
				hItem:Lookup('Handle_Compass'):Show()
				hItem:Lookup('Handle_Compass/Image_Player'):Show()
				hItem:Lookup('Handle_Compass/Image_Player'):SetRotate( - player.nFaceDirection / 128 * math.pi)
			end
			--目标相对位置
			local h = hItem:Lookup('Handle_Compass/Image_PointRed')
			hItem:Lookup('Handle_Compass/Image_PointRed'):Show()
			local nRotate = 0
			if player.nX == obj.nX then
				if player.nY > obj.nY then
					nRotate = math.pi / 2
				else
					nRotate = - math.pi / 2
				end
			else
				nRotate = math.atan((player.nY - obj.nY) / (player.nX - obj.nX))
			end
			if nRotate < 0 then
				nRotate = nRotate + math.pi
			end
			if obj.nY < player.nY then
				nRotate = math.pi + nRotate
			end
			local nRadius = 9.5
			h:SetRelPos((nRadius + nRadius * math.cos(nRotate)), (nRadius - nRadius * math.sin(nRotate))+1.5)
			hItem:Lookup('Handle_Compass'):FormatAllItemPos()
			
			--心法图标
			if School3 then
				hItem:Lookup('Image_School'):FromIconID(Table_GetSkillIconID(School2, 1))
			else
				hItem:Lookup('Image_School'):FromUITex(GetForceImage(School2))
			end
			
			-- 名字
			local hitname = hItem:Lookup("Text_Name")
			hitname:SetText(dis.."尺·"..(nName or weizhi))
			
			--队伍·装分
			local score = obj.GetTotalEquipScore()
			local dui = Party[obj.dwID] or "？"
			hItem:Lookup("Text_Score"):SetText("队"..dui.."·"..score)

			--血量百分比
			local nCurrentLife, nMaxLife = obj.nCurrentLife, obj.nMaxLife
			local szLife = ''
			if nMaxLife > 0 then
				local nPercent = math.floor(nCurrentLife / nMaxLife * 100)
				if nPercent > 100 then
					nPercent = 100
				end
				szLife = nPercent .. '%'
				hItem:Lookup("Image_Health"):SetPercentage(nCurrentLife/nMaxLife)
				hItem:Lookup("Text_Health"):SetText(szLife)
			end
			
			--标记
			hItem:Lookup('Handle_Mark'):Hide()
			local KTeam = GetClientTeam()
			if KTeam then
				local tMark = KTeam.GetTeamMark()
				if tMark then
					local nMarkID = tMark[dwID]
					if nMarkID then
						hItem:Lookup('Handle_Mark'):Show()
						hItem:Lookup('Handle_Mark/Image_Mark'):FromUITex(PARTY_MARK_ICON_PATH, PARTY_MARK_ICON_FRAME_LIST[nMarkID])
					end
				end
			end
			
			--选择目标按钮
			local nIndex
			for i, p in ipairs(Junefocus.FocusList) do
				if p[2] == dwID then
					nIndex = i
					break
				end
			end
			hItem:SetRelPos(0,(nIndex-1)*44)
			if nIndex <= 10 then
				btn = Junefocus.frameSelf:Lookup("Btn_C"..nIndex)
				btn.OnLButtonClick = function()
					SetTarget(4, Junefocus.FocusList[nIndex][2])
				end
				btn.OnRButtonClick = function()
					local menu = {
						szOption = "标记队伍",
						fnAction = function()
							local me = GetClientPlayer()
							local myteam = GetClientTeam()
							if myteam and myteam.GetAuthorityInfo(TEAM_AUTHORITY_TYPE.MARK) == me.dwID then
								if not Party[Junefocus.FocusList[nIndex][2]] then
									myteam.SetTeamMark(1, Junefocus.FocusList[nIndex][2])
								else
									local dui = Party[Junefocus.FocusList[nIndex][2]]
									local teamformark = {Junefocus.FocusList[nIndex][2],}
									for i, p in pairs(Party) do
										if p == dui then
											table.insert(teamformark, i)
										end
									end									
									for i, p in ipairs(teamformark) do
										if i <= 10 then
											myteam.SetTeamMark(i, p)
										else
											break
										end
									end
								end
							else 
								s_util.OutputSysMsg("你没有标记权限！") 
							end
						end,
					}
					PopupMenu({menu})
				end
				btn:Show()
			end
			
			--显示Handle
			hItem:Show()
			if dis > 30 then
				hItem:SetAlpha(200)
			end
			
			--装分标色
			local me = GetClientPlayer()
			if score > me.GetTotalEquipScore() then --装分超过我紫色
				hitname:SetFontColor(255,  45, 255)
				hItem:Lookup("Text_Score"):SetFontColor(255,  45, 255)
			end
			for i=0 ,12 do --橙装判定
				if GetPlayerItem(obj, INVENTORY_INDEX.EQUIP, i) and GetPlayerItem(obj, INVENTORY_INDEX.EQUIP, i).nQuality>4 then 
					hitname:SetFontColor(255, 165,   0)
					hItem:Lookup("Text_Score"):SetFontColor(255, 165,   0)
					break
				end
			end
		end
	end
	
	--调整窗口大小
	local nWidthNeed = 300
	local nHeightNeed 
	if #Junefocus.FocusList <= 10 then
		nHeightNeed = 44 * #Junefocus.FocusList + 32
	else 
		nHeightNeed = 472
	end
	Junefocus.frameSelf:SetSize(nWidthNeed, nHeightNeed)
	Junefocus.frameTotal:SetSize(nWidthNeed, nHeightNeed)
	Junefocus.frameList:SetSize(nWidthNeed, nHeightNeed-32)
	Junefocus.frameList:FormatAllItemPos()
end

--获取指定焦点的Handle 没有返回nil
function Junefocus.GetHandle(dwID)
	return Station.Lookup('Normal/Junefocus', 'Handle_List/HI_'..dwID)
end

--将目标移除焦点列表
function Junefocus.RemoveFocus(dwID)
	-- 从列表数据中删除
	local dwType = TARGET.PLAYER
	for i = #Junefocus.FocusList, 1, -1 do
		local p = Junefocus.FocusList[i]
		if p[2] == dwID then
			table.remove(Junefocus.FocusList, i)
			break
		end
	end
	-- 从UI中删除
	local hList = Station.Lookup('Normal/Junefocus', 'Handle_List')
	local szKey = 'HI_'..dwID
	local hItem = Station.Lookup('Normal/Junefocus', 'Handle_List/' .. szKey)
	if hItem then
		hList:RemoveItem(hItem)
	end
	hList:FormatAllItemPos()
end

function Junefocus.Sort(a, b)
	local r
	--距离等级
	local a4 = tonumber(a[4])
	local b4 = tonumber(b[4])
	--距离
	local a1 = tonumber(a[1])
	local b1 = tonumber(b[1])
	--血量百分比
	local a3 = tonumber(a[3])
	local b3 = tonumber(b[3])
	--排序优先级：1.距离等级由低到高，2.血量百分比由低到高，3.距离由低到高
	if a4 == 1 and b4 == 1 then
		if a3 == b3 then
			r = a1 < b1
		else
			r = a3 < b3
		end
	elseif a4 == 2 and b4 == 2 then
		r = a1 < b1
	elseif a4 ~= b4 then
		r = a4 < b4
	end
	return r
end

----------------------------------插件表，设置插件信息和回调函数--------------------------------------
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

	--重置伪装ID
	g_MacroVars.chijizhushou_WeiZhuangID = nil

	--扳手菜单
	if not g_MacroVars.chijimenu then
		g_MacroVars.chijimenu = {
		szOption = "吃鸡助手工具",
		{
		szOption = "快速标记",
		fnAction =function() 
			local me = GetClientPlayer()
			local myteam = GetClientTeam()
			if myteam and myteam.GetAuthorityInfo(TEAM_AUTHORITY_TYPE.MARK) == me.dwID then
				for i, p in ipairs(Junefocus.FocusList) do
					if i <= 10 then
						myteam.SetTeamMark(i, p[2])
					else
						break
					end
				end
			else 
				s_util.OutputSysMsg("你没有标记权限！") 
			end
		end,
		},
		{
		szOption = "开关目标列表",
		bCheck = true, 
		bChecked =function() return Junefocus.y0n end,
		fnAction =Junefocus.SwitchActive,
		},
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
	}
	end
	
	if not g_MacroVars.chijimenuisaction then
		TraceButton_AppendAddonMenu({g_MacroVars.chijimenu})
		g_MacroVars.chijimenuisaction = true
	end

	Junefocus.FocusList = {}
	Junefocus.SwitchActive()

	return true
end,

["OnTick"] = function()
	Minimap.bSearchRedName = true			--打开小地图红名
	local nFrame, me = GetLogicFrameCount(), GetClientPlayer()
	
	if not me or (nFrame % 4) ~= 0 then return end  --每秒处理4次
	
	if (nFrame % 16) == 0 then --列表排序每1S刷新
		Junefocus.FocusList = {}	--清空目标表格
		if Station.Lookup('Normal/Junefocus', 'Handle_List') then Station.Lookup('Normal/Junefocus', 'Handle_List'):Clear() end		--移除list所有控件
	end
	
	for i,v in ipairs(GetAllPlayer()) do			--遍历
		if v and v.dwID ~= me.dwID then				--如果有玩家，不是我
			local dis = s_util.GetDistance(me, v)
			if IsEnemy(me.dwID, v.dwID) and v.nMoveState ~= MOVE_STATE.ON_DEATH and dis < 300 then	--如果是敌人
				local dui = Party[v.dwID] or "？"	--队伍信息
				local score = v.GetTotalEquipScore()	--获取装分	
				if score == 0 or (nFrame % 80) == 0 then
					PeekOtherPlayer(v.dwID)					--拉取玩家面板信息
				end
				score = v.GetTotalEquipScore()	--获取装分	
				local sco = (math.floor(score/1000))/10	--装分取万
				local dwForceTitle = GetForceTitle(v)
				if score > me.GetTotalEquipScore() then 	--装分超过我紫色
					s_util.AddText(TARGET.PLAYER, v.dwID, 255, 45, 255, 200,sco.."W"..dwForceTitle.."·队"..dui.."·", 1.3, true)
				else 										--否则为红色
					s_util.AddText(TARGET.PLAYER, v.dwID, 255, 0, 0, 200, sco.."W"..dwForceTitle.."·队"..dui.."·", 1.3, true)
				end
				for i=0 ,12 do	--橙装判定
					if GetPlayerItem(v, INVENTORY_INDEX.EQUIP,i) and GetPlayerItem(v, INVENTORY_INDEX.EQUIP, i).nQuality>4 then 
						s_util.AddText(TARGET.PLAYER, v.dwID, 255, 165, 0, 200, sco.."W"..dwForceTitle.."·队"..dui.."·", 1.3, true)
						break
					end
				end
				if (nFrame % 16) == 0 then
					Junefocus.addFocus(v.dwID)	--写入目标列表
				end
			end
			if IsParty(me.dwID, v.dwID)	and v.nMoveState ~= MOVE_STATE.ON_DEATH then	--如果是队友标记蓝色
				local score = v.GetTotalEquipScore()	--获取装分	
				if score == 0 or (nFrame % 80) == 0 then
					PeekOtherPlayer(v.dwID)					--拉取玩家面板信息
				end
				score = v.GetTotalEquipScore()	--获取装分	
				local sco = (math.floor(score/1000))/10	--装分取万
				local dwForceTitle = GetForceTitle(v)
				s_util.AddText(TARGET.PLAYER, v.dwID, 0, 126, 255, 200, sco.."W"..dwForceTitle.."·队友·", 1.3, true)
			end
		end
	end
	
	if (nFrame % 16) == 0 then
		table.sort(Junefocus.FocusList, Junefocus.Sort)	--表格排序
	end
	
	--绘制handle
	if Junefocus.bShowFocus == false then
		Junefocus.frameList:Hide()
		Junefocus.frameSelf:SetSize(300, 32)
		Junefocus.frameTotal:SetSize(300, 32)
		Junefocus.frameList:SetSize(300, 32)
	else
		local me = GetClientPlayer()
		local tar = s_util.GetTarget(me)
		for i, p in ipairs(Junefocus.FocusList) do
			if i <= 10 then
				Junefocus.DrawFocus(p[2])
				if tar and p[2] == tar.dwID then
					local hItem = Junefocus.GetHandle(tar.dwID)
					if hItem then hItem:Lookup('Image_Select'):Show() end		--选中标示
				end
			else
				break
			end
		end
		if #Junefocus.FocusList then
			Station.Lookup("Normal/Junefocus", "Text_Title"):SetText("敌人："..#Junefocus.FocusList.."·装分："..me.GetTotalEquipScore())
		end
	end
	
	local tar, tarclass = s_util.GetTarget(me)	
	if tar and tarclass == 4 and IsEnemy(me.dwID, tar.dwID) then
		local ttar , ttarclass = s_util.GetTarget(tar)
		local tbuff = s_util.GetBuffInfo(tar)		
		if tbuff then
			for k, v in pairs(tbuff) do
				if v.bCanCancel and Table_BuffIsVisible(v.dwID, v.nLevel) then
					if v.dwSkillSrcID and v.dwSkillSrcID ~= 0 and v.dwSkillSrcID~= tar.dwID then
						GetParty(v.dwSkillSrcID, tar.dwID)
					end
				end
			end
		end
		if ttar and ttarclass == 4 and IsEnemy(me.dwID, ttar.dwID) then 
			local ttbuff = s_util.GetBuffInfo(ttar)
			if ttbuff then
				for k, v in pairs(ttbuff) do
					if v.bCanCancel and Table_BuffIsVisible(v.dwID, v.nLevel) then
						if v.dwSkillSrcID and v.dwSkillSrcID ~= 0 and v.dwSkillSrcID~= ttar.dwID then
							GetParty(v.dwSkillSrcID, ttar.dwID)
						end
					end
				end
			end
		end
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
	local me = GetClientPlayer()
	local player = GetPlayer(dwID)			--这返回的对象，只有ID之类的，名字等等都还没同步获取不到，和自己无关的人，也没法获取血量，返回都是255
	if player and player.dwID ~= me.dwID and IsEnemy(me.dwID, player.dwID) then			--如果有玩家，不是我，是敌人
		s_util.AddText(TARGET.PLAYER, player.dwID, 255, 0, 0, 200, "敌", 1.2, true)
	end
end,

--玩家离开场景，1个参数：玩家ID
["OnPlayerLeave"] = function(dwID)
	Junefocus.RemoveFocus(dwID)
end,

--施放技能调用， 参数：对象ID， 技能ID， 技能等级
["OnCastSkill"] = function(dwID, dwSkillID, dwLevel, targetClass, tidOrx, y, z)
	local player = GetClientPlayer()
	local target, targetClass = s_util.GetTarget(player)
	if not IsPlayer(dwID) or not IsEnemy(player.dwID,dwID) then return end	--过滤掉非敌对玩家
	if tidOrx == player.dwID then
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
		if UpdateSkill(dwID,dwSkillID,18629,12) or UpdateSkill(dwID,dwSkillID,2681,20) or UpdateSkill(dwID,dwSkillID,240,6) or UpdateSkill(dwID,dwSkillID,2645,20) then 
			s_util.SetTimer("tbaofa1")
			s_Output(Table_GetSkillName(dwSkillID, dwLevel))
		end
	end
	--梵音 20尺
	if UpdateSkill(dwID,dwSkillID,568,20) then
		s_util.SetTimer("tbaofa2")
		s_Output(Table_GetSkillName(dwSkillID, dwLevel))
	end
	--浮光掠影 30尺
	if UpdateSkill(dwID,dwSkillID,3112,30) then
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
	Junefocus.FocusList = {}
end,
}

--向插件管理系统返回定义的表
return tPlugin
