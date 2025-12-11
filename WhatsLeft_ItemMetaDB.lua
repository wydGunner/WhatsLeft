-- WhatsLeft_ItemMetaDB.lua
WL_ItemMetaDB_Version = WL_ItemMetaDB_Version or 0
local CURRENT_META_VERSION = 3
if WL_ItemMetaDB_Version < CURRENT_META_VERSION then
  WL_ItemMetaDB = nil
  WL_ItemMetaDB_Version = CURRENT_META_VERSION
end

-- If there is no SavedVariables table yet, seed it with defaults.
WL_ItemMetaDB = WL_ItemMetaDB or {
-------------------------------------------------------------------------
--Remix Vendors--
-------------------------------------------------------------------------

--Arturos
[241439] = { isSet=true, isMount=false, isPet=false, isToy=false },
[241436] = { isSet=true, isMount=false, isPet=false, isToy=false },
[241434] = { isSet=true, isMount=false, isPet=false, isToy=false },
[241431] = { isSet=true, isMount=false, isPet=false, isToy=false },
[241428] = { isSet=true, isMount=false, isPet=false, isToy=false },
[241427] = { isSet=true, isMount=false, isPet=false, isToy=false },
[241425] = { isSet=true, isMount=false, isPet=false, isToy=false },
[241424] = { isSet=true, isMount=false, isPet=false, isToy=false },
[241422] = { isSet=true, isMount=false, isPet=false, isToy=false },
[241421] = { isSet=true, isMount=false, isPet=false, isToy=false },
[241419] = { isSet=true, isMount=false, isPet=false, isToy=false },
[241418] = { isSet=true, isMount=false, isPet=false, isToy=false },
[241417] = { isSet=true, isMount=false, isPet=false, isToy=false },
[241426] = { isSet=true, isMount=false, isPet=false, isToy=false },
[241423] = { isSet=true, isMount=false, isPet=false, isToy=false },
[241420] = { isSet=true, isMount=false, isPet=false, isToy=false },

--Pythagorus
[254850] = { isSet=false, isMount=false, isPet=false, isToy=false, isTransmog=false},
[151524] = { isSet=false, isMount=false, isPet=false, isToy=false, isTransmog=false },
[253273] = { isSet=true,  isMount=false, isPet=false, isToy=false, isTransmog=false },
[255006] = { isSet=true,  isMount=false, isPet=false, isToy=false, isTransmog=false },
[241586] = { isSet=true,  isMount=false, isPet=false, isToy=false, isTransmog=false },
[241582] = { isSet=true,  isMount=false, isPet=false, isToy=false, isTransmog=false },
[241578] = { isSet=true,  isMount=false, isPet=false, isToy=false, isTransmog=false },
[241574] = { isSet=true,  isMount=false, isPet=false, isToy=false, isTransmog=false },
[241570] = { isSet=true,  isMount=false, isPet=false, isToy=false, isTransmog=false },
[241566] = { isSet=true,  isMount=false, isPet=false, isToy=false, isTransmog=false },
[241562] = { isSet=true,  isMount=false, isPet=false, isToy=false, isTransmog=false },
[241558] = { isSet=true,  isMount=false, isPet=false, isToy=false, isTransmog=false },
[241553] = { isSet=true,  isMount=false, isPet=false, isToy=false, isTransmog=false },
[241549] = { isSet=true,  isMount=false, isPet=false, isToy=false, isTransmog=false },
[241545] = { isSet=true,  isMount=false, isPet=false, isToy=false, isTransmog=false },
[241541] = { isSet=true,  isMount=false, isPet=false, isToy=false, isTransmog=false },
[241597] = { isSet=true,  isMount=false, isPet=false, isToy=false, isTransmog=false },
[241601] = { isSet=true,  isMount=false, isPet=false, isToy=false, isTransmog=false },
[241604] = { isSet=true,  isMount=false, isPet=false, isToy=false, isTransmog=false },
[241607] = { isSet=true,  isMount=false, isPet=false, isToy=false, isTransmog=false },
[241537] = { isSet=true,  isMount=false, isPet=false, isToy=false, isTransmog=false },
[241533] = { isSet=true,  isMount=false, isPet=false, isToy=false, isTransmog=false },
[241529] = { isSet=true,  isMount=false, isPet=false, isToy=false, isTransmog=false },
[241525] = { isSet=true,  isMount=false, isPet=false, isToy=false, isTransmog=false },
[241521] = { isSet=true,  isMount=false, isPet=false, isToy=false, isTransmog=false },
[241517] = { isSet=true,  isMount=false, isPet=false, isToy=false, isTransmog=false },
[241513] = { isSet=true,  isMount=false, isPet=false, isToy=false, isTransmog=false },
[241509] = { isSet=true,  isMount=false, isPet=false, isToy=false, isTransmog=false },
[241505] = { isSet=true,  isMount=false, isPet=false, isToy=false, isTransmog=false },
[241501] = { isSet=true,  isMount=false, isPet=false, isToy=false, isTransmog=false },
[241497] = { isSet=true,  isMount=false, isPet=false, isToy=false, isTransmog=false },
[241493] = { isSet=true,  isMount=false, isPet=false, isToy=false, isTransmog=false },
[241489] = { isSet=true,  isMount=false, isPet=false, isToy=false, isTransmog=false },
[241485] = { isSet=true,  isMount=false, isPet=false, isToy=false, isTransmog=false },
[241481] = { isSet=true,  isMount=false, isPet=false, isToy=false, isTransmog=false },
[241477] = { isSet=true,  isMount=false, isPet=false, isToy=false, isTransmog=false },
[241473] = { isSet=true,  isMount=false, isPet=false, isToy=false, isTransmog=false },
[241469] = { isSet=true,  isMount=false, isPet=false, isToy=false, isTransmog=false },
[241465] = { isSet=true,  isMount=false, isPet=false, isToy=false, isTransmog=false },
[241461] = { isSet=true,  isMount=false, isPet=false, isToy=false, isTransmog=false },
[241459] = { isSet=true,  isMount=false, isPet=false, isToy=false, isTransmog=false },
[241453] = { isSet=true,  isMount=false, isPet=false, isToy=false, isTransmog=false },
[241449] = { isSet=true,  isMount=false, isPet=false, isToy=false, isTransmog=false },
[241445] = { isSet=true,  isMount=false, isPet=false, isToy=false, isTransmog=false },
[254750] = { isSet=false,  isMount=false, isPet=false, isToy=false, isTransmog=false },
--Horos
[138827] = { isSet=false, isMount=false, isPet=false,  isToy=false, isTransmog=true },
[138828] = { isSet=false, isMount=false, isPet=false,  isToy=false, isTransmog=true },
[239705] = { isSet=false, isMount=false, isPet=true,  isToy=false, isTransmog=false },
[239699] = { isSet=false, isMount=false, isPet=true,  isToy=false, isTransmog=false },
[129108] = { isSet=false, isMount=false, isPet=true,  isToy=false, isTransmog=false },
[141349] = { isSet=false, isMount=false, isPet=true, isToy=false, isTransmog=false },
[140320] = { isSet=false, isMount=false, isPet=true,  isToy=false, isTransmog=false },
[136901] = { isSet=false, isMount=false, isPet=true,  isToy=false, isTransmog=false },
[140316] = { isSet=false, isMount=false, isPet=true,  isToy=false, isTransmog=false },
[136900] = { isSet=false, isMount=false, isPet=true,  isToy=false, isTransmog=false },
[136903] = { isSet=false, isMount=false, isPet=true,  isToy=false, isTransmog=false },
[136922] = { isSet=false, isMount=false, isPet=true,  isToy=false, isTransmog=false },
[130167] = { isSet=false, isMount=false, isPet=true,  isToy=false, isTransmog=false },
[153252] = { isSet=false, isMount=false, isPet=true,  isToy=false, isTransmog=false },
[131724] = { isSet=false, isMount=false, isPet=false, isToy=true, isTransmog=false },
[131717] = { isSet=false, isMount=false, isPet=false, isToy=true, isTransmog=false },
[129165] = { isSet=false, isMount=false, isPet=false, isToy=true, isTransmog=false },
[130169] = { isSet=false, isMount=false, isPet=false, isToy=true, isTransmog=false },
[140363] = { isSet=false, isMount=false, isPet=false, isToy=true, isTransmog=false },
[141862] = { isSet=false, isMount=false, isPet=false, isToy=true, isTransmog=false },
[140160] = { isSet=false, isMount=false, isPet=false, isToy=true, isTransmog=false },
[142265] = { isSet=false, isMount=false, isPet=true,  isToy=false, isTransmog=false },
[142530] = { isSet=false, isMount=false, isPet=false, isToy=true, isTransmog=false },
[142529] = { isSet=false, isMount=false, isPet=false, isToy=true, isTransmog=false },
[142528] = { isSet=false, isMount=false, isPet=false, isToy=true, isTransmog=false },
[143662] = { isSet=false, isMount=false, isPet=false, isToy=true, isTransmog=false },
[119211] = { isSet=false, isMount=false, isPet=false, isToy=true, isTransmog=false },
[146953] = { isSet=false, isMount=false, isPet=true,  isToy=false, isTransmog=false },
[147841] = { isSet=false, isMount=false, isPet=true,  isToy=false, isTransmog=false },
[151828] = { isSet=false, isMount=false, isPet=true,  isToy=false, isTransmog=false },
[151829] = { isSet=false, isMount=false, isPet=true,  isToy=false, isTransmog=false },
[147843] = { isSet=false, isMount=false, isPet=false, isToy=true, isTransmog=false },
[147867] = { isSet=false, isMount=false, isPet=false, isToy=true, isTransmog=false },
[153195] = { isSet=false, isMount=false, isPet=true,  isToy=false, isTransmog=false },
[153055] = { isSet=false, isMount=false, isPet=true,  isToy=false, isTransmog=false },
[153054] = { isSet=false, isMount=false, isPet=true,  isToy=false, isTransmog=false },
[153026] = { isSet=false, isMount=false, isPet=true,  isToy=false, isTransmog=false },
[153056] = { isSet=false, isMount=false, isPet=true,  isToy=false, isTransmog=false },
[153204] = { isSet=false, isMount=false, isPet=false, isToy=true, isTransmog=false },
[153193] = { isSet=false, isMount=false, isPet=false, isToy=true, isTransmog=false },
[153183] = { isSet=false, isMount=false, isPet=false, isToy=true, isTransmog=false },
[153124] = { isSet=false, isMount=false, isPet=false, isToy=true, isTransmog=false },
[153293] = { isSet=false, isMount=false, isPet=false, isToy=true, isTransmog=false },
[153179] = { isSet=false, isMount=false, isPet=false, isToy=true, isTransmog=false },
[153181] = { isSet=false, isMount=false, isPet=false, isToy=true, isTransmog=false },
[153180] = { isSet=false, isMount=false, isPet=false, isToy=true, isTransmog=false },
[153253] = { isSet=false, isMount=false, isPet=false, isToy=true, isTransmog=false },
[153182] = { isSet=false, isMount=false, isPet=false, isToy=true, isTransmog=false },
[153126] = { isSet=false, isMount=false, isPet=false, isToy=true, isTransmog=false },
[152982] = { isSet=false, isMount=false, isPet=false, isToy=true, isTransmog=false },
[153004] = { isSet=false, isMount=false, isPet=false, isToy=true, isTransmog=false },
[153194] = { isSet=false, isMount=false, isPet=false, isToy=true, isTransmog=false },


--Jakkus
[253028] = { isSet=false, isMount=true,  isPet=false, isToy=false, isTransmog=false },
[253033] = { isSet=false, isMount=true,  isPet=false, isToy=false, isTransmog=false },
[252954] = { isSet=false, isMount=true,  isPet=false, isToy=false, isTransmog=false },
[253025] = { isSet=false, isMount=true,  isPet=false, isToy=false, isTransmog=false },
[253031] = { isSet=false, isMount=true,  isPet=false, isToy=false, isTransmog=false },
[253030] = { isSet=false, isMount=true,  isPet=false, isToy=false, isTransmog=false },
[253027] = { isSet=false, isMount=true,  isPet=false, isToy=false, isTransmog=false },
[253024] = { isSet=false, isMount=true,  isPet=false, isToy=false, isTransmog=false },
[253013] = { isSet=false, isMount=true,  isPet=false, isToy=false, isTransmog=false },
[253029] = { isSet=false, isMount=true,  isPet=false, isToy=false, isTransmog=false },
[253032] = { isSet=false, isMount=true,  isPet=false, isToy=false, isTransmog=false },
[253026] = { isSet=false, isMount=true,  isPet=false, isToy=false, isTransmog=false },

--Mount dude
[250428] = { isSet=false, isMount=true,  isPet=false, isToy=false },
[250427] = { isSet=false, isMount=true,  isPet=false, isToy=false },
[250429] = { isSet=false, isMount=true,  isPet=false, isToy=false },
[250723] = { isSet=false, isMount=true,  isPet=false, isToy=false },
[250721] = { isSet=false, isMount=true,  isPet=false, isToy=false },
[239687] = { isSet=false, isMount=true,  isPet=false, isToy=false },
[239667] = { isSet=false, isMount=true,  isPet=false, isToy=false },
[239665] = { isSet=false, isMount=true,  isPet=false, isToy=false },
[250757] = { isSet=false, isMount=true,  isPet=false, isToy=false },
[250756] = { isSet=false, isMount=true,  isPet=false, isToy=false },
[250752] = { isSet=false, isMount=true,  isPet=false, isToy=false },
[250751] = { isSet=false, isMount=true,  isPet=false, isToy=false },
[251795] = { isSet=false, isMount=true,  isPet=false, isToy=false },
[251796] = { isSet=false, isMount=true,  isPet=false, isToy=false },
[250424] = { isSet=false, isMount=true,  isPet=false, isToy=false },
[250425] = { isSet=false, isMount=true,  isPet=false, isToy=false },
[250423] = { isSet=false, isMount=true,  isPet=false, isToy=false },
[250426] = { isSet=false, isMount=true,  isPet=false, isToy=false },
[138258] = { isSet=false, isMount=true,  isPet=false, isToy=false },
[131734] = { isSet=false, isMount=true,  isPet=false, isToy=false },
[141713] = { isSet=false, isMount=true,  isPet=false, isToy=false },
[250728] = { isSet=false, isMount=true,  isPet=false, isToy=false },
[250761] = { isSet=false, isMount=true,  isPet=false, isToy=false },
[250760] = { isSet=false, isMount=true,  isPet=false, isToy=false },
[250759] = { isSet=false, isMount=true,  isPet=false, isToy=false },
[250758] = { isSet=false, isMount=true,  isPet=false, isToy=false },
[142236] = { isSet=false, isMount=true,  isPet=false, isToy=false },
[137574] = { isSet=false, isMount=true,  isPet=false, isToy=false },
[137575] = { isSet=false, isMount=true,  isPet=false, isToy=false },
[147806] = { isSet=false, isMount=true,  isPet=false, isToy=false },
[147807] = { isSet=false, isMount=true,  isPet=false, isToy=false },
[143764] = { isSet=false, isMount=true,  isPet=false, isToy=false },
[147805] = { isSet=false, isMount=true,  isPet=false, isToy=false },
[143643] = { isSet=false, isMount=true,  isPet=false, isToy=false },
[147804] = { isSet=false, isMount=true,  isPet=false, isToy=false },
[250192] = { isSet=false, isMount=true,  isPet=false, isToy=false },
[250748] = { isSet=false, isMount=true,  isPet=false, isToy=false },
[250747] = { isSet=false, isMount=true,  isPet=false, isToy=false },
[250746] = { isSet=false, isMount=true,  isPet=false, isToy=false },
[250745] = { isSet=false, isMount=true,  isPet=false, isToy=false },
[250803] = { isSet=false, isMount=true,  isPet=false, isToy=false },
[250806] = { isSet=false, isMount=true,  isPet=false, isToy=false },
[250805] = { isSet=false, isMount=true,  isPet=false, isToy=false },
[250804] = { isSet=false, isMount=true,  isPet=false, isToy=false },
[250802] = { isSet=false, isMount=true,  isPet=false, isToy=false },
[152816] = { isSet=false, isMount=true,  isPet=false, isToy=false },
[152903] = { isSet=false, isMount=true,  isPet=false, isToy=false },
[152904] = { isSet=false, isMount=true,  isPet=false, isToy=false },
[152905] = { isSet=false, isMount=true,  isPet=false, isToy=false },
[153043] = { isSet=false, isMount=true,  isPet=false, isToy=false },
[153044] = { isSet=false, isMount=true,  isPet=false, isToy=false },
[153042] = { isSet=false, isMount=true,  isPet=false, isToy=false },
[152790] = { isSet=false, isMount=true,  isPet=false, isToy=false },
[152843] = { isSet=false, isMount=true,  isPet=false, isToy=false },
[152844] = { isSet=false, isMount=true,  isPet=false, isToy=false },
[152841] = { isSet=false, isMount=true,  isPet=false, isToy=false },
[152840] = { isSet=false, isMount=true,  isPet=false, isToy=false },
[152842] = { isSet=false, isMount=true,  isPet=false, isToy=false },
[152814] = { isSet=false, isMount=true,  isPet=false, isToy=false },
[152789] = { isSet=false, isMount=true,  isPet=false, isToy=false },

--Unicus
[253382] = { isSet=true,  isMount=false, isPet=false, isToy=false },
[255156] = { isSet=true,  isMount=false, isPet=false, isToy=false },
[253379] = { isSet=true,  isMount=false, isPet=false, isToy=false },
[241416] = { isSet=true,  isMount=false, isPet=false, isToy=false },
[241415] = { isSet=true,  isMount=false, isPet=false, isToy=false },
[241414] = { isSet=true,  isMount=false, isPet=false, isToy=false },
[241413] = { isSet=true,  isMount=false, isPet=false, isToy=false },
[241412] = { isSet=true,  isMount=false, isPet=false, isToy=false },
[241411] = { isSet=true,  isMount=false, isPet=false, isToy=false },
[241410] = { isSet=true,  isMount=false, isPet=false, isToy=false },
[241409] = { isSet=true,  isMount=false, isPet=false, isToy=false },
[241408] = { isSet=true,  isMount=false, isPet=false, isToy=false },
[241407] = { isSet=true,  isMount=false, isPet=false, isToy=false },
[241406] = { isSet=true,  isMount=false, isPet=false, isToy=false },
[241403] = { isSet=true,  isMount=false, isPet=false, isToy=false },
[241402] = { isSet=true,  isMount=false, isPet=false, isToy=false },
[241400] = { isSet=true,  isMount=false, isPet=false, isToy=false },
[241399] = { isSet=true,  isMount=false, isPet=false, isToy=false },
[241397] = { isSet=true,  isMount=false, isPet=false, isToy=false },
[241396] = { isSet=true,  isMount=false, isPet=false, isToy=false },
[241395] = { isSet=true,  isMount=false, isPet=false, isToy=false },
[241358] = { isSet=true,  isMount=false, isPet=false, isToy=false },
[190772] = { isSet=true, isMount=false, isPet=false, isToy=false },
[241356] = { isSet=true,  isMount=false, isPet=false, isToy=false },
[241355] = { isSet=true,  isMount=false, isPet=false, isToy=false },
[251271] = { isSet=true,  isMount=false, isPet=false, isToy=false },
[241360] = { isSet=true,  isMount=false, isPet=false, isToy=false },
[241392] = { isSet=true,  isMount=false, isPet=false, isToy=false },
[241390] = { isSet=true,  isMount=false, isPet=false, isToy=false },
[241389] = { isSet=true,  isMount=false, isPet=false, isToy=false },
[241385] = { isSet=true,  isMount=false, isPet=false, isToy=false },
[241388] = { isSet=true,  isMount=false, isPet=false, isToy=false },
[241387] = { isSet=true,  isMount=false, isPet=false, isToy=false },
[241386] = { isSet=true,  isMount=false, isPet=false, isToy=false },
[253385] = { isSet=true,  isMount=false, isPet=false, isToy=false },
[253358] = { isSet=true,  isMount=false, isPet=false, isToy=false },
[253551] = { isSet=true,  isMount=false, isPet=false, isToy=false },
[253556] = { isSet=true,  isMount=false, isPet=false, isToy=false },
[253561] = { isSet=true,  isMount=false, isPet=false, isToy=false },
[253565] = { isSet=true,  isMount=false, isPet=false, isToy=false },

[226127] = { isSet=false, isMount=false, isPet=false, isToy=false },
[5976]   = { isSet=false, isMount=false, isPet=false, isToy=false },
[139170] = { isSet=true,  isMount=false, isPet=false, isToy=false },
[139169] = { isSet=true,  isMount=false, isPet=false, isToy=false },
[139168] = { isSet=true,  isMount=false, isPet=false, isToy=false },
[139167] = { isSet=true,  isMount=false, isPet=false, isToy=false },
[241440] = { isSet=true,  isMount=false, isPet=false, isToy=false },
[241438] = { isSet=true,  isMount=false, isPet=false, isToy=false },
[241437] = { isSet=true,  isMount=false, isPet=false, isToy=false },
[241435] = { isSet=true,  isMount=false, isPet=false, isToy=false },
[241433] = { isSet=true,  isMount=false, isPet=false, isToy=false },
[241432] = { isSet=true,  isMount=false, isPet=false, isToy=false },
[241430] = { isSet=true,  isMount=false, isPet=false, isToy=false },
[241429] = { isSet=true,  isMount=false, isPet=false, isToy=false },
[241384] = { isSet=true,  isMount=false, isPet=false, isToy=false },
[241383] = { isSet=true,  isMount=false, isPet=false, isToy=false },
[241382] = { isSet=true,  isMount=false, isPet=false, isToy=false },
[241381] = { isSet=true,  isMount=false, isPet=false, isToy=false },
[241380] = { isSet=true, isMount=false,  isPet=false, isToy=false },
[241379] = { isSet=true,  isMount=false, isPet=false, isToy=false },
[241378] = { isSet=true,  isMount=false, isPet=false, isToy=false },
[241377] = { isSet=true,  isMount=false, isPet=false, isToy=false },
[241376] = { isSet=true,  isMount=false, isPet=false, isToy=false },
[241375] = { isSet=true,  isMount=false, isPet=false, isToy=false },
[241374] = { isSet=true,  isMount=false, isPet=false, isToy=false },
[241373] = { isSet=true, isMount=false,  isPet=false, isToy=false },
[241372] = { isSet=true,  isMount=false, isPet=false, isToy=false },
[241371] = { isSet=true,  isMount=false, isPet=false, isToy=false },
[241370] = { isSet=true,  isMount=false, isPet=false, isToy=false },
[241369] = { isSet=true,  isMount=false, isPet=false, isToy=false },
[241364] = { isSet=true,  isMount=false, isPet=false, isToy=false },
[241363] = { isSet=true,  isMount=false, isPet=false, isToy=false },
[241362] = { isSet=true,  isMount=false, isPet=false, isToy=false },
[241361] = { isSet=true,  isMount=false, isPet=false, isToy=false },
[241444] = { isSet=true,  isMount=false, isPet=false, isToy=false },
[241443] = { isSet=true,  isMount=false, isPet=false, isToy=false },
[241442] = { isSet=true,  isMount=false, isPet=false, isToy=false },
[241441] = { isSet=true,  isMount=false, isPet=false, isToy=false },
[241359] = { isSet=true,  isMount=false, isPet=false, isToy=false },
[241368] = { isSet=true,  isMount=false, isPet=false, isToy=false },
[241367] = { isSet=true,  isMount=false, isPet=false, isToy=false },
[241366] = { isSet=true,  isMount=false, isPet=false, isToy=false },
[241365] = { isSet=true,  isMount=false, isPet=false, isToy=false },
[241391] = { isSet=true,  isMount=false, isPet=false, isToy=false },
[253594] = { isSet=true,  isMount=false, isPet=false, isToy=false },
[253588] = { isSet=true,  isMount=false, isPet=false, isToy=false },
[254754] = { isSet=true,  isMount=false, isPet=false, isToy=false },
[254753] = { isSet=true,  isMount=false, isPet=false, isToy=false },
[254752] = { isSet=true,  isMount=false, isPet=false, isToy=false },



-------------------------------------------------------------------------
--Legion Vendors--
-------------------------------------------------------------------------
[44226] = { isSet=false, isMount=true, isPet=false, isToy=false }, 
[44690] = { isSet=false, isMount=true, isPet=false, isToy=false }, 
[44231] = { isSet=false, isMount=true, isPet=false, isToy=false }, 
[44234] = { isSet=false, isMount=true, isPet=false, isToy=false }, 
[25474] = { isSet=false, isMount=true, isPet=false, isToy=false }, 
[25475] = { isSet=false, isMount=true, isPet=false, isToy=false }, 
[25476] = { isSet=false, isMount=true, isPet=false, isToy=false }, 
[25531] = { isSet=false, isMount=true, isPet=false, isToy=false }, 
[25533] = { isSet=false, isMount=true, isPet=false, isToy=false }, 
[25477] = { isSet=false, isMount=true, isPet=false, isToy=false }, 
[25532] = { isSet=false, isMount=true, isPet=false, isToy=false }, 
[63251] = { isSet=false, isMount=false, isPet=false, isToy=false },

-------------------------------------------------------------------------
--The War Within Vendors--
-------------------------------------------------------------------------

--Velerd--
[230286] = { isSet=false, isMount=false, isPet=false, isToy=false },
[230378] = { isSet=false, isMount=false, isPet=false, isToy=false },
[230372] = { isSet=false, isMount=false, isPet=false, isToy=false },
[230367] = { isSet=false, isMount=false, isPet=false, isToy=false },
[230375] = { isSet=false, isMount=false, isPet=false, isToy=false },
[230369] = { isSet=false, isMount=false, isPet=false, isToy=false },
[230376] = { isSet=false, isMount=false, isPet=false, isToy=false },
[230288] = { isSet=false, isMount=false, isPet=false, isToy=false },
[230320] = { isSet=false, isMount=false, isPet=false, isToy=false },
[230309] = { isSet=false, isMount=false, isPet=false, isToy=false },
[230341] = { isSet=false, isMount=false, isPet=false, isToy=false },
[230290] = { isSet=false, isMount=false, isPet=false, isToy=false },
[230322] = { isSet=false, isMount=false, isPet=false, isToy=false },
[230317] = { isSet=false, isMount=false, isPet=false, isToy=false },
[230349] = { isSet=false, isMount=false, isPet=false, isToy=false },
[230298] = { isSet=false, isMount=false, isPet=false, isToy=false },
[230330] = { isSet=false, isMount=false, isPet=false, isToy=false },
[230312] = { isSet=false, isMount=false, isPet=false, isToy=false },
[230344] = { isSet=false, isMount=false, isPet=false, isToy=false },
[230304] = { isSet=false, isMount=false, isPet=false, isToy=false },
[230336] = { isSet=false, isMount=false, isPet=false, isToy=false },
[230293] = { isSet=false, isMount=false, isPet=false, isToy=false },
[230325] = { isSet=false, isMount=false, isPet=false, isToy=false },
[230363] = { isSet=false, isMount=false, isPet=false, isToy=false },
[230364] = { isSet=false, isMount=false, isPet=false, isToy=false },
[230365] = { isSet=false, isMount=false, isPet=false, isToy=false },
[230366] = { isSet=false, isMount=false, isPet=false, isToy=false },
[230357] = { isSet=false, isMount=false, isPet=false, isToy=false },
[230358] = { isSet=false, isMount=false, isPet=false, isToy=false },
[230359] = { isSet=false, isMount=false, isPet=false, isToy=false },
[230360] = { isSet=false, isMount=false, isPet=false, isToy=false },
[230361] = { isSet=false, isMount=false, isPet=false, isToy=false },
[230362] = { isSet=false, isMount=false, isPet=false, isToy=false },
[230352] = { isSet=false, isMount=false, isPet=false, isToy=false },
[230354] = { isSet=false, isMount=false, isPet=false, isToy=false },
[230355] = { isSet=false, isMount=false, isPet=false, isToy=false },
[230353] = { isSet=false, isMount=false, isPet=false, isToy=false },
[230356] = { isSet=false, isMount=false, isPet=false, isToy=false },
[225739] = { isSet=false, isMount=false, isPet=false, isToy=false },
[224556] = { isSet=false, isMount=false, isPet=false, isToy=false },

[235630] = { isSet=true, isMount=false, isPet=false, isToy=false }, 
[241591] = { isSet=true, isMount=false, isPet=false, isToy=false }, 
[241590] = { isSet=true, isMount=false, isPet=false, isToy=false }, 
[242240] = { isSet=true, isMount=false, isPet=false, isToy=false }, 
[242234] = { isSet=true, isMount=false, isPet=false, isToy=false }, 
[242233] = { isSet=true, isMount=false, isPet=false, isToy=false }, 
[242232] = { isSet=true, isMount=false, isPet=false, isToy=false }, 
[242231] = { isSet=true, isMount=false, isPet=false, isToy=false }, 
[242230] = { isSet=true, isMount=false, isPet=false, isToy=false }, 
[242229] = { isSet=true, isMount=false, isPet=false, isToy=false }, 
[242228] = { isSet=true, isMount=false, isPet=false, isToy=false }, 
[241593] = { isSet=true, isMount=false, isPet=false, isToy=false }, 
[241592] = { isSet=true, isMount=false, isPet=false, isToy=false }, 
[242235] = { isSet=true, isMount=false, isPet=false, isToy=false }, 
[242239] = { isSet=true, isMount=false, isPet=false, isToy=false }, 
[242238] = { isSet=true, isMount=false, isPet=false, isToy=false }, 
[242237] = { isSet=true, isMount=false, isPet=false, isToy=false }, 
[242236] = { isSet=true, isMount=false, isPet=false, isToy=false },

[241405] = { isSet=true, isMount=false, isPet=false, isToy=false }, 
[241404] = { isSet=true, isMount=false, isPet=false, isToy=false }, 
[241401] = { isSet=true, isMount=false, isPet=false, isToy=false }, 
[241398] = { isSet=true, isMount=false, isPet=false, isToy=false }, 
[241394] = { isSet=true, isMount=false, isPet=false, isToy=false }, 
[241393] = { isSet=true, isMount=false, isPet=false, isToy=false }, 
[241354] = { isSet=true, isMount=false, isPet=false, isToy=false },

[254850] = { isSet=false, isMount=false, isPet=false, isToy=false },
[254848] = { isSet=false, isMount=false, isPet=false, isToy=false },


[29466] = { isSet=false, isMount=true, isPet=false, isToy=false }, 
[29469] = { isSet=false, isMount=true, isPet=false, isToy=false }, 
[29470] = { isSet=false, isMount=true, isPet=false, isToy=false }, 
[29472] = { isSet=false, isMount=true, isPet=false, isToy=false }, 
[34129] = { isSet=false, isMount=true, isPet=false, isToy=false },


}



WL_EnsembleAppearances = WL_EnsembleAppearances or {
--Pythagorus
[241586]={31083,31085,31115,31087,31079,31084,31080,31086,31082},
[241578]={29083,29085,29048,29049,29087,29086,29082,29079,29084,29080},
[241574]={31913,31915,32166,31911,31916,31912,31909,31914,31910},
[241582]={30280,30282,30231,30283,30284,30279,30276,30281,30277},
[241566]={30670,30671,30491,30669,30674,30672,30667,30675,30673,30668},
[241570]={30696,30698,30815,30819,30700,30699,30695,30692,30697,30693},
[241562]={28986,28988,32317,28984,28989,28985,28981,28987,28982},
[241558]={29904,29905,30129,29902,29907,29903,29900,29906,29901},
[241553]={31039,31041,31348,31037,31043,31042,31038,30964,31040,31036},
[241549]={29829,29831,29939,29827,29825,29830,29826,29832,29828},
[241545]={29452,29454,29676,29677,29456,29455,29451,29448,29453,29449},
[241541]={31449,31455,32229,31452,31456,31453,31450,31454,31451},
[241597]={32797,32799,32770,32795,32800,32796,32793,32798,32794},
[241601]={32687,32689,32714,32685,32690,32686,32683,32688,32684},
[241604]={32885,32887,33169,32883,32888,32884,32881,32886,32882},
[241607]={32832,32834,32852,32836,32835,32831,32828,32833,32829},
[241537]={33556,33558,34152,33560,33555,33553,33557,33554},
[241533]={33384,33386,34091,33388,33387,33383,33381,33385,33382},
[241529]={33194,33196,33238,33198,33197,33193,33190,33195,33191},
[241525]={33312,33314,34249,33316,33311,33309,33313,33310},
[241521]={33588,33590,34123,33592,33591,33587,33585,33589},
[241517]={33565,33567,34194,33563,33564,33561,33566,33562},
[241513]={33685,33687,34343,33683,33688,33684,33681,33686,33682},
[241509]={33458,33460,33939,33456,33461,33457,33454,33459,33455},
[241505]={33868,33870,34311,33872,33867,33865,33869,33866},
[241501]={33783,33785,34227,33781,33786,33782,33779,33784,33780},
[241497]={32917,32919,32985,32915,32916,32913,32918,32914},
[241493]={33069,33071,33135,33067,33068,33065,33070,33066},
[241489]={34578,34581,35284,34579,34582,34577,34575,34580,34576},
[241485]={34911,34913,35315,34914,34910,34908,34912,34909},
[241481]={34839,34841,35342,34843,34842,34838,34836,34840,34837},
[241477]={29585,29587,29597,29583,29588,29584,29581,29586,29582},
[241473]={35075,35077,35384,35073,35078,35074,35076,35072},
[241469]={34986,34988,35724,34984,34985,34982,34987,34983},
[241465]={35205,35207,35833,35203,35208,35204,35201,35206},
[241461]={34629,34631,35756,34627,34632,34628,34625,34630,34626},
[241459]={35122,35124,35780,35120,35125,35121,35118,35123,35119},
[241453]={34479,34481,34517,34473,34482,34478,34471,34480},
[241449]={34754,34756,35870,34752,34757,34753,34750,34755,34751},
[241445]={34698,34700,35808,34696,34701,34697,34694,34699,34695},
[255006]={152094,255009},

--Arturos
[241439]={27572,27574,27570,27576,27575,27571,27568,27573,27569},
[241434]={27454,27456,29504,29505,27452,27457,27453,27450,27455,27451},
[241428]={27218,27221,27216,27222,27220,27217,27214,27219,27215},
[241425]={26906,26908,29332,29333,29334,29335,29336,26904,26909,26905,26902,26907,26903},
[241422]={27267,27268,27265,27270,27266,27263,27269,27264},
[241436]={27240,27242,27238,27244,27243,27239,27236,27241,27237},
[241431]={27125,27127,27123,99128,27124,27121,27126,27122},
[241427]={27191,27194,27189,27195,116028,27193,27190,27187,27192,27188},
[241424] = {
  26925,   -- Head
  26927,   -- Shoulder
  29350,   -- Back
  29351,   -- Back
  29352,   -- Back
  29353,   -- Back
  29354,   -- Back
  26923,   -- Chest
  26928,   -- Wrist
  26924,   -- Hands
  26921,   -- Waist
  26926,   -- Legs
  26922,   -- Feet
},
[241421]={27283,27284,27281,27286,27282,27279,27285,27280},
[241417]={34050,34052,32368,34048,34053,34049,34046,34051,34047},
[241419]={27079,27081,27077,27082,27078,27075,27080,27076},
[241423]={33974,33976,35158,35159,35160,33972,33977,33973,33970,33975,33971},
[241418]={27079,27082,27098,27103,27099,27096,27091,27097},
[241426]={33899,33902,33904,33903,33898,33896,33900,33897},
[241420]={34008,34010,34262,34263,34264,34265,34006,34011,34007,34004,34009,34005},

--Freddie Threads
[235630]={27628,27633,27634,27639,27640,27645,31711,31716},
[241591]={28148,28149,28155,28156,28164,28165,28179,28180,28187,28188},
[241590]={27984,27987,27990,27993,27996,28001,31717,31719},
[242234]={31144,31146,31154,31156,31164,31166,31176,32051,32052},
[242233]={31111,31116,31117,31121,31126,31127,31132,31137,31138},
[242232]={30472,30480,30488,30503,30506,30512,30515,30521,30524,30530,30533,30539,31919,31925},
[242231]={30324,30328,30334,30340},
[242230]={29940,29947,29952,29959,29963,29970,29974,29981,29986,29993,31979,31982,29997,30004},
[242229]={29398,29400,29401,29409,29411},
[242228]={29006,29017,29020,29026,29029,29035,29042,29043,29047,29053,29056,29062,120709,120755},
[242240]={30830,30837,30839,30846,30847,30854,30855,30862},
[241593]={28956,28958,28963,28965,28970,28972,28977,28979},
[241592]={28373,28376,28418,28422,28428,28431,28436,28440,28474,28478,28486,28491},
[242235]={34254,34255,34259,34260,34263,34264,34267,34268,34271,34272},
[242239]={35643,35644,35649,35650,35655,35656,35661,35662,35667,35668},
[242238]={35624,35625,35628,35629,35632,35633,35676,35679,35680,35683,35684,121376},
[242237]={35608,35609,35611,35612,35614,35615,35617,35618,35620,35621},
[242236]={35583,35584,35589,35590,35594,35595,35599,35600,35605,121242},

--Agos the Silent 
[241405]={28008,28009,27985,28006,28011,28007,28004,28010,28005},
[241404]={28024,28025,27998,28022,28027,28023,28020,28026,28021},
[241401]={28627,28639,28638,28634,28625,28636,28640,28626},
[241398]={28548,28550,28546,28551,28547,28544,28549,28545},
[241394]={27091,27094,27089,27095,27090,27087,27093,27088},
[241393]={28676,28678,28674,28679,28675,28672,28677,28673},
[241354]={27275,27276,27273,27278,27274,27271,27277,27272},

--Larah Treebender
[139170]={31376,31379,31374,31380,31375,31372,31377,31373},
[139169]={31393,31396,31394,31397,31392,31390,31395,31391},
[139168]={31385,31387,31383,31388,31384,31381,31386,31382},
[139167]={31310,31312,31308,31313,31309,31306,31311,31307},
[241440]={27544,27547,27542,27549,27548,27543,27545,27541,27546},
[241438]={27563,27565,27561,27567,27566,27562,27559,27564,27560},
[241437]={27249,27251,27247,27253,27252,27248,27245,27250,27246},
[241435]={27258,27260,27256,27262,27261,27257,27254,27259,27255},
[241433]={27346,27348,27344,27349,27345,27342,27347,27343},
[241432]={27462,27464,29518,29519,27460,27465,27459,27463,27461},
[241430]={27109,27111,27107,27112,27108,27104,27110,27106},
[241429]={27117,27119,32411,27115,27120,27116,27113,27118,27114},
[241384]={27801,27803,27799,27805,27804,27800,27797,27802,27798},
[241383]={27810,27812,27808,27814,27813,27809,27806,27811,27807},
[241382]={27819,27821,34028,30412,30413,30414,30415,27817,27823,27822,27818,27815,27820,27816},
[241381]={27828,27830,27826,27832,27831,27827,27824,27829,27825},
[241380]={26579,26581,26577,26582,26578,26575,26580,26576},
[241379]={26588,26590,26586,26591,26587,26584,26589,26585},
[241378]={26596,26598,26594,26599,26595,26592,26597,26593},
[241377]={26604,26606,26602,26607,26603,26600,26605,26601},
[241376]={26612,26614,29376,29378,26610,26616,26615,26611,26608,26613,27083,26609},
[241375]={26849,26851,29387,29389,29390,26847,26853,26852,26848,26845,26850,27084,26846},
[241374]={26858,26860,29420,29422,26856,26862,26861,26857,26854,26859,27085,26855},
[241373]={26867,26869,29431,29432,29433,30419,30421,30423,26865,26871,26870,26866,26863,26868,27086,26864},
[241372]={26941,26943,30395,30396,26939,26944,26940,26937,26942,26938},
[241371]={26949,26951,26947,26952,26948,26945,26950,26946},
[241370]={26957,26959,26955,26960,26956,26953,26958,26954},
[241369]={26965,26967,26963,26968,26964,26961,26966,26962},
[241364]={33917,33920,33922,116025,33921,33916,33914,33918,33915},
[241363]={33966,33968,35154,35155,35156,33964,33969,33965,33962,33967,33963},
[241362]={34024,34026,34270,34271,34272,34022,34027,34023,34020,34025,34021},
[241361]={34033,34035,34031,34036,34032,34029,34034,34030},
[241444]={33890,33892,33895,33894,33889,33887,33891,33888},
[241443]={33958,33960,33956,33961,33957,33954,33959,33955},
[241442]={34000,34002,34258,34259,34260,33998,34003,33999,33996,34001,33997},
[241441]={34041,34043,34039,34044,34040,34037,34042,34038},
[241359]={35569,35571,35677,35678,35567,35572,35568,35565,35570,35566},
[241368]={35406,35408,35582,35584,35585,35410,35409,35405,35403,35407,35404,116016},
[241367]={35456,35458,35610,35454,35459,35455,35452,35457,35453},
[241366]={35521,35523,35664,35665,35519,35525,35524,35520,35517,35522,35518},
[241365]={35561,35563,35630,35631,35559,35564,35560,35557,35562,35558},
[241391]={35464,35466,35613,35462,35467,35463,35460,35465,35461},
[253594]={34438,34440,34442,34441,34437,34435,34439,34436},
[253588]={34447,34449,34445,34450,34446,34443,34448,34444},
[254754]={21728,21730,21726,21731,21727,21724,21729,21725},
[254753]={21774,21770,21772,21771,21773,21768,21775,21769},
[254752]={21720,21722,21718,21723,21719,21716,21721,21717},

--Unicus 
[253382]={69931,69932},
[255156]={117240,117241},
[253379]={119895,119896,119897,119898,119899,119900,119901,119902,119903,119904,119905,119906,119907,119908,119909,119910,119911,119912,119913},
[241416]={27200,27203,27198,27204,27202,27199,27196,27201,27197},
[241415]={28309,28311,28307,28312,28308,28304,28310,28306},
[241414]={28325,28327,28323,28328,28324,28321,28326,28322},
[241413]={27650,27655,27652,27648,27654,27653,27649,27646,27651,99583,27647},
[241412]={27660,27665,27662,27658,27664,99585,27663,27659,27656,27661,99582,27657},
[241411]={27670,27675,27672,27643,27668,27674,27673,27669,27666,27671,99581,27667},
[241410]={27858,27860,27856,27861,27857,27854,27859,27855},
[241409]={27866,27868,27864,27869,27865,27862,27867,27863},
[241408]={32416,32418,32420,32565,32566,32567,32414,32419,32415,32412,32417,32413},
[241407]={26876,26879,29323,29324,29325,29326,29327,29329,26874,26878,26875,26872,26877,26873},
[241406]={26917,26919,29341,29342,29343,29344,26915,26920,26916,26910,26918,26914},
[241403]={28605,28607,28603,28608,28604,28601,28606,28602},
[241402]={27291,27292,27289,27294,27290,27287,27293,27288},
[241400]={28529,28533,28527,28534,28528,28525,28530,28526},
[241399]={28539,28541,28537,28542,28538,28535,28540,28536},
[241397]={28556,28558,28554,28559,28555,28552,28557,28553},
[241396]={28668,28670,28666,28671,28667,28664,28669,28665},

[241395]={27070,27072,27068,27074,27069,27066,27073,27067},
[241358]={27307,27309,27305,27310,27306,27303,27308,27304},
[190772]={28707,28710,28705,28709,28711,28706,28703,28708,28704},
[241356]={27792,27794,27790,27795,27791,27788,27793,27789},
[241355]={27209,27212,27213,27211,27205,27210,27206},
[251271]={28383,28385,28381,28386,28382,28379,28384,28380},
[241360]={35430,35432,35603,35605,35606,35434,116014,35433,35429,35427,35431,35428},
[241392]={35448,35450,35607,35446,35451,35447,35444,35449,35445},
[241390]={35494,35496,35492,35498,35497,35493,35490,35495,35491},
[241389]={35553,35555,35674,35675,35551,35556,35552,35549,35554,35550},

--[241385]={36088,36091,36093,36092,36089,36085,36090,36086},
--[241388]={36113,36116,36118,36117,36114,36111,36115,99786},
--[241387]={36131,36135,36132,36136,36133,36129,36134,36130},
--[241386]={36139,36143,36140,36144,36141,36137,36142,36138},

[253565]={119930,119931,119932},
[253556]={119922,119923,119924,119925},
[253551]={119916,119917,119918},
[253358]={119892,119893,119894},
[253385]={119914,119915},
[253569]={119919,119920,119921},
[253561]={119926,119927,119928,119929},

}

-- Slash command: /wlvendor
SLASH_WLVENDOR1 = "/wlvendor"

SlashCmdList["WLVENDOR"] = function()
    -- Make sure a vendor is actually open
    if not MerchantFrame or not MerchantFrame:IsShown() then
        print("|cffff5555[What's Left]|r Open a vendor first, then use /wlvendor.")
        return
    end

    local numItems = GetMerchantNumItems()
    local ids = {}

    for index = 1, numItems do
        local itemID = GetMerchantItemID(index)

        -- Fallback to parsing the link if needed
        if not itemID then
            local link = GetMerchantItemLink(index)
            if link then
                itemID = tonumber(link:match("item:(%d+)"))
            end
        end

        if itemID then
            table.insert(ids, itemID)
        end
    end

    if #ids == 0 then
        print("|cffff5555[What's Left]|r No itemIDs found for this vendor.")
        return
    end

    print("|cff66ff99[What's Left]|r Vendor itemIDs (" .. #ids .. "):")

    -- Print in chunks so chat doesn't explode / truncate
    local chunkSize = 12
    for i = 1, #ids, chunkSize do
        local line = {}
        for j = i, math.min(i + chunkSize - 1, #ids) do
            table.insert(line, ids[j])
        end
        print(table.concat(line, ","))
    end
end

-- Optional slash: /wlsettings
SLASH_WLSETTINGS1 = "/wlsettings"
SlashCmdList.WLSETTINGS = function() VKF_ToggleSettings() end

