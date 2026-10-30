-- PBZAutoCombat: automatic perfect parry + perfect dodge for Phantom Blade Zero (single player).
-- An accessibility mod, made with players with motor disabilities in mind. MIT License.
--
-- How it works (all game-side calls are the game's own):
--   * Attackers announce every hit to the defender's DeflectComponent as a "receive frame" with the exact
--     HitGameTime and an IsDodge flag (attacks that must be dodged: red-eye, grabs, ...).
--   * Once per game frame we read the player's received frames and pick the nearest deflect frame and the
--     nearest dodge frame (the same data the game's built-in assist uses).
--   * Parry: emulates the deflect key exactly like the input handler of BP_PlayerDeflectPassive
--     (Stance Key Down, Give Perfect Window, Activate Stance Ability) a fraction of the perfect window before
--     the hit, then releases the key after the hit. The quick-click punishment is reset first, so chained
--     hits each get the full window.
--   * Dodge: activates Ability.Action.Hun.PerfectDodge through the ability input component right before the
--     hit, like the built-in auto dodge (BP_PerfectDodgePassive "Try Auto Dodge", lead 0.04 s).
--   * Smart choice: dodge frames are dodged, deflect frames are parried; if both land together, dodge wins;
--     during Break (stance forbidden) nothing is pressed.
--
-- Keys: F7 = parry on/off, F8 = dodge on/off, F9 = mode smart/parry-only/dodge-only.
-- Settings are remembered in settings.txt next to this mod; set `log = true` below for autocombat.log.

local CFG = {
    parry = true,
    dodge = true,
    mode = "smart",              -- "smart" | "parry" | "dodge"
    parryLeadFraction = 0.45,    -- press this fraction of the perfect window before the hit
    parryMinLead = 0.05,         -- seconds; never later than this (one frame at 20 fps)
    parryMaxLead = 0.15,
    dodgeLead = 0.045,           -- built-in assist triggers at <= 0.04 s
    releaseAfterHit = 0.10,      -- keep the key "held" this long after the last parried hit
    holdGap = 0.35,              -- don't release if the next hit lands sooner than this (flurries): keep blocking
    maxHold = 2.5,               -- but never hold longer than this in one go (stance drains while held)
    ghostWithin = 0.4,           -- a deflect frame withdrawn this close to its hit is still parried on time
    bothWithin = 0.10,           -- deflect and dodge frames this close count as one attack
    lookahead = 1.5,             -- seconds of MaxPreimpactTime to query
    resetSpamPenalty = true,
    projectiles = true,          -- predict arrival of enemy projectiles (rocks, arrows, bullets)
    projectileRadius = 180,      -- uu; a projectile passing closer than this counts as a hit
    unannouncedRange = 6000,     -- uu; enemies further than this cannot land an unannounced attack (riders shoot from 30 m)
    wideProjectileRadius = 380,  -- uu; for wide projectiles (waves, slashes) whose centre passes further away
    log = false,                 -- true = write autocombat.log next to this mod (for bug reports)
}

-- Folder of this mod (…/ue4ss/Mods/PBZAutoCombat/), so nothing depends on where the game is installed.
local MOD_DIR = (function()
    -- Called directly (not through pcall, which would report pcall itself as level 1).
    local info = debug and debug.getinfo and debug.getinfo(1, "S")
    local src = info and info.source or ""
    local dir = src:gsub("^@", ""):gsub("\\", "/"):match("^(.*/)Scripts/[^/]*$")
    return dir or "Mods/PBZAutoCombat/" -- UE4SS runs with the ue4ss folder as working directory
end)()

local LOG_PATH = MOD_DIR .. "autocombat.log"
local DODGE_TAG = "Ability.Action.Hun.PerfectDodge"
local DASH_TAG = "Ability.Action.Hun.Dash" -- perfect dodge is refused without a dodge frame; the plain dash is not

-- Reloading the mod (UE4SS hot reload) stops the previous instance.
if _G.PBZAutoCombat then _G.PBZAutoCombat.stopped = true end
local S = { stopped = false, done = {}, seen = {}, checks = {}, proj = {}, unannounced = {}, ghosts = {}, releaseAt = 0, refreshAt = 0, cfg = CFG }
_G.PBZAutoCombat = S

local logFile = CFG.log and io.open(LOG_PATH, "a") or nil
local function log(...)
    if not logFile then return end
    local parts = {}
    for i = 1, select("#", ...) do parts[#parts + 1] = tostring(select(i, ...)) end
    logFile:write(os.date("%H:%M:%S "), table.concat(parts, "\t"), "\n")
    logFile:flush()
end

local GS = StaticFindObject("/Script/Engine.Default__GameplayStatics")
local IA_Dodge = StaticFindObject("/PBZDeflectSystem/Input/IA_Dodge.IA_Dodge")

local function valid(o) return o ~= nil and o:IsValid() end

-- First live (non-template) instance of a class, optionally owned by `outer`.
local function findLive(className, outer)
    for _, o in ipairs(FindAllOf(className) or {}) do
        if valid(o) and not o:GetFName():ToString():find("^Default__") then
            if not outer then return o end
            local ok, ow = pcall(function() return o:GetOuter() end)
            if ok and valid(ow) and ow:GetAddress() == outer:GetAddress() then return o end
        end
    end
    return nil
end

-- ---------------------------------------------------------------------------------------------
-- Persistent on/off state (survives restarts; can also be edited from outside the game).
local STATE_PATH = MOD_DIR .. "settings.txt"
local MODES = { smart = true, parry = true, dodge = true }

local function stateString()
    return string.format("parry=%d\ndodge=%d\nmode=%s\n", CFG.parry and 1 or 0, CFG.dodge and 1 or 0, CFG.mode)
end

local function saveState()
    local f = io.open(STATE_PATH, "w")
    if f then f:write(stateString()) f:close() end
    S.stateText = stateString()
end

-- Returns true when the file changed the settings.
local function loadState()
    local f = io.open(STATE_PATH, "r")
    if not f then return false end
    local text = f:read("a")
    f:close()
    if text == S.stateText then return false end
    S.stateText = text
    local p, d, m = text:match("parry=(%d)"), text:match("dodge=(%d)"), text:match("mode=(%a+)")
    if p then CFG.parry = p == "1" end
    if d then CFG.dodge = d == "1" end
    if m and MODES[m] then CFG.mode = m end
    return true
end

-- ---------------------------------------------------------------------------------------------
-- On-screen status, through the game's own text tip (port of UIHelper.showTipsText).
local TIP_TAG = { TagName = FName("UI.ExtensionPoint.TextTips") }
local TIP_CLASS = "/Game/PBZContent/UI/FrontEnd/WB_TextTipsObj.WB_TextTipsObj_C"
local MODE_NAMES = { smart = "SMART (parry + dodge)", parry = "PARRY ONLY", dodge = "DODGE ONLY" }

local function statusText()
    return string.format("Auto Parry: %s  |  Auto Dodge: %s  |  Mode: %s",
        CFG.parry and "ON" or "OFF", CFG.dodge and "ON" or "OFF", MODE_NAMES[CFG.mode] or CFG.mode)
end

local function hideTip()
    pcall(function()
        local ext = findLive("UIExtensionSubsystem")
        if valid(ext) then ext:UnregisterExtensionByTag(TIP_TAG) end
    end)
    S.tipHideAt = nil
end

local function showTip(text, now)
    local ok, err = pcall(function()
        local ext = findLive("UIExtensionSubsystem")
        local cls = StaticFindObject(TIP_CLASS)
        if not (valid(ext) and valid(cls)) then return end
        ext:UnregisterExtensionByTag(TIP_TAG)
        local obj = StaticConstructObject(cls, ext)
        obj.ShowText = FText(text)
        ext:K2_RegisterExtensionAsData(TIP_TAG, obj, 0)
    end)
    if not ok then log("TIP error", err) end
    S.tipHideAt = (now or 0) + 3.0
end

-- The pawn the player actually controls. Some chapters keep several Hun pawns in the level at once
-- (BP_Renewal_Hun_C, BP_Renewal_Hun_Young_C, BP_Renewal_Hun_Climax_C), so "the first instance of the class"
-- can be an idle one that never receives any attack.
local function possessedPawn()
    for _, pc in ipairs(FindAllOf("PlayerController") or {}) do
        if valid(pc) and not pc:GetFName():ToString():find("^Default__") then
            local ok, p = pcall(function() return pc.Pawn end)
            if ok and valid(p) then return p end
        end
    end
    return findLive("BP_Renewal_Hun_C")
end

local function refresh(now)
    S.pawn = possessedPawn()
    S.deflect, S.dc, S.input, S.window, S.windowBreak = nil, nil, nil, nil, nil
    S.refreshAt = now + 1.0 -- also when this pawn has no combat components (cutscene actors)
    if not valid(S.pawn) then return end
    S.deflect = findLive("BP_PlayerDeflectPassive_C", S.pawn)
    S.dc = findLive("DeflectComponent", S.pawn)
    S.input = findLive("AbilityInputComponent", S.pawn)
    S.attr = findLive("BasicAttributeSet", S.pawn)
    if not valid(S.deflect) then return end
    pcall(function()
        local cfg = S.deflect["Global Config"]
        local rate = cfg["Get Deflect Frame Rate"](cfg)
        S.window = cfg["Get Deflect Perfect Window Frames"](cfg) / rate
        S.windowBreak = cfg["Get Deflect Perfect Window Frames On Break"](cfg) / rate
    end)
end

local function parryLead(inBreak)
    local w = (inBreak and S.windowBreak or S.window) or (8 / 30)
    local lead = w * CFG.parryLeadFraction
    if lead < CFG.parryMinLead then lead = CFG.parryMinLead end
    if lead > CFG.parryMaxLead then lead = CFG.parryMaxLead end
    return lead
end

local function stanceForbidden()
    local ok, r = pcall(function() return S.deflect["Break Forbid Stance"](S.deflect, {}) end)
    -- UE4SS returns the BP return value; treat errors as "not forbidden".
    return ok and r == true
end

function playerHealth()
    local ok, v = pcall(function() return S.attr.Health.CurrentValue end)
    return ok and v or nil
end

local function expectHit(kind, hit, handle)
    S.checks[#S.checks + 1] = { kind = kind, at = hit + 0.25, hp = playerHealth(), handle = handle }
end

local function doParry(now, hit, handle)
    expectHit("PARRY", hit, handle)
    local d = S.deflect
    if CFG.resetSpamPenalty then pcall(function() d["Reset Perfect Window Punishment"](d) end) end
    if S.releaseAt == 0 then S.heldSince = now end
    d["Stance Key Down"] = true
    local ok1, e1 = pcall(function() d["Give Perfect Window"](d) end)
    local ok2, e2 = pcall(function() d["Activate Stance Ability"](d, {}) end)
    local release = hit + CFG.releaseAfterHit
    if release > S.releaseAt then S.releaseAt = release end
    log("PARRY", string.format("h=%d lead=%.3f", handle, hit - now), ok1 and "" or e1, ok2 and "" or e2)
end

local function releaseKey()
    local d = S.deflect
    pcall(function() d["On Stance Key Release"](d) end)
    S.releaseAt = 0
    S.holdLogged = false
end

-- Releasing between closely spaced hits and pressing again lets one of them through, so during a flurry
-- the key stays down (the stance blocks) and each hit still gets its own fresh perfect window.
local function maybeRelease(now)
    if S.releaseAt == 0 or now < S.releaseAt then return end
    local gap = (S.nextThreat or math.huge) - now
    if gap <= CFG.holdGap and now - (S.heldSince or now) < CFG.maxHold then
        S.releaseAt = now + 0.05
        if not S.holdLogged then
            S.holdLogged = true
            log("HOLD", string.format("next hit in %.3fs", gap))
        end
        return
    end
    releaseKey()
end

local function doDodge(now, hit, handle)
    expectHit("DODGE", hit, handle)
    local ok, r = pcall(function()
        return S.input:TryActivateExternalActionAbilityInterruptLowerByTag({ TagName = FName(DODGE_TAG) }, IA_Dodge, -5)
    end)
    local dashed = nil
    if ok and r == false then
        pcall(function()
            dashed = S.input:TryActivateExternalActionAbilityInterruptLowerByTag({ TagName = FName(DASH_TAG) }, IA_Dodge, -5)
        end)
    end
    log("DODGE", string.format("h=%d lead=%.3f", handle, hit - now), ok and tostring(r) or r, dashed ~= nil and "dash=" .. tostring(dashed) or "")
end

-- Diagnostics for unannounced hits: which animation montages the characters near the player are playing.
function attackerMontages()
    local out = {}
    local ok = pcall(function()
        local me = S.pawn:K2_GetActorLocation()
        local pawnAddr = S.pawn:GetAddress()
        for _, c in ipairs(FindAllOf("Character") or {}) do
            if valid(c) and c:GetAddress() ~= pawnAddr and not c:GetFName():ToString():find("^Default__") then
                local p = c:K2_GetActorLocation()
                local d = math.sqrt((p.X - me.X) ^ 2 + (p.Y - me.Y) ^ 2 + (p.Z - me.Z) ^ 2)
                if d < 3000 then
                    local m = nil
                    pcall(function() m = c.Mesh:GetAnimInstance():GetCurrentActiveMontage() end)
                    out[#out + 1] = string.format("%s@%.0f:%s", c:GetClass():GetFName():ToString(), d,
                        valid(m) and m:GetFName():ToString() or "-")
                end
            end
        end
    end)
    return ok and table.concat(out, " ") or "?"
end

-- Native roots, so every weapon is covered without listing it (FindAllOf includes subclasses). This list of all
-- 838 enemy ranged attacks in the game files covers bullets (rifles, arrows, rocks, darts, waves),
-- emitters (thrown bombs, grenades, cannon shells) and particle bullets.
local PROJECTILE_CLASSES = { "PBZ_ProjectileBullet", "PBZ_ProjectileEmitter", "PBZ_ParticleBullet" }

-- Time and distance of the closest approach to the player. r = player - projectile, az = measured vertical
-- acceleration: arcing projectiles (GravityScale > 0) would otherwise look like they fly over the player.
local function closestApproach(rx, ry, rz, vx, vy, vz, az)
    if az > -100 then
        local v2 = vx * vx + vy * vy + vz * vz
        local tca = (rx * vx + ry * vy + rz * vz) / v2
        local mx, my, mz = rx - vx * tca, ry - vy * tca, rz - vz * tca
        return tca, math.sqrt(mx * mx + my * my + mz * mz)
    end
    local bestT, best = 0, math.huge
    for i = 0, 200 do
        local t = i * 0.01
        local mx, my, mz = rx - vx * t, ry - vy * t, rz - vz * t - 0.5 * az * t * t
        local d = mx * mx + my * my + mz * mz
        if d < best then bestT, best = t, d end
    end
    return bestT, math.sqrt(best)
end

function trackProjectiles(now, dt, wantParry, wantDodge)
    local me = S.pawn:K2_GetActorLocation()
    local pawnAddr = S.pawn:GetAddress()
    local alive = {}
    for _, cls in ipairs(PROJECTILE_CLASSES) do
        for _, o in ipairs(FindAllOf(cls) or {}) do
            if valid(o) and not o:GetFName():ToString():find("^Default__") then
                local addr = o:GetAddress()
                alive[addr] = true
                local st = S.proj[addr]
                local p = o:K2_GetActorLocation()
                local step = st and now - st.t or 0
                local jumpLimit = st and math.max(800, 45000 * step) or 0
                local dist2 = st and (p.X - st.x) ^ 2 + (p.Y - st.y) ^ 2 + (p.Z - st.z) ^ 2 or 0
                local fresh = not st or dist2 > jumpLimit * jumpLimit
                if fresh then
                    -- New projectile, or a pooled one re-fired (teleported): start tracking afresh.
                    local owner = nil
                    pcall(function() owner = o:GetOwner() end)
                    local mine = valid(owner) and owner:GetAddress() == pawnAddr
                    local name = o:GetFName():ToString()
                    local wide = name:find("Wave") or name:find("Slash") or name:find("Blade")
                    st = { mine = mine, done = mine, radius = wide and CFG.wideProjectileRadius or CFG.projectileRadius }
                    S.proj[addr] = st
                end
                if not st.done or now < (st.hit or 0) then
                    -- The actor's own velocity is there on the first frame: the fastest rifle bullets arrive in a
                    -- frame or two, before a position difference exists. Otherwise measure it from the movement.
                    local vx, vy, vz = 0, 0, 0
                    local ok, v = pcall(function() return o:GetVelocity() end)
                    if ok and v then vx, vy, vz = v.X, v.Y, v.Z end
                    if vx * vx + vy * vy + vz * vz <= 100 and not fresh and step > 0 then
                        vx, vy, vz = (p.X - st.x) / step, (p.Y - st.y) / step, (p.Z - st.z) / step
                    end
                    local v2 = vx * vx + vy * vy + vz * vz
                    if v2 > 100 and (fresh or dist2 > 0) then -- moving; a stale velocity on a parked projectile does not count
                        local measured = st.vz ~= nil and step > 0 -- az needs two velocity samples
                        local az = measured and math.max(-4000, math.min(0, (vz - st.vz) / step)) or 0
                        st.vz = vz
                        local rx, ry, rz = me.X - p.X, me.Y - p.Y, me.Z - p.Z
                        local tca, miss = closestApproach(rx, ry, rz, vx, vy, vz, az)
                        if not st.seen and not st.mine and tca > 0 then
                            st.seen = true
                            log("SHOT", string.format("%s t=%.3f speed=%.0f eta=%.3f miss=%.0f", o:GetFName():ToString(), now, math.sqrt(v2), tca, miss))
                        end
                        if tca > 0 and miss <= st.radius then
                            if not st.logged then
                                st.logged = true
                                log("PROJ", string.format("%s speed=%.0f eta=%.3f miss=%.0f", o:GetFName():ToString(), math.sqrt(v2), tca, miss))
                            end
                            st.hit = now + tca
                            if now + tca < S.nextThreat then S.nextThreat = now + tca end
                            if not st.done and tca - dt <= parryLead(false) then
                                st.done = true
                                local hit = now + tca
                                -- Bombs burst on contact, so a parry still takes the explosion: leave the spot instead.
                                if cls == "PBZ_ProjectileEmitter" and wantDodge then doDodge(now, hit, -1)
                                elseif wantParry and not stanceForbidden() then doParry(now, hit, -1)
                                elseif wantDodge then doDodge(now, hit, -1) end
                            end
                        end
                    end
                end
                st.x, st.y, st.z, st.t = p.X, p.Y, p.Z, now
            end
        end
    end
    for addr in pairs(S.proj) do
        if not alive[addr] then S.proj[addr] = nil end
    end
end

-- Attacks the game does not announce in ReceiveFrames: montage name -> hit times in seconds from the montage start,
-- read from the ability timeline (ZuoShang_MiddleAttack_03_Montage is GA_ZuoShang_SpecialAttack_07).
local UNANNOUNCED_HITS = {
    ZuoShang_MiddleAttack_03_Montage = { 0.685, 0.936 },
}

-- QTEs with a fixed key: montage -> window in seconds from the montage start, and the key the game waits for.
-- The other QTEs in the game draw a random key, which the game does not expose to us.
local TIMED_QTE = {
    GuiChai_Horse_Gun_Skill_01_Montage = { from = 0.777, to = 1.296, action = "/PBZDeflectSystem/Input/IA_Deflect.IA_Deflect" },
    GuiChai_Horse_Gun_Skill_03_Montage = { from = 0.865, to = 1.392, action = "/PBZDeflectSystem/Input/IA_Dodge.IA_Dodge" },
}

-- Holds the key for the middle of the window, one injected frame at a time.
local function pressQte(name, qte, pos, now)
    if pos < qte.from + 0.1 or pos > qte.to - 0.1 then return end
    local ok, err = pcall(function()
        if not valid(S.enhanced) then S.enhanced = findLive("EnhancedInputLocalPlayerSubsystem") end
        S.enhanced:InjectInputVectorForAction(StaticFindObject(qte.action), { X = 1.0, Y = 0.0, Z = 0.0 }, {}, {})
    end)
    if now >= (qte.logAt or 0) or not ok then
        qte.logAt = now + 1
        log("QTE", name, string.format("pos=%.3f", pos), ok and "" or tostring(err))
    end
end

local function refreshNearEnemies(now)
    S.near = {}
    S.nearAt = now + 0.25
    local me = S.pawn:K2_GetActorLocation()
    for _, c in ipairs(FindAllOf("Character") or {}) do
        if valid(c) and c:GetClass():GetFName():ToString():find("^BP_Monster_") then
            local p = c:K2_GetActorLocation()
            if (p.X - me.X) ^ 2 + (p.Y - me.Y) ^ 2 + (p.Z - me.Z) ^ 2 < CFG.unannouncedRange ^ 2 then
                S.near[#S.near + 1] = c
            end
        end
    end
end

local function trackUnannounced(now, dt, wantDodge)
    if now >= (S.nearAt or 0) then refreshNearEnemies(now) end
    for _, c in ipairs(S.near) do
        if valid(c) then
            local anim, m = nil, nil
            pcall(function()
                anim = c.Mesh:GetAnimInstance()
                m = anim:GetCurrentActiveMontage()
            end)
            local name = valid(m) and m:GetFName():ToString() or nil
            local hits = name and UNANNOUNCED_HITS[name]
            local qte = name and TIMED_QTE[name]
            if qte then pressQte(name, qte, anim:Montage_GetPosition(m), now) end
            local addr = c:GetAddress()
            if hits then
                local pos = anim:Montage_GetPosition(m)
                local st = S.unannounced[addr]
                if not st or pos < st.pos then st = { next = 1 } S.unannounced[addr] = st end
                st.pos = pos
                while hits[st.next] and pos > hits[st.next] + 0.05 do st.next = st.next + 1 end -- seen too late
                local hit = hits[st.next]
                if hit and wantDodge and pos + dt + CFG.dodgeLead >= hit then
                    st.next = st.next + 1
                    log("UNANNOUNCED", name, string.format("pos=%.3f hit=%.3f", pos, hit))
                    doDodge(now, now + math.max(0, hit - pos), -2)
                end
            else
                S.unannounced[addr] = nil
            end
        end
    end
end

local trackErrors = 0
local function guarded(fn, ...)
    local ok, err = pcall(fn, ...)
    if not ok then
        trackErrors = trackErrors + 1
        if trackErrors <= 20 then log("ERROR", err) end
    end
end

-- Game time restarts with every level load (death, checkpoint): everything scheduled on the old clock is void.
local function resetForNewWorld()
    log("WORLD time restarted")
    S.done, S.seen, S.checks, S.proj, S.unannounced, S.ghosts, S.near = {}, {}, {}, {}, {}, {}, {}
    S.releaseAt, S.refreshAt, S.nearAt, S.lastHp, S.lastNow, S.tipHideAt = 0, 0, 0, nil, nil, nil
end

local function tick()
    local clock = os.clock()
    if not (valid(S.pawn) and valid(S.deflect) and valid(S.dc)) then
        if clock < (S.retryAt or 0) then return end
        S.retryAt = clock + 1.0
        refresh(0)
        if not valid(S.pawn) then return end
    end
    local now = GS:GetTimeSeconds(S.pawn)
    if S.lastNow and now < S.lastNow - 0.5 then resetForNewWorld() end
    if now >= S.refreshAt then refresh(now) end

    -- Settings file (external edits) once per second; on-screen status on world entry and on changes.
    if clock >= (S.stateCheckAt or 0) then
        S.stateCheckAt = clock + 1.0
        if loadState() then
            log("STATUS (file)", stateString():gsub("\n", " "))
            S.showPending = true
        end
    end
    local pawnAddr = S.pawn:GetAddress()
    if S.announcedPawn ~= pawnAddr then
        S.announcedPawn = pawnAddr
        S.showPending = true
    end
    if S.showPending then
        S.showPending = false
        showTip(statusText(), now)
    elseif S.tipHideAt and now >= S.tipHideAt then
        hideTip()
    end
    if not (valid(S.dc) and valid(S.deflect)) then return end

    -- Every HP loss, once (RESULT checks overlap during flurries, so one hit can show up in several of them).
    local hpNow = playerHealth()
    if logFile and hpNow and S.lastHp and hpNow < S.lastHp - 0.5 then
        log("DAMAGE", string.format("-%.1f HP", S.lastHp - hpNow), S.releaseAt > 0 and "key held" or "key up", attackerMontages())
    end
    S.lastHp = hpNow

    local wantParry = CFG.parry and CFG.mode ~= "dodge"
    local wantDodge = CFG.dodge and CFG.mode ~= "parry"

    -- Read the received-frame map directly. Only plain fields (time/flags) are touched: calling
    -- GetNearestValidReceivedFrame from Lua crashes UE4SS when it returns no frame (uninitialised pointers
    -- in the out struct).
    -- Act one frame early rather than one frame late: compare against the time left after the next frame.
    local dt = now - (S.lastNow or now)
    if dt < 0 then dt = 0 elseif dt > 0.1 then dt = 0.1 end
    S.lastNow = now

    local fp, fd = { HitGameTime = math.huge }, { HitGameTime = math.huge }
    local hp, hd = -1, -1
    local present = {}
    local nextFuture = math.huge
    S.dc.ReceiveFrames:ForEach(function(key, value)
        local handle = key:get()
        local frame = value:get()
        local hit = frame.HitGameTime
        present[handle] = true
        local isHit = frame.IsHit
        local info = S.seen[handle]
        if not info then
            info = { dodge = frame.IsDodge, hit = hit, isHit = isHit }
            S.seen[handle] = info
            log("FRAME", string.format("h=%d dodge=%s isHit=%s %s", handle, tostring(frame.IsDodge), tostring(isHit),
                hit < -1e30 and "untimed" or string.format("announced %.3fs before hit", hit - now)))
        elseif info.hit ~= hit or info.isHit ~= isHit then
            log("CHANGE", string.format("h=%d isHit=%s %s", handle, tostring(isHit),
                hit < -1e30 and "untimed" or string.format("%.3fs before hit", hit - now)))
            info.hit, info.isHit = hit, isHit
        end
        if hit < -1e30 then
            -- Untimed frame (continuous attacks, some projectiles): the game's own assist reacts when IsHit
            -- turns true, so do the same, immediately.
            if frame.IsHit and not S.done[handle] then
                S.done[handle] = true
                if frame.IsDodge and wantDodge then doDodge(now, now, handle)
                elseif wantParry and not stanceForbidden() then doParry(now, now, handle)
                elseif wantDodge then doDodge(now, now, handle) end
            end
            return
        end
        -- IsHit is not "already hit": timed frames are acted on by time regardless of it.
        if hit < now - 0.2 or hit > now + CFG.lookahead then return end
        if frame.IsDodge then
            if hit < fd.HitGameTime then hd, fd.HitGameTime = handle, hit end
        else
            if hit < fp.HitGameTime then hp, fp.HitGameTime = handle, hit end
            if hit > now and hit < nextFuture then nextFuture = hit end
        end
    end)

    -- Frames that vanished before we acted (attack cancelled, or our timing missed them).
    for handle, info in pairs(S.seen) do
        if not present[handle] then
            if not S.done[handle] and info.hit > -1e30 then
                log("LOST", string.format("h=%d dodge=%s %.3fs before hit", handle, tostring(info.dodge), info.hit - now))
                -- In flurries the game sometimes withdraws a frame shortly before its hit and re-announces it
                -- only after the hit has landed. Keep parrying it at the time it was announced for.
                local left = info.hit - now
                if not info.dodge and left > 0 and left < CFG.ghostWithin then
                    S.ghosts[#S.ghosts + 1] = { hit = info.hit, handle = handle }
                end
            end
            S.seen[handle] = nil
            S.done[handle] = nil
        end
    end

    -- Projectiles: their deflect frame is untimed and vanishes at launch; the game resolves the deflect when
    -- the projectile touches the player (open window = deflected). Predict the arrival ourselves.
    S.nextThreat = nextFuture
    for i = #S.ghosts, 1, -1 do
        local g = S.ghosts[i]
        local t = g.hit - now
        if t < 0 then
            table.remove(S.ghosts, i)
        else
            if g.hit < S.nextThreat then S.nextThreat = g.hit end
            if t - dt <= parryLead(false) then
                table.remove(S.ghosts, i)
                if wantParry and not stanceForbidden() then
                    log("GHOST", "h=" .. g.handle)
                    doParry(now, g.hit, g.handle)
                end
            end
        end
    end
    -- An error in the tracking must not skip the key release below: the stance would stay up.
    if CFG.projectiles and (wantParry or wantDodge) then guarded(trackProjectiles, now, dt, wantParry, wantDodge) end
    if wantParry or wantDodge then guarded(trackUnannounced, now, dt, wantDodge) end
    maybeRelease(now)

    -- Outcome of our actions: did the player lose HP around the hit?
    for i = #S.checks, 1, -1 do
        local c = S.checks[i]
        if now >= c.at then
            local hpNow = playerHealth()
            if hpNow and c.hp then
                local lost = c.hp - hpNow
                log("RESULT", c.kind, "h=" .. c.handle, lost > 0.5 and string.format("HIT -%.1f HP", lost) or "OK (no HP lost)")
            end
            table.remove(S.checks, i)
        end
    end

    -- Dodge frames: attacks the game marks as "must dodge".
    if hd >= 0 and not S.done[hd] then
        local t = fd.HitGameTime - now
        if t < -0.1 then
            S.done[hd] = true
        elseif t - dt <= CFG.dodgeLead then
            S.done[hd] = true
            local handled = wantDodge or (wantParry and CFG.mode == "parry")
            if wantDodge then doDodge(now, fd.HitGameTime, hd)
            elseif handled then doParry(now, fd.HitGameTime, hd) end
            -- the matching deflect frame of the same attack is skipped, unless nothing was pressed for it
            if handled and hp >= 0 and math.abs(fp.HitGameTime - fd.HitGameTime) <= CFG.bothWithin then S.done[hp] = true end
        end
    end

    -- Deflect frames.
    if hp >= 0 and not S.done[hp] then
        local t = fp.HitGameTime - now
        local bothSoon = hd >= 0 and math.abs(fd.HitGameTime - fp.HitGameTime) <= CFG.bothWithin
        if t < -0.1 then
            S.done[hp] = true
        elseif bothSoon and wantDodge and CFG.mode ~= "parry" then
            -- leave it to the dodge branch
        elseif t - dt <= parryLead(false) then
            S.done[hp] = true
            if wantParry then
                if stanceForbidden() then
                    log("SKIP break", hp)
                else
                    doParry(now, fp.HitGameTime, hp)
                end
            elseif wantDodge then
                doDodge(now, fp.HitGameTime, hp)
            end
        end
    end
end

-- Runs on the game thread once per frame. (LoopAsync + ExecuteInGameThread lost callbacks and crashed UE4SS.)
local errors = 0
LoopInGameThreadAfterFrames(1, function()
    if S.stopped then return true end
    local ok, err = pcall(tick)
    if not ok then
        errors = errors + 1
        if errors <= 20 then log("ERROR", err) end
    end
    return false
end)

-- Key callbacks only change settings; the game-thread loop shows the tip.
local function status()
    saveState()
    S.showPending = true
    log("STATUS parry=" .. tostring(CFG.parry) .. " dodge=" .. tostring(CFG.dodge) .. " mode=" .. CFG.mode)
end
pcall(function()
    RegisterKeyBind(Key.F7, function() CFG.parry = not CFG.parry status() end)
    RegisterKeyBind(Key.F8, function() CFG.dodge = not CFG.dodge status() end)
    RegisterKeyBind(Key.F9, function()
        CFG.mode = (CFG.mode == "smart" and "parry") or (CFG.mode == "parry" and "dodge") or "smart"
        status()
    end)
end)

log("PBZAutoCombat loaded")
if not loadState() then saveState() end
log("STATUS parry=" .. tostring(CFG.parry) .. " dodge=" .. tostring(CFG.dodge) .. " mode=" .. CFG.mode)
print("[PBZAutoCombat] loaded\n")
return "PBZAutoCombat loaded"
