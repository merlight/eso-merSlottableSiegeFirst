local myNAME = "merSlottableSiegeFirst"


local function onAddOnLoaded(event, addOnName)
    if addOnName ~= myNAME then return end
    EVENT_MANAGER:UnregisterForEvent(myNAME, EVENT_ADD_ON_LOADED)

    local zorgShouldAddItemToList = ZO_QuickslotManager.ShouldAddItemToList
    local seenItems = {}

    local function clearSeenItems()
        ZO_ClearTable(seenItems)
    end

    local function myShouldAddItemToList(self, itemData)
        if not zorgShouldAddItemToList(self, itemData) then
            return false
        end

        local itemInstanceId = GetItemInstanceId(itemData.bagId, itemData.slotIndex)
        local seenData = itemInstanceId and seenItems[itemInstanceId]
        if seenData then
            -- add this stack to the first one
            seenData.stackCount = seenData.stackCount + itemData.stackCount
            return false
        end

        -- work-around missing name bug, which breaks sorting
        -- http://www.esoui.com/forums/showthread.php?p=11715#post11715
        local rawName = GetItemName(itemData.bagId, itemData.slotIndex)
        itemData.name = zo_strformat(SI_TOOLTIP_ITEM_NAME, rawName)

        -- dirty hack giving precedence to siege equipment and repair kits
        local itemType = GetItemType(itemData.bagId, itemData.slotIndex)
        if itemType == ITEMTYPE_SIEGE then
            itemData.name = "|c000100|r" .. itemData.name
        elseif itemType == ITEMTYPE_AVA_REPAIR then
            itemData.name = "|c000200|r" .. itemData.name
        else
            itemData.name = "|c000300|r" .. itemData.name
        end

        -- collapse more instances of the same item
        seenItems[itemInstanceId] = itemData
        return true
    end

    ZO_QuickslotManager.ShouldAddItemToList = myShouldAddItemToList
    ZO_PreHook(ZO_QuickslotManager, "UpdateList", clearSeenItems)
end


EVENT_MANAGER:RegisterForEvent(myNAME, EVENT_ADD_ON_LOADED, onAddOnLoaded)

