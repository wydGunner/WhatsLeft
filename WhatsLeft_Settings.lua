local ADDON, NS = ...

local LOC = GetLocaleTable()

-- Make sure this exists somewhere early in your addon init:
VKF_Settings = _G.VKF_Settings or { uiScale = 1.00, settingsPos = nil, petGoal = 1, ensembleNotify = "enabled"}
_G.VKF_Settings = VKF_Settings

-- Reusable: apply saved position or center
local function VKF_PositionSettingsFrame(f)
  local pos = VKF_Settings.settingsPos
  f:ClearAllPoints()
  if pos and pos.point and pos.relPoint and type(pos.x) == "number" and type(pos.y) == "number" then
    f:SetPoint(pos.point, UIParent, pos.relPoint, pos.x, pos.y)
  else
    f:SetPoint("CENTER")
  end
end

-- === SETTINGS WINDOW ===
local function VKF_ShowSettings()
  if _G.VKF_SettingsFrame then
    VKF_SettingsFrame:Show()
    return
  end

  -------------------------------------------------
  -- Colors
  -------------------------------------------------
  local BABY_BLUE   = {0.55, 0.80, 1.00, 1.0}
  local CLR_BG      = {0, 0, 0, 0.92}
  local CLR_EDGE    = {0, 0, 0, 1.00}
  local CLR_TEXT    = {0.92, 0.92, 0.92, 1}
  local CLR_HINT    = {1, 1, 1, 0.90}
  local CLR_LINE    = {1, 1, 1, 0.10}
  local CLR_BOX_BG  = {0, 0, 0, 0.60}
  local CLR_BOX_EDGE= {0, 0, 0, 1.00}
  local CLR_HOVER   = {0.35, 0.65, 1.00, 0.30}

  local f = CreateFrame("Frame", "VKF_SettingsFrame", UIParent, "BackdropTemplate")
  -- ⬇️ made the frame bigger so text fits nicer
  f:SetSize(380, 270)
  f:SetFrameStrata("DIALOG")
  f:SetClampedToScreen(true)
  f:SetBackdrop({
    bgFile   = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 12,
    insets   = { left = 4, right = 4, top = 4, bottom = 4 }
  })
  f:SetBackdropColor(unpack(CLR_BG))
  f:SetBackdropBorderColor(unpack(CLR_EDGE))
  VKF_PositionSettingsFrame(f)

  local innerWidth = (f:GetWidth() or 420) - 48
  local function WrapFS(fs)
    fs:SetWidth(innerWidth)
    fs:SetJustifyH("LEFT")
  end

  -------------------------------------------------
  -- Title & Drag
  -------------------------------------------------
  local title = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  title:SetPoint("TOPLEFT", 10, -10)
  local appTitle     = LOC.UI_APP_TITLE or "What's Left?"
local settingsWord = LOC.UI_SETTINGS_TITLE or "Settings"
title:SetText( ("|cff8cccff%s|r  v1.4.1 %s"):format(appTitle, settingsWord) )

  f:SetMovable(true)
  f:EnableMouse(true)

  local drag = CreateFrame("Frame", nil, f)
  drag:SetPoint("TOPLEFT", 6, -6)
  drag:SetPoint("TOPRIGHT", -26, -6)
  drag:SetHeight(24)
  drag:EnableMouse(true)
  drag:SetScript("OnMouseDown", function(_, btn)
    if btn == "LeftButton" then f:StartMoving() end
  end)
  local function SaveSettingsPos()
    f:StopMovingOrSizing()
    local p, _, rp, x, y = f:GetPoint(1)
    VKF_Settings.settingsPos = { point = p, relPoint = rp, x = x, y = y }
  end
  drag:SetScript("OnMouseUp", SaveSettingsPos)
  f:SetScript("OnHide", SaveSettingsPos)

  -------------------------------------------------
  -- Custom Close Button
  -------------------------------------------------
  local close = CreateFrame("Button", nil, f, "BackdropTemplate")
  close:SetSize(19, 19)
  close:SetPoint("TOPRIGHT", -6, -6)
  local function makeStroke(parent)
    local t = parent:CreateTexture(nil, "ARTWORK")
    t:SetTexture("Interface\\BUTTONS\\WHITE8x8")
    t:SetSize(14, 3.5)
    t:SetPoint("CENTER")
    return t
  end
  close.s1, close.s2 = makeStroke(close), makeStroke(close)
  close.s1:SetRotation(math.rad(45))
  close.s2:SetRotation(math.rad(-45))
  local IDLE, HOVER, DOWN = {0.85,0.85,0.85},{0.35,0.65,1.00},{0.25,0.45,0.85}
  local function cc(c)
    close.s1:SetVertexColor(c[1], c[2], c[3], 1)
    close.s2:SetVertexColor(c[1], c[2], c[3], 1)
  end
  cc(IDLE)
  close:SetScript("OnEnter", function() cc(HOVER) end)
  close:SetScript("OnLeave", function() cc(IDLE) end)
  close:SetScript("OnMouseDown", function() cc(DOWN) end)
  close:SetScript("OnMouseUp", function(self) cc(self:IsMouseOver() and HOVER or IDLE) end)
  close:SetScript("OnClick", function() f:Hide() end)
-------------------------------------------------
  -- SECTION 1: Show Unlearned Totals (top)
  -------------------------------------------------

  -- Baby-blue header first
  local totalsHeader = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  totalsHeader:SetPoint("TOPLEFT", 16, -40)
  totalsHeader:SetText(LOC.UI_SETTINGS_UNLEARNED_HEADER)
  totalsHeader:SetTextColor(unpack(BABY_BLUE))


  -- Checkbox to the RIGHT of the header
  local totalsCheck = CreateFrame("CheckButton", "$parentTotalsToggle", f, "InterfaceOptionsCheckButtonTemplate")
  totalsCheck:SetPoint("LEFT", totalsHeader, "RIGHT", 2, 0)

  -- Kill the default white label on the checkbox
  totalsCheck.Text:SetText("")
  totalsCheck.Text:Hide()

  -- Hint text under the header
  local totalsHint = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  totalsHint:SetPoint("TOPLEFT", totalsHeader, "BOTTOMLEFT", 0, -2)
  totalsHint:SetText(LOC.UI_SETTINGS_UNLEARNED_HINT)
  totalsHint:SetTextColor(unpack(CLR_HINT))
  WrapFS(totalsHint)

  -- Checkbox state logic
  local function GetTotalsEnabled()
    return VKF_TotalsEnabled ~= false
  end

  totalsCheck:SetChecked(GetTotalsEnabled())
  totalsCheck:SetScript("OnClick", function(self)
    local enabled = self:GetChecked() and true or false
    VKF_TotalsEnabled = enabled

    if VKF_TotalsPanel then
      if enabled then
        VKF_TotalsPanel:Show()
      else
        VKF_TotalsPanel:Hide()
      end
    end

    if SOUNDKIT and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON then
      PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
    end
  end)

  -- Divider under this section
  local line1 = f:CreateTexture(nil, "BACKGROUND")
  line1:SetColorTexture(unpack(CLR_LINE))
  line1:SetHeight(1)
  line1:SetPoint("TOPLEFT", totalsHint, "BOTTOMLEFT", 0, -8)
  line1:SetPoint("TOPRIGHT", -16, 0)
    -------------------------------------------------
  -- SECTION 2: How many pets? (middle)
  -------------------------------------------------
  VKF_Settings.petGoal = (VKF_Settings.petGoal == 1 or VKF_Settings.petGoal == 2 or VKF_Settings.petGoal == 3)
    and VKF_Settings.petGoal or 1

  local label = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  label:SetPoint("TOPLEFT", line1, "BOTTOMLEFT", 0, -8)
  label:SetText(LOC.UI_SETTINGS_PETS_HEADER)
  label:SetTextColor(unpack(BABY_BLUE))
  WrapFS(label)

  local hint = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  hint:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, -2)
  --hint:SetText(LOC.UI_SETTINGS_PETS_HINT1)
  hint:SetTextColor(unpack(CLR_HINT))
  WrapFS(hint)

  local hint2 = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  hint2:SetPoint("TOPLEFT", hint, "BOTTOMLEFT", 0, -1)
  hint2:SetText(LOC.UI_SETTINGS_PETS_HINT2)
  hint2:SetTextColor(unpack(CLR_HINT))
  WrapFS(hint2)

   -------------------------------------------------
  -- Button that opens our own dropdown menu
  -------------------------------------------------
  local ddBtn = CreateFrame("Button", "$parentPetGoalDD", f, "BackdropTemplate")
  ddBtn:SetSize(80, 24)
  ddBtn:SetPoint("TOPLEFT", hint2, "BOTTOMLEFT", -2, -6)
  ddBtn:SetBackdrop({
    bgFile   = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 12,
    insets   = { left = 3, right = 3, top = 3, bottom = 3 }
  })
  ddBtn:SetBackdropColor(unpack(CLR_BOX_BG))
  ddBtn:SetBackdropBorderColor(unpack(CLR_BOX_EDGE))

  -- value text
  ddBtn.text = ddBtn:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  ddBtn.text:SetPoint("LEFT", 10, 0)
  ddBtn.text:SetTextColor(0.92, 0.92, 0.92, 1)
  ddBtn.text:SetText(tostring(VKF_Settings.petGoal or 1))

  -- dropdown arrow so it reads as a dropdown
  ddBtn.arrow = ddBtn:CreateTexture(nil, "ARTWORK")
  ddBtn.arrow:SetTexture("Interface\\Buttons\\UI-ScrollBar-ScrollDownButton-Up")
  ddBtn.arrow:SetSize(14, 14)
  ddBtn.arrow:SetPoint("RIGHT", -6, 0)
  ddBtn.arrow:SetAlpha(0.9)

  -- hover highlight
  ddBtn.hl = ddBtn:CreateTexture(nil, "OVERLAY")
  ddBtn.hl:SetColorTexture(CLR_HOVER[1], CLR_HOVER[2], CLR_HOVER[3], 0.10)
  ddBtn.hl:SetAllPoints()
  ddBtn.hl:Hide()

  ddBtn:SetScript("OnEnter", function(self)
    ddBtn.hl:Show()
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(
      LOC.UI_SETTINGS_PETS_HINT1 .. "\n" ..
      (LOC.UI_SETTINGS_PETS_HINT2 or ""),
      1, 1, 1, true
    )
  end)

  ddBtn:SetScript("OnLeave", function()
    ddBtn.hl:Hide()
    GameTooltip:Hide()
  end)


  -------------------------------------------------
  -- Custom dropdown panel underneath the button
  -------------------------------------------------
  local petGoalMenu = CreateFrame("Frame", "$parentPetGoalMenu", f, "BackdropTemplate")
  petGoalMenu:SetSize(ddBtn:GetWidth(), 3 * 20 + 6) -- 3 options
  petGoalMenu:SetPoint("TOPLEFT", ddBtn, "BOTTOMLEFT", 0, -2)
  petGoalMenu:SetBackdrop({
    bgFile   = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 12,
    insets   = { left = 3, right = 3, top = 3, bottom = 3 }
  })
  petGoalMenu:SetBackdropColor(0, 0, 0, 1)
  petGoalMenu:SetBackdropBorderColor(unpack(CLR_BOX_EDGE))
    petGoalMenu:SetFrameStrata("TOOLTIP")
  petGoalMenu:SetFrameLevel(f:GetFrameLevel() + 10)

  petGoalMenu:Hide()
  petGoalMenu:SetFrameStrata("DIALOG")

  local options = { 1, 2, 3 }
  for i, value in ipairs(options) do
    local opt = CreateFrame("Button", nil, petGoalMenu, "BackdropTemplate")
    opt:SetSize(petGoalMenu:GetWidth() - 6, 20)
    opt:SetPoint("TOPLEFT", 3, -3 - (i - 1) * 20)

    local txt = opt:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    txt:SetPoint("LEFT", 4, 0)
    txt:SetText(tostring(value))
    txt:SetTextColor(0.92, 0.92, 0.92, 1)
    opt.text = txt

    local hl = opt:CreateTexture(nil, "BACKGROUND")
    hl:SetColorTexture(CLR_HOVER[1], CLR_HOVER[2], CLR_HOVER[3], 0.15)
    hl:SetAllPoints()
    hl:Hide()
    opt.hl = hl

    opt:SetScript("OnEnter", function(self)
      self.hl:Show()
    end)
    opt:SetScript("OnLeave", function(self)
      self.hl:Hide()
    end)

    opt:SetScript("OnClick", function(self)
      VKF_Settings.petGoal = value
      ddBtn.text:SetText(tostring(value))
      petGoalMenu:Hide()

      if SOUNDKIT and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON then
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
      end
    end)
  end

  ddBtn:SetScript("OnClick", function(self)
    if petGoalMenu:IsShown() then
      petGoalMenu:Hide()
    else
      petGoalMenu:Show()
    end
  end)

  -------------------------------------------------
  -- SECTION 3: Ensemble Notifications
  -------------------------------------------------

  -- sanitize saved value
  VKF_Settings.ensembleNotify = VKF_Settings.ensembleNotify or "enabled"
  if VKF_Settings.ensembleNotify ~= "enabled"
    and VKF_Settings.ensembleNotify ~= "silenced"
    and VKF_Settings.ensembleNotify ~= "disabled" then
    VKF_Settings.ensembleNotify = "enabled"
  end

local ensHeader = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
-- Align vertically with "How many pets?" by using line1 like the label does
-- label:SetPoint("TOPLEFT", line1, "BOTTOMLEFT", 0, -8)
ensHeader:SetPoint("TOPLEFT", line1, "BOTTOMLEFT", 122, -8)  -- tweak 210 as needed
ensHeader:SetText(LOC.ENS_NOTIFS)
ensHeader:SetTextColor(unpack(BABY_BLUE))
WrapFS(ensHeader)

  local ensHint = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  ensHint:SetPoint("TOPLEFT", ensHeader, "BOTTOMLEFT", 0, -2)

  ensHint:SetTextColor(unpack(CLR_HINT))
  WrapFS(ensHint)

  -- Dropdown button
  local ensDD = CreateFrame("Button", "$parentEnsembleNotifyDD", f, "BackdropTemplate")
  ensDD:SetSize(120, 24)
  ensDD:SetPoint("TOPLEFT", ensHint, "BOTTOMLEFT", -2, -6)
  ensDD:SetBackdrop({
    bgFile   = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 12,
    insets   = { left = 3, right = 3, top = 3, bottom = 3 }
  })
  ensDD:SetBackdropColor(unpack(CLR_BOX_BG))
  ensDD:SetBackdropBorderColor(unpack(CLR_BOX_EDGE))

  ensDD.text = ensDD:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  ensDD.text:SetPoint("LEFT", 10, 0)
  ensDD.text:SetTextColor(0.92, 0.92, 0.92, 1)

  ensDD.arrow = ensDD:CreateTexture(nil, "ARTWORK")
  ensDD.arrow:SetTexture("Interface\\Buttons\\UI-ScrollBar-ScrollDownButton-Up")
  ensDD.arrow:SetSize(14, 14)
  ensDD.arrow:SetPoint("RIGHT", -6, 0)
  ensDD.arrow:SetAlpha(0.9)

  ensDD.hl = ensDD:CreateTexture(nil, "OVERLAY")
  ensDD.hl:SetColorTexture(CLR_HOVER[1], CLR_HOVER[2], CLR_HOVER[3], 0.10)
  ensDD.hl:SetAllPoints()
  ensDD.hl:Hide()

local ENSEMBLE_OPTIONS = {
    { value = "enabled",  label = LOC.ENS_OPT_ENABLED  }, -- Sound + popups + chat
    { value = "silenced", label = LOC.ENS_OPT_SILENCED }, -- Chat only
    { value = "disabled", label = LOC.ENS_OPT_DISABLED }, -- Off
}

  local function EnsembleGetLabel(value)
    for _, opt in ipairs(ENSEMBLE_OPTIONS) do
      if opt.value == value then
        return opt.label
      end
    end
    return "Enabled"
  end

  ensDD.text:SetText(EnsembleGetLabel(VKF_Settings.ensembleNotify))

ensDD:SetScript("OnEnter", function(self)
  ensDD.hl:Show()
  GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
  GameTooltip:SetText(LOC.ENS_TOOLTIP, 1, 1, 1, true)
end)

  ensDD:SetScript("OnLeave", function()
    ensDD.hl:Hide()
    GameTooltip:Hide()
  end)

  -- Dropdown menu
  local ensMenu = CreateFrame("Frame", "$parentEnsembleNotifyMenu", f, "BackdropTemplate")
  ensMenu:SetSize(ensDD:GetWidth(), #ENSEMBLE_OPTIONS * 20 + 6)
  ensMenu:SetPoint("TOPLEFT", ensDD, "BOTTOMLEFT", 0, -2)
  ensMenu:SetBackdrop({
    bgFile   = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 12,
    insets   = { left = 3, right = 3, top = 3, bottom = 3 }
  })
  ensMenu:SetBackdropColor(0, 0, 0, 1)
  ensMenu:SetBackdropBorderColor(unpack(CLR_BOX_EDGE))
  ensMenu:SetFrameStrata("DIALOG")
  ensMenu:SetFrameLevel(f:GetFrameLevel() + 10)
  ensMenu:Hide()

  for i, optData in ipairs(ENSEMBLE_OPTIONS) do
    local opt = CreateFrame("Button", nil, ensMenu, "BackdropTemplate")
    opt:SetSize(ensMenu:GetWidth() - 6, 20)
    opt:SetPoint("TOPLEFT", 3, -3 - (i - 1) * 20)

    local txt = opt:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    txt:SetPoint("LEFT", 4, 0)
    txt:SetText(optData.label)
    txt:SetTextColor(0.92, 0.92, 0.92, 1)
    opt.text = txt

    local hl = opt:CreateTexture(nil, "BACKGROUND")
    hl:SetColorTexture(CLR_HOVER[1], CLR_HOVER[2], CLR_HOVER[3], 0.15)
    hl:SetAllPoints()
    hl:Hide()
    opt.hl = hl

    opt:SetScript("OnEnter", function(self) self.hl:Show() end)
    opt:SetScript("OnLeave", function(self) self.hl:Hide() end)

    opt:SetScript("OnClick", function()
      VKF_Settings.ensembleNotify = optData.value
      ensDD.text:SetText(optData.label)
      ensMenu:Hide()

      if SOUNDKIT and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON then
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
      end
    end)
  end

  ensDD:SetScript("OnClick", function()
    if ensMenu:IsShown() then
      ensMenu:Hide()
    else
      ensMenu:Show()
    end
  end)



  -------------------------------------------------
  -- Divider line under the control (layout unchanged)
  -------------------------------------------------
  local line2 = f:CreateTexture(nil, "BACKGROUND")
  line2:SetColorTexture(unpack(CLR_LINE))
  line2:SetHeight(1)
  line2:SetPoint("TOPLEFT", ddBtn, "BOTTOMLEFT", 0, -8)
  line2:SetPoint("TOPRIGHT", -16, 0)

  -------------------------------------------------
  -- SECTION 3: UI Scale (bottom, with baby-blue bar)
  -------------------------------------------------
  local scaleHeader = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  scaleHeader:SetPoint("TOPLEFT", line2, "BOTTOMLEFT", 0, -8)
  scaleHeader:SetText(LOC.UI_SETTINGS_SCALE_HEADER)
  scaleHeader:SetTextColor(unpack(BABY_BLUE))
  WrapFS(scaleHeader)

  local scaleHint = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  scaleHint:SetPoint("TOPLEFT", scaleHeader, "BOTTOMLEFT", 0, -2)
  scaleHint:SetText(LOC.UI_SETTINGS_SCALE_HINT)
  scaleHint:SetTextColor(unpack(CLR_HINT))
  WrapFS(scaleHint)

  local slider = CreateFrame("Slider", "$parentScale", f, "OptionsSliderTemplate")
  slider:SetPoint("TOPLEFT", scaleHint, "BOTTOMLEFT", 10, -10)
  slider:SetWidth(innerWidth + 8)
  slider:SetMinMaxValues(0.80, 1.40)
  slider:SetValueStep(0.05)
  slider:SetObeyStepOnDrag(true)

  _G[slider:GetName() .. "Low"]:SetText("0.80")
  _G[slider:GetName() .. "High"]:SetText("1.40")
  _G[slider:GetName() .. "Low"]:SetTextColor(unpack(CLR_HINT))
  _G[slider:GetName() .. "High"]:SetTextColor(unpack(CLR_HINT))

  local sliderText = _G[slider:GetName() .. "Text"]
  local scaleFmt = LOC.UI_SETTINGS_SCALE_VALUE_FMT or "UI Scale: %.2f"
sliderText:SetText(scaleFmt:format(VKF_Settings.uiScale or 1.00))
  sliderText:SetTextColor(unpack(BABY_BLUE))

  slider:SetValue(VKF_Settings.uiScale or 1.00)

  -- baby-blue accent bar behind the slider
  local sliderBar = f:CreateTexture(nil, "BACKGROUND")
  sliderBar:SetColorTexture(BABY_BLUE[1], BABY_BLUE[2], BABY_BLUE[3], 0.35)
  sliderBar:SetHeight(3)
  sliderBar:SetPoint("LEFT", slider, "LEFT", 4, 0)
  sliderBar:SetPoint("RIGHT", slider, "RIGHT", -4, 0)
  sliderBar:SetDrawLayer("BACKGROUND", 1)

  -- ⬇️ move the "UI Scale: X.XX" text UNDER the slider bar
  sliderText:ClearAllPoints()
  sliderText:SetPoint("TOP", slider, "BOTTOM", 0, -4)

  slider:SetScript("OnValueChanged", function(self, val)
    VKF_Settings.uiScale = tonumber(string.format("%.2f", val))
    sliderText:SetText(scaleFmt:format(VKF_Settings.uiScale))
    if VKF_ApplyScale then
      VKF_ApplyScale()
    end
  end)

  -------------------------------------------------
  -- ESC handling
  -------------------------------------------------
  f:SetPropagateKeyboardInput(true)
  f:EnableKeyboard(true)
  f:SetScript("OnKeyDown", function(self, key)
    if key == "ESCAPE" then
      self:Hide()
    end
  end)
end


function VKF_ToggleSettings()
  if _G.VKF_SettingsFrame and VKF_SettingsFrame:IsShown() then
    VKF_SettingsFrame:Hide()
  else
    VKF_ShowSettings()
  end
end

-------------------------------------------------
-- Auto-close settings when you leave a vendor
-------------------------------------------------
local VKF_SettingsEvents = CreateFrame("Frame")
VKF_SettingsEvents:RegisterEvent("MERCHANT_CLOSED")
VKF_SettingsEvents:SetScript("OnEvent", function()
  if VKF_SettingsFrame and VKF_SettingsFrame:IsShown() then
    VKF_SettingsFrame:Hide()
  end
end)
