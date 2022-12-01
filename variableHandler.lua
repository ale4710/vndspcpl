local interface = {}

local variables = {}
interface.variables = variables

local globalVariables = {}
interface.global = {}
interface.global.variables = globalVariables
function interface.global.load(vartable)
	globalVariables = vartable
	interface.global.variables = vartable
	copyGlobals()
end
function interface.global.flush(callback)
	saveFileManager.saveGlobal(
		globalVariables,
		callback
	)
end

function copyGlobals()
	table.shallowCopy(
		globalVariables,
		variables
	)
end
interface.copyGlobals = copyGlobals

function interface.reset() 
	for key in pairs(variables) do 
		variables[key] = nil
	end
	
	copyGlobals()
end

local convertVariables
do
	local tempVariableTable
	local VARIABLE_WRAPPED = '{%$([^}]+)}'
	local VARIABLE_UNWRAPPED = '%$([^$ ]+)'
	local REPLACER_PRIVATE_CHARACTER = utf8.char(0xe573)
	
	local function dolToPriv(str)
		return str:gsub('%$%$', REPLACER_PRIVATE_CHARACTER) -- $$ -> REPLACER_PRIVATE_CHARACTER
	end
	
	local function getVariable(var)
		local varTable = tempVariableTable or variables
		return varTable[var] or 0
	end
	
	convertVariables = function(str, varTableOverride)
		tempVariableTable = varTableOverride
		varTableOverride = nil

		str = dolToPriv(str)
		str = str:gsub(VARIABLE_WRAPPED, getVariable)
		str = dolToPriv(str)
		str = str:gsub(VARIABLE_UNWRAPPED, getVariable)
		str = dolToPriv(str)
		str = str:gsub(REPLACER_PRIVATE_CHARACTER, '$')
		
		tempVariableTable = nil
		
		return str
	end
end
interface.convertVariables = convertVariables

return interface