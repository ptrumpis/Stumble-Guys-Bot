; Quit Bot with ESC key
HotKeySet("{F10}", "_Terminate")

; Game Title
Global $title = "Stumble Guys"

_Main()
Func _Main()
	; Change AutoIt defaults
	Opt("MouseCoordMode", 0)
	Opt("PixelCoordMode", 0)
	Opt("SendKeyDownDelay", 25)

	; Detect if game window is present and has focus
	WinWaitActive($title)

	; Get window handle
	$hWnd = WinGetHandle($title)

	$centerX = 1920/2;
	$centerY = 1080/2;
	
	; (main loop)
	While 1
		
		If DetectGameLost($hWnd) = 1 Then
			; Leave game on loss
			LeaveGame()
			Sleep(1000)
		EndIf
		
		; Skip the stumble pass/journey level up screens
		If DetectStumblePassLevelUp($hWnd) = 1 Or DetectStumbleJourneyLevelUp($hWnd) = 1 Then
			ClickContinue()	
		EndIf

		; Skip the item received screen
		If DetectItemReceived($hWnd) = 1 Then
			ClickOK()	
		EndIf
		
		; Start new game
		If DetectMainMenu($hWnd) = 1 Or DetectEventMenu($hWnd) = 1 Then
			If DetectEventAvailable($hWnd) = 1 Then
				ClickEventMenu()
				Sleep(1000)
				ContinueLoop
			ElseIf DetectEventMenu($hWnd) = 1 Then
				ClickPlayEvent()
			Else
				ClickPlayGame()
			EndIf

			Sleep(1000)

			; screen transition
			Sleep(500)

			; center mouse
			_MouseMove(Random($centerX-5, $centerX+5), Random($centerY, $centerY+10));

			; screen transition
			Sleep(500)

			; There is a 3 second in game counter at the start of each round
			Sleep(3000)
		EndIf

		; Fault tolerant approach
		If DetectGameLost($hWnd) = 1 Then
			; Leave game on loss
			LeaveGame()
			Sleep(1000)
		ElseIf DetectGetReward($hWnd) = 1 Then
			; Claim participation reward
			ClickGetReward()
			Sleep(1000)
		ElseIf DetectGetStumbleJourneyReward($hWnd) = 1 Then
			; Claim stumble journey reward (click anywhere on the screen)
			ClickGetReward()
			Sleep(1000)
		ElseIf DetectGameResults($hWnd) = 1 Then
			; Round has finished, results are shown
			; Must wait till screen goes away
			Sleep(1000)
		ElseIf DetectGameRunning($hWnd) = 1 Then
			; Game is still on-going
			; Warning: This condition will also be true for spectator mode on game loss (check loss first)
			; AFK gameplay happens here
			SimulateGamePlay($hWnd)
		Else
			Sleep(1000)
		EndIf

		; Game window must be active to continue
		While WinActive($title) = 0
			If WinExists($title) = 0 Then
				_Terminate()
			EndIf

			Sleep(5000)
		WEnd
	WEnd
EndFunc

Func SimulateGamePlay(ByRef $hWnd)
	Local $n = 4
	Local $keys[$n] = ["Left", "Right", "Jump", "Run"]

	For $counter = 1 to $n
		If DetectGameRunning($hWnd) = 0 Or DetectGameLost($hWnd) = 1 Then
			; Abort input on game loss to avoid waste of time
			Return
		EndIf

		; Start running
		_Send("{w down}")
		_Sleep(500, 1500)

		; Select random movement
		$key = Random(0, $n-1)
		Switch $keys[$key]
			Case "Left"
				$ms = Random(500, 1500)
				Left($ms)
			Case "Right"
				$ms = Random(500, 1500)
				Right($ms)
			Case "Jump"
				$ms = Random(100, 500)
				Jump($ms)
				_Sleep(500, 1000)
			Case "Run"
				_Sleep(500, 1500)
		EndSwitch

		; Stop running
		_Sleep(0, 1000)
		_Send("{w up}")

		; Short pause
		_Sleep(500, 1000)
	Next
EndFunc

Func Left($ms = 500)
	_Send("{a down}")
	Sleep($ms)
	_Send("{a up}")
EndFunc

Func Right($ms = 500)
	_Send("{d down}")
	Sleep($ms)
	_Send("{d up}")
EndFunc

Func Jump($ms = 500)
	_Send("{SPACE down}")
	Sleep($ms)
	_Send("{SPACE up}")
EndFunc

Func ClickPlayGame()
	$x = Random(1538, 1873)
	$y = Random(921, 1026)
	_LeftClick($x, $y)
EndFunc

Func ClickEventMenu()
	$x = Random(1053, 1465)
	$y = Random(948, 1033)
	_LeftClick($x, $y)
EndFunc

Func ClickPlayEvent()
	$x = Random(200, 440)
	$y = Random(915, 980)
	_LeftClick($x, $y)
EndFunc

Func ClickContinue()
	$x = Random(480, 520)
	$y = Random(930, 970)
	_LeftClick($x, $y)
EndFunc

Func ClickOK()
	$x = Random(1605, 1645)
	$y = Random(900, 940)
	_LeftClick($x, $y)
EndFunc

Func DetectMainMenu(ByRef $hWnd)
	; (Yellow Play Button)
	$c1 = PixelGetColor(1873, 921, $hWnd)
	$hex = Hex($c1, 6)
	If $hex = "FFC716" Then Return 1

	; (Yellow Play Button) 2nd check
	$c2 = PixelGetColor(1538, 1026, $hWnd)
	$hex = Hex($c2, 6)
	If $hex = "FFBA10" Then Return 1

	Return 0
EndFunc

Func DetectEventAvailable(ByRef $hWnd)
	; (Event Button)
	$c1 = PixelGetColor(1050, 943, $hWnd)
	$hex = Hex($c1, 6)
	If $hex = "07406F" Then Return 1

	; (Event Button) 2nd check
	$c2 = PixelGetColor(1225, 949, $hWnd)
	$hex = Hex($c2, 6)
	If $hex = "07406F" Then Return 1

	Return 0
EndFunc

Func DetectEventMenu(ByRef $hWnd)
	; (Start Button)
	$c1 = PixelGetColor(200, 915, $hWnd)
	$hex = Hex($c1, 6)
	If $hex = "0D89EC" Then Return 1

	; (Start Button) 2nd check
	$c2 = PixelGetColor(440, 980, $hWnd)
	$hex = Hex($c2, 6)
	If $hex = "0B6EE7" Then Return 1

	Return 0
EndFunc

Func DetectStumbleJourneyLevelUp(ByRef $hWnd)
	; (White in Level Up Banner)
	$c1 = PixelGetColor(770, 149, $hWnd)
	$hex = Hex($c1, 6)
	
	; (White in Level Up Banner)
	$c2 = PixelGetColor(1140, 164, $hWnd)
	$hex2 = Hex($c2, 6)
	
	; (Black in Level Up Banner)
	$c3 = PixelGetColor(1028, 155, $hWnd)
	$hex3 = Hex($c3, 6)
	
	; (Blue in Progress Bar)
	$c4 = PixelGetColor(664, 821, $hWnd)
	$hex4 = Hex($c4, 6)
	
	; (White in Tap To Continue Text)
	$c5 = PixelGetColor(781, 975, $hWnd)
	$hex5 = Hex($c5, 6)
	
	; All of them should match
	If $hex = "FFFFFF" And  $hex2 = "FFFFFF" And $hex3 = "000000" And $hex4 = "00DBFA" And $hex5 = "FFFFFF" Then Return 1

	Return 0
EndFunc

Func DetectStumblePassLevelUp(ByRef $hWnd)
	; (Blue Continue Button)
	$c1 = PixelGetColor(510, 948, $hWnd)
	$hex = Hex($c1, 6)
	
	; (White in Banner)
	$c2 = PixelGetColor(636, 69, $hWnd)
	$hex2 = Hex($c2, 6)
	
	; (White in Banner)
	$c3 = PixelGetColor(1279, 70, $hWnd)
	$hex3 = Hex($c3, 6)
	
	; All of them should match
	If $hex = "0D89EC" And  $hex2 = "FFFFFF" And $hex3 = "FFFFFF" Then Return 1

	Return 0
EndFunc

Func DetectItemReceived(ByRef $hWnd)
	; (White Received Text)
	$c1 = PixelGetColor(929, 422, $hWnd)
	$hex = Hex($c1, 6)
	
	; (Purple Background)
	$c2 = PixelGetColor(1040, 385, $hWnd)
	$hex2 = Hex($c2, 6)
	
	; (Green Equip Now Button)
	$c3 = PixelGetColor(610, 922, $hWnd)
	$hex3 = Hex($c3, 6)
	
	; (Blue OK Button)
	$c4 = PixelGetColor(1601, 915, $hWnd)
	$hex4 = Hex($c4, 6)
	
	; All of them should match
	If $hex = "FFFFFF" And  $hex2 = "7E1CB8" And $hex3 = "55DB1E" And $hex4 = "0D88EC" Then Return 1

	Return 0
EndFunc

Func DetectGameRunning(ByRef $hWnd)
	; (White Player Arrow) FFFFFF
	$c1 = PixelGetColor(959, 450, $hWnd)
	$hex1 = Hex($c1, 6)
	
	; (White Player Arrow) FFFFFF
	$c2 = PixelGetColor(961, 448, $hWnd)
	$hex2 = Hex($c2, 6)

	; Both of them should match
	If $hex1 = "FFFFFF" And $hex2 = "FFFFFF" Then Return 1
EndFunc

Func DetectGameResults(ByRef $hWnd)
	; (Purple border of flying screen thing) 840BE9
	$c1 = PixelGetColor(673, 133, $hWnd)
	$hex = Hex($c1, 6)
	If $hex = "840BE9" Then Return 1
	
	; (Purple border of flying screen thing) EC43A7
	$c2 = PixelGetColor(678, 167, $hWnd)
	$hex = Hex($c2, 6)
	If $hex = "EC43A7" Then Return 1

	Return 0
EndFunc

Func DetectGameLost(ByRef $hWnd)
	; (Red Leave Button) 
	$c1 = PixelGetColor(228, 969, $hWnd)
	$hex = Hex($c1, 6)
	
	; (Red Leave Button)
	$c2 = PixelGetColor(29, 994, $hWnd)
	$hex2 = Hex($c2, 6)
	
	; (White Text in Leave Button)
	$c3 = PixelGetColor(196, 1001, $hWnd)
	$hex3 = Hex($c3, 6)
	
	If $hex = "F7513F" And $hex2 = "F44C39" And $hex3 = "FFFFFF" Then Return 1
	
	Return 0
EndFunc

Func LeaveGame()
	_Send("{ESC}")
EndFunc

Func DetectGetStumbleJourneyReward(ByRef $hWnd)
	; (White Congratulations Banner)
	$c1 = PixelGetColor(611, 43, $hWnd)
	$hex = Hex($c1, 6)
	
	; (White Congratulations Banner)
	$c2 = PixelGetColor(1276, 50, $hWnd)
	$hex2 = Hex($c2, 6)
	
	; (Black Text in Congratulations Banner)
	$c3 = PixelGetColor(667, 71, $hWnd)
	$hex3 = Hex($c3, 6)
	
	; (Yellow Rewards Banner)
	$c4 = PixelGetColor(947, 130, $hWnd)
	$hex4 = Hex($c4, 6)
	
	; (White Tap To Continue Text)
	$c5 = PixelGetColor(809, 958, $hWnd)
	$hex5 = Hex($c5, 6)
	
	; (Purple Background)
	$c6 = PixelGetColor(946, 1004, $hWnd)
	$hex6 = Hex($c6, 6)
	
	If $hex = "FFFFFF" And $hex2 = "FFFFFF" And $hex3 = "333333" And $hex4 = "FFC800" And $hex5 = "FFFFFF" And $hex6 = "251852" Then Return 1

	Return 0
EndFunc

Func DetectGetReward(ByRef $hWnd)
	; (Green Get Button)
	$c1 = PixelGetColor(1499, 915, $hWnd)
	$hex = Hex($c1, 6)
	If $hex = "55DB1E" Then Return 1

	; (Green Get Button)
	$c2 = PixelGetColor(1809, 1001, $hWnd)
	$hex = Hex($c2, 6)
	If $hex = "44D018" Then Return 1

	Return 0
EndFunc

Func ClickGetReward()
	$x = Random(1499, 1809)
	$y = Random(915, 1001)
	_LeftClick($x, $y)
EndFunc

Func _Sleep($min, $max)
	Sleep(Random($min, $max))
EndFunc

Func _Send($keys, $flag = 0)
	; Send key input to game only
	If WinActive($title) = 0 Then Return

	Send($keys, $flag)
EndFunc

Func _LeftClick($x, $y)
	; Send clicks to game only
	If WinActive($title) = 0 Then Return

	MouseClick("left", $x, $y, 1, 10)
	Sleep(100)
EndFunc

Func _MouseMove($x, $y, $speed = 20)
	If WinActive($title) = 0 Then Return
		
	MouseMove($x, $y, $speed)
	Sleep(50)
EndFunc

Func _MouseMoveRandom($minSpeed = 20, $maxSpeed = 30)
	If WinActive($title) = 0 Then Return

	; Try to avoid outer borders
	$x = Random(220, 1700)
	$y = Random(180, 900)

	$speed = Random($minSpeed, $maxSpeed)

	MouseMove($x, $y, $speed)
	Sleep(100)
EndFunc

Func _MouseMoveEvent($x = "", $y = "")
	Local $MOUSEEVENTF_MOVE = 0x1

    DllCall("user32.dll", "none", "mouse_event", _
		"long",  $MOUSEEVENTF_MOVE, _
		"long",  $x, _
		"long",  $y, _
		"long",  0, _
		"long",  0)
EndFunc

Func _Terminate()
	Exit
EndFunc
