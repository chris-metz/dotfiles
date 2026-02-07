# Print an optspec for argparse to handle cmd's options that are independent of any subcommand.
function __fish_volta_global_optspecs
	string join \n verbose very-verbose quiet v/version h/help
end

function __fish_volta_needs_command
	# Figure out if the current invocation already has a command.
	set -l cmd (commandline -opc)
	set -e cmd[1]
	argparse -s (__fish_volta_global_optspecs) -- $cmd 2>/dev/null
	or return
	if set -q argv[1]
		# Also print the command, so this can be used to figure out what it is.
		echo $argv[1]
		return 1
	end
	return 0
end

function __fish_volta_using_subcommand
	set -l cmd (__fish_volta_needs_command)
	test -z "$cmd"
	and return 1
	contains -- $cmd[1] $argv
end

complete -c volta -n "__fish_volta_needs_command" -l verbose -d 'Enables verbose diagnostics'
complete -c volta -n "__fish_volta_needs_command" -l very-verbose -d 'Enables trace-level diagnostics'
complete -c volta -n "__fish_volta_needs_command" -l quiet -d 'Prevents unnecessary output'
complete -c volta -n "__fish_volta_needs_command" -s v -l version -d 'Prints the current version of Volta'
complete -c volta -n "__fish_volta_needs_command" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c volta -n "__fish_volta_needs_command" -f -a "fetch" -d 'Fetches a tool to the local machine'
complete -c volta -n "__fish_volta_needs_command" -f -a "install" -d 'Installs a tool in your toolchain'
complete -c volta -n "__fish_volta_needs_command" -f -a "uninstall" -d 'Uninstalls a tool from your toolchain'
complete -c volta -n "__fish_volta_needs_command" -f -a "pin" -d 'Pins your project\'s runtime or package manager'
complete -c volta -n "__fish_volta_needs_command" -f -a "list" -d 'Displays the current toolchain'
complete -c volta -n "__fish_volta_needs_command" -f -a "completions" -d 'Generates Volta completions'
complete -c volta -n "__fish_volta_needs_command" -f -a "which" -d 'Locates the actual binary that will be called by Volta'
complete -c volta -n "__fish_volta_needs_command" -f -a "use"
complete -c volta -n "__fish_volta_needs_command" -f -a "setup" -d 'Enables Volta for the current user / shell'
complete -c volta -n "__fish_volta_needs_command" -f -a "run" -d 'Run a command with custom Node, npm, pnpm, and/or Yarn versions'
complete -c volta -n "__fish_volta_needs_command" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c volta -n "__fish_volta_using_subcommand fetch" -l verbose -d 'Enables verbose diagnostics'
complete -c volta -n "__fish_volta_using_subcommand fetch" -l very-verbose -d 'Enables trace-level diagnostics'
complete -c volta -n "__fish_volta_using_subcommand fetch" -l quiet -d 'Prevents unnecessary output'
complete -c volta -n "__fish_volta_using_subcommand fetch" -s h -l help -d 'Print help'
complete -c volta -n "__fish_volta_using_subcommand install" -l verbose -d 'Enables verbose diagnostics'
complete -c volta -n "__fish_volta_using_subcommand install" -l very-verbose -d 'Enables trace-level diagnostics'
complete -c volta -n "__fish_volta_using_subcommand install" -l quiet -d 'Prevents unnecessary output'
complete -c volta -n "__fish_volta_using_subcommand install" -s h -l help -d 'Print help'
complete -c volta -n "__fish_volta_using_subcommand uninstall" -l verbose -d 'Enables verbose diagnostics'
complete -c volta -n "__fish_volta_using_subcommand uninstall" -l very-verbose -d 'Enables trace-level diagnostics'
complete -c volta -n "__fish_volta_using_subcommand uninstall" -l quiet -d 'Prevents unnecessary output'
complete -c volta -n "__fish_volta_using_subcommand uninstall" -s h -l help -d 'Print help'
complete -c volta -n "__fish_volta_using_subcommand pin" -l verbose -d 'Enables verbose diagnostics'
complete -c volta -n "__fish_volta_using_subcommand pin" -l very-verbose -d 'Enables trace-level diagnostics'
complete -c volta -n "__fish_volta_using_subcommand pin" -l quiet -d 'Prevents unnecessary output'
complete -c volta -n "__fish_volta_using_subcommand pin" -s h -l help -d 'Print help'
complete -c volta -n "__fish_volta_using_subcommand list" -l format -d 'Specify the output format' -r -f -a "{human\t'',plain\t''}"
complete -c volta -n "__fish_volta_using_subcommand list" -s c -l current -d 'Show the currently-active tool(s)'
complete -c volta -n "__fish_volta_using_subcommand list" -s d -l default -d 'Show your default tool(s)'
complete -c volta -n "__fish_volta_using_subcommand list" -l verbose -d 'Enables verbose diagnostics'
complete -c volta -n "__fish_volta_using_subcommand list" -l very-verbose -d 'Enables trace-level diagnostics'
complete -c volta -n "__fish_volta_using_subcommand list" -l quiet -d 'Prevents unnecessary output'
complete -c volta -n "__fish_volta_using_subcommand list" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c volta -n "__fish_volta_using_subcommand completions" -s o -l output -d 'File to write generated completions to' -r -F
complete -c volta -n "__fish_volta_using_subcommand completions" -s f -l force -d 'Write over an existing file, if any'
complete -c volta -n "__fish_volta_using_subcommand completions" -l verbose -d 'Enables verbose diagnostics'
complete -c volta -n "__fish_volta_using_subcommand completions" -l very-verbose -d 'Enables trace-level diagnostics'
complete -c volta -n "__fish_volta_using_subcommand completions" -l quiet -d 'Prevents unnecessary output'
complete -c volta -n "__fish_volta_using_subcommand completions" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c volta -n "__fish_volta_using_subcommand which" -l verbose -d 'Enables verbose diagnostics'
complete -c volta -n "__fish_volta_using_subcommand which" -l very-verbose -d 'Enables trace-level diagnostics'
complete -c volta -n "__fish_volta_using_subcommand which" -l quiet -d 'Prevents unnecessary output'
complete -c volta -n "__fish_volta_using_subcommand which" -s h -l help -d 'Print help'
complete -c volta -n "__fish_volta_using_subcommand use" -l verbose -d 'Enables verbose diagnostics'
complete -c volta -n "__fish_volta_using_subcommand use" -l very-verbose -d 'Enables trace-level diagnostics'
complete -c volta -n "__fish_volta_using_subcommand use" -l quiet -d 'Prevents unnecessary output'
complete -c volta -n "__fish_volta_using_subcommand use" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c volta -n "__fish_volta_using_subcommand setup" -l verbose -d 'Enables verbose diagnostics'
complete -c volta -n "__fish_volta_using_subcommand setup" -l very-verbose -d 'Enables trace-level diagnostics'
complete -c volta -n "__fish_volta_using_subcommand setup" -l quiet -d 'Prevents unnecessary output'
complete -c volta -n "__fish_volta_using_subcommand setup" -s h -l help -d 'Print help'
complete -c volta -n "__fish_volta_using_subcommand run" -l node -d 'Set the custom Node version' -r
complete -c volta -n "__fish_volta_using_subcommand run" -l npm -d 'Set the custom npm version' -r
complete -c volta -n "__fish_volta_using_subcommand run" -l pnpm -d 'Set the custon pnpm version' -r
complete -c volta -n "__fish_volta_using_subcommand run" -l yarn -d 'Set the custom Yarn version' -r
complete -c volta -n "__fish_volta_using_subcommand run" -l env -d 'Set an environment variable (can be used multiple times)' -r
complete -c volta -n "__fish_volta_using_subcommand run" -l bundled-npm -d 'Forces npm to be the version bundled with Node'
complete -c volta -n "__fish_volta_using_subcommand run" -l no-pnpm -d 'Disables pnpm'
complete -c volta -n "__fish_volta_using_subcommand run" -l no-yarn -d 'Disables Yarn'
complete -c volta -n "__fish_volta_using_subcommand run" -l verbose -d 'Enables verbose diagnostics'
complete -c volta -n "__fish_volta_using_subcommand run" -l very-verbose -d 'Enables trace-level diagnostics'
complete -c volta -n "__fish_volta_using_subcommand run" -l quiet -d 'Prevents unnecessary output'
complete -c volta -n "__fish_volta_using_subcommand run" -s h -l help -d 'Print help'
complete -c volta -n "__fish_volta_using_subcommand help; and not __fish_seen_subcommand_from fetch install uninstall pin list completions which use setup run help" -f -a "fetch" -d 'Fetches a tool to the local machine'
complete -c volta -n "__fish_volta_using_subcommand help; and not __fish_seen_subcommand_from fetch install uninstall pin list completions which use setup run help" -f -a "install" -d 'Installs a tool in your toolchain'
complete -c volta -n "__fish_volta_using_subcommand help; and not __fish_seen_subcommand_from fetch install uninstall pin list completions which use setup run help" -f -a "uninstall" -d 'Uninstalls a tool from your toolchain'
complete -c volta -n "__fish_volta_using_subcommand help; and not __fish_seen_subcommand_from fetch install uninstall pin list completions which use setup run help" -f -a "pin" -d 'Pins your project\'s runtime or package manager'
complete -c volta -n "__fish_volta_using_subcommand help; and not __fish_seen_subcommand_from fetch install uninstall pin list completions which use setup run help" -f -a "list" -d 'Displays the current toolchain'
complete -c volta -n "__fish_volta_using_subcommand help; and not __fish_seen_subcommand_from fetch install uninstall pin list completions which use setup run help" -f -a "completions" -d 'Generates Volta completions'
complete -c volta -n "__fish_volta_using_subcommand help; and not __fish_seen_subcommand_from fetch install uninstall pin list completions which use setup run help" -f -a "which" -d 'Locates the actual binary that will be called by Volta'
complete -c volta -n "__fish_volta_using_subcommand help; and not __fish_seen_subcommand_from fetch install uninstall pin list completions which use setup run help" -f -a "use"
complete -c volta -n "__fish_volta_using_subcommand help; and not __fish_seen_subcommand_from fetch install uninstall pin list completions which use setup run help" -f -a "setup" -d 'Enables Volta for the current user / shell'
complete -c volta -n "__fish_volta_using_subcommand help; and not __fish_seen_subcommand_from fetch install uninstall pin list completions which use setup run help" -f -a "run" -d 'Run a command with custom Node, npm, pnpm, and/or Yarn versions'
complete -c volta -n "__fish_volta_using_subcommand help; and not __fish_seen_subcommand_from fetch install uninstall pin list completions which use setup run help" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
