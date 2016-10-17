Scriptname zadPlugScript extends zadEquipScript

Keyword Property zad_DeviousBelt Auto

string strFailEquipBelt =  "Try as you might, the belt you are wearing prevents you from inserting this plug."
string strFailEquipHarness =  "Try as you might, the harness you are wearing prevents you from inserting this plug."

int Function OnEquippedFilter(actor akActor, bool silent=false)
	; FTM optimization
	if silent && akActor != libs.PlayerRef
		return 0
	EndIf
	if akActor.WornHasKeyword(libs.zad_DeviousBelt)
		if akActor == libs.PlayerRef && !silent
			libs.NotifyActor(strFailEquipBelt, akActor, true)
		ElseIf  !silent
			libs.NotifyActor("The belt " + akActor.GetLeveledActorBase().GetName() + " is wearing prevents you from inserting this plug.", akActor, true)
		EndIf
		if !silent
			return 2
		Else
			return 0
		EndIf
	Endif
	if akActor.WornHasKeyword(libs.zad_DeviousHarness)
		if akActor == libs.PlayerRef && !silent
			libs.NotifyActor(strFailEquipHarness, akActor, true)
		ElseIf  !silent
			libs.NotifyActor("The harness " + akActor.GetLeveledActorBase().GetName() + " is wearing prevents you from inserting this plug.", akActor, true)
		EndIf
		if !silent
			return 2
		Else
			return 0
		EndIf
	Endif
	return 0
EndFunction

Function OnEquippedPre(actor akActor, bool silent=false)
	; Check to see if old (slot 54) plug is being used.
	int slotMask = deviceRendered.GetSlotMask()
	if (Math.LogicalAnd(slotMask, 0x01000000)) ; Slot 54
		libs.Warn("Legacy (Slot 54) plug detected. Updating slotmask...")
		slotMask = ((slotMask - 0x01000000) + 0x08000000)
		deviceRendered.SetSlotMask(slotMask)
	EndIf
	string msg = ""
	if akActor == libs.PlayerRef
		if Aroused.GetActorExposure(akActor) < libs.ArousalThreshold("Desire")
			msg = "Your hole is now filled, as is your desire for pleasure."
		elseif Aroused.GetActorExposure(akActor) < libs.ArousalThreshold("Horny")
			msg = "You slowly insert the plug inside your opening, your lust growing with every inch it slides in."
		elseif Aroused.GetActorExposure(akActor) < libs.ArousalThreshold("Desperate")
			msg = "You insert the plug inside your opening and take great delight in the resulting feelings of pleasure."
		else
			msg = "Barely in control of control your own body you thrust the plug almost forcefully into the appropriate opening."
		endif
	else
		msg = akActor.GetLeveledActorBase().GetName() + " shudders as you push the plugs in to her."
	EndIf
	if !silent
		libs.NotifyActor(msg, akActor, true)
	EndIf
EndFunction


Function OnEquippedPost(actor akActor)
	Utility.Wait(5)
	bool legacyPlugs = false
	; Slots 48 and 57 Anal and Vaginal plugs      
	Form analSlot = akActor.GetWornForm(0x00040000)
	Form vagSlot = akActor.GetWornForm(0x08000000)
	if analSlot && vagSlot && analSlot == vagSlot
		legacyPlugs = true
	EndIf

; Depreciated as of 3.3, plugs are no longer supposed to slide out on their own

;	if ((!akActor.WornHasKeyword(libs.zad_DeviousBelt) && !akActor.WornHasKeyword(libs.zad_DeviousHarness))  || ((akActor.WornHasKeyword(libs.zad_DeviousBelt) || akActor.WornHasKeyword(libs.zad_DeviousHarness)) && akActor.WornHasKeyword(libs.zad_PermitAnal) && !legacyPlugs && deviceRendered.HasKeyword(libs.zad_DeviousPlugAnal))) && akActor.WornHasKeyword(zad_DeviousDevice) && !akActor.WornHasKeyword(libs.zad_EffectPossessed) && akActor == libs.PlayerRef && akActor.GetActorBase().GetSex() != 0
;		libs.Log("Belt not worn: Removing plugs.")
;		RemoveDevice(akActor)
;		if akActor == libs.PlayerRef
;			libs.NotifyPlayer("Lacking a belt to hold them in, the plugs slide out of you.")
;		else
;			libs.NotifyNPC("Lacking a belt to hold them in, the plugs slide out of "+akActor.GetLeveledActorBase().GetName()+".")
;			akActor.RemoveItem(deviceInventory, 1, true)
;			libs.PlayerRef.AddItem(deviceInventory, 1, true)
;		EndIf
;	EndIf
EndFunction

; removed this to allow scripts to unquip these items. The dialogue will catch in-game attempts anyway, so it's not really needed.
; int Function OnUnequippedFilter(actor akActor)
	; if akActor.WornHasKeyword(libs.zad_DeviousBelt)
		; return 1
	; EndIf
	; if akActor.WornHasKeyword(libs.zad_DeviousHarness)
		; return 1
	; EndIf
	; return 0
; EndFunction


Function DeviceMenu(Int msgChoice = 0)
        msgChoice = zad_DeviceMsg.Show() ; display menu
	if msgChoice==0 ; Not wearing a belt/harness, no plugs
		Debug.Notification("You choose to put the plugs in.")
		libs.EquipDevice(libs.PlayerRef, deviceInventory, deviceRendered, zad_DeviousDevice)
	elseif msgChoice==1 ; Wearing a harness, no plugs
		Debug.MessageBox(strFailEquipHarness)
	elseif msgChoice==2 ; Wearing a belt, no plugs
		Debug.MessageBox(strFailEquipBelt)
	elseif msgChoice==3 ; Not wearing a belt/harness, plugs
		string msg = ""
		if Aroused.GetActorExposure(libs.PlayerRef) < libs.ArousalThreshold("Desire")
			msg = "You easily slide the plug out of your hole and feel no regret."
		elseif Aroused.GetActorExposure(libs.PlayerRef) < libs.ArousalThreshold("Horny")
			msg = "Despite the pleasure it provides, you remove the plug from your hole."
		elseif Aroused.GetActorExposure(libs.PlayerRef) < libs.ArousalThreshold("Desperate")
			msg = "Despite your body telling you otherwise, you reluctantly pull the plug from your now well lubricated opening."
		else
			msg = "It takes all the willpower that you can muster to relax your muscles enough to let the plug slide out."
		endif
		libs.NotifyPlayer(msg, true)
		RemoveDevice(libs.PlayerRef)
	elseif msgChoice==4 ; Wearing a harness, plugs
		NoKeyFailMessageHarness(libs.PlayerRef)
	elseif msgChoice==5 ; Wearing a belt, plugs
		NoKeyFailMessageBelt(libs.PlayerRef)
	Endif
	DeviceMenuExt(msgChoice)
	SyncInventory()
EndFunction
		

Function NoKeyFailMessageBelt(Actor akActor)
	if akActor == libs.PlayerRef
		libs.NotifyPlayer("Try as you might, the belt you are wearing prevents you from removing this plug.", true)
	Else
		libs.NotifyNPC("The belt that "+akActor.GetLeveledActorBase().GetName() + " is wearing is securely locking this plug in place. You must remove it prior to removing the plug.", true)
	EndIf
EndFunction

Function NoKeyFailMessageHarness(Actor akActor)
	if akActor == libs.PlayerRef
		libs.NotifyPlayer("Try as you might, the harness you are wearing prevents you from removing this plug.", true)
	Else
		libs.NotifyNPC("The harness that "+akActor.GetLeveledActorBase().GetName() + " is wearing is securely locking this plug in place. You must remove it prior to removing the plug.", true)
	EndIf
EndFunction