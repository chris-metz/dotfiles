-- https://www.youtube.com/watch?v=FmHhonPjvvA
return {
  "L3MON4D3/LuaSnip",
  config = function()
    local ls = require("luasnip")
    local s = ls.snippet
    local t = ls.text_node
    local i = ls.insert_node

    ls.add_snippets("all", {
      s("hw", { t("Hello, world!") }),
    })

    ls.add_snippets("go", {
      s("pl", {
        t("fmt.Println("),
        i(1),
        t(")"),
      }),
    })
  end,
}
