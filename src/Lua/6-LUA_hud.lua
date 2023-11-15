if not (rawget(_G, "customhud")) return end
local modname = "takisthefox"

--HEALTH----------

local function drawheartcards(v,p)

	if (customhud.CheckType("takis_heartcards") != modname) return end
	
	local amiinsrbz = false
	
	if (gametype == GT_SRBZ)
		if (not p.chosecharacter)
		or p.shop_open
			amiinsrbz = true
		end
	end
	
	if p.takistable.inNIGHTSMode
	or (TAKIS_NET.inspecialstage)
	or amiinsrbz
		return
	end
	
	local xoff = 20*FU
	local takis = p.takistable
	local halfwidth = (v.width()*FU)/4
	local me = p.mo
	
	local maxx = (15*FU)*TAKIS_MAX_HEARTCARDS
	if TAKIS_MAX_HEARTCARDS > 6
		maxx = $-((TAKIS_MAX_HEARTCARDS-6)*FU)
		xoff = $-((FU)*(TAKIS_MAX_HEARTCARDS-6))
	elseif TAKIS_MAX_HEARTCARDS < 6
		xoff = $+((FU*2)*(TAKIS_MAX_HEARTCARDS))
	end
	
	--heart cards
	for i = 1, TAKIS_MAX_HEARTCARDS do
		
		local maxline = 14
		local linebreak = i/maxline
		
		local j = i
		if (TAKIS_MAX_HEARTCARDS == 1)
			j = 0
		end
		
		local eflag = V_HUDTRANS
		
		--patch
		local patch = v.cachePatch("HEARTCARD1")
		if ultimatemode
			patch = v.cachePatch("HEARTCARD3")
		end
		
		if TAKIS_MAX_HEARTCARDS-i > takis.heartcards-1
		or p.spectator
			patch = v.cachePatch("HEARTCARD2")
			if p.spectator
				eflag = V_HUDTRANSHALF
			end
		end			
		--
		
		--always make the first card (onscreen) go up
		local add = -3*FU
		local iseven = TAKIS_MAX_HEARTCARDS%2 == 0
		if (i%2 and iseven)
		or (not (i%2) and not iseven)
			add = 3*FU
		end
		
		if TAKIS_MAX_HEARTCARDS == 1
			add = 0
		end
		
		--shake
		local shakex,shakey = 0,0
				
		if takis.HUD.heartcards.shake
		and not (paused)
		and not (menuactive and takis.isSinglePlayer)
			
			local s = takis.HUD.heartcards.shake
			shakex,shakey = v.RandomFixed()/2,v.RandomFixed()/2
			
			local d1 = v.RandomRange(-1,1)
			local d2 = v.RandomRange(-1,1)
			if d1 == 0
				d1 = v.RandomRange(-1,1)
			end
			if d2 == 0
				d2 = v.RandomRange(-1,1)
			end
		
			shakex = $*s*d1
			shakey = $*s*d2
		end
		--
		
		--draw from last to first
		local flags = V_SNAPTOLEFT|V_SNAPTOTOP|V_PERPLAYER|eflag
		v.drawScaled(maxx-((13*FU)*j)+xoff+shakex,
			15*FU+add-takis.HUD.heartcards.add+shakey,
			4*FU/5, patch, flags
		)
	end

	--heal indc.
	/*
	if takis.heartcards ~= TAKIS_MAX_HEARTCARDS
	and not (takis.fakeexiting)
	and (me.health or p.playerstate == PST_LIVE)
		v.drawString((maxx/FU)+10+(xoff/FU),15+4,takis.heartcardpieces,V_SNAPTOLEFT|V_SNAPTOTOP|V_HUDTRANS|V_PERPLAYER,"thin")
		v.drawString((maxx/FU)+10+4+(xoff/FU),15+4+4,"/",V_SNAPTOLEFT|V_SNAPTOTOP|V_HUDTRANS|V_PERPLAYER,"thin")
		v.drawString((maxx/FU)+10+7+(xoff/FU),15+8+3-2+4,"7",V_SNAPTOLEFT|V_SNAPTOTOP|V_HUDTRANS|V_PERPLAYER,"thin")
		v.drawScaled(maxx+(10*FU)+(25*FU)+xoff, 33*FU, FU/2,v.getSpritePatch("RING", A, 0, 0), V_SNAPTOLEFT|V_SNAPTOTOP|V_HUDTRANS|V_PERPLAYER)
	end
	*/
	
end

--      ----------

--FACE  ----------

--referencing doom's status face code
-- https:--github.com/id-Software/DOOM/blob/77735c3ff0772609e9c8d29e3ce2ab42ff54d20b/linuxdoom-1.10/st_stuff.c#L752
local function calcstatusface(p,takis)
	local me = p.mo
	
	--idle
	if not HAPPY_HOUR.happyhour
	and not ((p.pizzaface) or ultimatemode)
		takis.HUD.statusface.state = "IDLE"
		takis.HUD.statusface.frame = (leveltime/3)%2
		takis.HUD.statusface.priority = 0
	else
		takis.HUD.statusface.state = "PTIM"
		takis.HUD.statusface.frame = (2*leveltime/3)%2
		takis.HUD.statusface.priority = 0
	end
	
	if (takis.heartcards <= (TAKIS_MAX_HEARTCARDS/6 or 1))
	and not (takis.fakeexiting)
		takis.HUD.statusface.state = "PTIM"
		takis.HUD.statusface.frame = (2*leveltime/3)%2
		takis.HUD.statusface.priority = 0	
	end
	
	if takis.HUD.statusface.priority < 10
		
		--dead
		if not (me)
		or (not me.health)
		or (p.playerstate ~= PST_LIVE)
		or (p.spectator)
			takis.HUD.statusface.state = "DEAD"
			takis.HUD.statusface.frame = 0
			takis.HUD.statusface.priority = 9
		end
	end
	
	if takis.HUD.statusface.priority < 9
		
		--pain
		if ((takis.inPain or takis.inFakePain)
		or (takis.ticsforpain)
		or (me.sprite2 == SPR2_PAIN)
		or (me.state == S_PLAY_PAIN)
		or (takis.HUD.statusface.painfacetic))
		and (not takis.resettingtoslide)
		and (me.sprite2 ~= SPR2_SLID)
			takis.HUD.statusface.state = "PAIN"
			takis.HUD.statusface.frame = (leveltime%4)/2
			takis.HUD.statusface.priority = 8
		end
		
	end
	
	
	if takis.HUD.statusface.priority < 8
		
		--evil grin when killing someone
		--or a boss
		if takis.HUD.statusface.evilgrintic
			takis.HUD.statusface.state = "EVL_"
			takis.HUD.statusface.frame = (leveltime/4)%2
			takis.HUD.statusface.priority = 7
		end
		
	end
	
	if takis.HUD.statusface.priority < 7
		
		--happy face
		if takis.HUD.statusface.happyfacetic
		or takis.tauntid == 2
			takis.HUD.statusface.state = "HAPY"
			takis.HUD.statusface.frame = (leveltime/2)%2
			takis.HUD.statusface.priority = 6		
		end
		
	end
	
	
	if takis.HUD.statusface.priority < 6
		
		--doom's godmode face
		if (p.pflags & PF_GODMODE)
			takis.HUD.statusface.state = "GOD_"
			takis.HUD.statusface.priority = 5
		end
		
	end
	
	if takis.HUD.statusface.priority < 2
	
		--space drown
		if ((P_InSpaceSector(me)) and (p.powers[pw_spacetime]))
		or ((p.powers[pw_underwater]) and (p.powers[pw_underwater] <= 11*TR))
			takis.HUD.statusface.state = "SDWN"
			takis.HUD.statusface.frame = (leveltime)%2
			takis.HUD.statusface.priority = 1
		end
		
	end
	
	--isnt this just so retro?
	--god, if only i lived in retroville
	if TAKIS_NET.isretro
		takis.HUD.statusface.frame = 0
	end
	
	return takis.HUD.statusface.state, takis.HUD.statusface.frame
end

local function drawface(v,p)

	if (customhud.CheckType("takis_statusface") != modname) return end

	local amiinsrbz = false
	
	if (gametype == GT_SRBZ)
		if (not p.chosecharacter)
		or p.shop_open
			amiinsrbz = true
		end
	end
	
	if p.takistable.inNIGHTSMode
	or (TAKIS_NET.inspecialstage)
	or amiinsrbz

		return
	end

	local takis = p.takistable
	local me = p.mo
	
	local eflags = V_HUDTRANS
	
	local headcolor
	if p.spectator
		headcolor = SKINCOLOR_CLOUDY
		eflags = V_HUDTRANSHALF
	else
		if ((me) and (me.valid))
			headcolor = me.color
		else
			headcolor = SKINCOLOR_CLOUDY
			eflags = V_HUDTRANSHALF
		end
	end
	
	local pre = "TAK"
	local scale = 2*FU/5
	local x,y2 = 0,0
	if TAKIS_NET.isretro
		pre = "RETR_"
		scale = $*3
		x = -17*FU
		y2 = -20*FU
	end
	
	local healthstate,healthframe = calcstatusface(p,takis)	
	local headpatch = v.cachePatch(pre..healthstate..tostring(healthframe))
	
	local y = 0
	local expectedtime = TR
	
	if HAPPY_HOUR.time and HAPPY_HOUR.time < 3*TR
	and (takis.io.nohappyhour == 0)
		local tics = HAPPY_HOUR.time
		
		if (tics < 2*TR)
			y = ease.inquad(( FU / expectedtime )*tics, 0, -60*FU)
		else
			y = ease.outquad(( FU / expectedtime )*(tics-(2*TR)), -60*FU, 0)
		end
	end
	
	v.drawScaled(20*FU+x,27*FU+y+y2,scale, headpatch, V_SNAPTOLEFT|V_SNAPTOTOP|V_PERPLAYER|eflags,v.getColormap(nil,headcolor))

end

--      ----------

--RINGS ----------

local function drawrings(v,p)

	if (customhud.CheckType("rings") != modname) return end

	if p.takistable.inNIGHTSMode
	or (TAKIS_NET.inspecialstage)
	or p.takistable.inSRBZ
		return
	end

	local ringpatch = "RING"
	
	local takis = p.takistable
	
	local flash = false
	
	if p.rings == 0
	and takis.heartcards <= 0
	and not (p.exiting)
		flash = true
	end
			
	local ringFx,ringFy = unpack(takis.HUD.rings.FIXED)
	local ringx,ringy = unpack(takis.HUD.rings.int)
	flash = (flash and ((leveltime%(2*TR)) < 30*TR) and (leveltime/5 & 1))

	if flash
		ringpatch = "TRNG"
	end
	
	local val = p.rings
	v.drawScaled(ringFx, ringFy, FU/2,v.getSpritePatch(ringpatch, A, 0, 0), V_SNAPTOLEFT|V_SNAPTOTOP|V_HUDTRANS|V_PERPLAYER,v.getColormap(nil,SKINCOLOR_RED))
	v.drawNum(ringx, ringy, val, V_SNAPTOLEFT|V_SNAPTOTOP|V_HUDTRANS|V_PERPLAYER)
	
end

--      ----------

--TIMER ----------

--this is so minhud
-- https:--mb.srb2.org/addons/minhud.2927/
local function howtotimer(player)
	local flash, tics = false
	
	local pt, lt = player.realtime, leveltime
	local puretlimit, purehlimit = CV_FindVar("timelimit").value, CV_FindVar("hidetime").value
	local tlimit = puretlimit * 60 * TR
	local hlimit = purehlimit * TR
	local extratext = ''
	local extrafunc = ''
	
	-- Counting down the hidetime?
	if (gametyperules & GTR_STARTCOUNTDOWN)
	and (pt <= hlimit)
		tics = hlimit - pt
		flash = true
		extrafunc = "countinghide"
	else
		-- Time limit?
		if (gametyperules & GTR_TIMELIMIT) and (puretlimit) then -- Gotta thank CobaltBW for spotting this oversight.
			if (tlimit > pt)
				tics = tlimit - pt
			else -- Overtime!
				tics = 0
			end
			flash = true
		-- Post-hidetime normal.
        elseif (gametyperules & GTR_STARTCOUNTDOWN) and (gametyperules & GTR_TIMELIMIT) -- Thanking 'im again.
            tics = tlimit - pt
        elseif (gametyperules & GTR_STARTCOUNTDOWN)
            tics = pt - hlimit
			extrafunc = "hiding"
        else
            tics = pt
        end
	end
	
	flash = (flash and (tics < 30*TR) and (lt/5 & 1)) -- Overtime?
	
	return flash, tics, extratext, extrafunc
end

local function drawtimer(v,p)

	if (customhud.CheckType("time") != modname) return end

	if p.takistable.inNIGHTSMode
	or (TAKIS_NET.inspecialstage)
	or p.takistable.inSRBZ
		return
	end
	
	local takis = p.takistable
	
	--time
	--this is so minhud
	local flashflag = 0
	local flash,timetic,extratext,extrafunc = howtotimer(p)
			
	if flash
		flashflag = V_REDMAP
	end
	
	local hours = G_TicsToHours(timetic)
	local minutes = G_TicsToMinutes(timetic, false)
	local seconds = G_TicsToSeconds(timetic)
	local tictrn  = G_TicsToCentiseconds(timetic)
	local spad, tpad = '', ''
	local extra = ''
	local extrac = ''
	
	--paddgin!!
	if (seconds < 10) then spad = '0' end
	if (tictrn < 10) then tpad = '0' end
	
	local timex, timey = unpack(takis.HUD.timer.int)
	local timetx = takis.HUD.timer.text
			
	if hours > 0
		extrac = ":"
	else
		hours = ''
	end
	
	if minutes >= 10
	and extrafunc == ''
		extra = " (SUCKS)"
	end
	
	if p.spectator
		timex, timey = unpack(takis.HUD.timer.spectator)
	elseif ( ((p.pflags & PF_FINISHED) and (netgame))
	or extrafunc == "hiding"
	or extrafunc == "countinghide")
	and not p.exiting
		timex, timey = unpack(takis.HUD.timer.finished)
	end
	v.drawString(timex, timey, hours..extrac..minutes..":"..spad..seconds.."."..tictrn..tpad,V_SNAPTOLEFT|V_SNAPTOTOP|V_HUDTRANS|V_PERPLAYER|flashflag,"thin-right")		v.drawString(timetx, timey, "Time"..extra,V_SNAPTOLEFT|V_SNAPTOTOP|V_HUDTRANS|V_PERPLAYER|flashflag,"thin")
	if extrastring ~= ''
		v.drawString(timetx, timey+8, extratext,V_SNAPTOLEFT|V_SNAPTOTOP|V_HUDTRANS|V_PERPLAYER|flashflag,"thin")			
	end
end

--      ----------

--SCORE ----------

local function drawscore(v,p)

	if (customhud.CheckType("score") != modname) return end
	
	if p.takistable.inNIGHTSMode
	or (TAKIS_NET.inspecialstage)
	or p.takistable.inSRBZ
		return
	end
	
	local takis = p.takistable
	
	local xshake = takis.HUD.flyingscore.xshake
	local yshake = takis.HUD.flyingscore.yshake
		
	local score = p.score
	if takis.HUD.flyingscore.tics
		score = p.score-takis.HUD.flyingscore.lastscore
	end
	
	--v.drawString((300-15)*FU+xshake, 15*FU+yshake, takis.HUD.flyingscore.scorenum,V_SNAPTORIGHT|V_SNAPTOTOP|V_HUDTRANS|V_PERPLAYER,"fixed-right")
	
	--buggie's tf2 engi code
	local scorenum = "SCREFT"
	score = takis.HUD.flyingscore.scorenum
	
	local prevw
	if not prevw then prevw = 0 end
	
	local width = (string.len(score))*(v.cachePatch(scorenum.."1").width*4/10)
	for i = 1,string.len(score)
		local n = string.sub(score,i,i)
		v.drawScaled((300-15+prevw-width)*FU+xshake,
			15*FU+yshake,
			FU/2,
			v.cachePatch(scorenum+n),
			V_SNAPTORIGHT|V_SNAPTOTOP|V_HUDTRANS|V_PERPLAYER
		)
			
		prevw = $+v.cachePatch(scorenum+n).width*4/10
	end
	
	/*
	for k,va in ipairs(takis.HUD.scoretext)
		if va == nil
			continue
		end
		
		if va.tics
			va.ymin = $-FU
			v.drawString((300-15)*FU,(15+8)*FU-va.ymin,va.text,va.cmap|va.trans|V_SNAPTOTOP|V_SNAPTORIGHT|V_ADD,"thin-fixed-right")
			va.tics = $-1
		else
			table.remove(takis.HUD.scoretext,k)
		end
	end
	*/
	
	if takis.HUD.flyingscore.tics
		local snap = V_SNAPTOLEFT
		if takis.HUD.flyingscore.tics < 4
			snap = V_SNAPTORIGHT
		end
		
		local x = takis.HUD.flyingscore.x
		local y = takis.HUD.flyingscore.y
		
		v.drawString(x, y, 
			takis.HUD.flyingscore.num,
			snap|V_SNAPTOTOP|V_HUDTRANS|V_PERPLAYER,
			"thin-fixed-center"
		)
		
	end
end

--      ----------

--LIVES ----------

--source lol
-- https:--github.com/STJr/SRB2/blob/eb1492fe6e501001a2271fa133bd76c0b0612715/src/st_stuff.c#L812
local function drawlivesarea(v,p)

	if (customhud.CheckType("lives") != modname) return end
	
	if p.takistable.inNIGHTSMode
	or (TAKIS_NET.inspecialstage)
	or p.takistable.inSRBZ
	or (p.textBoxInAction)
	or (TAKIS_DEBUGFLAG & DEBUG_SPEEDOMETER)
		return
	end
	
	local textmap = V_YELLOWMAP
	local candrawlives = true
	local infinite = false
	
	local disp = -20
	
	local me = p.mo
	local takis = p.takistable
	
	if not (p.skincolor)
		return
	end
	
	takis.HUD.hudname = skins[TAKIS_SKIN].hudname
	if p.skincolor == SKINCOLOR_GREEN
		takis.HUD.hudname = "Taykis"
	elseif p.skincolor == SKINCOLOR_RED
		takis.HUD.hudname = "Yakis"
	elseif p.skincolor == SKINCOLOR_SALMON
		takis.HUD.hudname = "Rakis"
	end
		
	--face background
	v.drawScaled(
		(hudinfo[HUD_LIVES].x)*FU,
		hudinfo[HUD_LIVES].y*FU,
		FU/2,
		v.cachePatch("TAK_LIFEBACK"),
		hudinfo[HUD_LIVES].f|V_HUDTRANS|V_PERPLAYER,
		v.getColormap(TAKIS_SKIN, nil)
	)
	
	--face
	if (p.spectator)
		v.drawScaled(
			(hudinfo[HUD_LIVES].x)*FU,
			hudinfo[HUD_LIVES].y*FU,
			FU/2,
			v.getSprite2Patch(TAKIS_SKIN,SPR2_XTRA,false,A,0,0),
			hudinfo[HUD_LIVES].f|V_HUDTRANSHALF|V_PERPLAYER,
			v.getColormap(TAKIS_SKIN, SKINCOLOR_CLOUDY)
		)
	elseif ((me) and (me.color))
		v.drawScaled(
			(hudinfo[HUD_LIVES].x)*FU,
			hudinfo[HUD_LIVES].y*FU,
			FU/2,
			v.getSprite2Patch(TAKIS_SKIN,SPR2_XTRA,false,A,0,0),
			hudinfo[HUD_LIVES].f|V_HUDTRANS|V_PERPLAYER,
			v.getColormap(TAKIS_SKIN, me.color)
		)
	elseif (p.skincolor)
		v.drawScaled(
			(hudinfo[HUD_LIVES].x)*FU,
			hudinfo[HUD_LIVES].y*FU,
			FU/2,
			v.getSprite2Patch(TAKIS_SKIN,SPR2_XTRA,false,A,0,0),
			hudinfo[HUD_LIVES].f|V_HUDTRANS|V_PERPLAYER,
			v.getColormap(TAKIS_SKIN, p.skincolor)
		)		
	end
	
	--text
	if (p.spectator)
		textmap = V_GRAYMAP
	elseif (gametyperules & GTR_TAG)
		if (p.pflags & PF_TAGIT)
			v.drawString(
				hudinfo[HUD_LIVES].x+58,hudinfo[HUD_LIVES].y+8,
				"IT!",
				V_HUDTRANS|hudinfo[HUD_LIVES].f|V_PERPLAYER|V_ALLOWLOWERCASE,
				"thin-right"
			)
			textmap = V_ORANGEMAP
		end
	elseif (G_GametypeHasTeams())
		
		if (p.ctfteam == 1)
			v.drawString(
				hudinfo[HUD_LIVES].x+58,hudinfo[HUD_LIVES].y+8,
				"\x85RED",
				V_HUDTRANS|hudinfo[HUD_LIVES].f|V_PERPLAYER|V_ALLOWLOWERCASE,
				"thin-right"
			)
			textmap = V_REDMAP
		
		elseif (p.ctfteam == 2)
			v.drawString(
				hudinfo[HUD_LIVES].x+58,hudinfo[HUD_LIVES].y+8,
				"\x84".."BLU",
				V_HUDTRANS|hudinfo[HUD_LIVES].f|V_PERPLAYER|V_ALLOWLOWERCASE,
				"thin-right"
			)
			textmap = V_BLUEMAP
		
		end
	end
	
	if (G_GametypeUsesLives())
		if CV_FindVar("cooplives").value == 0
			infinite = true
		end
	elseif (G_PlatformGametype() and not (gametyperules & GTR_LIVES))
		infinite = true
	else
		candrawlives = false
	end
	
	if takis.isSinglePlayer
		if p.lives ~= INFLIVES
			infinite = false
		else
			infinite = true
		end
	end
	
	if (candrawlives)
		v.drawScaled(
			(hudinfo[HUD_LIVES].x+22)*FU,(hudinfo[HUD_LIVES].y+10)*FU,
			FU,
			v.cachePatch("STLIVEX"),
			hudinfo[HUD_LIVES].f|V_PERPLAYER|V_HUDTRANS
		)
		if (infinite)
			
			v.drawScaled(
				(hudinfo[HUD_LIVES].x+50)*FU,(hudinfo[HUD_LIVES].y+8)*FU,
				FU,
				v.cachePatch("STCFN022"),
				hudinfo[HUD_LIVES].f|V_PERPLAYER|V_HUDTRANS
			)
			
		else
			local value = p.lives
			
			if CV_FindVar("cooplives").value == 3
			and (netgame or multiplayer)
				value = TAKIS_NET.livescount
			end
			
			v.drawString(
				hudinfo[HUD_LIVES].x+58,hudinfo[HUD_LIVES].y+9,
				value,
				hudinfo[HUD_LIVES].f|V_PERPLAYER|V_HUDTRANS,
				"thin-right"
			)
		end
			
		
	end
	
	if not (modeattacking)
	
		textmap = $|(V_HUDTRANS|hudinfo[HUD_LIVES].f|V_PERPLAYER|V_ALLOWLOWERCASE)
		v.drawString(
			hudinfo[HUD_LIVES].x+58,hudinfo[HUD_LIVES].y,
			takis.HUD.hudname,
			textmap,
			"thin-right"
		)
	
	else
		disp = $-10
	end
	
	--i guess i gotta draw the stones too
	if (G_RingSlingerGametype())
		disp = $-5
		local workx = hudinfo[HUD_LIVES].x+1
		local additive = 0
		
		local emeraldpics = {
			v.cachePatch("CHAOS1"),
			v.cachePatch("CHAOS2"),
			v.cachePatch("CHAOS3"),
			v.cachePatch("CHAOS4"),
			v.cachePatch("CHAOS5"),
			v.cachePatch("CHAOS6"),
			v.cachePatch("CHAOS7"),
		}
		
		if ((p.powers[pw_invulnerability]) and (p.powers[pw_sneakers] == p.powers[pw_invulnerability] ))
			if (not((leveltime/2)%2))
				additive = V_ADD
			end
			
			for i = 1, 7
				v.drawScaled(
					workx*FU,
					(hudinfo[HUD_LIVES].y-9)*FU,
					FU/4,
					emeraldpics[i],
					V_HUDTRANS|hudinfo[HUD_LIVES].f|V_PERPLAYER|additive
				)
				workx = $+9
			end
		else
		
			for i = 0, 7
				if (p.powers[pw_emeralds] & (1<<i))
					v.drawScaled(
						workx*FU,
						(hudinfo[HUD_LIVES].y-9)*FU,
						FU/4,
						emeraldpics[i+1],
						V_HUDTRANS|hudinfo[HUD_LIVES].f|V_PERPLAYER
					)
				end
				workx = $+9
			end
		
		end
		
	end
	
	if (takis.clutchcombo)
	and (takis.io.clutchstyle == 0)
		disp = $-20
	end
	
	if (takis.shotgunned)
		v.drawScaled(hudinfo[HUD_LIVES].x*FU, (hudinfo[HUD_LIVES].y+disp)*FU, (FU/2)+(FU/12), v.cachePatch("TB_C3"), V_SNAPTOLEFT|V_SNAPTOBOTTOM|V_PERPLAYER|V_HUDTRANS)
		v.drawString(hudinfo[HUD_LIVES].x+20, hudinfo[HUD_LIVES].y+(disp+5), "Un-Shotgun",V_ALLOWLOWERCASE|V_SNAPTOLEFT|V_SNAPTOBOTTOM|V_PERPLAYER|V_HUDTRANS, "small")	
		disp = $-20
	end
	
	if (p.powers[pw_shield] ~= SH_NONE)
		local shieldflag = V_HUDTRANSHALF
		shieldflag = (not(takis.noability&NOABIL_SHIELD)) and V_HUDTRANS or V_HUDTRANSHALF
		
		v.drawScaled(hudinfo[HUD_LIVES].x*FU, (hudinfo[HUD_LIVES].y+disp)*FU, (FU/2)+(FU/12), v.cachePatch("TB_C2"), V_SNAPTOLEFT|V_SNAPTOBOTTOM|V_PERPLAYER|shieldflag)
		v.drawString(hudinfo[HUD_LIVES].x+20, hudinfo[HUD_LIVES].y+(disp+5), "Shield Ability",V_ALLOWLOWERCASE|V_SNAPTOLEFT|V_SNAPTOBOTTOM|V_PERPLAYER|V_HUDTRANS, "small")
		disp = $-20
	end
	
	if (p.powers[pw_carry] == CR_MINECART)
		v.drawScaled(hudinfo[HUD_LIVES].x*FU, (hudinfo[HUD_LIVES].y+disp)*FU, (FU/2)+(FU/12), v.cachePatch("TB_C1"), V_SNAPTOLEFT|V_SNAPTOBOTTOM|V_PERPLAYER)
		v.drawString(hudinfo[HUD_LIVES].x+20, hudinfo[HUD_LIVES].y+(disp+5), "Break Minecart",V_ALLOWLOWERCASE|V_SNAPTOLEFT|V_SNAPTOBOTTOM|V_PERPLAYER|V_HUDTRANS, "small")
	end
	
	--xmom stuff
	/*
	if (S_PLAY_TRICKUP and S_PLAY_TRICKDOWN)
		if me and ((me.state != S_PLAY_TRICKUP) and (me.state != S_PLAY_TRICKDOWN)) return end	
		v.drawScaled(
			(hudinfo[HUD_LIVES].x+8)*FU, (hudinfo[HUD_LIVES].y-7)*FU,
			FU/2,
			v.getSprite2Patch(TAKIS_SKIN,me.sprite2,false,me.frame,2,me.rollangle),
			V_HUDTRANS|V_SNAPTOBOTTOM|V_SNAPTOLEFT,
			v.getColormap(TAKIS_SKIN, p.skincolor)
		)
	end
	*/
	
	if TAKIS_ISDEBUG
		v.drawString(hudinfo[HUD_LIVES].x+60,
			hudinfo[HUD_LIVES].y,
			"w.i.p.",
			V_HUDTRANS|V_REDMAP|V_SNAPTOLEFT|V_SNAPTOBOTTOM,
			"thin"
		)
	end
	
end

--      ----------

local function R_GetScreenCoords(v, p, c, mx, my, mz)
	local camx, camy, camz, camangle, camaiming
	if p.awayviewtics then
		camx = p.awayviewmobj.x
		camy = p.awayviewmobj.y
		camz = p.awayviewmobj.z
		camangle = p.awayviewmobj.angle
		camaiming = p.awayviewaiming
	elseif c.chase then
		camx = c.x
		camy = c.y
		camz = c.z
		camangle = c.angle
		camaiming = c.aiming
	else
		camx = p.mo.x
		camy = p.mo.y
		camz = p.viewz-20*FRACUNIT
		camangle = p.mo.angle
		camaiming = p.aiming
	end

	-- Lat: I'm actually very lazy so mx can also be a mobj!
	if type(mx) == "userdata" and mx.valid
		my = mx.y
		mz = mx.z
		mx = mx.x	-- life is easier
	end

	local x = camangle-R_PointToAngle2(camx, camy, mx, my)

	local distfact = cos(x)
	if not distfact then
		distfact = 1
	end -- MonsterIestyn, your bloody table fixing...

	if x > ANGLE_90 or x < ANGLE_270 then
		return -9, -9, 0
	else
		x = FixedMul(tan(x, true), 160<<FRACBITS)+160<<FRACBITS
	end

	local y = camz-mz
	--print(y/FRACUNIT)
	y = FixedDiv(y, FixedMul(distfact, R_PointToDist2(camx, camy, mx, my)))
	y = (y*160)+(100<<FRACBITS)
	y = y+tan(camaiming, true)*160

	local scale = FixedDiv(160*FRACUNIT, FixedMul(distfact, R_PointToDist2(camx, camy, mx, my)))
	--print(scale)

	return x, y, scale
end

--CLUTCH----------

local function drawclutches(v,p,cam)

	if (customhud.CheckType("takis_clutchstuff") != modname) return end
	
	/*
	if p.takistable.inNIGHTSMode
	or (TAKIS_NET.inspecialstage)
		return
	end
	*/
	
	local takis = p.takistable
	local me = p.mo
	
	if (takis.io.clutchstyle == 0)
		if takis.clutchtime > 0
			local maxammo = 13*23/5
			local barx = hudinfo[HUD_LIVES].x
			local bary = hudinfo[HUD_LIVES].y+20
			local color = SKINCOLOR_CRIMSON
			local pre = "CLTCHBAR_"
			
			if (takis.clutchtime <= 11)
			and (takis.clutchtime > 0)
				color = SKINCOLOR_GREEN
			end
			
			
			v.draw(barx, bary, v.cachePatch(pre.."BACK"),
				V_SNAPTOBOTTOM|V_SNAPTOLEFT|V_HUDTRANS|V_PERPLAYER
			)
			
			local max = 23*FU
			local timer = (23-takis.clutchtime)*FU
			local erm = FixedDiv((timer),max)
			local width = FixedMul(erm,v.cachePatch(pre.."FILL").width*FU)
			if width < 0 then
				width = 0
			end
			local scale = FU
			
			v.drawCropped(barx*FU,bary*FU,scale,scale,
				v.cachePatch(pre.."FILL"),
				V_SNAPTOBOTTOM|V_SNAPTOLEFT|V_HUDTRANS|V_PERPLAYER, 
				v.getColormap(nil,color),
				0,0,
				width,v.cachePatch(pre.."FILL").height*FU
			)
			
			v.draw(barx, bary, v.cachePatch(pre.."MARK"),
				V_SNAPTOBOTTOM|V_SNAPTOLEFT|V_HUDTRANS|V_PERPLAYER
			)
		end
		--clutch combo
		if takis.clutchcombo
			local y = 0
			if (modeattacking)
				y = -10
			end
			
			v.drawString(hudinfo[HUD_LIVES].x, hudinfo[HUD_LIVES].y-20+y, takis.clutchcombo.."x BOOSTS",V_SNAPTOLEFT|V_SNAPTOBOTTOM|V_HUDTRANS|V_PERPLAYER|V_ALLOWLOWERCASE)			
		end
	elseif (takis.io.clutchstyle == 1)
		--chrispy chars
		local player = p
		local mo = player.mo
		local color = SKINCOLOR_CRIMSON
		local pre = "CLTCHMET_"
		
		if (takis.clutchtime <= 11)
		and (takis.clutchtime > 0)
			color = SKINCOLOR_GREEN
		end
		
		local flip = 1
		local bubble = v.cachePatch(pre.."BACK")
		local angdiff = ANGLE_90
		local x, y, scale
		local cutoff = function(y) return false end
		
		if cam.chase and not (player.awayviewtics and not (me.flags2 & MF2_TWOD))
			x, y, scale = R_GetScreenCoords(v, player, cam, mo)
			scale = $*2
			if mo.eflags & MFE_VERTICALFLIP
			and player.pflags & PF_FLIPCAM
				y = 200*FRACUNIT - $
			else
				flip = P_MobjFlip(mo)
			end
		else
			x, y, scale = 160*FRACUNIT, (100 + bubble.height >> 1)*FRACUNIT, FRACUNIT
		end
		
		if splitscreen
			if player == secondarydisplayplayer
				cutoff = function(y) return y < (bubble.height*scale >> 1) end
			else
				cutoff = function(y) return y > 200*FRACUNIT + (bubble.height*scale >> 1) end
			end
		end
		
		local angle = angdiff + ANGLE_90
		local x = x - P_ReturnThrustX(nil, angle, 50*scale)
		local y = y - flip*P_ReturnThrustY(nil, angle, 64*scale)
			
		if not cutoff(y)
			if takis.clutchcombo
				v.drawString(x,y,
					"x"..takis.clutchcombo,
					V_PERPLAYER|V_HUDTRANS|V_ALLOWLOWERCASE,
					"fixed"
				)
				v.drawString(x,y+(8*FU),
					"boosts",
					V_PERPLAYER|V_HUDTRANS,
					"thin-fixed"
				)
			end
			if (takis.clutchspamcount)
			and not (takis.clutchcombo)
				if (takis.clutchspamcount >= 3)
				and (takis.clutchspamcount < 7)
					v.drawString(x,y,
						"don't",
						V_PERPLAYER|V_HUDTRANS,
						"thin-fixed"
					)			
					v.drawString(x,y+8*FU,
						"spam",
						V_PERPLAYER|V_HUDTRANS,
						"thin-fixed"
					)
				elseif (takis.clutchspamcount >= 7)
					v.drawString(x,y,
						"clutch on",
						V_PERPLAYER|V_HUDTRANS,
						"thin-fixed"
					)			
					v.drawString(x,y+8*FU,
						"green",
						V_PERPLAYER|V_HUDTRANS,
						"thin-fixed"
					)				
				end
			end
			
			if takis.clutchtime > 0
				v.drawScaled(x, y, scale, bubble, V_PERPLAYER|V_HUDTRANS)
				
				local max = 23*FU
				local timer = (23-takis.clutchtime)*FU
				local erm = FixedDiv((timer),max)
				local width = v.cachePatch(pre.."FILL").height*FU-FixedMul(erm,v.cachePatch(pre.."FILL").height*FU)
				if width < 0 then
					width = 0
				end
				
				v.drawCropped(x,y+FixedMul(width,scale),scale,scale,
					v.cachePatch(pre.."FILL"),
					V_PERPLAYER|V_HUDTRANS, 
					v.getColormap(nil,color),
					0,width,
					v.cachePatch(pre.."FILL").width*FU,v.cachePatch(pre.."FILL").height*FU
				)
				
				v.drawScaled(x, y, scale, v.cachePatch(pre.."MARK"), V_PERPLAYER|V_HUDTRANS)
			end
		end
	end
	
end

--      ----------

--COMBO ----------

local function drawcombostuff(v,p)

	if (customhud.CheckType("takis_combometer") != modname) return end

	if p.takistable.inNIGHTSMode
	or (TAKIS_NET.inspecialstage)
		return
	end
	
	local takis = p.takistable
	local me = p.mo

	if takis.combo.count
	or takis.combo.outrotics
		
		local comboscale = takis.HUD.combo.scale+FU
		local shake = -FixedMul(takis.HUD.combo.shake,comboscale)
		local backx = 15*FU
		local backy = 70*FU+shake-(takis.combo.gravity or takis.combo.outrotointro)
		
		if ((p.pflags & PF_FINISHED) and (netgame))
		and not p.exiting
			backy = $+(20*FU)
		end
		
		local max = TAKIS_MAX_COMBOTIME*FU or 1
		local erm = FixedDiv((takis.HUD.combo.fillnum),max)
		local width = FixedMul(erm,v.cachePatch("TAKCOFILL").width*FU)
		local color
		if takis.HUD.combo.fillnum <= TAKIS_MAX_COMBOTIME*FU/4
			color = SKINCOLOR_RED
		elseif takis.HUD.combo.fillnum <= TAKIS_MAX_COMBOTIME*FU/2
			color = SKINCOLOR_ORANGE
		elseif takis.HUD.combo.fillnum <= TAKIS_MAX_COMBOTIME*FU*3/4
			color = SKINCOLOR_YELLOW
		end
		if (takis.combo.frozen)
			color = SKINCOLOR_BLACK
		end
		if width < 0 then
			width = 0
		end
		takis.HUD.combo.patchx = v.cachePatch("TAKCOFILL").width*FU/2
		local patchx = takis.HUD.combo.patchx
		
		v.drawCropped(backx,backy,comboscale,comboscale,
			v.cachePatch("TAKCOFILL"),
			V_HUDTRANS|V_SNAPTOLEFT|V_SNAPTOTOP, 
			v.getColormap(nil,color),
			0,0,
			width,v.cachePatch("TAKCOFILL").height*FU
		)
		
		v.drawScaled(backx,backy,comboscale,
			v.cachePatch("TAKCOBACK"),
			V_HUDTRANS|V_SNAPTOLEFT|V_SNAPTOTOP
		)
		
		v.drawString(backx+5*comboscale+(FixedMul(patchx,comboscale)),
			backy+7*comboscale,
			takis.combo.score,
			V_HUDTRANS|V_SNAPTOLEFT|V_SNAPTOTOP,
			"thin-fixed-center"
		)
		
		--draw combo rank
		local length = #TAKIS_COMBO_RANKS
		v.drawString(backx+7*comboscale,
			backy+20*comboscale,
			TAKIS_COMBO_RANKS[ ((takis.combo.rank-1) % length)+1 ],
			V_HUDTRANS|V_ALLOWLOWERCASE|V_SNAPTOLEFT|V_SNAPTOTOP|V_PERPLAYER,
			"thin-fixed"
		)
		
		--font
		local scorenum = "CMBCF"
		local score = takis.combo.count
		
		local prevw
		if not prevw then prevw = 0 end
		
		for i = 1,string.len(score)
			local n = string.sub(score,i,i)
			v.drawScaled(backx+FixedMul(75*FU+(prevw*FU),comboscale),
				backy+5*FU,
				FixedDiv(comboscale,2*FU),
				v.cachePatch(scorenum+n),
				V_HUDTRANS|V_SNAPTOLEFT|V_SNAPTOTOP|V_PERPLAYER
			)
				
			prevw = $+v.cachePatch(scorenum+n).width*4/10
		end
		
		if takis.combo.cashable
			v.drawString(backx+5*comboscale+(FixedMul(patchx,comboscale)),
				backy-2*comboscale,
				"C1+C2: Cash in!",
				V_ALLOWLOWERCASE|V_GREENMAP|V_HUDTRANS|V_SNAPTOLEFT|V_SNAPTOTOP,
				"thin-fixed-center"
			)
		end
		
		--draw the verys
		local maxvery = 19	
		
		local waveforce = FU*2
		waveforce = $+(FU/50*((takis.combo.verylevel-1)))
		if takis.combo.verylevel > 0
			for i = 1, takis.combo.verylevel
				
				local verypatch = v.cachePatch("TAKCOVERY")
				--if not (i % 2)
				--	verypatch = v.cachePatch("TAKCOSUPR")
				--end
				
				local k = ((i-1)%maxvery) --x
				local j = ((i-1)/maxvery) --y
				
				local angle = FixedAngle(maxvery*FU)
				local ay = FixedMul(waveforce,sin((leveltime-k)*angle))
				
				v.drawScaled(backx+(7*FU)+(k*(5*FU)),
					backy+(37*FU)+(j*6*FU)+ay,
					FU/3,
					verypatch,
					V_HUDTRANS|V_SNAPTOLEFT|V_SNAPTOTOP|V_PERPLAYER
				)
				
			end
			/*
			v.drawString(backx+(7*FU)+(maxvery*(5*FU)),
				backy+(37*FU),
				"x"..takis.combo.verylevel.."\x83 Verys!",
				V_ALLOWLOWERCASE|V_HUDTRANS|V_SNAPTOLEFT|V_SNAPTOTOP|V_PERPLAYER,
				"thin-fixed"
			)
			*/
		end
		
	else
		if takis.combo.failcount
			takis.combo.failcount = 0
		end
	end

	if takis.combo.awardable
	and not takis.combo.dropped
		--takis.combo.awardable = true
		
		if takis.HUD.combo.tokengrow ~= 0
			takis.HUD.combo.tokengrow = $/2
		end
		
		local x = (300-30)*FU
		local y = 35*FU
		if p.ptsr_rank
			x = $-20*FU
		end
		local grow = takis.HUD.combo.tokengrow
		
		v.drawScaled(x-(grow*25),y-(grow*20),FU/3+grow,
			v.cachePatch("FCTOKEN"),
			V_HUDTRANS|V_SNAPTORIGHT|V_SNAPTOTOP, 
			v.getColormap(nil, p.skincolor)
		)
	end
	
end

--      ----------

local function drawjumpscarelol(v,p)

	if (customhud.CheckType("takis_c3jumpscare") != modname) return end

	local takis = p.takistable
	local h = takis.HUD.funny
	
	if h.tics
		takis.HUD.funny.y = $*4/5
		takis.HUD.funny.tics = $-1
		v.fadeScreen(35,10)
		
		local scale = FU*7/5
		local p = v.cachePatch("BALL_BUSTER")
		
		local x = v.RandomFixed()*3
		if ((leveltime%4) < 3)
			x = -$
		end
		
		if h.alsofunny
			p = v.cachePatch("BASTARD")
			scale = FU/2
		end
		
		v.drawScaled(((300/2)*FU)+x,h.y,scale,p,0)
	end
	
end

local function happyshakelol(v)
	local s = 5
	local shakex,shakey = v.RandomFixed()/2,v.RandomFixed()/2
	
	local d1 = v.RandomRange(-1,1)
	local d2 = v.RandomRange(-1,1)
	if d1 == 0
		d1 = v.RandomRange(-1,1)
	end
	if d2 == 0
		d2 = v.RandomRange(-1,1)
	end

	shakex = $*s*d1
	shakey = $*s*d2
	
	return shakex,shakey
end

local function drawhappyhour(v,p)

	if (customhud.CheckType("PTSR_itspizzatime") != modname) and (HAPPY_HOUR.othergt) then return end
	
	if ((skins[p.skin].name ~= TAKIS_SKIN)
	and (p.takistable.io.morehappyhour == 0))
	and (HAPPY_HOUR.othergt)
		return
	end
	
	local takis = p.takistable
	
	local dontdo = false
	if (HAPPY_HOUR.othergt)
		dontdo = takis.io.nohappyhour == 1
	end
	
	if (HAPPY_HOUR.time) and (HAPPY_HOUR.time <= 5*TR)
	and not (dontdo)
		
		local tics = HAPPY_HOUR.time

		takis.HUD.happyhour.doingit = true
		
		local cmap = 0xFF00
		
		if tics < 15
			v.fadeScreen(cmap,tics)
		elseif ((tics >= 15) and (tics < ((2*TR)+17) ))
			v.fadeScreen(cmap,16)
		elseif ((tics >= ((2*TR)+17)) and (tics < 103))
			v.fadeScreen(cmap,16-(tics-87)) 
		end
		
		local h = takis.HUD.happyhour
		local y = 40*FU
		
		local me = p.realmo

		local back = 4*FU/5
		
		local pa = v.cachePatch
		
		if tics > 1
			local shakex,shakey = happyshakelol(v)
			v.drawScaled(h.its.x+shakex, y+h.its.yadd+shakey, h.its.scale,
				pa(h.its.patch..h.its.frame),
				V_SNAPTOTOP|V_HUDTRANS
			)
			
			shakex,shakey = happyshakelol(v)
			v.drawScaled(h.happy.x+shakex, y+h.happy.yadd+shakey, h.happy.scale,
				pa(h.happy.patch..h.happy.frame),
				V_SNAPTOTOP|V_HUDTRANS
			)
			
			shakex,shakey = happyshakelol(v)
			v.drawScaled(h.hour.x+shakex, y+h.hour.yadd+shakey, h.hour.scale,
				pa(h.hour.patch..h.hour.frame),
				V_SNAPTOTOP|V_HUDTRANS
			)
			if tics > 4
				local pat = SPR2_TRNS
				local scale = 6*FU/5
				--if this looks weird, i dont care
				--ADD HHF_ SPRITE!!!!!
				local frame = G
				local num = {
					[0] = A,
					[1] = B
				}
				local skin = me.skin or p.skin
				local hires = skins[skin].highresscale or FU
				local yadd = 15*FU
				
				if P_IsValidSprite2(me,SPR2_HHF_)
					pat = SPR2_HHF_
					scale = 3*FU/5
					frame = num[h.face.frame]
					yadd = 0
				end
				
				local face = v.getSprite2Patch(p.skin,pat,false,frame,0,0)
				v.drawScaled(h.face.x+x, (130*FU)+h.face.yadd+yadd, FixedMul(scale,hires),
					face,
					V_HUDTRANS, v.getColormap(nil,p.skincolor)
				)
			end
		end
	end
	
end

local function getlaptext(p)
	local text = ''
	local exitingCount, playerCount = JISK_COUNT()
	local dynamiclapstext = "\x8D".."Dyna Laps"
	local lapsandmaxlapstext = "\x82Laps:"
	local lapstext = "\x82Laps:"
	local lapsperplayertext = "\x82Your Laps:"
	local num = ''
	
	--lots of these for backwards compatability
	local laps = ((PTSR) and (PTSR.laps)) or JISK_LAPS
	local laptype = ((CV_PTSR) and (CV_PTSR.lappingtype.value)) or ((JISK_LAPPINGTYPE) and (JISK_LAPPINGTYPE.value))
	local dynalap = ((CV_PTSR) and (CV_PTSR.dynamiclaps.value)) or ((JISK_DYNAMICLAPS) and (JISK_DYNAMICLAPS.value))
	local mlpp = ((CV_PTSR) and (CV_PTSR.maxlaps_perplayer.value)) or ((JISK_MAXLAPS_PERPLAYER) and (JISK_MAXLAPS_PERPLAYER.value))
	local maxlaps = ((CV_PTSR) and (CV_PTSR.maxlaps.value)) or ((JISK_MAXLAPS) and (JISK_MAXLAPS.value))
	local dynalapsv = ((PTSR) and (PTSR.dynamic_maxlaps)) or JISK_DYNAMICMAXLAPS
	
	if p.pizzaface and laptype == 2 then 
		num = 'dontdraw'
		return text,num
	end
	if laptype == 2 then
		text = lapsperplayertext
		num = p.lapsdid.." / "..mlpp
		return text,num
	end
	
	if dynalap then
		text = dynamiclapstext
		num = laps.." / "..dynalapsv
		return text,num
	end
	
	if maxlaps then
		text = lapsandmaxlapstext
		num = laps.." / "..maxlaps
		return text,num
	else
		text = lapstext
		num = laps
		return text,num
	end

end


local function hhtimerbase(v,p)
	if not HAPPY_HOUR.happyhour
		return
	end
	
	if not HAPPY_HOUR.timelimit
		return
	end
	
	if HAPPY_HOUR.time == 1
		return
	end
	
	local tics = HAPPY_HOUR.timeleft
	
	local takis = p.takistable
	
	if tics == nil
		tics = 0
	end
	
	local min = tics/(60*TR) --G_TicsToMinutes(tics,true)
	local sec = G_TicsToSeconds(tics)
	local cen = G_TicsToCentiseconds(tics)
	local spad,cpad,extrastring = '','',''
	
	--paddgin!!
	if (sec < 10) then spad = '0' end
	if (cen < 10) then cpad = '0' end
	
	local timertime = min..":"..spad..sec
	extrastring = "."..cpad..cen 
	if not (TAKIS_DEBUGFLAG & DEBUG_HAPPYHOUR)
		extrastring = ''
	end
	
	local string = timertime..extrastring
	
	local h = takis.HUD.ptsr
		
	local frame = ((5*leveltime/6)%14)
	local patch
	local trig = HAPPY_HOUR.trigger
	if (trig and trig.valid)
	and (trig.type == MT_HHTRIGGER)
		patch = v.getSpritePatch(SPR_HHT_,trig.frame,0)
	else
		patch = v.cachePatch("TAHHS"..frame)
	end
	
	if not (HAPPY_HOUR.othergt)
		h.xoffset = (-GetInternalFontWidth(tostring(string),TAKIS_HAPPYHOURFONT)-30)/10
	end
	
	if not (takis.inNIGHTSMode)
		v.drawScaled(110*FU+(h.xoffset*FU),168*FU+(h.yoffset),FU,patch,V_HUDTRANS|V_SNAPTOBOTTOM)
		local doot = false
		
		if not (HAPPY_HOUR.overtime)
			TakisDrawPatchedText(v, 150+(h.xoffset), 173+(h.yoffset/FU), tostring(string),{font = TAKIS_HAPPYHOURFONT, flags = (V_SNAPTOBOTTOM|V_HUDTRANS), align = 'left', scale = 4*FU/5})
		else
			local x,y = happyshakelol(v)
			v.drawScaled(
				(150+h.xoffset)*FU+x,173*FU+h.yoffset+y,4*FU/5,
				v.cachePatch(TAKIS_HAPPYHOURFONT.."OT"),
				V_SNAPTOBOTTOM|V_HUDTRANS
			)
		end
	else
		if (p.exiting) then return end
		
		v.drawScaled(100*FU,10*FU-(h.yoffset),
			FU,v.cachePatch("TAHHS"..frame),
			V_HUDTRANS|V_SNAPTOTOP
		)
	
	end

end

local function drawpizzatimer(v,p)

	if (customhud.CheckType("PTSR_bar") != modname) return end
	
	if (skins[p.skin].name ~= TAKIS_SKIN)
	and (p.takistable.io.morehappyhour == 0)
		return
	end
	
	hhtimerbase(v,p)
end

local function drawhappytime(v,p)
	if (customhud.CheckType("takis_happyhourtime") != modname) return end
	
	if HAPPY_HOUR.othergt
		return
	end
	
	hhtimerbase(v,p)
end

local function drawtelebar(v,p)

	
	local takis = p.takistable
	local me = p.mo
	local h = takis.HUD.ptsr
	
	local charge = p.pizzacharge or 0
	
		local maxammo = TR*7/5
		local curammo = charge*7/5
		local x = 153
		local y = 168
		local barx = x+(h.xoffset)
		local bary = y+(h.yoffset/FU)
		local patch1 = v.cachePatch("TAKISEG1") --blue
		local patch3 = v.cachePatch("TAKISEG2") --black
		local color = p.skincolor
		
			--Ammo bar
			local pos = 0 
			while (pos < maxammo)
				local patch = patch3
				pos = $ + 1
				
				
					if pos <= curammo
						v.draw(barx + pos - 1, bary, patch3, V_SNAPTOBOTTOM|V_HUDTRANS)
						if pos > curammo - 1
							if (curammo <= 1)
								--first
								patch = patch1
							else
								--fill
								patch = patch1
							end
						else
							patch = patch1
						end
					end
					
				v.draw(barx + pos - 1, bary, patch, V_SNAPTOBOTTOM|V_HUDTRANS,v.getColormap(nil,color))
			end
			

end

local function drawpizzatips(v,p)

	if (customhud.CheckType("PTSR_tooltips") != modname) return end
	
	if (skins[p.skin].name ~= TAKIS_SKIN)
	and (p.takistable.io.morehappyhour == 0)
		return
	end
	
	local takis = p.takistable
	local h = takis.HUD.ptsr
	
	h.xoffset = 0
	
	if not ( ((PTSR) and (PTSR.pizzatime)) or (JISK_PIZZATIME))
		return
	end
	
	local tics = JISK_PIZZATIMETICS or PTSR.pizzatime_tics

	
	local text,num = getlaptext(p)
	local exitingCount, playerCount = JISK_COUNT()

	if (not p.pizzaface) and (p.exiting) and (not PTSR.quitting) and (p.playerstate ~= PST_DEAD) and (exitingCount ~= playerCount)
		v.drawString(160, 130, "\x85Press FIRE to try a new lap!", V_ALLOWLOWERCASE|V_SNAPTOBOTTOM, "thin-center")
	end
	
	if tics > 3
		if num ~= 'dontdraw'
			h.xoffset = 31
			
			v.drawScaled(65*FU+(h.xoffset*FU),170*FU+(h.yoffset),3*FU/5,v.cachePatch("TA_LAPFLAG"),V_HUDTRANS|V_SNAPTOBOTTOM)
			v.drawString((85+h.xoffset)*FU,(160)*FU+(h.yoffset),text,V_ALLOWLOWERCASE|V_HUDTRANS|V_SNAPTOBOTTOM|V_RETURN8,"thin-fixed-center")

			v.drawString((85+h.xoffset)*FU,(177)*FU+(h.yoffset),num,V_PURPLEMAP|V_ALLOWLOWERCASE|V_HUDTRANS|V_SNAPTOBOTTOM|V_RETURN8,"fixed-center")
		end
		
		if playerCount == 1
			v.drawString((85+h.xoffset)*FU,(160-16)*FU+(h.yoffset),"\x88".."Exercise",V_ALLOWLOWERCASE|V_HUDTRANS|V_SNAPTOBOTTOM|V_RETURN8,"thin-fixed-center")
			v.drawString((85+h.xoffset)*FU,(160-8)*FU+(h.yoffset),"\x88".."Mode",V_ALLOWLOWERCASE|V_HUDTRANS|V_SNAPTOBOTTOM|V_RETURN8,"thin-fixed-center")
		end
		
	end
	
	if p.stuntime
	and tics > 3
		local ft = ((JISK_PIZZATIMESTUN) and (JISK_PIZZATIMESTUN.value)) or ((CV_PTSR) and (CV_PTSR.pizzatimestun.value))
		ft = $*TR
		
		local max = ft*FU
		local erm = FixedDiv(p.stuntime*FU,max)
		
		local scale2 = (30*FU)-FixedMul(erm,30*FU)
		
		if scale2 < 0 then scale2 = FU end
		
		v.drawString(165*FU,(120*FU)+(h.yoffset),"Frozen for "..p.stuntime/TR.." seconds",V_10TRANS|V_HUDTRANS|V_ALLOWLOWERCASE,"thin-fixed-center")
		v.drawScaled(145*FU,135*FU+(h.yoffset),FU,v.cachePatch("TA_ICE2"), V_HUDTRANS)
		v.drawCropped(
		145*FU, 135*FU+(scale2)+(h.yoffset),
		FU,FU,v.cachePatch("TA_ICE"), V_HUDTRANS,nil,
		0,scale2,30*FU,30*FU)	
		
	end
	
	if p.pizzaface
		if (p.pizzachargecooldown)
			v.drawString(153+(h.xoffset),162+(h.yoffset/FU),"Cooling down...",V_SNAPTOBOTTOM|V_HUDTRANS|V_ALLOWLOWERCASE,"small")
		elseif (p.pizzacharge)
			v.drawString(153+(h.xoffset),162+(h.yoffset/FU),"Charging!",V_SNAPTOBOTTOM|V_HUDTRANS|V_ALLOWLOWERCASE,"small")
		else
			v.drawString(153+(h.xoffset),162+(h.yoffset/FU),"Hold FIRE to teleport!", V_SNAPTOBOTTOM|V_HUDTRANS|V_ALLOWLOWERCASE,"small")
		end
		drawtelebar(v,p)
	end
end

local rankwidths = {
	["S"] = 34*FU,
	["A"] = 36*FU,
	["B"] = 32*FU,
	["C"] = 36*FU,
	["D"] = 35*FU,
}
local rankheights = {
	["S"] = 43*FU,
	["A"] = 44*FU,
	["B"] = 43*FU,
	["C"] = 40*FU,
	["D"] = 39*FU,
}

local function drawpizzaranks(v,p)

	if (customhud.CheckType("PTSR_rank") != modname) return end
	
	if (skins[p.skin].name ~= TAKIS_SKIN)
		return
	end
	
	if gametype ~= GT_PTSPICER then return end
	if p.pizzaface then return end
	
	local takis = p.takistable
	local h = takis.HUD.rank
	
	local x = (300-30)*FU
	local y = 35*FU
	
	if p.ptsr_rank
		v.drawScaled(x-(h.grow*25),y-(h.grow*20),FU/3+h.grow,
			v.cachePatch("HUDRANK"..p.ptsr_rank),
			V_HUDTRANS|V_SNAPTORIGHT|V_SNAPTOTOP
		)
		if h.percent
		and not ((p.ptsr_rank == "S" and p.timeshit) or (p.ptsr_rank == "P"))
			--thanks jisk for the help lol
			
			local max = h.percent
			local erm = FixedDiv((h.score),max)
			
			local scale2 = rankheights[p.ptsr_rank]-(FixedMul(erm,rankheights[p.ptsr_rank]))
			
 			if scale2 < 0 then scale2 = FU end
			
			v.drawCropped(x,y+(scale2/3),FU/3,FU/3,
				v.cachePatch("RANKFILL"..p.ptsr_rank),
				V_HUDTRANS|V_SNAPTORIGHT|V_SNAPTOTOP, 
				v.getColormap(nil, nil),
				0,scale2,
				rankwidths[p.ptsr_rank],rankheights[p.ptsr_rank]
			)
			
		end
		if p.timeshit
			v.drawScaled(x-(h.grow*25),y-(h.grow*20),FU/3+h.grow,
				v.cachePatch("HUDRANKBKN"),
				V_HUDTRANS|V_SNAPTORIGHT|V_SNAPTOTOP|V_50TRANS
			)
		end
	end

end

local function drawtauntmenu(v,p)

	if (customhud.CheckType("takis_tauntmenu") != modname) return end
	
	if (skins[p.skin].name ~= TAKIS_SKIN)
		return
	end
	
	local takis = p.takistable
	local me = p.mo
	
	if not takis.tauntmenu.open
		return
	end
	
	if not takis.tauntmenu.closingtime
		if takis.tauntmenu.yadd ~= 0
			local et = TR/2
			takis.tauntmenu.yadd = ease.outquad(( FU / et )*takis.tauntmenu.tictime,200*FU,0)
		end
		if takis.tauntmenu.tictime < 16
			v.fadeScreen(0xFF00,takis.tauntmenu.tictime)
		else
			v.fadeScreen(0xFF00,16)
		end
	else
		if takis.tauntmenu.yadd ~= 200*FU
			local et = TR/2
			takis.tauntmenu.yadd = ease.inquad(( FU / et )*((TR/2)-takis.tauntmenu.closingtime),0,200*FU)
		end	
		local tic = takis.tauntmenu.closingtime
		if tic > 16
			tic = 16
		end
		v.fadeScreen(0xFF00,tic)
	end
	local yadd = takis.tauntmenu.yadd
	
	
	v.drawScaled(160*FU,108*FU+yadd,FU/2,v.cachePatch("TAUNTBACK"),V_30TRANS,v.getColormap(nil, SKINCOLOR_BLACK))
	v.drawString(15*FU,(75*FU)+yadd,"Taunt",V_ALLOWLOWERCASE|V_HUDTRANS,"fixed")
	v.drawString(305*FU,(75*FU)+yadd,"Hit C1 to Cancel",V_ALLOWLOWERCASE|V_HUDTRANS,"thin-fixed-right")
	v.drawString(15*FU,(90*FU)+yadd,"Hit C3 to join a Partner Taunt",V_ALLOWLOWERCASE|V_HUDTRANS,"thin-fixed")
	v.drawString(305*FU,(86*FU)+yadd,"Quick Taunt: TF+#+C2/C3",V_ALLOWLOWERCASE|V_HUDTRANS,"small-fixed-right")
	v.drawString(305*FU,(94*FU)+yadd,"Delete Quick Taunt: TF+Fire+C2/C3",V_ALLOWLOWERCASE|V_HUDTRANS,"small-fixed-right")
	v.drawScaled(160*FU,100*FU+yadd,FU/2,v.cachePatch("TAUNTSEPAR"),0,nil)
	
	local ydisp = 25*FU
	for i = 1, 7 --#takis.tauntmenu.list
		v.drawScaled((20+(35*i))*FU,103*FU+yadd+ydisp,FU/2,v.cachePatch("TAUNTCELL"),V_10TRANS,v.getColormap(nil, SKINCOLOR_BLACK))
		local name = takis.tauntmenu.list[i]
		local xoffset = takis.tauntmenu.xoffsets[i] or 0
		local showicon = true
		
		local trans = V_HUDTRANS
		if ((name == "")
		or (name == nil))
			name = "\x86None"
			trans = V_HUDTRANSHALF
			showicon = false
		--there IS an entry, but no functions to call for it
		elseif ((TAKIS_TAUNT_INIT[i] == nil) or (TAKIS_TAUNT_THINK[i] == nil))
			name = "\x86"..takis.tauntmenu.list[i]
			trans = V_HUDTRANSHALF
		end
		
		if (i == takis.tauntmenu.cursor)
		and (takis.io.tmcursorstyle == 2)
			v.drawScaled((20+(35*i))*FU,103*FU+yadd+ydisp,(FU*6/10),v.cachePatch("TAUNTCUR"),0,v.getColormap(nil, SKINCOLOR_SUPERGOLD4))
		end
		
		if showicon
			
			local icon = (takis.tauntmenu.gfx.pix[i]) or "IRRELEVANT"
			local scale = (takis.tauntmenu.gfx.scales[i]) or FU
			
			local x,y = 0,0
			if icon == "IRRELEVANT"
				x,y = (-31*FU)/2,(-31*FU)/2
			end
			v.drawScaled( (20+(35*i))*FU+x, 103*FU+yadd+ydisp+y,
				scale, v.cachePatch(tostring(icon)),0,
				v.getColormap(TAKIS_SKIN, p.skincolor)
			)
		end
		
		v.drawString( (20+(35*i)+xoffset)*FU,(125*FU)+yadd+ydisp,
			name,trans|V_RETURN8|V_ALLOWLOWERCASE,
			"small-fixed-center"
		)
		if (takis.io.tmcursorstyle == 1)
			v.drawString( (20+(35*i))*FU,(135*FU)+yadd+ydisp,
				i,trans|V_ALLOWLOWERCASE,
				"small-fixed-center"
			)
		end
		if (i == takis.tauntquick1)
			v.drawString( (20+(35*i))*FU,(140*FU)+yadd+ydisp,
				"TF+C2",trans|V_ALLOWLOWERCASE,
				"small-fixed-center"
			)		
		end
		if (i == takis.tauntquick2)
			v.drawString( (20+(35*i))*FU,(140*FU)+yadd+ydisp,
				"TF+C3",trans|V_ALLOWLOWERCASE,
				"small-fixed-center"
			)		
		end

	end
	
	if (takis.io.tmcursorstyle == 2)
		v.drawString(160*FU,(135*FU)+yadd+ydisp,
			"Use Weapon Next/Prev to scroll. Press Fire Normal to select.",V_ALLOWLOWERCASE,
			"small-fixed-center"
		)	
	end
	
end

local function drawwareffect(v,p)
	if (customhud.CheckType("takis_tauntmenu") != modname) return end
	
	if (skins[p.skin].name ~= TAKIS_SKIN)
		return
	end
	
	local takis = p.takistable
	local me = p.mo
	
	if not (takis.shotgunned)
		return
	end
	
	local fade = 0
	local time = takis.shotguntime/10
	local maxfade = 3
	
	if (time%(maxfade*2))+1 > maxfade
		fade = maxfade-(time%maxfade)
	else
		fade = (time%maxfade)
	end
	fade = $+1
	
--	v.fadeScreen(35,fade)
	--drawfill my favorite :kindlygimmesummadat:
	v.drawScaled(0,0,FU*10,v.cachePatch("TAUNTBACK"),(9-fade)<<V_ALPHASHIFT,v.getColormap(nil,SKINCOLOR_RED))
end

--TODO: rewrite this all lel
--		needa make a font for this
local function drawcosmenu(v,p)
	if (customhud.CheckType("takis_cosmenu") != modname) return end
	
	local takis = p.takistable
	local me = p.mo
	
	local menu = takis.cosmenu
	local page = TAKIS_MENU.entries[menu.page]
	
	local function happyshakelol(v,pos)
		pos = $ or 0
		local s = 5
		local shakex,shakey = v.RandomFixed()/2,v.RandomFixed()/2
		
		local d1 = v.RandomRange(-1,1)
		local d2 = v.RandomRange(-1,1)
		if d1 == 0
			d1 = v.RandomRange(-1,1)
		end
		if d2 == 0
			d2 = v.RandomRange(-1,1)
		end

		shakex = $*s*d1
		shakey = $*s*d2
		
		local oncur = 0
		if pos-1 == takis.cosmenu.y then oncur = FU end
		
		shakex,shakey = FixedDiv($1,2*FU),FixedDiv($2,2*FU)
		shakex,shakey = FixedMul($1,oncur),FixedMul($2,oncur)
		
		return shakex,shakey
	end
	
	local pos = {x = 15,y = 10}
	local shakex,shakey = happyshakelol(v)
	
	--drawfill my favorite :kindlygimmesummadat:
	v.drawFill(0,0,v.width(),v.height(),31|V_SNAPTOLEFT|V_SNAPTOTOP)
	
	--draw title
	v.drawString(pos.x,pos.y,page.title,V_SNAPTOLEFT|V_SNAPTOTOP,"left")
	
	--the TEXT. BITCH!
	for i = 1,#page.text
		shakex,shakey = happyshakelol(v,i)
		if (page.text[i] == "$$$$$")
		
		else
			v.drawString(pos.x*FU+shakex, pos.y*FU+10*FU*i+shakey,
				page.text[i],
				V_SNAPTOLEFT|V_SNAPTOTOP,
				"thin-fixed"
			)
		end
	end
	
	/*
	local hinttrans = V_HUDTRANS
	if menu.hintfade > 0
		if menu.hintfade > (3*TR+9)
			hinttrans = (menu.hintfade-(3*TR+9))<<V_ALPHASHIFT
		end
		if menu.hintfade < 10
			hinttrans = (10-menu.hintfade)<<V_ALPHASHIFT
		end
		v.drawString(160*FU,Y+(25*FU/2*(maxbary+1)),
			"[C1] - Exit",
			V_GRAYMAP|V_RETURN8|V_ALLOWLOWERCASE|hinttrans,
			"thin-fixed-center"
		)
		v.drawString(160*FU,Y+(25*FU/2*(maxbary+1))+8*FU,
			"[Jump] - Select",
			V_GRAYMAP|V_RETURN8|V_ALLOWLOWERCASE|hinttrans,
			"thin-fixed-center"
		)
		v.drawString(160*FU,Y+(25*FU/2*(maxbary+1))+16*FU,
			"[Up/Down] - Move Cursor",
			V_GRAYMAP|V_RETURN8|V_ALLOWLOWERCASE|hinttrans,
			"thin-fixed-center"
		)
		v.drawString(160*FU,Y+(25*FU/2*(maxbary+1))+24*FU,
			"[Left/Right] - Flip page",
			V_GRAYMAP|V_RETURN8|V_ALLOWLOWERCASE|hinttrans,
			"thin-fixed-center"
		)
			
		if not paused
			menu.hintfade = $-1
		end
	end
	*/
	
	if takis.HUD.showingletter
		v.fadeScreen(0xFF00,16)
		if (p.cmd.buttons & BT_CUSTOM2)
			takis.HUD.showingletter = false
			P_RestoreMusic(p)
		end
		local color = v.getColormap(nil,p.skincolor)
		v.drawScaled(160*FU,100*FU,FU,v.cachePatch("IMP_LETTER"),V_HUDTRANS,color)
		v.drawString(82,11,"Dear pesky blasters...",V_ALLOWLOWERCASE|V_HUDTRANS|V_INVERTMAP,"thin")
		v.drawString(76,21,"The Badniks and I have taken over\nGreenflower City. The Chaos Emeralds are",V_RETURN8|V_ALLOWLOWERCASE|V_HUDTRANS|V_INVERTMAP,"thin")
		v.drawString(72,37,"now permanent guests at one of my seven",V_ALLOWLOWERCASE|V_HUDTRANS|V_INVERTMAP,"thin")
		v.drawString(69,37+8,"Special Stages. I dare you to find them, if\nyou can! ",V_ALLOWLOWERCASE|V_HUDTRANS|V_INVERTMAP,"thin")
		v.drawString(68,73,"C2 - Exit",V_ALLOWLOWERCASE|V_HUDTRANS|V_GRAYMAP,"left")
		v.drawScaled(108*FU,131*FU,FU,v.cachePatch("IMP_SIG"),V_HUDTRANS)
	end
end

local function drawcfgnotifs(v,p)
	if (customhud.CheckType("takis_cfgnotifs") != modname) return end
	
	if (skins[p.skin].name ~= TAKIS_SKIN)
		return
	end
	
	local takis = p.takistable
	local HUD = takis.HUD
	local me = p.mo
	
	if not HUD.cfgnotifstuff
		return
	end
	
	local trans = 0
	
	if HUD.cfgnotifstuff >= 6*TR+9
		trans = (HUD.cfgnotifstuff-(6*TR+9))<<V_ALPHASHIFT
	elseif HUD.cfgnotifstuff < 10
		trans = (10-HUD.cfgnotifstuff)<<V_ALPHASHIFT
	end
	
	local waveforce = FU/10
	local ay = FixedMul(waveforce,sin(leveltime*ANG2))
	v.drawScaled(160*FU,65*FU,FU+ay,v.cachePatch("BUBBLEBOX"),trans)
	
	v.drawString(160,50,"You have no Config, check",trans|V_ALLOWLOWERCASE,"thin-center")
	v.drawString(160,60,"out the \x86takis_openmenu\x80.",trans|V_ALLOWLOWERCASE,"thin-center")
	v.drawString(160,70,"Make sure to get the Music Wad!",trans|V_ALLOWLOWERCASE,"thin-center")
	v.drawString(160,80,"\x86".."C3 - Dismiss",trans|V_ALLOWLOWERCASE,"thin-center")
	
	if takis.c3
		HUD.cfgnotifstuff = 1
	end
	
	HUD.cfgnotifstuff = $-1
end

local function drawbonuses(v,p)
	if (customhud.CheckType("takis_cfgnotifs") != modname) return end
	
	if (skins[p.skin].name ~= TAKIS_SKIN)
		return
	end
	
	local takis = p.takistable
	local HUD = takis.HUD
	local me = p.mo
	
	TakisDrawBonuses(
		v, p, -- Self explanatory.
		(300-15)*FU, 30*FU, V_SNAPTORIGHT|V_SNAPTOTOP|V_ALLOWLOWERCASE, -- Powerups X & Y. Flags.
		'thin-fixed-right', -- string alignment.
		8*FU, ANGLE_90-- Distance to shift and which angle to do so.
	)
end

local function drawcrosshair(v,p)
	if (customhud.CheckType("takis_crosshair") != modname) return end
	
	if (skins[p.skin].name ~= TAKIS_SKIN)
		return
	end
	
	local takis = p.takistable
	local me = p.mo
	
	if not (takis.shotgunned)
		return
	end
	
	if (camera.chase)
		return
	end
	
	local trans = V_HUDTRANS
	local scale = FU/2
	if takis.shotguncooldown
		scale = $+FixedDiv(takis.shotguncooldown*FU,6*FU)
		trans = V_HUDTRANSHALF
	end
	if (takis.noability & NOABIL_SHOTGUN)
		trans = V_HUDTRANSHALF
	end
	
	v.drawScaled(160*FU,100*FU,scale,v.cachePatch("SHGNCRSH"),trans)
end

/*
local function drawbubbles(v,p,cam)
	--chrispy chars
	local player = p
	local mo = player.mo
	
	local flip = 1
	local bubble = v.cachePatch("TA_BUBBLE")
	local angdiff = ANGLE_90
	local x, y, scale
	local cutoff = function(y) return false end
	
	if cam.chase and not (player.awayviewtics and not (me.flags2 & MF2_TWOD))
		x, y, scale = R_GetScreenCoords(v, player, cam, mo)
		x = $+(10*scale)
		if mo.eflags & MFE_VERTICALFLIP
		and player.pflags & PF_FLIPCAM
			y = 200*FRACUNIT - $
		else
			flip = P_MobjFlip(mo)
		end
	else
		x, y, scale = 160*FRACUNIT, (100 + bubble.height >> 1)*FRACUNIT, FRACUNIT/3
	end
	
	if splitscreen
		if player == secondarydisplayplayer
			cutoff = function(y) return y < (bubble.height*scale >> 1) end
		else
			cutoff = function(y) return y > 200*FRACUNIT + (bubble.height*scale >> 1) end
		end
	end
	
	local angle = angdiff - ANGLE_90
	local x = x - P_ReturnThrustX(nil, angle, 50*scale)
	local y = y - flip*P_ReturnThrustY(nil, angle, 64*scale)
		
	if not cutoff(y)
	and p.powers[pw_underwater]
		local j = -1
		for i = -3,2
			j = $+1
			local flag = V_HUDTRANSHALF
			if j-1 < p.powers[pw_underwater]/TR/5
				flag = V_HUDTRANS
			end
			v.drawScaled(x, y+(i*25*scale), scale, bubble, V_PERPLAYER|flag)
		end
	end
end
*/

local function DrawButton(v, player, x, y, flags, color, color2, butt, symb, strngtype)
-- Buttons! Shows input controls.
-- butt parameter is the button cmd in question.
-- symb represents the button via drawn string.
	local offs, col
	if (butt == 1) then
		offs = 0
		col = flags|color2
	elseif (butt > 1) then
		offs = 0
		col = flags|color
	else
		offs = 1
		col = flags|16
		v.drawFill(
			(x), (y+9),
			10, 1, flags|29
		)
	end
	v.drawFill(
		(x), (y)-offs,
		10, 10,	col
	)
	
	local stringx, stringy = 1, 1
	if (strngtype == 'thin') then
		stringx, stringy = 0, 2
	end
	
	v.drawString(
		(x+stringx), (y+stringy)-offs,
		symb, flags, strngtype
	)
end

local function DrawMiniButton(v, player, x, y, flags, color, butt, symb, strngtype)
-- This is identical to above. Only mini, when you need to have it small.
-- butt parameter is the button cmd in question.
-- symb represents the button via drawn string.
	local offs, col
	if (butt) and (player.cmd.buttons & butt) then
		offs = 0
		col = flags|color
	else
		offs = 1
		col = flags|16
		v.drawFill(
			(x), (y+9),
			5, 1, flags|29
		)
	end
	v.drawFill(
		(x), (y)-offs,
		5, 10,	col
	)
	
	local stringx, stringy = 1, 1
	if (strngtype == 'thin') then
		stringx, stringy = 0, 2
	end
	
	v.drawString(
		(x+stringx), (y+stringy)-offs,
		symb, flags, strngtype
	)
end

local function drawflag(v,x,y,string,flags,onmap,offmap,align,flag)
	local map = offmap
	if flag
		map = onmap
	end
	
	v.drawString(x,y,string,flags|map,align)
end

local function drawdebug(v,p)
	local takis = p.takistable
	local me = p.mo
	
	if not TAKIS_ISDEBUG
		return
	end
	
	if (TAKIS_DEBUGFLAG & DEBUG_BUTTONS)
		local x, y = 16, 156
		local flags = V_HUDTRANS|V_PERPLAYER|V_SNAPTOBOTTOM|V_SNAPTOLEFT
		local color = (p.skincolor and skincolors[p.skincolor].ramp[4] or 0)
		local color2 = (ColorOpposite(p.skincolor) and skincolors[ColorOpposite(p.skincolor)].ramp[4] or 0)
		DrawButton(v, p, x, y, flags, color, color2, takis.jump, 'J', 'left')
		DrawButton(v, p, x+11, y, flags, color, color2, takis.use,  'S', 'left')
		DrawButton(v, p, x+22, y, flags, color, color2, takis.tossflag, 'TF', 'thin')
		DrawButton(v, p, x+33, y, flags, color, color2, takis.c1,  'C1', 'thin')
		DrawButton(v, p, x+44, y, flags, color, color2, takis.c2,  'C2', 'thin')
		DrawButton(v, p, x+55, y, flags, color, color2, takis.c3,  'C3', 'thin')
		DrawButton(v, p, x+66, y, flags, color, color2, takis.fire,'F', 'left')
		DrawButton(v, p, x+77, y, flags, color, color2, takis.firenormal,'FN', 'thin')
		
		v.drawString(x,y-58,"noability",flags|V_GREENMAP,"thin")
		drawflag(v,x+00,y-50,"CL",flags,V_GREENMAP,V_REDMAP,"thin",(takis.noability & NOABIL_CLUTCH))
		drawflag(v,x+15,y-50,"HM",flags,V_GREENMAP,V_REDMAP,"thin",(takis.noability & NOABIL_HAMMER))
		drawflag(v,x+30,y-50,"DI",flags,V_GREENMAP,V_REDMAP,"thin",(takis.noability & NOABIL_DIVE))
		drawflag(v,x+45,y-50,"SL",flags,V_GREENMAP,V_REDMAP,"thin",(takis.noability & NOABIL_SLIDE))
		drawflag(v,x+60,y-50,"WD",flags,V_GREENMAP,V_REDMAP,"thin",(takis.noability & NOABIL_WAVEDASH))
		drawflag(v,x+75,y-50,"SG",flags,V_GREENMAP,V_REDMAP,"thin",(takis.noability & NOABIL_SHOTGUN))
		drawflag(v,x+85,y-50,"SH",flags,V_GREENMAP,V_REDMAP,"thin",(takis.noability & NOABIL_SHIELD))
		
		v.drawString(x,y-38,"FSTASIS",flags|V_GREENMAP,"thin")
		v.drawString(x,y-30,takis.stasistic,flags,"thin")
		
		v.drawString(x+60,y-38,"stasis",flags,"thin")
		drawflag(v,x+60,y-30,"FS",flags,V_GREENMAP,V_REDMAP,"thin",(p.pflags & PF_FULLSTASIS))
		drawflag(v,x+78,y-30,"JS",flags,V_GREENMAP,V_REDMAP,"thin",(p.pflags & PF_JUMPSTASIS))
		drawflag(v,x+96,y-30,"SS",flags,V_GREENMAP,V_REDMAP,"thin",(p.pflags & PF_STASIS))
		
		v.drawString(x,y-18,"nocontrol",flags|V_GREENMAP,"thin")
		v.drawString(x,y-10,takis.nocontrol,flags,"thin")
		
		v.drawString(x+60,y-18,"nocontrol",flags,"thin")
		v.drawString(x+60,y-10,p.powers[pw_nocontrol],flags,"thin")
		
	end
	if (TAKIS_DEBUGFLAG & DEBUG_PAIN)
		drawflag(v,160,122,"Pain",V_HUDTRANS|V_PERPLAYER|V_ALLOWLOWERCASE,V_GREENMAP,V_REDMAP,"thin",(takis.inPain))
		drawflag(v,160,130,"FakePain",V_HUDTRANS|V_PERPLAYER|V_ALLOWLOWERCASE,V_GREENMAP,V_REDMAP,"thin",(takis.inFakePain))
		drawflag(v,160,138,"WaterSlide",V_HUDTRANS|V_PERPLAYER|V_ALLOWLOWERCASE,V_GREENMAP,V_REDMAP,"thin",(takis.inwaterslide))
	end
	if (TAKIS_DEBUGFLAG & DEBUG_ACH)
		for k,va in ipairs(takis.HUD.steam)
			if va == nil
				continue
			end
			
			local t = TAKIS_ACHIEVEMENTINFO
			v.drawString(165,k*8,t[va.enum].name,
				V_ALLOWLOWERCASE|V_HUDTRANS|V_SNAPTOTOP,
				"thin"
			)
		end	
	end
	if (TAKIS_DEBUGFLAG & DEBUG_QUAKE)
		for k,va in ipairs(takis.quake)
			if va == nil
				continue
			end
			
			v.drawString(40,8*(k-1),
				va.tics.." | "..
				L_FixedDecimal(va.intensity,3),
				V_HUDTRANS,
				"left"
			)
		end
		v.drawString(40,-8,L_FixedDecimal(takis.quakeint,3),V_HUDTRANS,"left")
	end
	if (TAKIS_DEBUGFLAG & DEBUG_HAPPYHOUR)
		local strings = prtable("Happy Hour",HAPPY_HOUR,false)
		for k,va in ipairs(strings)
			v.drawString(100,30+(8*(k-1)),va,V_ALLOWLOWERCASE,"left")
		end
		
	end
	if (TAKIS_DEBUGFLAG & DEBUG_ALIGNER)
		v.draw(160,100,v.cachePatch("ALIGNER"),V_20TRANS)
	end
	if (TAKIS_DEBUGFLAG & DEBUG_PFLAGS)
		drawflag(v,100,60,"FC",
			V_HUDTRANS|V_PERPLAYER,
			V_GREENMAP,V_REDMAP,
			"small",
			(p.pflags & PF_FLIPCAM)
		)
		drawflag(v,110,60,"AM",
			V_HUDTRANS|V_PERPLAYER,
			V_GREENMAP,V_REDMAP,
			"small",
			(p.pflags & PF_ANALOGMODE)
		)
		drawflag(v,120,60,"DC",
			V_HUDTRANS|V_PERPLAYER,
			V_GREENMAP,V_REDMAP,
			"small",
			(p.pflags & PF_DIRECTIONCHAR)
		)
		drawflag(v,130,60,"AB",
			V_HUDTRANS|V_PERPLAYER,
			V_GREENMAP,V_REDMAP,
			"small",
			(p.pflags & PF_AUTOBRAKE)
		)
		drawflag(v,140,60,"GM",
			V_HUDTRANS|V_PERPLAYER,
			V_GREENMAP,V_REDMAP,
			"small",
			(p.pflags & PF_GODMODE)
		)
		drawflag(v,150,60,"NC",
			V_HUDTRANS|V_PERPLAYER,
			V_GREENMAP,V_REDMAP,
			"small",
			(p.pflags & PF_NOCLIP)
		)
		drawflag(v,160,60,"IV",
			V_HUDTRANS|V_PERPLAYER,
			V_GREENMAP,V_REDMAP,
			"small",
			(p.pflags & PF_INVIS)
		)
		drawflag(v,170,60,"ad",
			V_HUDTRANS|V_PERPLAYER,
			V_GREENMAP,V_REDMAP,
			"small",
			(p.pflags & PF_ATTACKDOWN)
		)
		drawflag(v,180,60,"sd",
			V_HUDTRANS|V_PERPLAYER,
			V_GREENMAP,V_REDMAP,
			"small",
			(p.pflags & PF_SPINDOWN)
		)
		drawflag(v,190,60,"jd",
			V_HUDTRANS|V_PERPLAYER,
			V_GREENMAP,V_REDMAP,
			"small",
			(p.pflags & PF_JUMPDOWN)
		)
		drawflag(v,200,60,"wd",
			V_HUDTRANS|V_PERPLAYER,
			V_GREENMAP,V_REDMAP,
			"small",
			(p.pflags & PF_WPNDOWN)
		)
		drawflag(v,210,60,"Stasis not drawn",
			V_HUDTRANS|V_PERPLAYER,
			V_GREENMAP,0,
			"small"
		)
		
		drawflag(v,100,70,"AA",
			V_HUDTRANS|V_PERPLAYER,
			V_GREENMAP,V_REDMAP,
			"small",
			(p.pflags & PF_APPLYAUTOBRAKE)
		)
		drawflag(v,110,70,"sj",
			V_HUDTRANS|V_PERPLAYER,
			V_GREENMAP,V_REDMAP,
			"small",
			(p.pflags & PF_STARTJUMP)
		)
		drawflag(v,120,70,"ju",
			V_HUDTRANS|V_PERPLAYER,
			V_GREENMAP,V_REDMAP,
			"small",
			(p.pflags & PF_JUMPED)
		)
		drawflag(v,130,70,"nj",
			V_HUDTRANS|V_PERPLAYER,
			V_GREENMAP,V_REDMAP,
			"small",
			(p.pflags & PF_NOJUMPDAMAGE)
		)
		drawflag(v,140,70,"sp",
			V_HUDTRANS|V_PERPLAYER,
			V_GREENMAP,V_REDMAP,
			"small",
			(p.pflags & PF_SPINNING)
		)
		drawflag(v,150,70,"ss",
			V_HUDTRANS|V_PERPLAYER,
			V_GREENMAP,V_REDMAP,
			"small",
			(p.pflags & PF_STARTDASH)
		)
		drawflag(v,160,70,"th",
			V_HUDTRANS|V_PERPLAYER,
			V_GREENMAP,V_REDMAP,
			"small",
			(p.pflags & PF_THOKKED)
		)
		drawflag(v,170,70,"sa",
			V_HUDTRANS|V_PERPLAYER,
			V_GREENMAP,V_REDMAP,
			"small",
			(p.pflags & PF_SHIELDABILITY)
		)
		drawflag(v,100,70,"AA",
			V_HUDTRANS|V_PERPLAYER,
			V_GREENMAP,V_REDMAP,
			"small",
			(p.pflags & PF_APPLYAUTOBRAKE)
		)
		
	end
	if (TAKIS_DEBUGFLAG & DEBUG_DEATH)
		v.drawString(100,100,"State: "..me.state,V_ALLOWLOWERCASE,"thin")
		v.drawString(100,108,"Sprite2: "..me.sprite2,V_ALLOWLOWERCASE,"thin")
		v.drawString(100,116,"PState: "..p.playerstate,V_ALLOWLOWERCASE,"thin")
	end
	if (TAKIS_DEBUGFLAG & DEBUG_SPEEDOMETER)
		
		local speed = FixedDiv(takis.accspeed,100*FU)
		local roll
		local offy = 0
		local scale = FU
		if (speed ~= 0)
			roll = FixedAngle(90*FU-FixedMul(90*FU,speed))
		else
			roll = FixedAngle(90*FU)
		end
		if (roll == 0)
			offy = 4
		end
		if (takis.accspeed >= 100*FU)
			scale = $+FixedDiv(takis.accspeed-100*FU,20*FU)
		end
		
		for i = 0,5
			local ra = FixedAngle(90*FU-(i*18)*FU)
			v.drawScaled((hudinfo[HUD_LIVES].x+4)*FU,
				(hudinfo[HUD_LIVES].y-8+offy)*FU,
				FU,
				v.getSpritePatch(SPR_THND,B,0,ra),
				V_HUDTRANS|V_SNAPTOLEFT|V_SNAPTOBOTTOM|V_PERPLAYER
			)
		
		end
		
		v.drawScaled((hudinfo[HUD_LIVES].x+4)*FU,
			(hudinfo[HUD_LIVES].y-8+offy)*FU,
			FU,
			v.getSpritePatch(SPR_THND,A,0,roll),
			V_HUDTRANS|V_SNAPTOLEFT|V_SNAPTOBOTTOM|V_PERPLAYER
		)
		
		
		local scorenum = "CMBCF"
		local score = L_FixedDecimal(takis.accspeed,3)
		
		local prevw
		if not prevw then prevw = 0 end
		
		for i = 1,string.len(score)
			local n = string.sub(score,i,i)
			--if n == "." then n = "DOT" end
			v.drawScaled(hudinfo[HUD_LIVES].x*FU+(prevw*scale),
				(hudinfo[HUD_LIVES].y)*FU-(v.cachePatch(scorenum+n).height*FixedDiv(scale-FU,2*FU)),
				FixedDiv(scale,2*FU),
				v.cachePatch(scorenum+n),
				V_HUDTRANS|V_SNAPTOLEFT|V_SNAPTOBOTTOM|V_PERPLAYER
			)
				
			prevw = $+v.cachePatch(scorenum+n).width*4/10
		end
		
		//height debug
		local scale = FU/10
		local floorz = me.floorz
		local drawz = 175*FU-FixedMul(floorz,scale)
		v.drawFill(105,175-(FixedMul(floorz,scale)/FU),60,2,
			skincolors[ColorOpposite(p.skincolor)].ramp[4]|
			V_SNAPTOBOTTOM
		)
		local dist = (me.z-floorz)
		v.drawScaled(115*FU,
			drawz-FixedMul(dist,scale),
			FixedMul(scale,skins[me.skin].highresscale or FU),
			v.getSprite2Patch(me.skin,me.sprite2,
			p.powers[pw_super] > 0,
			me.frame,
				3,me.rollangle
			),
			V_SNAPTOBOTTOM,
			v.getColormap(nil,me.color)
		)
		for i = 0,2
			v.drawScaled(122*FU+(i*FU*7),
				drawz,
				FixedMul(scale,skins[i].highresscale or FU),
				v.getSprite2Patch(i,SPR2_STND,false,A,
					3,0
				),
				V_SNAPTOBOTTOM,
				v.getColormap(i,skins[i].prefcolor)
			)		
		end
		v.drawScaled(146*FU,
			drawz,
			scale,
			v.getSpritePatch(SPR_BRAK,A,3,0),
			V_SNAPTOBOTTOM
		)
		v.drawString(115*FU,
			drawz-4*FU-FixedMul(dist,FixedDiv(scale,2*FU)),
			L_FixedDecimal(dist,3),
			V_SNAPTOBOTTOM,
			"thin-fixed"
		)
	end
end

--draw the stuff
customhud.SetupItem("takis_wareffect", 		modname/*,	drawfreeze,		"game",	1*/)
customhud.SetupItem("takis_freezing", 		modname/*,	drawfreeze,		"game",	1*/)
customhud.SetupItem("takis_clutchstuff",	modname/*,	drawclutches,	"game",	23*/) --
customhud.SetupItem("rings", 				modname/*,	drawrings,		"game",	24*/) 
customhud.SetupItem("time", 				modname/*,	drawtimer,		"game",	25*/) 
customhud.SetupItem("lives", 				modname/*,	drawlivesarea,	"game",	10*/)
customhud.SetupItem("takis_combometer", 	modname/*,	drawcombostuff,	"game",	27*/) 
customhud.SetupItem("score", 				modname/*,	drawscore,		"game",	26*/) 
customhud.SetupItem("takis_heartcards", 	modname/*,	drawheartcards,	"game",	30*/) --
customhud.SetupItem("takis_statusface", 	modname/*,	drawface,		"game",	31*/) --
customhud.SetupItem("takis_c3jumpscare", 	modname/*,	drawface,		"game",	31*/) --
customhud.SetupItem("takis_tauntmenu", 		modname/*,	drawface,		"game",	31*/) --
customhud.SetupItem("takis_cosmenu", 		modname/*,	drawface,		"game",	31*/) --
customhud.SetupItem("rings", 				modname/*,	drawrings,		"game",	24*/) 
customhud.SetupItem("time", 				modname/*,	drawtimer,		"game",	25*/) 
customhud.SetupItem("score", 				modname/*,	drawscore,		"game",	26*/) 
customhud.SetupItem("lives", 				modname/*,	drawlivesarea,	"game",	10*/)
customhud.SetupItem("takis_cfgnotifs", 		modname/*,	drawlivesarea,	"game",	10*/)
customhud.SetupItem("takis_bonuses", 		modname/*,	drawlivesarea,	"game",	10*/)
customhud.SetupItem("takis_crosshair", 		modname/*,	drawlivesarea,	"game",	10*/)
customhud.SetupItem("takis_happyhourtime", 	modname/*,	drawlivesarea,	"game",	10*/)

addHook("HUD", function(v,p,cam)
	if not p
	or not p.valid
	or PSO
		return
	end
	
	if not p.takistable
		return
	end
	
	/*
	if p.takistable.inNIGHTSMode
	or (TAKIS_NET.inspecialstage)
		return
	end
	*/
	
	local takis = p.takistable
	local me = p.mo
	
	if takis
		drawhappytime(v,p)
		if takis.isTakis
			
			--customhud.SetupItem("takis_wareffect", 		modname/*,	drawfreeze,		"game",	1*/)
			customhud.SetupItem("takis_freezing", 		modname/*,	drawfreeze,		"game",	1*/)
			customhud.SetupItem("takis_clutchstuff",	modname/*,	drawclutches,	"game",	23*/) --
			customhud.SetupItem("rings", 				modname/*,	drawrings,		"game",	24*/) 
			customhud.SetupItem("time", 				modname/*,	drawtimer,		"game",	25*/) 
			customhud.SetupItem("score", 				modname/*,	drawscore,		"game",	26*/) 
			customhud.SetupItem("lives", 				modname/*,	drawlivesarea,	"game",	10*/)
			customhud.SetupItem("takis_combometer", 	modname/*,	drawcombostuff,	"game",	27*/) 
			customhud.SetupItem("takis_heartcards", 	modname/*,	drawheartcards,	"game",	30*/) --
			customhud.SetupItem("takis_statusface", 	modname/*,	drawface,		"game",	31*/) --
			customhud.SetupItem("takis_c3jumpscare", 	modname/*,	drawface,		"game",	31*/) --
			customhud.SetupItem("takis_tauntmenu", 		modname/*,	drawface,		"game",	31*/) --
			customhud.SetupItem("takis_cfgnotifs", 		modname/*,	drawlivesarea,	"game",	10*/)
			customhud.SetupItem("takis_bonuses", 		modname/*,	drawlivesarea,	"game",	10*/)
			customhud.SetupItem("takis_crosshair", 		modname/*,	drawlivesarea,	"game",	10*/)
			customhud.SetupItem("takis_happyhourtime", 	modname/*,	drawlivesarea,	"game",	10*/)
		
			if takis.io.nohappyhour == 0
				customhud.SetupItem("PTSR_itspizzatime",modname)
				customhud.SetupItem("PTSR_bar",modname)
				customhud.SetupItem("PTSR_tooltips",modname)
			elseif takis.io.nohappyhour == 1
				customhud.SetupItem("PTSR_itspizzatime","spicerunners")
				customhud.SetupItem("PTSR_bar","spicerunners")
				customhud.SetupItem("PTSR_tooltips","spicerunners")
			end
			customhud.SetupItem("PTSR_rank", modname)
			--customhud.SetupItem("rank", modname)
			
			if p.takis
			and p.takis.shotgunnotif
				local waveforce = FU/10
				local ay = FixedMul(waveforce,sin(leveltime*ANG2))
				v.drawScaled(160*FU,65*FU,FU+ay,v.cachePatch("SPIKEYBOX"),0)
				local draw = true
				if p.takis.shotgunnotif >= 5*TR
					if not (p.takis.shotgunnotif % 2)
						draw = false
					end
				elseif p.takis.shotgunnotif <= TR
					if not (p.takis.shotgunnotif % 2)
						draw = false
					end				
				end
				
				if draw
					v.drawString(160,55,"\x85You will be spawning with a",V_ALLOWLOWERCASE,"thin-center")
					v.drawString(160,65,"\x82Shotgun\x85 from now on!",V_ALLOWLOWERCASE,"thin-center")
					v.drawString(160,75,"C3 - Don't Care",V_ALLOWLOWERCASE,"thin-center")
				end
				if (p.cmd.buttons & BT_CUSTOM3)
					p.takis.shotgunnotif = 1
				end
				
				p.takis.shotgunnotif = $-1
			end
			
			--drawwareffect(v,p)
			if not (takis.cosmenu.menuinaction)
				drawclutches(v,p,cam)
				--drawbubbles(v,p,cam)
				drawrings(v,p)
				drawtimer(v,p)
				drawlivesarea(v,p)
				drawcombostuff(v,p)
				drawbonuses(v,p)
				drawheartcards(v,p)
				drawscore(v,p)
				drawface(v,p)
				drawtauntmenu(v,p)
				drawpizzatips(v,p)
				drawpizzatimer(v,p)
				drawpizzaranks(v,p)
				drawcrosshair(v,p)
				--drawnickranks(v,p)
			else
				drawcosmenu(v,p)
			end
			drawcfgnotifs(v,p)
			drawhappyhour(v,p)
			
			if takis.fchelper
				--fc helper
				local t = V_HUDTRANS
				if takis.thingsdestroyed == TAKIS_NET.numdestroyables
					t = V_HUDTRANSHALF
				end
				v.drawString(300-15,94,takis.thingsdestroyed,V_SNAPTORIGHT|t|V_BLUEMAP,"center")
				v.drawString(300-15,106,TAKIS_NET.numdestroyables,V_SNAPTORIGHT|t|V_BLUEMAP,"center")
			end
			
			if (takis.shotguntuttic)
				local string = ''
				if (takis.tossflag)
					local dec = L_FixedDecimal(
						FixedMul(
							FixedDiv(takis.tossflag*FU,
								17*FU
							),
							100*FU
						),
						1
					)
					string = "("..dec.."%) "
				end
				
				v.drawString(160,200-25,string.."\x82TOSSFLAG\x80: Shotgun Tutorial",
					V_ALLOWLOWERCASE|V_HUDTRANSHALF|V_SNAPTOBOTTOM,
					"thin-center"
				)
			end
		else
			customhud.SetupItem("rings","vanilla")
			customhud.SetupItem("time","vanilla")
			customhud.SetupItem("score","vanilla")
			customhud.SetupItem("lives","vanilla")
			if takis.io.morehappyhour == 0
				customhud.SetupItem("PTSR_itspizzatime","spicerunners")
			else
				customhud.SetupItem("PTSR_itspizzatime",modname)
				drawhappyhour(v,p)			
			end
			customhud.SetupItem("PTSR_bar","spicerunners")
			customhud.SetupItem("PTSR_tooltips","spicerunners")
			customhud.SetupItem("PTSR_rank", "spicerunners")
			--customhud.SetupItem("rank", "pizzatime2.0")
			
			--elfilin stuff
			if ((me) and (me.valid))
			and (me.skin == "elfilin")
			and (p.elfilin)
				--check out my sweet new ride!
				local ride = p.elfilin.ridingplayer
				
				if p.elfilin
				and ((ride) and (ride.valid))

					local p2 = ride.player
					local takis2 = p2.takistable
					
					if ride.skin == TAKIS_SKIN
						
						if takis2.io.nohappyhour == 0
						and takis.io.morehappyhour == 0
							customhud.SetupItem("PTSR_itspizzatime",modname)
							drawhappyhour(v,p2)
						end
						
						
						local workx = (265*FU)-(35*FU)
						
						--draw p2's heartcards
						for i = 1, TAKIS_MAX_HEARTCARDS
							local patch = v.cachePatch("HEARTCARD2")
							
							if takis2.heartcards >= i
								patch = v.cachePatch("HEARTCARD1")
							end
							
							v.drawScaled(
								workx,
								100*FU,
								FU/2,
								patch,
								V_SNAPTOTOP|V_SNAPTORIGHT|V_PERPLAYER
							)
							
							workx = $+(12*FU)
							
						end
					
						
						--show p2's combo
						drawcombostuff(v,p2)
						if takis2.combo.count
							
							v.drawString((hudinfo[HUD_RINGS].x+18+combdisp+6+10)*FU,(hudinfo[HUD_RINGS].y+20+35+comby-55-4)*FU,p2.name.."'s Combo",V_HUDTRANS|V_ALLOWLOWERCASE|V_SNAPTOLEFT|V_SNAPTOTOP|V_PERPLAYER,"thin-fixed-center")
							v.drawString((hudinfo[HUD_RINGS].x+18+combdisp+6+10)*FU,(hudinfo[HUD_RINGS].y+20+35+comby-55+4)*FU,"Cheer to refill!",V_HUDTRANS|V_ALLOWLOWERCASE|V_SNAPTOLEFT|V_SNAPTOTOP|V_PERPLAYER,"thin-fixed-center")
							
							/*
							local shake = takis2.HUD.combo.meter.shake
							local combdisp = 8
							local comby = 14
							if (p2.pflags & PF_FINISHED)
							or (p.pflags & PF_FINISHED)
								comby = $+16
							end
							comby = $+10
							
							drawcombotimebar(v,p,takis2,comby,0,shake)
							local meterx,metery = unpack(takis2.HUD.combo.meter.FIXED)
							local numx,numy = unpack(takis2.HUD.combo.num.int)
							v.drawScaled(meterx,metery+(comby*FU)+(shake),6*FU/5,v.cachePatch("TAKCOBACK"),V_HUDTRANS|V_SNAPTOLEFT|V_SNAPTOTOP|V_PERPLAYER, v.getColormap(nil, nil))
							v.drawNum(numx,numy+comby+(shake/FU),takis2.combo.count,V_HUDTRANS|V_SNAPTOLEFT|V_SNAPTOTOP|V_PERPLAYER)
							v.drawString((hudinfo[HUD_RINGS].x+18+combdisp+6)*FU,(hudinfo[HUD_RINGS].y+20+comby)*FU+(shake),"Combo!",V_HUDTRANS|V_ALLOWLOWERCASE|V_SNAPTOLEFT|V_SNAPTOTOP|V_PERPLAYER,"thin-fixed")
							
							if takis2.combo.verylevel > 0
								for i = 1, takis2.combo.verylevel
									
									local verypatch = v.cachePatch("TAKCOVERY")
									--if not (i % 2)
									--	verypatch = v.cachePatch("TAKCOSUPR")
									--end
									v.drawScaled(meterx+(7*FU)+(i*(3*FU)),metery+(37*FU)+(i*2*FU)+(comby*FU),FU/3,verypatch,V_HUDTRANS|V_SNAPTOLEFT|V_SNAPTOTOP|V_PERPLAYER, v.getColormap(nil, color))
									
								end
							end
							
							local length = #TAKIS_COMBO_RANKS
							v.drawString((hudinfo[HUD_RINGS].x+18+combdisp+6+10)*FU,(hudinfo[HUD_RINGS].y+20+35+comby)*FU,TAKIS_COMBO_RANKS[ ((takis2.combo.rank-1) % length)+1 ],V_HUDTRANS|V_ALLOWLOWERCASE|V_SNAPTOLEFT|V_SNAPTOTOP|V_PERPLAYER,"thin-fixed-center")
							*/
						end
						
					end
					
				end
				
			end
			
			if takis.cosmenu.menuinaction
				drawcosmenu(v,p)
			end
		end
		drawjumpscarelol(v,p)
		--prtable("steam",takis.HUD.steam)
		for k,va in ipairs(takis.HUD.steam)
			if va == nil
				continue
			end
			
			local enum = va.enum
			local bottom = 16*FU
			local trans = 0
			local yadd = 28*FU*(k-1)
			yadd = -$
			if va.tics < 10
				trans = (10-va.tics)<<V_ALPHASHIFT
			end
			
			local t = TAKIS_ACHIEVEMENTINFO
			local x = va.xadd
			
			v.drawScaled(178*FU+x,172*FU+yadd,FU,
				v.cachePatch("ACH_BOX"),
				trans|V_SNAPTORIGHT|V_SNAPTOBOTTOM
			)
			v.drawScaled((300*FU)-118*FU+x,(200*FU)-bottom-(8*FU)+yadd,
				t[enum].scale or FU,
				v.cachePatch(t[enum].icon),
				trans|V_SNAPTORIGHT|V_SNAPTOBOTTOM
			)
			v.drawString((300*FU)-100*FU+x,
				(200*FU)-bottom-(8*FU)+yadd,
				t[enum].name or "Ach. Enum "..enum,
				trans|V_SNAPTORIGHT|V_SNAPTOBOTTOM|V_ALLOWLOWERCASE|V_RETURN8,
				"thin-fixed"
			)
			v.drawString((300*FU)-100*FU+x,
				(200*FU)-bottom+yadd,
				t[enum].text or "Flavor text goes here",
				trans|V_SNAPTORIGHT|V_SNAPTOBOTTOM|V_ALLOWLOWERCASE|V_RETURN8,
				"small-fixed"
			)
			
		end
		
		if takis.HUD.menutext.tics
			local trans = 0
			if takis.HUD.menutext.tics > (3*TR)
				trans = (takis.HUD.menutext.tics-3*TR)<<V_ALPHASHIFT
			elseif takis.HUD.menutext.tics < 10
				trans = (10-takis.HUD.menutext.tics)<<V_ALPHASHIFT
			end
			
			v.drawString(160,200-8,"\x86takis_openmenu\x80 - Open Menu",trans|V_ALLOWLOWERCASE|V_SNAPTOBOTTOM,"thin-center")
			takis.HUD.menutext.tics = $-1
		end
	
		drawdebug(v,p)
	end
end)

addHook("HUD", function(v)
	if TAKIS_TITLEFUNNY
		v.fadeScreen(35,10)
		
		TAKIS_TITLEFUNNYY = $*3/4
		
		local scale = FU*7/5
		local p = v.cachePatch("BALL_BUSTER")
		
		local x = v.RandomFixed()*3
		if ((TAKIS_TITLETIME%4) < 3)
			x = -$
		end
		
		v.drawScaled(((300/2)*FU)+x,TAKIS_TITLEFUNNYY,scale,p,0)	
	end
end,"title")

filesdone = $+1
