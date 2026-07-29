-----------------------------------
-- Phoenix Beta GM Commands
-----------------------------------
local commands =
{
    'return',
    'setbag',
    'givegil',
    'getfame',
    'setfamelevel',
    'changejob',
    'changesjob',
    'speed',
    'goto',
    'gotoid',
    'zone',
    'additem',
    'addkeyitem',
    'setmerits',
    'addallspells',
    'capallskills',
    'addallweaponskills',
    'addallattachments',
    'setskill',
    'setcraftrank',
    'getid',
    'getstats',
    'uptime',
    'immortal',
    'reset',
    'spawnmob',
    'gotoname'
}

for _, name in ipairs(commands) do
    if xi.commands[name] and xi.commands[name].cmdprops then
        xi.commands[name].cmdprops.permission = 0
    end
end

return {}
