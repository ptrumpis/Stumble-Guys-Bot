; Quit Bot with ESC key
HotKeySet("{ESC}", "_Terminate")

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
			
			; not necessary but helps to determine current state
			While DetectGameSearch($hWnd) = 1
				; fake human behavior
				If Random(0, 2) = 1 Then _MouseMoveRandom()

				_Sleep(500, 1000)
			WEnd

			; screen transition
			Sleep(500)

			; not necessary but helps to determine current state
			While DetectMapSelection($hWnd) = 1
				; fake human behavior
				If Random(0, 2) = 1 Then _Send("{SPACE}")
				If Random(0, 2) = 1 Then _MouseMoveRandom()

				_Sleep(500, 1000)
			WEnd

			; center mouse
			_MouseMove(Random($centerX-5, $centerX+5), Random($centerY, $centerY+10));

			; screen transition
			Sleep(500)

			; not necessary but helps to determine current state
			While DetectGameStart($hWnd) = 1
				Sleep(500)
			WEnd

			; There is a 3 second in game counter at the start of each round
			Sleep(3000)
		EndIf

		; Fault tolerant approach
		If DetectGameLost($hWnd) = 1 Then
			; Leave game on loss
			ClickLeaveGame()
			Sleep(1000)
		ElseIf DetectGetReward($hWnd) = 1 Then
			; Claim participation reward
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

Func DetectGameSearch(ByRef $hWnd)
	; (Gray Abort Button) 89A8B3
	$c1 = PixelGetColor(333, 964, $hWnd)
	$hex = Hex($c1, 6)
	If $hex = "89A8B3" Then Return 1

	; (Gray Abort Button) 7393A0
	$c2 = PixelGetColor(65, 1022, $hWnd)
	$hex = Hex($c2, 6)
	If $hex = "7393A0" Then Return 1

	Return 0
EndFunc

Func DetectMapSelection(ByRef $hWnd)
	; (Purple Left Bottom) 9286FF
	$c1 = PixelGetColor(99, 988, $hWnd)
	$hex1 = Hex($c1, 6)

	; (Purple Right Bottom) 6878FF
	$c2 = PixelGetColor(1798, 991, $hWnd)
	$hex2 = Hex($c2, 6)

	; Both of them should match
	If $hex1 = "9286FF" And $hex2 = "6878FF" Then Return 1

	Return 0
EndFunc

Func DetectGameStart(ByRef $hWnd)
	; (White Screen Banner) FFFFFF
	$c1 = PixelGetColor(672, 72, $hWnd)
	$hex1 = Hex($c1, 6)
	
	; (White Screen Banner) FFFFFF
	$c2 = PixelGetColor(1250, 52, $hWnd)
	$hex2 = Hex($c2, 6)

	; Both of them should match
	If $hex1 = "FFFFFF" And $hex2 = "FFFFFF" Then Return 1

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
	; (Red Leave Button) F7513F
	$c1 = PixelGetColor(257, 973, $hWnd)
	$hex = Hex($c1, 6)
	If $hex = "F7513F" Then Return 1

	; (Red Leave Button)F44131
	$c2 = PixelGetColor(36, 1033, $hWnd)
	$hex = Hex($c2, 6)
	If $hex = "F44131" Then Return 1

	Return 0
EndFunc

Func ClickLeaveGame()
	$x = Random(36, 257)
	$y = Random(973, 1033)
	_LeftClick($x, $y)
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
