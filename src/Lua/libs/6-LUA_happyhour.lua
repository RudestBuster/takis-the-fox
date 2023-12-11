--happy hour stuff
local function L_ZCollide(mo1,mo2)
	if mo1.z > mo2.height+mo2.z then return false end
	if mo2.z > mo1.height+mo1.z then return false end
	return true
end

rawset(_G,"HAPPY_HOUR",{
	happyhour = false,
	timelimit = 0,
	timeleft = 0,
	time = 0,
	othergt = false,
	trigger = 0,
	exit = 0,
	overtime = false,
	gameover = false,
	
	song = "hapyhr",
	songend = "hpyhre",
	nosong = false,
	noendsong = false,
})

local hh = HAPPY_HOUR

rawset(_G,"HH_Trigger",function(actor,timelimit)
	if not hh.happyhour
	
		if timelimit == nil
			timelimit = 3*60*TR
		end
		hh.timelimit = timelimit
		hh.happyhour = true
		hh.time = 1
		hh.gameover = false
		
		for p in players.iterate
			if (hh.nosong == false)
				ChangeTakisMusic(hh.song,p)
			end
		end
		
		if not (actor and actor.valid) then return end
		
		local tag = actor.lastlook
		if (actor.type == MT_HHTRIGGER)
			tag = AngleFixed(actor.angle)/FU
			P_LinedefExecute(tag,actor,nil)
		end
		
		for mobj in mobjs.iterate()
			--if (mobj.type == MT_NIGHTSDRONE)
			if (mobj.type == MT_HHEXIT)
				hh.exit = mobj
				if (mobj.type == MT_HHEXIT)
					mobj.state = S_HHEXIT_OPEN
				end
			else
				continue
			end
		end
		
		hh.trigger = actor
	end
end)

rawset(_G,"HH_Reset",function()
	hh.happyhour = false
	hh.timelimit = 0
	hh.timeleft = 0
	hh.time = 0
	hh.trigger = 0
	hh.exit = 0
	hh.gameover = false
end)

addHook("ThinkFrame",do

	local nomus = string.lower(mapheaderinfo[gamemap].takis_hh_nomusic or '') == "true"
	local noendmus = string.lower(mapheaderinfo[gamemap].takis_hh_noendmusic or '') == "true"
	
	local song = mapheaderinfo[gamemap].takis_hh_music or "hapyhr"
	local songend = mapheaderinfo[gamemap].takis_hh_endmusic or "hpyhre"
	
	song,songend = string.lower($1),string.lower($2)
	
	hh.song = song
	hh.songend = songend
	hh.nosong = nomus
	hh.noendsong = noendmus
	
	hh.othergt = (gametype == GT_PTSPICER)
	if hh.othergt
		hh.happyhour = PTSR.pizzatime --and (PTSR.gameover == false)
		hh.timelimit = CV_PTSR.timelimit.value*TICRATE*60 or 0
		hh.timeleft = PTSR.timeleft
		hh.time = PTSR.pizzatime_tics
		hh.overtime = hh.timeleft <= 0 and hh.happyhour
	else
	
		if hh.happyhour
			
			if not hh.gameover
				if ((hh.timeleft ~= 0)
				and (hh.timelimit))
					hh.time = $+1
				end
			end
			if (hh.timelimit)
				hh.timeleft = hh.timelimit-hh.time
			end
			
			if (G_EnoughPlayersFinished())
			and not hh.gameover
				for p in players.iterate()
					if skins[p.skin].name == TAKIS_SKIN then continue end
					S_StopMusic(p)
				end
				hh.gameover = true
			end
			
			for p in players.iterate
				if not (p and p.valid) then continue end
				if not (p.mo and p.mo.valid) then continue end
				if (not p.mo.health) or (p.playerstate ~= PST_LIVE) then continue end
				
				local me = p.mo
				local takis = p.takistable
				
				--finish thinker
				if (p.exiting or p.pflags & PF_FINISHED)
				and (hh.exit and hh.exit.valid)
					P_DoPlayerExit(p)
					me.flags2 = $|MF2_DONTDRAW
					me.momx,me.momy,me.momz = 0,0,0
					P_SetOrigin(me,hh.exit.x,hh.exit.y,hh.exit.z)
					p.pflags = $|PF_FINISHED
					p.exiting = min(99,$)
					p.powers[pw_flashing] = 3
					p.powers[pw_shield] = 0
					if (takis.isTakis)
						takis.goingfast = false
						takis.wentfast = 0
					end
					
					continue
				end
				
				if not hh.gameover
					if not (hh.time % TR)
					and (hh.time)
						if (p.score > 5)
							p.score = $-5
						else
							p.score = 0
						end
					end
				end
				
			end
			
			if (hh.timelimit ~= nil or hh.timelimit ~= 0)
				if hh.timelimit < 0
					hh.timelimit = 3*60*TR
				end
				
				hh.timeleft = hh.timelimit-hh.time
				
				if hh.timeleft == 0
					if not hh.othergt
						for p in players.iterate
							if not (p and p.valid) then continue end
							if not (p.mo and p.mo.valid) then continue end
							if (p.exiting or p.pflags & PF_FINISHED) then continue end
							
							if not (p.happydeath)
								P_KillMobj(p.mo)
								p.happydeath = true
								--too bad! sucks to suck!
								if (p.score < 10000)
									p.score = 0
								else
									p.score = $-10000
								end
								p.exiting = 99
								--no time bonus
								p.rings = 0
								p.realtime = leveltime*99
							--DONT let them respawn....
							else
								if (multiplayer)
									p.deadtimer = min(3,$)
								end
								if (p.playerstate ~= PST_DEAD)
									p.happydeath = false
								end
							end
						end
					end
				end
			end
			
		end
	end
end)

----	trigger stuff
freeslot("SPR_HHT_")
freeslot("S_HHTRIGGER_IDLE")
freeslot("S_HHTRIGGER_PRESSED")
freeslot("S_HHTRIGGER_ACTIVE")
freeslot("MT_HHTRIGGER")
sfxinfo[freeslot("sfx_hhtsnd")] = {
	flags = SF_X2AWAYSOUND,
	caption = "/"
}

states[S_HHTRIGGER_IDLE] = {
	sprite = SPR_HHT_,
	frame = O,
	tics = -1
}
states[S_HHTRIGGER_PRESSED] = {
	sprite = SPR_HHT_,
	frame = A,
	tics = 5,
	nextstate = S_HHTRIGGER_ACTIVE
}
states[S_HHTRIGGER_ACTIVE] = {
	sprite = SPR_HHT_,
	frame = A,
	tics = -1,
}

mobjinfo[MT_HHTRIGGER] = {
	--$Name Happy Hour Trigger
	--$Sprite HHT_O0
	--$Category Takis Stuff
	doomednum = 3000,
	spawnstate = S_HHTRIGGER_IDLE,
	spawnhealth = 1,
	deathstate = S_HHTRIGGER_PRESSED,
	deathsound = sfx_mclang,
	height = 60*FRACUNIT,
	radius = 35*FRACUNIT, --FixedDiv(35*FU,2*FU),
	flags = MF_SOLID,
}

addHook("MobjSpawn",function(mo)
--	mo.height,mo.radius = $1*2,$2*2
	mo.shadowscale = mo.scale*9/10
	mo.spritexoffset = 19*FU
	mo.spriteyoffset = 26*FU
end,MT_HHTRIGGER)

addHook("MobjThinker",function(trig)
	if not trig
	or not trig.valid
		return
	end
	
	trig.spritexscaleadd = $ or 0
	trig.spriteyscaleadd = $ or 0
	
	if trig.state == S_HHTRIGGER_ACTIVE
		if not (hh.gameover)
			trig.frame = ((5*(HAPPY_HOUR.time)/6)%14)
			if not S_SoundPlaying(trig,sfx_hhtsnd)
				S_StartSound(trig,sfx_hhtsnd)
			end
		else
			trig.frame = A
			S_StopSound(trig)
		end
	end
	
	trig.spritexscale = 2*FU+trig.spritexscaleadd
	trig.spriteyscale = 2*FU+trig.spriteyscaleadd
	if trig.spritexscaleadd ~= 0
		trig.spritexscaleadd = 4*$/5
	end
	if trig.spriteyscaleadd ~= 0
		trig.spriteyscaleadd = 4*$/5
	end
	--trig.height = FixedMul(60*trig.scale,FixedDiv(trig.spriteyscale,2*FU))
end,MT_HHTRIGGER)

addHook("MobjCollide",function(trig,mo)
	if (HAPPY_HOUR.othergt) then return end
	
	if not mo
	or not mo.valid
		return
	end
	
	if (mo.type ~= MT_PLAYER) then return end
	
	if HAPPY_HOUR.happyhour
		if L_ZCollide(trig,mo)
			return true
		end
		return
	end
	
	if not trig.health
		if L_ZCollide(trig,mo)
			return true
		end
		return
	end
	
	
	if P_MobjFlip(trig) == 1
		local myz = trig.z+trig.height
		if not (mo.z <= myz+trig.scale and mo.z >= myz-trig.scale)
			if L_ZCollide(trig,mo)
				return true
			end
		return
		end
		if (mo.momz)
			return true
		end
		
		local tl = tonumber(mapheaderinfo[gamemap].takis_hh_timelimit or 0)*TR or 3*60*TR
		HH_Trigger(trig,tl)
		S_StartSound(trig,trig.info.deathsound)
		trig.state = trig.info.deathstate
		trig.spritexscaleadd = 2*FU
		trig.spriteyscaleadd = -FU*3/2
		P_AddPlayerScore(mo.player,5000)
		local takis = mo.player.takistable
		takis.bonuses["happyhour"].tics = 3*TR+18
		takis.bonuses["happyhour"].score = 5000
		takis.HUD.flyingscore.scorenum = $+5000
		return true
		
	end
	
end,MT_HHTRIGGER)
----

----	exit stuff
freeslot("SPR_HHE_")
freeslot("SPR_HHF_")
freeslot("S_HHEXIT")
states[S_HHEXIT] = {
	sprite = SPR_HHE_,
	frame = A,
	tics = -1
} 
freeslot("S_HHEXIT_OPEN")
states[S_HHEXIT_OPEN] = {
	sprite = SPR_HHE_,
	frame = B,
	tics = -1
} 
freeslot("S_HHEXIT_CLOSE1")
freeslot("S_HHEXIT_CLOSE2")
freeslot("S_HHEXIT_CLOSE3")
freeslot("S_HHEXIT_CLOSE4")
states[S_HHEXIT_CLOSE1] = {
	sprite = SPR_HHE_,
	frame = P|FF_ANIMATE,
	var1 = 3,
	var2 = 2,
	tics = 3*2,
	nextstate = S_HHEXIT_CLOSE2
} 
states[S_HHEXIT_CLOSE2] = {
	sprite = SPR_HHE_,
	frame = S,
	tics = 15,
	nextstate = S_HHEXIT_CLOSE3,
} 
states[S_HHEXIT_CLOSE3] = {
	sprite = SPR_HHF_,
	frame = B|FF_ANIMATE,
	var1 = 13,
	var2 = 1,
	tics = 13*6,
	nextstate = S_HHEXIT_CLOSE4
} 
states[S_HHEXIT_CLOSE4] = {
	sprite = SPR_HHF_,
	frame = A,
	tics = -1
} 
sfxinfo[freeslot("sfx_elebel")] = {
	flags = SF_X2AWAYSOUND,
	caption = "Elevator bell"
}

freeslot("MT_HHEXIT")
mobjinfo[MT_HHEXIT] = {
	--$Name Happy Hour Exit
	--$Sprite RINGA0
	--$Category Takis Stuff
	doomednum = 3001,
	spawnstate = S_HHEXIT,
	seestate = S_HHEXIT_OPEN,
	spawnhealth = 1,
	height = 115*FRACUNIT,
	radius = 25*FRACUNIT,
	flags = MF_SPECIAL,
}

addHook("MobjSpawn",function(mo)
	--mo.shadowscale = mo.scale*9/10
	local scale = FU*2
	mo.spritexscale,mo.spriteyscale = scale,scale
	mo.boltrate = 10
	hh.exit = mo
end,MT_HHEXIT)
addHook("TouchSpecial",function(door,mo)
	if not (mo and mo.valid) then return true end
	if not (door and door.valid) then return true end
	if not (hh.happyhour) then return true end
	if (hh.othergt) then return true end
	
	local p = mo.player
	
	if (p.exiting or p.pflags & PF_FINISHED) then return true end
	
	chatprint("\x82*\x83"..p.name.."\x82 reached the exit.")
	P_DoPlayerExit(p)
	mo.momx,mo.momy,mo.momz = 0,0,0
	P_SetOrigin(mo,door.x,door.y,door.z)
	mo.flags2 = $|MF2_DONTDRAW
	
	if (G_EnoughPlayersFinished())
		door.state = S_HHEXIT_CLOSE1
	end
	
	return true
end,MT_HHEXIT)
addHook("MobjThinker",function(door)
	if not (door and door.valid) then return end
	
	if door.state == S_HHEXIT_OPEN
		door.frame = 1+((hh.time)%14)
	elseif door.state == S_HHEXIT_CLOSE3
		if not (door.exittic)
			door.exittic = 1
		else
			if not (leveltime % 2)
				door.exittic = $+1
			end
		end
		local ay = FU+(door.exittic*FU/40)
		if P_RandomChance(FU/2)
			ay = FU/2+door.exittic*FU/20
		end
		
		door.spritexscale = FixedMul(2*FU,ay)
		door.spriteyscale = FixedDiv(2*FU,ay)
		
		if not (leveltime % 3)
			local rad = door.radius/FRACUNIT
			local hei = door.height/FRACUNIT
			local x = P_RandomRange(-rad,rad)*FRACUNIT
			local y = P_RandomRange(-rad,rad)*FRACUNIT
			local z = P_RandomRange(0,hei)*FRACUNIT
			local spark = P_SpawnMobjFromMobj(door,x,y,z,MT_SOAP_SUPERTAUNT_FLYINGBOLT)
			spark.tracer = door
			spark.state = P_RandomRange(S_SOAP_SUPERTAUNT_FLYINGBOLT1,S_SOAP_SUPERTAUNT_FLYINGBOLT5)			
			spark.blendmode = AST_ADD
			spark.color = P_RandomRange(SKINCOLOR_WHITE,SKINCOLOR_GREY)
			spark.angle = door.angle+(FixedAngle( (P_RandomRange(-337,337)*FU)+P_RandomFixed() ))
			spark.momz = P_RandomRange(0,4)*door.scale*P_MobjFlip(door)
			P_Thrust(spark,spark.angle,P_RandomRange(1,5)*door.scale)
			spark.scale = P_RandomRange(1,3)*FU+P_RandomFixed()
		end
	elseif door.state == S_HHEXIT_CLOSE4
		if (door.exittic ~= nil)
			S_StartSound(door,sfx_elebel)
			door.exittic = nil
		end
		door.spritexscale = 2*FU
		door.spriteyscale = 2*FU
	end

end,MT_HHEXIT)

----

filesdone = $+1
