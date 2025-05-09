return {
	-- Vue 3
	init_options = {
		vue = {
			-- disable hybrid mode
			hybridMode = false,
		},
	},
	settings = {
		typescript = {
			inlayHints = {
				enumMemberValues = {
					enable = true,
				},
				functionLikeReturnTypes = {
					enable = true,
				},
				propertyDeclarationTypes = {
					enable = true,
				},
				parameterTypes = {
					enabled = true,
					suppressWhenArgumentMatchesName = true,
				},
				variableTypes = {
					enabled = true,
				},
			},
		},
	},
}
