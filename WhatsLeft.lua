-- HideKnownAppearances.lua
local ADDON = ...

----------------------------------------------------------------
-- PERSISTED UI STATE (init first; do NOT touch frames here)
----------------------------------------------------------------
VKF_MenuPanelState = _G.VKF_MenuPanelState or { w = 300, h = 268, locked = false }
_G.VKF_MenuPanelState = VKF_MenuPanelState

VKF_TotalsState = _G.VKF_TotalsState or { h = 56, yOff = -2 }
_G.VKF_TotalsState = VKF_TotalsState

----------------------------------------------------------------
-- ROOT CONTROLLER
----------------------------------------------------------------
local HKA = CreateFrame("Frame")
_G.VKF_HKA = HKA
local WL = CreateFrame("Frame")
_G.WL_Core = WL
-- WhatsLeft Refresh/Rescan Stabilizer
-- Drop-in patch. Keeps your existing filtering logic; only manages hooks, events, and throttled rescans.


-- --------------- Configurable timing ---------------
local RESCAN_SOFT_DELAY  = 0.05  -- fast follow-up after UI paint
local RESCAN_HARD_DELAY  = 0.30  -- safety pass after merchant data settles
local RESCAN_DEBOUNCE_MS = 120   -- collapse bursts (currency, bag, merchant updates)

-- --------------- Internal state --------------------
WL._hooksInstalled = false
WL._debounceHandle = nil
WL._lastRescanAt   = 0
WL._merchantOpen   = false

-- Utility: ms clock
local function nowMs()
  return GetTime() * 1000
end

-- Debounce helper
local function debounced(fn, waitMs)
  return function(...)
    local args = {...}
    if WL._debounceHandle then
      WL._debounceHandle:Cancel()
      WL._debounceHandle = nil
    end
    WL._debounceHandle = C_Timer.NewTimer(waitMs/1000, function()
      WL._debounceHandle = nil
      fn(unpack(args))
    end)
  end
end

-- Idempotent hook installer
local function EnsureHooks()
  if WL._hooksInstalled then return end
  WL._hooksInstalled = true

  -- When Blizzard refreshes the merchant list, run our pass afterwards.
  hooksecurefunc("MerchantFrame_UpdateMerchantInfo", function()
    WL:RescanThrottled("MerchantFrame_UpdateMerchantInfo")
  end)

  -- Some UIs call this older path; harmless to hook as well.
  if MerchantFrame_Update then
    hooksecurefunc("MerchantFrame_Update", function()
      WL:RescanThrottled("MerchantFrame_Update")
    end)
  end
end

-- Core: Do the actual work (call your existing row-filter function here)
function WL:RescanNow(reason)
  if not WL._merchantOpen or not MerchantFrame or not MerchantFrame:IsShown() then
    return
  end

  local n = GetMerchantNumItems() or 0
  if n <= 0 then
    -- Try a delayed pass when the list is still populating
    C_Timer.After(RESCAN_SOFT_DELAY, function() WL:RescanNow("soft-wait") end)
    return
  end

  -- PASS 1: immediate pass after the triggering event
  for i = 1, n do
    -- 🔧 Replace the call below with YOUR filtering function:
    -- e.g., WhatsLeft_ApplyFiltersToMerchantRow(i)
    if WhatsLeft_ApplyFiltersToMerchantRow then
      pcall(WhatsLeft_ApplyFiltersToMerchantRow, i)
    end
  end

  -- PASS 2: safety pass a bit later (covers async icon/currency/state)
  C_Timer.After(RESCAN_HARD_DELAY, function()
    local m = GetMerchantNumItems() or 0
    for j = 1, m do
      if WhatsLeft_ApplyFiltersToMerchantRow then
        pcall(WhatsLeft_ApplyFiltersToMerchantRow, j)
      end
    end
  end)

  WL._lastRescanAt = nowMs()
end

-- Throttled wrapper (collapses bursts of events)
WL.RescanThrottled = debounced(function(reason)
  WL:RescanNow(reason)
end, RESCAN_DEBOUNCE_MS)

-- --------------- Event wiring ----------------------
WL:SetScript("OnEvent", function(self, event, ...)
  if event == "ADDON_LOADED" then
    local name = ...
    if name == ADDON then
      EnsureHooks()
    end

  elseif event == "PLAYER_LOGIN" then
    EnsureHooks()

  elseif event == "MERCHANT_SHOW" then
    WL._merchantOpen = true
    EnsureHooks()
    -- Run a couple of passes as UI settles
    C_Timer.After(0.01, function() WL:RescanNow("MERCHANT_SHOW+10ms") end)
    C_Timer.After(0.20, function() WL:RescanNow("MERCHANT_SHOW+200ms") end)

  elseif event == "MERCHANT_UPDATE" then
    WL:RescanThrottled("MERCHANT_UPDATE")

  elseif event == "MERCHANT_CLOSED" then
    WL._merchantOpen = false
    if WL._debounceHandle then
      WL._debounceHandle:Cancel()
      WL._debounceHandle = nil
    end

  -- Currency changes (Legion/MoP Remix bronze, etc.) can alter affordability/visibility
  elseif event == "CURRENCY_DISPLAY_UPDATE" or event == "PLAYER_MONEY" then
    if WL._merchantOpen then
      WL:RescanThrottled(event)
    end

  -- Bag changes (reagents, mats, or quest-item requirements sometimes affect UI logic)
  elseif event == "BAG_UPDATE_DELAYED" then
    if WL._merchantOpen then
      WL:RescanThrottled("BAG_UPDATE_DELAYED")
    end
  end
end)

-- Register events (safe set)
WL:RegisterEvent("ADDON_LOADED")
WL:RegisterEvent("PLAYER_LOGIN")
WL:RegisterEvent("MERCHANT_SHOW")
WL:RegisterEvent("MERCHANT_UPDATE")
WL:RegisterEvent("MERCHANT_CLOSED")
WL:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
WL:RegisterEvent("PLAYER_MONEY")
WL:RegisterEvent("BAG_UPDATE_DELAYED")

-- Register all relevant events
HKA:RegisterEvent("MERCHANT_SHOW")
HKA:RegisterEvent("MERCHANT_UPDATE")
HKA:RegisterEvent("MERCHANT_CLOSED")
HKA:RegisterEvent("PLAYER_ENTERING_WORLD")
HKA:RegisterEvent("ZONE_CHANGED_NEW_AREA")
HKA:RegisterEvent("ZONE_CHANGED")

HKA:SetScript("OnEvent", function(self, event)
  -- Handle zone transitions and dungeon exits
  if event == "PLAYER_ENTERING_WORLD"
  or event == "ZONE_CHANGED"
  or event == "ZONE_CHANGED_NEW_AREA" then
    if VKF_HideMini then VKF_HideMini() end
    if VKF_TotalsPanel then VKF_TotalsPanel:Hide() end
    if _G.VKF_MenuPanel then _G.VKF_MenuPanel:Hide() end
    self.needsRefresh = true
    return
  end

  -- Handle vendor closing
  if event == "MERCHANT_CLOSED" then
    if _G.VKF_MenuPanel then _G.VKF_MenuPanel:Hide() end
    if VKF_TotalsPanel then VKF_TotalsPanel:Hide() end
    if VKF_MiniPanel then VKF_MiniPanel:Hide() end
    return
  end

  -- Normal vendor updates
  if event == "MERCHANT_SHOW" or event == "MERCHANT_UPDATE" then
    if self.needsRefresh then
      self.needsRefresh = false
    end
    if HKA.Refresh then
      HKA:Refresh()
    end
  end
 end)

----------------------------------------------------------------
-- SESSION TOGGLES (defaults: all OFF unless explicitly saved)
----------------------------------------------------------------
local function on(v) return v == true end

VKF_HideSets           = on(VKF_HideSets)
VKF_HideMounts         = on(VKF_HideMounts)
VKF_HidePets           = on(VKF_HidePets)

-- (future) Toys – shown but disabled in UI
VKF_HideToys           = on(VKF_HideToys)
VKF_SkipUnavail_Toys   = on(VKF_SkipUnavail_Toys)

VKF_SkipUnavail_Sets   = on(VKF_SkipUnavail_Sets)
VKF_SkipUnavail_Mounts = on(VKF_SkipUnavail_Mounts)
VKF_SkipUnavail_Pets   = on(VKF_SkipUnavail_Pets)

----------------------------------------------------------------
-- HELPERS
----------------------------------------------------------------

-- Validates merchant slot is real & ready
local function VKF_IsValidSlot(slot)
  if type(slot) ~= "number" or slot < 1 then return false end
  local name = GetMerchantItemInfo and select(1, GetMerchantItemInfo(slot))
  return name ~= nil
end

-- Safely populate the hidden tooltip; returns true if lines are ready
local function VKF_SafeScannerSetMerchantItem(slot)
  if not VKF_IsValidSlot(slot) then return false end
  local tip = _G.VKF_ScannerTooltip
  if not tip then return false end
  tip:ClearLines()
  tip:SetOwner(UIParent, "ANCHOR_NONE")
  tip:SetMerchantItem(slot) -- only after slot validated
  return (tip:NumLines() or 0) > 0
end

-- iterate tooltip lines safely
local function VKF_ScannerEachLine(fn)
  local tip = _G.VKF_ScannerTooltip
  if not (tip and tip.GetName) then return end
  local base = tip:GetName()
  for i = 1, (tip:NumLines() or 0) do
    fn(_G[base.."TextLeft"..i], _G[base.."TextRight"..i], i)
  end
end

local function _vkf_sanitize_lower(s)
  if not s or s == "" then return nil end
  return (s:gsub("|c%x%x%x%x%x%x%x%x",""):gsub("|r",""):lower())
end

-- --- Safe shim: VKF_HideMini is always callable
if type(_G.VKF_HideMini) ~= "function" then
  function VKF_HideMini()
    local p = _G.VKF_MiniPanel
    if p and p.Hide then p:Hide() end
  end
  _G.VKF_HideMini = VKF_HideMini
end

-- === VKF scanner: create once, early ===
local scanner = _G.VKF_ScannerTooltip
if not scanner then
  scanner = CreateFrame("GameTooltip", "VKF_ScannerTooltip", UIParent, "GameTooltipTemplate")
  scanner:SetOwner(UIParent, "ANCHOR_NONE")
  _G.VKF_ScannerTooltip = scanner
end
-- keep an owner set; some UIs clear it
scanner:SetOwner(UIParent, "ANCHOR_NONE")

local VKF_MiniOffsetX, VKF_MiniOffsetY = -6, -14

local inRefresh = false
local function SafeSetShown(f, show)
  if not f then return end
  if f.SetShown then f:SetShown(show) elseif show then f:Show() else f:Hide() end
end

-- Run a function while merchant getters are remapped so that slot 1..10
-- refer to our filtered slots. Blizzard draws everything (including costs)
-- using these getters, so this guarantees prices match the new items.
local function VKF_WithRemappedMerchant(firstAbs, filtered, thunk)
  local per = MERCHANT_ITEMS_PER_PAGE or 10
  local G   = _G

  local function map(absSlot)
    -- Convert Blizzard’s absolute slot (11,12,...) to our filtered index
    local offset = absSlot - firstAbs + 1
    if offset < 1 or offset > per then return nil end
    return filtered[firstAbs + offset - 1]
  end

  -- Save originals
  local _GetMerchantItemInfo     = G.GetMerchantItemInfo
  local _GetMerchantItemLink     = G.GetMerchantItemLink
  local _GetMerchantItemCostInfo = G.GetMerchantItemCostInfo
  local _GetMerchantItemCostItem = G.GetMerchantItemCostItem

  local function wrap1(orig)
    return function(slot, ...)
      local real = map(slot)
      if real then return orig(real, ...) end
      return orig(slot, ...)
    end
  end

  G.GetMerchantItemInfo     = wrap1(_GetMerchantItemInfo)
  G.GetMerchantItemLink     = wrap1(_GetMerchantItemLink)
  G.GetMerchantItemCostInfo = wrap1(_GetMerchantItemCostInfo)
  G.GetMerchantItemCostItem = function(slot, i)
    local real = map(slot)
    if real then return _GetMerchantItemCostItem(real, i) end
    return _GetMerchantItemCostItem(slot, i)
  end

  local ok, err = pcall(thunk)

  -- Restore originals
  G.GetMerchantItemInfo     = _GetMerchantItemInfo
  G.GetMerchantItemLink     = _GetMerchantItemLink
  G.GetMerchantItemCostInfo = _GetMerchantItemCostInfo
  G.GetMerchantItemCostItem = _GetMerchantItemCostItem

  if not ok then error(err) end
end

local function PatchPopup(which)
  local D = StaticPopupDialogs and StaticPopupDialogs[which]
  if not D or D._vkfUnsurePatched then return end
  D._vkfUnsurePatched = true

  local origOnShow = D.OnShow
  D.OnShow = function(self, data)
    if origOnShow then pcall(origOnShow, self, data) end
    local t = self.text and self.text:GetText()
    if t and t:find("Are you sure", 1, true) then
      self.text:SetText(t:gsub("Are you sure", "ARE YOU UNSURE?"))
    end
  end
end

-- ---------- Safe "already known" tooltip checker (global) ----------
if type(_G.TooltipHasAlreadyKnown) ~= "function" then
  function TooltipHasAlreadyKnown(slot)
    if not VKF_SafeScannerSetMerchantItem(slot) then return false end
    local found = false
    VKF_ScannerEachLine(function(L, R)
      local function has(fs)
        local t = _vkf_sanitize_lower(fs and fs:GetText())
        if not t then return false end
        -- English tokens
        if t:find("already known", 1, true) then return true end
        if t:find("already collected", 1, true) then return true end
        -- (Optional) tolerant fallback if you want:
        -- if t:find("known", 1, true) and (t:find("collect",1,true) or t:find("appearance",1,true)) then return true end
        return false
      end
      if has(L) or has(R) then found = true end
    end)
    return found
  end
end

-- Escapes Lua pattern characters
local function _vkf_pat_escape(s)
  return (s or ""):gsub("(%W)","%%%1")
end

-- True if the tooltip has WORD 'wordLC' (case-insensitive) with word boundaries
local function TooltipContainsWordLower(slot, wordLC)
  scanner:ClearLines()
  scanner:SetMerchantItem(slot)
  local pat = "%f[%w]" .. _vkf_pat_escape(string.lower(wordLC)) .. "%f[%W]"
  for i = 1, scanner:NumLines() do
    local L = _G["VKF_ScannerTextLeft"..i]
    local R = _G["VKF_ScannerTextRight"..i]
    local function has(fs)
      local t = fs and fs:GetText()
      if not t or t == "" then return false end
      t = t:gsub("|c%x%x%x%x%x%x%x%x",""):gsub("|r",""):lower()
      return t:find(pat) ~= nil
    end
    if has(L) or has(R) then return true end
  end
  return false
end

-- True if tooltip shows "Collected (x/y)" with x > 0
local function TooltipHasCollected(slot)
  scanner:ClearLines()
  scanner:SetMerchantItem(slot)
  for i = 1, scanner:NumLines() do
    local L = _G["VKF_ScannerTextLeft"..i]
    local R = _G["VKF_ScannerTextRight"..i]
    local function extract(fs)
      local t = fs and fs:GetText()
      if not t or t == "" then return nil end
      t = t:gsub("|c%x%x%x%x%x%x%x%x",""):gsub("|r",""):lower()
      local x, y = t:match("collected%s*%((%d+)%s*/%s*(%d+)%)")
      if x and y then return tonumber(x), tonumber(y) end
      return nil
    end
    local a1,b1 = extract(L); if a1 and a1 > 0 then return true end
    local a2,b2 = extract(R); if a2 and a2 > 0 then return true end
  end
  return false
end


-- ===== Pet detection/cache (robust + consistent) =====

-- small cache to avoid hammering the journal while info is loading
local VKF_PetCache = {}   -- key: itemID -> { speciesID = n|true|nil, t = GetTime() }

local function VKF_PetCacheSet(itemID, speciesID)
  VKF_PetCache[itemID] = { speciesID = speciesID, t = GetTime() }
end
local function VKF_PetCacheGet(itemID)
  local e = VKF_PetCache[itemID]
  if e and (GetTime() - (e.t or 0) < 30) then  -- 30s freshness window is enough
    return e.speciesID
  end
end

-- Returns: speciesID (number) if known exactly,
--          true (boolean) if heuristically a pet (species unknown yet),
--          nil if NOT a pet
-- Robust: speciesID if exact, true if clearly a pet (heuristic), nil otherwise
local function ItemTeachesPet(slot, link)
  if not link or not VKF_IsValidSlot(slot) then return nil end

  -- 1) Explicit battle-pet link
  local sp = link:match("|Hbattlepet:(%d+):")
  if sp then return tonumber(sp) end

  -- 2) Journal: itemID -> speciesID
  local itemID = GetItemInfoInstant(link)
  if itemID and C_PetJournal and C_PetJournal.GetPetInfoByItemID then
    local speciesID = C_PetJournal.GetPetInfoByItemID(itemID)
    if speciesID then return speciesID end
  end

  -- 3) Tooltip heuristic (locale-lite)
  if VKF_SafeScannerSetMerchantItem(slot) then
    -- look for “battle”/“companion” or teaches+summon words
    if TooltipContainsWordLower(slot, "battle")
       or TooltipContainsWordLower(slot, "companion")
       or (TooltipContainsWordLower(slot, "teaches") and TooltipContainsWordLower(slot, "summon"))
       or TooltipContainsWordLower(slot, "pet") then
      return true
    end
  end

  return nil
end

-- Convenience: unified “is this a pet slot?”
local function DetectPet(slot, link)
  return ItemTeachesPet(slot, link) ~= nil
end

-- True if you already have at least one of that species
local function IsPetKnown(slot, link)
  if not link or not VKF_IsValidSlot(slot) then return false end

  -- 1) Exact species path
  local speciesID = ItemTeachesPet(slot, link)
  if type(speciesID) == "number"
     and C_PetJournal and C_PetJournal.GetNumCollectedInfo then
    local n = C_PetJournal.GetNumCollectedInfo(speciesID)
    if n and n > 0 then return true end
  end

  -- 2) Tooltip fallbacks (use the scanner helpers!)
  if not VKF_SafeScannerSetMerchantItem(slot) then return false end

  local collected = false
  local sawCollectWord = false
  VKF_ScannerEachLine(function(L, R)
    local function check(fs)
      local t = _vkf_sanitize_lower(fs and fs:GetText()); if not t then return end
      if t:find("collect", 1, true) then sawCollectWord = true end
      local a = t:match("%((%d+)%s*/%s*%d+%)")
      if a and tonumber(a) and tonumber(a) > 0 then collected = true end
    end
    check(L); check(R)
  end)
  if collected and sawCollectWord then return true end

  -- 3) Generic "already known" line (your shim)
  if TooltipHasAlreadyKnown and TooltipHasAlreadyKnown(slot) then return true end

  return false
end



----------------------------------------------------------------
-- TOOLTIP / CLASSIFICATION
----------------------------------------------------------------
scanner:SetOwner(UIParent, "ANCHOR_NONE")

local function TooltipContainsLower(slot, needleLC)
  if not VKF_SafeScannerSetMerchantItem(slot) then return false end
  local found = false
  VKF_ScannerEachLine(function(L, R)
    local function has(fs)
      local t = _vkf_sanitize_lower(fs and fs:GetText())
      return t and t:find(needleLC, 1, true) ~= nil
    end
    if has(L) or has(R) then found = true end
  end)
  return found
end

local function _vkf_pat_escape(s) return (s or ""):gsub("(%W)","%%%1") end
local function TooltipContainsWordLower(slot, wordLC)
  if not VKF_SafeScannerSetMerchantItem(slot) then return false end
  local pat = "%f[%w]" .. _vkf_pat_escape(wordLC) .. "%f[%W]"
  local ok = false
  VKF_ScannerEachLine(function(L, R)
    local function has(fs)
      local t = _vkf_sanitize_lower(fs and fs:GetText())
      return t and t:find(pat) ~= nil
    end
    if has(L) or has(R) then ok = true end
  end)
  return ok
end

local function TooltipHasCollected(slot)
  if not VKF_SafeScannerSetMerchantItem(slot) then return false end
  local ok = false
  VKF_ScannerEachLine(function(L, R)
    local function extract(fs)
      local t = _vkf_sanitize_lower(fs and fs:GetText())
      if not t then return 0,0 end
      local x, y = t:match("collected%s*%((%d+)%s*/%s*(%d+)%)")
      return tonumber(x or 0) or 0, tonumber(y or 0) or 0
    end
    local a = select(1, extract(L)); if a > 0 then ok = true end
    local b = select(1, extract(R)); if b > 0 then ok = true end
  end)
  return ok
end

local UNAVAILABLE_PATTERNS = {
  "available with the release","available in","not yet available","unavailable","coming soon",
}
local function TooltipIsTemporarilyUnavailable(slot)
  if not VKF_IsValidSlot(slot) then return false end
  for _, p in ipairs(UNAVAILABLE_PATTERNS) do
    if TooltipContainsLower(slot, p) then return true end
  end
  return false
end
----------------------------------------------------------------
-- CATEGORY CHECKS
----------------------------------------------------------------
-- Bundle items that teach multiple appearances (Ensemble/Arsenal/etc.)
local function IsEnsemble(link, slot)
  if not link then return false end
  local name = (link:match("%[(.-)%]") or ""):lower()
  if name:find("^ensemble:") or name:find("^arsenal:") then
    return true
  end
  -- Fallback for any future wording: detect via tooltip text
  if slot and TooltipContainsLower(slot, "collect the appearances") then
    return true
  end
  return false
end

local function IsKnownByTransmogAPI(link)
  if not link then return false end
  local itemID = GetItemInfoInstant(link)
  if not itemID then return false end
  if C_TransmogCollection and C_TransmogCollection.PlayerHasTransmogItemModifiedAppearance then
    local k = C_TransmogCollection.PlayerHasTransmogItemModifiedAppearance(itemID)
    if k ~= nil then return k end
  end
  if C_TransmogCollection and C_TransmogCollection.PlayerHasTransmog then
    local k = C_TransmogCollection.PlayerHasTransmog(itemID)
    if k ~= nil then return k end
  end
  return false
end

local function IsKnownSet(slot, link)
  if not link or not IsEnsemble(link, slot) then return false end
  if TooltipHasAlreadyKnown(slot) then return true end
  return IsKnownByTransmogAPI(link)
end

-- Mounts
local function ItemTeachesMount(link)
  if not link then return nil end
  if C_MountJournal and C_MountJournal.GetMountFromItem then
    local itemID = GetItemInfoInstant(link)
    if itemID then
      local mountID = C_MountJournal.GetMountFromItem(itemID)
      if mountID then return mountID end
    end
  end
  local _, spellID = GetItemSpell(link)
  if spellID and C_MountJournal and C_MountJournal.GetMountFromSpell then
    local mountID = C_MountJournal.GetMountFromSpell(spellID)
    if mountID then return mountID end
  end
  return nil
end

local function IsMountKnown(link)
  local mountID = ItemTeachesMount(link)
  if not mountID then return false end
  if C_MountJournal and C_MountJournal.GetMountInfoByID then
    local _, _, _, _, _, _, _, _, _, _, isCollected = C_MountJournal.GetMountInfoByID(mountID)
    return isCollected or false
  end
  return false
end



----------------------------------------------------------------
-- TOYS: detect “teaches a toy” + known/unknown status
----------------------------------------------------------------

-- Returns the toy's itemID if the item is a toy; otherwise nil.
-- Falls back to tooltip heuristics if the API can’t resolve yet.
local function ItemTeachesToy(slot, link)
  if not link then return nil end
  local itemID = GetItemInfoInstant(link)
  if not itemID then return nil end

  -- 1) Primary API checks
  if C_ToyBox then
    -- Some builds expose GetToyFromItemID; if it returns a value, it's a toy.
    if C_ToyBox.GetToyFromItemID then
      local toyItemID = C_ToyBox.GetToyFromItemID(itemID)
      if toyItemID then return toyItemID end
    end
    -- Fallback: GetToyInfo returns a name for toy items
    if C_ToyBox.GetToyInfo then
      local name = C_ToyBox.GetToyInfo(itemID)
      if name then return itemID end
    end
  end

  -- 2) Tooltip heuristic (works while info isn’t cached yet)
  -- Keep it conservative to avoid false positives.
  if TooltipContainsLower(slot, "use:") and TooltipContainsLower(slot, "toy") then
    return itemID
  end

  return nil
end

-- Returns true if the toy is already collected.
local function IsToyKnown(slot, link)
  if not link then return false end
  local toyItemID = ItemTeachesToy(slot, link)

  if toyItemID and PlayerHasToy and PlayerHasToy(toyItemID) then
    return true
  end

  if TooltipHasCollected and TooltipHasCollected(slot) then
  if not GetMerchantItemInfo(slot) then return false end
    return true
  end
  if TooltipHasAlreadyKnown and TooltipHasAlreadyKnown(slot) then
  if not GetMerchantItemInfo(slot) then return false end
    return true
  end

  return false
end



-- Mounts: strong detection (API first, then tooltip with the word "mount")
local function DetectMount(slot, link)
if not GetMerchantItemInfo(slot) then return false end
  if not link then return false end

  -- API paths
  if C_MountJournal then
    local itemID = GetItemInfoInstant(link)
    if itemID and C_MountJournal.GetMountFromItem then
      local mountID = C_MountJournal.GetMountFromItem(itemID)
      if mountID then return true end
    end
    local _, spellID = GetItemSpell(link)
    if spellID and C_MountJournal.GetMountFromSpell then
      local mountID = C_MountJournal.GetMountFromSpell(spellID)
      if mountID then return true end
    end
  end

  -- Tooltip fallback: require the word "mount"
  if slot and TooltipContainsLower(slot, "mounts") then
    return true
  end

  return false
end

-- Pets: strict detection (API first, battlepet link, or tooltip with "companion"/"battle pet")
local function DetectPet(slot, link)
if not GetMerchantItemInfo(slot) then return false end
  if not link then return false end

  -- API
  local itemID = GetItemInfoInstant(link)
  if itemID and C_PetJournal and C_PetJournal.GetPetInfoByItemID then
    local speciesID = C_PetJournal.GetPetInfoByItemID(itemID)
    if speciesID then return true end
  end

  -- Battle pet hyperlink
  if link:find("|Hbattlepet:%d+:") then
    return true
  end

  -- Tooltip fallback: only match clear pet phrases (avoid catching mounts)
  if slot then
    if TooltipContainsLower(slot, "battle pet") or TooltipContainsLower(slot, "companion") then
      return true
    end
  end

  return false
end

-- Toys unchanged; shown here for clarity
local function DetectToy(slot, link)
if not GetMerchantItemInfo(slot) then return false end
  if not link then return false end
  local itemID = GetItemInfoInstant(link)
  if itemID and C_ToyBox then
    if C_ToyBox.GetToyFromItemID and C_ToyBox.GetToyFromItemID(itemID) then return true end
    if C_ToyBox.GetToyInfo and C_ToyBox.GetToyInfo(itemID) then return true end
  end
  if slot and TooltipContainsLower(slot, "toy") then
    return true
  end
  return false
end


----------------------------------------------------------------
-- FILTER (gapless list)
----------------------------------------------------------------
local function BuildFilteredSlots()
  local out, total = {}, GetMerchantNumItems()
  for slot = 1, total do
    local link = GetMerchantItemLink(slot)
    local hide = false
    if not link then
      table.insert(out, slot)
    else
      ---------------------------------------------------------
      -- Detect item type first (each slot belongs to one type)
      ---------------------------------------------------------
      local isMount = DetectMount(slot, link)
      local isPet   = (not isMount) and DetectPet(slot, link) or false
      local isToy   = (not isMount and not isPet) and DetectToy(slot, link) or false
      local isSet   = (not isMount and not isPet and not isToy) and IsEnsemble(link) or false

      ---------------------------------------------------------
      -- Apply per-category rules (independent toggles)
      ---------------------------------------------------------
      if isSet then
        if VKF_HideSets and IsKnownSet(slot, link) then
          hide = true
        elseif VKF_SkipUnavail_Sets and TooltipIsTemporarilyUnavailable(slot) then
          hide = true
        end
      elseif isMount then
        if VKF_HideMounts and IsMountKnown(link) then
          hide = true
        elseif VKF_SkipUnavail_Mounts and TooltipIsTemporarilyUnavailable(slot) then
          hide = true
        end
      elseif isPet then
        if VKF_HidePets and IsPetKnown(slot, link) then
          hide = true
        elseif VKF_SkipUnavail_Pets and TooltipIsTemporarilyUnavailable(slot) then
          hide = true
        end
      elseif isToy then
        if VKF_HideToys and IsToyKnown(slot, link) then
          hide = true
        elseif VKF_SkipUnavail_Toys and TooltipIsTemporarilyUnavailable(slot) then
          hide = true
        end
      end

      ---------------------------------------------------------
      -- Keep item visible if no filters apply
      ---------------------------------------------------------
      if not hide then
        table.insert(out, slot)
      end
    end
  end
  return out
end

----------------------------------------------------------------
-- ROW PAINT
----------------------------------------------------------------
local function RowNameFS(i, row) return (row and row.Name) or _G["MerchantItem"..i.."Name"] end
local function RowIconTX(i, btn) return (btn and (btn.icon or btn.Icon)) or _G["MerchantItem"..i.."ItemButtonIconTexture"] end

local function PaintRow(i, slot)
  local row = _G["MerchantItem"..i]
  local btn = row and (row.ItemButton or _G["MerchantItem"..i.."ItemButton"])
  if not (row and btn) then return end

  if slot then
    row.index = slot
    btn:SetID(slot)
    btn.link = GetMerchantItemLink(slot)

    -- Pre-fill BEFORE Blizzard update
    local name, texture = GetMerchantItemInfo(slot)
    local nameFS = RowNameFS(i, row)
    local iconTX = RowIconTX(i, btn)
    if nameFS and name   then nameFS:SetText(name) end
    if iconTX and texture then iconTX:SetTexture(texture) end

    -- Let Blizzard do baseline paint
    if MerchantFrameItem_Update then
      MerchantFrameItem_Update(row, slot)
    end

    -- VKF: deep red icon overlay for temp-unavailable (text stays purple)
    local isTempUnavailable = TooltipIsTemporarilyUnavailable(slot)
    if not btn._vkfRedOverlay then
      local ov = btn:CreateTexture(nil, "OVERLAY")
      ov:SetColorTexture(0.55, 0.00, 0.00, 0.60) -- deep, assertive red
      ov:SetAllPoints(btn)
      ov:Hide()
      btn._vkfRedOverlay = ov
    end
    if isTempUnavailable then
      btn._vkfRedOverlay:Show()
      if iconTX then iconTX:SetVertexColor(1, 1, 1) end
    else
      btn._vkfRedOverlay:Hide()
      if iconTX then iconTX:SetVertexColor(1, 1, 1) end
    end

    SafeSetShown(row, true)
  else
    SafeSetShown(row, false)
  end
end

----------------------------------------------------------------
-- MINI PANEL CORE (defines VKF_ToggleMini safely, once)
----------------------------------------------------------------
if type(VKF_ToggleMini) ~= "function" then
  local VKF_MiniPanel -- kept private to this block

  -- --- Internal: pull Bronze cost (amount) for a given merchant slot ---
  local function VKF_GetBronzeCost(slot)
    local total = 0
    local nAlt = GetMerchantItemCostInfo(slot) or 0
    for i = 1, nAlt do
      local tex, amount, costLink = GetMerchantItemCostItem(slot, i)
      if amount and amount > 0 and costLink then
        local cid = C_CurrencyInfo and C_CurrencyInfo.GetCurrencyIDFromLink(costLink)
        if cid and C_CurrencyInfo.GetCurrencyInfo then
          local info = C_CurrencyInfo.GetCurrencyInfo(cid)
          local nm = info and info.name or ""
          if type(nm) == "string" and nm:lower():find("bronze", 1, true) then
            total = total + amount
          end
        end
      end
    end
    return total
  end

-- --- Internal: compute category breakdown for the current vendor page ---
-- --- Internal: compute category breakdown for the current vendor page (incl. Sets)
local function VKF_BuildCategoryBreakdown()
  local out = {
    sets   = { total = 0, known = 0, count = 0 },
    mounts = { total = 0, known = 0, count = 0 },
    pets   = { total = 0, known = 0, count = 0 },
    toys   = { total = 0, known = 0, count = 0 },
    countTotal = 0,
    countKnown = 0,
  }

  local function bronzeCost(slot)
    local total = 0
    local nAlt = GetMerchantItemCostInfo(slot) or 0
    for i = 1, nAlt do
      local _, amount, costLink = GetMerchantItemCostItem(slot, i)
      if amount and amount > 0 and costLink then
        local cid = C_CurrencyInfo and C_CurrencyInfo.GetCurrencyIDFromLink(costLink)
        if cid and C_CurrencyInfo.GetCurrencyInfo then
          local info = C_CurrencyInfo.GetCurrencyInfo(cid)
          local nm = info and info.name or ""
          if type(nm) == "string" and nm:lower():find("bronze", 1, true) then
            total = total + amount
          end
        end
      end
    end
    return total
  end

  local totalSlots = GetMerchantNumItems() or 0
  for slot = 1, totalSlots do
    local link = GetMerchantItemLink(slot)
    if link then
      local b = bronzeCost(slot) or 0

      -- Classify once, in strict order to avoid overlaps
      local isMount = DetectMount(slot, link)
      local isPet   = (not isMount) and DetectPet(slot, link) or false
      local isToy   = (not isMount and not isPet) and DetectToy(slot, link) or false
      local isSet   = (not isMount and not isPet and not isToy) and IsEnsemble(link) or false

      local any, known = false, false

      if isSet then
        any = true
        out.sets.total = out.sets.total + b
        out.sets.count = out.sets.count + 1
        if IsKnownSet(slot, link) then
          out.sets.known = out.sets.known + b
          known = true
        end
      elseif isMount then
        any = true
        out.mounts.total = out.mounts.total + b
        out.mounts.count = out.mounts.count + 1
        if IsMountKnown(link) then
          out.mounts.known = out.mounts.known + b
          known = true
        end
      elseif isPet then
        any = true
        out.pets.total = out.pets.total + b
        out.pets.count = out.pets.count + 1
        if IsPetKnown(slot, link) then
          out.pets.known = out.pets.known + b
          known = true
        end
      elseif isToy then
        any = true
        out.toys.total = out.toys.total + b
        out.toys.count = out.toys.count + 1
        if IsToyKnown(slot, link) then
          out.toys.known = out.toys.known + b
          known = true
        end
      end

      if any then
        out.countTotal = out.countTotal + 1
        if known then out.countKnown = out.countKnown + 1 end
      end
    end
  end

  return out
end

-- --- Internal: write text into the mini panel using current stats (now includes Sets)
local function VKF_FillMiniWithBreakdown(f)
  local stats = VKF_BuildCategoryBreakdown()
  local known = stats.countKnown or 0
  local total = stats.countTotal or 0

  local function fmt(n)
    return "|cffffffff" .. (BreakUpLargeNumbers and BreakUpLargeNumbers(n or 0) or tostring(n or 0)) .. "|r"
  end

  -- Title
  f.title:SetText(string.format("Breakdown (%d/%d)", known, total))

  -- Build rows only for categories detected on this vendor
  local rows = {}
  if stats.sets   and (stats.sets.count   or 0) > 0 then  table.insert(rows,   ("Sets Total:   %s / %s"):format(fmt(stats.sets.known),   fmt(stats.sets.total)))   end
  if stats.mounts and (stats.mounts.count or 0) > 0 then  table.insert(rows, ("Mounts Total: %s / %s"):format(fmt(stats.mounts.known), fmt(stats.mounts.total))) end
  if stats.pets   and (stats.pets.count   or 0) > 0 then  table.insert(rows,   ("Pets Total:   %s / %s"):format(fmt(stats.pets.known),   fmt(stats.pets.total)))   end
  if stats.toys   and (stats.toys.count   or 0) > 0 then  table.insert(rows,   ("Toys Total:   %s / %s"):format(fmt(stats.toys.known),   fmt(stats.toys.total)))   end

  -- Ensure the three line FontStrings exist
  if not f.line1 then f.line1 = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall") end
  if not f.line2 then f.line2 = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall") end
  if not f.line3 then f.line3 = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall") end

  -- Layout & fill
  f.line1:ClearAllPoints(); f.line1:SetPoint("TOPLEFT", f.title, "BOTTOMLEFT", 0, -8)
  local used = #rows

  if used >= 1 then f.line1:SetText(rows[1]); f.line1:Show() else f.line1:Hide() end

  f.line2:ClearAllPoints(); f.line2:SetPoint("TOPLEFT", f.line1, "BOTTOMLEFT", 0, -6)
  if used >= 2 then f.line2:SetText(rows[2]); f.line2:Show() else f.line2:Hide() end

  f.line3:ClearAllPoints(); f.line3:SetPoint("TOPLEFT", (f.line2:IsShown() and f.line2 or f.line1), "BOTTOMLEFT", 0, -6)
  if used >= 3 then f.line3:SetText(rows[3]); f.line3:Show() else f.line3:Hide() end

  -- Auto height
  local baseH, perRow = 54, 16
  local h = math.max(70, baseH + perRow * used)
  if f.SetHeight then f:SetHeight(h) end
end



  function VKF_EnsureMiniPanel(anchorFrame)
    if VKF_MiniPanel then return end
    local f = CreateFrame("Frame", "VKF_HKA_Mini", UIParent, "BackdropTemplate")
    VKF_MiniPanel = f
	_G.VKF_MiniPanel = VKF_MiniPanel  -- export for other code paths

-- add this once, near your mini functions:
function VKF_HideMini()
  if _G.VKF_MiniPanel and _G.VKF_MiniPanel.Hide then
    _G.VKF_MiniPanel:Hide()
  end
end
_G.VKF_HideMini = VKF_HideMini
	
    f:SetFrameStrata("TOOLTIP")
    f:SetClampedToScreen(true)
    f:SetSize(280, 110)
    f:SetBackdrop({
      bgFile   = "Interface/Tooltips/UI-Tooltip-Background",
      edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
      tile = true, tileSize = 16, edgeSize = 12,
      insets   = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    f:SetBackdropColor(0,0,0,0.92)
    f:SetBackdropBorderColor(0,0,0,1)

    f.title = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    f.title:SetPoint("TOPLEFT", 8, -8)

    f.line1 = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    f.line1:SetPoint("TOPLEFT", f.title, "BOTTOMLEFT", 0, -8)

    f.line2 = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    f.line2:SetPoint("TOPLEFT", f.line1, "BOTTOMLEFT", 0, -6)

    f.line3 = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    f.line3:SetPoint("TOPLEFT", f.line2, "BOTTOMLEFT", 0, -6)


    f:SetPropagateKeyboardInput(true)
    f:EnableKeyboard(true)
    f:SetScript("OnKeyDown", function(self, key)
      if key == "ESCAPE" then self:Hide() end
    end)

    -- First fill (safe default)
    VKF_FillMiniWithBreakdown(f)
  end

 function VKF_ShowMini(anchorFrame)
  VKF_EnsureMiniPanel(anchorFrame)
  local f = VKF_MiniPanel
  if not f then return end

  VKF_FillMiniWithBreakdown(f)

  -- Parent to MerchantFrame so it hides on vendor close
  local parent = MerchantFrame or UIParent
  f:SetParent(parent)
  f:SetFrameStrata("DIALOG")
  f:SetToplevel(true)
  f:SetFrameLevel(((VKF_TotalsPanel and VKF_TotalsPanel:GetFrameLevel()) or 20) + 50)

  f:ClearAllPoints()
  if VKF_TotalsPanel and VKF_TotalsPanel:IsShown() then
    f:SetPoint("TOPLEFT", VKF_TotalsPanel, "BOTTOMLEFT", VKF_MiniOffsetX, VKF_MiniOffsetY)
  elseif anchorFrame and anchorFrame.GetCenter and anchorFrame:IsShown() then
    f:SetPoint("TOPLEFT", anchorFrame, "BOTTOMLEFT", VKF_MiniOffsetX, VKF_MiniOffsetY)
  else
    f:SetPoint("CENTER", parent, "CENTER", 0, 0)
  end

  f:Show()
end

  function VKF_ToggleMini(anchorFrame)
    if VKF_MiniPanel and VKF_MiniPanel:IsShown() then
      VKF_MiniPanel:Hide()
    else
      VKF_ShowMini(anchorFrame)
    end
  end

  -- make sure they’re reachable as globals too
  _G.VKF_EnsureMiniPanel = VKF_EnsureMiniPanel
  _G.VKF_ShowMini        = VKF_ShowMini
  _G.VKF_ToggleMini      = VKF_ToggleMini
end




----------------------------------------------------------------
-- TOTALS (under menu) – stock tooltip styling
----------------------------------------------------------------
local VKF_TotalsPanel

local function EnsureTotalsPanel()
  if VKF_TotalsPanel then return end
  VKF_TotalsPanel = CreateFrame("Frame", "VKF_HKA_Totals", UIParent, "BackdropTemplate")
  VKF_TotalsPanel:SetHeight(VKF_TotalsState.h or 56)
  VKF_TotalsPanel:SetFrameStrata("DIALOG")
  VKF_TotalsPanel:SetBackdrop({
    bgFile   = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 12,
    insets   = { left = 4, right = 4, top = 4, bottom = 4 }
  })
  VKF_TotalsPanel:SetBackdropColor(0,0,0,0.90)
  VKF_TotalsPanel:SetBackdropBorderColor(0,0,0,1)

  VKF_TotalsPanel:SetResizable(true)
  if VKF_TotalsPanel.SetResizeBounds then VKF_TotalsPanel:SetResizeBounds(200, 40, 2000, 260) end
  local sizer = CreateFrame("Button", nil, VKF_TotalsPanel)
  sizer:SetPoint("BOTTOMRIGHT", -2, 2)
  sizer:SetSize(16,16)
  sizer:SetNormalTexture("Interface/ChatFrame/UI-ChatIM-SizeGrabber-Up")
  sizer:SetHighlightTexture("Interface/ChatFrame/UI-ChatIM-SizeGrabber-Highlight")
  sizer:SetPushedTexture("Interface/ChatFrame/UI-ChatIM-SizeGrabber-Down")
  sizer:SetScript("OnMouseDown", function(self, btn)
    if btn == "LeftButton" then self:GetParent():StartSizing("BOTTOMRIGHT") end
  end)
  sizer:SetScript("OnMouseUp", function(self)
    local p = self:GetParent(); p:StopMovingOrSizing()
    VKF_TotalsState.h = select(2, p:GetSize())
  end)
  VKF_TotalsPanel:SetScript("OnSizeChanged", function(_, _, h) VKF_TotalsState.h = h end)

  local title = VKF_TotalsPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  title:SetPoint("TOPLEFT", 8, -6); title:SetText("Unlearned Total")

  VKF_TotalsPanel.money = CreateFrame("Frame", nil, VKF_TotalsPanel, "SmallMoneyFrameTemplate")
  VKF_TotalsPanel.money:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -4)
  
  VKF_TotalsPanel:HookScript("OnSizeChanged", function()
  if VKF_MiniPanel and VKF_MiniPanel:IsShown() then
    VKF_ShowMini(VKF_TotalsPanel)  -- reapply anchor with the same offsets
  end
end)
  
  -- === BRONZE BUTTON (styled EXACTLY like AddLine rows) ===
  if not VKF_TotalsPanel.bronzeBtn then
    local b = CreateFrame("Button", nil, VKF_TotalsPanel, "BackdropTemplate")
    VKF_TotalsPanel.bronzeBtn = b

    -- Place it to the right of the existing currency line; move if you prefer
    b:SetPoint("LEFT", VKF_TotalsPanel.money, "RIGHT", 12, 0)
    b:SetFrameStrata("DIALOG")
    b:SetFrameLevel((VKF_TotalsPanel:GetFrameLevel() or 20) + 10)

    -- Icon: same size as AddLine()
    b.icon = b:CreateTexture(nil, "ARTWORK")
    b.icon:SetSize(14, 14)
    b.icon:SetPoint("LEFT", b, "LEFT", 6, 0)

    -- Text: same font template and inline color formatting as AddLine()
    b.text = b:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    b.text:SetPoint("LEFT", b.icon, "RIGHT", 6, 0)
    b.text:SetJustifyH("LEFT")

    -- Hover highlight (subtle, like tooltip rows)
    b.hl = b:CreateTexture(nil, "HIGHLIGHT")
    b.hl:SetTexture("Interface/Buttons/UI-Listbox-Highlight2")
    b.hl:SetBlendMode("ADD")
    b.hl:SetVertexColor(1,1,1,0.15)
    b.hl:SetAllPoints(b)

    b:RegisterForClicks("AnyUp")
    b:SetScript("OnClick", function(self, btn)
      if btn == "LeftButton" then
        VKF_ToggleMini(self)
        if PlaySound and SOUNDKIT then
          PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
        end
      end
    end)

    b:Hide() -- shown once we have data in UpdateTotalsUI()
  end


  VKF_TotalsPanel.lines = {}
end

local function AnchorTotalsToMenu()
  EnsureTotalsPanel()
  if not _G.VKF_MenuPanel then return end
  if VKF_TotalsPanel:GetParent() ~= _G.VKF_MenuPanel then
    VKF_TotalsPanel:SetParent(_G.VKF_MenuPanel)
  end
  VKF_TotalsPanel:ClearAllPoints()
  VKF_TotalsPanel:SetPoint("TOPLEFT",  _G.VKF_MenuPanel, "BOTTOMLEFT",  0, VKF_TotalsState.yOff or -2)
  VKF_TotalsPanel:SetPoint("TOPRIGHT", _G.VKF_MenuPanel, "BOTTOMRIGHT", 0, VKF_TotalsState.yOff or -2)
end



local function ClearTotalsLines(panel)
  for _, r in ipairs(panel.lines) do
    if r.icon then r.icon:Hide() end
    if r.text then r.text:Hide() end
  end
  wipe(panel.lines)
end

local function AddLine(panel, iconFile, label, amount, yOff)
  local row = {}
  row.icon = panel:CreateTexture(nil, "ARTWORK")
  row.icon:SetSize(14,14); row.icon:SetPoint("TOPLEFT", 6, yOff); row.icon:SetTexture(iconFile)
  row.text = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  row.text:SetPoint("LEFT", row.icon, "RIGHT", 6, 0)
  row.text:SetText(("%s: |cffffffff%s|r"):format(label, BreakUpLargeNumbers(amount or 0)))
  table.insert(panel.lines, row)
end

local function BuildTotals()
  local totals = { money = 0, cur = {}, itm = {} }
  local totalSlots = GetMerchantNumItems()
  for slot = 1, totalSlots do
    local link = GetMerchantItemLink(slot)
    local function CountThis()
      if IsEnsemble(link) then
        if VKF_SkipUnavail_Sets and TooltipIsTemporarilyUnavailable(slot) then return false end
        return not IsKnownSet(slot, link)
      end
      if ItemTeachesMount(link) then
        if VKF_SkipUnavail_Mounts and TooltipIsTemporarilyUnavailable(slot) then return false end
        return not IsMountKnown(link)
      end
      if ItemTeachesPet(slot, link) then
        if VKF_SkipUnavail_Pets and TooltipIsTemporarilyUnavailable(slot) then return false end
        return not IsPetKnown(slot, link)
      end
      if ItemTeachesToy(slot, link) then
        if VKF_SkipUnavail_Toys and TooltipIsTemporarilyUnavailable(slot) then return false end
        return not IsToyKnown(slot, link)
      end
      return false
    end
    if CountThis() then
      local price = select(3, GetMerchantItemInfo(slot)); if price and price > 0 then totals.money = totals.money + price end
      local nAlt = GetMerchantItemCostInfo(slot) or 0
      for i = 1, nAlt do
        local tex, amount, costLink = GetMerchantItemCostItem(slot, i)
        if amount and amount > 0 and costLink then
          local curID = C_CurrencyInfo and C_CurrencyInfo.GetCurrencyIDFromLink(costLink)
          if curID then
            local key = "currency:"..curID
            local info = C_CurrencyInfo.GetCurrencyInfo(curID)
            local entry = totals.cur[key] or { name = info and info.name or ("Currency "..curID), icon = info and info.iconFileID or tex, amount = 0 }
            entry.amount = entry.amount + amount; totals.cur[key] = entry
          else
            local itemID = GetItemInfoInstant(costLink)
            if itemID then
              local key = "item:"..itemID
              local name, _, _, _, _, _, _, _, _, icon = GetItemInfo(itemID)
              local entry = totals.itm[key] or { name = name or ("Item "..itemID), icon = icon or tex, amount = 0 }
              entry.amount = entry.amount + amount; totals.itm[key] = entry
            end
          end
        end
      end
    end
  end
  return totals
end

----------------------------------------------------------------
-- BREAKDOWN BUILDER (for Bronze click)
----------------------------------------------------------------
local function BuildCategoryBreakdown()
  local data = {
    pets = { total = 0, known = 0 },
    toys = { total = 0, known = 0 },
    countTotal = 0,
    countKnown = 0,
  }

  local totalSlots = GetMerchantNumItems()
  for slot = 1, totalSlots do
    local link = GetMerchantItemLink(slot)
    if link then
      local price = select(3, GetMerchantItemInfo(slot)) or 0

      local isPet = ItemTeachesPet(slot, link)
      local isToy = ItemTeachesToy(slot, link)
      local isKnown = false

      if isPet then
        data.pets.total = data.pets.total + price
        if IsPetKnown(slot, link) then
          data.pets.known = data.pets.known + price
          isKnown = true
        end
      elseif isToy then
        data.toys.total = data.toys.total + price
        if IsToyKnown(slot, link) then
          data.toys.known = data.toys.known + price
          isKnown = true
        end
      end

      if isPet or isToy then
        data.countTotal = data.countTotal + 1
        if isKnown then data.countKnown = data.countKnown + 1 end
      end
    end
  end

  return data
end


local function UpdateTotalsUI()
  AnchorTotalsToMenu()
  if not VKF_TotalsPanel then return end
  local totals = BuildTotals()
  if totals.money and totals.money > 0 then
    MoneyFrame_Update(VKF_TotalsPanel.money, totals.money); VKF_TotalsPanel.money:Show()
  else
    VKF_TotalsPanel.money:Hide()
  end
  ClearTotalsLines(VKF_TotalsPanel)
  -- === Clickable Bronze line: compute directly from totals, not mirroring ===
do
  local b = VKF_TotalsPanel and VKF_TotalsPanel.bronzeBtn
  if b then
    -- Find Bronze (by name), else largest currency
    local pick, bestAmt
    for _, e in pairs(totals.cur or {}) do
      local nm = (e.name or ""):lower()
      if nm:find("bronze", 1, true) then pick = e; break end
      if e.amount and e.amount > 0 then
        if not bestAmt or e.amount > bestAmt then bestAmt = e.amount; pick = e end
      end
    end

    if pick and pick.amount and pick.amount > 0 then
      -- Style EXACTLY like AddLine(): 14x14 icon + "Label: |cffffffffamount|r"
      if pick.icon then b.icon:SetTexture(pick.icon) else b.icon:SetTexture(132622) end
      local amtText = BreakUpLargeNumbers and BreakUpLargeNumbers(pick.amount) or tostring(pick.amount)
      local label   = pick.name or "Bronze"
      b.text:SetText( string.format("%s: |cffffffff%s|r", label, amtText) )
      b.text:SetJustifyH("LEFT")

      -- Size and position identical to first AddLine row
      local w = 6 + 14 + 6 + b.text:GetStringWidth() + 6
      b:SetSize(w, 16)
      b:ClearAllPoints()
      b:SetPoint("TOPLEFT", VKF_TotalsPanel, "TOPLEFT", 6, -24)  -- same slot as the old left line
      b:Show()
    else
      b:Hide()
    end
  end
end
  local y = -24
  -- for _, e in pairs(totals.cur) do AddLine(VKF_TotalsPanel, e.icon, e.name, e.amount, y); y = y - 16 end
  for _, e in pairs(totals.itm) do AddLine(VKF_TotalsPanel, e.icon, e.name, e.amount, y); y = y - 16 end
  VKF_TotalsPanel:Show()
  
  -- === Fill the bronze button to match the left line exactly ===
  do
    local b = VKF_TotalsPanel and VKF_TotalsPanel.bronzeBtn
    if b then
      local pick -- choose which currency to mirror (prefer Bronze by name)
      for _, entry in pairs(totals.cur or {}) do
        local nm = entry.name and entry.name:lower() or ""
        if nm:find("bronze", 1, true) then pick = entry; break end
      end
      -- fallback: take the largest currency if "Bronze" wasn’t found
      if not pick then
        local bestAmt
        for _, entry in pairs(totals.cur or {}) do
          if type(entry.amount) == "number" and entry.amount > 0 then
            if not bestAmt or entry.amount > bestAmt then
              bestAmt = entry.amount; pick = entry
            end
          end
        end
      end

      if pick and pick.amount and pick.amount > 0 then
        -- icon identical size; text identical format "Name: |cffffffffamount|r"
        if pick.icon then b.icon:SetTexture(pick.icon) end
        local amtText = BreakUpLargeNumbers and BreakUpLargeNumbers(pick.amount) or tostring(pick.amount)
        local label   = pick.name or "Bronze"
        b.text:SetText( string.format("%s: |cffffffff%s|r", label, amtText) )

        -- compute button width to fit icon + text exactly like a row
        local w = 6 + 14 + 6 + b.text:GetStringWidth() + 6
        b:SetSize(w, 16)
        b:Show()
      else
        b:Hide()
      end
    end
  end

end

----------------------------------------------------------------
-- PAGER (based on FILTERED results)
----------------------------------------------------------------
local function VKF_GetPagerBits()
  local prev = _G.MerchantPrevPageButton or (_G.MerchantFrame and _G.MerchantFrame.PrevPageButton)
  local nextb= _G.MerchantNextPageButton or (_G.MerchantFrame and _G.MerchantFrame.NextPageButton)
  local text = _G.MerchantPageText or (_G.MerchantFrame and _G.MerchantFrame.PageText)
  return prev, nextb, text
end

----------------------------------------------------------------
-- FIXED: pager respects filtered item count
----------------------------------------------------------------
local function VKF_UpdatePager(filteredCount)
  local per = MERCHANT_ITEMS_PER_PAGE or 10
  local total = filteredCount or 0
  local pages = math.max(1, math.ceil(total / per))
  local page  = MerchantFrame.page or 1

  -- Clamp page if it's now too high
  if page > pages then page = pages end
  if page < 1 then page = 1 end
  MerchantFrame.page = page

  local prev = _G.MerchantPrevPageButton or (_G.MerchantFrame and _G.MerchantFrame.PrevPageButton)
  local nextb = _G.MerchantNextPageButton or (_G.MerchantFrame and _G.MerchantFrame.NextPageButton)
  local text = _G.MerchantPageText or (_G.MerchantFrame and _G.MerchantFrame.PageText)

  if prev and prev.Enable and prev.Disable then
    if page > 1 then prev:Enable() else prev:Disable() end
  end
  if nextb and nextb.Enable and nextb.Disable then
    if page < pages then nextb:Enable() else nextb:Disable() end
  end

  if text and text.SetText then
    local fmt = _G.MERCHANT_PAGE_NUMBER or "Page %d of %d"
    text:SetText(fmt:format(page, pages))
  end

  -- Optional polish: hide arrows if only 1 page
  if pages <= 1 then
    if prev and prev.Hide then prev:Hide() end
    if nextb and nextb.Hide then nextb:Hide() end
  else
    if prev and prev.Show then prev:Show() end
    if nextb and nextb.Show then nextb:Show() end
  end

  return page, pages
end

----------------------------------------------------------------
-- REFRESH (always-compact + totals + filtered pager)
----------------------------------------------------------------
function HKA:Refresh()
  if inRefresh then return end
  inRefresh = true
  pcall(function()
    if not (MerchantFrame and MerchantFrame:IsShown()) then return end

    local per      = MERCHANT_ITEMS_PER_PAGE or 10
    local filtered = BuildFilteredSlots()
    local page     = select(1, VKF_UpdatePager(#filtered))
    local first    = (page - 1) * per + 1

    ------------------------------------------------------
    -- Step 1: let Blizzard paint prices while remapped
    ------------------------------------------------------
    VKF_WithRemappedMerchant(first, filtered, function()
      if MerchantFrame_Update then
        MerchantFrame_Update()
      elseif MerchantFrame_UpdateMerchant then
        MerchantFrame_UpdateMerchant()
      end
    end)

    ------------------------------------------------------
    -- Step 2: repaint name/icon/text using your PaintRow
    ------------------------------------------------------
    for i = 1, per do
      PaintRow(i, filtered[first + i - 1])
    end

    ------------------------------------------------------
    -- Step 3: fix IDs so purchase clicks the right slot
    ------------------------------------------------------
    for i = 1, per do
      local row = _G["MerchantItem"..i]
      local btn = row and (row.ItemButton or _G["MerchantItem"..i.."ItemButton"])
      local realSlot = filtered[first + i - 1]
      if row and btn then
        if realSlot then
          row.index = realSlot
          btn:SetID(realSlot)
          row:Show()
        else
          row:Hide()
        end
      end
    end
	-- Re-apply pager using the filtered count (Blizzard just overwrote it)
	VKF_UpdatePager(#filtered)
    ------------------------------------------------------
    -- Step 4: update totals panel (unchanged)
    ------------------------------------------------------
    UpdateTotalsUI()
  end)
  inRefresh = false
end

function HKA:RepaintOnly()
  if inRefresh then return end
  if not (MerchantFrame and MerchantFrame:IsShown()) then return end
  inRefresh = true
  pcall(function()
    local per      = MERCHANT_ITEMS_PER_PAGE or 10
    local filtered = BuildFilteredSlots()
    local page     = select(1, VKF_UpdatePager(#filtered))
    local first    = (page - 1) * per + 1
	
	-- Debug ping: show filtered count in the page header briefly
local total = GetMerchantNumItems() or 0
local shown = math.min(#filtered - (first-1), MERCHANT_ITEMS_PER_PAGE or 10)
shown = math.max(0, shown)
print(("VKF repaint: total=%d, filtered=%d, page=%d, showing=%d")
      :format(total, #filtered, page, shown))

local pageText = _G.MerchantPageText
if pageText and pageText.SetText then
  local old = pageText:GetText()
  pageText:SetText((old or "").."  |cff50fa7b(repaint)|r")
  C_Timer.After(0.8, function() if pageText and old then pageText:SetText(old) end end)
end

    -- Remap merchant getters WHILE we repaint, so Blizzard row paint uses our filtered slots.
    VKF_WithRemappedMerchant(first, filtered, function()
      for i = 1, per do
        PaintRow(i, filtered[first + i - 1])
      end
    end)

    -- Fix IDs so clicks buy the right slot
    for i = 1, per do
      local row = _G["MerchantItem"..i]
      local btn = row and (row.ItemButton or _G["MerchantItem"..i.."ItemButton"])
      local realSlot = filtered[first + i - 1]
      if row and btn then
        if realSlot then
          row.index = realSlot
          btn:SetID(realSlot)
          row:Show()
        else
          row:Hide()
        end
      end
    end

    -- Re-assert pager (Blizzard may have touched it)
    VKF_UpdatePager(#filtered)

    UpdateTotalsUI()
  end)
  inRefresh = false
end




hooksecurefunc("MerchantFrame_Update", function()
  if MerchantFrame and MerchantFrame:IsShown() then HKA:Refresh() end
end)

----------------------------------------------------------------
-- GEAR BUTTON + POSITION NEAR FILTER DROPDOWN
----------------------------------------------------------------
local VKF_MenuButton

local GEAR_ATLASES = {
  "commonoptions-gear","OptionsIcon-Brown","OptionsIcon-White",
  "Settings_Gear","commonoptions-gear-64x64",
}
local function TrySetGearAtlas(tex)
  if not tex or not C_Texture or not C_Texture.GetAtlasInfo then return false end
  for _, atlas in ipairs(GEAR_ATLASES) do
    local info = C_Texture.GetAtlasInfo(atlas)
    if info then tex:SetAtlas(atlas, true) return true end
  end
  return false
end

local function EnsureMenuButton()
  if VKF_MenuButton then return end
  VKF_MenuButton = CreateFrame("Button", "VKF_HKA_Gear", MerchantFrame)
  VKF_MenuButton:SetSize(24, 24)
  VKF_MenuButton:SetPoint("TOPRIGHT", MerchantFrame, "TOPRIGHT", -220, -6)
  VKF_MenuButton:SetFrameStrata("DIALOG")
  VKF_MenuButton:SetFrameLevel(MerchantFrame:GetFrameLevel() + 30)

  local ico = VKF_MenuButton:CreateTexture(nil, "ARTWORK")
  ico:SetPoint("CENTER"); ico:SetSize(20, 20)
  if not TrySetGearAtlas(ico) then
    ico:SetTexture("Interface/Buttons/UI-OptionsButton")
    ico:SetTexCoord(0.1, 0.9, 0.1, 0.9)
  end

  local hl = VKF_MenuButton:CreateTexture(nil, "HIGHLIGHT")
  hl:SetTexture("Interface/Buttons/UI-Common-MouseHilight")
  hl:SetBlendMode("ADD")
  hl:SetAllPoints(VKF_MenuButton)

  VKF_MenuButton:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
    GameTooltip:AddLine("What's Left?", 1,1,1)
    GameTooltip:AddLine("Click to see what's left to learn.", .9,.9,.9)
    GameTooltip:Show()
  end)
  VKF_MenuButton:SetScript("OnLeave", function() GameTooltip:Hide() end)
end

local function VKF_FindFilterDropdown()
  local cand = _G.MerchantFrameFilterDropdown
           or (MerchantFrame and (MerchantFrame.filterDropdown or MerchantFrame.FilterDropdown or MerchantFrame.FilterDropDown or MerchantFrame.LootFilterDropdown))
  if cand and cand.GetObjectType and cand:IsShown() then return cand end

  local best, scoreBest
  local function score(f)
    if not (f and f.GetObjectType and f:IsShown()) then return nil end
    local n = f.GetName and f:GetName() or ""
    local w = f.GetWidth and f:GetWidth() or 0
    local h = f.GetHeight and f:GetHeight() or 0
    local s = 0
    if n:find("DropDown") or n:find("Filter") then s = s + 4 end
    if w >= 80 and w <= 260 then s = s + 2 end
    if h >= 18 and h <= 32 then s = s + 2 end
    for _, r in ipairs{ f:GetRegions() } do
      if r and r.GetObjectType and r:GetObjectType() == "FontString" and r:GetText() and r:GetText() ~= "" then s = s + 2; break end
    end
    return s
  end
  local function scan(frame, depth)
    if not frame or depth > 4 then return end
    local s = score(frame)
    if s and (not best or s > scoreBest) then best, scoreBest = frame, s end
    for _, child in ipairs{ frame:GetChildren() } do scan(child, depth + 1) end
  end
  if MerchantFrame then scan(MerchantFrame, 1) end
  return best
end

local function PositionGearNearFilter()
  if not VKF_MenuButton or not MerchantFrame then return end
  VKF_MenuButton:ClearAllPoints()
  local dd = VKF_FindFilterDropdown()
  if dd then
    VKF_MenuButton:SetPoint("RIGHT", dd, "LEFT", -1, 0)
    VKF_MenuButton:SetFrameStrata(dd:GetFrameStrata() or "DIALOG")
    VKF_MenuButton:SetFrameLevel((dd:GetFrameLevel() or 20) + 5)
  else
    VKF_MenuButton:SetPoint("TOPRIGHT", MerchantFrame, "TOPRIGHT", -220, -6)
    VKF_MenuButton:SetFrameStrata("DIALOG")
    VKF_MenuButton:SetFrameLevel(MerchantFrame:GetFrameLevel() + 30)
  end
end

local function PositionGearNearFilterWithRetries()
  PositionGearNearFilter()
  if C_Timer then
    C_Timer.After(0.05, PositionGearNearFilter)
    C_Timer.After(0.15, PositionGearNearFilter)
  end
end

----------------------------------------------------------------
-- MENU PANEL (movable+resizable, created lazily; no top-level use)
----------------------------------------------------------------
function EnsureMenuPanel()
  if _G.VKF_MenuPanel then return end
  local S = VKF_MenuPanelState or {}
  if type(S.w) ~= "number" then S.w = 300 end
  if type(S.h) ~= "number" then S.h = 268 end
  if type(S.locked) ~= "boolean" then S.locked = false end
  VKF_MenuPanelState = S; _G.VKF_MenuPanelState = S

  local panel = CreateFrame("Frame", "VKF_HKA_MenuPanel", UIParent, "BackdropTemplate")
  _G.VKF_MenuPanel = panel

  panel:SetSize(S.w, S.h)
  if S.point and S.relPoint and type(S.x) == "number" and type(S.y) == "number" then
    panel:SetPoint(S.point, UIParent, S.relPoint, S.x, S.y)
  else
    panel:SetPoint("TOPLEFT", MerchantFrame, "TOPRIGHT", 4, 0)
  end
  panel:SetScale(1.0)
  panel:SetFrameStrata("DIALOG")
  panel:SetClampedToScreen(true)
  panel:SetBackdrop({
    bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 12,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
  })
  panel:SetBackdropColor(0,0,0,0.92)
  panel:SetBackdropBorderColor(0,0,0,1)

  -- Movable
  panel:EnableMouse(true)
  panel:SetMovable(true)
  panel:SetScript("OnMouseDown", function(self, btn)
    if btn == "LeftButton" and not S.locked then self._moving = true; self:StartMoving() end
  end)
  panel:SetScript("OnMouseUp", function(self)
    if self._moving then
      self._moving = nil; self:StopMovingOrSizing()
      local point, _, relPoint, x, y = self:GetPoint(1)
      S.point, S.relPoint, S.x, S.y = point, relPoint, x, y
      AnchorTotalsToMenu()
    end
  end)
  panel:SetScript("OnShow", function() AnchorTotalsToMenu(); PositionGearNearFilterWithRetries() end)
  
  _G.VKF_MenuPanel:HookScript("OnHide", function()
  if VKF_TotalsPanel and VKF_TotalsPanel.Hide then VKF_TotalsPanel:Hide() end
  if VKF_MiniPanel   and VKF_MiniPanel.Hide   then VKF_MiniPanel:Hide()   end
end)

  -- Title
  local title = CreateFrame("Frame", nil, panel)
  title:SetPoint("TOPLEFT", 6, -6); title:SetPoint("TOPRIGHT", -24, -6); title:SetHeight(22)
  local titleText = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
  titleText:SetPoint("LEFT", title, "LEFT", 4, -1); titleText:SetText("What's Left?")

  -- Close (X)
-- Minimal, TSM-like close button (slightly thicker + smaller)
local close = CreateFrame("Button", nil, panel, "BackdropTemplate")
panel.Close = close
close:SetSize(19, 19)
close:SetPoint("TOPRIGHT", -6, -6)
close:SetHitRectInsets(-3, -3, -3, -3)

local function makeStroke(parent)
  local t = parent:CreateTexture(nil, "ARTWORK")
  t:SetTexture("Interface\\BUTTONS\\WHITE8x8")
  t:SetSize(14, 4)
  t:SetPoint("CENTER")
  return t
end

close.stroke1 = makeStroke(close)
close.stroke2 = makeStroke(close)
close.stroke1:SetRotation(math.rad(45))
close.stroke2:SetRotation(math.rad(-45))

-- 🎨 color palette
local IDLE_R, IDLE_G, IDLE_B = 0.85, 0.85, 0.85   -- normal gray
local HOVER_R, HOVER_G, HOVER_B = 0.35, 0.65, 1.00 -- blue highlight
local DOWN_R, DOWN_G, DOWN_B  = 0.25, 0.45, 0.85  -- pressed blue

-- set starting color
close.stroke1:SetVertexColor(IDLE_R, IDLE_G, IDLE_B, 1)
close.stroke2:SetVertexColor(IDLE_R, IDLE_G, IDLE_B, 1)

close:SetScript("OnEnter", function(self)
  self.stroke1:SetVertexColor(HOVER_R, HOVER_G, HOVER_B, 1)
  self.stroke2:SetVertexColor(HOVER_R, HOVER_G, HOVER_B, 1)
end)
close:SetScript("OnLeave", function(self)
  self.stroke1:SetVertexColor(IDLE_R, IDLE_G, IDLE_B, 1)
  self.stroke2:SetVertexColor(IDLE_R, IDLE_G, IDLE_B, 1)
end)
close:SetScript("OnMouseDown", function(self)
  self.stroke1:SetVertexColor(DOWN_R, DOWN_G, DOWN_B, 1)
  self.stroke2:SetVertexColor(DOWN_R, DOWN_G, DOWN_B, 1)
end)
close:SetScript("OnMouseUp", function(self)
  if self:IsMouseOver() then
    self.stroke1:SetVertexColor(HOVER_R, HOVER_G, HOVER_B, 1)
    self.stroke2:SetVertexColor(HOVER_R, HOVER_G, HOVER_B, 1)
  else
    self.stroke1:SetVertexColor(IDLE_R, IDLE_G, IDLE_B, 1)
    self.stroke2:SetVertexColor(IDLE_R, IDLE_G, IDLE_B, 1)
  end
end)

close:SetScript("OnClick", function() panel:Hide() end)


  -- Resizable + click-to-lock
  panel:SetResizable(true)
  if panel.SetResizeBounds then panel:SetResizeBounds(240, 180, 640, 540) end
  local sizer = CreateFrame("Button", nil, panel); panel._sizer = sizer
  sizer:SetPoint("BOTTOMRIGHT", -2, 2); sizer:SetSize(16,16)
  sizer:SetNormalTexture("Interface/ChatFrame/UI-ChatIM-SizeGrabber-Up")
  sizer:SetHighlightTexture("Interface/ChatFrame/UI-ChatIM-SizeGrabber-Highlight")
  sizer:SetPushedTexture("Interface/ChatFrame/UI-ChatIM-SizeGrabber-Down")
  sizer:SetScript("OnMouseDown", function(self, btn)
    if btn == "LeftButton" then
      self._startW, self._startH = panel:GetSize()
      if not S.locked then self._resizing = true; panel:StartSizing("BOTTOMRIGHT") end
    end
  end)
  sizer:SetScript("OnMouseUp", function(self)
    if self._resizing then
      panel:StopMovingOrSizing(); self._resizing = false
      local w, h = panel:GetSize()
      local dw = math.abs(w - (self._startW or w))
      local dh = math.abs(h - (self._startH or h))
      if dw <= 2 and dh <= 2 then
        panel:SetSize(self._startW, self._startH); S.locked = not S.locked; panel:ApplyLock()
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
      else
        S.w, S.h = w, h
      end
      AnchorTotalsToMenu()
    else
      S.locked = not S.locked; panel:ApplyLock()
      PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
    end
  end)
  panel:SetScript("OnSizeChanged", AnchorTotalsToMenu)

  function panel:ApplyLock()
    local locked = S.locked and true or false
    self:SetMovable(not locked)
    self:SetResizable(not locked)

    if not self._lockText then
      self._lockText = self:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    end
    self._lockText:ClearAllPoints()
    self._lockText:SetPoint("BOTTOMRIGHT", -18, 6)
    self._lockText:SetJustifyH("RIGHT")
    self._lockText:SetText(locked and "|cffffffffFrame: |cffff5555Locked|r" or "|cffffffffFrame: |cff88ff88Unlocked|r")

    if self._sizer then
      local n = self._sizer:GetNormalTexture()
      local h = self._sizer:GetHighlightTexture()
      local p = self._sizer:GetPushedTexture()
      if n then n:SetDesaturated(locked and 1 or 0) end
      if h then h:SetDesaturated(locked and 1 or 0) end
      if p then p:SetDesaturated(locked and 1 or 0) end
      self._sizer:SetAlpha(locked and 0.7 or 1)
    end
  end

  -- ---------- Layout helpers (compact rows) ----------
  local ROW_H   = 22
  local LEFT_X  = 12
  local TOP_Y   = -34

  -- track created checkboxes for syncing after /vfreset
  panel._checks = {}

  local function makeCheck(y, label, key, opts)
    opts = opts or {}
    local cb = CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate")
    cb:SetScale(0.90) -- slightly smaller
    cb:SetPoint("TOPLEFT", LEFT_X, y)
    cb.text = cb:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    cb.text:SetPoint("LEFT", cb, "RIGHT", 6, 0)
    cb.text:SetText(label)
    cb:SetScript("OnShow", function(self) self:SetChecked(_G[key] == true) end)
    cb:SetScript("OnClick", function(self)
      _G[key] = self:GetChecked() and true or false
      HKA:Refresh()
      PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
    end)
    if opts.disabled then
      cb:Disable(); cb:SetAlpha(0.7); cb.text:SetTextColor(0.7,0.7,0.7)
      cb:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "ANCHOR_RIGHT"); GameTooltip:AddLine("Coming soon", 1,1,1); GameTooltip:Show() end)
      cb:SetScript("OnLeave", function() GameTooltip:Hide() end)
    end
    table.insert(panel._checks, { cb = cb, key = key })
    return cb
  end

  -- Section 1: Hide Known
  local section1 = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  section1:SetPoint("TOPLEFT", 10, TOP_Y)
  section1:SetText("Hide Known")

  local y = TOP_Y - 22
  makeCheck(y, "Sets",   "VKF_HideSets");   y = y - ROW_H
  makeCheck(y, "Mounts", "VKF_HideMounts"); y = y - ROW_H
  makeCheck(y, "Pets",   "VKF_HidePets");   y = y - ROW_H
  makeCheck(y, "Toys",   "VKF_HideToys");   y = y - ROW_H

  -- spacing controls
  local PAD_BELOW_FIRST    = 18
  local PAD_TITLE_FROM_DIV = 10
  local PAD_FIRST_CHECK    = 30

  local dividerY = (y + ROW_H) - PAD_BELOW_FIRST

  local divider = panel:CreateTexture(nil, "ARTWORK")
  divider:SetColorTexture(1,1,1,0.08)
  divider:SetPoint("TOPLEFT", 10, dividerY)
  divider:SetPoint("TOPRIGHT", -10, dividerY)
  divider:SetHeight(1)

  -- Section 2: Skip Unavailable
  local section2 = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  section2:SetPoint("TOPLEFT", 10, dividerY - PAD_TITLE_FROM_DIV)
  section2:SetText("Hide Currently Unavailable")

  y = dividerY - (PAD_TITLE_FROM_DIV + PAD_FIRST_CHECK)
  makeCheck(y, "Sets",   "VKF_SkipUnavail_Sets");   y = y - ROW_H
  makeCheck(y, "Mounts", "VKF_SkipUnavail_Mounts"); y = y - ROW_H
  makeCheck(y, "Pets",   "VKF_SkipUnavail_Pets");   y = y - ROW_H
  makeCheck(y, "Toys",   "VKF_SkipUnavail_Toys")

  panel:ApplyLock()
  panel:Hide()
end

----------------------------------------------------------------
-- WIRE GEAR BUTTON TOGGLE + POSITIONING
----------------------------------------------------------------
local function WireButton()
  if not VKF_MenuButton or VKF_MenuButton._wired then return end
  VKF_MenuButton._wired = true
  VKF_MenuButton:SetScript("OnClick", function()
    EnsureMenuPanel()
    _G.VKF_MenuPanel:SetShown(not _G.VKF_MenuPanel:IsShown())
    PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
    AnchorTotalsToMenu()
    UpdateTotalsUI()
  end)
end

----------------------------------------------------------------
-- BUILD UI WHEN MERCHANT OPENS
----------------------------------------------------------------
local _vkf_firstOpen = true
local function BuildMenuUI()
  EnsureMenuButton()
  WireButton()
  EnsureMenuPanel()
  PositionGearNearFilterWithRetries()
  AnchorTotalsToMenu()
  UpdateTotalsUI()
  if _vkf_firstOpen then _vkf_firstOpen = false; _G.VKF_MenuPanel:Show() end
end

if MerchantFrame then MerchantFrame:HookScript("OnShow", BuildMenuUI) end

if MerchantFrame then MerchantFrame:HookScript("OnHide", function() VKF_HideMini() end) end

hooksecurefunc("MerchantFrame_Update", function()
  if MerchantFrame and MerchantFrame:IsShown() then PositionGearNearFilterWithRetries() end
end)

-- ============================================================
-- VKF: Event-based popup icon refresher (clean + efficient)
--  - Works for items, toys, battle pets, and weird right-column rows
--  - Only runs while a confirm popup is visible
-- ============================================================

-- ---------- helpers ----------



local function VKF__FindIconRegion(dialog)
  if not dialog or not dialog.GetName then return nil end
  -- common places first
  if dialog.ItemFrame and dialog.ItemFrame.Icon and dialog.ItemFrame.Icon.SetTexture then
    return dialog.ItemFrame.Icon
  end
  if dialog.Icon and dialog.Icon.SetTexture then return dialog.Icon end
  if dialog.icon and dialog.icon.SetTexture then return dialog.icon end
  -- name-based fallbacks
  local n = dialog:GetName()
  if n then
    local g = _G[n.."ItemFrameIconTexture"] or _G[n.."ItemFrameIcon"] or _G[n.."IconTexture"] or _G[n.."AlertIcon"]
    if g and g.SetTexture then return g end
  end
  -- scan regions
  local num = dialog.GetNumRegions and dialog:GetNumRegions() or 0
  for i = 1, num do
    local r = select(i, dialog:GetRegions())
    if r and r.IsObjectType and r:IsObjectType("Texture") and r.SetTexture then
      return r
    end
  end
  -- scan shallow children
  for _, child in ipairs({ dialog:GetChildren() }) do
    if child and child.IsObjectType and child:IsObjectType("Texture") and child.SetTexture then
      return child
    end
    if child and child.ItemFrame and child.ItemFrame.Icon and child.ItemFrame.Icon.SetTexture then
      return child.ItemFrame.Icon
    end
    local rn = child.GetNumRegions and child:GetNumRegions() or 0
    for i = 1, rn do
      local r = select(i, child:GetRegions())
      if r and r.IsObjectType and r:IsObjectType("Texture") and r.SetTexture then
        return r
      end
    end
  end
end

local function VKF__IconFromPetLink(link)
  local id = type(link)=="string" and tonumber(link:match("|Hbattlepet:(%d+):"))
  if id and C_PetJournal and C_PetJournal.GetPetInfoBySpeciesID then
    local _, icon = C_PetJournal.GetPetInfoBySpeciesID(id)
    if icon and icon ~= 0 then return icon end
  end
end

local function VKF__IconFromItemLink(link)
  if type(link)=="string" and link:find("|Hitem:",1,true) then
    local _,_,_,_, icon = GetItemInfoInstant(link)
    if icon and icon ~= 0 then return icon end
  end
end

local function VKF__IconFromSlot(slot)
  if type(slot) ~= "number" or slot <= 0 then return nil end
  local _, tex = GetMerchantItemInfo(slot)
  if tex and tex ~= 0 and tex ~= "" then return tex end
  local link = GetMerchantItemLink(slot)
  return VKF__IconFromItemLink(link)
end

local function VKF__SlotFromDialog(dialog)
  local d = dialog and dialog.data
  if type(d) == "number" then return d end
  if type(d) == "table" then
    return d.index or d.slot or d.merchantSlot or d.slotIndex or d.itemIndex
  end
end

-- ---------- updater (GLOBAL) ----------
function VKF_UpdatePopupIcon(dialog)
  if not (dialog and dialog:IsShown()) then return end

  -- Prefer the link Blizzard attached to the popup (covers pets/toys)
  local link = dialog.itemFrame and dialog.itemFrame.link or nil
  local tex  = VKF__IconFromPetLink(link) or VKF__IconFromItemLink(link)

  -- If link path failed, try merchant slot carried in dialog.data
  if not tex then
    local slot = VKF__SlotFromDialog(dialog)
    if slot then tex = VKF__IconFromSlot(slot) end
  end

  if not tex then return end
  local region = VKF__FindIconRegion(dialog)
  if region then
    pcall(region.SetTexture, region, tex)
    if region.Show then region:Show() end
  end
end
_G.VKF_UpdatePopupIcon = VKF_UpdatePopupIcon  -- export so hooks can call it

-- ---------- lightweight watcher ----------
local VKF_PopupWatcher = CreateFrame("Frame")
local activeDialogs = {}

local function VKF__TickPopups()
  local any = false
  for d in pairs(activeDialogs) do
    if d and d:IsShown() then
      any = true
      VKF_UpdatePopupIcon(d)
    else
      activeDialogs[d] = nil
    end
  end
  if not any then
    VKF_PopupWatcher:SetScript("OnUpdate", nil)
  end
end

local function VKF__EnableWatcher(dialog)
  if not dialog then return end
  activeDialogs[dialog] = true
  VKF_PopupWatcher:SetScript("OnUpdate", VKF__TickPopups)
end

-- Hook the popup lifecycle so the watcher is active only when needed
local function VKF__HookDialogsOnce()
  local N = _G.STATICPOPUP_NUMDIALOGS or 4
  for i = 1, N do
    local d = _G["StaticPopup"..i]
    if d and not d.VKF_Watched then
      d.VKF_Watched = true
      d:HookScript("OnShow", function(self)
        if self.which and self.which:find("CONFIRM_PURCHASE") then
          -- kick one immediate repaint, then enable ticking
          C_Timer.After(0, function() VKF_UpdatePopupIcon(self) end)
          VKF__EnableWatcher(self)
        end
      end)
      d:HookScript("OnHide", function(self)
        activeDialogs[self] = nil
        if not next(activeDialogs) then
          VKF_PopupWatcher:SetScript("OnUpdate", nil)
        end
      end)
    end
  end
end
VKF__HookDialogsOnce()

-- Also catch freshly created dialogs (rare, but cheap)
hooksecurefunc("StaticPopup_Show", function()
  VKF__HookDialogsOnce()
end)

-- =============================
-- Drop-in: Alt-currency color fixer (white if affordable, gray if not)
-- No edits to your functions; robust scan (no reliance on "...Count" names)
-- =============================
local function VKF_RecolorAltCurrencyRow_Scan(rowIndex)
  local row = _G["MerchantItem"..rowIndex]; if not row then return end
  local btn = row.ItemButton or _G["MerchantItem"..rowIndex.."ItemButton"]; if not btn then return end
  local slot = btn:GetID(); if type(slot) ~= "number" or slot <= 0 then return end

  local acf = _G["MerchantItem"..rowIndex.."AltCurrencyFrame"]; if not acf then return end

  -- Build affordability array for this slot (1..nCosts)
  local nCosts = GetMerchantItemCostInfo(slot) or 0
  if nCosts <= 0 then return end
  local canPay = {}
  for i = 1, nCosts do
    local _, need, costLink = GetMerchantItemCostItem(slot, i)
    local have = 0
    if need and need > 0 and costLink then
      local curID = C_CurrencyInfo and C_CurrencyInfo.GetCurrencyIDFromLink(costLink)
      if curID and C_CurrencyInfo and C_CurrencyInfo.GetCurrencyInfo then
        local info = C_CurrencyInfo.GetCurrencyInfo(curID)
        have = (info and info.quantity) or 0
      else
        local itemID = GetItemInfoInstant(costLink)
        if itemID and GetItemCount then have = GetItemCount(itemID, true) or 0 end
      end
    end
    canPay[i] = (have >= (need or 0))
  end

  -- Palette
  local wR,wG,wB = (WHITE_FONT_COLOR and WHITE_FONT_COLOR:GetRGB()) or 1,1,1
  local gR,gG,gB = (GRAY_FONT_COLOR  and GRAY_FONT_COLOR:GetRGB())  or 0.5,0.5,0.5

  -- Try exact item frames first (…Item1/2/3)
  local colored = 0
  if acf.GetName then
    local base = acf:GetName()
    for i = 1, nCosts do
      local item = _G[base.."Item"..i]
      local count = item and (item.Count or (item.GetName and _G[(item:GetName() or "").."Count"]))
      if count and count.SetTextColor then
        local ok = canPay[i] == true
        count:SetTextColor(ok and wR or gR, ok and wG or gG, ok and wB or gB)
        colored = colored + 1
      end
    end
  end

  -- Fallback: scan all FontStrings under acf in creation order (first nCosts)
  if colored < nCosts then
    local fsList = {}
    local num = acf.GetNumRegions and acf:GetNumRegions() or 0
    for r = 1, num do
      local region = select(r, acf:GetRegions())
      if region and region.IsObjectType and region:IsObjectType("FontString") then
        table.insert(fsList, region)
      end
    end
    -- also check children (some skins put the FontString under child frames)
    for _, child in ipairs({ acf:GetChildren() }) do
      local rn = child.GetNumRegions and child:GetNumRegions() or 0
      for r = 1, rn do
        local region = select(r, child:GetRegions())
        if region and region.IsObjectType and region:IsObjectType("FontString") then
          table.insert(fsList, region)
        end
      end
    end
    -- apply to first nCosts fontstrings we found
    local idx = 1
    for _, fs in ipairs(fsList) do
      if idx > nCosts then break end
      if fs.SetTextColor then
        local ok = canPay[idx] == true
        fs:SetTextColor(ok and wR or gR, ok and wG or gG, ok and wB or gB)
        idx = idx + 1
      end
    end
  end
end

-- Run AFTER Blizzard paints the alt-currency for a row
if hooksecurefunc then
  hooksecurefunc("MerchantFrame_UpdateAltCurrency", function(rowIndex)
    if type(rowIndex) == "number" then
      VKF_RecolorAltCurrencyRow_Scan(rowIndex)
      if C_Timer and C_Timer.After then
        C_Timer.After(0.01, function() VKF_RecolorAltCurrencyRow_Scan(rowIndex) end)
      end
    end
  end)

  -- Also sweep after full page updates (covers page flips / filter toggles)
  hooksecurefunc("MerchantFrame_Update", function()
    local per = MERCHANT_ITEMS_PER_PAGE or 10
    for i = 1, per do VKF_RecolorAltCurrencyRow_Scan(i) end
    if C_Timer and C_Timer.After then
      C_Timer.After(0.01, function()
        for i = 1, per do VKF_RecolorAltCurrencyRow_Scan(i) end
      end)
    end
  end)
end

-- ————— Replace ALL existing /wl slash blocks with this one —————
SLASH_WHATSLEFT1 = "/wl"

SlashCmdList["WHATSLEFT"] = function(msg)
  msg = string.lower(msg or "")

  local function ToggleMenu()
    EnsureMenuPanel()
    local p = _G.VKF_MenuPanel
    if p then
      p:SetShown(not p:IsShown())
      AnchorTotalsToMenu()
      UpdateTotalsUI()
      PositionGearNearFilterWithRetries()
    end
  end

  if msg == "" or msg == "open" then
    ToggleMenu()

  elseif msg == "rescan" or msg == "refresh" or msg == "fix" then
    if HKA and HKA.Refresh then HKA:Refresh() end
    print("|cff50fa7bWhat's Left:|r forced a vendor rescan.")

  elseif msg == "help" then
    print("|cff66ccffWhat's Left commands:|r")
    print("/wl            – open/close the menu")
    print("/wl rescan     – force vendor refresh")
    print("/wl help       – show this help")

  else
    print("|cffff5555Unknown command.|r Type |cff66ccff/wl help|r for options.")
  end
end


-- ================================
-- What's Left – In-game Changelog
-- ================================

-- Persist the last version the player has seen
VKF_LastSeenVersion = VKF_LastSeenVersion or "0.0.0"

-- Your changelog data (edit this when you release)
-- Most recent first.
local VKF_CHANGELOG = {
  {
    version = "1.1.0",
    date    = "2025-10-27",
    notes   = {
      "Fixed /reload and /afk bug (both caused by the same underlying refresh issue).",
      "Resolved issue where /afk with ElvUI broke vendor frames.",
      "Fixed 'Unicus' vendor Arsenal items not respecting the 'Hide Known' filter.",
      "Corrected price, color updates after known items were removed, availability now displays properly.",
      "Pressing 'X' to close What's Left now also closes the Breakdown menu.",
      "Slash commands now work correctly: /wl , /wl help.",
      "Improved compatibility with DialogueUI and other addons that modify vendor frames.",

      "— — — — —",
      "Upcoming:",
      "Advanced Filtering (per-category behaviors).",
      "Optional 'Unlearned Total' display (may cause minor hiccups).",
      "Improved quest marker logic so the (!) icon follows quest items properly.",
      "'/wl popup' command to auto-confirm vendor purchases.",
      "Retail client integration.",

      "— — — — —",
      "Known issues:",
      "• Slight hiccups may occur when scanning large vendor pages due to multiple repaints and currency tracking.",
      "• Vendor quest item (!) icons occasionally fail to update when items move position.",
      "• Currently optimized for English-language clients; broader localization support is planned for a future update."
    },
  },
  {
    version = "1.0.0",
    date    = "2025-10-24",
    notes   = {
      "Initial public release for Remix vendors.",
    },
  },
}

-- --- Helpers ---
local function WL_GetVersion()
  local v = GetAddOnMetadata and GetAddOnMetadata(ADDON, "Version")
  return (type(v)=="string" and v ~= "" and v) or "1.1.0"
end

local function WL_IsNewerVersion(a, b) -- "1.1.0" > "1.0.0"
  local function split(s) local A,B,C = s:match("(%d+)%.(%d+)%.?(%d*)") return tonumber(A) or 0, tonumber(B) or 0, tonumber(C) or 0 end
  local a1,a2,a3 = split(a); local b1,b2,b3 = split(b)
  if a1 ~= b1 then return a1 > b1 end
  if a2 ~= b2 then return a2 > b2 end
  return a3 > b3
end

-- --- UI: simple scrollable panel ---
local VKF_ChangelogFrame

local function VKF_BuildChangelogText()
  local t = {}
  for _, entry in ipairs(VKF_CHANGELOG) do
    table.insert(t, ("|cffffffffv%s|r  |cffbbbbbb(%s)|r"):format(entry.version, entry.date or ""))
    for _, line in ipairs(entry.notes or {}) do
      table.insert(t, "  • "..line)
    end
    table.insert(t, " ") -- spacer
  end
  return table.concat(t, "\n")
end

local function VKF_EnsureChangelogFrame()
  if VKF_ChangelogFrame then return end
  local f = CreateFrame("Frame", "VKF_WL_Changelog", UIParent, "BackdropTemplate")
  VKF_ChangelogFrame = f
  f:SetSize(480, 420)
  f:SetPoint("CENTER")
  f:SetFrameStrata("DIALOG")
  f:SetClampedToScreen(true)
  f:SetBackdrop({
    bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 12,
    insets = { left=4, right=4, top=4, bottom=4 }
  })
  f:SetBackdropColor(0,0,0,0.93)
  f:SetBackdropBorderColor(0,0,0,1)

  local title = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
  title:SetPoint("TOPLEFT", 12, -10)
  title:SetText("|cff66ccffWhat’s Left|r – Changelog")

  local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
  close:SetPoint("TOPRIGHT", 2, 2)

  -- Scrollable body
  local sf = CreateFrame("ScrollFrame", nil, f, "UIPanelScrollFrameTemplate")
  sf:SetPoint("TOPLEFT", 12, -36)
  sf:SetPoint("BOTTOMRIGHT", -28, 12)

  local body = CreateFrame("Frame", nil, sf)
  body:SetSize(1, 1)
  sf:SetScrollChild(body)

  local text = body:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  text:SetPoint("TOPLEFT", 0, 0)
  text:SetPoint("RIGHT", -4, 0)
  text:SetJustifyH("LEFT")
  text:SetJustifyV("TOP")
  text:SetText(VKF_BuildChangelogText())

  -- Autosize height to contents
  C_Timer.After(0, function()
    text:SetWidth(sf:GetWidth() - 6)
    local h = math.max(200, text:GetStringHeight() + 4)
    body:SetSize(sf:GetWidth(), h)
  end)

  -- Tiny footer
 local verFS = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  verFS:SetPoint("TOPRIGHT", -28, -16)
  verFS:SetJustifyH("RIGHT")
  verFS:SetText(("Current: |cffffffffv%s|r"):format(WL_GetVersion()))
end

function VKF_ShowChangelog()
  VKF_EnsureChangelogFrame()
  VKF_ChangelogFrame:Show()
  PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
end

-- Slash commands: /wl changelog or /wlc
SLASH_WL_CHANGELOG1 = "/wlc"
SLASH_WL_CHANGELOG2 = "/wlchangelog"
SlashCmdList["WL_CHANGELOG"] = function() VKF_ShowChangelog() end

-- Show on update (first login after a new version)
local WL_Changelog_Events = CreateFrame("Frame")
WL_Changelog_Events:RegisterEvent("ADDON_LOADED")
WL_Changelog_Events:SetScript("OnEvent", function(_, ev, name)
  if ev ~= "ADDON_LOADED" or name ~= ADDON then return end
  local cur = WL_GetVersion()
  if WL_IsNewerVersion(cur, VKF_LastSeenVersion) then
    C_Timer.After(0.5, VKF_ShowChangelog) -- show after UI settles
    VKF_LastSeenVersion = cur
  end
end)
