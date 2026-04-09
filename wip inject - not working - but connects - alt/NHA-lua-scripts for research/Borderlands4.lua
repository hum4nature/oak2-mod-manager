NHA_Borderlands4TableVersion=1.01;
NHA_Borderlands4TableRelease="2/2/2026 AUSTRALIA";

UE.InitOffsets=function();
 UE.Offset={
  GameInstance=UE.GetOffsetBySymbol("GameEngine.GameInstance"),
  LocalPlayers=UE.GetOffsetBySymbol("GameInstance.LocalPlayers"),
  PlayerController=UE.GetOffsetBySymbol("player.PlayerController"),
  IsLocalPlayerController=UE.GetOffsetBySymbol("PlayerController.bIsLocalPlayerController"),
  MovementMode=UE.GetOffsetBySymbol("CharacterMovementComponent.MovementMode"),
  PlayerState=UE.GetOffsetBySymbol("Pawn.PlayerState"),
  bCanBeDamaged=UE.GetOffsetBySymbol("Actor.bCanBeDamaged"),
  GameViewport=UE.GetOffsetBySymbol("Engine.GameViewport"),
  World=UE.GetOffsetBySymbol("GameViewportClient.World"),
  PersistentLevel=UE.GetOffsetBySymbol("World.PersistentLevel"),
  WorldSettings=UE.GetOffsetBySymbol("Level.WorldSettings"),
  WorldSettingsKillZ=UE.GetOffsetBySymbol("WorldSettings.KillZ"),
  GameState=UE.GetOffsetBySymbol("World.GameState"),
  PlayerArray=UE.GetOffsetBySymbol("GameStateBase.PlayerArray"),
  PlayerNamePrivate=UE.GetOffsetBySymbol("PlayerState.PlayerNamePrivate"),
  Owner=UE.GetOffsetBySymbol("Actor.owner"),
  --Fix For Vehicles Breaking Pawns
  PawnUntrusted=UE.GetOffsetBySymbol("Controller.Pawn"),
  Pawn=UE.GetOffsetBySymbol("GbxPlayerController.PrimaryCharacter"),

  Movement=UE.GetOffsetBySymbol("Character.CharacterMovement"),
  JumpCurrentCount=UE.GetOffsetBySymbol("Character.JumpCurrentCount"),
  GravityScale=UE.GetOffsetBySymbol("CharacterMovementComponent.GravityScale"),
  WalkableFloorAngle=UE.GetOffsetBySymbol("CharacterMovementComponent.WalkableFloorAngle"),
  WalkableFloorZ=UE.GetOffsetBySymbol("CharacterMovementComponent.WalkableFloorZ"),
  MaxStepHeight=UE.GetOffsetBySymbol("CharacterMovementComponent.MaxStepHeight"),
  AirControl=UE.GetOffsetBySymbol("CharacterMovementComponent.AirControl"),
  AirControlBoostMultiplier=UE.GetOffsetBySymbol("CharacterMovementComponent.AirControlBoostMultiplier"),
  AirControlBoostVelocityThreshold=UE.GetOffsetBySymbol("CharacterMovementComponent.AirControlBoostVelocityThreshold"),
  VaultPowerCost_Dash=UE.GetOffsetBySymbol("OakCharacterMovementComponent.VaultPowerCost_Dash"),
  VaultPowerCost_Glide=UE.GetOffsetBySymbol("OakCharacterMovementComponent.VaultPowerCost_Glide")+4,
  
  MaxWalkSpeed=UE.GetOffsetBySymbol("CharacterMovementComponent.MaxWalkSpeed"),
  MaxWalkSpeedCrouched=UE.GetOffsetBySymbol("CharacterMovementComponent.MaxWalkSpeedCrouched"),
  MaxSwimSpeed=UE.GetOffsetBySymbol("CharacterMovementComponent.MaxSwimSpeed"),
  MaxAcceleration=UE.GetOffsetBySymbol("CharacterMovementComponent.MaxAcceleration"),
  
  InfinateClipLock=UE.GetOffsetBySymbol("OakPlayerController.InfiniteClipLock"),
  DamageCauserData=UE.GetOffsetBySymbol("OakCharacter.DamageCauserData"),
  DamageDealtMultiplier=UE.GetOffsetBySymbol("DamageCauserData.DamageDealtMultiplier"),
  CanUseWeaponWhileSprinting=UE.GetOffsetBySymbol("OakCharacter.bCanUseWeaponWhileSprinting"),
  CanZoomWhileSprinting=UE.GetOffsetBySymbol("OakCharacter.bCanZoomWhileSprinting"),
  CurrencyManager=UE.GetOffsetBySymbol("GbxPlayerController.CurrencyManager"),
  currencies=UE.GetOffsetBySymbol("GbxCurrencyManager.currencies"),
  GbxCurrencyAmount=UE.GetOffsetBySymbol("GbxCurrency.Amount"),
  
  RootComponent=UE.GetOffsetBySymbol("Actor.RootComponent"),
  ZoomState=UE.GetOffsetBySymbol("OakCharacter.ZoomState"),
  WantsToCrouch=UE.GetOffsetBySymbol("CharacterMovementComponent.bWantsToCrouch"),
  --96 == crouch, 8 = jump, 64= stand, 0=fall/swim
  ActiveWeapons=UE.GetOffsetBySymbol("OakCharacter.ActiveWeapons"),
  ActiveWeaponSlotPendingWeapon=UE.GetOffsetBySymbol("ActiveWeaponSlot.PendingWeapon"),
  
  PlayerControllerSpawnLocation=UE.GetOffsetBySymbol("PlayerController.SpawnLocation"),
  bDrivingVehicle=UE.GetOffsetBySymbol("OakPlayerState.bDrivingVehicle")
 };
 UE.Offset.OakChallengeManager=UE.GetOffsetBySymbol("OakPlayerController.OakChallengeManager");
 UE.Offset.OakPlayerStateBankItemsOffset=UE.GetOffsetBySymbol("OakPlayerState.BankItems");
 UE.Offset.OakPlayerStateBackpackItemsOffset=UE.GetOffsetBySymbol("OakPlayerState.BackpackItems");
 UE.Offset.GbxItemSlotsContainerItemsOffset=UE.GetOffsetBySymbol("GbxItemSlotsContainer.items");
 UE.Offset.GbxItemContainerSlot_InventoryItem=UE.GetOffsetBySymbol("GbxItemContainerSlot.InventoryItem");
 UE.Offset.InventoryItem_EquipSlot=UE.Offset.GbxItemContainerSlot_InventoryItem+UE.GetOffsetBySymbol("InventoryItem.EquipSlot");
 UE.Offset.InventoryItem_Handle=UE.Offset.GbxItemContainerSlot_InventoryItem+UE.GetOffsetBySymbol("InventoryItem.Handle");
 UE.Offset.InventoryItem_item=UE.Offset.GbxItemContainerSlot_InventoryItem+UE.GetOffsetBySymbol("InventoryItem.item");
 UE.Offset.GbxItemData_InstanceId=UE.Offset.InventoryItem_item+UE.GetOffsetBySymbol("GbxItemData.InstanceId");
 UE.Offset.GbxItemData_Identity=UE.Offset.InventoryItem_item+UE.GetOffsetBySymbol("GbxItemData.Identity");
 UE.Offset.InventoryIdentity_PartString=UE.Offset.GbxItemData_Identity+UE.GetOffsetBySymbol("InventoryIdentity.PartString");
 
 UE.Offset.OakCharacterWorldDifficulty=UE.GetOffsetBySymbol("OakCharacter.WorldDifficulty");
 UE.Offset.OakCharacterDef=UE.Offset.OakCharacterWorldDifficulty+0x8;




 --Predicting Team Name Offset By Knowing Its Offsets Away From Other Stuff In The Same Structure
 UE.Offset.GbxAICharacterTargetChangedEvent=UE.GetOffsetBySymbol("GbxAICharacter.TargetChangedEvent");
 UE.Offset.GbxAICharacterTargetableState=UE.GetOffsetBySymbol("GbxAICharacter.TargetableState");
 UE.Offset.GbxAICharacterName=UE.Offset.GbxAICharacterTargetableState-0x40;
 if UE.Offset.GbxAICharacterTargetChangedEvent+0x38~=UE.Offset.GbxAICharacterName then;
 local FF=0;
 for FF=0,10,1 do;
  print("Warning: GbxAICharacter Name Offset May Be Incorrect!");
  end
 end

 UE.Offset.CurrencysMax =UE.GetStructureSizeWithInheritanceCached("GbxCurrency");

 UE.Offset.OakCharacter_ResourcePoolManager=UE.GetOffsetBySymbol("OakCharacter.ResourcePoolManager");
 UE.Offset.GbxItemContainerSlotEndCount=UE.GetObjectByName("GbxItemContainerSlot").EndCount;
 UE.Offset.Progression_PointsAcquiredPerPool=UE.GetOffsetBySymbol("OakCharacter.GbxProgressionManager")+UE.GetOffsetBySymbol("GbxProgressionManager.ProgressPointsContainer")+UE.GetOffsetBySymbol("GbxProgressPointsContainer.PointsAcquiredPerPool")


 UE.Offset.ActiveWeaponsStateSlots=UE.Offset.ActiveWeapons+UE.GetOffsetBySymbol("ActiveWeaponsState.Slots");
 UE.Offset.WantsToZoom=UE.Offset.ZoomState+UE.GetOffsetBySymbol("ZoomHandlerState.bWantsToZoom");
 local GRRS=UE.GetOffsetBySymbol("OakGameState.RarityState");
 UE.Offset.RarityState_CommonModifier =GRRS+UE.GetOffsetBySymbol("GameRarityState.CommonModifier")+0x4
 UE.Offset.RarityState_UnCommonModifier =GRRS+UE.GetOffsetBySymbol("GameRarityState.UncommonModifier")+0x4
 UE.Offset.RarityState_RareModifier = GRRS+UE.GetOffsetBySymbol("GameRarityState.RareModifier")+0x4
 UE.Offset.RarityState_VeryRareModifier =GRRS+UE.GetOffsetBySymbol("GameRarityState.VeryRareModifier")+0x4
 UE.Offset.RarityState_LegendaryModifier =GRRS+UE.GetOffsetBySymbol("GameRarityState.LegendaryModifier")+0x4

 UE.Offset.bMayWantToGlide=UE.GetOffsetBySymbol("OakCharacterMovementComponent.bMayWantToGlide");
 
 UE.Offset.MaxGroundSpeedScale=UE.GetOffsetBySymbol("GbxCharacterMovementComponent.MaxGroundSpeedScale")+4;

 
 UE.Offset.ReplicatedSwimmingState=UE.GetOffsetBySymbol("GbxCharacterMovementComponent.ReplicatedSwimmingState");
 UE.Offset.ReplicatedSwimmingState_SurfaceZ=UE.Offset.ReplicatedSwimmingState+UE.GetOffsetBySymbol("ReplicatedSwimmingState.SurfaceZ");

 
 UE.Offset.CurrentJump=UE.GetOffsetBySymbol("GbxCharacterMovementComponent.CurrentJump");
 UE.Offset.CurrentJump_JumpGoal=UE.Offset.CurrentJump+0x10+UE.GetOffsetBySymbol("JumpDetails.JumpGoal");
 
 UE.Offset.JumpGoal_InitialZVelocity=UE.GetOffsetBySymbol("JumpGoalDef.InitialZVelocity");
 UE.Offset.JumpGoal_GoalHeight=UE.GetOffsetBySymbol("JumpGoalDef.GoalHeight");
 UE.Offset.JumpGoal_bUseInitialZVelocity=UE.GetOffsetBySymbol("JumpGoalDef.bUseInitialZVelocity");--bUseGoalHeight&bClearGravityScaleAtApex


end

UE.FillCustomObjects=function();
 --Borderlands Uses Blueprint Generated Structs Which This Dumper WILL Not Do Right Now
 local InventoryIdentity = UE.CreateCustomObjectData("InventoryIdentity", "Struct", {
  UE.CreateMemberData("PartString", "StrProperty", --[[0xB8]] 0xA0, 8,"StrProperty"),
 })
 UE.AddCustomObject(InventoryIdentity);
end;

UE.HackedPlayerData=nil;

UE.PlayerDataInitialize=function(Player)
 if UE.HackedPlayerData then;
  local S=readString(UE.HackedPlayerData,3);
  if S~="NHA" then
   UE.HackedPlayerData=nil;
  end
 end
 if UE.HackedPlayerData==nil then
  UE.HackedPlayerData=AllocateMemory(0x1000);
  WriteString(UE.HackedPlayerData,"NHA");
 end
 local HS=UE.HackedPlayerData+((0x1000/4)*(Player.Index-1));
 Player.GodMode=false;
 Player.SuperSpeed=false;
 Player.SuperJump=false;
 Player.InfinateAmmo=false;
 Player.MaxDamage=false;
 Player.Noclip=false;
 Player.MaxMoney=false;
 Player.WalkUnderWater=false;
 Player.LevelUp=false;
 Player.LevelUpSpecialization=false;
 Player.JumpCount=0;
 Player.JumpCountTicks=0;
 Player.LastJumpState=0;
 Player.InventoryIncrease=false;
 Player.VehicleBoostHack=false;
 Player.Freeze=false;
 Player.FreezeXYZ={0,0,0};
 Player.EnableHackedJumpGoalDef=false;
 Player.HackedJumpGoalDef=HS+0x8;
 writeQword(Player.HackedJumpGoalDef+0x10,1);
 writeFloat(Player.HackedJumpGoalDef+UE.Offset.JumpGoal_InitialZVelocity,840*1);
 writeFloat(Player.HackedJumpGoalDef+UE.Offset.JumpGoal_GoalHeight,198*4);
 writeByte(Player.HackedJumpGoalDef+UE.Offset.JumpGoal_bUseInitialZVelocity,2);--2 Or 7?



end

--Team_NPC, Team_Player, Team_Order, Team_Creep, Team_Cat,
UE.ReadTeamName=function(Address)
 local F=ReadPointer(Address+UE.Offset.GbxAICharacterName)
 F=F and ReadPointer(F+0x8) or nil
 F=F and readInteger(F+0xC) or nil
 F=F and UE.GetName(F) or nil;
 if F==nil then
  F=readInteger(Address+0x18);
  F=F and UE.GetName(F) or nil;
 end
 return F
end

UE.ActorArrayDo=function(Do)
 local A=UE.Level;
 if not A then;return;end
 local B=readInteger(A+0xA8);
 A=readPointer(A+0xA0);
 local C=0;
 local D=0;
 if B and B>0 then
  for C=0,B,1 do
   D=readPointer(A+(0x8*C));
   D=Do(D,C);
   if D and D==true then
    break;
   end
  end
 end
end FNR("UE.ActorArrayDo");

--Made By: dr NHA
UE.ReadItemNamingScheme=function(Address,DataOffset)
 --From Active Item: +0x420;
 --From InventoryItem: +0x48;
 local A,B,C,D,E=readInteger(Address+DataOffset+0x8),readPointer(Address+DataOffset),0,nil,"";
 for C=0,A-1,1 do
  D=readPointer(B+(0x10*C));
  D=D and readPointer(D+0x18);
  D=D and readString(D,1000,true) or nil;
  if D then
   if E=="" then;
    E=D;
   else
    E=E.." "..D;
   end
  end
 end
 return E;
end


UE.PawnResourcePoolsDo=function(Pawn,Do)
 local A=Pawn+UE.Offset.OakCharacter_ResourcePoolManager+0x18;
 local Pools=readPointer(A);
 local Count=ReadInteger(A+0x8);
 local B=0;local C=0;local N=nil;
 for B=0,Count-1,1 do
  C=readPointer(Pools+(B*0x10));
  if C then
   N=ReadPointer(C+0x10);
   if N then
    N=UE.GetName( readInteger(N+0x18))
    C=Do(B,C,N);
    if C and C==true then
     break;
    end
   end
  end
 end
end FNR("UE.PawnResourcePoolsDo");

UE.ReadGbxItemContainerSlot=function(Address)
 local replicationID = readInteger(Address + 0x0);
 local handle = readInteger(Address + 0x108);
 if replicationID and replicationID >0 and handle and handle>0 and handle~=4294967295 then
  local typePointer = readPointer(Address + 0x18);
  local infoPointer = readPointer(Address + 0x20);
  local TRUENAME=UE.ReadItemNamingScheme(Address,0x48);
  local partsPointer = readPointer(Address + 0xB8);
  local partsString = readString(partsPointer,1000);
  local partsBytesHex,partsBytes=B85.decode(partsString);
  local partsBits = B85.bytesToBits(partsBytes)
  local Level=partsBits and B85.itemDecodeLevel(partsBits);
  Level=Level and Level.level or 0;
  local quantity = readInteger(Address + 0xF8);
  local flags = readInteger(Address + 0xFC);
  local equipSlot = readByte(Address + 0x10D);
  if equipSlot and equipSlot==255 then;
   equipSlot="";
  end
  local maxQuantity = readInteger(Address + 0x138);
  local isLocked = readByte(Address + 0x13C);
  local itemName = "Unknown";
  local namePointer = nil;
  if infoPointer and infoPointer ~= 0 then
   namePointer = readPointer(infoPointer + 0x48);
   if namePointer and namePointer ~= 0 then
    itemName = UE.GetName(namePointer) or "Unknown";
   end
  end
  local itemType = "Unknown";
  local typeNamePointer = nil;
  if typePointer and typePointer ~= 0 then
   typeNamePointer = readPointer(typePointer + 0x3C);
   if typeNamePointer and typeNamePointer ~= 0 then
    itemType = UE.GetName(typeNamePointer) or "Unknown";
   end
  end
  local Parts=ReadPointer(Address + 0x28);
  local PartsCount=readInteger(Address + 0x30);
  local PartsMax=readInteger(Address + 0x34);
  local DecodedPartString="";
  local P=0;
  for P=0,PartsCount,1 do
   local ReadPointer=ReadPointer(Parts+(P*8));
   if not ReadPointer then;break;end
   local InnerPartTypeId=ReadInteger( ReadPointer+0x20);
   local InnerPartType=UE.GetName(InnerPartTypeId);
   local PartTypeId=ReadInteger( ReadPointer+0x40);
   local PartType=UE.GetName(PartTypeId);
   local PartId=ReadInteger( readPointer(ReadPointer+0x68));
   local PartName=UE.GetName(PartId);
   PartType=UE.IsValidString(PartType) and PartType or nil;
   PartName=UE.IsValidString(PartName) and PartName or nil;
   InnerPartType=UE.IsValidString(InnerPartType) and InnerPartType or nil;
   if PartName and PartType then;
    DecodedPartString=DecodedPartString..PartType.."."..PartName..", ";
   elseif InnerPartType then
    DecodedPartString=DecodedPartString..InnerPartType..", ";
   end;
  end
 
  return {
   Address = Address,
   truename=TRUENAME,
   name = itemName,
   type = itemType,
   quantity = quantity,
   maxQuantity = maxQuantity,
   flags = flags,
   handle = handle,
   equipSlot = equipSlot,
   isLocked = isLocked,
   typePointer = typePointer,
   infoPointer = infoPointer,
   partsPointer = partsPointer,
   namePointer = namePointer,
   typeNamePointer = typeNamePointer,
   replicationID = replicationID,
   partsString = partsString,
   partsBytesHex=partsBytesHex,
   partsBytes=partsBytes,
   partsBits=partsBits,
   level=Level,
   DecodedPartString=DecodedPartString,
   replicationIDOffset = Address + 0x0,
   typeOffset = Address + 0x18,
   infoOffset = Address + 0x20,
   partsOffset = Address + 0xB8,
   quantityOffset = Address + 0xF8,
   flagsOffset = Address + 0xFC,
   handleOffset = Address + 0x108,
   equipSlotOffset = Address + 0x10D,
   maxQuantityOffset = Address + 0x138,
   lockedOffset = Address + 0x13C
  };
 end
 return nil;
end

UE.KillAllEnemies=false;
UE.ForcedRarityModifiers=false;
UE.ForcedCommonModifier=1.0;
UE.ForcedUnCommonModifier=1.0;
UE.ForcedRareModifier=1.0;
UE.ForcedVeryRareModifier=1.0;
UE.ForcedLegendaryModifier=1.0;
UE.TpToCrosshairEnabled=false;
UE.TpToCrosshairExcludePlayers=true;
UE.TpToCrosshairExcludeNonPlayers=false;
UE.TpToCrosshairExcludeNpcs=true;
UE.TpToCrosshairStopTracking=false;
UE.TpToCrosshairDistance=1500; -- Adjust this distance as needed (units in front of player)
local LocalPlayerX,LocalPlayerY,LocalPlayerZ,yaw,pitch,yawRad,pitchRad,MX,MY,MZ,crosshairX,crosshairY,crosshairZ,A,B,C,D,E=nil;
--GameState +670 = Teleport Locations Array

UE.KillPawn=function(PAWN,RESTORE);
 if RESTORE and RESTORE==1 then
  UE.PawnResourcePoolsDo(PAWN,function(B,C,N);if N=="Health" or N=="Shield" or N=="Overshield" or N=="Resource_AI_Health_01" or N=="Resource_AI_Health_02" then;
  writeFloat(C+0x90,-1);
  writeFloat(C+0xC8,0.01);
  end;end);
 return
 end
  local Pool=0;
  UE.PawnResourcePoolsDo(PAWN,function(B,C,N);if N=="Health" or N=="Shield" or N=="Overshield" or N=="Resource_AI_Health_01" or N=="Resource_AI_Health_02" then;Pool=C;return true;end;end);
  local PBK=readFloat(Pool+0x90);
  writeFloat(Pool+0x90,-1);
  writeFloat(Pool+0xC8,0.01);
   sleep(4);
   writeFloat(Pool+0x90,PBK);
 end FNR("UE.KillPawn");

UE.KillEnemies=function()
 UE.ActorArrayDo(function(Address)
  if not Address or not UE.IsPlayerType(Address) then return end
  local F=UE.ReadTeamName(Address)
  if F=="Team_NPC" or F=="Team_FriendlyToAll" or F=="Team_Player" or F=="OakVehicle" or F==nil then return end
  --This Part Is For Trying To Apply The XP From The Death Of The Enemy, But So Far DOESNT WORK
  writeFloat(Address+0x4318,999999999);
  writeByte(Address+0x431C,1);
  writeInteger(Address+0x4320,0x313D);--DamageType
  --writeByte(Address+0x5B99,6);--Dont Touch
  writePointer(Address+0x4380,UE.LocalPlayer.Pawn);--DamageState.DeathDetails.Instigator
  writePointer(Address+0x4C50,UE.LocalPlayer.Pawn);--KillerActor
  writePointer(Address+0x4310,UE.LocalPlayer.Controller);--DamageState.LastHitByPlayer
  writePointer(Address+0x4378,UE.LocalPlayer.Controller);--DamageState.DeathDetails.InstatedBy
  writePointer(Address+0x4488,UE.LocalPlayer.Controller);--DamageState.LastHitBy
  writePointer(Address+0x3B8,UE.LocalPlayer.Controller);--LastHitBy
  writePointer(Address+0x4388,readPointer(readPointer(UE.LocalPlayer.Pawn+0x5FF0)+0x20));--DamageState.DeathDetails.DamageCauser (Weapon)
  writeInteger(Address+0x1330,2000);
  writeInteger(Address+0x1334,65792+3);
  writeByte(Address+0x61,255);
  writeByte(Address+0x60,255);
  writeByte(Address+0x64,255);
  
  local M=readPointer(Address+UE.Offset.Movement);
  writeByte(M+UE.Offset.MovementMode,0);
  UE.KillPawn(Address,1);
 end);
end FNR("UE.KillEnemies");


 --Best Loot Pools:
 --Char_Creep_Boss_Castilleia_TRUE ->7FF4C90E7E80
 --Char_Creep_Mine_Boss_SkullOrchid_TRUE -> 7FF4C90EA310
 --Char_Thresher_Mine_Boss_SurpriseAttack_TRUE
 --Char_TkBoss_TrueBoss < minimal loot?
 --Char_TkGuard_TrueBoss
 --Char_GunShip_PlotGrass2a_Boss_MeatPlant
UE.EnemyForcedDefinitionName="Char_TkGuard_TrueBoss";
UE.EnemyForcedDefinitionEnabled=false;

UE.SetPawnDefinition=function(Address,DefinitionNameOrAddress)
 if not Address then return end
 local DefAddress=type(DefinitionNameOrAddress)=="string" and UE.FindCharDef(DefinitionNameOrAddress) or DefinitionNameOrAddress;
 local CharacterData=readPointer(Address+ UE.Offset.OakCharacterDef);
 if DefAddress and CharacterData and CharacterData~=DefAddress then
  --writePointer(Address+0x1328,DefAddress );--Shouldnt Be Needed
  writePointer(Address+ UE.Offset.OakCharacterDef,DefAddress );
 end
 --Seems Useleess
 writeByte(Address+ UE.Offset.OakCharacterDef-0x8,50 );
 writeByte(Address+ UE.Offset.OakCharacterDef+0x20,1 );
 writeInteger(CharacterData+0xC78,1);--Spawn Loot On Death?
 writeFloat(CharacterData+0xCBC,0);--Item Spit Speed??? 0.12 (Lower = Faster)
 --local CharacterDataBalance=readPointer(CharacterData+0xCE0)--==Item Balance Ptr
 --writeByte(CharacterData+0x40,0);--Unknown Is Boss Type? 0 (Doesnt Seem To Do Anything)
 --writeInteger(CharacterData+0xCF0,0);--Unknown? 1
end

UE.SetEnemiesDefinition=function()
 local DefAddress=UE.FindCharDef(UE.EnemyForcedDefinitionName);
 UE.ActorArrayDo(function(Address)
  if not Address or not UE.IsPlayerType(Address) then return end
  local F=UE.ReadTeamName(Address)
  if F=="Team_NPC" or F=="Team_FriendlyToAll" or F=="Team_Player" or F=="OakVehicle" or F==nil then return end
  UE.SetPawnDefinition(Address,DefAddress);
 end);
end

UE.ForeachEntityTypeDefinition=function(Do);
 local F=readPointer(UE.LocalPlayer.Pawn+UE.Offset.OakCharacterDef--[[Same As 0x3E80]]);--Player Definition
 local CHQ=readPointer(F);
 if not F or not CHQ then return end
 local S=F;
 local Start,End=0,0;
 while true do
  if readByte(F-0x1000)==nil then
   Start=F;
   break;
  end
  F=F-0x1000;
 end
 F=S;
 while true do
  if readByte(F+0x1000)==nil then
   End=F;
   break;
  end
  F=F+0x1000;
 end
 local AOB=NHA_CE.MemScan(string.format("%X",CHQ),vtQword,"*X*C*W",false,Start,End);
 local I=1;
 for I=1,#AOB,1 do
  F=getAddress(AOB[I]);
  CHQ=Do(I,F,UE.GetName(readInteger(readPointer(F+0x8)+0xC)));
  if CHQ and CHQ==true then
   break;
  end
 end
end  FNR("UE.ForeachEntityTypeDefinition");
--[[UE.ForeachEntityTypeDefinition(function(I,Address,Name)
 print("["..I.."] "..Name.." -> "..string.format("%X",Address));
end)]]

UE.FindCharDef=function(Name)
 if UE.CachedCharDefs==nil then;UE.CachedCharDefs={};end
 local CHQ=UE.CachedCharDefs[Name] and readPointer(UE.CachedCharDefs[Name].Address+0x8) or nil;
 if not CHQ or CHQ~=UE.CachedCharDefs[Name].Check then
  UE.ForeachEntityTypeDefinition(function(I,Address,NameX)
   if NameX==Name then;
    UE.CachedCharDefs[Name]={
     Address=Address,
     Check=ReadPointer(Address+0x8),
    };
    return true;
   end
  end)
 end
 CHQ=UE.CachedCharDefs[Name];
 return CHQ and CHQ.Address or nil;
end FNR("UE.FindCharDef");

local ShouldExclude=function(Check);
 local F=UE.ReadTeamName(Check)
 local F2=F and string.sub(F,1,1) or nil
 if F==nil or (not F2 or (F2~="T" and F2~="O")) then
  return true;
 end
 if UE.TpToCrosshairExcludeNpcs and (F=="Team_NPC" or F=="Team_FriendlyToAll") or false then
  return true;
 end
 if UE.TpToCrosshairExcludePlayers and (F=="Team_Player" or F=="OakVehicle") or false then;
  return true;
 end
 if UE.TpToCrosshairExcludeNonPlayers and (F~="Team_Player" or F~="OakVehicle") or false then;
  return true;
 end
 return false;
end

UE.JumpCountConfig = {
 MaxTicks = 28,
 MaxJumps = 3
};
UE.WorldTickMax=4;

local moveSpeed = 40;
local yaw,pitch,yawRad,pitchRad,MX,MY,MZ,currentJumpCount,lastJumpState=nil;
UE.NoclipFunction=function(Player);
 if Player.Noclip then
  currentJumpCount = readInteger(Player.Pawn+UE.Offset.JumpCurrentCount) or 0
  lastJumpState = Player.LastJumpState or 0
  if not Player.NoclipToggleState and Player.NoclipToggleState==nil then
   Player.NoclipToggleState = "inactive"
   --writeByte(Player.Movement+UE.Offset.MovementMode,1);
   Player.JumpCount = 0
   Player.JumpCountTicks = 0
   Player.AllowedJumpsFromNoclip=false;
  end
  if currentJumpCount > 0 and lastJumpState == 0 then
   Player.JumpCount = Player.JumpCount + 1
   Player.JumpCountTicks = UE.JumpCountConfig.MaxTicks
  -- print("Jump detected for " .. Player.Name .. " - Count: " .. Player.JumpCount)
   if Player.JumpCount >= UE.JumpCountConfig.MaxJumps then
    if Player.NoclipToggleState == "inactive" then
     Player.Noclip_X=readDouble(Player.RootComponent+0x260);
     Player.Noclip_Y=readDouble(Player.RootComponent+0x268);
     Player.Noclip_Z=readDouble(Player.RootComponent+0x270);
     Player.NoclipToggleState = "active"
     --print("Noclip ACTIVATED for player: " .. Player.Name)
    else
     Player.NoclipToggleState = "inactive"
     writeByte(Player.Movement+UE.Offset.MovementMode,1)
     writeInteger(Player.Pawn+UE.Offset.JumpCurrentCount, 0)
     --print("Noclip DEACTIVATED for player: " .. Player.Name)
    end
     Player.JumpCount = 0
     Player.JumpCountTicks = 0
   end
  end
  Player.LastJumpState = currentJumpCount
  if Player.JumpCountTicks > 0 then
   Player.JumpCountTicks = Player.JumpCountTicks - 1
   if Player.JumpCountTicks <= 0 and Player.JumpCount < UE.JumpCountConfig.MaxJumps then
    writeByte(Player.Movement+UE.Offset.MovementMode,3)
    writeInteger(Player.Pawn+UE.Offset.JumpCurrentCount, Player.JumpCount ==1 and 1 or Player.JumpCount+1 )
    --print("Jump count reset for " .. Player.Name .. " (timeout after " .. UE.JumpCountConfig.MaxTicks .. " ticks) "..Player.JumpCount)
    Player.JumpCount = 0
    currentJumpCount=-1;
    Player.AllowedJumpsFromNoclip=false
   end
  elseif readByte(Player.Movement+UE.Offset.MovementMode)==1 then
   Player.AllowedJumpsFromNoclip=true
  end

  if currentJumpCount > 0 and Player.JumpCountTicks > 0 and Player.AllowedJumpsFromNoclip then;
   writeInteger(Player.Pawn+UE.Offset.JumpCurrentCount, 0);
  end
  if Player.NoclipToggleState == "active" then
   if Player.RootComponent then
    yaw = readDouble(Player.Controller+0x410);
    pitch = readDouble(Player.Controller+0x408);
    if yaw and pitch then
     yawRad,pitchRad = math.rad(yaw),math.rad(pitch);
     if readByte(Player.Movement+UE.Offset.bMayWantToGlide) == 1 then
      MX = math.cos(pitchRad) * math.cos(yawRad);
      MY = math.cos(pitchRad) * math.sin(yawRad);
      MZ = math.sin(pitchRad);
      Player.Noclip_X = Player.Noclip_X + (MX * moveSpeed);
      Player.Noclip_Y = Player.Noclip_Y + (MY * moveSpeed);
      Player.Noclip_Z = Player.Noclip_Z + (MZ * moveSpeed);
     end
     Manager=ReadPointer(Player.Pawn+UE.Offset.ActiveWeaponsStateSlots)
     local WantsToExitNoclip = false;
     if Manager then
      Manager=ReadPointer(Manager+UE.Offset.ActiveWeaponSlotPendingWeapon);
      if Manager and Manager~=0 then
       WantsToExitNoclip = true;
      end
     end
     if not Manager or WantsToExitNoclip then
      Player.NoclipToggleState = "inactive"
      Player.JumpCount = 0
      Player.JumpCountTicks = 0
      writeByte(Player.Movement+UE.Offset.MovementMode,1)
      --print("Noclip DEACTIVATED for player: " .. Player.Name)
      return;
     else
      writeDouble(Player.RootComponent+0x260,Player.Noclip_X);
      writeDouble(Player.RootComponent+0x268,Player.Noclip_Y);
      writeDouble(Player.RootComponent+0x270,Player.Noclip_Z);
      writeDouble(Player.RootComponent+0x198,Player.Noclip_X);
      writeDouble(Player.RootComponent+0x1A0,Player.Noclip_Y);
      writeDouble(Player.RootComponent+0x1A8,Player.Noclip_Z);
      writeByte(Player.Movement+UE.Offset.MovementMode,0);
     end
    end
   end
  end
 elseif Player.NoclipToggleState and Player.NoclipToggleState~=nil then
  writeByte(Player.Movement+UE.Offset.MovementMode,1);
  Player.NoclipToggleState=nil;
  Player.JumpCount = 0;
  Player.JumpCountTicks = 0;
 end
end


if not math.round then
math.round = function(n) return n >= 0.0 and n-n%-1 or n-n% 1 end
FNR("math.round")
end

function CalculateCharacterXp(level)
 if level > 0 and level <= 10 then
  local hardcoded = {0, 857, 1740, 3349, 5875, 9496, 14385, 20707, 28625, 38297};
  return hardcoded[level];
 end
 local base =
  20.43597 * math.pow(level, 3) +
  445.42202 * math.pow(level, 2) +
  -5301.02934 * level +
  27953.516161;
 -- Safety margin: 1.8%
 return math.round(base * 1.018);
end

-- Hardcoded XP for levels 1-10
CalculateSpecializationXp_Hardcoded = {
 [1]=0,[2]=1143,[3]=2320,[4]=4466,[5]=7834,[6]=12662,[7]=19180,[8]=27609,[9]=38167,[10]=51062
 }

-- segments: {minLevel, maxLevel, coefficients {a, b, c, d}, safetyMargin}
CalculateSpecializationXp_Segments = {
 {11, 31, {83.390778, -2314.676389, 41061.771085, -216525.913214}, 1.018},
 {32, 200, {20.903278, 1701.31766, -74334.753724, 1403361.683375}, 1.026},
 {201, 499, {16.708444, 4297.272805, -645890.804295, 46158303.367444}, 1.0001},
 {500, math.huge, {14.960904, 6708.446543, -1773218.961259, 224787945.740717}, 1.00001}
 }

function CalculateSpecializationXp(level)
 level = level or 0
 if level <= 0 then return 0 end
 if CalculateSpecializationXp_Hardcoded[level] then return CalculateSpecializationXp_Hardcoded[level] end

 for _, seg in ipairs(CalculateSpecializationXp_Segments) do
  if level >= seg[1] and level <= seg[2] then
   local c = seg[3]
   local base = c[1] * level^3 + c[2] * level^2 + c[3] * level + c[4]
   return math.round(base * seg[4])
  end
 end

 return 0
end

UE.TimerFunctions.Remove("PlayerModsUpdate");
local D,P,A,B,C,E,F,M,N,RC,Manager,Manager2,Player,WorldTick,XP=nil;
WorldTick=-1;
UE.TimerFunctions.Add("PlayerModsUpdate",function()
 if not UE.MainUpdateEnabled then;return;end;
 for D=1,#UE.PlayerCache,1 do;
  Player=UE.PlayerCache[D];
  if Player and Player.Pawn then
   P=Player.Pawn;
   C=Player.Controller;
   M=Player.Movement;
   RC=Player.RootComponent;
   if P and C and M and RC then;
    Player.DrivingVehicle=  readByte(Player.State+UE.Offset.bDrivingVehicle)==1 and true or false;
    Player.VehicleAddress=Player.DrivingVehicle and readPointer(C+UE.Offset.PawnUntrusted) or nil;

    if Player.VehicleBoostHack and Player.DrivingVehicle==true then
     if Player.VehicleBoostAddress==nil or ReadPointer(Player.VehicleBoostAddress+0x10)~=Player.VehicleBoostCheck then
      UE.PawnResourcePoolsDo(P,function(B,C,N)
       if N=="Vehicle_Boost" then
        Player.VehicleBoostAddress=C;
        Player.VehicleBoostCheck=ReadPointer(Player.VehicleBoostAddress+0x10)
       end
      end);
     else
      writeFloat(Player.VehicleBoostAddress+0xC8,100);
     end
    end


    if Player.EnableHackedJumpGoalDef then
     local JGD=Player.Movement+UE.Offset.CurrentJump_JumpGoal;
     WriteBytes( Player.HackedJumpGoalDef,ReadBytes(ReadPointer(JGD),0x18,true));
     WriteQword(JGD ,Player.HackedJumpGoalDef);
    end
    
    if Player.Freeze then
     if Player.Noclip and Player.NoclipToggleState~="inactive" then
      Player.NoclipToggleState = "inactive"
      writeByte(Player.Movement+UE.Offset.MovementMode,1)
      writeInteger(Player.Pawn+UE.Offset.JumpCurrentCount, 0)
     end
     writeDouble(RC+0x260,Player.FreezeXYZ[1]);
     writeDouble(RC+0x268,Player.FreezeXYZ[2]);
     writeDouble(RC+0x270,Player.FreezeXYZ[3]);
     writeDouble(RC+0x198,Player.FreezeXYZ[1]);
     writeDouble(RC+0x1A0,Player.FreezeXYZ[2]);
     writeDouble(RC+0x1A8,Player.FreezeXYZ[3]);
     Player.WasFreeze=true;
     writeByte(M+UE.Offset.MovementMode,0);
    elseif Player.WasFreeze then
    Player.WasFreeze=nil;
     writeByte(M+UE.Offset.MovementMode,1);
    end

    if Player.SuperJump and Player.DrivingVehicle==false then
     Player.SuperJumpWasEnabled=true;
     if not Player.Noclip then;writeInteger(P+UE.Offset.JumpCurrentCount,0);end
     writeFloat(M+UE.Offset.GravityScale,0.5);
     writeFloat(M+UE.Offset.AirControl,2)
     writeFloat(M+UE.Offset.VaultPowerCost_Glide,0)
    elseif Player.SuperJumpWasEnabled and Player.SuperJumpWasEnabled~=nil then
     Player.SuperJumpWasEnabled=nil;
     M=readPointer(P+UE.Offset.Movement);
     writeFloat(M+UE.Offset.GravityScale,1);
     writeFloat(M+UE.Offset.AirControl,0.6000000238)
     writeFloat(M+UE.Offset.VaultPowerCost_Glide,15)
    end
   
    if Player.SuperSpeed and Player.DrivingVehicle==false then
     Player.SuperSpeedWasEnabled=true;
     writeFloat(M+UE.Offset.MaxGroundSpeedScale,10);
     writeFloat(M+UE.Offset.MaxWalkSpeed,1500);
     writeFloat(M+UE.Offset.MaxWalkSpeedCrouched,800)
     writeFloat(M+UE.Offset.MaxSwimSpeed,800)
     writeFloat(M+UE.Offset.MaxAcceleration,9048)
     writeFloat(M+UE.Offset.VaultPowerCost_Dash+4,0)
     writeFloat(M+UE.Offset.WalkableFloorAngle,85)
     writeFloat(M+UE.Offset.WalkableFloorZ,0.5)
     writeFloat(M+UE.Offset.MaxStepHeight,70)
    elseif Player.SuperSpeedWasEnabled and Player.SuperSpeedWasEnabled~=nil then
     Player.SuperSpeedWasEnabled=nil;
     writeFloat(M+UE.Offset.MaxGroundSpeedScale,1);
     writeFloat(M+UE.Offset.MaxWalkSpeed,600);
     writeFloat(M+UE.Offset.MaxWalkSpeedCrouched,300)
     writeFloat(M+UE.Offset.MaxSwimSpeed,300)
     writeFloat(M+UE.Offset.MaxAcceleration,2048)
     writeFloat(M+UE.Offset.VaultPowerCost_Dash+4,15)
     writeFloat(M+UE.Offset.WalkableFloorAngle,44.76508331)
     writeFloat(M+UE.Offset.WalkableFloorZ,0.7099999785)
     writeFloat(M+UE.Offset.MaxStepHeight,45)
    end

    if Player.WalkUnderWater and Player.DrivingVehicle==false then
     if not Player.WalkUnderWaterTicks then
      Player.WalkUnderWaterTicks = 0
     end
     if readByte(M+UE.Offset.MovementMode)==6 or readByte(M+0x1EA0)==1 then
      WriteByte(M+UE.Offset.WantsToCrouch,64);
      Player.WalkUnderWaterTicks = 0
     elseif Player.WalkUnderWaterTicks < 10 then
      WriteByte(M+UE.Offset.WantsToCrouch,64);
      Player.WalkUnderWaterTicks = Player.WalkUnderWaterTicks + 1
     end
     Player.WalkUnderWaterWasEnabled = true;
    elseif Player.WalkUnderWaterWasEnabled and Player.WalkUnderWaterWasEnabled~=nil then
     Player.WalkUnderWaterWasEnabled=nil;
     Player.WalkUnderWaterTicks = nil;
     if readByte(M+UE.Offset.MovementMode)==6 or readByte(M+0x1EA0)==1 then;WriteByte(M+UE.Offset.WantsToCrouch,0);end
    end

    if WorldTick==0 then
     if Player.GodMode then
      F=readByte(P+UE.Offset.bCanBeDamaged);
      if F==100 then
       F=F & -8;
       Player.GodModeWasEnabled=true;
       WriteByte(P+UE.Offset.bCanBeDamaged,F);
      end
     elseif Player.GodModeWasEnabled and Player.GodModeWasEnabled~=nil then
      Player.GodModeWasEnabled=nil;
      WriteByte(P+UE.Offset.bCanBeDamaged,100);
     end 

     if Player.InventoryIncrease then
      Player.InventoryWasIncrease=true;
      writeInteger(Player.State+0x924,2147483647);
      writeInteger(Player.State+0xBB4,2147483647);
     elseif Player.InventoryWasIncrease and Player.InventoryWasIncrease~=nil then
      Player.InventoryWasIncrease=nil;
      writeInteger(Player.State+0x924,readInteger(Player.State+0x924));
      writeInteger(Player.State+0xBB4,readInteger(Player.State+0xBB4));
     end

     if Player.InfinateAmmo then
      Player.InfinateAmmoWasEnabled=true;
      writeByte(C+UE.Offset.InfinateClipLock,1);
     elseif Player.InfinateAmmoWasEnabled and Player.InfinateAmmoWasEnabled~=nil then
      Player.InfinateAmmoWasEnabled=nil;
      writeByte(C+UE.Offset.InfinateClipLock,0);
     end

     if Player.MaxDamage then
      Player.MaxDamageWasEnabled=true;
      WriteFloat(P+UE.Offset.DamageCauserData+UE.Offset.DamageDealtMultiplier+4,9999999999);
      writeByte(P+UE.Offset.CanUseWeaponWhileSprinting+4,1);
      writeByte(P+UE.Offset.CanZoomWhileSprinting+4,1);
     elseif Player.MaxDamageWasEnabled and Player.MaxDamageWasEnabled~=nil then
      Player.MaxDamageWasEnabled=nil;
      WriteFloat(P+UE.Offset.DamageCauserData+UE.Offset.DamageDealtMultiplier+4,1);
      writeByte(P+UE.Offset.CanUseWeaponWhileSprinting+4,0);
      writeByte(P+UE.Offset.CanZoomWhileSprinting+4,0);
     end

    end
    
    if Player.MaxMoney then
     Manager=readPointer(C+UE.Offset.CurrencyManager);
     if Manager then;
      Manager2=readInteger(Manager+UE.Offset.currencies+0x8);
      Manager=readPointer(Manager+UE.Offset.currencies);
      if Manager then;
       local _,_2=0,UE.Offset.CurrencysMax;
       for _=0,Manager2-1,1 do
        writeInteger(Manager+(_2*_)+UE.Offset.GbxCurrencyAmount,999999999);
       end
      end
     end
    end

    if Player.LevelUp then
     XP=readPointer(P+0x168);
     if XP then;
      XP=readPointer(XP+0x398);
      if XP then;
       XP=readPointer(XP+0x6C0);
       if XP then;
        local NXP=ReadQword(XP+0x20);
        if ReadQword(XP+0x8)<NXP-1 then
         WriteQword(XP+0x8,NXP-1);
        end
       end;
      end;
     end;
    end

    if Player.LevelUpSpecialization then
     XP=readPointer(P+0x168);
     if XP then;
      XP=readPointer(XP+0x398);
      if XP then;
       XP=readPointer(XP+0x6C0);
       if XP then;
        local NXP=ReadQword(XP+0x80);
        if ReadQword(XP+0x68)<NXP-1 then
         WriteQword(XP+0x68,NXP-1);
        end
       end;
      end;
     end;
    end
        
    UE.NoclipFunction(Player);
   end;
  end;
 end;
 if WorldTick==0 then
  local _KillAllEnemies= UE.KillAllEnemies;
  local _EnemyForcedDefinitionEnabled= UE.EnemyForcedDefinitionEnabled;
  local DefAddress=_EnemyForcedDefinitionEnabled and UE.FindCharDef(UE.EnemyForcedDefinitionName) or nil;
  local _TpToCrosshairEnabled=UE.TpToCrosshairEnabled;
  if _TpToCrosshairEnabled and UE.TpToCrosshairStopTracking==false then
   LocalPlayerX,LocalPlayerY,LocalPlayerZ=
   readDouble(UE.LocalPlayer.RootComponent+0x260),
   readDouble(UE.LocalPlayer.RootComponent+0x268),
   readDouble(UE.LocalPlayer.RootComponent+0x270);
   yaw = readDouble(UE.LocalPlayer.Controller+0x410);
   pitch = readDouble(UE.LocalPlayer.Controller+0x408);
   if yaw and pitch then
    yawRad,pitchRad = math.rad(yaw),math.rad(pitch);
    MX = math.cos(pitchRad) * math.cos(yawRad);
    MY = math.cos(pitchRad) * math.sin(yawRad);
    MZ = math.sin(pitchRad);
    crosshairX = LocalPlayerX + (MX * UE.TpToCrosshairDistance);
    crosshairY = LocalPlayerY + (MY * UE.TpToCrosshairDistance);
    crosshairZ = LocalPlayerZ + (MZ * UE.TpToCrosshairDistance);
   end 
  end
  if _EnemyForcedDefinitionEnabled or _KillAllEnemies or _TpToCrosshairEnabled then
   UE.ActorArrayDo(function(Address)
   if not Address or not UE.IsPlayerType(Address) then return end
    local F=UE.ReadTeamName(Address)
    if F=="Team_NPC" or F=="Team_FriendlyToAll" or F=="Team_Player" or F=="OakVehicle" or F==nil then
     return;
    end
    if _TpToCrosshairEnabled and not ShouldExclude(Address) then
     E=readPointer(Address+UE.Offset.RootComponent);
     if E then
      M=readPointer(Address+UE.Offset.Movement);
      N=readByte(M+UE.Offset.MovementMode);
      if N==0 then;
       writeByte(M+UE.Offset.MovementMode,readByte(M+UE.Offset.MovementMode+1));
       writeByte(M+UE.Offset.MovementMode+1,0)
      else
       writeByte(M+UE.Offset.MovementMode,0);
       writeDouble(E+0x260,crosshairX);
       writeDouble(E+0x268,crosshairY);
       writeDouble(E+0x270,crosshairZ+0.9);
       writeByte(M+UE.Offset.MovementMode+1,N);
      end
     end
    end
    if _EnemyForcedDefinitionEnabled and DefAddress then
     UE.SetPawnDefinition(Address,DefAddress);
    end
    if _KillAllEnemies then
     UE.KillPawn(Address,1);
    end
   end);
  end

  if UE.ForcedRarityModifiers then
   Manager = UE.GameState;
   UE.ForcedRarityModifiersWasEnabled=true;
   if Manager and Manager ~= 0 then
    writeFloat(Manager + UE.Offset.RarityState_CommonModifier, UE.ForcedCommonModifier);
    writeFloat(Manager + UE.Offset.RarityState_UnCommonModifier, UE.ForcedUnCommonModifier);
    writeFloat(Manager + UE.Offset.RarityState_RareModifier, UE.ForcedRareModifier);
    writeFloat(Manager + UE.Offset.RarityState_VeryRareModifier, UE.ForcedVeryRareModifier);
    writeFloat(Manager + UE.Offset.RarityState_LegendaryModifier, UE.ForcedLegendaryModifier);
   end
  elseif UE.ForcedRarityModifiersWasEnabled then--Reset
   UE.ForcedRarityModifiersWasEnabled=nil;
   Manager = UE.GameState;
   if Manager and Manager ~= 0 then
    writeFloat(Manager + UE.Offset.RarityState_CommonModifier, readFloat(Manager + UE.Offset.RarityState_CommonModifier-0x4));
    writeFloat(Manager + UE.Offset.RarityState_UnCommonModifier, readFloat(Manager + UE.Offset.RarityState_UnCommonModifier-0x4));
    writeFloat(Manager + UE.Offset.RarityState_RareModifier, readFloat(Manager + UE.Offset.RarityState_RareModifier-0x4));
    writeFloat(Manager + UE.Offset.RarityState_VeryRareModifier, readFloat(Manager + UE.Offset.RarityState_VeryRareModifier-0x4));
    writeFloat(Manager + UE.Offset.RarityState_LegendaryModifier, readFloat(Manager + UE.Offset.RarityState_LegendaryModifier-0x4));
   end
  end
 end
 if WorldTick<=0 then
  WorldTick=UE.WorldTickMax;
 else
  WorldTick=WorldTick-1;
 end
end);


UE.ArrayAlgo=function(BaseAddress,ArrayOffset,CountOffset,StructureSize,AlgoFunction);
 local Base = type(BaseAddress)=="string" and getAddressSafe(BaseAddress) or BaseAddress
 if Base then
  local CountCur = readInteger(Base + CountOffset)
  local Memory = readPointer(Base + ArrayOffset);
  if CountCur and CountCur > 0 and Memory then
   local C=0;
   for C = 0, CountCur - 1, 1 do
    local Entry = Memory+(C* StructureSize);
    if AlgoFunction(Entry,C) then;break;end;
    end
  end
 end
end;FNR("UE.ArrayAlgo");
 
UE.ExtendedArrayRestoreData = {};
UE.ExtendedArrayRestore = function()
 if UE.ExtendedArrayRestoreData and #UE.ExtendedArrayRestoreData > 0 then
  local restoredCount = 0;
  for I = 1, #UE.ExtendedArrayRestoreData do
   local V = UE.ExtendedArrayRestoreData[I];
   if V and V.BaseAddress and V.OriginalPointer then
    local Fake=readPointer(V.BaseAddress + V.DataOffset);
    writePointer(V.BaseAddress + V.DataOffset, V.OriginalPointer);
    writeInteger(V.BaseAddress + V.CountOffset, V.OriginalCount);
    writeInteger(V.BaseAddress + V.MaxOffset, V.OriginalMax);
    --deAlloc(Fake);
    restoredCount = restoredCount + 1;
   end
  end
  if restoredCount > 0 then
   print("Extended Array Memory Restored: " .. restoredCount .. " entries.");
  end
  UE.ExtendedArrayRestoreData = {};
 else
  print("No Extended Array data to restore.");
 end
end  FNR("UE.ExtendedArrayRestore");

UE.ExtendMemoryArray = function(BaseAddress, DataOffset, CountOffset, MaxOffset, OFFSET, InputMaxAllocateCount, ForeachEntry, ToAllocateCount)
  local Base = type(BaseAddress) == "string" and getAddressSafe(BaseAddress) or BaseAddress
  ToAllocateCount = ToAllocateCount or 1
  if Base then
   local MaxAllocateCount = InputMaxAllocateCount or 1000;
   local alignedSize = ((MaxAllocateCount * OFFSET + 15) // 16) * 16
   local CountCur = readInteger(Base + CountOffset)
   if CountCur and CountCur > 0 then
    if CountCur + ToAllocateCount >= MaxAllocateCount then
     print("Max Entries For New Memory")
     return false
    end
    local MaxCur = readInteger(Base + MaxOffset)
    local OldMemory = readPointer(Base + DataOffset)
    local NHAMEM = readInteger(OldMemory + alignedSize - 0x4) == 0x41484E
    printf("OldMemory: %X, Count: %i, Max: %i", OldMemory, CountCur, MaxCur)
    local NewMemory
    if NHAMEM then
     NewMemory = OldMemory
    else
     local restoreEntry = {
      BaseAddress = Base,
      DataOffset = DataOffset,
      CountOffset = CountOffset,
      MaxOffset = MaxOffset,
      OriginalPointer = OldMemory,
      OriginalCount = CountCur,
      OriginalMax = MaxCur,
      OFFSET = OFFSET,
      Timestamp = os.time()
     };
     UE.ExtendedArrayRestoreData[#UE.ExtendedArrayRestoreData + 1] = restoreEntry;
     NewMemory = AllocateMemory(alignedSize, OldMemory)
     if not NewMemory then
      NewMemory = AllocateMemory(alignedSize)
      if not NewMemory then
       print("Failed to allocate memory")
       return false
      end
      print("Allocated using failsafe!")
     end
     restoreEntry.NewMemory = NewMemory;
     createTimer(50, UE.SafeParts.Hijack);
     writeInteger(NewMemory +alignedSize- 0x4, "NHA")
     local existingData = readBytes(OldMemory, OFFSET * CountCur, true)
     WriteBytes(NewMemory, existingData)
     print("NewMemory Pointer Written To Base Address")
     writePointer(Base + DataOffset, NewMemory)
     --writePointer(NewMemory +alignedSize- (0x8+0x4), OldMemory);
    end
    local templateBytes = readBytes(NewMemory, OFFSET, true)
    for C = 0, ToAllocateCount - 1, 1 do
     local newEntryOffset = (CountCur + C) * OFFSET
     if newEntryOffset + OFFSET <= MaxAllocateCount * OFFSET then
      WriteBytes(NewMemory + newEntryOffset, templateBytes)
      if ForeachEntry then
       ForeachEntry(NewMemory + newEntryOffset, CountCur + C, NewMemory);
      end
     else
      print("Would exceed allocated memory, stopping at entry " .. C)
      ToAllocateCount = C
      break
     end
    end
    local newCount = CountCur + ToAllocateCount
    local newMax = math.max(MaxCur, newCount)
    writeInteger(Base + CountOffset, newCount)
    writeInteger(Base + MaxOffset, newMax)
    printf("NewMemory: %X, Count: %i, Max: %i", NewMemory, newCount, newMax)
    return true
   else
    print("Invalid or zero CountCur")
    return false
   end
  else
   print("Base address not found")
   return false
  end
end FNR("UE.ExtendMemoryArray");

UE.GbxItemContainerSlotCopyTo=function(FromAddress,ToAddress,ArrayOffset)
 if not FromAddress or not ToAddress or not ArrayOffset or not UE.Offset.GbxItemContainerSlotEndCount then;return;end
 UE.ExtendMemoryArray(ToAddress,ArrayOffset,ArrayOffset+8,ArrayOffset+12,UE.Offset.GbxItemContainerSlotEndCount,1500,function(A,C)
  writeBytes(A,readBytes(FromAddress,UE.Offset.GbxItemContainerSlotEndCount,true));
  writeInteger(A,C+1);
  writeInteger(A+UE.Offset.GbxItemData_InstanceId,C+1);
  writeInteger(A+UE.Offset.InventoryItem_Handle,C+1);
  writeByte(A+UE.Offset.InventoryItem_EquipSlot,255);
  local Str=readString(readPointer(M+UE.Offset.InventoryIdentity_PartString),1000);
  local ST_=AllocateMemory(1000);
  writePointer(A+UE.Offset.InventoryIdentity_PartString,ST_);
  writeString(ST_,Str);
 end);
end FNR("UE.GbxItemContainerSlotCopyTo");

UE.CopyActiveWeaponFromPlayerState=function(FromAddress,ToAddress);
 local ArrayOffset=(UE.Offset.OakPlayerStateBackpackItemsOffset and UE.Offset.GbxItemSlotsContainerItemsOffset) and (UE.Offset.OakPlayerStateBackpackItemsOffset+UE.Offset.GbxItemSlotsContainerItemsOffset) or nil;
 if not UE.ArrayAlgo or not FromAddress or not ArrayOffset or not UE.Offset.GbxItemContainerSlotEndCount then;return;end
 local IActiveSlot=readInteger(FromAddress+UE.GetOffsetBySymbol("OakPlayerState.ActiveWeaponEquipSlot"));
 local ActiveMemory=nil;
 UE.ArrayAlgo(FromAddress,ArrayOffset,ArrayOffset+8,UE.Offset.GbxItemContainerSlotEndCount,function(A,C)
  if readByte(A+UE.Offset.InventoryItem_EquipSlot)==IActiveSlot then
   ActiveMemory=A;
   return true;
  end
  return false;
 end);
 if not ActiveMemory then;
  print("Failed To Find The Users Active Weapon!");
  return;
 end
 UE.GbxItemContainerSlotCopyTo(ActiveMemory,ToAddress,ArrayOffset);
 print("Successfully Duped That Players Weapon From Slot: "..IActiveSlot);
end FNR("UE.CopyActiveWeaponFromPlayerState");


UE.SafeParts={
 MemoryStart=nil,
 MemoryEnd=nil,
 Size=600*100,
 Offset=0,
 Restore={},
};
UE.SafeParts.ArrayRestore=function()--Call This After The Game Serializes To Restore All The Old Pointers
 if UE.SafeParts.Restore and #UE.SafeParts.Restore>0 then;
  local I=0;
  for I=1,#UE.SafeParts.Restore do
   local V=UE.SafeParts.Restore[I];
   if V and V.Pointed and V.Address then
    writePointer(V.Address,V.Pointed);
    writeInteger(V.Address+0x10,V.Size);
   end
  end
  local CHQ=UE.SafeParts.MemoryStart and readInteger(UE.SafeParts.MemoryStart) or nil;
  if not CHQ or CHQ~=0x41484E then;
   print("Safe Parts Memory Was Validated To Be Unknown. Deallocating...");
   UE.SafeParts.MemoryStart=nil;UE.SafeParts.MemoryEnd=nil;UE.SafeParts.Offset=0;UE.SafeParts.Restore={};
  elseif #UE.SafeParts.Restore>0 then--Clear
   print("Safe Parts Memory Was Cleared. Restored " .. #UE.SafeParts.Restore .. " entries.");
   UE.SafeParts.MemoryStart=nil;
   UE.SafeParts.MemoryEnd=nil;
   UE.SafeParts.Offset=0;
   UE.SafeParts.Restore={};
  end
 end
end

UE.SafeParts.Hijack=function();
 local A=getAddressSafe("SafeSpaceReload")
 if A and readByte(A) and ReadByte(A)==0x48 and ReadByte(A+1)==0x81 and ReadByte(A+2)==0xC1 and ReadByte(A+0xF)~=0xE8 then;
  return;
 end
 ---SHHH Dont Tell Gearbox About This One
 local AOB=NHA_CE.MemScan("48 81 C1 ?? ?? ?? 00 48 8D 94 24 ?? ?? 00 00 E? ?? ?? ?? ?? 48 8D 9C 24",vtByteArray,"*X*C*W",true,CodebaseStart,CodebaseStop);
 if not AOB then;
  print("Failed To Hook Safe Parts Deallocator");
  return;
 end
 AOB=AOB+0xF;
 local Address=UE.ReadX64R(AOB,1);
 registerSymbol("SafeSpaceReloadCall",Address);
 --RDX == GameState?
 --RDI == PlayerState
 --R9 == LastItem?
 --R11 == LastItem Another Address?
 --R13 == Player Equipment?
 autoAssemble([[
  aobscanmodule(SafeSpaceReload,Borderlands4.exe,48 81 C1 ?? ?? ?? 00 48 8D 94 24 ?? ?? 00 00 E? ?? ?? ?? ?? 48 8D 9C 24)
  alloc(SafeSpaceHook,$1000,$process)
  label(return SafeSpaceReloadHit HERE)
  SafeSpaceHook:
  mov [SafeSpaceReloadHit],1
  HERE:
  cmp [SafeSpaceReloadHit],1
  je HERE
  call SafeSpaceReloadCall
  jmp return
  
  SafeSpaceReloadHit:
  dq 0
  SafeSpaceReload+F:
  jmp SafeSpaceHook
  return:
  registersymbol(SafeSpaceHook SafeSpaceReload SafeSpaceReloadHit)
 ]]);
 print("Safe Space Crash Fix Enabled");
 UE.TimerFunctions.Remove("SafeSpaceChecker");
 local SafeSpaceReloadHit=0;
 UE.TimerFunctions.Add("SafeSpaceChecker",function()
  if not SafeSpaceReloadHit or SafeSpaceReloadHit==0 then;SafeSpaceReloadHit=getAddressSafe("SafeSpaceReloadHit");end
  if not SafeSpaceReloadHit or SafeSpaceReloadHit==0 then;return;end
  local S=readByte(SafeSpaceReloadHit);
  if S==nil then
   UE.SafeParts.DeHijack();
  end
  if S==1 then
   UE.SafeParts.ArrayRestore();
   --UE.ExtendedArrayRestore();
   writeByte(SafeSpaceReloadHit,0);
  end
 end);
end

UE.SafeParts.DeHijack=function();
 autoAssemble([[
  SafeSpaceReload+F:
  call Borderlands4.exe+95E4210
  dealloc(SafeSpaceHook)
  unregistersymbol(SafeSpaceReload SafeSpaceReloadRax SafeSpaceHook)
 ]]);
 UE.TimerFunctions.Remove("SafeSpaceChecker");
 print("Safe Space Crash Fix Disabled");
end

UE.SafeEditPartString=function(PointerToParts,NewString,Unicode);
 local Size=Unicode and (((#NewString+1)*2)+2) or (#NewString+2);
 local PartsMemory=readPointer(PointerToParts);
 if UE.SafeParts.MemoryStart then;
  local CHQ=readInteger(UE.SafeParts.MemoryStart);
  if not CHQ or CHQ~=0x41484E then;
   print("Safe Parts Memory Was Validated To Be Unknown. Deallocating...");
   UE.SafeParts.MemoryStart=nil;UE.SafeParts.MemoryEnd=nil;UE.SafeParts.Offset=0;UE.SafeParts.Restore={};
  end
 end
 if not UE.SafeParts.MemoryStart then;
  print("Safe Parts Memory Was Not Allocated, Allocating....");
  UE.SafeParts.MemoryStart=AllocateMemory(UE.SafeParts.MemorySize);--Big Memory For Loads Of Strings
  UE.SafeParts.MemoryEnd=UE.SafeParts.MemoryStart+UE.SafeParts.MemorySize;
  writeInteger(UE.SafeParts.MemoryStart,0x41484E);--Mark It As Our Memory
  UE.SafeParts.Offset=4;UE.SafeParts.Restore={};
  createTimer(50, UE.SafeParts.Hijack);
 end
 if PartsMemory>=UE.SafeParts.MemoryStart and PartsMemory<UE.SafeParts.MemoryEnd and readSmallInteger(PartsMemory-0x2)<=Size then;
   writeString(PartsMemory,NewString,Unicode);
   writeInteger(PointerToParts+0x10,Size);
   return true;
 else
  local FakeMemory=UE.SafeParts.MemoryStart+UE.SafeParts.Offset;
  writeSmallInteger(FakeMemory,Size);FakeMemory=FakeMemory+2;
  if not (PartsMemory>=UE.SafeParts.MemoryStart and PartsMemory<UE.SafeParts.MemoryEnd) then
  UE.SafeParts.Restore[#UE.SafeParts.Restore+1]={OriginalString=readString(PartsMemory,1000,Unicode),Size=Size,Address=PointerToParts,Pointed=PartsMemory};
  end
  writePointer(PointerToParts,FakeMemory);
  writeString(FakeMemory,NewString,Unicode);
  writeInteger(PointerToParts+0x10,Size);
  UE.SafeParts.Offset=UE.SafeParts.Offset+Size+2
  return true;
 end
end


--Challenge Manager:
--+0xB8 = Array Of Challenges
--+0xC0 = Count

--ArrayOfChallenges Structure:
--+0x0 = Pointer To Challenge Definition

--Challenge Definition:
--+0x20]+0x8]+0xC FNAME = Pointer To Challenge Name String

--UE.Offset.OakChallengeManager=UE.GetOffsetBySymbol("OakPlayerController.OakChallengeManager");
ForeachChallengeInManager=function(Player,Func);
 local Manager=readPointer(Player+UE.Offset.OakChallengeManager)
 local Array,Count,J,K,BaseAddress,Address,Name,Description,DescriptionSize,FullDescription,FullDescriptionOld,FullDescriptionSize,Tst=readPointer(Manager+0xB8),readInteger(Manager+0xC0),0,0,0,0,0,0,0,0,0,0,0;
 for J=0,Count-1,1 do
  BaseAddress=readPointer(Array+(J*0x8));
  K=0;
  while true do
   Address=readPointer(BaseAddress+(K*0x20));
   if not Address then;break;end
   K=K+1;
   Tst=readPointer(Address+0x8);
   if not Tst then;break;end
   Tst=readInteger(Tst+0xC);
   if not Tst then;break;end
   Name=UE.GetName(Tst);
   if not Name or not UE.IsValidString(Name) then;break;end

   Description=ReadPointer(Address+0x18);
   if not Description then;break;end
   DescriptionSize=readInteger(Description+0x24);
   Description=ReadPointer(Description+0x18);
   if not Description then;break;end
   Description=readString(Description,(DescriptionSize*2),true);
   if Description==nil or Description=="" then
    Description="?";
   end;

   FullDescription=ReadPointer(Address+0x118);
   if not FullDescription then;break;end
   FullDescriptionSize=readInteger(FullDescription+0x84);
   FullDescription=ReadPointer(FullDescription+0x78);
   if FullDescription and FullDescriptionSize then
     FullDescription=readString(FullDescription,(FullDescriptionSize*2),true);
   end
   if not FullDescription then;
    FullDescription="?";
   end
   FullDescriptionOld=FullDescription;
   
   FullDescription=ReadPointer(Address+0x118);
   if not FullDescription then;break;end
   FullDescription=ReadPointer(FullDescription+0x88);

   FullDescriptionSize=readInteger(FullDescription+0x14);
   FullDescription=ReadPointer(FullDescription+0x8);
   if FullDescription and FullDescriptionSize then
     FullDescription=readString(FullDescription,(FullDescriptionSize*2),true);
   end
   if not FullDescription then;
    FullDescription="?";
   end

   if FullDescription==Name or FullDescription=="?" or FullDescription=="Acquired" then
    FullDescription=FullDescriptionOld;
   end
   Func(BaseAddress,Address,Name,Description,FullDescription);
  end
 end
end FNR("ForeachChallengeInManager");


DumpChallenges=function();
  local startTime = os.clock()
  local filename="challenges_dump.txt";
    local file = io.open(filename, "w")
    if not file then
     print("Error: Could not create " .. filename)
     return false
    end
    file:write("Challenge Dump By: dr NHA @" .. os.date() .. "\n")
ForeachChallengeInManager(UE.LocalPlayer.Controller,function(BaseAddress,Address,Name,Description,FullDescription)
Description=Description=="?" and "" or ", "..Description;
FullDescription=FullDescription=="?" and "" or ", "..FullDescription;
file:write(string.format("0x%X",Address)..", ".. Name..Description..FullDescription.."\n")
end);
file:close()
print("Challenge Dump Completed In " .. (os.clock() - startTime) .. " Seconds. Saved To " .. filename)
end
FNR("DumpChallenges");
