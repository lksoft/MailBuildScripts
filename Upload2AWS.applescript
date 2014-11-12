on run (argv)
	
	--	For Testing
	--	set argv to {"/Users/scott/Downloads/sampleHeader.h", "sis", "yes"}
	
	set argCount to count of argv
	if ((argCount is less than 2 and argCount is greater than 3) or (item 1 of argv is "") or (item 2 of argv is "")) then
		return "Invalid Syntax: Upload2AWS fullFilePath productCode [yes]"
	end if
	
	--	Set our variables
	set fileToSend to item 1 of argv
	set destination to "/media.littleknownsoftware.com/" & item 2 of argv
	set shouldClose to true
	
	--	See if we should keep the browser open
	if (((count of argv) is 3) and (item 3 of argv is "yes")) then
		set shouldClose to false
	end if
	
	--	Validate the file path
	try
		set test to POSIX file fileToSend as alias
	on error err
		return "The file path provided [" & fileToSend & "] doesn't exist!"
	end try
	
	tell application "Transmit"
		
		--	Ensure that we have the favorite we expect
		if ((count of (favorites whose name is "AWS")) is less than 1) then
			return "Transmit favorite for AWS was not found!"
		end if
		
		set myFav to item 1 of (favorites whose name is "AWS")
		set myNewDoc to make new document
		tell current tab of myNewDoc
			
			--	If there is a remote browser open, ensure that it is the AWS one
			set aRemote to remote browser
			if ((aRemote is not missing value) and (address of aRemote is not address of myFav)) then
				--	Otherwise close it
				close remote browser
				set aRemote to missing value
			end if
			
			--	Figure out if we need to open a browser now
			if (aRemote is missing value) then
				connect to myFav
			end if
			
			--	Do the upload, after deleting any current file
			set ATID to AppleScript's text item delimiters
			set AppleScript's text item delimiters to "/"
			set fileName to last text item of fileToSend
			set AppleScript's text item delimiters to ATID
			tell remote browser
				with timeout of 180 seconds
					delete item at path destination & "/" & fileName
					upload item at path fileToSend to destination
				end timeout
			end tell
			
			--	Close the connection and the document
			close remote browser
			close myNewDoc
			
		end tell
		
	end tell
	
end run
