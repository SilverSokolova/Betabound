local ini = init
function init() ini() root.materialPath=function(a) return root.materialConfig(a) and root.materialConfig(a).path end end