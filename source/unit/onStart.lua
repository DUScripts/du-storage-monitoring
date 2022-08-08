--[[
	LUA PARAMETERS
]]
useDatabankValues = false --export: if checked and if values were saved in databank, parmaters will be loaded from the databank, if not, following ones will be used

PrefixScreen1 = "s1_" --export: the prefix used to enable container monitoring and display on the 1st screen
PrefixScreen2 = "s2_" --export: the prefix used to enable container monitoring and display on the 2nd screen
PrefixScreen3 = "s3_" --export: the prefix used to enable container monitoring and display on the 3rd screen
PrefixScreen4 = "s4_" --export: the prefix used to enable container monitoring and display on the 4th screen
PrefixScreen5 = "s5_" --export: the prefix used to enable container monitoring and display on the 5th screen
PrefixScreen6 = "s6_" --export: the prefix used to enable container monitoring and display on the 6th screen
PrefixScreen7 = "s7_" --export: the prefix used to enable container monitoring and display on the 7th screen
PrefixScreen8 = "s8_" --export: the prefix used to enable container monitoring and display on the 8th screen
PrefixScreen9 = "s9_" --export: the prefix used to enable container monitoring and display on the 9th screen

screenTitle1 = "-" --export: the title display on the 1st screen, not displayed if empty or equal to "-"
screenTitle2 = "-" --export: the title display on the 2nd screen, not displayed if empty or equal to "-"
screenTitle3 = "-" --export: the title display on the 3rd screen, not displayed if empty or equal to "-"
screenTitle4 = "-" --export: the title display on the 4th screen, not displayed if empty or equal to "-"
screenTitle5 = "-" --export: the title display on the 5th screen, not displayed if empty or equal to "-"
screenTitle6 = "-" --export: the title display on the 6th screen, not displayed if empty or equal to "-"
screenTitle7 = "-" --export: the title display on the 7th screen, not displayed if empty or equal to "-"
screenTitle8 = "-" --export: the title display on the 8th screen, not displayed if empty or equal to "-"
screenTitle9 = "-" --export: the title display on the 9th screen, not displayed if empty or equal to "-"

containerProficiencyLvl = 5 --export: Talent level for Container Proficiency
containerOptimizationLvl = 5 --export: Talent level for Container Optimization
groupByItemName = true --export: if enabled, this will group all entries with the same item name

QuantityRoundedDecimals = 2 --export: maximum of decimals displayed for the quantity value
PercentRoundedDecimals = 2 --export: maximum of decimals displayed for the percent fill value
fontSize = 15 --export: the size of the text for all the screen
maxAmountOfElementsLoadedByTick = 5000 --export: the maximum number of element loaded by tick of the coroutine on script startup
maxAmountOfElementsRefreshedByTick = 200 --export: the maximum number of element refreshed by tick of the coroutine when refreshing values
maxVolumePosition=50 --export: the position in percent of width for the column Max Volume
quantityPosition=75 --export: the position in percent of width for the column Quantity
verticalMode = true --export: rotate the screen 90deg (bottom on right)
verticalModeBottomSide = "right" --export: when vertical mode is enabled, on which side the bottom of the screen is positioned ("left" or "right")
--defaultSorting = "none" --export: the default sorting of items on the screen: "none": like in the container, "items-asc": ascending sorting on the name, "items-desc": descending sorting on the name, "quantity-asc": ascending on the quantity, "quantity-desc": descending on the quantity

--[[
	INIT
]]

local version = '4.3.1'

system.print("----------------------------------")
system.print("DU-Storage-Monitoring version " .. version)
system.print("----------------------------------")

options = {}
options.containerMonitoringPrefix_screen1 = PrefixScreen1
options.containerMonitoringPrefix_screen2 = PrefixScreen2
options.containerMonitoringPrefix_screen3 = PrefixScreen3
options.containerMonitoringPrefix_screen4 = PrefixScreen4
options.containerMonitoringPrefix_screen5 = PrefixScreen5
options.containerMonitoringPrefix_screen6 = PrefixScreen6
options.containerMonitoringPrefix_screen7 = PrefixScreen7
options.containerMonitoringPrefix_screen8 = PrefixScreen8
options.containerMonitoringPrefix_screen9 = PrefixScreen9
options.screenTitle1 = screenTitle1
options.screenTitle2 = screenTitle2
options.screenTitle3 = screenTitle3
options.screenTitle4 = screenTitle4
options.screenTitle5 = screenTitle5
options.screenTitle6 = screenTitle6
options.screenTitle7 = screenTitle7
options.screenTitle8 = screenTitle8
options.screenTitle9 = screenTitle9
options.container_proficiency_lvl = containerProficiencyLvl
options.container_optimization_lvl = containerOptimizationLvl
options.groupByItemName = groupByItemName
options.QuantityRoundedDecimals = QuantityRoundedDecimals
options.PercentRoundedDecimals = PercentRoundedDecimals
options.fontSize = fontSize
options.maxAmountOfElementsLoadedByTick = maxAmountOfElementsLoadedByTick
options.maxAmountOfElementsRefreshedByTick = maxAmountOfElementsRefreshedByTick
options.maxVolumePosition = maxVolumePosition
options.quantityPosition = quantityPosition
options.verticalMode = verticalMode
options.verticalModeBottomSide = verticalModeBottomSide
options.defaultSorting = defaultSorting


local sorting=0
if defaultSorting=="items-asc" then sorting = 1
elseif defaultSorting=="items-desc" then sorting = 2
elseif defaultSorting=="quantity-asc" then sorting = 3
elseif defaultSorting=="quantity-desc" then sorting = 4
end

local renderScript = [[
local json = require('dkjson')
local data = json.decode(getInput()) or {}
local vmode = ]] .. tostring(verticalMode) .. [[

local vmode_side = "]] .. verticalModeBottomSide .. [["

if items == nil or data[7] then items = {} end
if page == nil or data[7] then page = 1 end
if screenTitle == nil or data[7] then page = data[6] or "" end
if sorting == nil or data[7] then sorting = ]] .. sorting .. [[ end

local images = {}

if data ~= {} then
    items[#items+1] = {
        data[1],
        data[2],
        data[3],
        data[4],
        data[5],
        data[8]
    }
    setOutput(#items)
    data = nil
end

local rx,ry = getResolution()
local cx, cy = getCursor()
if vmode then
    ry,rx = getResolution()
    cy, cx = getCursor()
    cx = rx - cx
    if vmode_side == "right" then
        cy = ry - cy
        cx = rx - cx
    end
end

local back=createLayer()
local front=createLayer()

font_size = ]] .. fontSize .. [[

local mini=loadFont('Play',12)
local small=loadFont('Play',14)
local smallBold=loadFont('Play-Bold',18)
local itemName=loadFont('Play-Bold',font_size)
local medV=loadFont('Play-Bold', 25)
local bigV=loadFont('Play-Bold', 30)
local big=loadFont('Play',38)

setBackgroundColor( 15/255,24/255,29/255)

setDefaultStrokeColor( back,Shape_Line,0,0,0,0.5)
setDefaultShadow( back,Shape_Line,6,0,0,0,0.5)

setDefaultFillColor( front,Shape_BoxRounded,249/255,212/255,123/255,1)
setDefaultFillColor( front,Shape_Text,0,0,0,1)
setDefaultFillColor( front,Shape_Box,0.075,0.125,0.156,1)
setDefaultFillColor( front,Shape_Text,0.710,0.878,0.941,1)

function format_number(a)local b=a;while true do b,k=string.gsub(b,"^(-?%d+)(%d%d%d)",'%1 %2')if k==0 then break end end;return b end

function round(a,b)if b then return utils.round(a/b)*b end;return a>=0 and math.floor(a+0.5)or math.ceil(a-0.5)end

function getRGBGradient(a,b,c,d,e,f,g,h,i,j)a=-1*math.cos(a*math.pi)/2+0.5;local k=0;local l=0;local m=0;if a>=.5 then a=(a-0.5)*2;k=e-a*(e-h)l=f-a*(f-i)m=g-a*(g-j)else a=a*2;k=b-a*(b-e)l=c-a*(c-f)m=d-a*(d-g)end;return k,l,m end

function renderHeader(title, subtitle)
    local h_factor = 12
    local h = 35
    if subtitle ~= nil and subtitle ~= "" and subtitle ~= "-" then
        h = 50
    end
    addLine( back,0,h+12,rx,h+12)
    addBox(front,0,12,rx,h)
    if subtitle ~= nil and subtitle ~= "" and subtitle ~= "-" then
        addText(front,big,subtitle,44,50)
        addText(front,smallBold,title,rx-275,40)
    else
        addText(front,smallBold,title,44,35)
    end
end

local storageBar = createLayer()
setDefaultFillColor(storageBar,Shape_Text,110/255,166/255,181/255,1)
setDefaultFillColor(storageBar,Shape_Box,0.075,0.125,0.156,1)
setDefaultFillColor(storageBar,Shape_Line,1,1,1,1)

local storageDark = createLayer()
setDefaultFillColor(storageDark,Shape_Text,63/255,92/255,102/255,1)
setDefaultFillColor(storageDark,Shape_Box,13/255,24/255,28/255,1)

local buttonHover = createLayer()
setDefaultFillColor(buttonHover,Shape_Box,249/255,212/255,123/255,1)
setDefaultFillColor(buttonHover,Shape_Text,0,0,0,1)

local colorLayer = createLayer()
local imagesLayer = createLayer()

if vmode then
    local r = 90
    local tx = ry
    local ty = 0
    if vmode_side == "left" then
        r = r + 180
        tx = 0
        ty = rx
    end
    setLayerTranslation(back, tx,ty)
    setLayerRotation(back, math.rad(r))
    setLayerTranslation(front, tx, ty)
    setLayerRotation(front, math.rad(r))
    setLayerTranslation(storageBar, tx, ty)
    setLayerRotation(storageBar, math.rad(r))
    setLayerTranslation(colorLayer, tx, ty)
    setLayerRotation(colorLayer, math.rad(r))
    setLayerTranslation(imagesLayer, tx, ty)
    setLayerRotation(imagesLayer, math.rad(r))
    setLayerTranslation(buttonHover, tx, ty)
    setLayerRotation(buttonHover, math.rad(r))
    setLayerTranslation(storageDark, tx, ty)
    setLayerRotation(storageDark, math.rad(r))
end
function renderResistanceBar(title, quantity, max, percent, item_id, x, y, w, h, withTitle, withIcon)
    local colorPercent = percent
    if percent > 100 then colorPercent = 100 end
    local r,g,b = getRGBGradient(colorPercent/100,177/255,42/255,42/255,249/255,212/255,123/255,34/255,177/255,76/255)

    local quantity_x_pos = font_size * 6.7
    local percent_x_pos = font_size * 2

    addBox(storageBar,x,y,w,h)

    if withTitle then
        addText(storageBar, small, "ITEMS", x, y-5)
        setNextTextAlign(storageDark, AlignH_Center, AlignV_Bottom)
        addText(storageDark, small, "MAX VOLUME", x+(w*]] .. tostring(maxVolumePosition/100) .. [[), y-3)
        setNextTextAlign(storageBar, AlignH_Center, AlignV_Bottom)
        addText(storageBar, small, "QUANTITY", x+(w*]] .. tostring(quantityPosition/100) .. [[), y-3)
        setNextTextAlign(storageBar, AlignH_Right, AlignV_Bottom)
        addText(storageBar, small, "STORAGE", rx-x, y-5)
    end

    local pos_y = y+(h/2)-2

    if item_id and tonumber(item_id) > 0 and images[item_id] and withIcon then
        addImage(imagesLayer, images[item_id], x+10, y+font_size*.1, font_size*1.3, font_size*1.2)
    end

    setNextTextAlign(storageBar, AlignH_Left, AlignV_Middle)
    addText(storageBar, itemName, title, x+20+font_size, pos_y)

    setNextFillColor(colorLayer, r, g, b, 1)
    addBox(colorLayer,x,y+h-3,w*(colorPercent)/100,3)

    setNextTextAlign(storageDark, AlignH_Center, AlignV_Middle)
    addText(storageDark, itemName, format_number(max) .. ' L', x+(w*]] .. tostring(maxVolumePosition/100) .. [[), pos_y)

    setNextTextAlign(storageBar, AlignH_Center, AlignV_Middle)
    addText(storageBar, itemName, format_number(quantity), x+(w*]] .. tostring(quantityPosition/100) .. [[), pos_y)

    setNextFillColor(colorLayer, r, g, b, 1)
    setNextTextAlign(colorLayer, AlignH_Right, AlignV_Middle)
    addText(colorLayer, itemName, format_number(percent) .."%", rx-x-5, pos_y)
end

renderHeader('STORAGE MONITORING v]] .. version .. [[', screenTitle)

start_h = 75
if screenTitle ~= nil and screenTitle ~= "" then
    start_h = 100
end


local h = font_size + font_size / 2

local loadedImages = 0
if data ~= {} then
    for _,item in ipairs(items) do
        if item[1] and images[item[6] ] == nil and loadedImages <= 15 then
            loadedImages = loadedImages + 1
            images[item[6] ] = loadImage(item[5])
        end
    end
end

for i,container in ipairs(items) do
    if container[1] then
        renderResistanceBar(container[1], container[2], container[3], container[4], container[6], 44, start_h, rx-88, h, i==1, i<=16)
        start_h = start_h+h+5
    end
end
requestAnimationFrame(100)
]]

--[[
	split a string on a delimiter By jericho
]]
function strSplit(a,b)result={}for c in(a..b):gmatch("(.-)"..b)do table.insert(result,c)end;return result end

--[[
    return RGB colors calculated from a gradient between two colors
]]
function getRGBGradient(a,b,c,d,e,f,g,h,i,j)a=-1*math.cos(a*math.pi)/2+0.5;local k=0;local l=0;local m=0;if a>=.5 then a=(a-0.5)*2;k=e-a*(e-h)l=f-a*(f-i)m=g-a*(g-j)else a=a*2;k=b-a*(b-e)l=c-a*(c-f)m=d-a*(d-g)end;return k,l,m end

--[[
	formatting numbers by adding a space between thousands by Jericho
]]
function format_number(a)local b=a;while true do b,k=string.gsub(b,"^(-?%d+)(%d%d%d)",'%1 %2')if k==0 then break end end;return b end

core = nil
databank = nil
screens = {}
for slot_name, slot in pairs(unit) do
    if
    type(slot) == "table"
            and type(slot.export) == "table"
            and slot.getClass
    then
        if slot.getClass():lower():find("coreunit") then
            core = slot
        end
        if slot.getClass():lower() == 'screenunit' then
            slot.slotname = slot_name
            table.insert(screens,slot)
            slot.setRenderScript(renderScript)
        end
        if slot.getClass():lower() == 'databankunit' then
            databank = slot
        end
    end
end
if #screens == 0 then
    system.print("No Screen Detected")
else
    --sorting screens by slotname to be sure the display is not changing
    table.sort(screens, function(a,b) return a.slotname < b.slotname end)
    local plural = ""
    if #screens > 1 then plural = "s" end
    system.print(#screens .. " screen" .. plural .. " Connected")
end
if core == nil then
    system.print("No Core Detected")
else
    system.print("Core Connected")
end
if databank == nil then
    system.print("No Databank Detected")
else
    system.print("Databank Connected")
    if (databank.hasKey("options")) and (useDatabankValues == true) then
        local db_options = json.decode(databank.getStringValue("options"))
        for key, value in pairs(options) do
            if db_options[key] then options[key] = db_options[key] end
        end
        system.print("Options Loaded From Databank")
    else
        system.print("Options Loaded From LUA Parameters")
    end
end
prefixes = {
    options.containerMonitoringPrefix_screen1,
    options.containerMonitoringPrefix_screen2,
    options.containerMonitoringPrefix_screen3,
    options.containerMonitoringPrefix_screen4,
    options.containerMonitoringPrefix_screen5,
    options.containerMonitoringPrefix_screen6,
    options.containerMonitoringPrefix_screen7,
    options.containerMonitoringPrefix_screen8,
    options.containerMonitoringPrefix_screen9
}
titles = {
    options.screenTitle1,
    options.screenTitle2,
    options.screenTitle3,
    options.screenTitle4,
    options.screenTitle5,
    options.screenTitle6,
    options.screenTitle7,
    options.screenTitle8,
    options.screenTitle9
}
elementsIdList = {}
if core ~= nil then
    elementsIdList = core.getElementIdList()
end
storageIdList= {}
initIndex = 0
initFinished = false
screens_displayed = false

--Nested Coroutines by Jericho
coroutinesTable  = {}
--all functions here will become a coroutine
MyCoroutines = {
    function()
        if not initFinished then
            system.print("Loading contructs elements (" .. #elementsIdList .. " elements detected)")
            for i = 1, #elementsIdList, 1 do
                initIndex = i
                local id = elementsIdList[i]
                local elementType = core.getElementDisplayNameById(id):lower()
                if elementType:lower():find("container") then
                    table.insert(storageIdList, id)
                end
                if (i%options.maxAmountOfElementsLoadedByTick) == 0 then
                    system.print(i .. ' elements scanned on ' .. #elementsIdList .. ' with ' .. #storageIdList .. " identified")
                    coroutine.yield(coroutinesTable[1])
                end
            end
            if initIndex == #elementsIdList then
                system.print(#elementsIdList .. " scanned with " .. #storageIdList .. " storage elements identified")
                initFinished = true
            end
        end
    end,
    function()
        local html = ''
        local storage_elements = {}
        for elemindex,id in ipairs(storageIdList) do
            local elementType = core.getElementDisplayNameById(id)
            if elementType:lower():find("container") then
                local elementName = core.getElementNameById(id)
                if elementName:lower():find(prefixes[1]:lower())
                        or elementName:lower():find(prefixes[2]:lower())
                        or elementName:lower():find(prefixes[3]:lower())
                        or elementName:lower():find(prefixes[4]:lower())
                        or elementName:lower():find(prefixes[5]:lower())
                        or elementName:lower():find(prefixes[6]:lower())
                        or elementName:lower():find(prefixes[7]:lower())
                        or elementName:lower():find(prefixes[8]:lower())
                        or elementName:lower():find(prefixes[9]:lower())
                then
                    local container = {}
                    local splitted = strSplit(elementName, '_')
                    local name = splitted[2]
                    local ingredient = system.getItem(name)
                    local container_size = "XS"
                    local container_amount = 1
                    local container_empty_mass = 0
                    local container_volume = 0
                    local contentQuantity = 0
                    local percent_fill = 0
                    if not elementType:lower():find("hub") then
                        local containerMaxHP = core.getElementMaxHitPointsById(id)
                        if containerMaxHP > 68000 then
                            container_size = "XXL"
                            container_empty_mass = 88410
                            container_volume = 512000 * (options.container_proficiency_lvl * 0.1) + 512000
                        elseif containerMaxHP > 33000 then
                            container_size = "XL"
                            container_empty_mass = 44210
                            container_volume = 256000 * (options.container_proficiency_lvl * 0.1) + 256000
                        elseif containerMaxHP > 17000 then
                            container_size = "L"
                            container_empty_mass = 14842.7
                            container_volume = 128000 * (options.container_proficiency_lvl * 0.1) + 128000
                        elseif containerMaxHP > 7900 then
                            container_size = "M"
                            container_empty_mass = 7421.35
                            container_volume = 64000 * (options.container_proficiency_lvl * 0.1) + 64000
                        elseif containerMaxHP > 900 then
                            container_size = "S"
                            container_empty_mass = 1281.31
                            container_volume = 8000 * (options.container_proficiency_lvl * 0.1) + 8000
                        else
                            container_size = "XS"
                            container_empty_mass = 229.09
                            container_volume = 1000 * (options.container_proficiency_lvl * 0.1) + 1000
                        end
                    else
                        if splitted[3] then
                            container_size = splitted[3]
                        end
                        if splitted[4] then
                            container_amount = splitted[4]
                        end
                        local volume = 0
                        container_volume_list = {xxl=512000, xl=256000, l=128000, m=64000, s=8000, xs=1000}
                        container_size = container_size:lower()
                        if container_volume_list[container_size] then
                            volume = container_volume_list[container_size]
                        end
                        container_volume = (volume * options.container_proficiency_lvl * 0.1 + volume) * tonumber(container_amount)
                        container_empty_mass = 55.8
                    end
                    local totalMass = core.getElementMassById(id)
                    local contentMassKg = totalMass - container_empty_mass
                    container.id = id
                    container.itemid = ingredient.id
                    container.realName = elementName
                    container.prefix = splitted[1] .. "_"
                    container.name = name
                    container.ingredient = ingredient
                    container.quantity = contentMassKg / (ingredient.unitMass - (ingredient.unitMass * (options.container_optimization_lvl * 0.05)))
                    container.volume = container_volume
                    container.percent = utils.round((ingredient.unitVolume * container.quantity) * 100 / container_volume)
                    if ingredient.name == "InvalidItem" then
                        container.percent = 0
                        container.quantity = 0
                    end
                    if container.percent > 100 then container.percent = 100 end
                    table.insert(storage_elements, container)
                end
            end
            if (elemindex%options.maxAmountOfElementsRefreshedByTick) == 0 then
                coroutine.yield(coroutinesTable[2])
            end
        end

        -- group by name and screen
        local groupped = {}
        if groupByItemName then
            for _,v in pairs(storage_elements) do
                local prefix = v.prefix:lower()
                if groupped[prefix .. v.itemid] then
                    groupped[prefix .. v.itemid].quantity = groupped[prefix .. v.itemid].quantity + v.quantity
                    groupped[prefix .. v.itemid].volume = groupped[prefix .. v.itemid].volume + v.volume
                    groupped[prefix .. v.itemid].percent = (v.ingredient.unitVolume * groupped[prefix .. v.itemid].quantity) * 100 / groupped[prefix .. v.itemid].volume
                else
                    groupped[prefix .. v.itemid] = v
                end
            end
        else
            groupped = storage_elements
        end

        -- sorting by tier
        local tiers = {}
        tiers[1] = {} --tier 0 (thx to Belorion#3127 for pointing Oxygen and Hydrogen are Tier 0 and not 1)
        tiers[2] = {} --tier 1
        tiers[3] = {} --tier 2
        tiers[4] = {} --tier 3
        tiers[5] = {} --tier 4
        tiers[6] = {} --tier 5
        for _,v in pairs(groupped) do
            table.insert(tiers[v.ingredient.tier+1],v)
        end

        -- sorting by name
        for k,v in pairs(tiers) do
            table.sort(tiers[k], function(a,b) return a.ingredient.name:lower() < b.ingredient.name:lower() end)
        end

        if #screens > 0 and not screens_displayed then
            for index, screen in pairs(screens) do
                local prefix = prefixes[index]
                local title = titles[index]
                local refreshScreen=true
                local i = 1
                for tier_k,tier in pairs(tiers) do
                    for _,container in pairs(tier) do
                        if container.prefix:lower():find(prefix:lower()) then
                            local item_name = container.ingredient.locDisplayNameWithSize
                            if container.ingredient.name == 'InvalidItem' then
                                item_name = 'Invalid Item Id'
                            end
                            local storage_data = {
                                item_name,
                                utils.round(container.quantity * (10 ^ options.QuantityRoundedDecimals)) / (10 ^ options.QuantityRoundedDecimals),
                                utils.round(container.volume),
                                utils.round(container.percent * (10 ^ options.PercentRoundedDecimals)) / (10 ^ options.PercentRoundedDecimals),
                                container.ingredient.iconPath,
                                titles[index],
                                refreshScreen,
                                container.ingredient.id,
                                screens_displayed
                            }
                            screen.setScriptInput(json.encode(storage_data))
                            refreshScreen = false
                            while tonumber(screen.getScriptOutput()) ~= i do
                                coroutine.yield(coroutinesTable[2])
                            end
                            i = i+1
                        end
                    end
                end
                screen.setScriptInput(json.encode(nil))
            end
            screens_displayed = true
        end
        unit.exit()
    end
}

function initCoroutines()
    for _,f in pairs(MyCoroutines) do
        local co = coroutine.create(f)
        table.insert(coroutinesTable, co)
    end
end

initCoroutines()

runCoroutines = function()
    for i,co in ipairs(coroutinesTable) do
        if coroutine.status(co) == "dead" then
            coroutinesTable[i] = coroutine.create(MyCoroutines[i])
        end
        if coroutine.status(co) == "suspended" then
            assert(coroutine.resume(co))
        end
    end
end

MainCoroutine = coroutine.create(runCoroutines)

system.showScreen(true)
