local compareFns = {
	['=='] = (function(a,b) return a == b end),
	['!='] = (function(a,b) return a ~= b end),
	['>'] = (function(a,b) return a > b end),
	['>='] = (function(a,b) return a >= b end),
	['<'] = (function(a,b) return a < b end),
	['<='] = (function(a,b) return a <= b end)
}

local COMPARE_FINDER_PATTERN = '.([%=%!%<%>]%=?).'

local numberCompares = {}
for _, comp in pairs({
	'>', '>=', '<', '<='
}) do numberCompares[comp] = true end

return function(ci) 

	local IF_PATTERN = '^%s*if'
	local FI_PATTERN = '^%s*fi%s*$'
	local function skipToFi()
		local cl = currentLine
		local pendingIfs = 1 --set to 1 because in the beginning we already have one pending if
		while(true) do 
			cl = cl + 1
			local curString = currentScript[cl] or ''
			if(
				curString:find(IF_PATTERN) --we found an 'if' statement
			) then
				pendingIfs = pendingIfs + 1
			elseif(cl == #currentScript) then --at the end of the script...
				ci.jumpToLine(cl)
				break
			elseif(curString:find(FI_PATTERN)) then --found fi
				pendingIfs = pendingIfs - 1
				if(pendingIfs <= 0) then 
					ci.jumpToLine(cl)
					break
				end
			end
		end
	end

	local cmds = {}
	
	cmds['if'] = (function(args)
		if(args) then 
			local compStart, compEnd, compare = args:find(COMPARE_FINDER_PATTERN)
			local varname
			local value
			if(compare) then
				varname = args:sub(1, compStart - 1)
				value = args:sub(compEnd + 1)
			end
			
			if(varname and compare and value) then
				do
					local valuean = tonumber(value) --value as number
					if(valuean) then
						value = valuean
					else
						valuean = nil
						local _, _, valuenq = string.find(value, STRING_PATTERN)
						--valuenq = value no quotation (marks)
						if(valuenq) then 
							value = valuenq 
						end
					end
				end
				
				local var = variableHandler.variables[varname] or 0
				
				if(numberCompares[compare]) then 
					if(
						(type(var) ~= 'number') or
						(type(value) ~= 'number')
					) then
						--false
						skipToFi()
						return
					end
				end
				
				local compareResult = compareFns[compare](var, value)
				
				print(
					'[scriptHandler/if] ' .. 
					var .. compare .. value ..
					' = ' .. ((compareResult and 'true') or 'false')
				)
				
				if(not compareResult) then
					skipToFi()
					return
				end
			end
		end
		--print('[scriptHandler/if] true')
	end)
	
	cmds['fi'] = emptyfn
	
	return cmds
end