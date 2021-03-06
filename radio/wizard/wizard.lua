
-- Wizard pages
local MODELTYPE_MENU = 0
local PLANE_MENU    = MODELTYPE_MENU+1
local HELI_MENU     = PLANE_MENU+10
local DELTA_MENU    = HELI_MENU+10
local QUADRI_MENU   = DELTA_MENU+10

local AILERONS_MENU = PLANE_MENU

local page = MODELTYPE_MENU
local dirty = true
local choice = 0

local edit = false
local field = 0
local fieldsMax = 0
local aileronsMode = 0
local aileronsCH1 = 0
local aileronsCH2 = 4

local function init()
  for stick = 0, 4, 1 do
    local index = channelOrder(stick);
    if index == 0 then
    elseif index == 1 then
    elseif index == 2 then
    else
      aileronsCH1 = stick
    end
  end
end

local function choiceSurround(index)
  lcd.drawRectangle(12+47*index, 13, 48, 48)
  lcd.drawPixmap(17+47*index, 8, "/TEMPLATES/mark.bmp")
end

local function drawModelChoiceMenu()
  lcd.clear()
  lcd.drawScreenTitle("", 0, 0)
  -- lcd.drawText(58, 13, "Select model type", 0)
  lcd.drawPixmap( 16, 17, "/TEMPLATES/plane.bmp")
  lcd.drawPixmap( 63, 17, "/TEMPLATES/heli.bmp")
  lcd.drawPixmap(110, 17, "/TEMPLATES/delta.bmp")
  lcd.drawPixmap(157, 17, "/TEMPLATES/quadri.bmp")
  choiceSurround(choice)
end

local function keyIncDec(event, value, max, isvalue)
  if isvalue then
    if event == EVT_PLUS_BREAK then
      if value < max then
        value = (value + 1)
        dirty = true
      end
    elseif event == EVT_MINUS_BREAK then
      if value > 0 then
        value = (value - 1)
        dirty = true
      end
    end
  else
    if event == EVT_PLUS_BREAK then
      value = (value + max)
      dirty = true
    elseif event == EVT_MINUS_BREAK then
      value = (value + max + 2)
      dirty = true
    end
    value = (value % (max+1))
  end
  return value
end

local function modelTypeMenu(event)
  if dirty == true then
    drawModelChoiceMenu()
    dirty = false
  end
  if event == EVT_ENTER_BREAK then
    page = PLANE_MENU+(10*choice)
    dirty = true
  else
    choice = keyIncDec(event, choice, 3)
  end
end

local function getFieldFlags(position)
  flags = 0
  if field == position then
    flags = INVERS
    if edit then
      flags = INVERS + BLINK
    end
  end
  return flags
end

local lastBlink = 0
local function blinkChanged()
  local time = getTime() % 128
  local blink = (time - time % 64) / 64
  if blink ~= lastBlink then
    lastBlink = blink
    return true
  else
    return false
  end
end

local aileronsModeItems = {"Yes...", "No...", "Yes, 2 channels..."}

local function drawAileronsMenu()
  lcd.clear()
  lcd.drawText(1, 0, "Has your model got ailerons?", 0)
  lcd.drawRect(0, 0, LCD_W, 8, GREY_DEFAULT+FILL_WHITE)
  lcd.drawCombobox(0, 8, LCD_W/2, aileronsModeItems, aileronsMode, getFieldFlags(0)) 
  lcd.drawLine(LCD_W/2-1, 18, LCD_W/2-1, LCD_H, DOTTED, 0)
  if aileronsMode == 2 then
    -- 2 channels
    lcd.drawPixmap(112, 8, "/TEMPLATES/ailerons-2.bmp")
    lcd.drawText(20, LCD_H-16, "Assign channels", 0);
    lcd.drawText(LCD_W/2-19, LCD_H-8, ">>>", 0);
    lcd.drawSource(116, LCD_H-8, SOURCE_FIRST_CH+aileronsCH1, getFieldFlags(1))
    lcd.drawSource(175, LCD_H-8, SOURCE_FIRST_CH+aileronsCH2, getFieldFlags(2))
    fieldsMax = 2
  elseif aileronsMode == 1 then
    -- No ailerons
    lcd.drawPixmap(112, 8, "/TEMPLATES/ailerons-0.bmp")
    fieldsMax = 0
  else
    -- 1 channel
    lcd.drawPixmap(112, 8, "/TEMPLATES/ailerons-1.bmp")
    lcd.drawText(25, LCD_H-16, "Assign channel", 0);
    lcd.drawText(LCD_W/2-19, LCD_H-8, ">>>", 0);
    lcd.drawSource(151, LCD_H-8, SOURCE_FIRST_CH+aileronsCH1, getFieldFlags(1))
    fieldsMax = 1
  end
end

local function aileronsMenu(event)
  if not dirty then
    dirty = blinkChanged()
  end
  if dirty then
    dirty = false
    drawAileronsMenu()
  end
  if event == EVT_ENTER_BREAK then
    edit = not edit
    dirty = true
  end
  if edit == false then
    field = keyIncDec(event, field, fieldsMax)
  elseif field == 0 then
    aileronsMode = keyIncDec(event, aileronsMode, 2)
  elseif field == 1 then
    aileronsCH1 = keyIncDec(event, aileronsCH1, 7, true)
  elseif field == 2 then
    aileronsCH2 = keyIncDec(event, aileronsCH2, 7, true)    
  end    
end

local function run(event)
  if event == EVT_EXIT_BREAK then
    return 2
  end
  lcd.lock()
  if page == MODELTYPE_MENU then
    modelTypeMenu(event)
  elseif page == AILERONS_MENU then
    aileronsMenu(event)
  end
  return 0
end

return { init=init, run=run }
