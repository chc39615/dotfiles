local M = {}

function M.diagnostics()
	if vim.diagnostic.is_enabled then
		enabled = vim.diagnostic.is_enabled()
	end
	enabled = not enabled

	if enabled then
		vim.diagnostic.enable()
		Myutil.info("Enabled diagnostics", { title = "Diagnostics" })
	else
		vim.diagnostic.enable(false)
		Myutil.warn("Disabled diagnostics", { title = "Diagnostics" })
	end
end

function M.option(option, silent, values)
	if values then
		if vim.opt_local[option]:get() == values[1] then
			vim.opt_local[option] = values[2]
		else
			vim.opt_local[option] = values[1]
		end
		return Myutil.info("Set " .. option .. " to " .. vim.opt_local[option]:get(), { title = "Option" })
	end

	vim.opt_local[option] = not vim.opt_local[option]:get()
	if not silent then
		if vim.opt_local[option]:get() then
			Myutil.info("Enabled " .. option, { title = "Option" })
		else
			Myutil.info("Disabled " .. option, { title = "Option" })
		end
	end
end

setmetatable(M, {
	__call = function(m, ...)
		return m.option(...)
	end,
})

return M
