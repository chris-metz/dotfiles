return {
  {
    "conform.nvim",
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      if LazyVim.has_extra("formatting.prettier") then
        opts.formatters_by_ft.gohtml = { "prettier" }
      end
      -- opts.formatters_by_ft.sql = { "sqlfmt" }
      opts.formatters.sqlfluff = {
        args = { "format", "--dialect=ansi", "-" },
      }
      opts.formatters_by_ft.sql = { "sqlfluff" }
    end,
  },
}
