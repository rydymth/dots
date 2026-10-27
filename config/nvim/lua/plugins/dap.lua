return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "rcarriga/nvim-dap-ui",
    "nvim-neotest/nvim-nio",
    "theHamsta/nvim-dap-virtual-text",
  },
  keys = {
    { "<F5>",       function() require("dap").continue() end,          desc = "Debug: start/continue" },
    { "<F10>",      function() require("dap").step_over() end,         desc = "Debug: step over" },
    { "<F11>",      function() require("dap").step_into() end,         desc = "Debug: step into" },
    { "<F12>",      function() require("dap").step_out() end,          desc = "Debug: step out" },
    { "<leader>b",  function() require("dap").toggle_breakpoint() end, desc = "Toggle breakpoint" },
    { "<leader>du", function() require("dapui").toggle() end,          desc = "Debug UI" },
  },
  config = function()
    local dap, dapui = require("dap"), require("dapui")
    dapui.setup()
    require("nvim-dap-virtual-text").setup()

    dap.adapters.coreclr = {
      type = "executable",
      command = vim.fn.stdpath("data") .. "/mason/bin/netcoredbg",
      args = { "--interpreter=vscode" },
    }

    dap.configurations.cs = {
      {
        type = "coreclr",
        name = "Launch .dll",
        request = "launch",
        program = function()
          return vim.fn.input("Path to dll: ", vim.fn.getcwd() .. "/bin/Debug/", "file")
        end,
      },
    }

    dap.listeners.after.event_initialized["dapui"] = function() dapui.open() end
    dap.listeners.before.event_terminated["dapui"] = function() dapui.close() end
    dap.listeners.before.event_exited["dapui"] = function() dapui.close() end
  end,
}
