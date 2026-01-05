local providers = {}
local nextId = 1

---@class FakeItem
---@field label string
---@field description string
---@field imageUrl string
---@field count? number
---@field weight? number
---@field event? string

---@alias FakeItemProvider fun(): FakeItem[]

---Register a fake item provider that will be called every time the player opens their inventory
---@param callback FakeItemProvider Function that returns an array of fake items
---@return fun() unregister Function to call to unregister this provider
local function registerFakeItemProvider(callback)
    local id = nextId
    nextId = nextId + 1

    providers[id] = callback

    return function()
        providers[id] = nil
    end
end

---Get all fake items from all registered providers
---@return FakeItem[]
local function getAllFakeItems()
    local fakeItems = {}

    for _, provider in pairs(providers) do
        if provider then
            local success, result = pcall(provider)

            if success then
                for _, item in ipairs(result) do
                    table.insert(fakeItems, item)
                end
            end
        end
    end

    return fakeItems
end

---Convert fake items to ox_inventory item format and inject into inventory
---@param inventory table The player's inventory data
local function injectFakeItems(inventory)
    if not inventory or not inventory.items or not inventory.slots then
        return
    end

    local fakeItems = getAllFakeItems()

    if #fakeItems == 0 then
        return
    end

    -- Clone the items table to avoid modifying PlayerData.inventory
    local clonedItems = {}
    for slot, item in pairs(inventory.items) do
        clonedItems[slot] = item
    end
    inventory.items = clonedItems

    -- determine last nonempty slot
    local lastOccupiedSlotCount = 0
    for slot, item in pairs(clonedItems) do
        if slot > lastOccupiedSlotCount then
            lastOccupiedSlotCount = slot
        end
    end

    -- Assign fake items to empty slots starting after the last real item
    -- Also, start from the next slot that is a multiple of 5
    -- Fake items are not limited by inventory.slots and don't count toward weight
    local currentSlot = math.floor(lastOccupiedSlotCount / 5) * 5 + 6

    for _, fakeItem in ipairs(fakeItems) do
        local itemName = 'ox_inventory_fake_item_' .. currentSlot

        -- Create item in ox_inventory format
        local item = {
            name = itemName,
            label = fakeItem.label,
            count = fakeItem.count or 1,
            weight = fakeItem.weight or 0,
            slot = currentSlot,
            event = fakeItem.event,
            custom = true, -- Mark as fake/custom item for easy identification and to exclude from weight sum
            metadata = {
                label = fakeItem.label,
                description = fakeItem.description,
                imageurl = fakeItem.imageUrl, -- This will be used by NUI for image display
                itemData = {
                    name = itemName,
                    label = fakeItem.label,
                    description = fakeItem.description,
                },
            }
        }

        inventory.items[currentSlot] = item

        currentSlot = currentSlot + 1
    end
end

exports('registerFakeItemProvider', registerFakeItemProvider)

return {
    injectFakeItems = injectFakeItems
}
