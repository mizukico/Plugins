local szPluginName = "CD监控插件v0.3.2"


-- get skill name by id
local _RN = {
	tBuffCache = {},
	tSkillCache = {},
	aNpc = {},
	aPlayer = {},
	aDoodad = {},
}
local RN = {}

--打印表
local function printT(t)
    local s_Output_r_cache={}
    local function sub_s_Output_r(t,indent)
        if (s_Output_r_cache[tostring(t)]) then
            s_Output(indent.."*"..tostring(t))
        else
            s_Output_r_cache[tostring(t)]=true
            if (type(t)=="table") then
                for pos,val in pairs(t) do
                    if (type(val)=="table") then
                        s_Output(indent.."["..pos.."] => "..tostring(t).." {")
                        sub_s_Output_r(val,indent..string.rep(" ",string.len(pos)+8))
                        s_Output(indent..string.rep(" ",string.len(pos)+6).."}")
                    elseif (type(val)=="string") then
                        s_Output(indent.."["..pos..'] => "'..val..'"')
                    else
                        s_Output(indent.."["..pos.."] => "..tostring(val))
                    end
                end
            else
                s_Output(indent..tostring(t))
            end
        end
    end
    if (type(t)=="table") then
        s_Output(tostring(t).." {")
        sub_s_Output_r(t,"  ")
        s_Output("}")
    else
        sub_s_Output_r(t,"  ")
    end
    s_Output()
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

-- 根据技能 ID 及等级获取技能的名称及图标 ID（内置缓存处理）
-- (string, number) RN.GetSkillName(number dwSkillID[, number dwLevel])
RN.GetSkillName = function(dwSkillID, dwLevel)
	if not _RN.tSkillCache[dwSkillID] then
		local tLine = Table_GetSkill(dwSkillID, dwLevel)	--tSkill表
		if tLine and tLine.dwSkillID > 0 and tLine.bShow	--该技能可见
			and (StringFindW(tLine.szDesc, "_") == nil  or StringFindW(tLine.szDesc, "<") ~= nil)	--不是气场效果技能或者dot、hot
		then
			_RN.tSkillCache[dwSkillID] = { tLine.szName, tLine.dwIconID }	--将技能名和技能图标写入到缓存tSkillCache
		else
			local szName = "SKILL#" .. dwSkillID	--找不到就先编一个名字SKILL#4567
			if dwLevel then
				szName = szName .. ":" .. dwLevel	--有等级就加上等级SKILL#4567:8
			end
			_RN.tSkillCache[dwSkillID] = { szName, 13 }		--把编好的技能名字和太极图标写入到缓存tSkillCache
		end
	end
	return unpack(_RN.tSkillCache[dwSkillID])
end

-- 根据Buff ID 及等级获取 BUFF 的名称及图标 ID（内置缓存处理）
-- (string, number) RN.GetBuffName(number dwBuffID[, number dwLevel])
RN.GetBuffName = function(dwBuffID, dwLevel)
	local xKey = dwBuffID	--把键定义为buffID
	if dwLevel then
		xKey = dwBuffID .. "_" .. dwLevel	--有buff等级就把键变成1234_5这种形式
	end
	if not _RN.tBuffCache[xKey] then
		local tLine = Table_GetBuff(dwBuffID, dwLevel or 1)	--tBuff表
		if tLine then
			_RN.tBuffCache[xKey] = { tLine.szName, tLine.dwIconID }	--将buff名和buff图标写入到缓存tBuffCache
		else
			local szName = "BUFF#" .. dwBuffID		--找不到就先编一个名字BUFF#1234
			if dwLevel then
				szName = szName .. ":" .. dwLevel	--有等级就加上等级BUFF#1234:5
			end
			_RN.tBuffCache[xKey] = { szName, -1 }	--将编好的buff名和-1图标写入到缓存tBuffCache
		end
	end
	return unpack(_RN.tBuffCache[xKey])
end

-- 根据技能 ID 获取引导帧数，非引导技能返回 nil
-- (number) RN.GetChannelSkillFrame(number dwSkillID)
RN.GetChannelSkillFrame = function(dwSkillID)
	local t = _RN.tSkillEx[dwSkillID]
	if t then
		return t.nChannelFrame
	end
end

-- 根据技能 ID 判断当前技能是否可打断
-- (bool) RN.CanBrokenSkill(number dwSkillID)
RN.CanBrokenSkill = function(dwSkillID)
	local t = _RN.tSkillEx[dwSkillID]
	if t and t.nBrokenRate == 0 then
		return false
	end
	return true
end

-- Load skill extend data
_RN.tSkillEx = {
[14299]={nChannelFrame=48},[6144]={nAreaRadius=384,nMaxRadius=1920,nMinRadius=0},[8206]={nBrokenRate=0},[3093]={nChannelFrame=40},[10349]={nAreaRadius=320,nMaxRadius=6400,nMinRadius=0},[4169]={nBrokenRate=0},[8350]={nAreaRadius=512,nMaxRadius=3200,nMinRadius=0},[4185]={nAreaRadius=256,nMaxRadius=512,nMinRadius=0},[4193]={nBrokenRate=0},[8398]={nBrokenRate=0},[3129]={nBrokenRate=0},[16852]={nAreaRadius=640,nMaxRadius=1920,nMinRadius=0},[8446]={nAreaRadius=512,nMaxRadius=6400,nMinRadius=0},[6280]={nBrokenRate=0},[6288]={nAreaRadius=320,nMaxRadius=1920,nMinRadius=0},[3149]={nBrokenRate=0},[14651]={nAreaRadius=512,nMaxRadius=1920,nMinRadius=0},[4265]={nAreaRadius=384,nMaxRadius=6400,nMinRadius=0},[17108]={nBrokenRate=0},[3173]={nBrokenRate=0},[8606]={nMinRadius=0,nAreaRadius=640,nMaxRadius=1280,nChannelFrame=80},[4337]={nBrokenRate=0},[3197]={nBrokenRate=0},[4377]={nBrokenRate=0},[4385]={nBrokenRate=0},[14923]={nBrokenRate=0},[8830]={nAreaRadius=640,nMaxRadius=1280,nMinRadius=0},[17716]={nBrokenRate=0},[4457]={nBrokenRate=0},[1629]={nBrokenRate=0},[1631]={nBrokenRate=0},[8974]={nBrokenRate=0},[1639]={nBrokenRate=0},[1641]={nBrokenRate=0},[1645]={nBrokenRate=0,nChannelFrame=84},[3301]={nAreaRadius=384,nMaxRadius=12800,nMinRadius=0},[13212]={nAreaRadius=1024,nMaxRadius=6400,nMinRadius=0},[3313]={nAreaRadius=384,nMaxRadius=2560,nMinRadius=0},[15355]={nBrokenRate=0},[9262]={nAreaRadius=512,nMaxRadius=1280,nMinRadius=0},[15435]={nBrokenRate=0},[15483]={nBrokenRate=0},[3365]={nBrokenRate=0},[3377]={nBrokenRate=0},[4713]={nAreaRadius=384,nMaxRadius=1920,nMinRadius=0},[4737]={nAreaRadius=256,nMaxRadius=3840,nMinRadius=0},[13660]={nBrokenRate=0},[15723]={nBrokenRate=0},[4801]={nBrokenRate=0},[4865]={nBrokenRate=0},[15883]={nBrokenRate=0},[6968]={nBrokenRate=0},[4953]={nBrokenRate=0},[14012]={nBrokenRate=0},[4977]={nBrokenRate=0},[16107]={nBrokenRate=0},[14092]={nBrokenRate=0},[1767]={nBrokenRate=0},[14140]={nChannelFrame=48},[7080]={nAreaRadius=320,nMaxRadius=5120,nMinRadius=0},[3549]={nBrokenRate=0},[7104]={nAreaRadius=192,nMaxRadius=6400,nMinRadius=0},[3577]={nBrokenRate=0},[3585]={nBrokenRate=0},[16406]={nBrokenRate=0},[5137]={nBrokenRate=0},[3597]={nBrokenRate=0},[7200]={nBrokenRate=0},[7216]={nBrokenRate=0},[3613]={nBrokenRate=0},[14476]={nAreaRadius=0,nMaxRadius=2560,nMinRadius=0},[10398]={nBrokenRate=0},[455]={nAreaRadius=640,nMaxRadius=3200,nMinRadius=0},[7280]={nBrokenRate=0},[8447]={nAreaRadius=512,nMaxRadius=6400,nMinRadius=0},[7320]={nChannelFrame=128},[3669]={nBrokenRate=0},[5297]={nMaxRadius=6400,nAreaRadius=512,nBrokenRate=0,nMinRadius=0},[461]={nAreaRadius=512,nMaxRadius=1280,nMinRadius=0},[14748]={nBrokenRate=0},[462]={nAreaRadius=512,nMaxRadius=1280,nMinRadius=0},[7392]={nBrokenRate=0},[463]={nAreaRadius=512,nMaxRadius=1280,nMinRadius=0},[3705]={nBrokenRate=0},[464]={nAreaRadius=512,nMaxRadius=1280,nMinRadius=0},[3713]={nBrokenRate=0},[465]={nAreaRadius=512,nMaxRadius=1280,nMinRadius=0},[8767]={nAreaRadius=192,nMaxRadius=6400,nMinRadius=0},[5425]={nBrokenRate=0},[5441]={nBrokenRate=0},[17718]={nBrokenRate=0},[7520]={nAreaRadius=640,nMaxRadius=1280,nMinRadius=0},[8911]={nBrokenRate=0},[5513]={nBrokenRate=0},[15132]={nAreaRadius=0,nMaxRadius=1280,nMinRadius=0},[9023]={nAreaRadius=320,nMaxRadius=1280,nMinRadius=0},[7608]={nAreaRadius=384,nMaxRadius=1280,nMinRadius=0},[7616]={nAreaRadius=320,nMaxRadius=5120,nMinRadius=0},[13197]={nBrokenRate=0},[7632]={nBrokenRate=0},[15276]={nBrokenRate=0},[13245]={nAreaRadius=192,nMaxRadius=6400,nMinRadius=0},[5609]={nBrokenRate=0},[7664]={nAreaRadius=640,nMaxRadius=12800,nMinRadius=0},[1919]={nAreaRadius=0,nMaxRadius=0,nMinRadius=0},[15356]={nBrokenRate=0},[9263]={nAreaRadius=512,nMaxRadius=1280,nMinRadius=0},[7720]={nBrokenRate=0},[15452]={nChannelFrame=160},[7736]={nBrokenRate=0},[7744]={nBrokenRate=0},[3881]={nAreaRadius=512,nMaxRadius=6400,nMinRadius=0},[9391]={nBrokenRate=0},[15548]={nBrokenRate=0},[7784]={nBrokenRate=0},[1953]={nBrokenRate=0},[9487]={nBrokenRate=0},[9503]={nBrokenRate=0},[3917]={nBrokenRate=0},[1963]={nBrokenRate=0},[13661]={nAreaRadius=256,nMaxRadius=6400,nMinRadius=0},[17111]={nBrokenRate=0},[13693]={nBrokenRate=0},[1977]={nBrokenRate=0},[7912]={nAreaRadius=960,nMaxRadius=1920,nMinRadius=0},[3961]={nChannelFrame=120},[7944]={nAreaRadius=512,nMaxRadius=1600,nMinRadius=0},[7952]={nBrokenRate=0},[7968]={nChannelFrame=96},[13901]={nBrokenRate=0},[13933]={nBrokenRate=0},[8000]={nBrokenRate=0},[16012]={nAreaRadius=320,nMaxRadius=640,nMinRadius=0},[2005]={nBrokenRate=0},[16060]={nAreaRadius=320,nMaxRadius=3200,nMinRadius=0},[2013]={nBrokenRate=0},[2015]={nBrokenRate=0},[8096]={nAreaRadius=192,nMaxRadius=6400,nMinRadius=0},[14157]={nAreaRadius=640,nMaxRadius=6400,nMinRadius=0},[2029]={nBrokenRate=0},[2031]={nBrokenRate=0},[6081]={nAreaRadius=384,nMaxRadius=1920,nMinRadius=0},[16300]={nBrokenRate=0},[2041]={nBrokenRate=0},[14301]={nChannelFrame=48},[6145]={nAreaRadius=384,nMaxRadius=1920,nMinRadius=0},[2054]={nBrokenRate=0},[6161]={nBrokenRate=0},[10335]={nBrokenRate=0},[8304]={nAreaRadius=256,nMaxRadius=6400,nMinRadius=0},[6209]={nAreaRadius=512,nMaxRadius=1920,nMinRadius=0},[4170]={nBrokenRate=0},[6225]={nBrokenRate=0},[2094]={nBrokenRate=0},[4202]={nBrokenRate=0},[4210]={nBrokenRate=0},[14573]={nAreaRadius=64,nMaxRadius=6400,nMinRadius=0},[2118]={nBrokenRate=0},[4250]={nBrokenRate=0},[6313]={nBrokenRate=0},[4274]={nBrokenRate=0},[8592]={nAreaRadius=640,nMaxRadius=12800,nMinRadius=0},[8608]={nAreaRadius=640,nMaxRadius=1280,nMinRadius=0},[8736]={nAreaRadius=384,nMaxRadius=6400,nMinRadius=0},[2198]={nBrokenRate=0},[4402]={nBrokenRate=0},[14973]={nAreaRadius=512,nMaxRadius=3840,nMinRadius=0},[15005]={nAreaRadius=2240,nMaxRadius=2240,nMinRadius=0},[15053]={nBrokenRate=0,nChannelFrame=80},[4498]={nAreaRadius=640,nMaxRadius=1920,nMinRadius=0},[9024]={nAreaRadius=320,nMaxRadius=1280,nMinRadius=0},[567]={nChannelFrame=160},[570]={nChannelFrame=80},[13214]={nAreaRadius=1536,nMaxRadius=6400,nMinRadius=0},[4570]={nAreaRadius=640,nMaxRadius=3840,nMinRadius=0},[2290]={nBrokenRate=0},[9184]={nBrokenRate=0},[15341]={nBrokenRate=0},[15357]={nBrokenRate=0},[13342]={nAreaRadius=256,nMaxRadius=3840,nMinRadius=0},[13390]={nBrokenRate=0},[6705]={nAreaRadius=256,nMaxRadius=64000,nMinRadius=0},[15469]={nBrokenRate=0},[9376]={nBrokenRate=0},[9392]={nBrokenRate=0},[2354]={nAreaRadius=384,nMaxRadius=2560,nMinRadius=0},[2362]={nBrokenRate=0},[2366]={nBrokenRate=0},[4738]={nAreaRadius=384,nMaxRadius=3840,nMinRadius=0},[9488]={nBrokenRate=0},[9504]={nBrokenRate=0},[17081]={nAreaRadius=256,nMaxRadius=1280,nMinRadius=0},[17113]={nBrokenRate=0},[17145]={nBrokenRate=0},[13758]={nBrokenRate=0},[15869]={nBrokenRate=0},[6929]={nBrokenRate=0},[6977]={nBrokenRate=0},[16029]={nBrokenRate=0},[17785]={nBrokenRate=0},[2510]={nBrokenRate=0},[2514]={nBrokenRate=0},[2522]={nBrokenRate=0},[2534]={nBrokenRate=0},[16285]={nAreaRadius=384,nMaxRadius=6400,nMinRadius=0},[16301]={nBrokenRate=0},[14334]={nAreaRadius=512,nMaxRadius=6400,nMinRadius=0},[14382]={nAreaRadius=2432,nMaxRadius=2432,nMinRadius=0},[7217]={nBrokenRate=0},[7225]={nBrokenRate=0},[5210]={nAreaRadius=0,nMaxRadius=1280,nMinRadius=0},[7281]={nBrokenRate=0},[14574]={nAreaRadius=640,nMaxRadius=320000,nMinRadius=0},[14590]={nBrokenRate=0},[5282]={nBrokenRate=0},[14686]={nBrokenRate=0},[5306]={nAreaRadius=288,nMaxRadius=3200,nMinRadius=0},[7361]={nBrokenRate=0},[8593]={nAreaRadius=384,nMaxRadius=1920,nMinRadius=0},[7385]={nAreaRadius=512,nMaxRadius=2560,nMinRadius=0},[2674]={nMinRadius=0,nAreaRadius=512,nMaxRadius=1280,nChannelFrame=8},[8737]={nBrokenRate=0},[8753]={nMaxRadius=6400,nAreaRadius=320,nBrokenRate=0,nMinRadius=0},[8785]={nAreaRadius=512,nMaxRadius=6400,nMinRadius=0},[5450]={nBrokenRate=0},[5458]={nBrokenRate=0},[17786]={nBrokenRate=0},[15134]={nAreaRadius=1280,nMaxRadius=1280,nMinRadius=0},[2782]={nBrokenRate=0},[7625]={nBrokenRate=0},[13215]={nAreaRadius=1792,nMaxRadius=6400,nMinRadius=0},[2798]={nBrokenRate=0},[9153]={nBrokenRate=0},[9185]={nBrokenRate=0},[7681]={nBrokenRate=0},[5642]={nBrokenRate=0},[708]={nAreaRadius=640,nMaxRadius=3200,nMinRadius=0},[7721]={nBrokenRate=0},[15502]={nBrokenRate=0},[15518]={nBrokenRate=0},[9393]={nBrokenRate=0},[16795]={nBrokenRate=0},[13535]={nMaxRadius=12800,nAreaRadius=12800,nBrokenRate=0,nMinRadius=2240},[9457]={nBrokenRate=0},[2882]={nBrokenRate=0},[2886]={nBrokenRate=0},[2890]={nBrokenRate=0},[9537]={nBrokenRate=0},[15694]={nAreaRadius=256,nMaxRadius=6400,nMinRadius=0},[15710]={nBrokenRate=0},[17115]={nBrokenRate=0},[17147]={nAreaRadius=160,nMaxRadius=3200,nMinRadius=0},[13743]={nBrokenRate=0},[7905]={nBrokenRate=0},[13775]={nBrokenRate=0},[13807]={nAreaRadius=0,nMaxRadius=1280,nMinRadius=0},[17435]={nBrokenRate=0},[7953]={nBrokenRate=0},[7977]={nBrokenRate=0},[7985]={nBrokenRate=0},[13935]={nBrokenRate=0},[17787]={nBrokenRate=0},[14047]={nBrokenRate=0},[16110]={nBrokenRate=0},[14111]={nAreaRadius=256,nMaxRadius=3840,nMinRadius=0},[3022]={nBrokenRate=0},[6082]={nAreaRadius=384,nMaxRadius=1920,nMinRadius=0},[16302]={nAreaRadius=256,nMaxRadius=6400,nMinRadius=0},[8177]={nBrokenRate=0},[8194]={nBrokenRate=0},[16444]={nBrokenRate=0},[14383]={nAreaRadius=128,nMaxRadius=2432,nMinRadius=0},[10337]={nMaxRadius=6400,nAreaRadius=3200,nBrokenRate=0,nMinRadius=0},[4171]={nBrokenRate=0},[4179]={nBrokenRate=0},[8434]={nAreaRadius=320,nMaxRadius=3200,nMinRadius=0},[8450]={nBrokenRate=0},[6306]={nBrokenRate=0},[4267]={nAreaRadius=384,nMaxRadius=6400,nMinRadius=0},[14687]={nAreaRadius=512,nMaxRadius=2560,nMinRadius=0},[3166]={nBrokenRate=0},[8578]={nBrokenRate=0},[8594]={nAreaRadius=384,nMaxRadius=1920,nMinRadius=0},[4315]={nBrokenRate=0},[8658]={nBrokenRate=0},[17436]={nBrokenRate=0},[8738]={nBrokenRate=0},[4379]={nBrokenRate=0},[8770]={nAreaRadius=256,nMaxRadius=6400,nMinRadius=0},[4403]={nBrokenRate=0},[8850]={nBrokenRate=0},[15007]={nAreaRadius=0,nMaxRadius=2240,nMinRadius=0},[3246]={nBrokenRate=0},[3250]={nBrokenRate=0},[3254]={nBrokenRate=0},[15135]={nAreaRadius=256,nMaxRadius=3200,nMinRadius=0},[13104]={nMaxRadius=12800,nAreaRadius=12800,nBrokenRate=0,nMinRadius=2240},[9026]={nBrokenRate=0},[3306]={nAreaRadius=384,nMaxRadius=12800,nMinRadius=0},[3318]={nBrokenRate=0},[832]={nBrokenRate=0},[15359]={nBrokenRate=0},[15391]={nAreaRadius=1600,nMaxRadius=1920,nMinRadius=0},[9266]={nAreaRadius=320,nMaxRadius=2880,nMinRadius=0},[13376]={nBrokenRate=0},[13392]={nBrokenRate=0},[15455]={nBrokenRate=0},[6714]={nAreaRadius=384,nMaxRadius=6400,nMinRadius=0},[841]={nBrokenRate=0},[15519]={nBrokenRate=0},[4723]={nAreaRadius=256,nMaxRadius=3840,nMinRadius=0},[3398]={nBrokenRate=0},[9506]={nBrokenRate=0},[13616]={nChannelFrame=80},[854]={nBrokenRate=0},[855]={nBrokenRate=0},[17117]={nBrokenRate=0},[15791]={nBrokenRate=0},[17277]={nBrokenRate=0},[13792]={nAreaRadius=256,nMaxRadius=6400,nMinRadius=0},[15871]={nBrokenRate=0},[15887]={nBrokenRate=0},[13872]={nBrokenRate=0},[15983]={nBrokenRate=0},[16031]={nAreaRadius=320,nMaxRadius=1280,nMinRadius=0},[17757]={nBrokenRate=0},[16111]={nBrokenRate=0},[3530]={nBrokenRate=0},[14144]={nAreaRadius=960,nMaxRadius=6400,nMinRadius=0},[3566]={nBrokenRate=0},[3578]={nBrokenRate=0},[16367]={nBrokenRate=0},[3590]={nBrokenRate=0},[16446]={nBrokenRate=0},[7194]={nBrokenRate=0},[7202]={nBrokenRate=0},[7210]={nBrokenRate=0},[10338]={nBrokenRate=0},[8307]={nAreaRadius=320,nMaxRadius=6400,nMinRadius=0},[7242]={nBrokenRate=0},[10402]={nAreaRadius=384,nMaxRadius=6400,nMinRadius=0},[5211]={nAreaRadius=512,nMaxRadius=6400,nMinRadius=0},[14576]={nBrokenRate=0},[7314]={nChannelFrame=32},[3666]={nBrokenRate=0},[8531]={nAreaRadius=192,nMaxRadius=3840,nMinRadius=0},[14688]={nAreaRadius=512,nMaxRadius=2560,nMinRadius=0},[3682]={nBrokenRate=0},[7370]={nAreaRadius=640,nMaxRadius=1280,nMinRadius=0},[8627]={nBrokenRate=0},[3714]={nBrokenRate=0},[3718]={nBrokenRate=0},[8739]={nBrokenRate=0},[8771]={nAreaRadius=128,nMaxRadius=6400,nMinRadius=0},[5427]={nBrokenRate=0},[5443]={nBrokenRate=0},[5459]={nBrokenRate=0},[17758]={nAreaRadius=288,nMaxRadius=1920,nMinRadius=0},[15104]={nBrokenRate=0},[7562]={nBrokenRate=0},[5523]={nAreaRadius=256,nMaxRadius=1600,nMinRadius=0},[5531]={nBrokenRate=0},[9091]={nAreaRadius=2560,nMaxRadius=2560,nMinRadius=0},[5627]={nBrokenRate=0},[961]={nBrokenRate=0},[13377]={nBrokenRate=0},[7722]={nBrokenRate=0},[7730]={nBrokenRate=0},[3874]={nBrokenRate=0},[3886]={nAreaRadius=192,nMaxRadius=6400,nMinRadius=0},[974]={nBrokenRate=0},[9475]={nBrokenRate=0},[3914]={nBrokenRate=0},[3926]={nBrokenRate=0},[17151]={nBrokenRate=0},[986]={nBrokenRate=0},[7898]={nBrokenRate=0},[62]={nBrokenRate=0},[3970]={nMaxRadius=1280,nAreaRadius=256,nBrokenRate=0,nMinRadius=0},[17439]={nAreaRadius=256,nMaxRadius=1920,nMinRadius=0},[13857]={nAreaRadius=128,nMaxRadius=2560,nMinRadius=0},[13873]={nBrokenRate=0},[13937]={nBrokenRate=0},[13969]={nAreaRadius=64,nMaxRadius=2560,nMinRadius=0},[8026]={nBrokenRate=0},[16064]={nBrokenRate=0},[14049]={nBrokenRate=0},[16112]={nBrokenRate=0},[8090]={nAreaRadius=384,nMaxRadius=3840,nMinRadius=0},[8098]={nBrokenRate=0},[8122]={nBrokenRate=0},[8130]={nBrokenRate=0},[1019]={nBrokenRate=0},[8178]={nBrokenRate=0},[2051]={nBrokenRate=0},[16448]={nAreaRadius=128,nMaxRadius=64000,nMinRadius=0},[1036]={nBrokenRate=0},[6203]={nAreaRadius=384,nMaxRadius=12800,nMinRadius=0},[6211]={nAreaRadius=512,nMaxRadius=1920,nMinRadius=0},[4204]={nBrokenRate=0},[1056]={nBrokenRate=0},[6275]={nAreaRadius=384,nMaxRadius=6400,nMinRadius=0},[4252]={nBrokenRate=0},[8532]={nAreaRadius=192,nMaxRadius=6400,nMinRadius=0},[17120]={nBrokenRate=0},[14721]={nBrokenRate=0},[17216]={nBrokenRate=0},[14769]={nAreaRadius=3200,nMaxRadius=640,nMinRadius=0},[17280]={nBrokenRate=0},[8724]={nBrokenRate=0},[4372]={nBrokenRate=0},[6427]={nBrokenRate=0},[8772]={nAreaRadius=256,nMaxRadius=6400,nMinRadius=0},[2199]={nBrokenRate=0},[2203]={nBrokenRate=0},[4412]={nBrokenRate=0},[8836]={nAreaRadius=320,nMaxRadius=6400,nMinRadius=0},[15009]={nBrokenRate=0},[1112]={nAreaRadius=384,nMaxRadius=5120,nMinRadius=0},[8916]={nBrokenRate=0},[2235]={nBrokenRate=0,nChannelFrame=128},[15137]={nBrokenRate=0},[2255]={nBrokenRate=0},[2259]={nBrokenRate=0},[1134]={nBrokenRate=0},[13170]={nAreaRadius=960,nMaxRadius=1088,nMinRadius=0},[1138]={nBrokenRate=0},[2279]={nBrokenRate=0},[13218]={nBrokenRate=0},[1144]={nBrokenRate=0},[1146]={nBrokenRate=0},[1148]={nBrokenRate=0},[72]={nBrokenRate=0},[15361]={nBrokenRate=0},[2311]={nBrokenRate=0},[6675]={nChannelFrame=80},[13378]={nAreaRadius=192,nMaxRadius=64000,nMinRadius=0},[6715]={nAreaRadius=512,nMaxRadius=6400,nMinRadius=0},[13458]={nChannelFrame=80},[2347]={nBrokenRate=0},[13522]={nBrokenRate=0},[1182]={nBrokenRate=0},[1184]={nBrokenRate=0},[2371]={nBrokenRate=0},[9492]={nBrokenRate=0},[9508]={nBrokenRate=0},[4772]={nAreaRadius=512,nMaxRadius=3200,nMinRadius=0},[17121]={nBrokenRate=0},[17153]={nBrokenRate=0},[15761]={nBrokenRate=0},[15793]={nAreaRadius=128,nMaxRadius=64000,nMinRadius=0},[17281]={nAreaRadius=384,nMaxRadius=7680,nMinRadius=0},[15857]={nBrokenRate=0},[15889]={nBrokenRate=0},[13890]={nBrokenRate=0},[6963]={nBrokenRate=0},[6971]={nBrokenRate=0},[6979]={nBrokenRate=0},[16065]={nBrokenRate=0},[16081]={nBrokenRate=0},[4980]={nBrokenRate=0},[1248]={nBrokenRate=0},[14082]={nAreaRadius=0,nMaxRadius=1280,nMinRadius=0},[14114]={nBrokenRate=0},[2531]={nBrokenRate=0},[2535]={nBrokenRate=0},[16353]={nBrokenRate=0},[8197]={nChannelFrame=80},[16450]={nBrokenRate=0},[7203]={nBrokenRate=0},[8277]={nAreaRadius=384,nMaxRadius=6400,nMinRadius=0},[7219]={nBrokenRate=0},[8325]={nAreaRadius=512,nMaxRadius=16384,nMinRadius=0},[7259]={nBrokenRate=0},[8405]={nAreaRadius=1280,nMaxRadius=9600,nMinRadius=0},[8421]={nAreaRadius=512,nMaxRadius=1280,nMinRadius=0},[5244]={nAreaRadius=0,nMaxRadius=1280,nMinRadius=0},[5268]={nChannelFrame=40},[7331]={nBrokenRate=0},[7339]={nAreaRadius=192,nMaxRadius=1600,nMinRadius=0},[7347]={nBrokenRate=0},[1328]={nBrokenRate=0},[1330]={nBrokenRate=0},[8597]={nBrokenRate=0},[7379]={nBrokenRate=0},[14770]={nAreaRadius=576,nMaxRadius=640,nMinRadius=0},[7395]={nBrokenRate=0},[1340]={nBrokenRate=0},[1342]={nBrokenRate=0},[1344]={nBrokenRate=0},[8725]={nBrokenRate=0},[8741]={nBrokenRate=0},[2707]={nChannelFrame=48},[1362]={nBrokenRate=0},[15058]={nAreaRadius=320,nMaxRadius=1280,nMinRadius=768},[15074]={nBrokenRate=0},[13203]={nAreaRadius=128,nMaxRadius=6400,nMinRadius=0},[15266]={nBrokenRate=0},[13283]={nBrokenRate=0},[9205]={nBrokenRate=0},[15362]={nBrokenRate=0},[1414]={nAreaRadius=384,nMaxRadius=19200,nMinRadius=0},[9269]={nBrokenRate=0},[9301]={nMaxRadius=2560,nAreaRadius=2560,nBrokenRate=0,nMinRadius=1280},[7731]={nBrokenRate=0},[7747]={nBrokenRate=0},[7763]={nAreaRadius=320,nMaxRadius=12800,nMinRadius=0},[9397]={nAreaRadius=512,nMaxRadius=2560,nMinRadius=0},[9413]={nBrokenRate=0},[7787]={nBrokenRate=0},[7795]={nBrokenRate=0},[2879]={nBrokenRate=0},[2883]={nBrokenRate=0},[2887]={nBrokenRate=0},[9509]={nBrokenRate=0},[7835]={nBrokenRate=0},[1452]={nBrokenRate=0},[15714]={nBrokenRate=0},[7867]={nBrokenRate=0},[15762]={nBrokenRate=0},[13779]={nBrokenRate=0},[13811]={nBrokenRate=0},[15890]={nAreaRadius=128,nMaxRadius=64000,nMinRadius=0},[7963]={nBrokenRate=0},[1482]={nBrokenRate=0},[7979]={nBrokenRate=0},[8003]={nBrokenRate=0},[1492]={nBrokenRate=0},[16082]={nBrokenRate=0},[14067]={nChannelFrame=48},[3011]={nBrokenRate=0},[8075]={nBrokenRate=0},[8091]={nAreaRadius=192,nMaxRadius=3200,nMinRadius=0},[8099]={nAreaRadius=384,nMaxRadius=3840,nMinRadius=0},[6076]={nAreaRadius=384,nMaxRadius=1920,nMinRadius=0},[6084]={nAreaRadius=384,nMaxRadius=1920,nMinRadius=0},[16290]={nBrokenRate=0},[1542]={nBrokenRate=0},[8262]={nAreaRadius=384,nMaxRadius=6400,nMinRadius=0},[8278]={nMaxRadius=6400,nAreaRadius=384,nBrokenRate=0,nMinRadius=0},[6204]={nAreaRadius=384,nMaxRadius=2560,nMinRadius=0},[8326]={nChannelFrame=96},[3111]={nAreaRadius=384,nMaxRadius=1280,nMinRadius=0},[4181]={nAreaRadius=256,nMaxRadius=6400,nMinRadius=0},[1560]={nBrokenRate=0},[1562]={nBrokenRate=0},[8438]={nAreaRadius=960,nMaxRadius=640000,nMinRadius=0},[3143]={nBrokenRate=0},[4269]={nBrokenRate=0},[14691]={nAreaRadius=512,nMaxRadius=2560,nMinRadius=0},[6332]={nBrokenRate=0},[17156]={nBrokenRate=0},[3179]={nBrokenRate=0},[14771]={nAreaRadius=2560,nMaxRadius=640,nMinRadius=0},[14787]={nAreaRadius=2560,nMaxRadius=2560,nMinRadius=0},[8726]={nBrokenRate=0},[4381]={nBrokenRate=0},[8790]={nBrokenRate=0},[17636]={nAreaRadius=384,nMaxRadius=6400,nMinRadius=0},[8838]={nAreaRadius=256,nMaxRadius=6400,nMinRadius=0},[1624]={nBrokenRate=0},[8918]={nAreaRadius=512,nMaxRadius=6400,nMinRadius=0},[1630]={nBrokenRate=0},[1632]={nBrokenRate=0},[1634]={nBrokenRate=0},[8998]={nBrokenRate=0},[1640]={nBrokenRate=0},[15171]={nBrokenRate=0},[1652]={nBrokenRate=0},[13220]={nAreaRadius=1280,nMaxRadius=25600,nMinRadius=0},[13252]={nBrokenRate=0,nChannelFrame=160},[15395]={nBrokenRate=0},[9302]={nMaxRadius=2560,nAreaRadius=2560,nBrokenRate=0,nMinRadius=1280},[1680]={nMaxRadius=1280,nAreaRadius=192,nBrokenRate=0,nMinRadius=256},[3367]={nAreaRadius=640,nMaxRadius=6400,nMinRadius=0},[13492]={nBrokenRate=0},[9494]={nBrokenRate=0},[9510]={nBrokenRate=0},[4813]={nBrokenRate=0},[17221]={nBrokenRate=0},[13748]={nBrokenRate=0},[17317]={nBrokenRate=0},[17349]={nBrokenRate=0},[4861]={nBrokenRate=0},[6916]={nBrokenRate=0},[1742]={nBrokenRate=0},[6972]={nBrokenRate=0},[14020]={nBrokenRate=0},[14052]={nBrokenRate=0},[16147]={nAreaRadius=320,nMaxRadius=3200,nMinRadius=0},[3531]={nBrokenRate=0},[3535]={nBrokenRate=0},[1770]={nBrokenRate=0},[3547]={nBrokenRate=0},[1778]={nBrokenRate=0},[14228]={nBrokenRate=0},[3571]={nBrokenRate=0},[16390]={nBrokenRate=0},[5133]={nBrokenRate=0},[3595]={nBrokenRate=0},[7196]={nBrokenRate=0},[7204]={nBrokenRate=0},[1804]={nBrokenRate=0},[7220]={nBrokenRate=0},[8311]={nAreaRadius=256,nMaxRadius=32000,nMinRadius=0},[8327]={nChannelFrame=96},[3623]={nBrokenRate=0},[16710]={nBrokenRate=0},[8375]={nBrokenRate=0},[3651]={nBrokenRate=0},[5277]={nBrokenRate=0},[3671]={nBrokenRate=0},[14692]={nAreaRadius=512,nMaxRadius=2560,nMinRadius=0},[17126]={nBrokenRate=0},[7364]={nMaxRadius=2560,nAreaRadius=128,nBrokenRate=0,nMinRadius=0},[7372]={nAreaRadius=640,nMaxRadius=1280,nMinRadius=0},[8615]={nChannelFrame=160},[7396]={nBrokenRate=0},[3703]={nBrokenRate=0},[17350]={nAreaRadius=320,nMaxRadius=1920,nMinRadius=0},[3719]={nBrokenRate=0},[3731]={nBrokenRate=0},[14932]={nAreaRadius=256,nMaxRadius=3200,nMinRadius=0},[8807]={nBrokenRate=0},[7492]={nBrokenRate=0},[17766]={nBrokenRate=0},[8903]={nBrokenRate=0},[5493]={nBrokenRate=0},[15108]={nAreaRadius=192,nMaxRadius=2432,nMinRadius=0},[15140]={nBrokenRate=0},[5549]={nBrokenRate=0},[9063]={nAreaRadius=256,nMaxRadius=3840,nMinRadius=0},[15268]={nBrokenRate=0},[7660]={nAreaRadius=640,nMaxRadius=9600,nMinRadius=64},[7676]={nBrokenRate=0},[15380]={nBrokenRate=0},[15396]={nBrokenRate=0},[13381]={nBrokenRate=0},[7732]={nBrokenRate=0},[9335]={nChannelFrame=40},[16679]={nBrokenRate=0},[13477]={nBrokenRate=0},[3887]={nAreaRadius=512,nMaxRadius=6400,nMinRadius=0},[9415]={nBrokenRate=0},[9495]={nBrokenRate=0},[9511]={nBrokenRate=0},[1960]={nBrokenRate=0},[7844]={nAreaRadius=32000,nMaxRadius=320000,nMinRadius=0},[7868]={nBrokenRate=0},[1970]={nBrokenRate=0},[13749]={nBrokenRate=0},[7908]={nBrokenRate=0},[15876]={nBrokenRate=0},[15892]={nBrokenRate=0},[17511]={nAreaRadius=384,nMaxRadius=6400,nMinRadius=0},[7980]={nBrokenRate=0},[17607]={nAreaRadius=384,nMaxRadius=6400,nMinRadius=0},[8028]={nBrokenRate=0},[2010]={nBrokenRate=0},[4023]={nBrokenRate=0},[8076]={nBrokenRate=0},[8100]={nBrokenRate=0},[8108]={nBrokenRate=0},[6069]={nAreaRadius=384,nMaxRadius=1920,nMinRadius=0},[6077]={nAreaRadius=384,nMaxRadius=1920,nMinRadius=0},[6085]={nAreaRadius=384,nMaxRadius=1920,nMinRadius=0},[2036]={nBrokenRate=0},[2038]={nBrokenRate=0},[4083]={nAreaRadius=128,nMaxRadius=1280,nMinRadius=0},[6133]={nAreaRadius=512,nMaxRadius=1920,nMinRadius=0},[2048]={nBrokenRate=0},[16392]={nBrokenRate=0},[16584]={nBrokenRate=0},[2080]={nBrokenRate=0},[8360]={nBrokenRate=0},[6245]={nBrokenRate=0},[4206]={nBrokenRate=0},[14565]={nAreaRadius=192,nMaxRadius=2432,nMinRadius=0},[6269]={nAreaRadius=256,nMaxRadius=6400,nMinRadius=0},[6277]={nAreaRadius=768,nMaxRadius=6400,nMinRadius=0},[16968]={nAreaRadius=192,nMaxRadius=960,nMinRadius=0},[6309]={nBrokenRate=0},[4310]={nBrokenRate=0},[14789]={nAreaRadius=0,nMaxRadius=2560,nMinRadius=0},[14901]={nBrokenRate=0},[4398]={nBrokenRate=0},[8808]={nBrokenRate=0},[2208]={nBrokenRate=0},[2212]={nAreaRadius=384,nMaxRadius=1280,nMinRadius=0},[15061]={nAreaRadius=960,nMaxRadius=6400,nMinRadius=0},[13030]={nBrokenRate=0},[13062]={nAreaRadius=512,nMaxRadius=6400,nMinRadius=0},[15141]={nBrokenRate=0},[13174]={nAreaRadius=128,nMaxRadius=6400,nMinRadius=0},[9112]={nBrokenRate=0},[15269]={nBrokenRate=0},[4582]={nAreaRadius=640,nMaxRadius=3840,nMinRadius=0},[2296]={nBrokenRate=0},[9192]={nBrokenRate=0},[2312]={nBrokenRate=0},[15477]={nBrokenRate=0},[16681]={nBrokenRate=0},[2348]={nBrokenRate=0},[9416]={nBrokenRate=0},[9432]={nBrokenRate=0},[4726]={nAreaRadius=256,nMaxRadius=1920,nMinRadius=0},[4734]={nAreaRadius=256,nMaxRadius=3840,nMinRadius=0},[4742]={nAreaRadius=384,nMaxRadius=3840,nMinRadius=0},[13590]={nBrokenRate=0},[13606]={nAreaRadius=192,nMaxRadius=25600,nMinRadius=0},[13638]={nBrokenRate=0},[4782]={nBrokenRate=0},[15749]={nAreaRadius=1280,nMaxRadius=1280,nMinRadius=0},[17225]={nBrokenRate=0},[13766]={nBrokenRate=0},[17353]={nBrokenRate=0},[13814]={nAreaRadius=320,nMaxRadius=5120,nMinRadius=0},[6925]={nBrokenRate=0},[13894]={nBrokenRate=0},[6973]={nBrokenRate=0},[17769]={nBrokenRate=0},[14022]={nAreaRadius=512,nMaxRadius=3840,nMinRadius=0},[16085]={nChannelFrame=32},[17777]={nBrokenRate=0},[17767]={nBrokenRate=0},[1546]={nBrokenRate=0},[17681]={nAreaRadius=640,nMaxRadius=6400,nMinRadius=0},[14126]={nAreaRadius=96,nMaxRadius=3840,nMinRadius=0},[17668]={nAreaRadius=256,nMaxRadius=1600,nMinRadius=0},[17654]={nBrokenRate=0},[17652]={nBrokenRate=0},[7758]={nBrokenRate=0},[1140]={nBrokenRate=0},[2532]={nBrokenRate=0},[17648]={nAreaRadius=256,nMaxRadius=1280,nMinRadius=0},[16293]={nBrokenRate=0},[17150]={nAreaRadius=2560,nMaxRadius=3200,nMinRadius=0},[2548]={nBrokenRate=0},[17512]={nAreaRadius=256,nMaxRadius=6400,nMinRadius=0},[17467]={nAreaRadius=384,nMaxRadius=6400,nMinRadius=0},[17465]={nBrokenRate=0},[8201]={nBrokenRate=0},[17457]={nBrokenRate=0},[9441]={nChannelFrame=48},[17444]={nBrokenRate=0},[7205]={nBrokenRate=0},[17443]={nBrokenRate=0},[17442]={nAreaRadius=256,nMaxRadius=6400,nMinRadius=0},[7229]={nBrokenRate=0},[8329]={nChannelFrame=128},[14486]={nBrokenRate=0},[17440]={nBrokenRate=0},[1821]={nBrokenRate=0},[9183]={nBrokenRate=0},[17358]={nBrokenRate=0},[8425]={nBrokenRate=0},[13595]={nBrokenRate=0},[17288]={nBrokenRate=0},[17287]={nBrokenRate=0},[5270]={nBrokenRate=0,nChannelFrame=153},[17282]={nAreaRadius=384,nMaxRadius=7680,nMinRadius=0},[3685]={nBrokenRate=0},[17255]={nBrokenRate=0},[17253]={nBrokenRate=0},[17252]={nBrokenRate=0},[17250]={nBrokenRate=0},[7373]={nAreaRadius=640,nMaxRadius=1280,nMinRadius=0},[7381]={nBrokenRate=0},[17244]={nBrokenRate=0},[7397]={nBrokenRate=0},[17228]={nBrokenRate=0},[17222]={nAreaRadius=384,nMaxRadius=1920,nMinRadius=0},[17200]={nBrokenRate=0},[17186]={nBrokenRate=0},[15634]={nAreaRadius=512,nMaxRadius=56320,nMinRadius=0},[17152]={nBrokenRate=0},[17514]={nAreaRadius=512,nMaxRadius=6400,nMinRadius=0},[17143]={nAreaRadius=384,nMaxRadius=3200,nMinRadius=0},[7469]={nBrokenRate=0},[5430]={nBrokenRate=0},[5438]={nBrokenRate=0},[5446]={nBrokenRate=0},[17141]={nBrokenRate=0},[7913]={nBrokenRate=0},[17122]={nBrokenRate=0},[17114]={nBrokenRate=0},[17086]={nAreaRadius=128,nMaxRadius=960,nMinRadius=0},[17084]={nAreaRadius=160,nMaxRadius=3840,nMinRadius=0},[17082]={nAreaRadius=256,nMaxRadius=1280,nMinRadius=0},[17080]={nBrokenRate=0},[17062]={nBrokenRate=0},[173]={nBrokenRate=0},[17019]={nBrokenRate=0},[15174]={nBrokenRate=0},[16951]={nAreaRadius=1600,nMaxRadius=6400,nMinRadius=0},[16948]={nAreaRadius=32000,nMaxRadius=1920,nMinRadius=0},[13175]={nAreaRadius=384,nMaxRadius=6400,nMinRadius=0},[16947]={nBrokenRate=0},[7629]={nBrokenRate=0},[15270]={nBrokenRate=0},[16945]={nAreaRadius=1600,nMaxRadius=6400,nMinRadius=0},[16892]={nAreaRadius=384,nMaxRadius=640,nMinRadius=0},[7661]={nBrokenRate=0},[2812]={nBrokenRate=0},[16878]={nBrokenRate=0},[16877]={nBrokenRate=0},[9241]={nBrokenRate=0},[16876]={nBrokenRate=0},[16723]={nBrokenRate=0},[16697]={nBrokenRate=0},[15820]={nBrokenRate=0},[13415]={nAreaRadius=1280,nMaxRadius=25600,nMinRadius=0},[7741]={nAreaRadius=192,nMaxRadius=2560,nMinRadius=0},[9353]={nAreaRadius=640,nMaxRadius=1920,nMinRadius=0},[7757]={nBrokenRate=0},[13479]={nBrokenRate=0},[16683]={nBrokenRate=0},[9417]={nBrokenRate=0},[7789]={nBrokenRate=0},[7797]={nBrokenRate=0},[2880]={nBrokenRate=0},[7813]={nBrokenRate=0},[9497]={nBrokenRate=0},[2892]={nBrokenRate=0},[16583]={nBrokenRate=0},[16575]={nBrokenRate=0},[16572]={nBrokenRate=0},[16492]={nAreaRadius=256,nMaxRadius=6400,nMinRadius=0},[13687]={nBrokenRate=0},[16475]={nBrokenRate=0},[16453]={nAreaRadius=480,nMaxRadius=3200,nMinRadius=0},[16452]={nBrokenRate=0},[13751]={nAreaRadius=128,nMaxRadius=6400,nMinRadius=0},[16451]={nAreaRadius=448,nMaxRadius=3200,nMinRadius=0},[7917]={nBrokenRate=0},[7925]={nBrokenRate=0},[7933]={nBrokenRate=0},[7941]={nBrokenRate=0},[17451]={nAreaRadius=256,nMaxRadius=6400,nMinRadius=0},[7957]={nAreaRadius=1920,nMaxRadius=1920,nMinRadius=0},[16431]={nAreaRadius=192,nMaxRadius=320,nMinRadius=0},[16404]={nBrokenRate=0},[16402]={nBrokenRate=0},[14579]={nBrokenRate=0},[15990]={nBrokenRate=0},[17675]={nAreaRadius=384,nMaxRadius=1280,nMinRadius=0},[16022]={nBrokenRate=0},[16384]={nBrokenRate=0},[16054]={nBrokenRate=0},[16381]={nBrokenRate=0},[16086]={nBrokenRate=0},[1142]={nBrokenRate=0},[16351]={nBrokenRate=0},[16346]={nBrokenRate=0},[16072]={nBrokenRate=0},[9498]={nBrokenRate=0},[16303]={nBrokenRate=0},[9499]={nBrokenRate=0},[3032]={nAreaRadius=384,nMaxRadius=6399936,nMinRadius=0},[16276]={nAreaRadius=1600,nMaxRadius=1280,nMinRadius=0},[6078]={nAreaRadius=384,nMaxRadius=1920,nMinRadius=0},[8758]={nAreaRadius=128,nMaxRadius=6400,nMinRadius=0},[16103]={nBrokenRate=0},[16099]={nBrokenRate=0},[16074]={nBrokenRate=0},[16326]={nBrokenRate=0},[16058]={nBrokenRate=0},[3793]={nBrokenRate=0},[7218]={nBrokenRate=0},[16009]={nBrokenRate=0},[15900]={nAreaRadius=64,nMaxRadius=3200,nMinRadius=0},[15884]={nBrokenRate=0},[4127]={nBrokenRate=0},[15006]={nAreaRadius=192,nMaxRadius=2560,nMinRadius=0},[15867]={nBrokenRate=0},[3100]={nBrokenRate=0,nChannelFrame=48},[15834]={nBrokenRate=0},[8330]={nChannelFrame=128},[16684]={nBrokenRate=0},[8124]={nAreaRadius=256,nMaxRadius=6400,nMinRadius=0},[15800]={nBrokenRate=0},[15792]={nBrokenRate=0},[3128]={nBrokenRate=0},[15760]={nBrokenRate=0},[8442]={nAreaRadius=640,nMaxRadius=6400,nMinRadius=0},[6278]={nBrokenRate=0},[6286]={nBrokenRate=0},[15711]={nAreaRadius=256,nMaxRadius=7680,nMinRadius=0},[15663]={nBrokenRate=0},[1332]={nBrokenRate=0},[6318]={nBrokenRate=0},[3164]={nBrokenRate=0},[15638]={nBrokenRate=0},[17164]={nChannelFrame=80},[15633]={nAreaRadius=256,nMaxRadius=2560,nMinRadius=0},[3180]={nBrokenRate=0},[15539]={nBrokenRate=0},[15536]={nBrokenRate=0},[8666]={nBrokenRate=0},[4343]={nBrokenRate=0},[15534]={nBrokenRate=0},[15533]={nBrokenRate=0},[8730]={nBrokenRate=0},[15532]={nBrokenRate=0},[15525]={nBrokenRate=0},[8778]={nBrokenRate=0},[4399]={nBrokenRate=0},[15524]={nBrokenRate=0},[14967]={nAreaRadius=512,nMaxRadius=3840,nMinRadius=0},[14983]={nAreaRadius=512,nMaxRadius=2560,nMinRadius=0},[8858]={nAreaRadius=384,nMaxRadius=6400,nMinRadius=0},[15015]={nAreaRadius=2048,nMaxRadius=2048,nMinRadius=0},[15521]={nBrokenRate=0},[4455]={nBrokenRate=0},[3256]={nBrokenRate=0},[5284]={nBrokenRate=0},[13048]={nChannelFrame=80},[15484]={nBrokenRate=0},[15127]={nChannelFrame=48},[15478]={nBrokenRate=0},[8530]={nAreaRadius=192,nMaxRadius=3200,nMinRadius=0},[4312]={nBrokenRate=0},[15462]={nBrokenRate=0},[15434]={nMaxRadius=1280,nAreaRadius=640,nBrokenRate=0,nMinRadius=0},[13176]={nAreaRadius=6400,nMaxRadius=6400,nMinRadius=0},[847]={nBrokenRate=0},[7369]={nAreaRadius=640,nMaxRadius=1280,nMinRadius=0},[9130]={nBrokenRate=0},[13240]={nBrokenRate=0},[6314]={nBrokenRate=0},[9178]={nBrokenRate=0},[15402]={nBrokenRate=0},[15389]={nAreaRadius=320,nMaxRadius=1920,nMinRadius=0},[16397]={nBrokenRate=0},[9242]={nBrokenRate=0},[15383]={nBrokenRate=0},[15415]={nAreaRadius=320,nMaxRadius=1920,nMinRadius=0},[15360]={nBrokenRate=0},[15354]={nBrokenRate=0},[3356]={nAreaRadius=192,nMaxRadius=12800,nMinRadius=0},[15352]={nBrokenRate=0},[15344]={nBrokenRate=0},[15343]={nBrokenRate=0},[15340]={nBrokenRate=0},[9402]={nAreaRadius=512,nMaxRadius=2560,nMinRadius=0},[9418]={nBrokenRate=0},[9434]={nBrokenRate=0},[15291]={nAreaRadius=256,nMaxRadius=1920,nMinRadius=0},[3392]={nBrokenRate=0},[7371]={nAreaRadius=640,nMaxRadius=1600,nMinRadius=0},[4751]={nBrokenRate=0},[9514]={nBrokenRate=0},[13624]={nAreaRadius=640,nMaxRadius=32000,nMinRadius=0},[9371]={nBrokenRate=0},[13656]={nBrokenRate=0},[15139]={nBrokenRate=0},[15116]={nAreaRadius=640,nMaxRadius=320000,nMinRadius=0},[15115]={nBrokenRate=0},[15114]={nAreaRadius=960,nMaxRadius=6400,nMinRadius=0},[15109]={nBrokenRate=0},[15107]={nAreaRadius=192,nMaxRadius=2432,nMinRadius=0},[15073]={nBrokenRate=0},[15052]={nBrokenRate=0},[10352]={nBrokenRate=0},[15008]={nAreaRadius=0,nMaxRadius=2240,nMinRadius=0},[15879]={nAreaRadius=512,nMaxRadius=512,nMinRadius=0},[6926]={nBrokenRate=0},[14984]={nAreaRadius=512,nMaxRadius=2560,nMinRadius=0},[14982]={nMaxRadius=2560,nAreaRadius=2560,nBrokenRate=0,nMinRadius=1280},[13896]={nBrokenRate=0},[14981]={nAreaRadius=384,nMaxRadius=6400,nMinRadius=0},[14980]={nAreaRadius=384,nMaxRadius=6400,nMinRadius=0},[14978]={nAreaRadius=2432,nMaxRadius=2432,nMinRadius=0},[3539]={nBrokenRate=0},[1045]={nBrokenRate=0},[14966]={nAreaRadius=512,nMaxRadius=3840,nMinRadius=0},[3504]={nBrokenRate=0},[14949]={nBrokenRate=0},[4975]={nBrokenRate=0},[14056]={nBrokenRate=0},[14933]={nAreaRadius=256,nMaxRadius=3200,nMinRadius=0},[4999]={nAreaRadius=256,nMaxRadius=6400,nMinRadius=0},[14912]={nAreaRadius=512,nMaxRadius=640,nMinRadius=0},[14788]={nAreaRadius=0,nMaxRadius=2560,nMinRadius=0},[3536]={nBrokenRate=0},[14786]={nAreaRadius=2560,nBrokenRate=0,nChannelFrame=20,nMaxRadius=2560,nMinRadius=0},[14720]={nBrokenRate=0},[14719]={nBrokenRate=0},[14200]={nBrokenRate=0},[14685]={nMaxRadius=2560,nAreaRadius=2560,nBrokenRate=0,nMinRadius=1280},[14684]={nMaxRadius=2560,nAreaRadius=2560,nBrokenRate=0,nMinRadius=1280},[3564]={nBrokenRate=0},[14611]={nAreaRadius=512,nMaxRadius=640,nMinRadius=0},[1448]={nBrokenRate=0},[14584]={nAreaRadius=960,nMaxRadius=6400,nMinRadius=0},[3580]={nBrokenRate=0},[14583]={nAreaRadius=960,nMaxRadius=6400,nMinRadius=0},[16398]={nBrokenRate=0},[3592]={nBrokenRate=0},[7190]={nBrokenRate=0},[14578]={nBrokenRate=0},[7206]={nBrokenRate=0},[14577]={nBrokenRate=0},[8299]={nAreaRadius=256,nMaxRadius=6400,nMinRadius=0},[7230]={nBrokenRate=0},[8331]={nBrokenRate=0},[14575]={nBrokenRate=0},[3628]={nBrokenRate=0},[14566]={nAreaRadius=192,nMaxRadius=2432,nMinRadius=0},[14475]={nAreaRadius=0,nMaxRadius=2560,nMinRadius=0},[14420]={nBrokenRate=0},[8837]={nAreaRadius=320,nMaxRadius=6400,nMinRadius=0},[5247]={nBrokenRate=0},[5255]={nBrokenRate=0},[14378]={nBrokenRate=0},[3660]={nBrokenRate=0},[3664]={nBrokenRate=0},[9440]={nChannelFrame=48},[14345]={nAreaRadius=960,nMaxRadius=6400,nMinRadius=0},[8176]={nBrokenRate=0},[7358]={nAreaRadius=640,nMaxRadius=1600,nMinRadius=0},[3684]={nMaxRadius=1280,nAreaRadius=512,nBrokenRate=0,nMinRadius=0},[3688]={nBrokenRate=0},[2050]={nBrokenRate=0},[6146]={nAreaRadius=384,nMaxRadius=1920,nMinRadius=0},[7398]={nBrokenRate=0},[5131]={nBrokenRate=0},[3708]={nBrokenRate=0},[2368]={nBrokenRate=0},[10347]={nBrokenRate=0},[1039]={nBrokenRate=0},[6198]={nAreaRadius=512,nMaxRadius=1920,nMinRadius=0},[8763]={nAreaRadius=320,nMaxRadius=1280,nMinRadius=0},[7809]={nBrokenRate=0},[3107]={nAreaRadius=640,nMaxRadius=1280,nMinRadius=0},[3109]={nAreaRadius=0,nMaxRadius=1280,nMinRadius=0},[14968]={nAreaRadius=512,nMaxRadius=3840,nMinRadius=0},[5447]={nBrokenRate=0},[13854]={nAreaRadius=512,nMaxRadius=5120,nMinRadius=0},[15016]={nAreaRadius=128,nMaxRadius=2432,nMinRadius=0},[3760]={nBrokenRate=0},[8907]={nBrokenRate=0},[1051]={nBrokenRate=0},[8939]={nBrokenRate=0},[8955]={nBrokenRate=0},[3780]={nAreaRadius=640,nMaxRadius=5120,nMinRadius=0},[1193]={nBrokenRate=0},[4208]={nBrokenRate=0},[3792]={nBrokenRate=0},[1055]={nBrokenRate=0},[3135]={nBrokenRate=0},[9471]={nBrokenRate=0},[3717]={nBrokenRate=0},[7869]={nBrokenRate=0},[13424]={nAreaRadius=1280,nMaxRadius=1280,nMinRadius=0},[13225]={nBrokenRate=0},[5599]={nBrokenRate=0},[9163]={nAreaRadius=576,nMaxRadius=2560,nMinRadius=0},[7662]={nBrokenRate=0},[5293]={nBrokenRate=0},[13305]={nBrokenRate=0},[15368]={nBrokenRate=0},[15384]={nBrokenRate=0},[2370]={nBrokenRate=0},[15416]={nBrokenRate=0},[3177]={nBrokenRate=0},[9307]={nBrokenRate=0},[15464]={nBrokenRate=0},[1348]={nBrokenRate=0},[14112]={nAreaRadius=3200,nMaxRadius=3840,nMinRadius=0},[3880]={nAreaRadius=192,nMaxRadius=6400,nMinRadius=0},[7393]={nBrokenRate=0},[9403]={nAreaRadius=512,nMaxRadius=2560,nMinRadius=0},[7782]={nBrokenRate=0},[7790]={nBrokenRate=0},[3900]={nBrokenRate=0},[7806]={nBrokenRate=0},[6444]={nChannelFrame=40},[3912]={nBrokenRate=0},[13587]={nBrokenRate=0},[13625]={nAreaRadius=640,nMaxRadius=64000,nMinRadius=0},[4364]={nBrokenRate=0},[6414]={nBrokenRate=0},[13534]={nAreaRadius=6400,nMaxRadius=19200,nMinRadius=0},[14050]={nBrokenRate=0},[13899]={nBrokenRate=0},[2271]={nBrokenRate=0},[7894]={nBrokenRate=0},[7902]={nBrokenRate=0},[7485]={nBrokenRate=0},[14149]={nAreaRadius=640,nMaxRadius=6400,nMinRadius=0},[1115]={nAreaRadius=384,nMaxRadius=1280,nMinRadius=0},[13213]={nAreaRadius=1280,nMaxRadius=6400,nMinRadius=0},[7942]={nBrokenRate=0},[3257]={nBrokenRate=0},[5495]={nBrokenRate=0},[4231]={nBrokenRate=0},[13897]={nBrokenRate=0},[8968]={nAreaRadius=2560,nMaxRadius=2560,nMinRadius=0},[13949]={nBrokenRate=0},[7786]={nAreaRadius=512,nMaxRadius=1920,nMinRadius=0},[13961]={nBrokenRate=0},[565]={nChannelFrame=48},[14147]={nBrokenRate=0},[16056]={nBrokenRate=0},[14025]={nBrokenRate=0},[9442]={nBrokenRate=0},[1136]={nBrokenRate=0},[1139]={nBrokenRate=0},[2282]={nBrokenRate=0},[1143]={nBrokenRate=0},[1147]={nBrokenRate=0},[5631]={nBrokenRate=0},[14376]={nAreaRadius=2560,nMaxRadius=2560,nMinRadius=0},[6063]={nAreaRadius=384,nMaxRadius=1920,nMinRadius=0},[13915]={nAreaRadius=320,nMaxRadius=2560,nMinRadius=0},[8126]={nBrokenRate=0},[13903]={nAreaRadius=384,nMaxRadius=6400,nMinRadius=0},[13148]={nAreaRadius=0,nMaxRadius=64000,nMinRadius=0},[6103]={nAreaRadius=512,nMaxRadius=1920,nMinRadius=0},[13891]={nBrokenRate=0},[4720]={nAreaRadius=384,nMaxRadius=1920,nMinRadius=0},[2346]={nBrokenRate=0},[589]={nAreaRadius=384,nMaxRadius=1280,nMinRadius=0},[16376]={nBrokenRate=0},[8204]={nBrokenRate=0},[2360]={nBrokenRate=0},[14377]={nAreaRadius=192,nMaxRadius=2560,nMinRadius=0},[4128]={nBrokenRate=0},[3393]={nAreaRadius=640,nMaxRadius=1600,nMinRadius=0},[6191]={nAreaRadius=0,nMaxRadius=63999936,nMinRadius=0},[4152]={nBrokenRate=0},[1041]={nBrokenRate=0},[333]={nAreaRadius=640,nMaxRadius=3200,nMinRadius=0},[6223]={nBrokenRate=0},[1047]={nBrokenRate=0},[1049]={nBrokenRate=0},[4200]={nBrokenRate=0},[2105]={nBrokenRate=0},[6263]={nAreaRadius=256,nMaxRadius=256,nMinRadius=0},[1194]={nBrokenRate=0},[9544]={nBrokenRate=0},[4240]={nBrokenRate=0},[4248]={nBrokenRate=0},[9398]={nAreaRadius=512,nMaxRadius=2560,nMinRadius=0},[1067]={nBrokenRate=0},[7897]={nBrokenRate=0},[2141]={nBrokenRate=0},[17136]={nMaxRadius=1920,nAreaRadius=256,nBrokenRate=0,nMinRadius=0},[304]={nAreaRadius=640,nMaxRadius=3200,nMinRadius=0},[8604]={nChannelFrame=80},[2157]={nBrokenRate=0},[1081]={nBrokenRate=0},[8809]={nBrokenRate=0},[17328]={nAreaRadius=512,nMaxRadius=1920,nMinRadius=0},[13591]={nBrokenRate=0},[8865]={nAreaRadius=320,nMaxRadius=1280,nMinRadius=0},[4360]={nBrokenRate=0},[2654]={nAreaRadius=384,nMaxRadius=1280,nMinRadius=0},[14165]={nAreaRadius=6400,nMaxRadius=3200,nMinRadius=0},[2193]={nBrokenRate=0},[5481]={nMaxRadius=1920,nAreaRadius=128,nBrokenRate=0,nMinRadius=0},[4400]={nBrokenRate=0},[13497]={nAreaRadius=320,nMaxRadius=6400,nMinRadius=0},[14969]={nBrokenRate=0},[14148]={nAreaRadius=960,nMaxRadius=6400,nMinRadius=0},[13416]={nAreaRadius=640,nMaxRadius=25600,nMinRadius=0},[6079]={nAreaRadius=384,nMaxRadius=1920,nMinRadius=0},[6083]={nAreaRadius=384,nMaxRadius=1920,nMinRadius=0},[4456]={nBrokenRate=0},[2233]={nMinRadius=0,nAreaRadius=384,nMaxRadius=1280,nChannelFrame=80},[3137]={nBrokenRate=0},[6147]={nAreaRadius=384,nMaxRadius=1920,nMinRadius=0},[3593]={nBrokenRate=0},[4496]={nBrokenRate=0},[3603]={nBrokenRate=0},[4137]={nAreaRadius=192,nMaxRadius=6400,nMinRadius=0},[1294]={nBrokenRate=0},[1133]={nBrokenRate=0},[1135]={nBrokenRate=0},[4177]={nBrokenRate=0},[9100]={nAreaRadius=2560,nMaxRadius=2560,nMinRadius=0},[13210]={nBrokenRate=0},[2285]={nBrokenRate=0},[2289]={nBrokenRate=0},[4584]={nAreaRadius=640,nMaxRadius=3840,nMinRadius=0},[5212]={nAreaRadius=512,nMaxRadius=1280,nMinRadius=0},[3641]={nBrokenRate=0},[9212]={nBrokenRate=0},[9228]={nBrokenRate=0},[16433]={nBrokenRate=0},[329]={nAreaRadius=512,nMaxRadius=1280,nMinRadius=0},[363]={nAreaRadius=0,nMaxRadius=1280,nMinRadius=0},[9489]={nBrokenRate=0},[330]={nAreaRadius=512,nMaxRadius=1280,nMinRadius=0},[6711]={nAreaRadius=384,nMaxRadius=6400,nMinRadius=0},[7318]={nChannelFrame=64},[9532]={nBrokenRate=0},[15513]={nBrokenRate=0},[2349]={nBrokenRate=0},[13498]={nAreaRadius=320,nMaxRadius=6400,nMinRadius=0},[7954]={nBrokenRate=0},[2361]={nBrokenRate=0},[13546]={nAreaRadius=192,nMaxRadius=640,nMinRadius=0},[13224]={nAreaRadius=128,nMaxRadius=25600,nMinRadius=0},[4744]={nAreaRadius=192,nMaxRadius=3840,nMinRadius=0},[15641]={nBrokenRate=0},[2636]={nChannelFrame=80},[13626]={nAreaRadius=320,nMaxRadius=64000,nMinRadius=0},[3691]={nAreaRadius=0,nMaxRadius=63999936,nMinRadius=0},[1347]={nBrokenRate=0},[300]={nChannelFrame=80},[1351]={nBrokenRate=0},[6080]={nAreaRadius=384,nMaxRadius=1920,nMinRadius=0},[9147]={nBrokenRate=0},[302]={nAreaRadius=0,nMaxRadius=0,nMinRadius=0},[2724]={nChannelFrame=40},[13157]={nAreaRadius=6400,nMaxRadius=19200,nMinRadius=0},[4848]={nAreaRadius=384,nMaxRadius=1920,nMinRadius=0},[13802]={nBrokenRate=0},[6911]={nAreaRadius=0,nMaxRadius=1280,nMinRadius=0},[3533]={nBrokenRate=0},[6927]={nBrokenRate=0},[13105]={nAreaRadius=640,nMaxRadius=25600,nMinRadius=0},[1375]={nBrokenRate=0},[6951]={nBrokenRate=0},[6184]={nBrokenRate=0},[3108]={nAreaRadius=384,nMaxRadius=1280,nMinRadius=0},[17649]={nBrokenRate=0},[13962]={nBrokenRate=0},[13016]={nChannelFrame=80},[10399]={nBrokenRate=0},[16057]={nBrokenRate=0},[14026]={nBrokenRate=0},[1245]={nBrokenRate=0},[10346]={nBrokenRate=0},[1249]={nBrokenRate=0},[7047]={nAreaRadius=320,nMaxRadius=1280,nMinRadius=0},[9519]={nBrokenRate=0},[13254]={nBrokenRate=0},[9170]={nBrokenRate=0},[5616]={nBrokenRate=0},[3182]={nBrokenRate=0},[9505]={nBrokenRate=0},[706]={nAreaRadius=384,nMaxRadius=3200,nMinRadius=0},[2533]={nBrokenRate=0},[16281]={nAreaRadius=192,nMaxRadius=6400,nMinRadius=0},[2824]={nBrokenRate=0},[16313]={nBrokenRate=0},[357]={nAreaRadius=0,nMaxRadius=1280,nMinRadius=0},[8129]={nBrokenRate=0},[8339]={nBrokenRate=0},[9470]={nBrokenRate=0},[8205]={nBrokenRate=0},[1635]={nBrokenRate=0},[322]={nAreaRadius=640,nMaxRadius=3200,nMinRadius=0},[3891]={nAreaRadius=192,nMaxRadius=63999936,nMinRadius=0},[323]={nAreaRadius=640,nMaxRadius=3200,nMinRadius=0},[7215]={nBrokenRate=0},[324]={nAreaRadius=640,nMaxRadius=3200,nMinRadius=0},[2874]={nBrokenRate=0},[325]={nAreaRadius=640,nMaxRadius=3200,nMinRadius=0},[1443]={nBrokenRate=0},[326]={nAreaRadius=256,nMaxRadius=3200,nMinRadius=0},[8381]={nAreaRadius=512,nMaxRadius=16384,nMinRadius=0},[327]={nAreaRadius=512,nMaxRadius=1280,nMinRadius=0},[9490]={nBrokenRate=0},[328]={nAreaRadius=512,nMaxRadius=1280,nMinRadius=0},[14586]={nBrokenRate=0},[5256]={nBrokenRate=0},[9419]={nBrokenRate=0},[7319]={nChannelFrame=96},[9404]={nAreaRadius=128,nMaxRadius=9600,nMinRadius=0},[331]={nAreaRadius=512,nMaxRadius=1280,nMinRadius=0},[7343]={nBrokenRate=0},[332]={nAreaRadius=640,nMaxRadius=3200,nMinRadius=0},[8792]={nAreaRadius=128,nMaxRadius=6400,nMinRadius=0},[8589]={nAreaRadius=320,nMaxRadius=2560,nMinRadius=0},[3985]={nBrokenRate=0,nChannelFrame=128},[334]={nAreaRadius=640,nMaxRadius=3200,nMinRadius=0},[13942]={nBrokenRate=0},[7399]={nBrokenRate=0},[8891]={nBrokenRate=0},[17362]={nMaxRadius=6400,nAreaRadius=640,nBrokenRate=0,nMinRadius=0},[1514]={nBrokenRate=0},[8717]={nBrokenRate=0},[1349]={nBrokenRate=0},[5400]={nAreaRadius=320,nMaxRadius=1280,nMinRadius=0},[7367]={nAreaRadius=640,nMaxRadius=1280,nMinRadius=0},[5416]={nAreaRadius=384,nMaxRadius=5120,nMinRadius=0},[1357]={nBrokenRate=0},[8932]={nBrokenRate=0,nChannelFrame=96},[17650]={nBrokenRate=0},[17682]={nAreaRadius=256,nMaxRadius=1280,nMinRadius=0},[7503]={nBrokenRate=0},[8877]={nBrokenRate=0},[1547]={nBrokenRate=0},[5480]={nAreaRadius=128,nMaxRadius=960,nMinRadius=0},[7535]={nBrokenRate=0},[5496]={nBrokenRate=0},[8300]={nAreaRadius=384,nMaxRadius=6400,nMinRadius=0},[5512]={nBrokenRate=0},[1381]={nBrokenRate=0},[15146]={nBrokenRate=0},[8788]={nBrokenRate=0},[3134]={nBrokenRate=0},[13147]={nAreaRadius=0,nMaxRadius=64000,nMinRadius=0},[6268]={nAreaRadius=256,nMaxRadius=64000,nMinRadius=0},[4230]={nBrokenRate=0},[7623]={nBrokenRate=0},[13211]={nAreaRadius=768,nMaxRadius=6400,nMinRadius=0},[9133]={nBrokenRate=0,nChannelFrame=96},[15290]={nBrokenRate=0},[4306]={nBrokenRate=0},[2809]={nBrokenRate=0},[5624]={nBrokenRate=0},[7679]={nBrokenRate=0},[3196]={nBrokenRate=0},[1413]={nBrokenRate=0},[2829]={nBrokenRate=0},[15418]={nBrokenRate=0},[7719]={nBrokenRate=0},[5233]={nBrokenRate=0},[15466]={nAreaRadius=960,nMaxRadius=1920,nMinRadius=0},[5473]={nAreaRadius=320,nMaxRadius=5120,nMinRadius=0},[7751]={nBrokenRate=0},[5477]={nBrokenRate=0},[358]={nAreaRadius=0,nMaxRadius=1280,nMinRadius=0},[7317]={nChannelFrame=48},[359]={nAreaRadius=0,nMaxRadius=1280,nMinRadius=0},[8440]={nAreaRadius=640,nMaxRadius=6400,nMinRadius=0},[360]={nAreaRadius=0,nMaxRadius=1280,nMinRadius=0},[2881]={nBrokenRate=0},[361]={nAreaRadius=0,nMaxRadius=1280,nMinRadius=0},[2889]={nBrokenRate=0},[362]={nAreaRadius=0,nMaxRadius=1280,nMinRadius=0},[9533]={nBrokenRate=0},[2901]={nBrokenRate=0},[14207]={nBrokenRate=0},[8354]={nAreaRadius=320,nMaxRadius=2880,nMinRadius=0},[8287]={nAreaRadius=512,nMaxRadius=76800,nMinRadius=0},[7366]={nAreaRadius=640,nMaxRadius=256,nMinRadius=0},[8270]={nAreaRadius=320,nMaxRadius=6400,nMinRadius=0},[7799]={nAreaRadius=256,nMaxRadius=1280,nMinRadius=0},[17267]={nAreaRadius=384,nMaxRadius=3840,nMinRadius=0},[15818]={nBrokenRate=0},[7919]={nBrokenRate=0},[368]={nMinRadius=0,nAreaRadius=384,nMaxRadius=960,nChannelFrame=80},[9453]={nBrokenRate=0},[17427]={nBrokenRate=0},[3604]={nAreaRadius=2560,nMaxRadius=2560,nMinRadius=0},[7770]={nBrokenRate=0},[7967]={nChannelFrame=96},[371]={nAreaRadius=0,nMaxRadius=1280,nMinRadius=0},[7983]={nBrokenRate=0},[13931]={nAreaRadius=256,nMaxRadius=640,nMinRadius=0},[3602]={nBrokenRate=0},[8007]={nAreaRadius=256,nMaxRadius=6400,nMinRadius=0},[2589]={nChannelFrame=96},[3616]={nBrokenRate=0},[8031]={nAreaRadius=256,nMaxRadius=6400,nMinRadius=0},[8039]={nBrokenRate=0},[1501]={nBrokenRate=0},[14059]={nBrokenRate=0},[9493]={nBrokenRate=0},[7228]={nBrokenRate=0},[7368]={nAreaRadius=640,nMaxRadius=1280,nMinRadius=0},[16170]={nBrokenRate=0},[3025]={nBrokenRate=0},[4757]={nBrokenRate=0},[3033]={nBrokenRate=0},[2777]={nBrokenRate=0},[8127]={nBrokenRate=0},[2885]={nBrokenRate=0},[1979]={nBrokenRate=0},[1996]={nBrokenRate=0},[2008]={nBrokenRate=0},[2026]={nBrokenRate=0}}
--printT(_RN.tSkillEx)
---------------------------------------------------------------------
-- 本地函数和变量
---------------------------------------------------------------------
local _RN_TargetMon = {
	tCD = {},
	lastTar = 0,
}

-- get skill name by id
local function _s(dwSkillID)
	local szName, _ = RN.GetSkillName(dwSkillID)
	return szName
end

-- get buff name by id
local function _b(dwBuffID, dwLevel)
	local szName, _ = RN.GetBuffName(dwBuffID, dwLevel)
	return szName
end

_RN_TargetMon.tSkillList4 = {
	{		-- 少林
		[_s(258)--[[舍身诀]]] = 45,
		[_s(242)--[[捉影式]]] = 20,
		[_s(18604)--[[千斤坠]]] = 25,
		[_s(261)--[[无相诀]]] = 60,
		[_s(240)--[[抢珠式]]] = 25,
		[_s(252)--[[大狮子吼]]] = 13,
		[_s(257)--[[锻骨诀]]] = 35,
	},  {	-- 万花
		[_s(182)--[[玉石俱焚]]] = 17,
		[_s(100)--[[星楼月影]]] = 24,
		[_s(132)--[[春泥护花]]] = 30,
		[_s(186)--[[芙蓉并蒂]]] = 20,
		[_s(183)--[[厥阴指]]] = 10,
		[_s(136)--[[水月无间]]] = 60,
		[_s(228)--[[太阴指]]] = 17,
		[_s(14965)--[[南风吐月]]] = 105,
		[_s(2645)--[[乱洒青荷]]] = 60,
		[_s(2663)--[[听风吹雪]]] = 120,
		[_s(14963)--[[折叶笼花]]] = 120,
	}, {	-- 天策
		[_s(412)--[[疾如风]]] = 50,
        [_s(413)--[[守如山]]] = 110,
        [_s(18240)--[[沧月]]] = 20,
		[_s(418)--[[突]]] = 17,
		[_s(422)--[[啸如虎]]] = 90,
		[_s(428)--[[断魂刺]]] = 23,
		[_s(433)--[[任驰骋]]] = 40,
		[_s(423)--[[灭]]] = 24,
		[_s(2628)--[[渊]]] = 45,
		[_s(424)--[[疾]]] = 25,
	}, {	-- 纯阳
		[_s(15187)--[[行天道]]] = 60,
		[_s(363)--[[吞日月]]] = 10,
		[_s(307)--[[剑冲阴阳]]] = 30,
		[_s(366)--[[大道无术]]] = 20,
		[_s(588)--[[人剑合一]]] = 15,
		[_s(310)--[[剑飞惊天]]] = 20,
		[_s(372)--[[转乾坤]]] = 120,
		[_s(355)--[[凭虚御风]]] = 30,
		[_s(312)--[[坐忘无我]]] = 18,
		----------------------------------
		[_s(371)--[[镇山河]]] = 240,
		[_s(2681)--[[紫气东来]]] = 60,
		[_s(305)--[[九转归一]]] = 15,
		[_s(302)--[[五方行尽]]] = 15,
		[_s(303)--[[三才化生]]] = 20,

		[_s(370)--[[八卦洞玄]]] = 25,
		[_s(358)--[[生太极]]] = 10,
		[_s(2699)--[[八荒归元]]] = 14,
		[_s(346)--[[梯云纵]]] = 30,
	},  {	-- 七秀
		[_s(544)--[[帝骖龙翔]]] = 40,
		[_s(546)--[[剑影留痕]]] = 10,
		[_s(2716)--[[剑破虚空]]] = 10,
		[_s(547)--[[剑心通明]]] = 30,
		[_s(550)--[[鹊踏枝]]] = 55,
		[_s(18579)--[[水榭花盈]]] = 40,
		[_s(574)--[[蝶弄足]]] = 75,
		[_s(557)--[[天地低昂]]] = 45,
		[_s(569)--[[王母挥袂]]] = 10,
		[_s(555)--[[风袖低昂]]] = 35,
		[_s(558)--[[雷霆震怒]]] = 90,
		[_s(568)--[[繁音急节]]] = 54,
	},  {	-- 五毒
		[_s(2212)--[[百足]]] = 12,
		[_s(2218)--[[幻蛊]]] = 30,
		[_s(2228)--[[化蝶]]] = 30,
		[_s(18584)--[[灵蛊]]] = 20,
		[_s(2226)--[[蛊虫献祭]]] = 27,
		[_s(2230)--[[女娲补天]]] = 54,
		[_s(2227)--[[蛊虫狂暴]]] = 120,
		[_s(2957)--[[圣手织天]]] = 18,
		[_s(2235)--[[千蝶吐瑞]]] = 60,
	},  {	-- 唐门
		[_s(3115)--[[荆天棘地]]] = 35,
		[_s(3114)--[[惊鸿游龙]]] = 60,
		[_s(3090)--[[迷神钉]]] = 20,
		[_s(3089)--[[雷震子]]] = 25,
		[_s(3094)--[[心无旁骛]]] = 120,
		[_s(3112)--[[浮光掠影]]] = 90,
		[_s(3103)--[[飞星遁影]]] = 40,
		[_s(3101)--[[逐星箭]]] = 10,
		[_s(3118)--[[鸟翔碧空]]] = 25,
		[_s(18675)--[[千秋万劫]]] = 50,
		[_s(3110)--[[鬼斧神工]]] = 120,


	},  {	-- 藏剑
		[_s(1577)--[[玉虹贯日]]] = 15,
		[_s(1580)--[[玉泉鱼跃]]] = 30,
		[_s(1589)--[[梦泉虎跑]]] = 24,
		[_s(18322)--[[鹤归孤山]]] = 16,
		[_s(1645)--[[风来吴山]]] = 90,
		[_s(1613)--[[峰插云景]]] = 15,
		[_s(1649)--[[醉月]]] = 15,
		[_s(1656)--[[啸日]]] = 12,
		[_s(1663)--[[莺鸣柳]]] = 90,
		[_s(1666)--[[泉凝月]]] = 40,
		[_s(1668)--[[云栖松]]] = 100,
		[_s(1665)--[[风吹荷]]] = 20,
		[_s(1647)--[[惊涛]]] = 12,
		[_s(1655)--[[探梅]]] = 20,

	},  {	-- 丐帮
		-- [_s(5265)--[[见龙在田]]] = 23,
		[_s(5262)--[[龙跃于渊]]] = 8,
		[_s(5257)--[[蜀犬吠日]]] = 45,
		[_s(5259)--[[棒打狗头]]] = 20,
		[_s(5267)--[[龙啸九天]]] = 36,
		[_s(5269)--[[烟雨行]]] = 30,
		[_s(5270)--[[笑醉狂]]] = 90,
		-- [_s(5272)--[[醉逍遥]]] = 60,
	},  {	-- 明教
		[_s(3977)--[[流光囚影]]] = 12,
		[_s(3975)--[[怖畏暗刑]]] = 28,
		[_s(3973)--[[贪魔体]]] = 45,
		[_s(3974)--[[暗尘弥散]]] = 45,
		[_s(3978)--[[生灭予夺]]] = 120,
		[_s(4910)--[[无明魂锁]]] = 25,
		[_s(3969)--[[光明相]]] = 105,
		[_s(3968)--[[如意法]]] = 60,
		[_s(3971)--[[极乐引]]] = 45,
		[_s(3970)--[[幻光步]]] = 30,
		[_s(18626)--[[伏明众生]]] = 25,
		[_s(18629)--[[冥月渡心]]] = 45,

	},
	-- 江湖
	[0] = {
		[_s(9003)--[[蹑云逐月]]] = 30,
		[_s(9002)--[[扶摇直上]]] = 30,
	},
	-- 苍云
	[21] = {
		[_s(13046)--[[盾猛]]] = 15,
		[_s(13050)--[[盾飞]]] = 18,
		[_s(13068)--[[盾毅]]] = 45,
		[_s(13049)--[[盾墙]]] = 35,
		[_s(13424)--[[撼地]]] = 20,
		[_s(13070)--[[盾壁]]] = 90,
		[_s(13042)--[[无惧]]] = 30,
		[_s(13067)--[[盾立]]] = 35,
		[_s(13054)--[[斩刀]]] = 12,
		[_s(13040)--[[血怒]]] = 25,
	},
	-- 长歌
	[22] = {
		[_s(14073)--[[笑傲光阴]]] = 60,
		[_s(14074)--[[江逐月天]]] = 60,
		[_s(14075)--[[云生结海]]] = 60,
		[_s(14154)--[[迴梦逐光]]] = 60,
		[_s(14076)--[[青霄飞羽]]] = 35,
		[_s(14081)--[[孤影化双]]] = 180,
		[_s(14082)--[[疏影横斜]]] = 20,
		[_s(14083)--[[清绝影歌]]] = 60,
		[_s(14093)--[[冲秋冥]]] = 15,
		[_s(14095)--[[清音长啸]]] = 20,
		[_s(15068)--[[琴音共鸣]]] = 90,
	},
	-- 霸刀
	[23] = {
		[_s(16608)--[[散流霞]]] = 40,
		[_s(16598)--[[雷走风切]]] = 16,
		[_s(16460)--[[踏宴扬旗]]] = 20,
		[_s(16479)--[[割据秦宫]]] = 20,
		[_s(16620)--[[封渊震煞]]] = 40,
		[_s(16870)--[[擒龙六斩]]] = 10,
		[_s(16459)--[[临渊蹈河]]] = 30,
		[_s(16621)--[[坚壁清野]]] = 30,
		[_s(16455)--[[楚河汉界]]] = 35,
		[_s(16454)--[[西楚悲歌]]] = 50,
	},
}



-- 充能技能
_RN_TargetMon.tChongNeng = {
		[_s(228)--[[太阴指]]] = 2,
		[_s(568)--[[繁音急节]]] = 2,
		[_s(574)--[[蝶弄足]]] = 2,
		[_s(550)--[[鹊踏枝]]] = 2,
		[_s(569)--[[王母挥袂]]] = 2,
		[_s(242)--[[捉影式]]] = 2,
		[_s(2681)--[[紫气东来]]] = 3,
		[_s(418)--[[突]]] = 2,
		[_s(433)--[[任驰骋]]] = 2,
		[_s(1656)--[[啸日]]] = 2,
		[_s(1663)--[[莺鸣柳]]] = 3,
		[_s(18584)--[[灵蛊]]] = 3,
		[_s(3101)--[[逐星箭]]] = 2,
		[_s(3103)--[[飞星遁影]]] = 2,
		[_s(3973)--[[贪魔体]]] = 2,
		[_s(3977)--[[流光囚影]]] = 2,
		[_s(5269)--[[烟雨行]]] = 2,
		[_s(13050)--[[盾飞]]] = 3,
		[_s(13040)--[[血怒]]] = 3,
		[_s(13067)--[[盾立]]] = 3,
		[_s(14082)--[[疏影横斜]]] = 3,
}

-- 透支技能
_RN_TargetMon.tTouZhi = {
	[_s(16608)--[[散流霞]]] = 3,
	[_s(16598)--[[雷走风切]]] = 3,
	[_s(16460)--[[踏宴扬旗]]] = 3,
	[_s(16602)--[[破釜沉舟]]] = 3,
	[_s(16479)--[[割据秦宫]]] = 3,
	[_s(16620)--[[封渊震煞]]] = 3,
}
-- 重置技能CD
_RN_TargetMon.tSkillReset = {
	[_s(433)--[[任驰骋]]] = { _s(428)--[[断魂刺]], _s(426)--[[破坚阵]], _s(18240)--[[沧月]] },
	[_s(346)--[[梯云纵]]] = { _s(9003)--[[蹑云逐月]] },
	[_s(2645)--[[乱洒青荷]]] = { _s(182)--[[玉石俱焚]] },
	[_s(3978)--[[生灭予夺]]] = { _s(3974)--[[暗尘弥散]], _s(3975)--[[怖畏暗刑]], _s(4910)--[[无明魂锁]], _s(3977)--[[流光囚影]], _s(3976)--[[业海罪缚]], _s(3979)--[[驱夜断愁]] },
	[_s(14081)--[[孤影化双]]] = { _s(14073)--[[笑傲光阴]], _s(14074)--[[江逐月天]], _s(14075)--[[云生结海]], _s(14154)--[[迴梦逐光]] },
	[_s(5269)--[[烟雨行]]] = { _s(5259)--[[棒打狗头]] },
}


-- 加载监视器缓存tSkillCache
_RN_TargetMon.LoadSkillMon = function()
	local aCache = {}
	for _, v in pairs(_RN_TargetMon.tSkillList4) do
		for kk, vv in pairs(v) do
			aCache[kk] = vv
		end
	end
	_RN_TargetMon.tSkillCache = aCache
end

-- 从监视器缓存tSkillCache获取技能CD
_RN_TargetMon.GetSkillMonCD = function(szName)
	if not _RN_TargetMon.tSkillCache then
		_RN_TargetMon.LoadSkillMon()
	end
	return _RN_TargetMon.tSkillCache[szName]
end

-- 获取指定玩家的所有CD
_RN_TargetMon.GetPlayerCD = function(dwPlayer)
	local aCD, nFrame = {}, GetLogicFrameCount()
	if _RN_TargetMon.tCD[dwPlayer] then
		aCD = _RN_TargetMon.tCD[dwPlayer]
		for k, v in ipairs(aCD) do
			if v.nEnd < nFrame then
				table.remove(aCD, k)
			end
		end
	end
	return aCD
end

-- 获取门派名称
_RN_TargetMon.GetForceTitle = function(nForce)
	if nForce > 0 and g_tStrings.tForceTitle[nForce] then
		return g_tStrings.tForceTitle[nForce]
	end
	return g_tStrings.tForceTitle[0]
end

-- 获取技能所属的门派
_RN_TargetMon.GetSkillForce = function(szName)
	local nCount = g_tTable.Skill:GetRowCount()
	for i = 1, nCount do
		local tLine = g_tTable.Skill:GetRow(i)
		if tLine.bShow and tLine.dwIconID ~= 13 and tLine.szName == szName then
			local skill = GetSkill(tLine.dwSkillID, 1)
			if skill then
				local szSchool = Table_GetSkillSchoolName(skill.dwBelongSchool)
				for k, v in pairs(g_tStrings.tForceTitle) do
					if k > 0 and v == szSchool then
						return k
					end
				end
				return 0
			end
		end
	end
end

-- 获取时间差与要显示的字体(100秒以内204,10小时内203)
_RN_TargetMon.GetLeftTime = function(nEndFrame, bFloat)
	local nSec = (nEndFrame - GetLogicFrameCount()) / 16
	if nSec < 100 then	--100秒以内
		if bFloat and nSec < 3 then		--3秒以内
			return string.format("%.1f\"", nSec), 204
		else
			return string.format("%d\"", nSec), 204
		end
	elseif nSec < 3600 then		--1小时以内
		return string.format("%d'", nSec / 60), 203
	elseif nSec < 36000 then	--10小时以内 
		return string.format("%d", nSec / 3600), 203
	else
		return "", 203
	end
end
-- 获取时间差与要显示的字体(100秒以内204,10小时内203)
_RN_TargetMon.GetLeftTimeSec = function(nEndFrame)
	local nSec = (nEndFrame - GetLogicFrameCount()) / 16
	return nSec
end

_RN_TargetMon.UpdateSkillTimer = function(data)
	local nChongNeng = _RN_TargetMon.tChongNeng[data.szName]
	if nChongNeng then
		local nLogicFrame = GetLogicFrameCount()
		local nSec = _RN_TargetMon.GetSkillMonCD(data.szName)
		local nLeftSec = (data.nEnd - nLogicFrame) / 16
		--if math.ceil(nLeftSec / nSec) == nChongNeng then -- 进入CD状态
			--s_Output(data.szName,"进入CD",(1 - nLeftSec % nSec / nSec))
		--else -- 否则进入充能状态
			--s_Output(data.szName,"进入充能")
		--end
		local szTime = _RN_TargetMon.GetLeftTimeSec(data.nEnd - (math.floor(nLeftSec / nSec) * nSec * 16))
		--s_Output("red",data.szName.."-充能："..nChongNeng - math.ceil(nLeftSec / nSec),szTime,data.dwSkillID)
		GAY3SkillTimer.AddTimer("red",data.szName.."-充能："..nChongNeng - math.ceil(nLeftSec / nSec),szTime,data.dwSkillID,data.nTotal/16)
		return 0
	else
		local szTime = _RN_TargetMon.GetLeftTimeSec(data.nEnd)
		local nTouzhi = _RN_TargetMon.tTouZhi[data.szName]
		if nTouzhi then
			--s_Output(data.szName, szTime, string.format("%.2f ",1 - (data.nEnd - GetLogicFrameCount()) / data.nTotal))
			--s_Output(data.szName,"可释放层数：", nTouzhi - data.nUsed)
			--s_Output("blue",data.szName.."-透支："..nTouzhi - data.nUsed,szTime,data.dwSkillID)
			GAY3SkillTimer.AddTimer("blue",data.szName.."-透支："..nTouzhi - data.nUsed,szTime,data.dwSkillID,data.nTotal/16)
			return 0
		else
			--s_Output("green",data.szName,szTime,data.dwSkillID)
			GAY3SkillTimer.AddTimer("green",data.szName,szTime,data.dwSkillID,data.nTotal/16)
			return 0
		end
	end
end
-- breathe
_RN_TargetMon.OnFrameBreathe = function()
	-- base check
	local nFrame, me = GetLogicFrameCount(), GetClientPlayer()
	if not me or (nFrame % 2) ~= 0 then return end
	--获取当前目标
	local tar = GetTargetHandle(me.GetTarget())
	if not tar then 
		GAY3SkillTimer.Clear()
		return 
	end
	if _RN_TargetMon.lastTar == tar.dwID then
		if (nFrame % 8) ~= 0 then return end
	else
		_RN_TargetMon.lastTar = tar.dwID
	end
	--local tar = me
	-- 绘制当前目标的技能监控器UI
	GAY3SkillTimer.Clear()
	if tar and _RN_TargetMon.tCD[tar.dwID] then
		for _, v in ipairs(_RN_TargetMon.tCD[tar.dwID]) do
			if v.nEnd > nFrame then
				--printT(v)
				_RN_TargetMon.UpdateSkillTimer(v)
			end
		end
	end
end



---------------------------------------------------------------------
-- 事件处理函数
---------------------------------------------------------------------
_RN_TargetMon.OnSkillCast = function(dwCaster, dwSkillID, dwLevel)
	-- 获取技能名和图标ID
	local szName, dwIconID = RN.GetSkillName(dwSkillID, dwLevel)
	if not szName or szName == "" or dwIconID == 13 then
		return
	end
	-- 如果是充能技能或是透支技能
	local nChongNeng = _RN_TargetMon.tChongNeng[szName] or _RN_TargetMon.tTouZhi[szName]
	
	if nChongNeng then
		--s_util.OutputTip("充能透支："..nChongNeng)
	end
	-- 如果是引导技能 (skip effect log)
	if RN.GetChannelSkillFrame(dwSkillID) then
		return
	end
	-- 检查重置技能
	local aReset = _RN_TargetMon.tSkillReset[szName] or {}
	for _, v in ipairs(aReset) do
		local aCD = _RN_TargetMon.tCD[dwCaster] or {}
		for kk, vv in ipairs(aCD) do
			if vv.szName == v then
				table.remove(aCD, kk)
			end
		end
	end
	
	-- 检查CD
	-- 获取技能的原始CD
	local nSec = _RN_TargetMon.GetSkillMonCD(szName)
	if nSec then
		local bAdd = true
		local nTotal = nSec * 16	--用逻辑帧表示的技能CD总计
		local nLogicFrameCount = GetLogicFrameCount()
		--下次技能CD结束的逻辑帧
		local nEnd = nLogicFrameCount + nTotal
		if not _RN_TargetMon.tCD[dwCaster] then
			_RN_TargetMon.tCD[dwCaster] = {}
		else
			for k, v in ipairs(_RN_TargetMon.tCD[dwCaster]) do
				if v.szName == szName then
					if nChongNeng then	--如果是充能技能或是透支技能
						if v.nEnd > nLogicFrameCount then	--如果该技能CD结束的逻辑帧大于当前逻辑帧
							v.nEnd   = v.nEnd + nTotal	--将技能CD结束的逻辑帧自增一个技能CD总计
							v.nTotal = v.nTotal + nTotal	--将技能CD总计自增一个技能CD总计
							v.nUsed = v.nUsed + 1	--使用过的次数+1
							bAdd = false	--不需要被添加
						end
					end
					if bAdd then	--删除对应的技能CD
						table.remove(_RN_TargetMon.tCD[dwCaster], k)
					end
					break
				end
			end
		end
		if bAdd then	--如果需要添加
			table.insert(_RN_TargetMon.tCD[dwCaster], {
				nEnd = nEnd, nTotal = nTotal,
				dwSkillID = dwSkillID, dwLevel = dwLevel,
				dwIconID = dwIconID, szName = szName,
				nUsed = 1,
			})
		end
	end
end






----------------




local tPlugin = {
--插件在菜单中显示的名字。必须设置
["szName"] = szPluginName,

--插件类型。  1(5人副本)， 2(10人副本)， 3(25人副本)，4(竞技场)，5(其他)。必须设置
["nType"] = 4,

--绑定的地图ID。进入对应地图自动启用。这个是可选的，注意不要重复。如果没有设置，也可以在游戏中手动开启插件
["dwMapID"] = {127,128,129,238,277},--天山碎冰谷，乐山大佛窟，华山之巅，青竹书院，拭剑台

--初始化函数，启用插件会调用。没有参数。返回一个bool值，指示插件是否初始化成功。如果返回false，插件不会启用。可以在这里检查插件使用的必要条件（比如地图ID对不对之类的）
["OnInit"] = function()
	local player = GetClientPlayer()
	s_util.OutputSysMsg("插件 "..szPluginName.." 已启用")
	s_util.OutputSysMsg("欢迎 "..player.szName.." 使用本插件")
	s_util.OutputSysMsg("插件作者：(°—°〃)")
	s_util.OutputSysMsg("使用GAY3SkillTimer作为UI显示，绿色为普通技能，红色为充能技能，蓝色为透支技能")
	return true
end,

--每帧都会调用（1秒16帧)。没有参数。由于调用频繁，如果实现复杂，对性能有一定影响。
["OnTick"] = function()
	_RN_TargetMon.OnFrameBreathe()
end,

--有警告信息会调用，参数：类型，内容
["OnWarning"] = function(szType, szText)
	s_Output("OnWarning: "..szText)
end,

--有聊天信息会调用，参数： 对象ID，内容，名字，频道
["OnTalk"] = function(dwID, szText, szName, nChannel)
	
end,

--施放技能调用， 参数：对象ID， 技能ID， 技能等级
["OnCastSkill"] = function(dwID, dwSkillID, dwLevel, targetClass, tidOrx, y, z)
	_RN_TargetMon.OnSkillCast(dwID,dwSkillID,dwLevel)
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