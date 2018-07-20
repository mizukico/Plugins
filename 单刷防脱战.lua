--插件名字
local szPluginName = "明教-PVP"

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
--判断对象B是否在对象A的扇形面向内
--参数：对象A,对象B,面向角(角度制)
local function Is_B_in_A_FaceDirection(pA, pB, agl)
	local rd = (pA.nFaceDirection%256)*math.pi/128
    local dx = pB.nX - pA.nX;
    local dy = pB.nY - pA.nY;
	local length = math.sqrt(dx*dx+dy*dy);
    return math.acos(dx/length*math.cos(rd)+dy/length*math.sin(rd)) < agl*math.pi/360;
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
	local player = GetClientPlayer()
	if not player then return end
	--当前血量比值
	local hpRatio = player.nCurrentLife / player.nMaxLife
	--获取当前目标,未进战没目标直接返回,战斗中没目标选择最近敌对NPC,调整面向
	local target, targetClass = s_util.GetTarget(player)
	if not player.bFightState and (not target or not IsEnemy(player.dwID, target.dwID) )then return end --
	if player.bFightState and (not target or not IsEnemy(player.dwID, target.dwID) ) then  
	local MinDistance = 20			--最小距离
	local MindwID = 0		    --最近NPC的ID
	for i,v in ipairs(GetAllNpc()) do		--遍历所有NPC
		if IsEnemy(player.dwID, v.dwID) and s_util.GetDistance(v, player) < MinDistance and v.nLevel>0 then	--如果是敌对，并且距离更小
			MinDistance = s_util.GetDistance(v, player)            
			MindwID = v.dwID      --替换距离和ID
		end
	end
	if MindwID == 0 then
		return --没有敌对NPC则返回
	else
		SetTarget(TARGET.NPC, MindwID)  --设定目标为最近的敌对
	end
	end
	if target then s_util.TurnTo(target.nX,target.nY) end  --调整面向
	--如果目标死亡，直接返回
	if target.nMoveState == MOVE_STATE.ON_DEATH then return end
	--获取自己和目标的距离
	local distance = s_util.GetDistance(player, target)
	--获取自己的读条数据
	local bPrepareMe, dwSkillIdMe, dwLevelMe, nLeftTimeMe, nActionStateMe =  GetSkillOTActionState(player)
	--获取自己的buff表
	local MyBuff = s_util.GetBuffInfo(player)
	--获取自己对目标造成的buff表11
	local TargetBuff = s_util.GetBuffInfo(target, true)
	--获取目标全部的buff表
	local TargetBuffAll = s_util.GetBuffInfo(target)
	--判断目标读条，这里没有做处理，可以判断读条的技能ID做相应处理(打断、迎风回浪、挑起等等)
	local bPrepare, dwSkillId, dwLevel, nLeftTime, nActionState =  GetSkillOTActionState(target)		--返回 是否在读条, 技能ID，等级，剩余时间(秒)，动作类型
	--简化日月能量
	local CurrentSun=player.nCurrentSunEnergy/100
	local CurrentMoon=player.nCurrentMoonEnergy/100
	--与目标距离>8尺使用流光，流光CD使用幻光步
	if distance > 8 then if s_util.CastSkill(3977,false) then return end end --流光
	if distance > 8 then if s_util.CastSkill(3970,false) then return end end --幻光
	--判断player是否在target的180°扇形面向内
	if (Is_B_in_A_FaceDirection(target, player, 180) and s_util.GetTarget(target).dwID ~= player.dwID) or distance > 3.5 then
		s_util.TurnTo(target.nX,target.nY) 
		MoveForwardStart()
	end
	if (not Is_B_in_A_FaceDirection(target, player, 180) or s_util.GetTarget(target).dwID == player.dwID) and distance < 3.5 then 
		MoveForwardStop()
		s_util.TurnTo(target.nX,target.nY)
	end
	--满日且没有同辉，光明相
	if player.nSunPowerValue > 0 and (not MyBuff[4937] or MyBuff[4937] and MyBuff[4937].nLevel ~= 2)   then
		if s_util.CastSkill(3969,true) then return end
	end
	--日60，日大
	if CurrentSun > 59 and CurrentSun <=79 then if s_util.CastSkill(18626,true) then return end end
	--破魔
	if s_util.CastSkill(3967,false) then return end
	--日0 月0,幽月轮；日80 月40，幽月轮
	if (CurrentMoon <= 19 and CurrentSun <= 19 ) or (CurrentSun >79 and CurrentSun <=99 and CurrentMoon >39 and CurrentMoon <=59 ) then 
		if s_util.CastSkill(3959,false) then return end
	end
	--日0 月20 且日盈中，幽月轮
	if CurrentSun <= 19 and CurrentMoon >19 and CurrentMoon <=39 and MyBuff[12487] then 
		if s_util.CastSkill(3959,false) then return end
	end
	--日0 月40 且非日盈中，日斩
	if  CurrentSun <= 19 and CurrentMoon >39 and CurrentMoon <=59 and not MyBuff[12487] then
		if  s_util.CastSkill(3963,false)  then return end 
	end
	--日20 月20 且非日盈中，日斩
	if CurrentSun >19 and CurrentSun <=39 and CurrentMoon >19 and CurrentMoon <=39 and not MyBuff[12487] then 
		if  s_util.CastSkill(3963,false)  then return end 
	end
	--日0 月20 且非日盈中，赤日轮
	if CurrentSun <= 18 and CurrentMoon >19 and CurrentMoon <=39 and not MyBuff[12487] then 
		if  s_util.CastSkill(3962,false)  then return end 
	end
	--日60 月60 且非日盈中，赤日轮
	if CurrentSun >59 and CurrentSun <=79 and CurrentMoon >59 and CurrentMoon <=79 and not MyBuff[12487] then
		if  s_util.CastSkill(3962,false)  then return end 
	end
	--日60 月20，驱夜
	if  CurrentSun >59 and CurrentSun <=79 and CurrentMoon >19 and CurrentMoon <=39 then
		if s_util.CastSkill(3979,false) then return end
	end
	--日40 月40，驱夜
	if  CurrentSun >39 and CurrentSun <=59 and CurrentMoon >39 and CurrentMoon <=59 then
		if s_util.CastSkill(3979,false) then return end
	end
	--日80 月60，月斩
	if CurrentSun >79 and CurrentSun <=99 and CurrentMoon >59 and CurrentMoon <=79 then 
		if s_util.CastSkill(3960,false) then return end 
	end
	--卡宏补月轮
	if CurrentSun < 100 and CurrentMoon < 100 and player.nSunPowerValue <= 0 and player.nMoonPowerValue <= 0 then
		if s_util.CastSkill(3959,false) then return end
	end
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
	if not IsPlayer(dwID) or not IsEnemy(player.dwID,dwID) then return end	--过滤掉非敌对玩家
	--撼地 20尺，千斤坠 20尺，疾 15尺
	if UpdateSkill(dwID,dwSkillID,13424,20) or UpdateSkill(dwID,dwSkillID,18604,20) or UpdateSkill(dwID,dwSkillID,424,15) then 
		s_util.SetTimer("tkongzhi1")
		s_Output("tkongzhi1")
	end
	--盾猛 12尺，龙跃于渊 20尺，龙战于野 20尺，棒打狗头 20尺，割据秦宫 10尺，断魂刺 27尺，破坚阵 4尺
	if UpdateSkill(dwID,dwSkillID,13046,12) or UpdateSkill(dwID,dwSkillID,5262,20) or UpdateSkill(dwID,dwSkillID,5266,20) or UpdateSkill(dwID,dwSkillID,5259,20) or UpdateSkill(dwID,dwSkillID,16479,10) or UpdateSkill(dwID,dwSkillID,428,27) or UpdateSkill(dwID,dwSkillID,426,4) then 
		s_util.SetTimer("tkongzhi2")
		s_Output("tkongzhi2")
	end
	--浮光掠影 30尺，冥月度心 12尺，紫气东来 20尺，擒龙诀 6尺，乱洒 20尺，梵音 20尺
	if UpdateSkill(dwID,dwSkillID,3112,30) or UpdateSkill(dwID,dwSkillID,18629,12) or UpdateSkill(dwID,dwSkillID,2681,20) or UpdateSkill(dwID,dwSkillID,260,6) or UpdateSkill(dwID,dwSkillID,2645,20) or UpdateSkill(dwID,dwSkillID,568,20) then 
		s_util.SetTimer("tbaofa1")
		s_Output("tbaofa1")
	end
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
