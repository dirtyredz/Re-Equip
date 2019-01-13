
Scriptname DR_ReEquip_MCM extends  SKI_ConfigBase


GlobalVariable Property DR_ReEquip_WeaponsToggle Auto
GlobalVariable Property DR_ReEquip_ArmorToggle Auto
GlobalVariable Property DR_ReEquip_Hotkey Auto

SPELL Property DR_ReEquipPower Auto


Event OnPageReset(string page)
  If (Page == "") ;This is always the first page we see when we first enter, or click on the menu.
    SetCursorFillMode(TOP_TO_BOTTOM)
    SetCursorPosition(0)

    AddHeaderOption("Re-Equip Toggles")
    AddEmptyOption() ;Adds a space before the next option is added.

    AddToggleOptionST("OID_DR_ReEquip_ArmorToggle", "Armor Toggle", DR_ReEquip_ArmorToggle.GetValueInt())
    AddToggleOptionST("OID_DR_ReEquip_WeaponsToggle", "Weapons Toggle", DR_ReEquip_WeaponsToggle.GetValueInt())

    AddEmptyOption() ;Adds a space before the next option is added.
    AddHeaderOption("")

    SetCursorPosition(1)
    AddHeaderOption("Hotkeys")
    AddEmptyOption() ;Adds a space before the next option is added.

    AddKeyMapOptionST("OID_DR_ReEquip_HotKey", "Cast Re-Equip Power Hotkey", DR_ReEquip_Hotkey.GetValueInt(), OPTION_FLAG_WITH_UNMAP)

    string unbindMsg = ""
    if (DR_ReEquip_Hotkey.GetValueInt() > -1)
      unbindMsg = "Unbind Hotkey"
    endif
    AddTextOptionST("OID_DR_ReEquip_UnbindHotkey", "", unbindMsg)
    AddEmptyOption() ;Adds a space before the next option is added.
    AddHeaderOption("")
  EndIf
EndEvent

state OID_DR_ReEquip_ArmorToggle
  Event OnHighlightST()
    SetInfoText("When selected Re-Equip power will Re-Equip all armor your currently wearing.\nDefault: true")
  EndEvent

  Event OnSelectST()
    If DR_ReEquip_ArmorToggle.GetValue() == 1 ;If the ToggleA Global Variable is 1, or rather, if our toggle option in the menu is checked
      DR_ReEquip_ArmorToggle.SetValue(0) ;sets the Global Variable to 0
      SetToggleOptionValueST(0) ;Sets the toggle display in the menu to unchecked. Optionally disable something in your mod here, or use the ToggleA global variable elsewhere.
    ElseIf DR_ReEquip_ArmorToggle.GetValue() == 0 ;If the ToggleA is 0, or rather, if our toggle option is unchecked
      DR_ReEquip_ArmorToggle.SetValue(1) ;set’s the Global Variable to 1
      SetToggleOptionValueST(1) ;Set’s the toggle display in the menu to checked. Optionally enable something in your mod here, or use the ToggleA global variable elsewhere.
    EndIf
  EndEvent
EndState

state OID_DR_ReEquip_WeaponsToggle
  Event OnHighlightST()
    SetInfoText("When selected Re-Equip power will Re-Equip all Weapons your currently holding.\nDefault: false")
  EndEvent

  Event OnSelectST()
    If DR_ReEquip_WeaponsToggle.GetValue() == 1 ;If the ToggleA Global Variable is 1, or rather, if our toggle option in the menu is checked
      DR_ReEquip_WeaponsToggle.SetValue(0) ;sets the Global Variable to 0
      SetToggleOptionValueST(0) ;Sets the toggle display in the menu to unchecked. Optionally disable something in your mod here, or use the ToggleA global variable elsewhere.
    ElseIf DR_ReEquip_WeaponsToggle.GetValue() == 0 ;If the ToggleA is 0, or rather, if our toggle option is unchecked
      DR_ReEquip_WeaponsToggle.SetValue(1) ;set’s the Global Variable to 1
      SetToggleOptionValueST(1) ;Set’s the toggle display in the menu to checked. Optionally enable something in your mod here, or use the ToggleA global variable elsewhere.
    EndIf
  EndEvent
EndState

;https://www.creationkit.com/index.php?title=Input_Script#DXScanCodes
state OID_DR_ReEquip_HotKey
  event OnKeyMapChangeST(int theKeyCode, string conflictControl, string conflictName)
    int oldHotKey = DR_ReEquip_Hotkey.GetValueInt()

    if (CheckNewHotkey(conflictControl, conflictName))
			if oldHotKey
        unregisterForKey(oldHotKey)
      endIf
      SetKeyMapOptionValueST(theKeyCode)
      DR_ReEquip_Hotkey.SetValue(theKeyCode)
      registerForKey(theKeyCode)
      SetTextOptionValueST("Unbind Hotkey", false, "OID_DR_ReEquip_UnbindHotkey")
		endIf
  endEvent

  event OnHighlightST()
    SetInfoText("Set hot key to cast the Re-Equip power (will cast then re-equip your originally equiped power/shout).")
  endEvent
endState

state OID_DR_ReEquip_UnbindHotkey
	event OnSelectST()
    int Hotkey = DR_ReEquip_Hotkey.GetValueInt()
    if (Hotkey > -1)
      if ShowMessage("Do you want to unbind the Re-Equip hotkey?", true, "Unbind", "Cancel")
        SetTextOptionValueST("")
        unregisterForKey(DR_ReEquip_Hotkey.GetValueInt())
        SetKeyMapOptionValueST(-1, false, "OID_DR_ReEquip_HotKey")
      endIf
    endif
	endEvent

	event OnHighlightST()
    int Hotkey = DR_ReEquip_Hotkey.GetValueInt()
    if (Hotkey > -1)
      SetInfoText("Will unbind the Re-Equip hotkey.")
    endif
	endEvent
endState

Event OnKeyDown(Int KeyCode)
	Debug.Trace("A registered key has been pressed")
	If KeyCode == DR_ReEquip_Hotkey.GetValueInt()
    CastReEquipPower(Game.GetPlayer())
	EndIf
EndEvent

; Checks if the newly assigned key is conflicting with another mod and asks
; the user if we should go on. Return true if no conflict or ignore.
bool function CheckNewHotkey(string conflictControl, string conflictName)
	if (conflictControl != "")
		string msg
		if (conflictName != "")
			msg = "This Key mapped to mod {" + conflictControl + "}{" + conflictName + "}"
		else
			msg = "This Key mapped to game {" + conflictControl + "}"
		endIf

		return ShowMessage(msg, true, "$Yes", "$No")
	endIf

	return true
endFunction

function CastReEquipPower(Actor target)
	form equippedShoutOrPower = GetEquippedShoutOrPower(target)
	int shoutKey = Input.GetMappedKey("Shout", 255)

  Input.ReleaseKey(shoutKey)
  Utility.WaitMenuMode(0.04)
  target.EquipSpell(DR_ReEquipPower, 2)
  Input.TapKey(shoutKey)
	Utility.WaitMenuMode(0.04)
  if !equippedShoutOrPower
		return
	endIf
  bool isShout = (equippedShoutOrPower as Shout)
  if isShout
    target.EquipShout(equippedShoutOrPower as Shout)
  else
    target.EquipSpell(equippedShoutOrPower as Spell, 2)
  endif
endFunction

Form function GetEquippedShoutOrPower(Actor target)
  form equippedShout = target.GetEquippedShout()
  if equippedShout
    return equippedShout
  endif
  form equippedSpell = target.GetEquippedSpell(2) ; specified source (0: Left hand; 1: Right hand; 2: Other; 3: Instant)
  if equippedSpell
    return equippedSpell
  endif
  return none ; if no shout or spell equipped, then return none.
endfunction
