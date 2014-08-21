on run (argv)
	
	--	For Testing
	-- set argv to {"tstape-no", current date}
	
	set argCount to count of argv
	if ((argCount is less than 2 and argCount is greater than 2) or (item 1 of argv is "") or (item 2 of argv is "")) then
		return "Invalid Syntax: UpdateTextExpanderSnippet snippetAbbreviation newExpansion"
	end if
	
	--	Set our variables
	set snippetAbbreviation to item 1 of argv
	set newText to item 2 of argv
	
	tell application "TextExpander"
		if (not (exists group "LittleKnown")) then
			return "LittleKnown Group was not found!"
		end if
		set snips to snippets of group "LittleKnown"
		set mySnippet to ""
		repeat with aSnippet in snips
			if abbreviation of aSnippet is snippetAbbreviation then
				set mySnippet to aSnippet
				exit repeat
			end if
		end repeat
		log mySnippet
		
		if mySnippet is not equal to "" then
			set plain text expansion of mySnippet to newText as rich text
		end if
	end tell
	
end run