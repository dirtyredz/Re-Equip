Scriptname DR_ReEquip_Effect extends activemagiceffect


GlobalVariable Property DR_ReEquip_WeaponsToggle Auto
GlobalVariable Property DR_ReEquip_ArmorToggle Auto


function OnEffectStart(Actor akTarget, Actor akCaster)
  ;Casting Power
  if(DR_ReEquip_ArmorToggle.GetValueInt())
    ReEquipArmor(Game.GetPlayer())
  endif
  if(DR_ReEquip_WeaponsToggle.GetValueInt())
    ReEquipWeapons(Game.GetPlayer())
  endif
endFunction

Function ReEquipWeapons(Actor target)
  Weapon RightHand = target.GetEquippedWeapon()
  Weapon LeftHand = target.GetEquippedWeapon(true)
  Armor Shield = target.GetEquippedShield()

  if (RightHand)
    target.UnequipItemEx(RightHand) ;UnEquip
    target.EquipItemEx(RightHand, 1, false, false) ;ReEquip Silently
  endif

  if (LeftHand)
    target.UnequipItemEx(LeftHand) ;UnEquip
    target.EquipItemEx(LeftHand, 2, false, false) ;ReEquip Silently
  elseIf (Shield)
    target.UnequipItemEx(Shield) ;UnEquip
    target.EquipItemEx(Shield, 2, false, false) ;ReEquip Silently
  endif
endFunction

;https://www.creationkit.com/index.php?title=Slot_Masks_-_Armor
Function ReEquipArmor(Actor target)
  int index
  int slotsChecked
  slotsChecked += 0x00100000
  slotsChecked += 0x00200000 ;ignore reserved slots
  slotsChecked += 0x80000000

  int thisSlot = 0x01
  while (thisSlot < 0x80000000)
    if (Math.LogicalAnd(slotsChecked, thisSlot) != thisSlot) ;only check slots we haven't found anything equipped on already
      Armor thisArmor = target.GetWornForm(thisSlot) as Armor
      if (thisArmor)
        target.UnequipItemEx(thisArmor) ;UnEquip
        target.EquipItemEx(thisArmor, thisArmor.GetSlotMask(), false, false) ;ReEquip Silently
        index += 1
        slotsChecked += thisArmor.GetSlotMask() ;add all slots this item covers to our slotsChecked variable
      else ;no armor was found on this slot
        slotsChecked += thisSlot
      endif
    endif
    thisSlot *= 2 ;double the number to move on to the next slot
  endWhile
EndFunction
