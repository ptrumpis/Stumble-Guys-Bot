; Quit Bot with F10 key
HotKeySet("{F10}", "_Terminate")

; Game Title
Global $title = "Stumble Guys"

; Window Handle
Global $hWnd = 0

; Window Properties
Global $baseWidth = 1920
Global $baseHeight = 1080

; Mouse Centering
Global $centerX = Round($baseWidth/2)
Global $centerY = Round($baseHeight/2)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Main loop

_Main()
Func _Main()
	; Change AutoIt defaults
	Opt("MouseCoordMode", 0)
	Opt("PixelCoordMode", 0)
	Opt("SendKeyDownDelay", 25)

	; Detect if game window is present and has focus
	Debug("Waiting until game gets active focus")
	WinWaitActive($title)

	; Get window handle
	$hWnd = WinGetHandle($title)

	; (main menu loop)
	While 1
		HandleAdvert()
		HandleLevelUp()
		HandleItemReceived()

		If DetectMainMenu() = 1 Then
			Debug("Detect: Main Menu")

			HandleMissionRewards()

			; Start new game
			ClickPlayGame()
			_Sleep(1000)

			HandleGameLoad()
		EndIf

		GamePlayLoop()

		; Game window must be active to continue
		While WinActive($title) = 0
			Debug("Window Lost Focus")

			If WinExists($title) = 0 Then
				Debug("Window Closed")
				Exit
			EndIf

			Sleep(5000)
		WEnd
	WEnd
EndFunc

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Game Play Loop

Func GamePlayLoop()
	Debug("Enter Gameplay Loop")

	While 1
		HandleAdvert()
		HandleLevelUp()
		HandleItemReceived()

		; Fault tolerant approach
		If DetectGameLost() = 1 Then
			; Leave game on loss
			Debug("Detect: Game Lost")
			LeaveGame()
			_Sleep(1000)
		ElseIf DetectGetReward() = 1 Then
			; Claim participation reward
			Debug("Detect: Get Reward")
			ClickGetReward()
			_Sleep(1000)
		ElseIf DetectGetStumbleJourneyReward() = 1 Then
			; Claim stumble journey reward (click anywhere on the screen)
			Debug("Detect: Journey Reward")
			ClickGetReward()
			_Sleep(1000)
		ElseIf DetectGameResults() = 1 Then
			; Round has finished, results are shown
			; Must wait till screen goes away
			Debug("Detect: Game Results")
			_Sleep(1000)
		ElseIf DetectGameRunning() = 1 Then
			Debug("Detect: Game Running")
			; Game is still on-going
			; Warning: This condition will also be true for spectator mode on game loss (check loss first)
			; AFK gameplay happens here
			SimulateGamePlay()
		Else
			ExitLoop
		EndIf

		If WinActive($title) = 0 Then
			Debug("Window Inactive")
			ExitLoop
		EndIf
	WEnd

	Debug("Exit Gameplay Loop")

EndFunc

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Sub Routines

Func HandleAdvert()
	; Skip the advert
	If DetectAdvert() = 1 Then
		Debug("Detect: Advert")
		ClickAdvertClose()
		_Sleep(500, 1000)
	EndIf
EndFunc

Func HandleLevelUp()
	; Skip the stumble pass/journey level up screens
	If DetectStumblePassLevelUp() = 1 Or DetectStumbleJourneyLevelUp() = 1 Then
		Debug("Detect: Level Up")
		ClickContinue()
		_Sleep(500, 1000)
	EndIf
EndFunc

Func HandleItemReceived()
	; Skip the item received screen
	If DetectItemReceived() = 1 Then
		Debug("Detect: Item Received")
		ClickOK()
		_Sleep(500, 1000)
	EndIf
EndFunc

Func HandleMissionRewards()
	; Collect pending mission rewards
	If DetectMainMenuMissionComplete() = 1 Then
		Debug("Detect: Mission Complete")
		ClickMissions()
		_Sleep(1000)

		While DetectMissionReward() = 1
			Debug("Detect: Mission Reward")
			CollectMissionReward()
			_Sleep(1000)
		WEnd

		GoBack()
		_Sleep(1000)
	EndIf
EndFunc

Func HandleGameLoad()
	; not necessary but helps to determine current state
	While DetectGameSearch() = 1
		Debug("Detect: Game Search")
		If Random(0, 2) = 1 Then MouseRandom()
		_Sleep(1000, 2000)
	WEnd

	HandleScreenTransition()

	; not necessary but helps to determine current state
	While DetectMapSelection() = 1
		Debug("Detect: Map Selection")
		If Random(0, 2) = 1 Then MouseRandom()
		_Sleep(1000, 2000)
	WEnd

	; center mouse
	Mouse(Random($centerX-5, $centerX+5), Random($centerY, $centerY+10));

	HandleScreenTransition()

	; not necessary but helps to determine current state
	While DetectGameStart() = 1
		Debug("Detect: Game Start")
		_Sleep(500)
	WEnd

	; There is a 3 second in game counter at the start of each round
	Debug("Waiting for Countdown")
	_Sleep(3000)
	Debug("Game Ready")
EndFunc

Func HandleScreenTransition()
	While DetectScreenTransition() = 1
		_Sleep(300, 600)
	WEnd
EndFunc

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Detection functions

Func DetectMainMenu()
	; (Yellow Play Button)
	If IsHexColorInRange(Pixel(1871, 930), "FFC716", 10) Or IsHexColorInRange(Pixel(1941, 1026), "FFBA10", 10) Then Return 1

	Return 0
EndFunc

Func DetectMainMenuMissionComplete()
	; (Red Number Badge)
	If IsHexColorInRange(Pixel(1867, 152), "FF4B4B", 10) Or IsHexColorInRange(Pixel(1893, 181), "FF4B4B", 10) Then Return 1

	Return 0
EndFunc

Func DetectMissionReward()
	; (Full Progress Bar)
	If IsHexColorInRange(Pixel(787, 861), "FFFF94", 10) Or IsHexColorInRange(Pixel(1542, 860), "FFFF94", 10) Then Return 1

	Return 0
EndFunc

Func DetectStumbleJourneyLevelUp()
	; (White in Level Up Banner)
	Local $match1 = IsHexColorInRange(Pixel(770, 149), "FFFFFF", 10)

	; (White in Level Up Banner)
	Local $match2 = IsHexColorInRange(Pixel(1140, 164), "FFFFFF", 10)

	; (Black in Level Up Banner)
	Local $match3 = IsHexColorInRange(Pixel(1028, 155), "000000", 10)

	; (Blue in Progress Bar)
	Local $match4 = IsHexColorInRange(Pixel(664, 821), "00DBFA", 10)

	; (White in Tap To Continue Text)
	Local $match5 = IsHexColorInRange(Pixel(781, 975), "FFFFFF", 10)

	; All of them should match
	If $match1 And $match2 And $match3 And $match4 And $match5 Then Return 1

	Return 0
EndFunc

Func DetectStumblePassLevelUp()
	; (Blue Continue Button)
	Local $matchButton = IsHexColorInRange(Pixel(203, 948), "0D89EC", 10) Or IsHexColorInRange(Pixel(513, 995), "086EE7", 10)

	; (White in Banner)
	Local $matchBanner = IsHexColorInRange(Pixel(611, 117), "FFFFFF", 10) Or IsHexColorInRange(Pixel(1308, 118), "FFFFFF", 10)

	; Both of them should match
	If $matchButton And $matchBanner Then Return 1

	Return 0
EndFunc

Func DetectItemReceived()
	; (White Received Text)
	Local $match1 = IsHexColorInRange(Pixel(929, 422), "FFFFFF", 10)

	; (Purple Background)
	Local $match2 = IsHexColorInRange(Pixel(1040, 385), "7E1CB8", 10)

	; (Green Equip Now Button)
	Local $match3 = IsHexColorInRange(Pixel(610, 922), "55DB1E", 10)

	; (Blue OK Button)
	Local $match4 = IsHexColorInRange(Pixel(1601, 915), "0D88EC", 10)

	; All of them should match
	If $match1 And $match2 And $match3 And $match4 Then Return 1

	Return 0
EndFunc

Func DetectAdvert()
	; (Green bottom left purchase button)
	Local $match1 = IsHexColorInRange(Pixel(719, 919), "B1FB76", 10)

	; (Green bottom rifgt purchase button)
	Local $match2 = IsHexColorInRange(Pixel(1167, 919), "7AB068", 10)

	; (Purple top left)
	Local $match3 = IsHexColorInRange(Pixel(335, 156), "152ED2", 10)

	; (Pink bottom right)
	Local $match4 = IsHexColorInRange(Pixel(1581, 932), "CE4F8E", 10)

	; (Red x button)
	Local $match5 = IsHexColorInRange(Pixel(1557, 103), "F45731", 10)

	; All of them should match
	If $match1 And $match2 And $match3 And $match4 And $match5 Then Return 1

	Return 0
EndFunc

Func DetectScreenTransition()
	; (Black screen)
	Local $match1 = IsHexColorInRange(Pixel(50, 50), "000000", 10)
	Local $match2 = IsHexColorInRange(Pixel(50, 950), "000000", 10)
	Local $match3 = IsHexColorInRange(Pixel(1850, 50), "000000", 10)
	Local $match4 = IsHexColorInRange(Pixel(1850, 950), "000000", 10)

	; All of them should match
	If $match1 And $match2 And $match3 And $match4 Then Return 1

	Return 0
EndFunc

Func DetectGameSearch()
	; (Blue Abort Button)
	If IsHexColorInRange(Pixel(65, 960), "128EEB", 10) Then Return 1

	; (Blue Abort Button)
	If IsHexColorInRange(Pixel(331, 1020), "1586EA", 10) Then Return 1

	; (Blue Bottom Right)
	If IsHexColorInRange(Pixel(1892, 1062), "69D8FA", 10) Then Return 1

	; (Blue Top Right)
	If IsHexColorInRange(Pixel(1879, 26), "527EF1", 10) Then Return 1

	Return 0
EndFunc

Func DetectMapSelection()
	; (Purple Top Left)
	If IsHexColorInRange(Pixel(21, 75), "5B57CA", 10) Then Return 1

	; (Purple Bottom Left)
	If IsHexColorInRange(Pixel(46, 1047), "8279F3", 10) Then Return 1

	; (Purple Top Right)
	If IsHexColorInRange(Pixel(1847, 79), "5262D0", 10) Then Return 1

	; (Purple Bottom Right)
	If IsHexColorInRange(Pixel(1841, 1027), "6876FF", 10) Then Return 1

	Return 0
EndFunc

Func DetectGameStart()
	; (White Screen Banner)
	Local $match1 = IsHexColorInRange(Pixel(672, 72), "FFFFFF", 10)

	; (White Screen Banner)
	Local $match2 = IsHexColorInRange(Pixel(1250, 52), "FFFFFF", 10)

	; Both of them should match
	If $match1 And $match2 Then Return 1

	Return 0
EndFunc

Func DetectGameRunning()
	; (White Player Arrow)
	Local $match1 = IsHexColorInRange(Pixel(959, 450), "FFFFFF", 10)

	; (White Player Arrow)
	Local $match2 = IsHexColorInRange(Pixel(961, 448), "FFFFFF", 10)

	; Both of them should match
	If $match1 And $match2 Then Return 1

	Return 0
EndFunc

Func DetectGameResults()
	; (Purple border of flying screen thing)
	If IsHexColorInRange(Pixel(673, 133), "840BE9", 10) Then Return 1

	; (Purple border of flying screen thing)
	If IsHexColorInRange(Pixel(678, 167), "EC43A7", 10) Then Return 1

	Return 0
EndFunc

Func DetectGameLost()
	; (Red Leave Button) 
	Local $match1 = IsHexColorInRange(Pixel(228, 969), "F7513F", 10)

	; (Red Leave Button)
	Local $match2 = IsHexColorInRange(Pixel(29, 994), "F44C39", 10)

	; (White Text in Leave Button)
	Local $match3 = IsHexColorInRange(Pixel(196, 1001), "FFFFFF", 10)

	If $match1 And $match2 And $match3 Then Return 1

	Return 0
EndFunc

Func DetectGetStumbleJourneyReward()
	; (White Congratulations Banner)
	Local $match1 = IsHexColorInRange(Pixel(611, 43), "FFFFFF", 10)

	; (White Congratulations Banner)
	Local $match2 = IsHexColorInRange(Pixel(1276, 50), "FFFFFF", 10)

	; (Black Text in Congratulations Banner)
	Local $match3 = IsHexColorInRange(Pixel(667, 71), "333333", 10)

	; (Yellow Rewards Banner)
	Local $match4 = IsHexColorInRange(Pixel(947, 130), "FFC800", 10)

	; (White Tap To Continue Text)
	Local $match5 = IsHexColorInRange(Pixel(809, 958), "FFFFFF", 10)

	; (Purple Background)
	Local $match6 = IsHexColorInRange(Pixel(946, 1004), "251852", 10)

	If $match1 And $match2 And $match3 And $match4 And $match5 And $match6 Then Return 1

	Return 0
EndFunc

Func DetectGetReward()
	; (Green Get Button)
	If IsHexColorInRange(Pixel(1499, 915), "55DB1E", 10) Then Return 1

	; (Green Get Button)
	If IsHexColorInRange(Pixel(1809, 1001), "44D018", 10) Then Return 1

	Return 0
EndFunc

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Control functions 

Func GoBack()
	Debug("Go Back")
	_Send("{ESC}")
EndFunc

Func LeaveGame()
	Debug("Leave Game")
	_Send("{ESC}")
EndFunc

Func ClickMissions()
	Debug("Click Missions")
	Local $x = Random(1760, 1875)
	Local $y = Random(180, 260)
	_LeftClick($x, $y)
EndFunc

Func CollectMissionReward()
	Debug("Collect Mission Reward")
	Local $x = Random(345, 1710)
	Local $y = Random(780, 880)
	_LeftClick($x, $y)
EndFunc

Func ClickPlayGame()
	Debug("Click Play Game")
	Local $x = Random(1540, 1840)
	Local $y = Random(930, 1030)
	_LeftClick($x, $y)
EndFunc

Func ClickGetReward()
	Debug("Click Get Reward")
	Local $x = Random(1499, 1809)
	Local $y = Random(915, 1001)
	_LeftClick($x, $y)
EndFunc

Func ClickContinue()
	Debug("Click Continue")
	Local $x = Random(480, 520)
	Local $y = Random(930, 970)
	_LeftClick($x, $y)
EndFunc

Func ClickOK()
	Debug("Click OK")
	Local $x = Random(1605, 1645)
	Local $y = Random(900, 940)
	_LeftClick($x, $y)
EndFunc

Func ClickAdvertClose()
	Debug("Click Advert Close")
	Local $x = Random(1553, 1563)
	Local $y = Random(124, 134)
	_LeftClick($x, $y)
EndFunc

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Gameplay functions

Func SimulateGamePlay()
	Debug("Simulate Game Play")

	Local $n = 4
	Local $keys[$n] = ["Left", "Right", "Jump", "Run"]

	For $counter = 1 to $n
		If DetectGameRunning() = 0 Or DetectGameLost() = 1 Then
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Mouse functions

Func Mouse($x, $y, $speed = 20)
	If WinActive($title) = 0 Then Return

	TransformCoordinates($x, $y)
	MouseMove($x, $y, $speed)

	Sleep(50)
EndFunc

Func MouseRandom($minSpeed = 20, $maxSpeed = 30)
	If WinActive($title) = 0 Then Return

	; Try to avoid outer borders
	Local $x = Random(220, 1700)
	Local $y = Random(180, 900)
	Local $speed = Random($minSpeed, $maxSpeed)

	Mouse($x, $y, $speed)
EndFunc

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Color detection functions

Func Pixel($x, $y)
	TransformCoordinates($x, $y)
	Return PixelGetColor($x, $y, $hWnd)
EndFunc

Func IsHexColorInRange($color, $targetHex, $tolerance, $log = 0)
	Local $sourceHex = Hex($color, 6)

	Local $sourceRGB = HexToRGB($sourceHex)
	Local $r1 = $sourceRGB[0]
	Local $g1 = $sourceRGB[1]
	Local $b1 = $sourceRGB[2]

	Local $targetRGB = HexToRGB($targetHex)
	Local $r2 = $targetRGB[0]
	Local $g2 = $targetRGB[1]
	Local $b2 = $targetRGB[2]

	If $log = 1 Then
		Debug("Detected: " & $sourceHex & " / Wanted: " & $targetHex)
		Debug("Diff R: " & Abs($r1 - $r2) & ", G: " & Abs($g1 - $g2) & ", B: " & Abs($b1 - $b2))
	EndIf

	Return _
		Abs($r1 - $r2) <= $tolerance And _
		Abs($g1 - $g2) <= $tolerance And _
		Abs($b1 - $b2) <= $tolerance
EndFunc

Func HexToRGB($hex)
	Local $r = Dec(StringLeft($hex, 2))
	Local $g = Dec(StringMid($hex, 3, 2))
	Local $b = Dec(StringRight($hex, 2))
	Local $rgb[3] = [$r, $g, $b]
	Return $rgb
EndFunc

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Transform functions to support different screen resolutions

Func TransformCoordinates(ByRef $x, ByRef $y)
	Local $pos = WinGetPos($hWnd)
	If @error Then Return

	Local $currWidth = $pos[2]
	Local $currHeight = $pos[3]

	If $currWidth <> $baseWidth Or $currHeight <> $baseHeight Then
		$x = Round($x * $currWidth / $baseWidth)
		$y = Round($y * $currHeight / $baseHeight)
	EndIf
EndFunc

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Simple wrapper functions

Func _Send($keys, $flag = 0)
	; Send key input to game only
	If WinActive($title) = 0 Then Return

	Send($keys, $flag)
EndFunc

Func _LeftClick($x, $y)
	; Send clicks to game only
	If WinActive($title) = 0 Then Return

	TransformCoordinates($x, $y)
	MouseClick("left", $x, $y, 1, 10)

	Sleep(100)
EndFunc

Func _Sleep($min, $max = -1)
	If $max > 0 Then
		Sleep(Random($min, $max))
	Else
		Sleep($min)
	EndIf
EndFunc

Func _Terminate()
	Exit
EndFunc

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Func Debug($msg)
	If Not @Compiled Then
		ConsoleWrite($msg & @CRLF)
	EndIf
EndFunc
