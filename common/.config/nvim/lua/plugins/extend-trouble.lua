return {
  "folke/trouble.nvim",
  opts = {
    modes = {
      symbols = {
        filter = {
          ["not"] = {
            ft = { "javascript" },
            kind = {
              -- "Class",
              -- "Constructor",
              -- "Enum",
              -- "Field",
              -- "Function",
              -- "Interface",
              -- "Method",
              -- "Module",
              -- "Namespace",
              -- "Package",
              "Property",
              -- "Struct",
              -- "Trait",
            },
          },
        },
        win = {
          position = "right",
          size = {
            width = 50,
            height = 10,
          },
        },
      },
    },
  },
}
