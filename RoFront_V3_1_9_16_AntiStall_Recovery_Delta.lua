-- ROFRONT V3.1.9.16 VISIBLE DELTA SCRIPT. Copy the entire file, including the last END marker.
-- Single Luau chunk: no loadstring wrapper, HTTP, key or purchase call.
-- Local boot simulation passed; real Delta acceptance remains unverified.

-- RoFront Remake V3.1.9.16 ISLAND AND REPORT -- based on V3.1.9.8; not Delta-live-tested.
-- Standalone: no HTTP, key system or external code loader.
local function mountGui(root)
local parents={}
-- The user's short Delta probe rendered in PlayerGui. Mount there first;
-- gethui can accept a ScreenGui yet still be invisible on this device.
local ok,pg=pcall(function()
 local p=game:GetService("Players").LocalPlayer
 return p and p:FindFirstChildOfClass("PlayerGui")
end)
if ok and pg then parents[#parents+1]={pg,"PlayerGui"} end
if type(gethui)=="function" then
 local worked,p=pcall(gethui);if worked and p then parents[#parents+1]={p,"gethui"} end
end
local good,core=pcall(function() return game:GetService("CoreGui") end)
if good and core then parents[#parents+1]={core,"CoreGui"} end
local errors={}
for _,entry in ipairs(parents) do
 local mounted,err=pcall(function()
  local old=entry[1]:FindFirstChild(root.Name)
  if old and old~=root then old:Destroy() end
  root.Parent=entry[1]
  assert(root.Parent==entry[1],"parent assignment did not stick")
 end)
 if mounted then return entry[2],entry[1] end
 errors[#errors+1]=entry[2]..":"..tostring(err)
end
error("No usable GUI parent; "..table.concat(errors," | "))
end
local bootGui
local function bootNotice(message)
warn("[RoFront bootstrap] "..tostring(message))
if tostring(message):find("BOOT ERROR",1,true) and type(setclipboard)=="function" then
 pcall(setclipboard,"ROFRONT V3.1.9.16 "..tostring(message))
end
local ok=pcall(function()
local p=game:GetService("Players").LocalPlayer
if not p then error("LocalPlayer unavailable") end
if bootGui then bootGui:Destroy() end
bootGui=Instance.new("ScreenGui");bootGui.Name="RoFrontBoot31915";bootGui.ResetOnSpawn=false;bootGui.DisplayOrder=999999;bootGui.Enabled=true;mountGui(bootGui)
local b=Instance.new("TextButton");b.Size=UDim2.fromOffset(300,90);b.Position=UDim2.fromOffset(10,50)
b.TextWrapped=true;b.TextSize=13;b.Text="ROFRONT 3.1.9.16\n"..tostring(message).."\nTap to copy boot status"
b.Parent=bootGui
b.Activated:Connect(function() if type(setclipboard)=="function" then pcall(setclipboard,tostring(message)) end end)
end)
if not ok then warn("[RoFront bootstrap] Cannot display notice; inspect Delta console") end
end
print("[RoFront v3.1.9.16] BOOT entry")
bootNotice("chunk_started; preparing main UI")
local bootOK,bootError=xpcall(function()
print("[RoFront v3.1.9.16] Chunk started; preparing UI")
local EXPECTED_PLACE = 137151641329864
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
if not player then
error("LocalPlayer unavailable; execute after joining RoFront")
end
local sharedEnv = _G
if type(getgenv) == "function" then
local ok, result = pcall(getgenv)
if ok and type(result) == "table" then sharedEnv = result end
end
if type(sharedEnv.AirfrontRemakeV3Stop) == "function" then
pcall(sharedEnv.AirfrontRemakeV3Stop)
end
if type(sharedEnv.AirfrontRemakeV2Stop) == "function" then pcall(sharedEnv.AirfrontRemakeV2Stop) end
if type(sharedEnv.AirfrontRemakeV1Stop) == "function" then
pcall(sharedEnv.AirfrontRemakeV1Stop)
end
local alive, suspended = true, false
local R = {boot="core_started", epoch=0, tasks={}, actions={}, outcomes={},
subsystemFaults={}, plannerFallbacks=0,
block="none", traceback="none", lastMilitary=-9999, lastTick=nil,
map=nil, state=nil, owner=nil, phase=nil, source=nil, ownerBuf=nil,
discoveryBusy=false, moduleStatus="pending", uiCreated=false, maxCycleMs=0}
local function traceError(err)
return debug and debug.traceback and debug.traceback(tostring(err),2) or tostring(err)
end
function R.spawn(fn)
for i=#R.tasks,1,-1 do
if coroutine.status(R.tasks[i])=="dead" then table.remove(R.tasks,i) end
end
local thread=task.spawn(function()
local ok,err=xpcall(fn,traceError)
if not ok and alive then R.traceback=tostring(err);R.workerError=tostring(err); warn("[RoFront worker] "..tostring(err)) end
end)
R.tasks[#R.tasks+1]=thread
return thread
end
function R.blocked(reason) R.block=reason; return false end
function R.sent(kind,intent,st)
local own=st and st.owners and (st.owners[st.local_owner] or st.owners[tostring(st.local_owner)])
local row={kind=kind,structureKind=intent.kind,tile=intent.tile,ratio=intent.ratio,at=os.clock(),epoch=R.epoch,
status="SENT_UNCONFIRMED",troops=own and own.troops,gold=own and own.gold}
if st and intent.tile and typeof(st.owner)=="buffer" and buffer then
local width=buffer.len(st.owner)/(st.N or 1)
local read=width==1 and buffer.readu8 or width==2 and buffer.readu16 or width==4 and buffer.readu32
if read then local ok,v=pcall(read,st.owner,intent.tile*width);if ok then row.ownerBefore=v end end
end
R.actions[#R.actions+1]=row
if #R.actions>60 then table.remove(R.actions,1) end
R.outcomes[kind]="SENT_UNCONFIRMED"
end
function R.observed(kind,detail,st,expectedTile)
-- Match observations against the actual outstanding command, never another tile.
-- No server ACK is available; ownership/structure change remains unattributed.
for i=#R.actions,1,-1 do
 local a=R.actions[i]
 if a.kind==kind and a.epoch==R.epoch and a.status=="SENT_UNCONFIRMED" and
    (expectedTile==nil or a.tile==expectedTile) then
  a.status="OBSERVED_CHANGE_UNATTRIBUTED"
  a.detail=detail
  local own=st and st.owners and (st.owners[st.local_owner] or st.owners[tostring(st.local_owner)])
  a.troopsAfter=own and own.troops;a.goldAfter=own and own.gold
  a.ownerAfter=st and st.local_owner;a.elapsed=os.clock()-a.at
  R.outcomes[kind]="OBSERVED_CHANGE_UNATTRIBUTED"
  return true
 end
end
R.evidenceUnmatched=(R.evidenceUnmatched or 0)+1
return false
end
local enabled = {
autoJoin = true,
autoSpawn = true,
autoAttack = true,
autoBuild = true,
autoSam = true,
autoAlliance = true,
autoNuke = true, -- Only when an actual nuke payload round-trips the game codec.
autoBoat = true, -- User requested all implemented planners enabled; route checks remain active.
autoReinforce = true, -- Inert until user explicitly arms after earning the permanent unlock.
}
local attempted = { join=0, spawn=0, spawnSeen=0, attack=0, attackCaptured=0, attackUnconfirmed=0, build=0, buildConfirmed=0, buildDenied=0, ally=0, allyObserved=0, allyUnconfirmed=0, nuke=0, nukeObserved=0, nukeUnconfirmed=0, boat=0, boatCaptured=0, boatUnconfirmed=0, reinforce=0, reinforceObserved=0, reinforceUnconfirmed=0 }
local naval
local combat = {pending=nil, avoidUntil={}, lastTarget="none", lastRatio="not-chosen", lastDecision="none", borderThreat=0}
local baselineSample, latestSample = nil, nil
local lastAction = { join = -9999, spawn = -9999, attack = -9999, build = -9999, ally = -9999, nuke = -9999, boat = -9999, reinforce = -9999 }
R.reinforceUnlocked=false -- User must arm this after the Stars unlock; never infer ownership from a codec roundtrip.
local reinforceAudit={status="locked-user-not-armed",schema="type-only-read-only-probe",pending=nil,lastGold="none"}
local session, protocol, defs, sessionFrom = nil, nil, nil, "searching"
local getgcTries, nextScan, events, gui = 0, 0, {}, nil
local conn = {}
local lastInfo = "Loading Airfront modules..."
local lastError = "none"
local ownerReaderError = "none"
local validated = {}
local lastVerify = 0
local statsLabel, infoLabel, statusLabel, toggles, pauseButton, bubble, panel, expanded = nil, nil, nil, nil, nil, nil, nil, true
local hintText = "Land-target verification blocks water attacks. Client intents are not ACKs."
function R.timedOut(kind,expectedTile)
-- A timeout means the observation did not arrive; it does NOT prove rejection.
for i=#R.actions,1,-1 do
 local a=R.actions[i]
 if a.kind==kind and a.epoch==R.epoch and a.status=="SENT_UNCONFIRMED" and
    (expectedTile==nil or a.tile==expectedTile) then
  a.status="OBSERVATION_TIMEOUT_UNCONFIRMED"
  a.detail="observation-timeout; server-rejection-reason-unavailable"
  a.elapsed=os.clock()-a.at
  R.outcomes[kind]="OBSERVATION_TIMEOUT_UNCONFIRMED"
  return true
 end
end
R.evidenceUnmatched=(R.evidenceUnmatched or 0)+1
return false
end
local function now() return os.clock() end
local function str(v, maxLen)
local s = tostring(v):gsub("[%c]", " ")
return s:sub(1, maxLen or 100)
end
local function log(msg, isError)
msg = str(msg, 175)
lastInfo = msg
if isError then lastError = msg end
events[#events + 1] = os.date("%H:%M:%S") .. " " .. msg
if #events > 60 then table.remove(events, 1) end
print("[RoFront v3] " .. msg)
end
local function watch(connection)
conn[#conn + 1] = connection
return connection
end
local function stop()
if not alive then return end
alive = false
for _, thread in ipairs(R.tasks) do
if type(task.cancel)=="function" and thread~=coroutine.running() then pcall(task.cancel,thread) end
end
if bootGui then pcall(function() bootGui:Destroy() end) end
for _, c in ipairs(conn) do pcall(function() c:Disconnect() end) end
conn = {}
if gui then pcall(function() gui:Destroy() end) end
local pg=player:FindFirstChildOfClass("PlayerGui")
local errGui=pg and pg:FindFirstChild("RoFrontBootError")
if errGui then pcall(function() errGui:Destroy() end) end
if sharedEnv.AirfrontRemakeV3Stop == stop then
sharedEnv.AirfrontRemakeV3Stop = nil
end
end
sharedEnv.AirfrontRemakeV3Stop = stop
local function getChild(root, path)
local at = root
for _, name in ipairs(path) do
if not at then return nil end
at = at:FindFirstChild(name)
end
return at
end
local function requirePath(root, path)
local obj = getChild(root, path)
if not obj or not obj:IsA("ModuleScript") then return nil end
local ok, v = pcall(require, obj)
return ok and v or nil
end
local function loadModules()
local path = {"Airfront", "Net", "Protocol"}
protocol = requirePath(ReplicatedStorage, path)
defs = requirePath(ReplicatedStorage, {"Airfront", "Core", "Defs"})
if type(protocol) ~= "table" then log("Net.Protocol unavailable", true) end
end
local function recognize(v)
if type(v) ~= "table" then return nil end
if type(v.session) == "table" then v = v.session end
if type(v.send_intent) == "function" and type(v.state) == "table" and type(v.lobby) == "table" then
return v
end
return nil
end
local function findSession(forceGC)
if recognize(session) then return session end
return nil
end
function R.discover()
local ps=player:FindFirstChild("PlayerScripts")
if ps and not R.discoveryBusy then
 R.discoveryBusy=true
 R.spawn(function()
 local m=requirePath(ps,{"AirfrontClient","Main"})
 local found=recognize(m)
 if alive and found then session,sessionFrom=found,"PlayerScripts/Main" end
 R.discoveryBusy=false
 end)
end
if type(getgc)=="function" and getgcTries<12 and now()>=nextScan and not recognize(session) then
nextScan=now()+15;getgcTries=getgcTries+1
local ok,objects=pcall(getgc,true)
if ok and type(objects)=="table" then
for i,obj in ipairs(objects) do
local good,found=pcall(recognize,obj)
if good and found and alive then session,sessionFrom=found,"getgc(true)";break end
if i%1500==0 then task.wait();if not alive then return end end
end
end
end
end
local function probeIntent(kind,example)
-- Validate every actual payload; a cached kind cannot validate a new tile/ratio.
validated[kind]=false
if type(protocol)~="table" or type(protocol.encode_intent)~="function" or
 type(protocol.decode_intent)~="function" then return R.blocked("codec-unavailable:"..kind) end
local ok,encoded=pcall(protocol.encode_intent,example)
if not ok or encoded==nil then return R.blocked("encode-failed:"..kind) end
local good,decoded=pcall(protocol.decode_intent,encoded)
if not good or type(decoded)~="table" or decoded.type~=kind then return R.blocked("decode-type-mismatch:"..kind) end
for key,value in pairs(example) do
 local got=decoded[key]
 if type(got)~=type(value) or (type(value)=="number" and
 (got~=got or math.abs(got-value)>0.001)) or (type(value)~="number" and got~=value) then
 return R.blocked("codec-field-mismatch:"..kind.."."..key)
 end
end
validated[kind]=true
return true
end
local function sendIntent(kind, intent)
if suspended or not alive or game.PlaceId~=EXPECTED_PLACE then return R.blocked("paused-stopped-or-wrong-place") end
local s = findSession(false)
if not s or type(s.send_intent) ~= "function" then return false end
if R.canSend and not R.canSend(s,kind,intent) then return false end
if not probeIntent(kind, intent) then
if ownerReaderError ~= "codec:" .. kind then
ownerReaderError = "codec:" .. kind
log(kind .. " paused: local packet format did not validate (no packet sent)")
end
return false
end
local ok, result = pcall(s.send_intent, s, intent)
if not ok or result == false then
log(kind .. " call failed: " .. str(result, 90), true)
return false
end
R.sent(kind,intent,s.state)
attempted[kind] = (attempted[kind] or 0) + 1
log(kind .. " intent passed to game client (server result unconfirmed)")
return true
end
local function lobbyInMatch(s)
if not s then return false end
if type(s.lobby) == "table" and s.lobby.in_match == true then return true end
local st = s.state
return type(st)=="table" and (st.phase==0 or st.phase==1) and type(st.local_owner)=="number" and type(st.owners)=="table" and type(st.owners[st.local_owner] or st.owners[tostring(st.local_owner)])=="table"
end
local function joinIfNeeded()
local s = findSession(false)
if not s or lobbyInMatch(s) then return end
if now() - lastAction.join < 18 then return end
if type(s.join_multiplayer) ~= "function" then
log("join_multiplayer not available; Auto Join waiting")
lastAction.join = now()
return
end
if type(s.lobby) == "table" and (s.lobby.in_match or s.lobby.stage == "playing") then return end
if s._mp_waiting == true then return end
lastAction.join = now()
local ok, res = pcall(s.join_multiplayer, s)
if ok and res ~= false then
attempted.join = attempted.join + 1
log("Auto Join request called")
else
log("Auto Join call failed: " .. str(res, 70), true)
end
end
local function tileReader(state)
if type(state) ~= "table" or type(state.N) ~= "number" or state.N <= 0 then return nil end
local n = math.floor(state.N)
local owners = state.owner
if typeof(owners) ~= "buffer" or not buffer or type(buffer.len) ~= "function" then
return nil
end
local ok, len = pcall(buffer.len, owners)
if not ok then return nil end
local bytes = len / n
R.ownerWidth=bytes
local read
if bytes == 1 and type(buffer.readu8) == "function" then read = buffer.readu8
elseif bytes == 2 and type(buffer.readu16) == "function" then read = buffer.readu16
elseif bytes == 4 and type(buffer.readu32) == "function" then read = buffer.readu32
else return nil end
return function(tile)
if type(tile) ~= "number" or tile < 0 or tile >= n then return nil end
local good, value = pcall(read, owners, math.floor(tile) * bytes)
return good and value or nil
end
end
local function myOwner(s)
if not s or type(s.state) ~= "table" then return nil, nil end
local st = s.state
local id = st.local_owner
if type(id) ~= "number" or id < 0 then return nil, nil end
local o = type(st.owners) == "table" and (st.owners[id] or st.owners[tostring(id)]) or nil
if type(o) ~= "table" then return nil, nil end
return id, o
end
function R.vacant(st,id)
if type(id)~="number" then return false end
if type(st.owners)=="table" and (st.owners[id] or st.owners[tostring(id)]) then return false end
return id==0 or id==255 or id==65535 or id==4294967295
end
local function landTiles(st)
if type(st) ~= "table" or type(st.map) ~= "table" then return nil end
local map = st.map
if typeof(map.land_list) ~= "buffer" or type(map.land_count) ~= "number" then return nil end
if not buffer or type(buffer.readi32) ~= "function" then return nil end
local count = math.floor(map.land_count)
local ok, len = pcall(buffer.len, map.land_list)
if not ok then return nil end
count = math.min(count, math.floor(len / 4))
if count < 1 then return nil end
return function(i)
if type(i) ~= "number" or i < 0 or i >= count then return nil end
local good, tile = pcall(buffer.readi32, map.land_list, i * 4)
if good and tile >= 0 and tile < st.N then return tile end
return nil
end, count
end
local landCache={mapRef=nil,source=nil,n=0,ready=false,busy=false,mask=nil,count=0,
reason="not-started",loaded=0}
local function ensureLandIndex(st)
if type(st)~="table" or type(st.map)~="table" then return false end
local m,source,n=st.map,st.map.land_list,tonumber(st.N)
if landCache.mapRef==m and landCache.source==source and landCache.n==n and
landCache.inputCount==m.land_count and (landCache.ready or landCache.busy) then return landCache.ready end
if not n or n%1~=0 or n<1 or n>10000000 then landCache.reason="map-N-invalid";return false end
if typeof(source)~="buffer" or not buffer or not buffer.create or not buffer.readi32 or
not buffer.readu8 or not buffer.writeu8 then landCache.reason="buffer-api-unavailable";return false end
local len=buffer.len(source)
local count=tonumber(m.land_count)
if not count or count%1~=0 or count<1 or count*4>len then
landCache.reason="land-list-not-ready-or-invalid-count";return false end
local cache={mapRef=m,source=source,n=n,ready=false,busy=true,mask=nil,count=count,
inputCount=count,reason="building-land-mask",loaded=0,epoch=R.epoch}
landCache=cache
R.spawn(function()
local ok,err=xpcall(function()
local mask=buffer.create(math.ceil(n/8))
for i=0,count-1 do
 local tile=buffer.readi32(source,i*4)
 if tile<0 or tile>=n then error("land_list contains out-of-range tile "..tile) end
 local addr=math.floor(tile/8);local bit=2^(tile%8)
 local byte=buffer.readu8(mask,addr)
 if math.floor(byte/bit)%2==0 then buffer.writeu8(mask,addr,byte+bit) end
 if i%4096==4095 then
 cache.loaded=i+1;task.wait()
 if not alive or landCache~=cache or R.epoch~=cache.epoch then return end
 end
end
if not alive or landCache~=cache or R.epoch~=cache.epoch then return end
cache.mask=mask;cache.loaded=count;cache.ready=true;cache.reason="ready"
end,traceError)
cache.busy=false
if not ok and landCache==cache then cache.reason="index-error:"..str(err,120);R.traceback=err;log(cache.reason,true) end
end)
return cache.ready
end
local function isVerifiedLand(st,tile)
if not landCache.ready or landCache.mapRef~=st.map or
type(tile)~="number" or tile<0 or tile>=landCache.n then return nil end
local byte=buffer.readu8(landCache.mask,math.floor(tile/8))
return math.floor(byte/2^(tile%8))%2==1
end
-- V3.1.9.16 CRITICAL RUNTIME FIX: original atlas called a later local
-- ownerAllied(), resolving to nil and aborting every 1-second action cycle.
local function ownerAllied(st, id, targetOwner)
if not targetOwner or targetOwner == id then return false end
local pairsOf = st.alliances
if type(pairsOf) ~= "table" then return false end
local row = pairsOf[id] or pairsOf[tostring(id)]
if type(row) == "table" then
local value=row[targetOwner] or row[tostring(targetOwner)]
if value==true then return true end
end
return false
end
-- BEGIN V31916 FULL CLIENT WORLD ATLAS & GRAND PLAN
-- Reads EVERY land_list entry, records all nation footprints/borders/coasts.
-- Snapshot is deliberately labeled non-atomic, NOT proof of server-global state.
R.atlas={status="waiting-land-index",busy=false,ready=false,epoch=-1, scanned=0,
  total=0,snapshot=nil,plan=nil,route="none",nextDue=0,errors=0}
local function atlasFastOwner(st)
 if typeof(st.owner)~="buffer" or not buffer then return nil,"owner-buffer-missing" end
 local len=buffer.len(st.owner);local n=tonumber(st.N) or 0
 if n<1 or len%n~=0 then return nil,"owner-width-invalid" end
 local bytes=len/n
 local get=bytes==4 and buffer.readu32 or bytes==2 and buffer.readu16 or
           bytes==1 and buffer.readu8 or nil
 if not get then return nil,"owner-read-unsupported" end
 return function(t) return get(st.owner,t*bytes) end,"ready"
end
local function atlasCoast(st,t,land)
 local w,n=st.W,st.N;local x=t%w
 return (x>0 and not land(t-1)) or (x<w-1 and not land(t+1)) or
        (t>=w and not land(t-w)) or (t+w<n and not land(t+w))
end
local function atlasLand(st,t)
 local mask=landCache.mask
 if not mask or t<0 or t>=st.N then return false end
 local v=buffer.readu8(mask,math.floor(t/8))
 return math.floor(v/2^(t%8))%2==1
end
function R.atlasPickPlan(x)
 local army=math.max(0,tonumber(x.army) or 0)
 local strongest=math.max(0,tonumber(x.strongest) or 0)
 if x.incoming or x.nuclear then return "FORTIFY_ACTIVE_THREAT" end
 if x.recentLoss and (tonumber(x.neutrals) or 0)>0 then return "RECOVER_FREE_LAND" end
 if x.coastPath and (tonumber(x.coast) or 0)==0 and (tonumber(x.neutrals) or 0)>0 then
  return "CAPTURE_COAST_CORRIDOR"
 end
 if (tonumber(x.owned) or 0)<15 and (tonumber(x.neutrals) or 0)>0 then return "BOOTSTRAP_FREE_LAND" end
 if (tonumber(x.neutrals) or 0)>0 then return "LAND_GRAB" end
 if (tonumber(x.coast) or 0)>0 and army>=50000 then return "NAVAL_FOOTHOLD" end
 if strongest>0 and army>=strongest*1.8 then return "OPPORTUNISTIC_CONQUEST" end
 return "ECONOMY_AND_RECON"
end
local function atlasCorridor(st,get,land,coastBits,fronts,epoch,maxExpanded)
 -- Cooperative BFS through OWNED or truly VACANT land only; NEVER assume
 -- a diagonal/water jump or enemy territory is an accessible land corridor.
 local own=tonumber(st.local_owner);local w,n=st.W,st.N
 if not own or #fronts==0 then return nil,"no-owned-frontier" end
 local queue,prev,head,found={}, {},1,nil
 for _,t in ipairs(fronts) do
  if get(t)==own and not prev[t] then prev[t]=-1;queue[#queue+1]=t end
 end
 local expanded=0;maxExpanded=maxExpanded or 110000
 local function visit(t,from)
  if prev[t]~=nil or not land(t) then return end
  local id=get(t)
  if id~=own and not R.vacant(st,id) then return end
  prev[t]=from;queue[#queue+1]=t
 end
 while head<=#queue and expanded<maxExpanded do
  local t=queue[head];head=head+1;expanded=expanded+1
  if buffer.readu8(coastBits,math.floor(t/8))%(2^(t%8+1))>=2^(t%8) then
   if get(t)==own then return {goal=t,next=t,hops=0,expanded=expanded},"already-owned-coast" end
   found=t;break
  end
  local x=t%w
  if x>0 then visit(t-1,t) end
  if x<w-1 then visit(t+1,t) end
  if t>=w then visit(t-w,t) end
  if t+w<n then visit(t+w,t) end
  if expanded%2048==0 then
   task.wait()
   if not alive or R.epoch~=epoch or st.map~=landCache.mapRef then return nil,"context-changed" end
  end
 end
 if not found then return nil,(expanded>=maxExpanded and "corridor-budget-exhausted" or "no-vacant-coast-corridor") end
 local current,hops,nextStep=found,0,found
 while prev[current] and prev[current]~=-1 and hops<maxExpanded do
  local parent=prev[current];hops=hops+1
  if get(parent)==own then nextStep=current;break end
  current=parent
 end
 if not nextStep or get(nextStep)==own then return nil,"corridor-next-step-unavailable" end
 return {goal=found,next=nextStep,hops=hops,expanded=expanded},"verified-vacant-land-corridor"
end
function R.startFullAtlas(st)
 local a=R.atlas
 if not st or st.phase~=1 or not landCache.ready or landCache.mapRef~=st.map then return end
 if a.busy or now()<(a.nextDue or 0) then return end
 local get,why=atlasFastOwner(st)
 if not get then a.status=why;return end
 local landAt,count=landTiles(st)
 if not landAt then a.status="land-list-unavailable";return end
 local epoch,map,source=R.epoch,st.map,st.owner
 a.busy=true;a.status="scanning-all-land";a.scanned=0;a.total=count
 R.spawn(function()
  local ok,err=xpcall(function()
   local nations,neighbors,coastCounts,fronts={}, {}, {}, {}
   local coasts=buffer.create(math.ceil(st.N/8))
   local mine=tonumber(st.local_owner)
   local localNeutral,localHostile,localCoast=0,0,0
   local function inc(a,b)
    local r=neighbors[a];if not r then r={};neighbors[a]=r end
    r[b]=(r[b] or 0)+1
   end
   for i=0,count-1 do
    local t=landAt(i)
    if not t then error("invalid-land-list-entry-"..tostring(i)) end
    local id=get(t)
    local row=nations[id]
    if not row then row={count=0,minX=st.W,maxX=0,minY=st.H,maxY=0};nations[id]=row end
    local x=t%st.W;local y=math.floor(t/st.W)
    row.count=row.count+1;row.minX=math.min(row.minX,x);row.maxX=math.max(row.maxX,x)
    row.minY=math.min(row.minY,y);row.maxY=math.max(row.maxY,y)
    local isCoast=atlasCoast(st,t,function(tile) return atlasLand(st,tile) end)
    if isCoast then
     local pos=math.floor(t/8);local bit=2^(t%8);local v=buffer.readu8(coasts,pos)
     if math.floor(v/bit)%2==0 then buffer.writeu8(coasts,pos,v+bit) end
     coastCounts[id]=(coastCounts[id] or 0)+1
     if id==mine then localCoast=localCoast+1 end
    end
    local border=false
    -- Unordered land border pairs, so nation-level adjacency does not depend
    -- on which 2,800 owned tiles the attack selector happened to sample.
    if x<st.W-1 and atlasLand(st,t+1) then
     local other=get(t+1)
     if other~=id then inc(id,other);inc(other,id);border=true end
    end
    if t+st.W<st.N and atlasLand(st,t+st.W) then
     local other=get(t+st.W)
     if other~=id then inc(id,other);inc(other,id);border=true end
    end
    if id==mine then
     if x>0 and atlasLand(st,t-1) and get(t-1)~=mine then border=true end
     if t>=st.W and atlasLand(st,t-st.W) and get(t-st.W)~=mine then border=true end
     if border then
      local j=#fronts
      if j<360 then fronts[j+1]=t
      else
       local slot=(i*1299709+j*7919)%(j+1)+1
       if slot<=360 then fronts[slot]=t end
      end
     end
    end
    if i%2048==2047 then
     a.scanned=i+1;task.wait()
     if not alive or a~=R.atlas or R.epoch~=epoch or st.map~=map or st.owner~=source then return end
    end
   end
   if not alive or a~=R.atlas or R.epoch~=epoch or st.map~=map then return end
   local adj=neighbors[mine] or {}
   for other,edges in pairs(adj) do
    if R.vacant(st,other) then localNeutral=localNeutral+edges else localHostile=localHostile+edges end
   end
   local structures={}
   for _,b in pairs(type(st.structures)=="table" and st.structures or {}) do
    if type(b)=="table" then
     local id=tonumber(b.owner)
     if id then
      local kind=tostring(b.kind)
      local item=structures[id] or {};item[kind]=(item[kind] or 0)+1;structures[id]=item
     end
    end
   end
   -- Grounded coast access: prefer the complete coast_list supplied by the
   -- game. Coastline inferred from terrain is a FALLBACK, not proof of boats.
   local coastlineSource="TERRAIN_INFERRED_NOT_NAVAL_VERIFIED"
   local listedCoast,listedRead,listedInvalid=0,0,0
   local listed=st.map and st.map.coast_list
   if typeof(listed)=="buffer" and type(st.map.coast_count)=="number" and
       buffer.readi32 and st.map.coast_count>=0 and st.map.coast_count<=3000000 and
       buffer.len(listed)>=st.map.coast_count*4 then
    coastlineSource="GAME_COAST_LIST_ALL_ENTRIES"
    local exact=buffer.create(math.ceil(st.N/8))
    local verifiedCounts={}
    for i=0,st.map.coast_count-1 do
     local tile=buffer.readi32(listed,i*4)
     listedRead=i+1
     if tile>=0 and tile<st.N and atlasLand(st,tile) then
      local owner=get(tile)
      local byte=math.floor(tile/8);local bit=2^(tile%8)
      local oldByte=buffer.readu8(exact,byte)
      if math.floor(oldByte/bit)%2==0 then
       buffer.writeu8(exact,byte,oldByte+bit)
       verifiedCounts[owner]=(verifiedCounts[owner] or 0)+1
       listedCoast=listedCoast+1
      end
     else listedInvalid=listedInvalid+1 end
     if i%2048==2047 then
      task.wait()
      if not alive or a~=R.atlas or R.epoch~=epoch or st.map~=map then return end
     end
    end
    coasts=exact;coastCounts=verifiedCounts
    localCoast=coastCounts[mine] or 0
   end
   local old=a.snapshot
   local growth={}
   if old and old.epoch==epoch then
    for id,row in pairs(nations) do growth[id]=row.count-((old.nations[id] or {}).count or 0) end
   end
   -- This optional coast-path BFS searches up to 110k reachable land cells;
   -- it does not claim to solve every possible geopolitical/naval route.
   local corridor,route=nil,"not-needed"
   if localCoast==0 and #fronts>0 then
    corridor,route=atlasCorridor(st,get,function(t) return atlasLand(st,t) end,
      coasts,fronts,epoch,110000)
    if a~=R.atlas or R.epoch~=epoch then return end
   end
   local snap={epoch=epoch,at=now(),tick=tonumber(st.tick),map=map,
    scanned=count,total=count,nations=nations,neighbors=neighbors,coasts=coastCounts,
    structures=structures,growth=growth,myCoast=localCoast,neutralEdges=localNeutral,
    hostileEdges=localHostile,corridor=corridor,route=route,
    coastSource=coastlineSource,coastListRead=listedRead,coastListInvalid=listedInvalid,
    coastListedUnique=listedCoast,
    countNations=0,complete=true,nonAtomic=true}
   for _ in pairs(nations) do snap.countNations=snap.countNations+1 end
   a.snapshot=snap;a.status="complete-client-land-list-nonatomic";a.ready=true
   a.scanned=count;a.lastAt=snap.at;a.nextDue=now()+16
  end,traceError)
  a.busy=false
  if not ok then a.status="atlas-error:"..str(err,140);a.errors=a.errors+1;a.nextDue=now()+20 end
 end)
end
function R.updateGrandPlan(s)
 local a=R.atlas;local snap=a.snapshot;local _,own=myOwner(s)
 if not own or not snap or snap.epoch~=R.epoch or now()-snap.at>75 then
  a.plan={mode="WAIT_FOR_FRESH_WORLD",why=a.status};return a.plan
 end
 local id=s.state.local_owner
 local land=(snap.nations[id] or {}).count or 0
 local rivals=snap.neighbors[id] or {};local neutral=0;local chosen=nil;local best=-1e30
 local army=tonumber(own.troops) or 0
 for other,edges in pairs(rivals) do
  if R.vacant(s.state,other) then neutral=neutral+edges
  elseif not ownerAllied(s.state,id,other) then
   local opponent=s.state.owners and (s.state.owners[other] or s.state.owners[tostring(other)])
   local enemy=tonumber(opponent and opponent.troops) or 0
   local enemyLand=(snap.nations[other] or {}).count or 0
   -- A theater is an opportunity only when the old battle safety gate can
   -- accept it; even this ranking does NOT prove local garrison strength.
   if enemy>0 and army>=enemy*2.1 then
    local score=edges*0.5+math.sqrt(enemyLand+1)*2-math.log(enemy+1)*8
    if (R.world.attackerLast or {})[other] then score=score+45 end
    if score>best then best=score;chosen=other end
   end
  end
 end
 local w=R.world
 local mode=R.atlasPickPlan({army=army,owned=land,neutrals=neutral,
  coast=snap.myCoast,coastPath=snap.corridor~=nil,incoming=w.incoming>0,
  nuclear=(w.nukeUntil or -9999)>now(),recentLoss=(w.emergencyUntil or -9999)>now(),
  strongest=chosen and tonumber((s.state.owners[chosen] or {}).troops) or 0})
 local old=a.plan
 if old and old.epoch==R.epoch and old.mode=="CAPTURE_COAST_CORRIDOR" and
     mode=="LAND_GRAB" and snap.corridor then mode=old.mode end
 local steps
 if mode=="FORTIFY_ACTIVE_THREAT" then
  steps={"preserve-home-army","defend-critical-economy","resume-land-expansion-after-threat"}
 elseif mode=="CAPTURE_COAST_CORRIDOR" then
  steps={"capture-reachable-neutral-corridor","reach-verified-coast","launch-safe-naval-foothold"}
 elseif mode=="NAVAL_FOOTHOLD" then
  steps={"verify-water-route","secure-island-landing","reinforce-supply-and-economy"}
 elseif mode=="OPPORTUNISTIC_CONQUEST" then
  steps={"verify-troop-superiority","focus-one-border-opponent","consolidate-economy"}
 else
  steps={"claim-low-risk-land","balance-city-and-factory","reassess-geography-and-threats"}
 end
 a.plan={epoch=R.epoch,at=now(),mode=mode,enemy=chosen,land=land,
  neutralEdges=neutral,coast=snap.myCoast,corridorNext=snap.corridor and snap.corridor.next,
  corridorGoal=snap.corridor and snap.corridor.goal,route=snap.route,steps=steps,
  topThreat=w.incoming>0 and "active-incoming" or "no-active-attack-observed",
  why="complete-client-map-read; routes-and-future-events-unverified"}
 return a.plan
end
-- END V31916 FULL CLIENT WORLD ATLAS & GRAND PLAN

-- BEGIN V31914 COMPLETE SEA COMPONENT ATLAS
-- Full WATER connectivity over client map.N, built once per map epoch.
-- A connected component proves topological water access, NOT that RoFront
-- permits a boat order for that range, cost, fleet or destination.
R.seaAtlas={status="waiting-land-index",busy=false,ready=false,epoch=-1,
  scanned=0,total=0,waterCells=0,groups=0,label=nil,errors=0}
function R.startSeaAtlas(st)
 local a=R.seaAtlas
 if not st or not landCache.ready or landCache.mapRef~=st.map then return end
 if a.ready or a.busy or a.epoch==R.epoch and now()<(a.nextRetry or 0) then return end
 if not buffer or not buffer.create or not buffer.readu16 or not buffer.writeu16 then
  a.status="buffer-u16-unavailable";a.nextRetry=now()+30;return
 end
 local epoch,map=R.epoch,st.map
 a.epoch=epoch;a.busy=true;a.status="indexing-every-water-cell";a.total=st.N;a.scanned=0
 R.spawn(function()
  local ok,err=xpcall(function()
   local labels=buffer.create(st.N*2)
   local waterCount,groupCount=0,0
   local function tryPush(t,id,q)
    if t<0 or t>=st.N or atlasLand(st,t) then return end
    if buffer.readu16(labels,t*2)~=0 then return end
    buffer.writeu16(labels,t*2,id)
    q[#q+1]=t
   end
   for t=0,st.N-1 do
    if not atlasLand(st,t) and buffer.readu16(labels,t*2)==0 then
     groupCount=groupCount+1
     if groupCount>65534 then error("ocean-label-id-overflow") end
     local queue={t};local head=1
     buffer.writeu16(labels,t*2,groupCount)
     while head<=#queue do
      local cell=queue[head];head=head+1;waterCount=waterCount+1
      local x=cell%st.W
      if x>0 then tryPush(cell-1,groupCount,queue) end
      if x<st.W-1 then tryPush(cell+1,groupCount,queue) end
      if cell>=st.W then tryPush(cell-st.W,groupCount,queue) end
      if cell+st.W<st.N then tryPush(cell+st.W,groupCount,queue) end
      if waterCount%4096==0 then
       task.wait()
       if not alive or a~=R.seaAtlas or R.epoch~=epoch or st.map~=map then return end
      end
     end
    end
    if t%8192==8191 then
     a.scanned=t+1;task.wait()
     if not alive or a~=R.seaAtlas or R.epoch~=epoch or st.map~=map then return end
    end
   end
   if not alive or a~=R.seaAtlas or R.epoch~=epoch or st.map~=map then return end
   a.label=labels;a.waterCells=waterCount;a.groups=groupCount
   a.scanned=st.N;a.ready=true;a.status="full-client-map-water-components"
  end,traceError)
  a.busy=false
  if not ok then a.status="sea-index-error:"..str(err,140);a.errors=a.errors+1;a.nextRetry=now()+45 end
 end)
end
function R.seaConnected(st,target,sources)
 local a=R.seaAtlas
 if not a.ready or a.epoch~=R.epoch then return nil,"sea-atlas-not-ready" end
 local w,n=st.W,st.N
 local function labelsNear(t)
  local x=t%w;local nodes={}
  if x>0 then nodes[#nodes+1]=t-1 end
  if x<w-1 then nodes[#nodes+1]=t+1 end
  if t>=w then nodes[#nodes+1]=t-w end
  if t+w<n then nodes[#nodes+1]=t+w end
  local groups={}
  for _,node in ipairs(nodes) do
   local g=buffer.readu16(a.label,node*2)
   if g>0 then groups[g]=true end
  end
  return groups
 end
 local targetGroups=labelsNear(target)
 if next(targetGroups)==nil then return false,"target-no-connected-water" end
 for _,src in ipairs(sources) do
  for group in pairs(labelsNear(src)) do
   if targetGroups[group] then return true,"same-water-component-route-distance-unverified" end
  end
 end
 return false,"different-water-components"
end
-- END V31914 COMPLETE SEA COMPONENT ATLAS

local ownerScan={ready=false,busy=false,mapRef=nil,owner=nil,tiles={},total=0,
scanned=0,lastAt=-1000,reason="not-started"}
local function refreshOwnerScan(st)
if not landCache.ready or landCache.mapRef~=st.map or st.phase~=1 then return end
local id=tonumber(st.local_owner)
if not id or typeof(st.owner)~="buffer" then return end
local same=ownerScan.mapRef==st.map and ownerScan.owner==id and ownerScan.source==st.owner
if same and (ownerScan.busy or now()-ownerScan.lastAt<10) then return end
local reader=tileReader(st)
if not reader then ownerScan.reason="owner-buffer-unreadable";return end
local scan={ready=false,busy=true,mapRef=st.map,owner=id,source=st.owner,
tiles={},total=0,scanned=0,lastAt=-1000,reason="scanning",epoch=R.epoch}
ownerScan=scan
R.spawn(function()
local ok,err=xpcall(function()
local landAt,count=landTiles(st)
if not landAt then error("land-list-unavailable") end
local stride=math.max(1,math.floor(count/2800))
local borderCount=0
for i=0,count-1 do
local tile=landAt(i)
if tile and reader(tile)==id then
 scan.total=scan.total+1
 -- Retain frontier cells, not only the first 2800 interior tiles.
 local x=tile%st.W
 local border=(x>0 and reader(tile-1)~=id) or (x<st.W-1 and reader(tile+1)~=id) or
 (tile>=st.W and reader(tile-st.W)~=id) or (tile+st.W<st.N and reader(tile+st.W)~=id)
 if #scan.tiles<2800 and (border or i%stride==0) then scan.tiles[#scan.tiles+1]=tile end
 if border then borderCount=borderCount+1 end
 -- Deterministic replacement distributes frontier samples across the map.
 if border and #scan.tiles>=2800 and borderCount%stride==0 then scan.tiles[(borderCount%2800)+1]=tile end
end
if i%4096==4095 then
 scan.scanned=i+1;task.wait()
 if not alive or ownerScan~=scan or scan.epoch~=R.epoch then return end
end
end
if not alive or ownerScan~=scan or scan.epoch~=R.epoch then return end
scan.scanned=count;scan.ready=true;scan.reason="ready-nonatomic";scan.lastAt=now()
end,traceError)
scan.busy=false
if not ok and ownerScan==scan then scan.reason="scan-error:"..str(err,100);R.traceback=err;log(scan.reason,true) end
end)
end
local spawnAudit={tested=0, chosen="none", score="none", result="not-verified",
  coastScanned=0,coastCandidates=0,coastalEligible=0,interiorEligible=0,
  coastStatus="not-scanned", bestCoastal="none", bestInterior="none", selection="none"}
function R.chooseSpawnCandidate(coastal,interior)
 if not coastal then return interior,"INTERIOR_NO_VIABLE_COAST" end
 if not interior then return coastal,"COAST_CANDIDATE_LAND_ONLY" end
 -- A coast bonus of roughly 40 previously overwhelmed the actual land
 -- quality. The live selected goals were occupied before we reached them.
 -- Demand comparable land quality; proximity alone cannot prove a naval route.
 if coastal.baseScore>=interior.baseScore-3 and
     coastal.score>=interior.score-12 then
  return coastal,"COAST_CANDIDATE_ROUTE_UNVERIFIED"
 end
 return interior,"INTERIOR_PREFERRED_OVER_SPECULATIVE_COAST"
end
-- V3.1.9.16: coast-informed spawn search. Neither proximity to coast nor
-- client codec success guarantees server spawn validity or naval access.
local function spawnTile(s)
 local st=s.state
 if not landCache.ready or landCache.mapRef~=st.map then
  spawnAudit.result="waiting-for-map-land-index";return nil
 end
 local landAt,count=landTiles(st);local ownerAt=tileReader(st)
 local epoch,contextMap=R.epoch,st.map
 local w,h,n=tonumber(st.W),tonumber(st.H),tonumber(st.N)
 if not landAt or not ownerAt or not w or not h or w<10 or h<10 or not n then return nil end
 local directions={{1,0},{-1,0},{0,1},{0,-1},{1,1},{-1,1},{1,-1},{-1,-1}}
 local bestCoastal,bestInterior=nil,nil
 local checked,unique=0,{}
 spawnAudit.coastScanned=0;spawnAudit.coastCandidates=0
 spawnAudit.coastalEligible=0;spawnAudit.interiorEligible=0
 spawnAudit.coastStatus="missing-coast-list";spawnAudit.bestCoastal="none";spawnAudit.bestInterior="none";spawnAudit.coastGoal="none"
 local function evaluate(tile,nearCoast,distCoast,coastGoal)
  if not tile or unique[tile] then return end
  unique[tile]=true
  if tile<0 or tile>=n or isVerifiedLand(st,tile)~=true or not R.vacant(st,ownerAt(tile)) then return end
  local x,y=tile%w,math.floor(tile/w)
  if x<5 or x>=w-5 or y<5 or y>=h-5 then return end
  local open,room,hostile,water,exits=0,0,0,0,0
  local nearSafe=0
  for _,d in ipairs(directions) do
   local lane=0
   for _,radius in ipairs({1,3,10,25,55}) do
    local xx,yy=x+d[1]*radius,y+d[2]*radius
    if xx>=0 and xx<w and yy>=0 and yy<h then
     local t=yy*w+xx
     if isVerifiedLand(st,t)==true then
      local other=ownerAt(t)
      if R.vacant(st,other) then
       room=room+1;lane=lane+1
       if radius==1 then open=open+1 end
       if radius==3 then nearSafe=nearSafe+1 end
      else
       local enemy=type(st.owners)=="table" and (st.owners[other] or st.owners[tostring(other)])
       hostile=hostile+(radius<=10 and 5 or 1)*(type(enemy)=="table" and (tonumber(enemy.troops) or 0)>25000 and 2 or 1)
      end
     elseif radius<=25 then water=water+1 end
    end
   end
   if lane>=3 then exits=exits+1 end
  end
  -- 3x3 vacant footprint filters out water-edge misplacements; the game
  -- may require a different radius and can still reject this candidate.
  if open<6 or nearSafe<5 or exits<3 then return end
  for dy=-1,1 do for dx=-1,1 do
   local t=(y+dy)*w+x+dx
   if isVerifiedLand(st,t)~=true or not R.vacant(st,ownerAt(t)) then return end
  end end
  local edge=math.min(x/w,1-x/w,y/h,1-y/h)
  local shelter=math.max(0,1-edge/.13)*12
  local landScore=open*5+room*1.5+exits*2-hostile*10+shelter
  -- Use verified coast_list as a candidate generator, not guesswork from
  -- unowned water tiles. Require broad land even for coastal spawns.
  local coastBonus=0
  if nearCoast then
   if distCoast>=7 and distCoast<=36 then
    coastBonus=42-(math.abs(distCoast-18)*0.3)
   elseif distCoast<7 then coastBonus=7 else coastBonus=8 end
  end
  local score=landScore+coastBonus
  local detail={tile=tile,score=score,baseScore=landScore,room=room,exits=exits,
   hostile=hostile,open=open,water=water,coastDist=distCoast or -1,
   coast=nearCoast and true or false,coastGoal=coastGoal}
  checked=checked+1
  if nearCoast then
   spawnAudit.coastalEligible=spawnAudit.coastalEligible+1
   if not bestCoastal or score>bestCoastal.score then bestCoastal=detail end
  else
   spawnAudit.interiorEligible=spawnAudit.interiorEligible+1
   if not bestInterior or score>bestInterior.score then bestInterior=detail end
  end
 end
 -- Do not rely on 900 isolated random-ish land cells to happen to reach
 -- a coast. Generate actual candidates 7-36 tiles INLAND from coastline.
 local coast=st.map and st.map.coast_list
 local coastCount=st.map and tonumber(st.map.coast_count)
 if typeof(coast)=="buffer" and coastCount and coastCount>0 and
    buffer and type(buffer.len)=="function" and type(buffer.readi32)=="function" then
  local ok,coastBytes=pcall(buffer.len,coast)
  if ok and coastBytes>=4 then
   coastCount=math.min(math.floor(coastBytes/4),math.floor(coastCount))
   local limit=math.min(coastCount,520)
   spawnAudit.coastStatus="coast-list-candidates"
   for j=0,limit-1 do
    if R.epoch~=epoch or st.phase~=0 or s.state~=st or st.map~=contextMap then
     spawnAudit.result="spawn-scan-context-changed";return nil
    end
    local idx=math.floor((j+.5)*coastCount/limit)
    local readOK,shore=pcall(buffer.readi32,coast,idx*4)
    if readOK and type(shore)=="number" and shore>=0 and shore<n and
       isVerifiedLand(st,shore)==true then
     spawnAudit.coastScanned=spawnAudit.coastScanned+1
     local cx,cy=shore%w,math.floor(shore/w)
     -- Alternate coast distances and cardinal/diagonal search to respect
     -- the CPU budget on a phone; the game state is sampled, not complete.
     for d=1,8 do
      local dist=({9,17,28,36})[1+(j+d)%4]
      local dd=directions[d]
      local x,y=cx+dd[1]*dist,cy+dd[2]*dist
      if x>=5 and x<w-5 and y>=5 and y<h-5 then
       spawnAudit.coastCandidates=spawnAudit.coastCandidates+1
       -- A coast behind hostile land or across water is not usable.
       -- Require a neutral inland corridor toward the sampled coast.
       local connected=R.vacant(st,ownerAt(shore))
       if connected then
        for step=1,dist do
         local xx=cx+dd[1]*step;local yy=cy+dd[2]*step
         local middle=yy*w+xx
         if isVerifiedLand(st,middle)~=true or not R.vacant(st,ownerAt(middle)) then
          connected=false;break
         end
        end
       end
       if connected then evaluate(y*w+x,true,dist,shore) end
      end
     end
    end
    if j%110==109 then task.wait() end
   end
  else spawnAudit.coastStatus="invalid-coast-buffer" end
 end
 local limit=math.min(count,1150)
 for j=0,limit-1 do
  if R.epoch~=epoch or st.phase~=0 or s.state~=st or st.map~=contextMap then
   spawnAudit.result="spawn-scan-context-changed";return nil
  end
  local sample=landAt(math.floor((j+.5)*count/limit))
  local asCoast=false
  -- If the game's coast_list is unavailable during spawn phase, derive a
  -- possible shore from the verified land mask instead. 'Not land' may also
  -- mean impassable terrain; this is strictly a fallback, not proof of sea.
  if spawnAudit.coastScanned==0 and sample and sample>=0 and sample<n and
     R.vacant(st,ownerAt(sample)) then
   local sx,sy=sample%w,math.floor(sample/w)
   for d=1,4 do
    local dd=directions[d];local lastLand=nil
    for step=1,36 do
     local xx,yy=sx+dd[1]*step,sy+dd[2]*step
     if xx<0 or xx>=w or yy<0 or yy>=h then break end
     local at=yy*w+xx
     local land=isVerifiedLand(st,at)
     if land==true and R.vacant(st,ownerAt(at)) then lastLand=at
     elseif land==false then
      if step>=7 and lastLand then
       spawnAudit.coastStatus="land-mask-fallback-sea-unverified"
       spawnAudit.coastCandidates=spawnAudit.coastCandidates+1
       evaluate(sample,true,step,lastLand)
       asCoast=true
      end
      break
     else break end
    end
    if asCoast then break end
   end
  end
  if not asCoast then evaluate(sample,false,nil) end
  if j%250==249 then task.wait() end
 end
 -- Compare land quality separately from the speculative coast bonus.
 -- A coast_list tile does not establish usable ocean access later in a match.
 local chosen,selection=R.chooseSpawnCandidate(bestCoastal,bestInterior)
 spawnAudit.selection=chosen and selection or "NO_SAFE_SPAWN_FOUND"
 spawnAudit.tested=checked
 if bestInterior then spawnAudit.bestInterior=string.format("tile=%d score=%.1f",bestInterior.tile,bestInterior.score) end
 if bestCoastal then spawnAudit.bestCoastal=string.format("tile=%d score=%.1f",bestCoastal.tile,bestCoastal.score) end
 if chosen then
  spawnAudit.chosen=tostring(chosen.tile)
  spawnAudit.coastGoal=tostring(chosen.coastGoal or "none")
  spawnAudit.score=string.format("%.1f",chosen.score)
  spawnAudit.detail=string.format("open=%d room=%d exits=%d hostile=%d water-proxy=%d coast-distance=%d selected=%s",
   chosen.open,chosen.room,chosen.exits,chosen.hostile,chosen.water,chosen.coastDist,spawnAudit.selection)
  return chosen.tile
 end
 spawnAudit.result="no-safe-candidate-after-coast-and-land-search"
 return nil
end

function R.pollSpawn(s)
local st=s.state
if st.phase==1 and spawnAudit.result=="request-sent-unconfirmed" then
local _,own=myOwner(s)
if own and (own.spawned==true or (tonumber(own.spawn_tile) or -1)>=0) then
local observed=tonumber(own.spawn_tile)
local chosen=tonumber(spawnAudit.chosen)
if observed and chosen and observed==chosen then
spawnAudit.result="observed-spawn-at-selected-tile"
else
spawnAudit.result="spawned-but-selected-tile-unconfirmed (observed="..tostring(observed)..")"
end
R.observed("spawn",spawnAudit.result,st,tonumber(spawnAudit.chosen))
attempted.spawnSeen=attempted.spawnSeen+1
end
end
end
local function autoSpawn(s)
if not enabled.autoSpawn or not s or not s.state then return end
local st=s.state
R.pollSpawn(s)
if st.phase~=0 or st.loaded==false then return end
if now()-lastAction.spawn<10 then return end
local id,own=myOwner(s)
if not id or not own then return end
if own.spawned==true or (type(own.spawn_tile)=="number" and own.spawn_tile>=0) then
if spawnAudit.result~="observed-spawn" then
spawnAudit.result="observed-spawn"
R.observed("spawn",spawnAudit.result,st,tonumber(spawnAudit.chosen))
attempted.spawnSeen=attempted.spawnSeen+1
end
return
end
local target=spawnTile(s)
if not target then
if spawnAudit.result~="waiting-for-map-land-index" and
   spawnAudit.result~="spawn-scan-context-changed" then
spawnAudit.result="no-valid-land-candidate"
end
return
end
-- Spawn search yields to avoid freezing mobile; match may start meanwhile.
if st.phase~=0 or s.state~=st then
 spawnAudit.result="spawn-phase-changed-before-send";return
end
lastAction.spawn=now()
if sendIntent("spawn",{type="spawn",tile=target}) then
spawnAudit.result="request-sent-unconfirmed"
log("Spawn candidate="..target.." score="..spawnAudit.score.." (placement not confirmed)")
end
end
local function neighbours(tile, width, n)
local x = tile % width
local t = {}
if x > 0 then t[#t+1] = tile-1 end
if x < width-1 then t[#t+1] = tile+1 end
if tile >= width then t[#t+1] = tile-width end
if tile+width < n then t[#t+1] = tile+width end
return t
end
-- V3.1.9.16: ownerAllied is defined BEFORE R.updateGrandPlan;
-- do not declare it after GrandPlan (a later local is invisible above).
-- Function definition moved to the common helper area.

function R.shouldBlockSecondFront(x)
 return x.enemy and not x.tribe and not x.retaliation and
     (x.earlyArmy or x.borderDanger) and x.lastOwner~=nil and
     x.targetOwner~=x.lastOwner and x.since<180
end
function R.occupiedEngagementGate(x)
 -- A small tribe can be a safe way out of a full troop cap before the first
 -- city can be afforded. Owner totals are proxies, not tile garrisons.
 local army=math.max(0,tonumber(x.army) or 0)
 local cap=math.max(1,tonumber(x.cap) or 1)
 local enemy=tonumber(x.enemy)
 if (tonumber(x.incoming) or 0)>0 then return false,"incoming-attack-hold-home" end
 if x.nuclearActive then return false,"active-missile-threat" end
 if not enemy or enemy<=0 then return false,"target-total-unreadable" end
 -- V31916: losing territory or a non-attributed troop crash MUST NOT
 -- forbid all easy tribe captures for 150 seconds when troops are 97% full.
 -- Check tribes BEFORE the severe-loss restriction on player wars.
 if x.tribe then
  if army<25000 or army/cap<.55 then return false,"tribe-wait-for-army" end
  local recovering=x.recentSevereLoss or x.recentLoss
  if recovering then
   -- While recovering, only a very weak tribe qualifies, with large home reserve.
   if army<enemy*6 or army*.25<enemy*2.25 then return false,"recovery-tribe-insufficient-advantage" end
   if army*.75<math.max(cap*.45,enemy*3) then return false,"recovery-tribe-home-reserve" end
   return true,"recovery-safe-weak-tribe"
  end
  if army<enemy*3 or army*.25<enemy*1.2 then return false,"tribe-dispatch-proxy-too-small" end
  if army*.75<math.max(cap*.4,enemy*2) then return false,"tribe-home-reserve-too-small" end
  return true,"weak-tribe-with-home-reserve"
 end
 if x.recentSevereLoss then return false,"recent-severe-loss-block-new-player-war" end
 if x.recentLoss then return false,"recent-loss-no-player-war" end
 if army<300000 or army/cap<.55 then return false,"opening-army-or-fill-too-low" end
 if (tonumber(x.cities) or 0)<1 or (tonumber(x.factories) or 0)<1 then
  return false,"city-and-factory-not-established"
 end
 if army<enemy*(x.retaliation and 2.2 or 3.0) then
  return false,"insufficient-owner-total-advantage"
 end
 if army*.25<enemy*(x.retaliation and .5 or .65) then
  return false,"quarter-dispatch-too-small"
 end
 if army*.75<math.max(cap*.35,enemy*1.5) then
  return false,"home-reserve-after-quarter-dispatch"
 end
 return true,"economic-and-army-gates-pass"
end
function R.neutralFrontPenalty(strongAdjacent)
 -- Neutral or weak tribe land can create a border with a stronger player.
 -- Prefer a safer expansion path when both exist.
 return math.min(240,math.max(0,strongAdjacent)*125)
end
function R.combatDispatchGate(army,enemy,ratio,retaliating)
 -- Owner.troops is a TOTAL, not the garrison on the chosen border cell.
 -- This is a conservative opening-war gate after repeated captured tiles
 -- exposed our economy to a much larger counterattack in two live reports.
 if type(enemy)~="number" or enemy<=0 then return false,"enemy-total-unreadable" end
 if type(ratio)~="number" or ratio<=0 then return false,"dispatch-ratio-unreadable" end
 local sent=army*ratio
 local left=army-sent
 local sendNeed=enemy*(retaliating and .50 or .65)
 local homeNeed=enemy*(retaliating and 1.00 or 1.25)
 if sent<sendNeed then return false,"dispatch-below-enemy-total-proxy" end
 if left<homeNeed then return false,"home-reserve-below-enemy-total-proxy" end
 return true,"sent-and-home-proxy-pass"
end
local function selectAttackTarget(s)
local st=s.state
if not landCache.ready or landCache.mapRef~=st.map then
combat.lastDecision="waiting-for-terrain-index: "..landCache.reason
return nil
end
local id,own=myOwner(s)
if not id or not own or own.alive==false or own.spawned==false then return nil end
local ownerAt=tileReader(st)
local w,n=tonumber(st.W),tonumber(st.N)
if not ownerAt or not w or w<1 or not n then return nil end
local samples={}
local seen={}
local spawn=tonumber(own.spawn_tile)
if spawn and spawn>=0 and spawn<n then
local queue={spawn};local h=1
seen[spawn]=true
while h<=#queue and #queue<1450 do
local t=queue[h];h=h+1
if ownerAt(t)==id then
samples[#samples+1]=t
for _,a in ipairs(neighbours(t,w,n)) do
if not seen[a] then
seen[a]=true
if ownerAt(a)==id then queue[#queue+1]=a end
end
end
end
end
end
local landAt,count=landTiles(st)
if landAt then
local limit=math.min(2600,count)
local offset=(math.floor(now()*97)+(tonumber(st.tick) or 0))%count
for j=0,limit-1 do
local idx=(offset+math.floor((j+0.5)*count/limit))%count
local t=landAt(idx)
if t and not seen[t] and ownerAt(t)==id then
samples[#samples+1]=t;seen[t]=true
end
end
end
if ownerScan.ready and ownerScan.mapRef==st.map and ownerScan.owner==id then
for _,t in ipairs(ownerScan.tiles) do
if not seen[t] and ownerAt(t)==id then
samples[#samples+1]=t
seen[t]=true
end
end
end
if #samples==0 then
combat.lastDecision="no-owned-tiles-found (check spawn/owner buffer)"
return nil
end
local troopCount=tonumber(own.troops) or 0
local highest,best,borderThreat=nil,-math.huge,0
local bestVacant,vacantScore=nil,-math.huge
local cities,factories=0,0
for _,b in pairs(type(st.structures)=="table" and st.structures or {}) do
 if type(b)=="table" and tonumber(b.owner)==id then
  if b.kind=="city" or tonumber(b.kind)==0 then cities=cities+1 end
  if b.kind=="factory" or tonumber(b.kind)==2 then factories=factories+1 end
 end
end
R.secondFrontCurrent=0
R.commitmentBlocked=0
R.lastCommitGateReason="none"
R.occupiedBlocked=0
R.occupiedBlockReason="none"
R.occupiedReasonCounts={}
R.recoveryTribeCandidates=0
R.neutralFrontBlocked=0
local viable=0;local rejected=0
local tested={}
local valuable={}
for _,b in pairs(type(st.structures)=="table" and st.structures or {}) do
 if type(b)=="table" and tonumber(b.owner)~=id then
  local tile=tonumber(b.tile or b.at or b.pos or b.cell or b.idx)
  local kind=tonumber(b.kind)
  if tile and kind then
   valuable[tile]=kind==5 and 55 or kind==0 and 42 or kind==2 and 35 or
      kind==1 and 25 or kind==3 and -15 or 0
  end
 end
end
for _,from in ipairs(samples) do
for _,to in ipairs(neighbours(from,w,n)) do
local other=ownerAt(to)
if isVerifiedLand(st,to)==true and type(other)=="number" and other~=id and not ownerAllied(st,id,other)
and (combat.avoidUntil[to] or 0)<now() and not tested[to] then
tested[to]=true
local enemy=type(st.owners)=="table" and (st.owners[other] or st.owners[tostring(other)]) or nil
local vacant=R.vacant(st,other)
local tribe=type(enemy)=="table" and tonumber(enemy.kind)==1
local enemyTroops=type(enemy)=="table" and tonumber(enemy.troops) or nil
local ratioStrength=enemyTroops and troopCount/math.max(1,enemyTroops) or nil
if not vacant and not tribe and enemyTroops and enemyTroops>troopCount*0.5 then
borderThreat=borderThreat+1
end
local currentMode=R.world and R.world.mode or "GROWTH"
local earlyArmy=troopCount<350000
local aggression=(R.world.attackerLast or {})[other]
local retaliation=aggression and now()-aggression<110
-- In V3192, 1.23x TOTAL enemy troops was enough to open a new war,
-- even though the packet dispatched only a fraction of our own troops.
-- Refuse near-peer *new* wars in the early game; retaliation is separate.
local openWarThreshold=earlyArmy and 2.10 or 1.75
local possible=vacant or (tribe and (not enemyTroops or troopCount>=enemyTroops*.95)) or
 (enemyTroops and troopCount>=enemyTroops*(retaliation and 1.30 or openWarThreshold))
if possible and not vacant then
 local safe,why=R.occupiedEngagementGate({army=troopCount,cap=own.max_troops,
  enemy=enemyTroops,tribe=tribe,cities=cities,factories=factories,
  incoming=R.world and R.world.incoming or 0,
  recentLoss=now()<(R.world and R.world.emergencyUntil or -9999),
  recentSevereLoss=R.world and ((R.world.peakOwned or 0)>=80 and
      (R.world.lastOwned or 0)<(R.world.peakOwned or 0)*.65 or
      now()-(R.world.troopCrashAt or -9999)<150),
  nuclearActive=now()<(R.world and R.world.nukeUntil or -9999),
  retaliation=retaliation})
 if not safe then
  possible=false;R.occupiedBlocked=R.occupiedBlocked+1
  R.occupiedBlockReason=why
  R.occupiedReasonCounts[why]=(R.occupiedReasonCounts[why] or 0)+1
 elseif tribe and why=="recovery-safe-weak-tribe" then
  R.recoveryTribeCandidates=R.recoveryTribeCandidates+1
 end
end
if possible and not vacant and not tribe then
 local expectedRatio=currentMode=="GROWTH" and troopCount>=900000 and .35 or .25
 local allowed,gateReason=R.combatDispatchGate(troopCount,enemyTroops,expectedRatio,retaliation)
 if not allowed then
  possible=false
  R.commitmentBlocked=R.commitmentBlocked+1
  R.lastCommitGateReason=gateReason
 end
end
-- V3.1.9.5 opened wars against many different neighbors while its first
-- City and Factory were exposed. Consolidate one offensive front at a time.
-- Retaliation against a current attacker is still allowed.
local openingFront=earlyArmy or (R.world and (R.world.borderDanger or 0)>0)
if R.shouldBlockSecondFront({enemy=not vacant,tribe=tribe,
    retaliation=retaliation,earlyArmy=earlyArmy,
    borderDanger=openingFront,lastOwner=R.lastRivalOwner,
    targetOwner=other,since=now()-(R.lastRivalAttack or -9999)}) then
 possible=false
 R.secondFrontCurrent=R.secondFrontCurrent+1
end
if currentMode=="DEFEND" and not vacant and not retaliation then possible=false end
if not vacant and not tribe and earlyArmy and not retaliation and troopCount<90000 then possible=false end
local score=(vacant and 170 or tribe and 100 or 10)
if not vacant then score=score+(valuable[to] or 0) end
if currentMode=="RECOVER" or currentMode=="CAUTION" then
 if vacant then score=score+85 elseif not retaliation then score=score-90 end
elseif currentMode=="DEFEND" then
 if vacant then score=score+35
 elseif retaliation and enemyTroops and troopCount>=enemyTroops*1.5 then
  score=score+250
 elseif retaliation then score=score+90 end
end
-- V31914 persistent strategy: boost ONLY verified adjacent legal land targets.
-- Global plan cannot bypass possible/ratio/protocol dispatch safety filters.
local macro=R.atlas and R.atlas.plan
if macro and macro.epoch==R.epoch then
 if vacant and macro.corridorNext==to and macro.mode=="CAPTURE_COAST_CORRIDOR" then
  score=score+180
 elseif vacant and macro.mode=="BOOTSTRAP_FREE_LAND" then score=score+22 end
 if not vacant and not tribe and macro.enemy==other and macro.mode=="OPPORTUNISTIC_CONQUEST" then
  score=score+45
 end
end
-- Drive early neutral expansion toward the accessible coastline selected at spawn.
local goal=tonumber(spawnAudit.coastGoal)
if vacant and goal and goal>=0 and goal<n and
 isVerifiedLand(st,goal)==true and R.vacant(st,ownerAt(goal)) then
 local gx,gy=goal%w,math.floor(goal/w)
 local srcDist=math.abs(from%w-gx)+math.abs(math.floor(from/w)-gy)
 local dstDist=math.abs(to%w-gx)+math.abs(math.floor(to/w)-gy)
 if dstDist<srcDist then
  score=score+22
 elseif dstDist>srcDist then score=score-3 end
end
if enemyTroops then
score=score+math.min(30,math.log(math.max(1,ratioStrength or 1))*9)
if enemyTroops>troopCount*1.8 then score=score-80 end
elseif not vacant then
score=score-10 -- unknown strength: conservative
end
local nFree=0
for _,neighbor in ipairs(neighbours(to,w,n)) do
local v=ownerAt(neighbor)
if isVerifiedLand(st,neighbor)==true and R.vacant(st,v) then nFree=nFree+1 end
end
score=score+nFree*1.6
-- Vacant or weak-tribe land beside a powerful third party opens a risky
-- frontier. Owner totals are only caution proxies, not local garrisons.
if vacant or tribe then
 local danger=0
 for _,neighbor in ipairs(neighbours(to,w,n)) do
  local nid=ownerAt(neighbor)
  if nid~=id and nid~=other and not R.vacant(st,nid) and
     type(nid)=="number" and not ownerAllied(st,id,nid) then
   local rec=type(st.owners)=="table" and (st.owners[nid] or st.owners[tostring(nid)]) or nil
   local troops=type(rec)=="table" and tonumber(rec.troops) or nil
   if troops and troops>troopCount*(troopCount<1000000 and 1.05 or 1.3) then danger=danger+1 end
  end
 end
 score=score-R.neutralFrontPenalty(danger)
 if vacant and danger>0 and troopCount<300000 then
  possible=false
  R.neutralFrontBlocked=(R.neutralFrontBlocked or 0)+1
 end
end
if R.world and (R.world.outgoing[other] or 0)>0 then score=score+8 end
if not possible then rejected=rejected+1 else viable=viable+1 end
if possible and score>best then
best=score
highest={tile=to,from=from,targetOwner=other,
enemyTroops=enemyTroops,neutral=vacant,tribe=tribe,
score=score,ourTroops=troopCount}
end
if possible and vacant and score>vacantScore then
 vacantScore=score
 bestVacant={tile=to,from=from,targetOwner=other,
  enemyTroops=nil,neutral=true,tribe=false,score=score,ourTroops=troopCount}
end
end
end
end
combat.borderThreat=borderThreat
-- Spend the opening on safe unowned land even if a counterattack receives
-- an attractive score. Occupied battles wait until the free front closes.
if bestVacant and vacantScore>=60 and (R.world.incoming or 0)==0 then
 highest=bestVacant
end
R.borderThreatAt=now()
R.attackCandidates=viable;R.attackRejected=rejected
R.coastApproach="no-selected-coast-goal"
local coastGoal=tonumber(spawnAudit.coastGoal)
if coastGoal and coastGoal>=0 and coastGoal<n then
 local v=ownerAt(coastGoal)
 if v==id then R.coastApproach="coast-already-owned"
 elseif not R.vacant(st,v) then R.coastApproach="coast-goal-occupied-by-rival"
 elseif highest and highest.neutral then
  local gx,gy=coastGoal%w,math.floor(coastGoal/w)
  local startDistance=math.abs(highest.from%w-gx)+math.abs(math.floor(highest.from/w)-gy)
  local endDistance=math.abs(highest.tile%w-gx)+math.abs(math.floor(highest.tile/w)-gy)
  R.coastApproach=endDistance<startDistance and "chosen-neutral-toward-coast" or "chosen-neutral-other-front"
 else R.coastApproach="no-viable-neutral-coast-route" end
end
if not highest then
 combat.lastDecision="no-safe-land-target (ownerScan="..tostring(ownerScan.total)..
    "; commitment-blocked="..tostring(R.commitmentBlocked)..")"
end
return highest,own
end
local function underPressure(s)
return R.isPressured and R.isPressured(s) or false
end
local function chooseAttackRatio(s,target,own)
 local army=math.max(0,tonumber(own.troops) or 0)
 local cap=math.max(1,tonumber(own.max_troops) or 1)
 local p=R.currentPolicy(s)
 local threatening=(R.world.attackerLast or {})[target.targetOwner]
 local retaliating=threatening and now()-threatening<=110
 local reserve=math.max(1400,army*p.reserveFraction)
 R.reserve=reserve
 if army<4500 or army-reserve<1400 then return nil,"army-below-minimum-safe-dispatch" end
 if target.neutral and not p.allowNeutral then return nil,"neutral-restricted-during-missile-strike" end
 if p.mode=="DEFEND" and not target.neutral and not retaliating then
  return nil,"avoid-opening-new-war-under-active-attack"
 end
 local desired,reason
 if target.neutral then
  desired=(p.mode=="RECOVER" or p.mode=="DEFEND") and 0.10 or
       (p.fill>=.65 and 0.25 or army>=180000 and 0.25 or 0.10)
  reason="low-cost-open-land"
 elseif target.tribe then
  if target.enemyTroops and army<target.enemyTroops*.90 then return nil,"tribe-too-strong" end
  desired=p.mode=="DEFEND" and 0.10 or army>=350000 and 0.35 or 0.25
  reason="tribe-front"
 elseif not target.enemyTroops then
  if p.mode~="GROWTH" and not retaliating then return nil,"unknown-enemy-during-recovery" end
  desired=0.10;reason="unknown-strength-low-commitment"
 else
  local advantage=army/math.max(1,target.enemyTroops)
  if advantage<1.23 and not retaliating then return nil,"bad-force-ratio" end
  if advantage<1.05 then return nil,"cannot-counter-stronger-force" end
  desired=(advantage>=4 and army>=450000 and p.mode=="GROWTH" and 0.75) or
      (advantage>=2.5 and p.mode=="GROWTH" and 0.50) or
      (advantage>=1.65 and 0.35) or 0.25
  reason="force-advantage="..string.format("%.2f",advantage)
 end
 if p.mode=="DEFEND" then
  local oneFront=(R.world.incoming or 0)<=1
  local favorableCounter=retaliating and target.enemyTroops and
      army>=target.enemyTroops*2.4 and oneFront
  desired=math.min(desired,favorableCounter and 0.35 or 0.25)
 elseif p.mode=="RECOVER" then desired=math.min(desired,target.neutral and 0.10 or 0.25)
 elseif p.mode=="CAUTION" then desired=math.min(desired,0.25) end
if not target.neutral and army<900000 then
  desired=math.min(desired,0.25)
 end
 local available=(army-reserve)/army
 for _,ratio in ipairs({0.75,0.50,0.35,0.25,0.10}) do
  if ratio<=desired and ratio<=available+0.000001 then
   if not target.neutral and not target.tribe then
    local allowed,why=R.combatDispatchGate(army,target.enemyTroops,ratio,retaliating)
    if not allowed then return nil,why.."; candidate-ratio="..ratio end
   end
   return ratio,reason.."; strategy="..p.mode
  end
 end
 return nil,"keep-reserve:"..p.mode
end
function R.pollAttack(s)
if combat.pending then
local p=combat.pending
local getOwner=tileReader(s.state)
if getOwner and getOwner(p.tile)==s.state.local_owner then
R.observed("attack","target-owner-changed",s.state,p.tile)
attempted.attackCaptured=attempted.attackCaptured+1
combat.avoidUntil[p.tile]=nil
R.fastAttackUnconfirmed=0
log("Capture observed at "..p.tile.." (causal attribution unverified)")
combat.pending=nil
elseif now()-p.since>27 then
R.timedOut("attack",p.tile)
attempted.attackUnconfirmed=attempted.attackUnconfirmed+1
combat.avoidUntil[p.tile]=now()+80
R.fastAttackUnconfirmed=(R.fastAttackUnconfirmed or 0)+1
if R.fastAttackUnconfirmed>=3 then
 R.fastAttackBackoffUntil=now()+90
 R.attackTempoDecision="90s-fast-neutral-backoff-after-three-unconfirmed"
 R.fastAttackUnconfirmed=0
end
log("Attack outcome unconfirmed at tile "..p.tile)
combat.pending=nil
else return true end
end

return false
end
local function autoAttack(s)
if not enabled.autoAttack or not s or type(s.state)~="table" then return end
if s.state.phase~=1 or s.paused==true then return end
if combat.pending then return end
-- Give the coastal planner a short exclusive window when it is examining a
-- nearby island. The old 3s land cadence made the 12s boat gate unreachable.
if naval and naval.planning then return end
-- V3.1.9.16: safe-neutral TEMPO. Underpopulated nations lose the opening
-- when every inexpensive neutral claim waits five full seconds. Quicker
-- neutral dispatch is conditional; enemy invasions keep the 5s cadence.
-- Client calls and territory observations are NOT server acknowledgements.
local planned=R.currentPolicy(s)
local currentOwn=select(2,myOwner(s))
R.lastArmyObserved=tonumber(currentOwn and currentOwn.troops) or 0
local canQuick=planned and planned.allowNeutral and not planned.emergency and
 planned.mode~="DEFEND" and
 -- A near-empty army can still make tiny neutral claims; retain the 5s gate
 -- when the actual army is too small to defend the home territory.
 ((planned.fill or 0)>=.40 or
  ((planned.mode=="GROWTH" or planned.mode=="RECOVER") and
   ((R.lastArmyObserved or 0)>=20000))) and
 now()>=(R.fastAttackBackoffUntil or 0)
-- A confirmed capture clears combat.pending; throttle prevents unbounded sends.
local minDelay=canQuick and 2 or 5
R.attackTempoDecision=canQuick and "candidate-neutral-fast-2s" or "normal-5s"
if now()-R.lastMilitary<minDelay then return end
-- A boat in transit must not freeze land expansion for 105s.
if now()-lastAction.attack<minDelay then return end
local target,own=selectAttackTarget(s)
if not target or not own then return end
-- Do not speed up contested war just because we also have free land nearby.
if not target.neutral and (now()-R.lastMilitary<5 or now()-lastAction.attack<5) then
 R.attackTempoDecision="enemy-target-5s-safety"
 return
end
local army=tonumber(own.troops) or 0
if army<50 then return end
-- Enemy global troop counts are NOT their local defending garrison.
-- Avoid consecutive offensive wars during the vulnerable opening minutes.
if not target.neutral and not target.tribe then
 local since=now()-(R.lastRivalAttack or -9999)
 local waitFor=(R.world.borderDanger or 0)>0 and 22 or army<800000 and 16 or 11
 if since<waitFor then
  R.attackTempoDecision="rival-cooldown="..string.format("%.1f",waitFor-since)
  return
 end
end
local ratio,reason=chooseAttackRatio(s,target,own)
combat.lastDecision=reason.." / enemy="..tostring(target.enemyTroops).." / score="..string.format("%.1f",target.score)
if not ratio then
combat.avoidUntil[target.tile]=now()+9
return
end
lastAction.attack=now()
combat.lastRatio=string.format("%.2f",ratio)
combat.lastTarget=tostring(target.tile).." / troops="..math.floor(army).." / enemy="..tostring(target.enemyTroops).." / ratio="..combat.lastRatio
if sendIntent("attack",{type="attack",tile=target.tile,ratio=ratio}) then
if not target.neutral and not target.tribe then
 R.lastRivalAttack=now();R.lastRivalArmy=army;R.lastRivalOwner=target.targetOwner
end
R.lastMilitary=now()
R.attackTempoDecision=(target.neutral and canQuick and "fast-neutral-attempt" or "standard-attempt")..
 "; last-ratio="..string.format("%.2f",ratio)
combat.pending={tile=target.tile,since=now(),enemy=target.enemyTroops,ratio=ratio}
end
end
-- Source: AllThingsHow RoFront guides, 2026-10-12 and 2026-10-19.
-- Costs are estimates until a fresh contextual game quote; optional Port now guarded.
-- Actual price, tier mapping and reserve after purchase remain unverified.
local COST = {[0]=125000, [1]=125000, [2]=125000, [3]=50000, [4]=1500000, [5]=1000000}
local KIND_NAME = {[0]="city", [1]="port", [2]="factory", [3]="defense",
[4]="sam", [5]="silo", [6]="artillery", [7]="airfield", [8]="railgun"}
local goldReserve = 10000
local construction = {pending=nil, candidate=nil, candidates={}, nextIdx=1, inspected=0,
latest="waiting", schema="not-tested", lastObserved="none", counts=nil, samples={}, avoided={}, reasons={}, lastPrice="published-minimum-not-quote"}
local structuresError = "none"
local function tileOf(b, st)
if type(b) ~= "table" then return nil end
local t = b.tile or b.at or b.pos or b.cell or b.idx
t=tonumber(t)
if t and t >= 0 and t < (st.N or 0) then return math.floor(t) end
return nil
end
local function structureInfo(st, id)
local counts, blocked, countTotal = {}, {}, 0
R.structuresUnlocated=0
for kind=0,8 do counts[kind] = 0 end
if type(st.structures) == "table" then
for key, b in pairs(st.structures) do
if type(b) == "table" then
local tile = tileOf(b, st)
if not tile then R.structuresUnlocated=R.structuresUnlocated+1 end
if tile then blocked[tile] = true end
if tonumber(b.owner) == id then
local kind=tonumber(b.kind)
if not kind then for k,name in pairs(KIND_NAME) do if name==b.kind then kind=k;break end end end
if kind and counts[kind] then counts[kind] = counts[kind] + 1 end
countTotal = countTotal + 1
end
end
end
end
return counts, blocked, countTotal
end
local function isUnderAttack(st, id)
if type(st.attacks) ~= "table" then return false end
for _, a in pairs(st.attacks) do
if type(a) == "table" and tonumber(a.attacker) ~= id then
local tid = tonumber(a.target)
if tid == id then return true end
end
end
return false
end
local defenseAudit={incoming=0,nukesSeen=0,samCount=0,assets=0,
samReason="none",samCoverage="unmeasured",nukeThreat="none"}
local function buildingBudgetThreshold(kind,counts)
-- A lower bound only enables a rate-limited build attempt. Server enforces price.
-- Counts cannot establish the next price: captured structures and upgrades differ.
return COST[kind] or math.huge
end
local function likelyNukeThreat(st,id)
local threat=0;local seen=0
local ownTiles={}
local readOwner=tileReader(st)
local ownStructures=0
if type(st.structures)=="table" then
for k,b in pairs(st.structures) do
if type(b)=="table" and tonumber(b.owner)==id then
local pos=tileOf(b,st)
if pos then ownTiles[#ownTiles+1]=pos end
ownStructures=ownStructures+1
end
end
end
if type(st.nukes)=="table" then
for _,nuke in pairs(st.nukes) do
if type(nuke)=="table" then
seen=seen+1
local attacker=tonumber(nuke.owner or nuke.sender or nuke.from_owner or nuke.attacker)
local to=tonumber(nuke.target or nuke.tile or nuke.target_tile or nuke.to)
if attacker~=id then
if tonumber(nuke.target_owner)==id then threat=threat+2
elseif to and readOwner and readOwner(to)==id then threat=threat+2
elseif to and type(st.W)=="number" then
local x,y=to%st.W,math.floor(to/st.W)
for _,pos in ipairs(ownTiles) do
local dx=(pos%st.W)-x
local dy=math.floor(pos/st.W)-y
if dx*dx+dy*dy<85*85 then threat=threat+2;break end
end
else
threat=threat+0.2
end
end
end
end
end
defenseAudit.incoming=math.floor(threat)
defenseAudit.nukesSeen=seen
defenseAudit.assets=ownStructures
defenseAudit.nukeThreat=(threat>=1 and "suspected-near-us" or "no-local-threat-detected")
return threat
end
-- BEGIN V317_PURE_POLICY (V3.1.9.16 graduated defense and recovery; locally testable)
local function policy317(x)
 local army=math.max(0,tonumber(x.army) or 0)
 local cap=math.max(1,tonumber(x.cap) or 1)
 local peak=math.max(0,tonumber(x.peakOwned) or 0)
 local owned=math.max(0,tonumber(x.owned) or 0)
 local fill=math.min(1,army/cap)
 local fraction=peak>=80 and owned/peak or 1
 local incoming=(tonumber(x.incoming) or 0)>0
 local borderDanger=(tonumber(x.borderDanger) or 0)
 local loss=x.lossActive==true
 local nuclear=x.nuclearActive==true
 local depleted=peak>=80 and fraction<0.38
 local fragile=army<13000 or (cap<=250000 and army<cap*.065)
 local mode,reason
 -- Never lock into 90% reserve / no neutral captures after a huge loss. If
 -- direct attacks stop, RECOVER must be able to take easy land immediately.
 if incoming or nuclear then
  mode,reason="DEFEND","active-front-or-missile"
 elseif loss and (depleted or fraction<0.65) then
  mode,reason="RECOVER","recent-loss-recapture-vacant-land"
 elseif loss then
  mode,reason="CAUTION","recent-territory-loss"
 elseif borderDanger>=1 then
  mode,reason="CAUTION","strong-opponent-on-nearby-frontier"
 elseif depleted or (fragile and peak>=80) then
  mode,reason="RECOVER","post-loss-rebuild"
 else
  mode,reason="GROWTH","stable-expansion"
 end
 -- Keep enough troops for the main defense, but allow a small economical
 -- expansion even during pressure when the alternative is inactivity.
 local reserve=(mode=="DEFEND" and 0.64 or mode=="CAUTION" and 0.50 or
                mode=="RECOVER" and 0.40 or 0.30)
 -- Island/landlocked recovery: 75K at a 75K cap should not be blocked by
 -- the former 95K absolute troop gate. Naval still requires a real route.
 -- Direct incoming attacks or an active missile warning override expansion.
 local canRecoverCoast=(mode=="GROWTH" or mode=="RECOVER" or mode=="CAUTION")
 -- V31914: get usable early coast access without gambling the defense on
 -- low-troop boats. A still-small country is allowed neutral claims when
 -- 10% commitment and the absolute home reserve remain feasible.
 -- At 50K and 40% fill a neutral island can be reached with a 10% boat
 -- while keeping at least 35% of capacity at home. Occupied islands have
 -- a separate economy/force gate. Water connectivity alone is not an ACK.
 local capStallEscape=(mode=="RECOVER" and fill>=.90 and borderDanger<=1 and
     (tonumber(x.landTargets) or 0)==0 and army>=50000)
 local allowNaval=(canRecoverCoast and not incoming and not nuclear and
     (borderDanger==0 or capStallEscape) and
     army>=50000 and owned>=25 and fill>=.40 and army*.90>=cap*.35)
 local allowNeutral=(army>=4300 and not nuclear)
 return {mode=mode,reason=reason,reserveFraction=reserve,
  allowNaval=allowNaval, allowNeutral=allowNeutral,
  emergency=(mode=="DEFEND"),lossFraction=1-fraction,fill=fill,
  fragile=fragile,activeIncoming=incoming,activeNuclear=nuclear, borderDanger=borderDanger}
end
R.policy317=policy317
-- END V317_PURE_POLICY
-- END V317_PURE_POLICY
-- Decisions use only state delivered to this client. Unknown records remain unknown.
R.world={active={},events={},outgoing={},incoming=0,incomingTroops=0,unknown=0,raw={},lastScan=-1,lastOwned=nil,peakOwned=0,lossAt=-9999,emergencyUntil=-9999,nukeUntil=-9999,lastNukeCheck=-9999,lastNukeSignature="none",attackerLast={},mode="WAITING",troopWindow={},troopCrashAt=-9999}
function R.ownerLabel(st,id)
 local o=type(st.owners)=="table" and (st.owners[id] or st.owners[tostring(id)])
 return tostring(id)..":"..str(type(o)=="table" and (o.name or o.display_name or o.country) or "unnamed",50)
end
function R.worldEvent(message)
 local w=R.world
 w.events[#w.events+1]=string.format("%.1fs %s",now(),message)
 if #w.events>50 then table.remove(w.events,1) end
end
-- Read-only early-warning based on borders already held. Owner troop totals
-- cannot prove the army placed at a given frontier; use ONLY as a caution flag.
function R.frontThreat(s)
 local st=s and s.state
 if type(st)~="table" then return 0,0,0 end
 if R.frontMemo and R.frontMemo.epoch==R.epoch and now()-R.frontMemo.at<3 then
  return R.frontMemo.level,R.frontMemo.rivals,R.frontMemo.strongest
 end
 local id,own=myOwner(s)
 local get=tileReader(st)
 local samples=ownerScan.ready and ownerScan.mapRef==st.map and ownerScan.owner==id and ownerScan.tiles
 local army=tonumber(own and own.troops) or 0
 if not id or not get or not samples or #samples==0 then return 0,0,0 end
 local rivals={};local strongest=0;local count=0
 local sampleCount=math.min(2200,#samples)
 for j=1,sampleCount do
  local t=samples[math.floor((j-.5)*#samples/sampleCount)+1]
  if t and get(t)==id then
   for _,around in ipairs(neighbours(t,st.W,st.N)) do
    local other=get(around)
    if type(other)=="number" and other~=id and not R.vacant(st,other) and
     not ownerAllied(st,id,other) then
     rivals[other]=true
     local o=type(st.owners)=="table" and (st.owners[other] or st.owners[tostring(other)]) or nil
     local troops=tonumber(type(o)=="table" and o.troops) or 0
     strongest=math.max(strongest,troops/math.max(1,army))
    end
   end
  end
 end
 for _ in pairs(rivals) do count=count+1 end
 local level=(strongest>=1.65 or (strongest>=1.12 and count>=2)) and 1 or 0
 R.frontSampleCount=sampleCount
 R.frontMemo={epoch=R.epoch,at=now(),level=level,rivals=count,strongest=strongest}
 return level,count,strongest
end
function R.currentPolicy(s)
 local _,own=myOwner(s)
 local w=R.world
 local border,rivals,strongest=R.frontThreat(s)
 local p=policy317({army=own and own.troops,cap=own and own.max_troops,
   peakOwned=w.peakOwned,owned=w.lastOwned,incoming=w.incoming,borderDanger=border,
   lossActive=now()<(w.emergencyUntil or -9999) and
     ((w.peakOwned or 0)>=80 and (w.lastOwned or 0)<(w.peakOwned or 0)*.80 or
      now()-(w.troopCrashAt or -9999)<150),
   nuclearActive=now()<(w.nukeUntil or -9999),
   landTargets=R.attackCandidates or 0})
 w.plan=p;w.mode=p.mode;w.borderDanger=border;w.borderRivals=rivals;w.borderStrongest=strongest
 return p
end
function R.observeWorld(s,force)
 local st=s and s.state;if type(st)~="table" then return end
 local w=R.world
 if not force and now()-w.lastScan<0.5 then return end
 w.lastScan=now();w.incoming=0;w.incomingTroops=0;w.outgoing={};w.unknown=0;w.raw={}
 local _,own=myOwner(s)
 local troops=tonumber(own and own.troops)
 local cap=tonumber(own and own.max_troops)
 if troops and cap and cap>0 then
  local history=w.troopWindow or {}
  for i=#history,1,-1 do if now()-history[i].at>25 then table.remove(history,i) end end
  local high=troops
  for _,row in ipairs(history) do high=math.max(high,row.troops) end
  if #history>0 and high>=75000 and troops<high*.50 and troops/cap<.35 and
      now()-(w.troopCrashAt or -9999)>110 then
   w.troopCrashAt=now();w.lossAt=now()
   w.emergencyUntil=math.max(w.emergencyUntil or -9999,now()+150)
   R.worldEvent("ARMY_CRASH_OBSERVED peak25s="..math.floor(high).." now="..math.floor(troops).."; cause-unverified; occupied-attacks-paused")
   history={}
  end
  history[#history+1]={at=now(),troops=troops}
  w.troopWindow=history
 end
 local active={};local scanned=0;local owners=type(st.owners)=="table" and st.owners or {}
 for key,a in pairs(type(st.attacks)=="table" and st.attacks or {}) do
  scanned=scanned+1;if scanned>2000 then w.unknown=w.unknown+1;break end
  if type(a)=="table" then
   local attacker=tonumber(a.attacker or a.from_owner)
   local defender=tonumber(a.defender or a.to_owner or a.target_owner or a.target)
   local troops=tonumber(a.troops)
   local attackerKnown=attacker and (owners[attacker] or owners[tostring(attacker)])
   local defenderKnown=defender and (owners[defender] or owners[tostring(defender)])
   if #w.raw<8 then
    w.raw[#w.raw+1]="key="..str(key,30).." attacker="..tostring(a.attacker).." target="..tostring(a.target).." defender="..tostring(a.defender).." to_owner="..tostring(a.to_owner).." troops="..tostring(a.troops).." retreating="..tostring(a.retreating)
   end
   if attackerKnown and defenderKnown and attacker~=defender and a.retreating~=true then
    local tag=tostring(key)..":"..attacker..">"..defender
    active[tag]={attacker=attacker,defender=defender,troops=troops}
    w.outgoing[attacker]=(w.outgoing[attacker] or 0)+math.max(0,troops or 0)
    if defender==st.local_owner and attacker~=st.local_owner then
     w.incoming=w.incoming+1;w.incomingTroops=w.incomingTroops+math.max(0,troops or 0)
     w.attackerLast[attacker]=now();w.emergencyUntil=math.max(w.emergencyUntil or -9999,now()+90)
    end
    if not w.active[tag] then
     R.worldEvent("ATTACK_OBSERVED "..R.ownerLabel(st,attacker).." -> "..R.ownerLabel(st,defender).." troops(raw)="..tostring(troops))
    end
   elseif a.retreating~=true then w.unknown=w.unknown+1 end
  else w.unknown=w.unknown+1 end
 end
 for tag,old in pairs(w.active) do
  if not active[tag] then R.worldEvent("ATTACK_NO_LONGER_VISIBLE "..R.ownerLabel(st,old.attacker).." -> "..R.ownerLabel(st,old.defender).."; outcome unknown") end
 end
 w.active=active
 if ownerScan.ready and ownerScan.owner==st.local_owner and ownerScan.mapRef==st.map then
  local count=ownerScan.total
  w.peakOwned=math.max(w.peakOwned or 0,count)
  if w.lastOwned and count<w.lastOwned then
   local delta=w.lastOwned-count
   w.lossAt=now()
   if delta>=math.max(50,math.floor(w.lastOwned*.20)) then
    w.emergencyUntil=math.max(w.emergencyUntil or -9999,now()+150)
   end
   R.worldEvent("OWNED_LAND_DECREASE "..w.lastOwned.." -> "..count.." loss="..delta.."; non-atomic scan; attribution unknown")
  end
  w.lastOwned=count
 end
 -- The projectile list can go empty after impact. Remember a plausible local strike
 -- briefly instead of immediately resuming overseas attacks.
 if now()-(w.lastNukeCheck or -9999)>8 then
  w.lastNukeCheck=now()
  local suspicion=likelyNukeThreat(st,st.local_owner)
  if suspicion>=1 then
   -- Projectile arrays may retain completed launches. Only arm a new emergency
   -- for a NEW client-visible signature, not every time we poll a stale list.
   local stamps={};local k=0
   for key,pj in pairs(type(st.nukes)=="table" and st.nukes or {}) do
    if type(pj)=="table" then
     k=k+1
     stamps[#stamps+1]=str(key,20)..":"..str(pj.target_tile or pj.target or pj.tile or pj.to,20)..":"..str(pj.owner or pj.sender or pj.from_owner or pj.attacker,16)
     if k>=100 then break end
    end
   end
   table.sort(stamps)
   local signature=table.concat(stamps,";")
   if signature~=w.lastNukeSignature then
    w.lastNukeSignature=signature
    w.nukeUntil=math.max(w.nukeUntil or -9999,now()+130)
    w.emergencyUntil=math.max(w.emergencyUntil or -9999,now()+110)
    R.worldEvent("POSSIBLE_LOCAL_MISSILE_CHANGE; signature changed; actual impact not proven")
   end
  else w.lastNukeSignature="none" end
 end
 for attacker,last in pairs(w.attackerLast) do
  if now()-last>150 then w.attackerLast[attacker]=nil end
 end
 R.currentPolicy(s)
end
function R.isPressured(s)
 R.observeWorld(s)
 return R.world.plan and R.world.plan.emergency==true or false
end

-- A UI quote is contextual, short-lived and invalidated by any structure change.
R.quotes={};R.priceHistory={}
function R.structureFingerprint(st)
 local count,sum=0,0
 for k,b in pairs(type(st and st.structures)=="table" and st.structures or {}) do
  if type(b)=="table" and tonumber(b.owner)==st.local_owner then
   count=count+1;sum=sum+(tonumber(b.tile or b.at or b.pos or b.cell or b.idx) or 0)*31+(tonumber(b.level) or 1)*1000003
  end
 end
 return tostring(count)..":"..tostring(sum)
end
function R.money(raw)
 local s=tostring(raw):gsub("<[^>]*>",""):gsub(",",""):lower():gsub("gold",""):gsub("cost",""):gsub(":",""):match("^%s*(.-)%s*$")
 local number,suffix=s:match("^(%d+%.?%d*)%s*([km]?)$")
 if not number then return nil end
 local value=tonumber(number)*(suffix=="m" and 1000000 or suffix=="k" and 1000 or 1)
 if value<1000 or value>1000000000 then return nil end
 return value
end
function R.recordQuote(kind,value,context)
 local s=findSession(false)
 if not s or not s.state or not value then return end
 R.quotes[kind]={value=value,at=now(),fingerprint=R.structureFingerprint(s.state),epoch=R.epoch,context=str(context,180)}
 R.priceHistory[kind]="UI_OBSERVED "..value.." at="..string.format("%.1f",now()).." "..str(context,120)
end
function R.quotePrice(kind)
 local q=R.quotes[kind];local s=findSession(false)
 if q and s and q.epoch==R.epoch and now()-q.at<=20 and q.fingerprint==R.structureFingerprint(s.state) then
  return q.value,"UI_OBSERVED_CONTEXTUAL"
 end
 return nil,"NO_FRESH_UI_QUOTE"
end
function R.inspectPriceNode(node,visible)
 local function clean(text) return tostring(text or ""):gsub("<[^>]*>",""):lower() end
 local text=clean(node.Text)
 local named
 for kind,name in pairs(KIND_NAME) do
  if text:find("%f[%a]"..name.."%f[%A]") then named=kind;break end
 end
 if named==nil then return end
 local qualified=text:find("cost",1,true)~=nil
 local ancestor=node
 for _=1,10 do
  if not ancestor then break end
  local name=tostring(ancestor.Name):lower()
  if name:find("upgrade",1,true) then return end
  if name:find("build",1,true) or name:find("construct",1,true) then qualified=true end
  ancestor=ancestor.Parent
 end
 if not qualified then return end
 local container=node
 for _=1,3 do
  if not container then break end
  local queue={container};local head=1;local items={};local money={};local upgrade=false;local scanned=0
  local context={}
  while head<=#queue and scanned<60 do
   local current=queue[head];head=head+1;scanned=scanned+1
   if tostring(current.Name):lower():find("upgrade",1,true) then upgrade=true end
   if (current:IsA("TextLabel") or current:IsA("TextButton") or current:IsA("TextBox")) and visible(current) then
    local raw=clean(current.Text)
    if raw:find("upgrade",1,true) or raw:find("robux",1,true) or raw:find("stars",1,true) then upgrade=true end
    for kind,name in pairs(KIND_NAME) do if raw:find("%f[%a]"..name.."%f[%A]") then items[kind]=true end end
    local value=R.money(raw)
    if not value then value=R.money(raw:match("cost%s*:%s*([%d%.,]+%s*[km]?%s*gold)") or "") end
    if value then money[value]=true end
    if #context<6 and raw~="" then context[#context+1]=str(raw,55) end
   end
   local children=current:GetChildren()
   if #children<60 then for _,c in ipairs(children) do queue[#queue+1]=c end end
  end
  local itemCount,costCount,cost=0,0,nil
  for _ in pairs(items) do itemCount=itemCount+1 end
  for v in pairs(money) do costCount=costCount+1;cost=v end
  if not upgrade and head>#queue and itemCount==1 and items[named] and costCount==1 then
   R.recordQuote(named,cost,tostring(container.Name).." / "..table.concat(context," | "));return
  end
  container=container.Parent
 end
end
function R.buildBudget(kind,counts)
 local quoted,source=R.quotePrice(kind)
 if quoted then return quoted,source end
 -- Based on independently published OpenFront ladder, corroborated by the
 -- user's RoFront UI screenshots. NOT a verified RoFront game price.
 local owned=math.max(0,math.floor(tonumber(counts[kind]) or 0))
 local ladder={125000,250000,500000,1000000}
 local estimate
 if kind==0 then estimate=ladder[math.min(4,owned+1)]
 elseif kind==1 then
  -- Ports and factories have a shared ladder in OpenFront; RoFront unverified.
  estimate=ladder[math.min(4,owned+math.max(0,math.floor(tonumber(counts[2]) or 0))+1)]
 elseif kind==2 then
  -- OpenFront uses a shared port/factory ladder; RoFront sharing unconfirmed.
  estimate=ladder[math.min(4,owned+math.max(0,math.floor(tonumber(counts[1]) or 0))+1)]
 elseif kind==3 then estimate=math.min(250000,50000*(owned+1))
 elseif kind==4 then estimate=owned==0 and 1500000 or 3000000
 elseif kind==5 then estimate=1000000
 end
 return estimate or COST[kind] or math.huge,"OPENFRONT_PRICE_LADDER_ESTIMATE_NOT_GAME_QUOTE"
end
-- V3.1.9.16: dynamic resource choices. Port/coast are optional investments,
-- never buy just because a patch of water exists. OpenFront economics are
-- useful hypotheses; the RoFront client is the authoritative observed state.
R.ecoCoastCache=nil
function R.ecoCoast(s)
 local st=s and s.state
 local id=st and st.local_owner
 if type(st)~="table" or type(st.map)~="table" or type(id)~="number" then
  return {owned=0,tiles={},foreignPorts=0,status="state-not-ready"}
 end
 local old=R.ecoCoastCache
 if old and old.map==st.map and old.owner==id and now()-old.at<12 then return old end
 local info={map=st.map,owner=id,at=now(),tiles={},owned=0,
  foreignPorts=0,status="coast-not-verified",checked=0}
 local coast=st.map.coast_list; local declared=tonumber(st.map.coast_count)
 local read=tileReader(st)
 if typeof(coast)=="buffer" and declared and declared>0 and read and
  buffer and type(buffer.len)=="function" and type(buffer.readi32)=="function" then
  local ok,len=pcall(buffer.len,coast)
  if ok then
   local count=math.min(math.floor(len/4),math.floor(declared))
   local limit=math.min(count,16000)
   if limit>0 then
    for i=0,limit-1 do
     local idx=math.floor((i+.5)*count/limit)
     local success,t=pcall(buffer.readi32,coast,idx*4)
     if success and type(t)=="number" and t>=0 and t<st.N and
        isVerifiedLand(st,t)==true and read(t)==id then
       info.tiles[t]=true;info.owned=info.owned+1
     end
    end
    info.checked=limit;info.status="coast-list-sampled-not-route-confirmed"
   end
  end
 end
 if type(st.structures)=="table" then
  for _,b in pairs(st.structures) do
   if type(b)=="table" and (tonumber(b.kind)==1 or b.kind=="port") and
    type(b.owner)=="number" and b.owner~=id then info.foreignPorts=info.foreignPorts+1 end
  end
 end
 R.ecoCoastCache=info
 return info
end
-- Pure and deterministic: this helper can be exercised in a separate Luau
-- simulator without Roblox API mocks. Returns ordered *candidate* choices,
-- not an instruction to spend; affordability and placement are checked later.
function R.economyPriority(x)
 local cities=math.max(0,tonumber(x.cities) or 0)
 local factories=math.max(0,tonumber(x.factories) or 0)
 local ports=math.max(0,tonumber(x.ports) or 0)
 local defenses=math.max(0,tonumber(x.defenses) or 0)
 local sams=math.max(0,tonumber(x.sams) or 0)
 local incoming=x.incoming==true
 local mode=tostring(x.mode or "GROWTH")
 local fill=math.min(1,math.max(0,tonumber(x.fill) or 0))
 local gold=math.max(0,tonumber(x.gold) or 0)
 local income=math.max(0,tonumber(x.income) or 0)
 local recentLoss=x.recentLoss==true
 local coast=math.max(0,tonumber(x.coast) or 0)
 local foreignPorts=math.max(0,tonumber(x.foreignPorts) or 0)
 local landFront=math.max(0,tonumber(x.landFront) or 0)
 local nearbyIsland=math.max(0,tonumber(x.nearbyIsland) or 0)
 local enemySilos=math.max(0,tonumber(x.enemySilos) or 0)
 local nukes=math.max(0,tonumber(x.nukes) or 0)
 local nukesSeen=math.max(0,tonumber(x.nukesSeen) or 0)
 local silos=math.max(0,tonumber(x.silos) or 0)
 local choices={};local used={}
 local function add(kind,reason)
  if not used[kind] then used[kind]=true;choices[#choices+1]={kind,reason} end
 end
 -- The real V3.1.9.4 match repeatedly spent the first million on City/Factory.
 -- Save for the first SAM once the economy can sustain it, before a missile
 -- appears in our own projectile list. Do not starve the first City/Factory.
 local assetCount=cities+factories+ports
 local established=assetCount>=8 or (assetCount>=5 and income>=2500)
 local nuclearAlarm=nukes>=1 or nukesSeen>0 or enemySilos>0 or x.nuclearRecent==true
 if x.autoSam~=false and sams==0 and (established or
     (nuclearAlarm and cities+factories+ports>=3)) then
  add(4,nuclearAlarm and "first-sam-visible-nuclear-era" or "first-sam-capital-reserve")
 end
 -- Capacity is a cap, not the current growth rate. Buy when nearing cap,
 -- except the first city which supports the opening's next troop threshold.
 if fill>=.83 and not incoming then add(0,"troop-cap-bottleneck") end
 if cities==0 then add(0,"first-city-secure-capacity") end
 -- A port is an economic/coastal option when stranded; boat movement remains
 -- independent of it until the game confirms an actual server requirement.
 if ports==0 and coast>=1 and landFront==0 and nearbyIsland>0 and
    cities>=1 and not incoming and not recentLoss then
  add(1,"coast-island-port-option")
 end
 -- A solitary factory has no guaranteed paying connection: require City/Port.
 if factories==0 and cities+ports>0 then add(2,"first-connected-factory") end
 -- If badly outnumbered and already economically established, buy protection.
 local defenseGoal=math.max(1,math.ceil(cities/8))
 if cities>=8 and defenses<math.max(1,math.floor(cities/12)) then
  add(3,"critical-defense-deficit")
 end
 if incoming and defenses<defenseGoal and cities+factories+ports>=2 then
  add(3,"live-border-defense")
 end
 -- Important: do not pay for City after City with army at 5% fill.
 if factories>0 and (income<=1500 or factories<math.max(1,math.ceil(cities*.55))) then
  add(2,"gold-production-network-lagging")
 end
 if fill>=.72 and cities<math.max(3,math.ceil(factories*1.2)) then add(0,"approaching-troop-cap") end
 if x.autoSam~=false and nukes>0 and sams<math.max(1,math.ceil((cities+factories)/12)) and
    cities+factories>=3 then add(4,"missile-warning-protect-assets") end
 if x.autoSam~=false and sams>=1 and nuclearAlarm and
    sams<math.max(1,math.ceil((cities+factories)/16)) then
  add(4,"replace-nuclear-coverage")
 end
 if recentLoss and defenses<defenseGoal and cities+factories>=3 then
  add(3,"restore-broken-front")
 end
 -- PORT requires owned confirmed coastline and an independently observed
 -- foreign port opportunity. Same water connection is NOT established.
 -- Budget is checked against an additional buffer at purchase time.
 if mode~="DEFEND" and not incoming and not recentLoss and cities>=1 and
    factories>=1 and ports<2 and coast>=3 and foreignPorts>=1 and gold>=400000 then
  add(1,"conditional-protected-coastal-trade")
 end
 if factories>0 and cities<math.max(2,math.ceil(factories*.85)) then add(0,"balance-network-capacity") end
 if factories<cities and cities>0 then add(2,"more-connected-factory-capacity") end
 if defenses<defenseGoal and cities+factories>=3 then add(3,"frontier-coverage") end
 if x.autoSam~=false and gold>=3500000 and cities+factories>=5 and sams==0 then add(4,"mature-nuclear-insurance") end
 -- V3.1.9.4 advertised a conditional silo but had no candidate of kind 5.
 -- Keep this after the first SAM; production also needs a target and an
 -- independent codec check before it can ever launch.
 if x.autoNuke~=false and sams>=1 and silos==0 and
    cities+factories>=8 and gold>=3200000 and
    not incoming and not recentLoss then add(5,"conditional-silo-after-sam") end
 if cities>0 then add(0,"develop-capacity") end
 if cities+ports>0 then add(2,"develop-gold-network") end
 if incoming and defenses==0 and cities>0 then add(3,"emergency-basic-defense") end
 if cities==0 then add(0,"bootstrap-city") end
 return choices,defenseGoal
end
function R.nuclearCapitalGate(kind,price,gold,samGoalBudget,savingSam,emergencyDefense,bootstrap)
 return savingSam and kind~=4 and not emergencyDefense and not bootstrap and
     gold-price<samGoalBudget
end
local function pickBuildKind(s,own,counts)
 local st=s.state
 local gold=math.max(0,tonumber(own.gold) or 0)
 R.observeWorld(s)
 local p=R.currentPolicy(s)
 local coastInfo=R.ecoCoast(s)
 local fill=(tonumber(own.troops) or 0)/math.max(1,tonumber(own.max_troops) or 1)
 local nukeCount=likelyNukeThreat(st,st.local_owner)
 local enemySilos=0
 if type(st.structures)=="table" then
  for _,b in pairs(st.structures) do
   if type(b)=="table" and (tonumber(b.kind)==5 or b.kind=="silo") and
      tonumber(b.owner) and tonumber(b.owner)~=st.local_owner then
    enemySilos=enemySilos+1
   end
  end
 end
 local choices,defenseGoal=R.economyPriority({
  cities=counts[0],ports=counts[1],factories=counts[2],defenses=counts[3],
  sams=counts[4],silos=counts[5],gold=gold,income=own.income,fill=fill,mode=p.mode,
  incoming=p.activeIncoming or false,recentLoss=p.lossFraction>.25,
  nukes=nukeCount,nukesSeen=defenseAudit.nukesSeen,enemySilos=enemySilos,
  nuclearRecent=(R.world.nukeUntil or -9999)>now(),
  coast=coastInfo.owned,foreignPorts=coastInfo.foreignPorts,
  landFront=R.attackCandidates or 0,nearbyIsland=naval.nearbyTargets or 0,
  autoSam=enabled.autoSam,autoNuke=enabled.autoNuke
 })
 R.defenseGoal=defenseGoal
 R.samGoal=math.max(1,math.ceil(((counts[0] or 0)+(counts[2] or 0))/12))
 defenseAudit.samCount=counts[4] or 0
 local reserve=math.min(175000,math.max(2500,gold*.06))
 local samPrice=R.buildBudget(4,counts)
 local assetCount=(counts[0] or 0)+(counts[1] or 0)+(counts[2] or 0)
 local firstSam=(counts[4] or 0)==0 and enabled.autoSam and
     (assetCount>=8 or (assetCount>=5 and (tonumber(own.income) or 0)>=2500) or
      ((defenseAudit.nukesSeen>0 or enemySilos>0) and assetCount>=3) or
      ((R.world.nukeUntil or -9999)>now() and assetCount>=3))
 local savingSam=firstSam and gold>=350000 and
     now()>=(construction.kindRetry and construction.kindRetry[4] or 0)
 local samGoalBudget=samPrice+math.max(50000,reserve)
 -- For a speculative port preserve more gold than for the first City/Factory.
 local available={};local notes={}
 for _,row in ipairs(choices) do
  local kind,reason=row[1],row[2]
  local price,source=R.buildBudget(kind,counts)
  local keep=kind==1 and math.max(reserve,math.min(250000,price*.25)) or reserve
  if kind==0 and (counts[0] or 0)==0 and fill>=.85 and not p.activeIncoming then
   keep=0 -- Break the observed troop-cap stall as soon as the first city is affordable.
  end
  local retry=construction.kindRetry and construction.kindRetry[kind] or 0
  -- Until the first SAM is funded, avoid another expensive factory/city
  -- consuming the same capital. A cheap emergency Defense remains possible.
  local emergencyDefense=kind==3 and p.activeIncoming and
      (counts[3] or 0)<math.max(1,math.ceil((counts[0] or 0)/8))
  local bootstrap=kind==0 and (counts[0] or 0)==0 or
      kind==2 and (counts[2] or 0)==0
  local capitalLocked=R.nuclearCapitalGate(kind,price,gold,samGoalBudget,
      savingSam,emergencyDefense,bootstrap)
  if now()>=retry and gold-price>=keep and not capitalLocked then
   available[#available+1]={kind=kind,reason=reason,price=price,source=source,reserve=keep}
  else
   notes[#notes+1]=KIND_NAME[kind]..(now()<retry and ":backoff" or
      capitalLocked and ":saving-first-sam="..math.floor(samGoalBudget) or
      ":need="..math.floor(price+keep))
  end
 end
 R.economyAudit={mode=p.mode,fill=fill,coast=coastInfo.owned,
  coastStatus=coastInfo.status,coastChecked=coastInfo.checked,
  foreignPorts=coastInfo.foreignPorts,candidates=#available,
  first=available[1] and KIND_NAME[available[1].kind] or "none",
  priority=available[1] and available[1].reason or "saving-or-backoff",
  samSavings=savingSam,samTarget=firstSam and samGoalBudget or 0,
  nukesSeen=defenseAudit.nukesSeen,enemySilos=enemySilos,silos=counts[5] or 0}
 R.buildPolicy="V31914 bottleneck-first:"..p.mode.." income="..tostring(own.income).." troop-fill="..string.format("%.2f",fill)
 construction.lastPrice=available[1] and ("budget="..available[1].price.." source="..available[1].source.." gold="..math.floor(gold).." reserve="..math.floor(available[1].reserve)) or table.concat(notes,"; ")
 if available[1] then return available[1].kind,available[1].reason,available end
 return nil,"saving-or-kind-backoff-"..p.mode,available
end
local function selectBuildTile(s,id,kind,blocked)
if (R.structuresUnlocated or 0)>0 then return nil,"structure-location-schema-unverified" end
local st=s.state
local ownerAt=tileReader(st)
if not ownerAt then return nil,"owner-buffer-unreadable" end
if not landCache.ready or landCache.mapRef~=st.map then return nil,"waiting-land-index" end
local w,n=tonumber(st.W),tonumber(st.N)
if not w or not n or w<1 then return nil,"map-dimensions-unreadable" end
local own=select(2,myOwner(s))
local spawn=own and tonumber(own.spawn_tile) or -1
local search,seen,picks={}, {}, {}
if spawn and spawn>=0 and spawn<n then
search[1]=math.floor(spawn);seen[math.floor(spawn)]=true
end
local i=1
while i<=#search and #search<1800 do
local cell=search[i];i=i+1
if ownerAt(cell)==id then
picks[#picks+1]=cell
for _,adj in ipairs(neighbours(cell,w,n)) do
if not seen[adj] and ownerAt(adj)==id then
seen[adj]=true;search[#search+1]=adj
end
end
end
end
local landAt,count=landTiles(st)
if landAt then
local m=math.min(count,2100)
local seed=(math.floor(now()*101)+(tonumber(st.tick) or 0))%count
for j=0,m-1 do
local tile=landAt((seed+math.floor((j+0.5)*count/m))%count)
if tile and not seen[tile] and ownerAt(tile)==id then
seen[tile]=true;picks[#picks+1]=tile
end
end
end
if ownerScan.ready and ownerScan.mapRef==st.map and ownerScan.owner==id then
for _,tile in ipairs(ownerScan.tiles) do
 if not seen[tile] and ownerAt(tile)==id then picks[#picks+1]=tile;seen[tile]=true end
end
end
if #picks==0 then return nil,"no-owned-tiles" end
if #picks>3600 or kind==1 then
 local pool=picks
 local bounded,added={},{}
 local function addCandidate(t)
  if t and not added[t] and ownerAt(t)==id then
   added[t]=true;bounded[#bounded+1]=t
  end
 end
 for i=1,math.min(#pool,1000) do addCandidate(pool[i]) end
 local total=math.min(2500,#pool)
 for j=1,total do
  local at=math.max(1,math.min(#pool,math.floor((j-.5)*#pool/total)+1))
  addCandidate(pool[at])
 end
 if kind==1 then
  local coasts=R.ecoCoast(s)
  local inspected=0
  for t in pairs(coasts.tiles) do
   addCandidate(t);inspected=inspected+1
   if inspected>=500 then break end
  end
 end
 picks=bounded
end
local assets,samLocations={},{}
local econStations={}
local coastInfo=(kind==1) and R.ecoCoast(s) or nil
if type(st.structures)=="table" then
for key,b in pairs(st.structures) do
if type(b)=="table" and tonumber(b.owner)==id then
local loc=tileOf(b,st)
local kindId=tonumber(b.kind)
if not kindId then for k,name in pairs(KIND_NAME) do if name==b.kind then kindId=k;break end end end
if loc and (kindId==0 or kindId==1) then econStations[#econStations+1]=loc end
if loc and kindId==4 then samLocations[#samLocations+1]=loc end
if loc and (kindId==0 or kindId==1 or kindId==2 or kindId==5) then
assets[#assets+1]={tile=loc,weight=kindId==0 and 4 or kindId==5 and 4 or 3}
end
end
end
end
if #assets==0 and spawn and spawn>=0 then assets[1]={tile=spawn,weight=4} end
local best,bestScore=nil,-math.huge
local inspected=0
local function dist2(a,b)
local dx=(a%w)-(b%w)
local dy=math.floor(a/w)-math.floor(b/w)
return dx*dx+dy*dy
end
local placementBins={}
for occupied in pairs(blocked) do
 local key=math.floor((occupied%w)/20)..":"..math.floor(math.floor(occupied/w)/20)
 placementBins[key]=placementBins[key] or {};table.insert(placementBins[key],occupied)
end
for _,tile in ipairs(picks) do
if isVerifiedLand(st,tile)==true and not blocked[tile] and ownerAt(tile)==id and (construction.avoided[tile] or 0)<=now() and
 not (construction.recentlyBuilt and construction.recentlyBuilt[tile] and now()-construction.recentlyBuilt[tile]<125) then
local nearestStructure=math.huge
local gx,gy=math.floor((tile%w)/20),math.floor(math.floor(tile/w)/20)
for yy=gy-1,gy+1 do for xx=gx-1,gx+1 do
 for _,occupied in ipairs(placementBins[xx..":"..yy] or {}) do nearestStructure=math.min(nearestStructure,dist2(tile,occupied)) end
end end
local friendly,enemy=0,0
for _,near in ipairs(neighbours(tile,w,n)) do
local o=ownerAt(near)
if o==id then friendly=friendly+1
elseif type(o)=="number" and o~=0 and o~=255 and o~=65535 and o~=4294967295 then
enemy=enemy+1
end
end
local score
if kind==4 then
score=friendly*0.7-enemy*0.2
local protected,overlap=0,0
for _,asset in ipairs(assets) do
local d=dist2(tile,asset.tile)
if d<=70*70 then protected=protected+asset.weight*(1-math.sqrt(d)/100) end
end
for _,prior in ipairs(samLocations) do
if dist2(tile,prior)<105*105 then overlap=overlap+8 end
end
score=score+protected*6-overlap
-- Coverage is a placement heuristic, not a verified interception radius.
elseif kind==3 then
score=enemy*15+friendly*0.5
else
-- Put economic buildings behind the active border when possible. The
-- previous score barely penalized an adjacent hostile cell (four points).
score=friendly*7-enemy*((kind==0 or kind==2 or kind==5) and 120 or 4)
for _,asset in ipairs(assets) do
local d=dist2(tile,asset.tile)
if d<25*25 then score=score+0.5 end
end
end
if spawn and spawn>=0 then score=score-math.sqrt(dist2(tile,spawn))/65 end
-- Soft spacing preference only; actual minimum placement distance remains unverified.
if nearestStructure<15*15 then score=score-400-(15-math.sqrt(nearestStructure))*24
elseif nearestStructure<24*24 then score=score-(24-math.sqrt(nearestStructure))*3 end
score=score+(tile%103)*0.0001
-- Factory: never throw 125k-1m gold at an isolated factory with no
-- potential city/port station in range. Alignment is a HEURISTIC only.
if kind==2 then
 local connection=-math.huge
 for _,station in ipairs(econStations) do
  local dx=math.abs((tile%w)-(station%w))
  local dy=math.abs(math.floor(tile/w)-math.floor(station/w))
  local d=math.sqrt(dx*dx+dy*dy)
  if d>=15 and d<=110 then
   local alignment=math.min(dx,dy)<=7 and 18 or 0
   connection=math.max(connection,90-d*.25+alignment)
  end
 end
 if connection==-math.huge then score=-math.huge else score=score+connection end
elseif kind==1 then
 -- Coast_list entries provide a real coast candidate; no speculative water.
 -- Refuse shore tiles adjacent to an opposing owner (too easy to lose port).
 if not coastInfo or not coastInfo.tiles[tile] or enemy>0 then
  score=-math.huge
 else
  score=score+25+math.min(25,#econStations*2)
 end
end
if score>bestScore then best,bestScore=tile,score; if kind==4 then defenseAudit.samCoverage="heuristic-score="..string.format("%.1f",score) end end
inspected=inspected+1
end
end
construction.inspected=inspected
return best,best and "candidate-heuristic" or "no-unblocked-owned-tiles"
end
local function makeCandidate(kind,tile,which)
local name=KIND_NAME[kind]
local variant=which or 1
if variant==1 then return {type="build", tile=tile, kind=kind}, "kind-int" end
if variant==2 then return {type="build", tile=tile, kind=name}, "kind-name" end
if variant==3 then return {type="build", tile=tile, structure=kind}, "structure-int" end
if variant==4 then return {type="build", tile=tile, structure=name}, "structure-name" end
if variant==5 then return {type="build", tile=tile, unit=kind}, "unit-int" end
if variant==6 then return {type="build", tile=tile, unit=name}, "unit-name" end
if variant==7 then return {type="build", tile=tile, building=kind}, "building-int" end
if variant==8 then return {type="build", tile=tile, building=name}, "building-name" end
if variant==9 then return {type="build", tile=tile, struct_kind=kind}, "struct_kind-int" end
if variant==10 then return {type="build", tile=tile, unit_kind=kind}, "unit_kind-int" end
if variant==11 then return {type="build", tile=tile, kind=kind, level=1}, "kind-level" end
if variant==12 then return {type="build", tile=tile, build_kind=kind}, "build_kind-int" end
if variant==13 then return {type="build", tile=tile, structure_type=kind}, "structure_type-int" end
return nil,nil
end
local function safeEncodeDecode(intent)
if type(protocol)~="table" or type(protocol.encode_intent)~="function" or
type(protocol.decode_intent)~="function" then return nil,"codec-unavailable" end
local ok, encoded=pcall(protocol.encode_intent,intent)
if not ok or encoded==nil then return nil,"encode-failed" end
local good, decoded=pcall(protocol.decode_intent,encoded)
if not good or type(decoded)~="table" then return nil,"decode-failed" end
return decoded,nil
end
local function buildRoundTrip(decoded, kind, tile)
if not decoded or decoded.type~="build" then return false end
local gotTile=tonumber(decoded.tile or decoded.at or decoded.pos or decoded.cell)
if not gotTile or gotTile~=tile then return false end
for _,field in ipairs({"kind","structure","building","unit","struct_kind","unit_kind","build_kind","structure_type","unit_type"}) do
local v=decoded[field]
if v~=nil and (v==kind or v==KIND_NAME[kind] or tonumber(v)==kind) then
return true
end
end
return false
end
local function tryBuild(s,kind,tile)
for _,variant in ipairs({2}) do
local intent,label=makeCandidate(kind,tile,variant)
if intent then
local decoded,err=safeEncodeDecode(intent)
if variant==1 or variant==2 or variant==4 or variant==12 then
local keys={}
if type(decoded)=="table" then
for k,v in pairs(decoded) do
if type(v)=="string" or type(v)=="number" or type(v)=="boolean" then
keys[#keys+1]=tostring(k).."="..str(v,30)
else
keys[#keys+1]=tostring(k)..":"..type(v)
end
if #keys >= 12 then break end
end
end
construction.samples[variant]=str(label.." => "..(err or table.concat(keys,",")),240)
end
if buildRoundTrip(decoded,kind,tile) then
construction.schema=label
local ok=sendIntent("build",intent)
if ok then
construction.latest="sent "..KIND_NAME[kind].."@"..tile.." via "..label
log("Build request "..KIND_NAME[kind].." tile="..tile.." via "..label.." (awaiting confirmation)")
return true
end
construction.latest="build not sent: "..R.block
log(construction.latest,true)
return false
end
end
end
construction.schema="no-matching-roundtrip"
construction.latest="Build codec cannot verify kind+tile; 0 packets sent"
if not construction.schemaWarned then
construction.schemaWarned=true
log(construction.latest)
end
return false
end
local function checkPending(s)
local pending=construction.pending
if not pending then return end
local st=s.state
if type(st)~="table" or st.phase~=1 then return end
local id=tonumber(st.local_owner)
local counts=structureInfo(st,id)
local foundAtTile=false
if type(st.structures)=="table" then
for key,b in pairs(st.structures) do
if type(b)=="table" then
local tile=tileOf(b,st)
if tile==pending.tile and tonumber(b.owner)==id and
(tonumber(b.kind)==pending.kind or b.kind==KIND_NAME[pending.kind]) then
foundAtTile=true;break
end
end
end
end
if foundAtTile then
R.observed("build","structure-at-requested-tile",st,pending.tile)
attempted.buildConfirmed=attempted.buildConfirmed+1
construction.recentlyBuilt=construction.recentlyBuilt or {}
construction.recentlyBuilt[pending.tile]=now()
construction.latest="OBSERVED AT REQUESTED TILE: "..KIND_NAME[pending.kind]
construction.lastObserved=construction.latest
log(construction.latest.." (server attribution not guaranteed)")
construction.pending=nil
if construction.failures then construction.failures[pending.kind]=0 end
if construction.kindRetry then construction.kindRetry[pending.kind]=nil end
construction.schemaWarned=false
elseif now()-pending.at>12 then
R.timedOut("build",pending.tile)
attempted.buildDenied=attempted.buildDenied+1
construction.avoided[pending.tile]=now()+200
local countChange=(counts[pending.kind] or 0)>pending.previousCount
construction.lastObserved="UNCONFIRMED "..KIND_NAME[pending.kind].." @"..pending.tile..
(countChange and " (kind count changed elsewhere)" or " (no matching tile)")
log(construction.lastObserved)
construction.pending=nil
construction.failures=construction.failures or {};construction.kindRetry=construction.kindRetry or {}
construction.failures[pending.kind]=(construction.failures[pending.kind] or 0)+1
construction.kindRetry[pending.kind]=now()+math.min(180,30*construction.failures[pending.kind])
construction.retryAt=0
end
end
local function autoBuild(s)
if not enabled.autoBuild or not s or not s.state or s.state.phase~=1 or s.paused==true then return end
checkPending(s)
if construction.pending then return end
if now()<(construction.retryAt or 0) then return end
if now()-lastAction.build<8 then return end
local id,own=myOwner(s)
if not id or not own then return end
if type(own.gold)~="number" then construction.latest="owner gold unreadable";return end
local counts,blocked=structureInfo(s.state,id)
construction.counts=counts
local kind,reason,candidates=pickBuildKind(s,own,counts)
if not kind then construction.latest="Wait: "..reason.."; "..construction.lastPrice;return end
local tile,why=nil,"no-valid-placement"
local tried={}
-- A high-priority factory may have NO CONNECTED SITE. If so use the next
-- affordable option instead of freezing the entire economy for 10 minutes.
for i=1,math.min(4,#candidates) do
 local candidate=candidates[i]
 local found,reasonTile=selectBuildTile(s,id,candidate.kind,blocked)
 if found then
  kind,reason,tile=candidate.kind,candidate.reason,found
  R.buildPriceSource=candidate.source;R.buildPriceValue=candidate.price
  construction.lastPrice="budget="..candidate.price.." source="..candidate.source.." gold="..math.floor(tonumber(own.gold) or 0)
  break
 end
 tried[#tried+1]=KIND_NAME[candidate.kind]..":"..tostring(reasonTile)
end
if not tile then construction.latest="Build blocked by placement: "..table.concat(tried,";");return end
lastAction.build=now()
construction.latest="decision="..KIND_NAME[kind].." reason="..reason.." tile="..tile
local sent=tryBuild(s,kind,tile)
if sent then
construction.pending={kind=kind,tile=tile,previousCount=counts[kind] or 0,at=now(),reason=reason}
else
construction.avoided[tile]=now()+60
construction.kindRetry=construction.kindRetry or {};construction.kindRetry[kind]=now()+30
end
end
local allianceAudit={seen=0,candidates=0,waiting=0,sent=0,observed=0,
last="not-scanned", schema="not-confirmed", sample="none", pending=nil}
local function describeRequest(request)
if type(request)~="table" then return type(request) end
local fields={}
for key,value in pairs(request) do
fields[#fields+1]=str(key,22)..":"..type(value)
if #fields>=15 then break end
end
table.sort(fields)
return table.concat(fields,",")
end
function R.requestShape(requests)
if type(requests)~="table" then return type(requests) end
local rows={}
for k,v in pairs(requests) do
local key=type(k)=="number" and tostring(k) or type(k)
local value=type(v)=="number" and tostring(v) or describeRequest(v)
rows[#rows+1]=key.."="..value
if #rows>=8 then break end
end
return table.concat(rows,"; ")
end
local visibleAlliance={at=-9999,names={},seen=0,scan="not-scanned"}
local function visibleInvitationOwners(st)
 if now()-visibleAlliance.at<5 then return visibleAlliance.names end
 visibleAlliance.at=now();visibleAlliance.names={};visibleAlliance.seen=0
 local pg=player:FindFirstChildOfClass("PlayerGui")
 if not pg then visibleAlliance.scan="PlayerGui-unavailable";return visibleAlliance.names end
 local ok,children=pcall(function() return pg:GetDescendants() end)
 if not ok then visibleAlliance.scan="descendants-unavailable";return visibleAlliance.names end
 local messages={}
 for i,obj in ipairs(children) do
  if i>5500 then break end
  if (obj:IsA("TextLabel") or obj:IsA("TextButton")) and type(obj.Text)=="string" then
   local t=obj.Text:lower()
   local name=t:match("([%w_ %-]+)%s+wants an alliance")
   if name then messages[#messages+1]=name:gsub("^%s+",""):gsub("%s+$","");visibleAlliance.seen=visibleAlliance.seen+1 end
  end
 end
 for id,o in pairs(type(st.owners)=="table" and st.owners or {}) do
  if type(o)=="table" then
   local n=tostring(o.name or o.display_name or o.country or ""):lower()
   if #n>=2 then
    for _,txt in ipairs(messages) do
     if txt:find(n,1,true) then visibleAlliance.names[tonumber(id) or id]=true end
    end
   end
  end
 end
 visibleAlliance.scan="UI-text-matches="..tostring(visibleAlliance.seen)
 return visibleAlliance.names
end
local function requestSender(request,key,st)
 local me=st.local_owner
 if type(request)=="table" then
  local sender=tonumber(request.from_owner or request.requester or request.from or request.sender)
  local receiver=tonumber(request.to_owner or request.receiver or request.to or request.target_owner)
  if sender and not receiver and visibleInvitationOwners(st)[sender] then receiver=me end
  return sender,receiver
 end
 -- Some versions use numeric relationships. Numeric direction is ambiguous,
 -- so require an independently visible '<name> wants an alliance' notice.
 if type(request)=="number" or type(request)=="string" then
  local a,b=tonumber(key),tonumber(request)
  if a and b and a~=b and (a==me or b==me) then
   local sender=a==me and b or a
   if visibleInvitationOwners(st)[sender] then return sender,me end
  end
 end
 return nil,nil
end
local function isAttackingUs(s,sender)
local st=s.state
if type(st.attacks)~="table" then return false end
for _,a in pairs(st.attacks) do
if type(a)=="table" then
local attacker=tonumber(a.attacker or a.from_owner or a.owner)
local defender=tonumber(a.defender or a.to_owner or a.target_owner)
if attacker==sender and defender==st.local_owner then return true end
end
end
return false
end
local function nearOurBorder(st,sender,id)
local ownerAt=tileReader(st)
local at,total=landTiles(st)
if not ownerAt or not at or not st.W then return false end
local m=math.min(total,1600)
for i=0,m-1 do
local tile=at(math.floor((i+0.5)*total/m))
if tile and ownerAt(tile)==id then
for _,other in ipairs(neighbours(tile,st.W,st.N)) do
if ownerAt(other)==sender then return true end
end
end
end
return false
end
local function verifiedAllyReply(sender,request)
local candidates={
{type="ally_reply",from=sender,accept=true},
{type="ally_reply",to=sender,accept=true},
{type="ally_reply",target=sender,accept=true},
{type="ally_reply",owner=sender,accept=true},
{type="ally_reply",requester=sender,accept=true},
}
for index,intent in ipairs(candidates) do
local decoded=safeEncodeDecode(intent)
if type(decoded)=="table" and decoded.type=="ally_reply" then
local idOK=false
for _,k in ipairs({"from","to","target","owner","requester","from_owner","to_owner"}) do
if tonumber(decoded[k])==sender then idOK=true;break end
end
local acceptOK=(decoded.accept==true or decoded.accepted==true or decoded.response=="accept")
if idOK and acceptOK and probeIntent("ally_reply",intent) then return intent,"variant-"..index end
end
end
return nil,"codec-has-no-verified-ally-reply-schema"
end
local function checkAllyPending(st)
local pending=allianceAudit.pending
if not pending then return end
if ownerAllied(st,st.local_owner,pending.sender) then
R.observed("ally_reply","alliance-state-changed",st)
attempted.allyObserved=attempted.allyObserved+1
allianceAudit.observed=attempted.allyObserved
allianceAudit.last="alliance-observed-for-"..pending.sender
allianceAudit.pending=nil
log("Alliance appeared in game state (attribution unverified)")
elseif now()-pending.since>30 then
R.timedOut("ally_reply")
attempted.allyUnconfirmed=attempted.allyUnconfirmed+1
allianceAudit.last="alliance-reply-not-confirmed"
allianceAudit.pending=nil
end
end
local function autoAlliance(s)
if not enabled.autoAlliance or type(s.state)~="table" or s.state.phase~=1 then return end
local st=s.state
local id,own=myOwner(s)
if not id then return end
checkAllyPending(st)
if allianceAudit.pending then return end
local allies=type(st.alliances)=="table" and (st.alliances[id] or st.alliances[tostring(id)])
local allyCount=0
if type(allies)=="table" then for _,value in pairs(allies) do if value==true then allyCount=allyCount+1 end end end
if allyCount>=6 then allianceAudit.last="six-ally-policy-cap-not-game-rule";return end
local requests=st.requests
if type(requests)~="table" then requests={};allianceAudit.last="requests-unavailable-using-UI-evidence" end
local firstCandidate=nil
local seen=0
allianceAudit.candidates=0
allianceAudit.sample="none"
local unsupported=0
for key,request in pairs(requests) do
seen=seen+1
if allianceAudit.sample=="none" then allianceAudit.sample=describeRequest(request) end
local sender,receiver=requestSender(request,key,st)
if not sender or not receiver then unsupported=unsupported+1 end
if sender and receiver==id and sender~=id and not ownerAllied(st,id,sender) then
local isRecord=type(request)=="table"
local cancelled=isRecord and (request.cancelled==true or request.rejected==true or request.closed==true) or false
local pending=isRecord and (request.pending==false or request.active==false) or false
if not cancelled and not pending then
allianceAudit.candidates=allianceAudit.candidates+1
local enemy=type(st.owners)=="table" and st.owners[sender] or nil
local myTroops=tonumber(own.troops) or 0
local enemyTroops=type(enemy)=="table" and (tonumber(enemy.troops) or 0) or 0
local useful=visibleInvitationOwners(st)[sender] or nearOurBorder(st,sender,id) or enemyTroops>=myTroops*0.35
if useful and not isAttackingUs(s,sender) then
firstCandidate={sender=sender,request=request};break
else
allianceAudit.last="request-not-beneficial-or-hostile"
end
end
end
end
allianceAudit.seen=seen
-- UI-confirmed invitations may exist while state.requests is empty or encoded in
-- a client-specific numeric shape. A verified visible owner can be considered,
-- but the outgoing packet is still codec-gated and awaits state confirmation.
if not firstCandidate then
 local visible=visibleInvitationOwners(st)
 for sender,present in pairs(visible) do
  sender=tonumber(sender)
  if present and sender and sender~=id and not ownerAllied(st,id,sender) and
     not isAttackingUs(s,sender) then
   firstCandidate={sender=sender,request=nil}
   allianceAudit.last="candidate-from-visible-invitation"
   allianceAudit.candidates=allianceAudit.candidates+1
   break
  end
 end
end
if not firstCandidate then
if seen==0 then allianceAudit.last="no-requests"
elseif unsupported>0 then allianceAudit.last="unsupported-request-schema:"..unsupported end
return
end
if now()-lastAction.ally<45 then return end
local intent,schema=verifiedAllyReply(firstCandidate.sender,firstCandidate.request)
allianceAudit.schema=schema
if not intent then
allianceAudit.last="read-request-but-unsupported-codec"
return
end
lastAction.ally=now()
local ok=sendIntent("ally_reply",intent)
if ok then
attempted.ally=attempted.ally+1
allianceAudit.sent=attempted.ally
allianceAudit.last="ally-reply-sent-unconfirmed"
allianceAudit.pending={sender=firstCandidate.sender,since=now()}
log("Alliance reply sent; awaiting game state confirmation")
else
allianceAudit.last="ally-reply-call-rejected"
log("Alliance reply blocked: "..R.block,true)
end
end
naval = { scanned=0, myCoast=0, targetCoast=0, nearbyTargets=0,
 coastCoverage="not-scanned", schema="untested",
reason="awaiting-map", pending=nil, avoidUntil={}, last="none", capture="none" }
local function coastalList(st)
if type(st)~="table" or type(st.map)~="table" then return nil,"map-unavailable" end
local m=st.map
if typeof(m.coast_list)~="buffer" or type(m.coast_count)~="number" then
return nil,"coast-list-unavailable"
end
if not buffer or type(buffer.len)~="function" or type(buffer.readi32)~="function" then
return nil,"coast-buffer-api-unavailable"
end
local ok,len=pcall(buffer.len,m.coast_list)
if not ok or len<4 then return nil,"invalid-coast-buffer" end
local count=math.min(math.floor(len/4),math.floor(m.coast_count))
if count<1 or count>3000000 then return nil,"invalid-coast-count" end
return function(idx)
if idx<0 or idx>=count then return nil end
local success,tile=pcall(buffer.readi32,m.coast_list,idx*4)
if success and type(tile)=="number" and tile>=0 and tile<(st.N or 0) then
return tile
end
return nil
end,count
end
local function coastalCandidates(s)
local st=s.state
local at,count=coastalList(st)
if not at then return nil,count end
local ownerAt=tileReader(st)
if not ownerAt then return nil,"tile-owner-unavailable" end
local me=st.local_owner
if type(me)~="number" or type(st.W)~="number" then return nil,"owner-or-map-width-unavailable" end
local sources,targets={},{}
local sourceSeen,nearbySeen=0,0
local minX,maxX,minY,maxY=math.huge,-math.huge,math.huge,-math.huge
local epoch,map=R.epoch,st.map
-- Read the complete client coast list in cooperative batches. Owner values
-- can change during scanning; this is a best-effort client snapshot.
for i=0,count-1 do
 local tile=at(i)
 if tile and isVerifiedLand(st,tile)==true and ownerAt(tile)==me then
  sourceSeen=sourceSeen+1
  local x,y=tile%st.W,math.floor(tile/st.W)
  minX=math.min(minX,x);maxX=math.max(maxX,x)
  minY=math.min(minY,y);maxY=math.max(maxY,y)
  if #sources<130 then sources[#sources+1]=tile else
   local slot=(tile*1103515245+sourceSeen*12345)%sourceSeen+1
   if slot<=130 then sources[slot]=tile end
  end
 end
 if i%4096==4095 then
  task.wait()
  if not alive or R.epoch~=epoch or st.map~=map then return nil,"coast-context-changed" end
 end
end
naval.scanned=count;naval.myCoast=sourceSeen
if #sources==0 then naval.targetCoast=0;naval.nearbyTargets=0;return {sources=sources,targets=targets},"no-owned-coast" end
local heap={}
local function worse(a,b) return a.dist2>b.dist2 end
local function offer(item)
 if #heap<1800 then
  heap[#heap+1]=item;local i=#heap
  while i>1 do local p=math.floor(i/2);if not worse(heap[i],heap[p]) then break end
   heap[i],heap[p]=heap[p],heap[i];i=p end
 elseif worse(heap[1],item) then
  heap[1]=item;local i=1
  while i*2<=#heap do local c=i*2
   if c+1<=#heap and worse(heap[c+1],heap[c]) then c=c+1 end
   if not worse(heap[c],heap[i]) then break end
   heap[c],heap[i]=heap[i],heap[c];i=c
  end
 end
end
for i=0,count-1 do
 local tile=at(i)
 if tile and isVerifiedLand(st,tile)==true then
  local x,y=tile%st.W,math.floor(tile/st.W)
  if x>=minX-100 and x<=maxX+100 and y>=minY-100 and y<=maxY+100 then
   local id=ownerAt(tile)
   if type(id)=="number" and id~=me and not ownerAllied(st,me,id) and
      (naval.avoidUntil[tile] or 0)<now() then
    local d2=math.huge
    for _,src in ipairs(sources) do
     local dx=x-src%st.W;local dy=y-math.floor(src/st.W)
     d2=math.min(d2,dx*dx+dy*dy)
    end
    if d2>4 and d2<=10000 then
     nearbySeen=nearbySeen+1;offer({tile=tile,owner=id,dist2=d2})
    end
   end
  end
 end
 if i%4096==4095 then
  task.wait()
  if not alive or R.epoch~=epoch or st.map~=map then return nil,"coast-context-changed" end
 end
end
table.sort(heap,function(a,b) return a.dist2<b.dist2 end)
naval.targetCoast=#heap;naval.nearbyTargets=nearbySeen
naval.coastCoverage="complete-client-coast-list-nonatomic; sources="..sourceSeen
return {sources=sources,targets=heap},"ok"
end
-- Goal-directed A*, bounded and cooperative. Terrain connectivity is not a server ACK.
function R.waterRoute(st,target,sources)
 if isVerifiedLand(st,target)~=true then return false,"target-not-land" end
 -- V31914 full water map rejects disconnected oceans; it cannot prove
 -- range/cost/server boat acceptance. Keep local route validation below.
 local marine,marineWhy=R.seaConnected(st,target,sources)
 if marine==false then return false,"global-ocean-disconnected:"..marineWhy end
 -- Fast safe-path heuristic: accept only an all-water ray between a verified
 -- owned coastal source and the target shoreline; otherwise run original A*.
 -- This proves map connectivity only, never a legal server route.
 local tx,ty=target%st.W,math.floor(target/st.W)
 for _,src in ipairs(sources) do
  local sx,sy=src%st.W,math.floor(src/st.W)
  local dx,dy=tx-sx,ty-sy
  if math.abs(dx)+math.abs(dy)>=3 and math.abs(dx)+math.abs(dy)<=85 then
   -- Two orthogonal water-only L routes. Each intermediate cell is tested,
   -- unlike a diagonal raster line that can cut through impassable corners.
   for _,xFirst in ipairs({true,false}) do
    local x,y=sx,sy
    local throughWater=true
    for segment=1,2 do
     local toX=(segment==1 and (xFirst and tx or sx)) or tx
     local toY=(segment==1 and (xFirst and sy or ty)) or ty
     while throughWater and x~=toX do
      x=x+(toX>x and 1 or -1)
      if not (x==tx and y==ty) and isVerifiedLand(st,y*st.W+x)~=false then throughWater=false end
     end
     while throughWater and y~=toY do
      y=y+(toY>y and 1 or -1)
      if not (x==tx and y==ty) and isVerifiedLand(st,y*st.W+x)~=false then throughWater=false end
     end
    end
    if throughWater and x==tx and y==ty then
     R.routeExpanded=0;return true,"verified-L-shaped-water-path; server-unverified",src
    end
   end
  end
 end
 local goals={};local goalSet={}
 for _,t in ipairs(neighbours(target,st.W,st.N)) do
  if isVerifiedLand(st,t)==false then goals[#goals+1]=t;goalSet[t]=true end
 end
 if #goals==0 then return false,"target-has-no-adjacent-water" end
 local epoch=R.epoch;local map=st.map
 local function heuristic(t)
  local best=math.huge;local x,y=t%st.W,math.floor(t/st.W)
  for _,g in ipairs(goals) do best=math.min(best,math.abs(x-g%st.W)+math.abs(y-math.floor(g/st.W))) end
  return best
 end
 local heap={};local distance={};local origin={}
 local function before(a,b) return a.f<b.f or (a.f==b.f and a.g>b.g) end
 local function push(row)
  heap[#heap+1]=row;local i=#heap
  while i>1 do local p=math.floor(i/2);if not before(heap[i],heap[p]) then break end;heap[i],heap[p]=heap[p],heap[i];i=p end
 end
 local function pop()
  local first=heap[1];local last=table.remove(heap)
  if #heap>0 then
   heap[1]=last;local i=1
   while i*2<=#heap do
    local c=i*2;if c+1<=#heap and before(heap[c+1],heap[c]) then c=c+1 end
    if not before(heap[c],heap[i]) then break end
    heap[c],heap[i]=heap[i],heap[c];i=c
   end
  end
  return first
 end
 for _,src in ipairs(sources) do
  for _,tile in ipairs(neighbours(src,st.W,st.N)) do
   if isVerifiedLand(st,tile)==false and distance[tile]==nil then
    distance[tile]=0;origin[tile]=src;push({tile=tile,g=0,f=heuristic(tile)})
   end
  end
 end
 local expanded,pops=0,0
 while #heap>0 and expanded<10000 and pops<20000 do
  local item=pop();local tile=item.tile;pops=pops+1
  if item.g==distance[tile] then
   expanded=expanded+1
   if goalSet[tile] then R.routeExpanded=expanded;return true,"water-connected-Astar; game-route-unverified",origin[tile] end
   for _,adj in ipairs(neighbours(tile,st.W,st.N)) do
    if isVerifiedLand(st,adj)==false then
     local g=item.g+1
     if distance[adj]==nil or g<distance[adj] then distance[adj]=g;origin[adj]=origin[tile];push({tile=adj,g=g,f=g+heuristic(adj)}) end
    end
   end
  end
  if pops%256==0 then
   task.wait()
   if not alive or suspended or not enabled.autoBoat or R.epoch~=epoch or not session or not session.state or session.state.map~=map then return false,"context-changed-during-route-check" end
  end
 end
 R.routeExpanded=expanded
 return false,#heap>0 and "route-search-budget-exhausted" or "no-connected-water-route"
end

local function chooseBoatTarget(s,own)
local coast,why=coastalCandidates(s)
if not coast then return nil,why end
if #coast.sources==0 then return nil,"no-owned-coast-in-client-list" end
if #coast.targets==0 then return nil,"no-nearby-target-coast" end
local st=s.state
local ownerAt=tileReader(st)
local w=st.W
local best,bestScore=nil,-math.huge
local ranked={}
local ourTroops=tonumber(own.troops) or 0
for _,candidate in ipairs(coast.targets) do
local tile,other=candidate.tile,candidate.owner
local enemy=type(st.owners)=="table" and
(st.owners[other] or st.owners[tostring(other)]) or nil
local enemyTroops=type(enemy)=="table" and tonumber(enemy.troops) or nil
local neutral=R.vacant(st,other)
local tribe=type(enemy)=="table" and tonumber(enemy.kind)==1
local allowedOccupied=false
if not neutral then
 allowedOccupied=R.occupiedEngagementGate({army=ourTroops,
  cap=own.max_troops,enemy=enemyTroops,tribe=tribe,
  cities=(construction.counts and construction.counts[0]) or 0,
  factories=(construction.counts and construction.counts[2]) or 0,
  incoming=R.world.incoming,
  recentLoss=now()<(R.world.emergencyUntil or -9999),
  recentSevereLoss=(R.world.peakOwned or 0)>=80 and
       (R.world.lastOwned or 0)<(R.world.peakOwned or 0)*.65 or
       now()-(R.world.troopCrashAt or -9999)<150,
  nuclearActive=now()<(R.world.nukeUntil or -9999),
  retaliation=false})
end
if neutral or allowedOccupied then
local minDist2=candidate.dist2
if minDist2>2*2 and minDist2<math.max(390,math.min(1200,w*.6))^2 then
local nearbyNeutral,waterSides=0,0
for _,around in ipairs(neighbours(tile,w,st.N)) do
local land=isVerifiedLand(st,around)
local id=ownerAt(around)
if land==true and R.vacant(st,id) then nearbyNeutral=nearbyNeutral+1 end
if land==false then waterSides=waterSides+1 end
end
local dist=math.sqrt(minDist2)
local islandBonus=(neutral or tribe) and waterSides>=2 and (waterSides-1)*12 or 0
local score=(neutral and 130 or tribe and 100 or 35)
+nearbyNeutral*4+islandBonus+((not neutral and nearbyNeutral<=1) and 18 or 0)-dist*0.12
if enemyTroops then
score=score-math.min(45,enemyTroops/math.max(1,ourTroops)*65)
end
local item={tile=tile,targetOwner=other,neutral=neutral,tribe=tribe,
enemyTroops=enemyTroops,ourTroops=ourTroops,dist=dist,score=score}
ranked[#ranked+1]=item
table.sort(ranked,function(a,b) return a.score>b.score end)
if #ranked>8 then table.remove(ranked) end
best=ranked[1]
end
end
end
if not best then return nil,"no-safe-water-access-candidate" end
local finalReason="no-connected-water-route"
for _,candidate in ipairs(ranked) do
 local connected,route,source=R.waterRoute(st,candidate.tile,coast.sources)
 naval.route=route;finalReason=route
 if connected then candidate.routeSource=source;return candidate,"ok" end
 if route=="context-changed-during-route-check" then return nil,route end
 naval.avoidUntil[candidate.tile]=now()+30
end
return nil,finalReason
end
local function checkBoatPending(s)
if not naval.pending then return false end
local p=naval.pending
local ownerAt=tileReader(s.state)
if ownerAt and ownerAt(p.tile)==s.state.local_owner then
R.observed("boat","target-owner-changed",s.state,p.tile)
attempted.boatCaptured=attempted.boatCaptured+1
naval.capture="owned-at-target (attribution-unverified)"
naval.reason="target-captured-observed"
log("Naval target captured at "..p.tile.." (source unverified)")
naval.pending=nil
return false
end
if now()-p.since>105 then
R.timedOut("boat",p.tile)
attempted.boatUnconfirmed=attempted.boatUnconfirmed+1
naval.avoidUntil[p.tile]=now()+220
naval.capture="not-confirmed"
naval.reason="boat-unconfirmed-cooldown"
log("Naval target not confirmed at "..p.tile)
naval.pending=nil
return false
end
return true
end
function R.islandDecision(x)
 local army=math.max(0,tonumber(x.army) or 0)
 local incoming=x.incoming==true
 local nuke=x.nuclear==true
 local borderDanger=(tonumber(x.borderDanger) or 0)>0
 local coast=math.max(0,tonumber(x.coast) or 0)
 local landFront=math.max(0,tonumber(x.landFront) or 0)
 local fill=math.max(0,tonumber(x.fill) or 0)
 if incoming or nuke then return "HOLD_DEFEND_HOME" end
 if borderDanger then return "HOLD_STRONG_BORDER" end
 if coast==0 then return "CAPTURE_COAST_FIRST" end
 if army<50000 or fill<.40 then return "WAIT_FOR_TROOPS" end
 if army*.90<math.max(1,tonumber(x.cap) or 1)*.35 then return "WAIT_FOR_HOME_RESERVE" end
 return "LOOK_FOR_NEAR_SAFE_ISLANDS"
end
local function autoBoat(s)
if not enabled.autoBoat or not s or type(s.state)~="table" or s.state.phase~=1
or s.paused==true then return end
if naval.pending or naval.planning or combat.pending then return end
local p=R.currentPolicy(s)
if p and not p.allowNaval then
 naval.reason="strategic-stop:"..p.mode.."; fill="..string.format("%.2f",p.fill or 0)
 return
end
if not landCache.ready or landCache.mapRef~=s.state.map then naval.reason="waiting-for-land-index";return end
if now()-lastAction.boat<65 or now()<(naval.nextPlan or 0) then return end
naval.nextPlan=now()+5
local me,own=myOwner(s)
if not me or not own then return end
local army=tonumber(own.troops) or 0
local cap=math.max(1,tonumber(own.max_troops) or army)
if army<50000 or army/cap<0.40 then
naval.reason="save-troop-reserve"
return
end
if underPressure(s) then naval.reason="local-defense-priority";return end
local epoch=R.epoch;naval.planning=true;naval.reason="planning-water-route"
R.spawn(function()
local planOK,planError=xpcall(function()
local target,why=chooseBoatTarget(s,own)
if not target then naval.reason=why;naval.nextPlan=now()+(why=="route-search-budget-exhausted" and 80 or 22);return end
if not alive or suspended or not enabled.autoBoat or R.epoch~=epoch or combat.pending then naval.reason="route-ready-dispatch-context-changed";return end
local current=findSession(false)
if not current or not R.ready(current) or current.state.phase~=1 then return end
local read=tileReader(current.state)
if not target.routeSource or not read or read(target.routeSource)~=current.state.local_owner then naval.reason="route-source-no-longer-owned";return end
s=current;me,own=myOwner(current)
R.observeWorld(current,true)
local currentPlan=R.world and R.world.plan
if underPressure(current) or (currentPlan and not currentPlan.allowNaval) then
 naval.reason="strategic-cancel-route-during-threat";return end
local targetOwner=read(target.tile)
if targetOwner~=target.targetOwner then naval.reason="route-target-owner-changed";return end
if not target.neutral then
 local enemy=s.state.owners[targetOwner] or s.state.owners[tostring(targetOwner)]
 target.enemyTroops=type(enemy)=="table" and tonumber(enemy.troops) or nil
end
local ratio,reason=chooseAttackRatio(s,target,own)
if not ratio then naval.reason="ratio-blocked:"..tostring(reason);return end
ratio=math.min(0.25,math.max(0.10,ratio))
local currentPlan2=R.world and R.world.plan
if currentPlan2 and not currentPlan2.allowNaval then naval.reason="strategic-cancel-before-boat-send";return end
local intent={type="boat",tile=target.tile,ratio=ratio}
local decoded,err=safeEncodeDecode(intent)
if not decoded or decoded.type~="boat" or
tonumber(decoded.tile)~=target.tile or
type(decoded.ratio)~="number" or math.abs(decoded.ratio-ratio)>0.001 then
naval.schema="not-validated"
naval.reason="boat-codec-not-validated:"..tostring(err)
return
end
naval.schema="boat/tile/ratio codec roundtrip"
lastAction.boat=now()
naval.last="tile="..target.tile.." distance="..math.floor(target.dist).." ratio="..string.format("%.2f",ratio).." score="..math.floor(target.score)
if sendIntent("boat",intent) then
R.lastMilitary=now()
naval.pending={tile=target.tile,since=now()}
naval.reason="request-sent-unconfirmed"
log("Coastal expansion attempt "..naval.last.." (server ACK unavailable)")
else
naval.avoidUntil[target.tile]=now()+90
naval.reason="client-rejected-or-codec-failed"
end
end,traceError)
if R.epoch==epoch then
 naval.planning=false
 if not planOK then naval.reason="planner-error:"..str(planError,100);R.traceback=planError end
end
end)
end
-- EXPERIMENTAL: no premium purchases or free-weapon unlock assumptions.
-- A codec roundtrip is necessary but NOT evidence of game/server acceptance.
local nukeAudit={pending=nil,last="not-attempted",schema="not-tested",target="none",count=0,observed=0,errors=0,mode="none"}
local function nukeTarget(s)
 local st=s.state;local me=st.local_owner
 if type(st.structures)~="table" or not st.W then return nil,"structures-unavailable" end
 local enemySites,ours={},{}
 local hasSilo=false
 local hostileSam={}
 for _,obj in pairs(st.structures) do
  if type(obj)=="table" then
   local tile=tileOf(obj,st);local kind=tonumber(obj.kind)
   if tile and kind then
    if tonumber(obj.owner)==me then
     if kind==5 then hasSilo=true end
     if kind==0 or kind==2 or kind==4 or kind==5 then ours[#ours+1]=tile end
    elseif not ownerAllied(st,me,tonumber(obj.owner)) then
     if kind==4 then hostileSam[#hostileSam+1]=tile end
     if kind==0 or kind==2 or kind==5 or kind==7 then
      enemySites[#enemySites+1]={tile=tile,owner=tonumber(obj.owner),kind=kind}
     end
    end
   end
  end
 end
 if not hasSilo then return nil,"no-owned-silo-observed" end
 if #enemySites<2 then return nil,"insufficient-verified-target-assets" end
 local w=st.W
 local function distanceSquared(a,b)
  local x=(a%w)-(b%w);local y=math.floor(a/w)-math.floor(b/w)
  return x*x+y*y
 end
 local best,bestScore=nil,-math.huge
 local inspected=0
 for _,site in ipairs(enemySites) do
  inspected=inspected+1
  if inspected>600 then break end
  local safe=true
  for _,ownTile in ipairs(ours) do
   if distanceSquared(site.tile,ownTile)<=35*35 then safe=false;break end
  end
  -- The clip avoids missile paths through enemy air defense. The client
  -- state gives us positions, not a verified trajectory/intercept radius:
  -- only reject sites very close to visible hostile SAMs as a heuristic.
  for _,samTile in ipairs(hostileSam) do
   if distanceSquared(site.tile,samTile)<=25*25 then safe=false;break end
  end
  if safe then
   local score=site.kind==5 and 8 or site.kind==0 and 6 or 4
   for _,other in ipairs(enemySites) do
    if other~=site and other.owner==site.owner and distanceSquared(site.tile,other.tile)<=18*18 then score=score+2 end
   end
   if score>bestScore then bestScore=score;best=site end
  end
 end
 if not best or bestScore<9 then return nil,"no-high-value-target-outside-friendly-safety-radius" end
 best.score=bestScore
 return best,"ok"
end
function R.weaponPlan(gold,score)
 -- Screenshot-derived budget floors, not RoFront server price quotations.
 -- MIRV is "scatter" in the original client VM, whereas its UI calls it MIRV.
 local choices={}
 if score>=18 and gold>=30000000 then choices[#choices+1]={name="mirv",kind="scatter",price=25000000,reserve=5000000} end
 if score>=14 and gold>=7000000 then choices[#choices+1]={name="h-bomb",kind="hydrogen",price=5000000,reserve=2000000} end
 if score>=9 and gold>=1250000 then choices[#choices+1]={name="atom",kind="atom",price=750000,reserve=500000} end
 return choices
end
local function chooseNukePayload(tile,weapon)
 -- Only string modes seen in the original client; no guessed integer enum.
 -- Decode must preserve the actual weapon and tile before any packet is sent.
 local possibilities={
  {type="nuke",tile=tile,kind=weapon},
  {type="nuke",tile=tile,nuke_kind=weapon},
 }
 for _,payload in ipairs(possibilities) do
  local decoded=safeEncodeDecode(payload)
  if decoded and decoded.type=="nuke" and tonumber(decoded.tile)==tile then
   local key=payload.kind~=nil and "kind" or "nuke_kind"
   if decoded[key]==payload[key] and probeIntent("nuke",payload) then
    return payload,key..":"..tostring(payload[key])
   end
  end
 end
 return nil,"no-validated-nuke-codec-layout"
end
local function autoNuke(s)
 if not enabled.autoNuke or suspended or not alive or not s or type(s.state)~="table" or s.state.phase~=1 then return end
 if nukeAudit.pending then
  local p=nukeAudit.pending
  local seen=false
  for _,projectile in pairs(type(s.state.nukes)=="table" and s.state.nukes or {}) do
   if type(projectile)=="table" then
    local to=tonumber(projectile.target_tile or projectile.target or projectile.tile or projectile.to)
    local from=tonumber(projectile.owner or projectile.sender or projectile.from_owner or projectile.attacker)
    if to==p.tile and from==p.owner then seen=true;break end
   end
  end
  if seen then
   R.observed("nuke","projectile-visible-target-and-owner; causal-ACK-unavailable",s.state,p.tile)
   attempted.nukeObserved=attempted.nukeObserved+1
   nukeAudit.last="projectile-observed-no-server-ACK";nukeAudit.pending=nil
  elseif now()-p.at>20 then
   R.timedOut("nuke",p.tile);attempted.nukeUnconfirmed=attempted.nukeUnconfirmed+1
   nukeAudit.last="outcome-unconfirmed-after-20s";nukeAudit.pending=nil
  else
   return
  end
 end
 if now()-lastAction.nuke<120 then return end
 if now()-(nukeAudit.lastScan or -9999)<10 then return end
 nukeAudit.lastScan=now()
 local id,own=myOwner(s)
 if not id or not own then return end
 local gold=tonumber(own.gold) or 0
 local counts=structureInfo(s.state,id)
 if (counts[5] or 0)<1 then nukeAudit.last="no-owned-silo-observed";return end
 if (counts[4] or 0)<1 then nukeAudit.last="first-sam-not-yet-observed";return end
 if gold<1250000 then nukeAudit.last="below-atom-screenshot-floor-plus-reserve";return end
 if R.world.plan and R.world.plan.emergency then
  nukeAudit.last="strategic-priority-defend-instead-of-nuke";return
 end
 if R.world.incoming>0 and (tonumber(R.world.incomingTroops) or 0)>200000 then
  nukeAudit.last="protect-our-front-first";return
 end
 local target,reason=nukeTarget(s)
 if not target then nukeAudit.last=reason;return end
 local choices=R.weaponPlan(gold,target.score)
 local intent,schema,selected
 for _,weapon in ipairs(choices) do
  intent,schema=chooseNukePayload(target.tile,weapon.kind)
  if intent then selected=weapon;break end
 end
 if not intent then
  nukeAudit.last=#choices==0 and "no-weapon-budget-for-asset-cluster" or
      "no-validated-codec-for-eligible-modes"
  nukeAudit.schema=schema or "not-tested";return
 end
 nukeAudit.schema=schema
 nukeAudit.mode=selected.name
 if not R.canSend(s,"nuke",intent) then nukeAudit.last="blocked:"..tostring(R.block);return end
 lastAction.nuke=now()
 if sendIntent("nuke",intent) then
  nukeAudit.pending={tile=target.tile,owner=id,at=now(),mode=selected.name}
  nukeAudit.target=tostring(target.tile).." owner="..tostring(target.owner).." score="..tostring(target.score)
  nukeAudit.last="sent-unconfirmed:"..selected.name.." "..schema
  nukeAudit.count=nukeAudit.count+1
 else
  nukeAudit.errors=nukeAudit.errors+1;nukeAudit.last="client-call-or-codec-rejected:"..tostring(R.block)
 end
end
local function sampleOwnership(s)
local st=s and s.state
if not st or not ownerScan.ready or ownerScan.mapRef~=st.map or
ownerScan.owner~=st.local_owner then return nil end
return {mine=ownerScan.total,total=landCache.count,occupied=-1,
tick=tonumber(st.tick) or -1}
end
local lastTelemetry=0
local function pollTelemetry(s)
if now()-lastTelemetry<25 then return end
lastTelemetry=now()
local cur=sampleOwnership(s)
if not cur then return end
latestSample=cur
if not baselineSample or (baselineSample.tick>=0 and cur.tick<baselineSample.tick) then
baselineSample=cur
end
end
function R.sync(s)
local st=s.state
if type(st)~="table" then return end
local tick=tonumber(st.tick)
local changed=R.state==nil or R.map~=st.map or R.owner~=st.local_owner or
 R.width~=st.W or R.height~=st.H or R.cells~=st.N or
 (tick and R.lastTick and tick<R.lastTick) or (R.phase==1 and st.phase==0) or
 R.source~=(st.map and st.map.land_list)
if changed then
R.epoch=R.epoch+1
R.state,R.map,R.owner,R.source,R.ownerBuf=st,st.map,st.local_owner,st.map and st.map.land_list,st.owner
landCache={ready=false,busy=false,reason="context-reset",count=0,loaded=0,n=0}
ownerScan={ready=false,busy=false,reason="context-reset",total=0,tiles={},lastAt=-1000,scanned=0}
combat.pending=nil;combat.avoidUntil={};construction.pending=nil;construction.avoided={};construction.recentlyBuilt={};construction.retryAt=0;construction.kindRetry={};construction.failures={}
R.atlas={status="context-reset",busy=false,ready=false,epoch=R.epoch,scanned=0,total=0,snapshot=nil,plan=nil,nextDue=0,errors=0}
R.seaAtlas={status="context-reset",busy=false,ready=false,epoch=R.epoch,scanned=0,total=0,waterCells=0,groups=0,label=nil,errors=0}
R.frontMemo=nil;R.ecoCoastCache=nil;R.economyAudit=nil;R.lastRivalAttack=-9999;R.lastRivalOwner=nil;R.lastRivalArmy=0
R.quotes={};R.priceHistory={};R.world={active={},events={},outgoing={},incoming=0,incomingTroops=0,unknown=0,raw={},lastScan=-1,lastOwned=nil,peakOwned=0,lossAt=-9999,emergencyUntil=-9999,nukeUntil=-9999,lastNukeCheck=-9999,lastNukeSignature="none",attackerLast={},mode="WAITING",troopWindow={},troopCrashAt=-9999}
allianceAudit.pending=nil;nukeAudit.pending=nil;nukeAudit.last="new-match";naval.pending=nil;naval.avoidUntil={};naval.nextPlan=0;naval.planning=false
naval.scanned=0;naval.myCoast=0;naval.targetCoast=0;naval.nearbyTargets=0;naval.coastCoverage="not-scanned";naval.reason="new-match"
reinforceAudit.pending=nil;reinforceAudit.status=R.reinforceUnlocked and "armed-new-match" or "locked-user-not-armed"
spawnAudit={tested=0,chosen="none",score="none",result="not-attempted",
 coastScanned=0,coastCandidates=0,coastalEligible=0,interiorEligible=0,
 coastStatus="not-scanned",bestCoastal="none",bestInterior="none",selection="not-selected",coastGoal="none"}
baselineSample=nil;latestSample=nil;validated={};R.outcomes={}
for k in pairs(lastAction) do lastAction[k]=-9999 end
R.lastMilitary=-9999
log("Match context reset epoch="..R.epoch)
end
R.state=st;R.ownerBuf=st.owner
R.width,R.height,R.cells=st.W,st.H,st.N
R.lastTick=tick;R.phase=st.phase
for _,map in ipairs({combat.avoidUntil,construction.avoided,naval.avoidUntil}) do
for tile,deadline in pairs(map) do if deadline<now() then map[tile]=nil end end
end
end
function R.monitor(s)
if not s or type(s.state)~="table" or s.state.phase~=1 then return end
R.pollSpawn(s);R.pollAttack(s);checkPending(s);checkAllyPending(s.state);checkBoatPending(s);R.checkReinforcePending(s)
end
function R.ready(s)
if not s or type(s.state)~="table" then return R.blocked("session-or-state-unavailable") end
local st=s.state
if s.paused==true or st.loaded==false or st.game_over==true then return R.blocked("paused-loading-or-game-over") end
if st.phase~=0 and st.phase~=1 then return R.blocked("unknown-phase:"..tostring(st.phase)) end
if type(st.N)~="number" or type(st.W)~="number" or type(st.H)~="number" or
 st.W<1 or st.H<1 or st.W%1~=0 or st.H%1~=0 or st.N~=st.W*st.H then return R.blocked("invalid-map-dimensions") end
if not tileReader(st) then return R.blocked("owner-buffer-unreadable") end
local id,own=myOwner(s)
if not id or not own or (st.phase==1 and own.alive==false) then return R.blocked("local-owner-not-ready-or-dead") end
R.block="none";return true
end
function R.canSend(s,kind,intent)
if not R.ready(s) then return false end
local st=s.state
local expected=kind=="spawn" and 0 or 1
if st.phase~=expected then return R.blocked("wrong-phase-for:"..kind) end
if kind=="reinforce" then
 if not enabled.autoReinforce or not R.reinforceUnlocked then return R.blocked("reinforce-not-armed") end
 local _,own=myOwner(s)
 if not own or (tonumber(own.gold) or 0)<500000 then return R.blocked("reinforce-policy-gold-floor-500k-not-game-quote") end
 if now()-lastAction.reinforce<40 then return R.blocked("reinforce-40s-send-throttle") end
end
local tile=intent.tile
if kind=="spawn" or kind=="attack" or kind=="boat" or kind=="build" then
 if type(tile)~="number" or tile%1~=0 or isVerifiedLand(st,tile)~=true then return R.blocked("target-land-unverified:"..kind) end
 local reader=tileReader(st);local owner=reader and reader(tile)
 if kind=="build" and owner~=st.local_owner then return R.blocked("build-target-no-longer-owned") end
 if kind=="spawn" and not R.vacant(st,owner) then return R.blocked("spawn-target-no-longer-vacant") end
 if kind=="attack" then
  local adjacent=false
  for _,near in ipairs(neighbours(tile,st.W,st.N)) do
   if reader(near)==st.local_owner then adjacent=true;break end
  end
  if not adjacent then return R.blocked("attack-no-longer-adjacent") end
 end
 if kind=="attack" or kind=="boat" then
  if owner==st.local_owner or ownerAllied(st,st.local_owner,owner) then return R.blocked("target-owned-or-allied") end
  local _,own=myOwner(s)
  local ratio=intent.ratio;local army=tonumber(own and own.troops) or 0
  if type(ratio)~="number" or ratio<=0 or ratio>.75 or army*(1-ratio)<(R.reserve or 50) then return R.blocked("military-reserve-recheck") end
 end
end
 if kind=="nuke" then
  local ntile=intent.tile
  if type(ntile)~="number" or ntile%1~=0 or isVerifiedLand(st,ntile)~=true then return R.blocked("nuke-invalid-target") end
  local nOwner=tileReader(st)(ntile)
  if nOwner==st.local_owner or R.vacant(st,nOwner) or ownerAllied(st,st.local_owner,nOwner) then return R.blocked("nuke-friendly-neutral-or-allied-target") end
 end
return true
end
function R.reinforceProbe()
-- Read-only codec inspection. Screenshot shows the player has NOT unlocked it.
local decoded,err=safeEncodeDecode({type="reinforce"})
if not decoded then return "read-only-type-probe:"..tostring(err) end
local fields={}
for k,v in pairs(decoded) do
if type(v)=="number" or type(v)=="boolean" or k=="type" then
fields[#fields+1]=str(k,24).."="..str(v,36)
else fields[#fields+1]=str(k,24)..":"..type(v) end
if #fields>=12 then break end
end
table.sort(fields)
return table.concat(fields,",").."; server action schema unverified"
end
function R.reinforceDecision(x)
 if not x.armed then return false,"locked-user-not-armed" end
 if not x.enabled then return false,"toggle-off" end
 if x.pending then return false,"awaiting-observation" end
 if (x.since or 0)<40 then return false,"40s-send-throttle; game-ui-says-30s" end
 if (x.gold or 0)<500000 then return false,"gold-below-500k-policy-floor-not-price" end
 if (x.cap or 0)<=0 then return false,"troop-cap-unreadable" end
 local fill=(x.troops or 0)/x.cap
 if fill>.50 then return false,"troops-above-half-cap" end
 if not x.pressured then return false,"no-active-defense-or-loss-pressure" end
 return true,"low-troops-under-pressure; effect-and-gold-cost-server-unverified"
end
function R.checkReinforcePending(s)
 local p=reinforceAudit.pending
 if not p or p.epoch~=R.epoch then reinforceAudit.pending=nil;return end
 local _,own=myOwner(s)
 local troop=own and tonumber(own.troops)
 local gold=own and tonumber(own.gold)
 -- Both changes are required; still no causal server ACK because other events may overlap.
 if troop and gold and troop>=p.troops*1.10 and gold<p.gold then
  R.observed("reinforce","troops-up-10pct-and-gold-down; attribution-unverified",s.state)
  attempted.reinforceObserved=attempted.reinforceObserved+1
  reinforceAudit.status="observed-change-unattributed";reinforceAudit.lastGold=tostring(p.gold).."->"..tostring(gold)
  reinforceAudit.pending=nil
 elseif now()-p.since>7 then
  R.timedOut("reinforce")
  attempted.reinforceUnconfirmed=attempted.reinforceUnconfirmed+1
  reinforceAudit.status="observation-timeout-unconfirmed"
  reinforceAudit.pending=nil
 end
end
local function autoReinforce(s)
 if not s or not s.state or s.state.phase~=1 then reinforceAudit.status="waiting-for-active-match";return end
 local _,own=myOwner(s)
 if not own then return end
 local mode=R.world and R.world.mode
 local pressured=(R.world and (R.world.incoming or 0)>0) or
   (mode=="DEFEND" or mode=="RECOVER")
 local allowed,reason=R.reinforceDecision({armed=R.reinforceUnlocked,enabled=enabled.autoReinforce,
   pending=reinforceAudit.pending~=nil,since=now()-lastAction.reinforce,
   gold=tonumber(own.gold),troops=tonumber(own.troops),cap=tonumber(own.max_troops),pressured=pressured})
 reinforceAudit.status=reason
 if not allowed then return end
 local intent={type="reinforce"}
 -- A type-only codec roundtrip is a client format check, not proof of game acceptance.
 local decoded,err=safeEncodeDecode(intent)
 if not decoded or decoded.type~="reinforce" then
  reinforceAudit.status="no-matching-codec:"..tostring(err);return
 end
 reinforceAudit.schema="reinforce/type-only-roundtrip; server-unverified"
 if sendIntent("reinforce",intent) then
  lastAction.reinforce=now()
  reinforceAudit.pending={epoch=R.epoch,since=now(),troops=tonumber(own.troops) or 0,gold=tonumber(own.gold) or 0}
  reinforceAudit.status="request-sent-observation-pending"
 end
end
R.priceEvidence={status="not-started",visited=0,textCount=0,rows={},finished=nil,busy=false}
function R.definitionEvidence()
 local result,seen={},{}
 local function walk(t,path,depth)
  if type(t)~="table" or seen[t] or depth>3 or #result>=50 then return end
  seen[t]=true
  local checked=0
  for k,v in pairs(t) do
   checked=checked+1;if checked>200 then break end
   local key=tostring(k);local p=path.."."..key;local low=string.lower(p)
   if type(v)=="number" and (low:find("cost",1,true) or low:find("price",1,true)) then
    result[#result+1]=str(p,140).."="..tostring(v).." [raw definition, applicability unverified]"
   elseif type(v)=="table" then walk(v,p,depth+1) end
   if #result>=50 then break end
  end
 end
 walk(defs,"Defs",0)
 if #result==0 then result[1]="NO_NUMERIC_PRICE_DEFINITION_OBSERVED" end
 return result
end
function R.startPriceScan()
 if R.priceEvidence.busy or not alive then return end
 local pg=player:FindFirstChildOfClass("PlayerGui")
 if not pg then R.priceEvidence.status="PlayerGui-unavailable";return end
 local evidence=R.priceEvidence
 evidence.busy=true;evidence.status="scanning-all-depths-in-batches"
 R.spawn(function()
  local ok,err=xpcall(function()
   local queue={pg};local head=1;local visited,textCount=0,0;local rows={}
   local excluded={AirfrontRemakeV3=true,RoFrontEntryPriceCheck=true,RoFrontBoot31915=true,RoFrontCompile317=true,RoFrontBootError=true}
   local function visible(node)
    local at=node
    for _=1,80 do
     if at==pg then return true end
     if not at or excluded[at.Name] then return false end
     if at:IsA("GuiObject") and at.Visible==false then return false end
     if at:IsA("ScreenGui") and at.Enabled==false then return false end
     at=at.Parent
    end
    return false
   end
   local function itemText(text)
    local low=string.lower(text)
    for _,name in ipairs({"city","factory","port","defense","sam","silo","reinforcements","warship","upgrade","cost","price"}) do
     if low:find("%f[%a]"..name.."%f[%A]") then return true end
    end
    return false
   end
   while #queue>0 do
    if not alive then return end
    local node=table.remove(queue);visited=visited+1
    if not excluded[node.Name] then
     if (node:IsA("TextLabel") or node:IsA("TextButton") or node:IsA("TextBox")) and visible(node) then
      textCount=textCount+1
      local raw=str(node.Text,260)
      R.inspectPriceNode(node,visible)
      if itemText(raw) and #rows<100 then
       rows[#rows+1]="UI_RAW "..str(node.Name,60).." text="..raw
       local parent=node.Parent
       if parent then
        local included=0
        for _,other in ipairs(parent:GetChildren()) do
         if other~=node and (other:IsA("TextLabel") or other:IsA("TextButton")) and visible(other) then
          local value=str(other.Text,200)
          if value:find("%d") then
           rows[#rows+1]="  sibling="..str(other.Name,50).." text="..value
           included=included+1;if included>=3 or #rows>=100 then break end
          end
         end
        end
       end
      end
     end
     -- Queue all children, including hidden containers: visibility may change mid-scan.
     for _,child in ipairs(node:GetChildren()) do queue[#queue+1]=child end
    end
    if visited%300==0 then
     evidence.scanVisited=visited;evidence.scanTextCount=textCount;task.wait()
    end
   end
   if #rows==0 then rows[1]="PRICE_NOT_OBSERVED; no matching visible game text in this scan" end
   rows[#rows+1]="Visibility=ancestor-flags-only; not screen/occlusion verified. Build/upgrade/level/currency require review."
   evidence.rows=rows;evidence.visited=visited;evidence.textCount=textCount
   evidence.finished=now();evidence.status="complete-no-6000-prefix-limit"
  end,traceError)
  if not ok then evidence.status="scan-error:"..str(err,120) end
  evidence.busy=false
 end)
end

local function makeReport()
local s=findSession(false)
local id,owner=myOwner(s)
local st=s and s.state or nil
local report={
"ROFRONT REMAKE V3.1.9.16 STRATEGY BETA FULL REPORT (no secrets)",
"placeId="..tostring(game.PlaceId).." / executor=Delta (target)",
"session="..sessionFrom,
"ui-parent="..tostring(R.uiParent).." actual-on-screen-visibility=NOT_VERIFIED",
"feature-scope=AutoJoin,AutoSpawn,SmartAttack,AutoBuild,AutoSam,SmartAlliance,Naval,EXPERIMENTAL_NUKE_ATOM_HBOMB_MIRV,EXPERIMENTAL_REINFORCE_AFTER_UNLOCK; autoReinforce toggle ON but ownership arm OFF",
"unimplemented=Upgrade,Retreat,Warship,Artillery,Airstrike; Reinforce and Nuke CODEC-GATED EXPERIMENTS",
"live-status=V3.1.9.12 user-reported cap stall and blocked tribe expansion; V3.1.9.16 LOCAL_QA_ONLY; NOT_TESTED_IN_DELTA",
"price-policy=fresh contextual UI quote preferred; OpenFront-derived tier fallback labelled as ESTIMATE, RoFront server quote not verified",
"price-source=https://allthings.how/rofront-world-pvp-inside-roblox-s-real-world-conquest-strategy-game/",
"price-source-conflict=Port 125K vs 250K initial; warship upper tier differs; not automated",
"published-tiers city/factory=125K,250K,500K,1M; defense=50K,100K,150K,200K,250K; sam=1.5M,3M; mapping-to-count=UNVERIFIED",
"price-scan="..R.priceEvidence.status.." current-visited="..tostring(R.priceEvidence.scanVisited).." last-complete-visited="..R.priceEvidence.visited.." text="..R.priceEvidence.textCount.." last-complete="..tostring(R.priceEvidence.finished),
"reinforcements-owned=NO at screenshot 8340/40000 stars; arm only after user unlocks. effect=+20pct troops per use; 30s cooldown and gold cost from UI; exact gold price and server schema UNVERIFIED; no premium purchases",
"reinforce-codec="..R.reinforceProbe(),
"reinforce-gated status="..reinforceAudit.status.." armed="..tostring(R.reinforceUnlocked).." schema="..reinforceAudit.schema.." requests="..attempted.reinforce.." observed-unattributed="..attempted.reinforceObserved.." unconfirmed="..attempted.reinforceUnconfirmed.." gold-before-after="..reinforceAudit.lastGold.." policy-floor=500000-gold-NOT-GAME-PRICE; 40s-send-throttle; 30s-game-cooldown-SCREENSHOT",
"boot="..R.boot.." ui_created="..tostring(R.uiCreated).." modules="..R.moduleStatus.." eof_marker="..tostring(R.eof),
"session_connected="..tostring(s~=nil).." map_ready="..tostring(landCache.ready).." owner_readable="..tostring(st and tileReader(st)~=nil),
"worker-error="..tostring(R.workerError or "none").." cycles="..tostring(R.cycles or 0),
"evidence-unmatched="..tostring(R.evidenceUnmatched or 0).." timeouts=OBSERVATION_ONLY_NOT_REJECTION",
"module-wait-seconds="..tostring(R.moduleStatus=="loading" and now()-(R.moduleStarted or now()) or 0),
"epoch="..R.epoch.." owner-buffer-width="..tostring(R.ownerWidth).." scan_is_nonatomic=true",
"last-block-reason="..R.block.." max-cycle-ms="..string.format("%.2f",R.maxCycleMs),
"strategy-mode="..R.world.mode.." incoming="..R.world.incoming.." incoming-troops-raw="..R.world.incomingTroops.." unknown-attack-records="..R.world.unknown,
"world-coverage=CLIENT_VISIBLE_STATE_ONLY; global completeness unverified; troop-units=RAW_NOT_UI_SCALE",
"v31914-water-map status="..tostring(R.seaAtlas.status)..
 " cells-scanned="..tostring(R.seaAtlas.scanned).."/"..tostring(R.seaAtlas.total)..
 " water-cells="..tostring(R.seaAtlas.waterCells)..
 " components="..tostring(R.seaAtlas.groups)..
 " routes=TOPOLOGY_ONLY_NOT_SERVER_ACCEPTANCE",
"v31914-atlas status="..tostring(R.atlas.status).." scanning="..tostring(R.atlas.busy)..
 " land-scanned="..tostring(R.atlas.scanned).."/"..tostring(R.atlas.total)..
 " latest-age="..string.format("%.1f",math.max(0,now()-(R.atlas.lastAt or now())))..
 " client-only=true snapshot-nonatomic=true; NO guarantee all server events exposed",
"v31914-world nations="..tostring(R.atlas.snapshot and R.atlas.snapshot.countNations or 0)..
 " owned-coast="..tostring(R.atlas.snapshot and R.atlas.snapshot.myCoast or "unknown")..
 " neutral-edges="..tostring(R.atlas.snapshot and R.atlas.snapshot.neutralEdges or "unknown")..
 " hostile-edges="..tostring(R.atlas.snapshot and R.atlas.snapshot.hostileEdges or "unknown")..
 " coast-source="..tostring(R.atlas.snapshot and R.atlas.snapshot.coastSource or "not-scanned")..
 " coast-list-read="..tostring(R.atlas.snapshot and R.atlas.snapshot.coastListRead or 0)..
 " coast-list-invalid="..tostring(R.atlas.snapshot and R.atlas.snapshot.coastListInvalid or 0)..
 " corridor="..tostring(R.atlas.snapshot and R.atlas.snapshot.route or "not-scanned"),
"v31916-runtime-safety planner-fallbacks="..tostring(R.plannerFallbacks or 0)..
 " isolated-faults="..(function()
  local rows={}
  for kind,entry in pairs(R.subsystemFaults or {}) do
   rows[#rows+1]=kind..":"..tostring(entry.count)..":"..str(entry.message,64)
  end
  table.sort(rows)
  return #rows>0 and table.concat(rows,";") or "none"
 end)().." fallback-actions=ENABLED",
"v31916-grand-plan stage="..tostring(R.atlas.plan and R.atlas.plan.mode or "waiting")..
 " opponent="..tostring(R.atlas.plan and R.atlas.plan.enemy or "none")..
 " next-land="..tostring(R.atlas.plan and R.atlas.plan.corridorNext or "none")..
 " coast-goal="..tostring(R.atlas.plan and R.atlas.plan.corridorGoal or "none")..
 " horizons="..tostring(R.atlas.plan and table.concat(R.atlas.plan.steps or {},">>") or "none")..
 " caution=PLAN_NOT_PREDICTION_NOT_SERVER_ACK",
"v31914-global-land-top="..tostring((function()
 local snapshot=R.atlas.snapshot;if not snapshot then return "not-scanned" end
 local top={};for owner,row in pairs(snapshot.nations) do
  top[#top+1]={id=owner,count=row.count,delta=(snapshot.growth or {})[owner] or 0}
 end
 table.sort(top,function(a,b) return a.count>b.count end)
 local results={};for i=1,math.min(8,#top) do
  local r=top[i];results[#results+1]=tostring(r.id)..":"..r.count.."("..r.delta..")"
 end
 return table.concat(results,",")
end)()),
"v318-policy mode="..tostring(R.world.mode).." reason="..tostring(R.world.plan and R.world.plan.reason).." reserve-fraction="..tostring(R.world.plan and R.world.plan.reserveFraction).." allow-naval="..tostring(R.world.plan and R.world.plan.allowNaval).." allow-neutral="..tostring(R.world.plan and R.world.plan.allowNeutral),
"v318-threat peak-owned="..tostring(R.world.peakOwned).." last-owned="..tostring(R.world.lastOwned).." emergency-remaining="..string.format("%.1f",math.max(0,(R.world.emergencyUntil or -9999)-now())).." nuke-remaining="..string.format("%.1f",math.max(0,(R.world.nukeUntil or -9999)-now())).." incoming="..tostring(R.world.incoming),
"v318-build-policy="..tostring(R.buildPolicy or "not-evaluated").." defense-goal="..tostring(R.defenseGoal or "?").." sam-goal="..tostring(R.samGoal or "?"),
"spawn-strategy="..tostring(spawnAudit.detail or "not-selected"),
"v319-spawn-choice="..tostring(spawnAudit.selection or "not-selected").." selected-coast-goal="..tostring(spawnAudit.coastGoal or "none").." coast-approach="..tostring(R.coastApproach or "not-selected").." coast-status="..tostring(spawnAudit.coastStatus or "not-scanned").." coast-scanned="..tostring(spawnAudit.coastScanned or 0).." generated="..tostring(spawnAudit.coastCandidates or 0).." eligible="..tostring(spawnAudit.coastalEligible or 0).." inland-eligible="..tostring(spawnAudit.interiorEligible or 0).." coast-best="..tostring(spawnAudit.bestCoastal or "none").." inland-best="..tostring(spawnAudit.bestInterior or "none"),
"naval-planning="..tostring(naval.planning).." route-expanded="..tostring(R.routeExpanded),
"attack-viable-candidates="..tostring(R.attackCandidates or 0).." rejected="..tostring(R.attackRejected or 0),
"v31916-attack-tempo="..tostring(R.attackTempoDecision or "idle").." fast-backoff-remaining="..string.format("%.1f",math.max(0,(R.fastAttackBackoffUntil or -999)-now())).." unconfirmed-streak="..tostring(R.fastAttackUnconfirmed or 0),
"v31914-opponent-defense=front-danger:"..tostring(R.world.borderDanger or 0).." adjacent-rivals:"..tostring(R.world.borderRivals or 0).." strongest-total-army-ratio:"..string.format("%.2f",R.world.borderStrongest or 0).." ratio-is-not-local-garrison=true",
"v31914-rival-last=owner:"..tostring(R.lastRivalOwner or "none").." since:"..string.format("%.1f",now()-(R.lastRivalAttack or now())).." military-tempo:"..tostring(R.attackTempoDecision or "none"),
"v31914-front sampled-owned="..tostring(R.frontSampleCount or 0).." nearby-rival-cells-over-half-our-army="..tostring(combat.borderThreat or 0).." second-front-candidates-blocked="..tostring(R.secondFrontCurrent or 0).." offensive-front-owner="..tostring(R.lastRivalOwner or "none").." scan-nonatomic=true; nearby-rival-cells-do-not-alone-trigger-danger=true",
"v31916-recovery-tribe eligible="..tostring(R.recoveryTribeCandidates or 0).." rejected-breakdown="..tostring((function()
 local rows={};for reason,count in pairs(R.occupiedReasonCounts or {}) do rows[#rows+1]=tostring(reason)..":"..tostring(count) end
 table.sort(rows);return #rows==0 and "none" or table.concat(rows,",")
end)()).." policy=weak-tribe-can-expand-during-loss;no-player-war-bypass",
"v31914-combat-gate commitment-blocked="..tostring(R.commitmentBlocked or 0).." occupied-blocked="..tostring(R.occupiedBlocked or 0).." occupied-reason="..tostring(R.occupiedBlockReason or "none").." neutral-border-blocked="..tostring(R.neutralFrontBlocked or 0).." last="..tostring(R.lastCommitGateReason or "none").." dispatch-and-home-tested=true; opponent-total-is-proxy-not-local-garrison=true",
"v31914-army-crash last="..tostring(R.world.troopCrashAt or "none").." recent-hold="..tostring(now()-(R.world.troopCrashAt or -9999)<150).." cause=unverified",
"v31914-prevent-duplicate-builds=125s-after-observed-tile; high-priority-first-factory=true; early-near-peer-war-restricted=true",
"v31914-economic-planner="..tostring(R.economyAudit and R.economyAudit.first or "no-purchase-yet").." reason="..tostring(R.economyAudit and R.economyAudit.priority).." gold-income="..tostring(owner and owner.income).." troop-fill="..tostring(R.economyAudit and R.economyAudit.fill).." eligible-purchases="..tostring(R.economyAudit and R.economyAudit.candidates),
"v31914-nuclear-capital first-sam-saving="..tostring(R.economyAudit and R.economyAudit.samSavings).." first-sam-budget="..tostring(R.economyAudit and R.economyAudit.samTarget).." nukes-seen="..tostring(R.economyAudit and R.economyAudit.nukesSeen).." owned-silos="..tostring(R.economyAudit and R.economyAudit.silos).." budget=CONTEXTUAL_UI_OR_ESTIMATE; missile-interception-radius=UNVERIFIED",
"v31914-enemy-silos-visible="..tostring(R.economyAudit and R.economyAudit.enemySilos).." observed-client-structures-only; no missile range assumed",
"v31914-conditional-port coast-sampled="..tostring(R.economyAudit and R.economyAudit.coast).." foreign-ports-visible="..tostring(R.economyAudit and R.economyAudit.foreignPorts).." coast-status="..tostring(R.economyAudit and R.economyAudit.coastStatus).." route-profit-not-server-verified",
"v31914-island-timing="..tostring(R.islandDecision({army=owner and owner.troops,
 incoming=R.world.incoming>0,nuclear=(R.world.nukeUntil or -9999)>now(),
 borderDanger=R.world.borderDanger or 0,coast=naval.myCoast,
 landFront=R.attackCandidates or 0,cap=owner and owner.max_troops,fill=owner and
 (tonumber(owner.troops) or 0)/math.max(1,tonumber(owner.max_troops) or 1)})).." route-eligibility=UNVERIFIED",
"self-play-caveat=PREVIOUS_4_PLAYER_RESULTS_WITHDRAWN; adversarial stress is NOT RoFront validation",
"v31914-open-expansion=absolute-army="..tostring(R.lastArmyObserved or 0).." neutral-safeguard=4300 coastal-gate=50000 first-city-cap-stall-buffer=0",
"v31914-evaluation=LIVE_TOP20_AND_EARLY_ELIMINATION_NOT_PROVEN",
"v319-expansion-diagnosis="..tostring((function()
 local cap=owner and tonumber(owner.max_troops) or 0
 local army=owner and tonumber(owner.troops) or 0
 local fill=(cap and cap>0 and army) and army/cap or 0
 local land=(R.attackCandidates or 0)
 local policy=R.world.plan
 if cap<=0 then return "no-cap-or-no-local-owner" end
 if fill>=.90 and land==0 then
  return "TROOP_CAP_STALL_NO_LAND_FRONT;NAVAL="..tostring(policy and policy.allowNaval)..";NAVAL_REASON="..tostring(naval.reason)
 end
 if fill>=.90 then return "NEAR_TROOP_CAP;LAND_TARGETS="..land end
 if land==0 then return "NO_VIABLE_LAND_FRONT;NAVAL="..tostring(policy and policy.allowNaval)..";NAVAL_REASON="..tostring(naval.reason) end
 return "LAND_EXPANSION_CANDIDATES_AVAILABLE="..land
end)()),
"owner-observed-current="..tostring(R.world.lastOwned).." peak-in-this-match="..tostring(R.world.peakOwned).." snapshot-and-scan-are-nonatomic=true",
"troop-fill-estimate="..tostring(owner and owner.max_troops and tonumber(owner.max_troops)>0 and string.format("%.1f%%",100*(tonumber(owner.troops) or 0)/tonumber(owner.max_troops)) or "unknown").." HUD +5/s CAN INDICATE STALLED_EXPANSION_NEAR_TROOP_CAP; owner.income NOT HUD troop regeneration",
"military-reserve="..tostring(R.reserve).." game-route-verification=UNAVAILABLE naval-default=ON_USER_REQUEST",
"naval-terrain-route="..tostring(naval.route or "not-tested"),
"sam-radius=HEURISTIC_NOT_GAME_RULE cost-source=CONTEXTUAL_UI_OR_LABELED_HISTORY; post-build-gold-reserve=NOT_GUARANTEED",
"structure-unlocated="..tostring(R.structuresUnlocated or 0).." index-fallback=DISABLED; placement-eligibility=land+ownership+vacancy-only",
"traceback="..tostring(R.traceback),
"protocol="..type(protocol).." / version="..tostring(protocol and protocol.VERSION),
"automation="..(suspended and "PAUSED" or "RUNNING"),
"toggles autoJoin="..tostring(enabled.autoJoin).." autoSpawn="..tostring(enabled.autoSpawn)..
" autoAttack="..tostring(enabled.autoAttack).." autoBuild="..tostring(enabled.autoBuild)..
" autoSam="..tostring(enabled.autoSam).." autoAlliance="..tostring(enabled.autoAlliance)..
" autoBoat="..tostring(enabled.autoBoat).." autoNuke="..tostring(enabled.autoNuke).." autoReinforce="..tostring(enabled.autoReinforce).." reinforceUnlockedArmed="..tostring(R.reinforceUnlocked),
"phase="..tostring(st and st.phase).." / tick="..tostring(st and st.tick)..
" / local_owner="..tostring(id),
"owner gold="..tostring(owner and owner.gold).." troops="..tostring(owner and owner.troops)..
" max_troops="..tostring(owner and owner.max_troops).." income="..tostring(owner and owner.income),
"requests join="..attempted.join.." spawn="..attempted.spawn..
" attack="..attempted.attack.." build="..attempted.build.." boat="..attempted.boat.." nuke="..attempted.nuke.." reinforce="..attempted.reinforce,
"observed attack-target-captured="..attempted.attackCaptured..
" attack-not-confirmed="..attempted.attackUnconfirmed,
"observed build-at-requested-tile="..attempted.buildConfirmed..
" build-not-confirmed="..attempted.buildDenied,
"last-attack="..combat.lastTarget,
"pending-attack="..tostring(combat.pending and combat.pending.tile),
"pending-build="..tostring(construction.pending and construction.pending.tile),
"build-decision="..construction.latest,
"build-last-budget-source="..tostring(R.buildPriceSource),
"build-schema="..construction.schema,
"build-last-observed="..construction.lastObserved,
"build-inspected-owned-tiles="..tostring(construction.inspected),
"spawn-scanned="..tostring(spawnAudit.tested).." chosen="..spawnAudit.chosen.." score="..spawnAudit.score.." outcome="..spawnAudit.result,
"combat-last-ratio="..combat.lastRatio.." decision="..combat.lastDecision.." threatened-border="..tostring(combat.borderThreat),
"combat-ratio-is-INTENT-NOT-HUD=TRUE; HUD percentage may stay on 25% independently",
"sam="..tostring(defenseAudit.samCount).." nukes-visible="..tostring(defenseAudit.nukesSeen).." incoming-estimate="..tostring(defenseAudit.incoming),
"sam-build-reason="..defenseAudit.samReason.." coverage-score="..defenseAudit.samCoverage.." nuke-threat="..defenseAudit.nukeThreat,
"alliance requests="..tostring(allianceAudit.seen).." candidates="..tostring(allianceAudit.candidates).." sent="..tostring(allianceAudit.sent).." observed="..tostring(allianceAudit.observed),
"requests-shape="..R.requestShape(st and st.requests),
"alliance status="..allianceAudit.last.." schema="..allianceAudit.schema.." request-fields="..allianceAudit.sample,
"alliance-visible-notices="..visibleAlliance.seen.." scan="..visibleAlliance.scan.." numeric-requests-require-independent-UI-identity=true",
"nuke experimental status="..nukeAudit.last.." mode="..nukeAudit.mode.." schema="..nukeAudit.schema.." target="..nukeAudit.target.." sent="..attempted.nuke.." observed="..attempted.nukeObserved.." timeout="..attempted.nukeUnconfirmed.." price-floors=Atom:750K,H-Bomb:5M,MIRV:25M-SCREENSHOT-NOT-LIVE; H-Bomb/MIRV-CODEC-GATED",
"naval boat-targets-captured="..attempted.boatCaptured.." unconfirmed="..attempted.boatUnconfirmed,
"naval coast-scanned="..naval.scanned.." owned="..naval.myCoast.." targets="..naval.targetCoast,
"naval coast-coverage="..tostring(naval.coastCoverage or "not-scanned").." nearby-targets="..tostring(naval.nearbyTargets or 0).." range=100-map-cells-source-sampled; route/server-validity=UNVERIFIED",
"naval reason="..naval.reason.." schema="..naval.schema.." last="..naval.last.." capture="..naval.capture,
"land-index status="..landCache.reason.." entries="..tostring(landCache.count)..
" progress="..tostring(landCache.loaded).." / map-N="..tostring(landCache.n),
"owner-scan status="..ownerScan.reason.." local-owner="..tostring(ownerScan.owner)..
" owned-tiles="..tostring(ownerScan.total).." scanning="..tostring(ownerScan.busy)..
" exact-enumeration=best-effort",
"build-cost="..construction.lastPrice,
"codec attack="..tostring(validated.attack).." spawn="..tostring(validated.spawn).." boat="..tostring(validated.boat).." nuke="..tostring(validated.nuke).." reinforce="..tostring(validated.reinforce).." / server ACK=not-available",
"last-error="..lastError,
"last-info="..lastInfo,
}
if latestSample then
report[#report+1]="observed-owned-land-cells="..latestSample.mine.."/"..latestSample.total.." (snapshot count; not official score)"
if baselineSample then
report[#report+1]="observed-owned-land-delta="..(latestSample.mine-baselineSample.mine).." (since this round's first scan)"
end
end
if construction.counts then
for _, kind in ipairs({0,1,2,3,4,5}) do
report[#report+1]="structures "..KIND_NAME[kind].."="..tostring(construction.counts[kind] or 0)
end
end
report[#report+1]="--- BUILD CODEC LOCAL READ-ONLY PROBES ---"
for _,idx in ipairs({1,2,4,12}) do
report[#report+1]="candidate "..idx..": "..tostring(construction.samples[idx] or "not-run")
end
report[#report+1]="--- ACTION EVIDENCE (run totals; last 60 calls) ---"
for _,kind in ipairs({"spawn","attack","build","ally_reply","boat","nuke","reinforce"}) do
report[#report+1]=kind.."="..(R.outcomes[kind] or "NOT_ATTEMPTED")
end
report[#report+1]="CONFIRMED=0 (no causal server acknowledgement available)"
for _,a in ipairs(R.actions) do
report[#report+1]=string.format("e%s %s tile=%s ratio=%s %s owner=%s->%s troops=%s->%s gold=%s->%s elapsed=%s %s",
a.epoch,a.kind..(a.structureKind and "/"..tostring(a.structureKind) or ""),tostring(a.tile),tostring(a.ratio),a.status,tostring(a.ownerBefore),tostring(a.ownerAfter),
tostring(a.troops),tostring(a.troopsAfter),tostring(a.gold),tostring(a.goldAfter),tostring(a.elapsed),a.detail or "")
end
report[#report+1]="--- CONTEXTUAL UI PRICE OBSERVATIONS ---"
for kind,history in pairs(R.priceHistory) do report[#report+1]=KIND_NAME[kind]..": "..history end
report[#report+1]="--- CLIENT-VISIBLE ATTACK EVENTS (not all world events) ---"
for _,entry in ipairs(R.world.events) do report[#report+1]=entry end
for _,entry in ipairs(R.world.raw) do report[#report+1]="attack-raw "..entry end
report[#report+1]="--- OWN STRUCTURE SCHEMA (bounded, raw kinds/levels) ---"
local shown=0
for key,b in pairs(type(st and st.structures)=="table" and st.structures or {}) do
 if type(b)=="table" and tonumber(b.owner)==id then
  report[#report+1]="structure key="..str(key,30).." kind(raw)="..tostring(b.kind).." tile="..tostring(tileOf(b,st)).." level="..tostring(b.level)
  shown=shown+1;if shown>=30 then break end
 end
end
report[#report+1]="--- GAME PRICE/UI EVIDENCE: RAW, NOT AUTOMATIC QUOTATIONS ---"
for _,line in ipairs(R.priceEvidence.rows) do report[#report+1]=line end
report[#report+1]="--- DEFS PRICE FIELDS: RAW, NO FUNCTIONS CALLED ---"
for _,line in ipairs(R.definitionEvidence()) do report[#report+1]=line end
report[#report+1]="--- EVENT LOG (most recent) ---"
for _,line in ipairs(events) do report[#report+1]=line end
report[#report+1]="IMPORTANT: Sending an intent is NOT proof of server acceptance or game victory."
return table.concat(report,"\n")
end
local function makeUI()
if gui then pcall(function() gui:Destroy() end) end
gui=Instance.new("ScreenGui")
gui.Name="AirfrontRemakeV3"
gui.ResetOnSpawn=false
gui.DisplayOrder=999998;gui.Enabled=true
gui.IgnoreGuiInset=false
R.uiParent=mountGui(gui)
local white=Color3.fromRGB(236,244,255)
local mint=Color3.fromRGB(106,228,167)
local dim=Color3.fromRGB(153,171,193)
local function addCorner(node,r)
local c=Instance.new("UICorner")
c.CornerRadius=UDim.new(0,r)
c.Parent=node
return c
end
local function addStroke(node)
local st=Instance.new("UIStroke")
st.Color=Color3.fromRGB(76,110,158)
st.Thickness=1.2
st.Parent=node
end
local function textLabel(parentNode,txt,x,y,w,h,sz,color)
local t=Instance.new("TextLabel")
t.BackgroundTransparency=1
t.Position=UDim2.fromOffset(x,y)
t.Size=UDim2.new(1,-x-w,0,h)
t.Font=Enum.Font.Gotham
t.TextSize=sz or 12
t.TextColor3=color or white
t.Text=txt
t.TextWrapped=true
t.TextXAlignment=Enum.TextXAlignment.Left
t.TextYAlignment=Enum.TextYAlignment.Center
t.Parent=parentNode
return t
end
local cam=workspace.CurrentCamera
local view=cam and cam.ViewportSize or Vector2.new(380,720)
local width=math.min(344,math.max(274,view.X-26))
local height=math.min(425,math.max(315,view.Y-40))
panel=Instance.new("Frame")
panel.Name="MainPanel"
panel.Size=UDim2.fromOffset(width,height)
panel.Position=UDim2.fromOffset(math.max(0,view.X-width-14),math.max(8,math.min(78,view.Y-height-12)))
panel.BackgroundColor3=Color3.fromRGB(19,27,41)
panel.BorderSizePixel=0
panel.Active=true
panel.Parent=gui
addCorner(panel,15); addStroke(panel)
local content=Instance.new("ScrollingFrame")
content.Size=UDim2.new(1,-14,1,-55)
content.Position=UDim2.fromOffset(7,49)
content.BackgroundTransparency=1
content.BorderSizePixel=0
content.ScrollBarThickness=3
content.CanvasSize=UDim2.fromOffset(0,610)
content.AutomaticCanvasSize=Enum.AutomaticSize.None
content.Parent=panel
local header=Instance.new("Frame")
header.Size=UDim2.new(1,0,0,45)
header.BackgroundColor3=Color3.fromRGB(30,49,78)
header.BorderSizePixel=0
header.Active=true
header.Parent=panel
addCorner(header,15)
local title=Instance.new("TextLabel")
title.BackgroundTransparency=1
title.Position=UDim2.fromOffset(13,0)
title.Size=UDim2.new(1,-103,1,0)
title.Font=Enum.Font.GothamBold
title.Text="ROFRONT  |  V3.1.9.16 BETA"
title.TextSize=14
title.TextColor3=white
title.TextXAlignment=Enum.TextXAlignment.Left
title.Parent=header
local function makeButton(parentNode,txt,x,y,w,h,bg)
local b=Instance.new("TextButton")
b.BackgroundColor3=bg or Color3.fromRGB(51,84,130)
b.BorderSizePixel=0
b.Position=UDim2.fromOffset(x,y)
b.Size=UDim2.fromOffset(w,h)
b.Font=Enum.Font.GothamBold
b.TextColor3=white
b.TextSize=12
b.TextWrapped=true
b.Text=txt
b.AutoButtonColor=true
b.Parent=parentNode
addCorner(b,8)
return b
end
bubble=Instance.new("TextButton")
bubble.Name="MinimizedAF"
bubble.Size=UDim2.fromOffset(58,58)
bubble.Position=UDim2.new(1,-77,0,145)
bubble.BackgroundColor3=Color3.fromRGB(34,96,155)
bubble.TextColor3=Color3.fromRGB(255,255,255)
bubble.Text="AF"
bubble.Font=Enum.Font.GothamBold
bubble.TextSize=22
bubble.BorderSizePixel=0
bubble.AutoButtonColor=true
bubble.Visible=false
bubble.Active=true
bubble.Parent=gui
addCorner(bubble,30); addStroke(bubble)
local function setExpanded(on)
expanded=on
panel.Visible=on
bubble.Visible=not on
end
local minBtn=makeButton(header,"–",width-81,8,31,28,Color3.fromRGB(50,116,142))
local closeBtn=makeButton(header,"X",width-43,8,31,28,Color3.fromRGB(151,56,76))
watch(minBtn.Activated:Connect(function() setExpanded(false) end))
watch(closeBtn.Activated:Connect(function() stop() end))
local function enableDrag(handle,movable,isBubble)
local tracking=false
local startInput=nil
local startPos=nil
local traveled=false
local releasedDragAt=-999
watch(handle.InputBegan:Connect(function(input)
if input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseButton1 then
tracking=true
traveled=false
startInput=input.Position
startPos=movable.Position
end
end))
watch(UserInputService.InputChanged:Connect(function(input)
if not tracking or not startInput or not startPos then return end
if input.UserInputType~=Enum.UserInputType.Touch and input.UserInputType~=Enum.UserInputType.MouseMovement then return end
local delta=input.Position-startInput
if delta.Magnitude>9 then traveled=true end
if not traveled then return end
local viewport=workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or view
local desiredX=startPos.X.Offset+delta.X+startPos.X.Scale*viewport.X
local desiredY=startPos.Y.Offset+delta.Y+startPos.Y.Scale*viewport.Y
local nodeW,nodeH=movable.AbsoluteSize.X,movable.AbsoluteSize.Y
local newX=math.clamp(desiredX,0,math.max(0,viewport.X-nodeW))
local newY=math.clamp(desiredY,30,math.max(30,viewport.Y-nodeH))
movable.Position=UDim2.fromOffset(newX,newY)
end))
watch(UserInputService.InputEnded:Connect(function(input)
if input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseButton1 then
if tracking and traveled then releasedDragAt=now() end
tracking=false
end
end))
if isBubble then
watch(handle.Activated:Connect(function()
if traveled or now()-releasedDragAt<0.24 then return end
setExpanded(true)
end))
end
end
enableDrag(header,panel,false)
enableDrag(bubble,bubble,true)
statusLabel=textLabel(content,"Locating Airfront Session...",8,0,8,23,12,mint)
statsLabel=textLabel(content,"Waiting for match",8,26,8,44,11,white)
infoLabel=textLabel(content,"Build: waiting for resources",8,74,8,44,11,dim)
local toggleOrder={
{"autoJoin","AUTO JOIN"},
{"autoSpawn","AUTO SPAWN"},
{"autoAttack","SMART ATTACK"},
{"autoBuild","AUTO BUILD (BETA)"},
{"autoSam","AUTO SAM PRIORITY"},
{"autoAlliance","SMART ALLIANCE"},
{"autoBoat","COASTAL NAVAL (BETA)"},
{"autoNuke","AUTO ATOM (EXPERIMENT)"},
{"autoReinforce","AUTO REINFORCE (GATED)"},
}
toggles={}
local btnWidth=math.floor((width-42)/2)
for i,item in ipairs(toggleOrder) do
local field,label=item[1],item[2]
local x=7+((i-1)%2)*(btnWidth+7)
local y=127+math.floor((i-1)/2)*48
local b=makeButton(content,label..(enabled[field] and " : ON" or " : OFF"),x,y,btnWidth,40)
toggles[field]={obj=b,label=label}
watch(b.Activated:Connect(function()
enabled[field]=not enabled[field]
log(label.." "..(enabled[field] and "ON" or "OFF"))
end))
end
local unlockButton=makeButton(content,"REINFORCE LOCKED: ARM AFTER 40K STARS",7,368,width-30,39,Color3.fromRGB(93,62,92))
unlockButton.Name="ReinforceArm"
watch(unlockButton.Activated:Connect(function()
 R.reinforceUnlocked=not R.reinforceUnlocked
 if not R.reinforceUnlocked then reinforceAudit.pending=nil end
 log(R.reinforceUnlocked and "Reinforce armed: user asserts permanent unlock; no premium purchase" or "Reinforce disarmed")
end))
pauseButton=makeButton(content,"PAUSE ALL",7,414,width-30,39,Color3.fromRGB(121,83,49))
watch(pauseButton.Activated:Connect(function()
suspended=not suspended
log(suspended and "All automation paused" or "All automation resumed")
end))
local copy=makeButton(content,"COPY FULL REPORT",7,462,width-30,43,Color3.fromRGB(53,105,154))
watch(copy.Activated:Connect(function()
R.startPriceScan()
local ok,report=xpcall(makeReport,traceError)
if not ok then R.traceback=report;report="ROFRONT REPORT ERROR\n"..tostring(report) end
print(report)
local copied=false
if type(setclipboard)=="function" then local ok,result=pcall(setclipboard,report);copied=ok and result~=false end
R.lastReport=report;sharedEnv.RoFrontLastReport=report
if copied then log("Full report copied!");return end
local old=panel:FindFirstChild("ReportOverlay")
if old then old:Destroy() end
local overlay=Instance.new("Frame")
overlay.Name="ReportOverlay";overlay.Size=UDim2.new(1,0,1,0);overlay.ZIndex=49;overlay.Parent=panel
local scroll=Instance.new("ScrollingFrame")
scroll.Size=UDim2.new(1,0,1,-36);scroll.Position=UDim2.fromOffset(0,36);scroll.ZIndex=50
scroll.CanvasSize=UDim2.fromOffset(0,math.max(500,(#report/30)*16));scroll.Parent=overlay
local closeReport=Instance.new("TextButton")
closeReport.Text="CLOSE REPORT";closeReport.Size=UDim2.new(1,0,0,34);closeReport.ZIndex=52;closeReport.Parent=overlay
closeReport.Activated:Connect(function() overlay:Destroy() end)
local box=Instance.new("TextBox")
box.Name="ManualReport";box.Size=UDim2.new(1,-16,0,math.max(500,(#report/30)*16));box.Position=UDim2.fromOffset(8,0)
box.MultiLine=true;box.ClearTextOnFocus=false;box.TextEditable=true
box.TextWrapped=true;box.TextSize=12;box.Font=Enum.Font.Code
box.TextXAlignment=Enum.TextXAlignment.Left;box.TextYAlignment=Enum.TextYAlignment.Top
box.Text=report;box.BackgroundColor3=Color3.fromRGB(20,28,40);box.TextColor3=Color3.fromRGB(240,240,240)
box.Parent=scroll;box.ZIndex=51
box:CaptureFocus();box.SelectionStart=1;box.CursorPosition=#report+1
log("Clipboard unavailable: select/copy report text; tap COPY again to refresh")
end))

local foot=textLabel(content,"ARM only after permanent Stars unlock. Gold cost and server acceptance unverified. No Robux purchase.",7,524,7,50,10,dim)
foot.TextYAlignment=Enum.TextYAlignment.Top
end
local function emergencyUI(message)
warn("[RoFront v3.1.9.16] UI start failed: "..tostring(message))
local ok,err=pcall(function()
local root=Instance.new("ScreenGui")
root.Name="RoFrontBootError"
root.ResetOnSpawn=false
root.DisplayOrder=99999
mountGui(root)
local box=Instance.new("TextButton")
box.Name="ErrorNotice"
box.Size=UDim2.fromOffset(310,120)
box.Position=UDim2.new(0.5,-155,0,75)
box.Text="ROFRONT START FAILED\n"..str(message,155).."\nTAP TO COPY ERROR"
box.TextScaled=false
box.TextWrapped=true
box.TextSize=13
box.Font=Enum.Font.GothamBold
box.TextColor3=Color3.fromRGB(255,255,255)
box.BackgroundColor3=Color3.fromRGB(128,44,57)
box.Parent=root
box.Activated:Connect(function()
if type(setclipboard)=="function" then pcall(setclipboard,"ROFRONT V3.1.9.16 BOOT ERROR: "..tostring(message)) end
end)
end)
if not ok then warn("[RoFront v3.1.1] Fallback UI also failed: "..tostring(err)) end
end
local function updateUI()
if not alive or not gui or not statusLabel then return end
local s=findSession(false)
if bootGui then
 local badge=bootGui:FindFirstChild("BootStatus")
 if badge then
  badge.Text="RF 3.1.9.16 RUNNING\n"..(s and "SESSION FOUND" or "WAITING FOR SESSION").." | TAP FOR PANEL"
 end
end
if s then
statusLabel.Text="CONNECTED: "..sessionFrom..(suspended and " [PAUSED]" or "").." / "..tostring(R.uiParent)
statusLabel.TextColor3=Color3.fromRGB(111,224,159)
local st=s.state
local id,own=myOwner(s)
local line="Phase="..tostring(st and st.phase).." | Lobby="..str(s.lobby and s.lobby.stage or "?",20)
if own then
line=line.."\nGold="..str(own.gold,15).." | Troops(raw)="..str(own.troops,15).." | Owner="..tostring(id)
else
line=line.."\nWaiting for local owner/match"
end
statsLabel.Text=line
else
statusLabel.Text="WAITING FOR GAME SESSION"
statusLabel.TextColor3=Color3.fromRGB(254,179,114)
statsLabel.Text="Join RoFront and enter a match"
end
for key,item in pairs(toggles or {}) do
local on=enabled[key]
item.obj.Text=item.label.." : "..(on and "ON" or "OFF")
item.obj.BackgroundColor3=on and Color3.fromRGB(35,110,101) or Color3.fromRGB(81,84,96)
end
if pauseButton then pauseButton.Text=suspended and "RESUME ALL" or "PAUSE ALL" end
if gui then
 local arm=gui:FindFirstChild("MainPanel") and gui.MainPanel:FindFirstChildOfClass("ScrollingFrame")
 arm=arm and arm:FindFirstChild("ReinforceArm")
 if arm then arm.Text=R.reinforceUnlocked and "REINFORCE ARMED: TAP TO DISARM" or "REINFORCE LOCKED: ARM AFTER 40K STARS" end
end
if infoLabel then
infoLabel.Text="Attack "..combat.lastRatio..": "..str(combat.lastDecision,42).."\nBuild: "..str(construction.latest,46).." | Nuke: "..str(nukeAudit.last,26)
end
end
-- TEST_EXPORT_POINT (only the test harness injects exports here)
local function showRunningBadge()
 pcall(function()
  local badge=bootGui and bootGui:FindFirstChildOfClass("TextButton")
  if not badge then return end
  badge.Name="BootStatus"
  badge.Size=UDim2.fromOffset(232,46)
  badge.Position=UDim2.fromOffset(10,65)
  badge.BackgroundColor3=Color3.fromRGB(27,137,80)
  badge.TextColor3=Color3.fromRGB(255,255,255)
  badge.Text="RF 3.1.9.16 RUNNING | TAP FOR PANEL"
  badge.Activated:Connect(function()
   if panel and bubble then
    expanded=not expanded
    panel.Visible=expanded;bubble.Visible=not expanded
   end
  end)
 end)
end
-- V3.1.9.16 fault containment, located before the main worker loop.
function R.safeSubsystem(name,fn,arg)
 if type(fn)~="function" then
  -- Missing optional subsystem is a fault, never a reason to freeze attack.
  local f=R.subsystemFaults[name] or {count=0,lastAt=-9999}
  f.count=f.count+1;f.message="missing-function:"..tostring(name)
  R.subsystemFaults[name]=f
  return false
 end
 local ok,err=xpcall(function() return fn(arg) end,traceError)
 if ok then return true end
 local f=R.subsystemFaults[name] or {count=0,lastAt=-9999}
 f.count=f.count+1;f.message=str(err,180)
 R.subsystemFaults[name]=f
 if name=="grand-plan" then
  R.plannerFallbacks=(R.plannerFallbacks or 0)+1
  if R.atlas then R.atlas.plan=nil;R.atlas.planFailure="planner-error-isolated" end
 end
 R.traceback=err
 if now()-(f.lastAt or -9999)>30 then
  f.lastAt=now()
  log("Subsystem "..tostring(name).." error (isolated): "..str(err,90),true)
 end
 return false
end
local uiOK,uiError=xpcall(makeUI,traceError)
if not uiOK then
lastError="UI: "..str(uiError,200);R.traceback=uiError;R.boot="ui_failed"
emergencyUI(lastError)
else
R.uiCreated=true;R.boot="ui_created"
showRunningBadge()
end
log("V3.1.9.16 strategy beta started; live Delta verification still required")
if game.PlaceId~=EXPECTED_PLACE then log("Wrong PlaceId; actions disabled",true) end
R.spawn(function()
while alive do
 R.startPriceScan()
 task.wait(15)
end
end)
R.spawn(function()
while alive and type(protocol)~="table" do
R.moduleStatus="loading"
R.moduleStarted=now()
local ok,err=xpcall(loadModules,traceError)
R.moduleStatus=type(protocol)=="table" and "ready" or "unavailable-retrying"
if not ok then R.traceback=err;log("Module error: "..str(err,150),true) end
if type(protocol)~="table" then task.wait(10) end
end
end)
R.spawn(function()
while alive do
if not recognize(session) then R.discover() end
task.wait(5)
end
end)
R.spawn(function()
while alive do
local started=now()
R.cycles=(R.cycles or 0)+1
local ok,err=xpcall(function()
local s=findSession(false)
if s then
R.sync(s);R.observeWorld(s);R.monitor(s)
if not suspended and R.uiCreated and game.PlaceId==EXPECTED_PLACE then
if enabled.autoJoin and not (s.state and s.state.game_over==true) then joinIfNeeded() end
if R.ready(s) then
R.safeSubsystem("land-index",ensureLandIndex,s.state)
if landCache.ready then
 R.safeSubsystem("owner-scan",refreshOwnerScan,s.state)
 R.safeSubsystem("atlas-scan",R.startFullAtlas,s.state)
 R.safeSubsystem("sea-scan",R.startSeaAtlas,s.state)
 if R.atlas.ready then R.safeSubsystem("grand-plan",R.updateGrandPlan,s) end
end
-- Each strategic module is isolated: a single planner/boat/economy exception
-- must NOT prevent attack, build, alliance or telemetry in the same cycle.
if enabled.autoSpawn then R.safeSubsystem("spawn",autoSpawn,s) end
if enabled.autoAttack then R.safeSubsystem("attack",autoAttack,s) end
if enabled.autoBoat then R.safeSubsystem("naval",autoBoat,s) end
if enabled.autoBuild then R.safeSubsystem("economy",autoBuild,s) end
if enabled.autoAlliance then R.safeSubsystem("alliance",autoAlliance,s) end
if enabled.autoNuke then R.safeSubsystem("nuke",autoNuke,s) end
if enabled.autoReinforce then R.safeSubsystem("reinforce",autoReinforce,s) end
R.safeSubsystem("telemetry",pollTelemetry,s)
end
end
else R.block="waiting-for-session" end
end,traceError)
if not ok then R.traceback=err;log("Cycle error: "..str(err,160),true) end
R.maxCycleMs=math.max(R.maxCycleMs,(now()-started)*1000)
local uiGood,uiErr=xpcall(updateUI,traceError)
if not uiGood then R.traceback=uiErr;log("UI error: "..str(uiErr,160),true) end
if not R.uiCreated and not R.uiRetryBusy then
R.uiRetryBusy=true
R.spawn(function()
local good,msg=xpcall(makeUI,traceError)
if good then R.uiCreated=true;R.boot="ui_created_after_retry";showRunningBadge()
else R.traceback=msg;log("UI retry failed: "..str(msg,120),true) end
 task.wait(10);R.uiRetryBusy=false
end)
end
task.wait(1)
end
end)
R.eof=true
local reportOK,initialReport=xpcall(makeReport,traceError)
if reportOK then
 R.lastReport=initialReport;sharedEnv.RoFrontLastReport=initialReport
 if type(setclipboard)=="function" then pcall(setclipboard,initialReport) end
end
print("[RoFront v3.1.9.16] EOF reached; workers scheduled")
end,function(err) return debug and debug.traceback and debug.traceback(tostring(err),2) or tostring(err) end)
if not bootOK then bootNotice("BOOT ERROR: "..tostring(bootError)) end
-- ROFRONT_V31916_END -- If missing, the paste/file is incomplete.
-- ROFRONT_V31916_DIRECT_FULL_END
