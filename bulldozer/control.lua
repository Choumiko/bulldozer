require "defines"
require "bulldozer"
require "GUI"

remote.addinterface("bulldozer",{})
  
removeStone = true

  function resetMetatable(o, mt)
    setmetatable(o,{__index=mt})
    return o
  end

  local function onTick(event)

    if event.tick % 10 == 0  then
      for pi, player in ipairs(game.players) do
        if (player.vehicle ~= nil and player.vehicle.name == "bulldozer") then
          if player.gui.left.bull == nil then
            BULL.onPlayerEnter(player)
            GUI.createGui(player)
          end
        end
        if player.vehicle == nil and player.gui.left.bull ~= nil then
          BULL.onPlayerLeave(player)
          GUI.destroyGui(player)
        end
      end
    end
    for i, bull in ipairs(glob.bull) do
      bull:collect(event)
      if bull.driver and bull.driver.name ~= "bull_player" then
        GUI.updateGui(bull)
      end
    end
  end
  
  local function onGuiClick(event)
    local index = event.playerindex or event.name
    local player = game.players[index]
    if player.gui.left.bull ~= nil then
      local bull = BULL.findByPlayer(player)
      if bull then
        GUI.onGuiClick(event, bull, player)
      else
        player.print("Gui without bulldozer, wrooong!")
        GUI.destroyGui(player)
      end
    end
  end
  
  function onpreplayermineditem(event)
    local ent = event.entity
    local cname = ent.name
    if ent.type == "car" and cname == "bulldozer" then
      for i=1,#glob.bull do
        if glob.bull[i].vehicle.equals(ent) then
          glob.bull[i].delete = true
        end
      end
    end
  end

  function onplayermineditem(event)
    if event.itemstack.name == "bulldozer" then
      for i=#glob.bull,1,-1 do
        if glob.bull[i].delete then
          table.remove(glob.bull, i)
        end
      end
    end
  end
  
  local function onplayercreated(event)
    local player = game.getplayer(event.playerindex)
    local gui = player.gui
    if gui.top.bull ~= nil then
      gui.top.bull.destroy()
    end
  end

  game.onevent(defines.events.onplayercreated, onplayercreated)
  
  local function initGlob()
    if glob.version == nill or glob.version < "0.0.1" then
      glob = {}
      glob.settings = {}
      glob.version = "0.0.1"
    end
    glob.bull = glob.bull or {}
    for i,bull in ipairs(glob.bull) do
    bull = resetMetatable(bull, BULL)
    bull.index = nil
   end
  end
  
  local function oninit() initGlob() end

  local function onload()
    initGlob()
  end
  
  game.oninit(oninit)
  game.onload(onload)
  game.onevent(defines.events.ontick, onTick)
  game.onevent(defines.events.onguiclick, onGuiClick)
  game.onevent(defines.events.onplayermineditem, onplayermineditem)
  game.onevent(defines.events.onpreplayermineditem, onpreplayermineditem)
  game.onevent(defines.events.onbuiltentity, onbuiltentity)