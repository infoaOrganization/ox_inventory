local func, err = load(LoadResourceFile('ox_inventory_config', 'shops.lua'), 'user_code', 't')
if not func then
    print('Error loading shops.lua: ' .. err)
    return {}
end
return func()
