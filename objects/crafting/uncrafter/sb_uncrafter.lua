local ini = init or function() end

function init(a) ini(a)
	local b = {}
	b={"copperbar","copperbar"} sb_swapOutputs(1,"tungstenbar",b)
	b={"sb_steelbar","tungstenbar"} sb_swapOutputs(2,"titaniumbar",b)
	b={"goldbar","platinumbar"} sb_swapOutputs(3,"durasteelbar",b)
	weaponLevelKinds[4][#weaponLevelKinds[4]+1] = "durasteelbar"
	weaponLevelKinds[4][#weaponLevelKinds[4]+1] = "sb_refinedrubium"
	weaponLevelKinds[4][#weaponLevelKinds[4]+1] = "sb_refinedrubium"
	weaponLevelKinds[5][#weaponLevelKinds[5]+1] = "sb_refinedrubium"
	weaponLevelKinds[5][#weaponLevelKinds[5]+1] = "sb_ceruliumcompound"
	weaponLevelKinds[5][#weaponLevelKinds[5]+1] = "sb_ceruliumcompound"
	weaponLevelKinds[5][#weaponLevelKinds[5]+1] = "sb_ceruliumcompound"
end

function sb_swapOutputs(l,m,b)
	for i = 1, #weaponLevelKinds[l] do if weaponLevelKinds[l][i] == m then weaponLevelKinds[l][i] = b[1+i%2] end end
end