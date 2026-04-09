--UE Dumper And Library Written By: dr NHA
 if UE==nil then;
  UE={
   FoundFinished=false,
   Constant = {
    oClassName = 0x18,
    oClass=0x10,
    oSuper=0x40,
    oOuter=0x20,
    oChildren =0x50,
    oNext=0x18,
    oNext2=0x48,
    oEnumEndCount=0x48,
    oEndCount=0x58,
    oStartCount=0x44,
   },
   Offset={
    GameInstance,LocalPlayers,PlayerController,PlayerState,bCanBeDamaged,GameViewport,World,GameState,PlayerArray,PlayerNamePrivate,Owner,Pawn,RootComponent,Movement,JumpCurrentCount,GravityScale,WalkableFloorAngle,WalkableFloorZ,MaxStepHeight,AirControl,MaxWalkSpeed,MaxWalkSpeedCrouched,MaxSwimSpeed,MaxAcceleration,
   },
   LocalPlayer={
    Controller=0,
    Pawn=0,
    State=0,
    RootComponent=0,
    Index=0,
   },
   FNamePool=0,
   UObjectArray=0,
   GEngine=0,
   GameInstance=0,
   GameViewport=0,
   World=0,
   GameState=0,
   Level=0,
   ObjectChunks=0,
   ObjectChunksCount=0,
   ObjectChunksArray={},
   ObjectsCount=0,
   GlobalNameCache={},
   CoreUObjectVFTable=nil,
   PlayerClassTypes={},
   StructureSizeCache={},
  };FNR("UE");
  do;--Player Cache Setup
   UE.PlayerNameCache={};
   UE.PlayerCache={};
   UE.InitializePlayerToCache=function(name)
    I=#UE.PlayerCache+1;
    UE.PlayerCache[I]={
     Index=I,
     Name=name,
     PlayerStateAddress=0,
     };
     if UE.PlayerDataInitialize then;UE.PlayerDataInitialize(UE.PlayerCache[I]);end;
    UE.PlayerNameCache[name]=I;
    end
   
   UE.RemovePlayerFromCache = function(playerName)
    local index = UE.PlayerNameCache[playerName]
    if index then
     UE.PlayerCache[index] = nil
     UE.PlayerNameCache[playerName] = nil
     local newCache = {}
     local newNameCache = {}
     local newIndex = 1
     for i, player in pairs(UE.PlayerCache) do
      if player then
       newCache[newIndex] = player
       newNameCache[player.Name] = newIndex
       newIndex = newIndex + 1
      end
     end
    UE.PlayerCache = newCache
    UE.PlayerNameCache = newNameCache
    return true
    end
    return false
    end
   
   UE.GetPlayerFromCache = function(playerName)
    local index = UE.PlayerNameCache[playerName]
    if index and UE.PlayerCache[index] then
     return UE.PlayerCache[index], index
    else
     UE.InitializePlayerToCache(playerName)
     local newIndex = #UE.PlayerCache
     return UE.PlayerCache[newIndex], newIndex
    end;end
   
   UE.ClearPlayerCache = function()
    if #UE.PlayerNameCache>0  then
     UE.PlayerNameCache={};
     UE.PlayerCache={};
    end;
   end;
  end
  do;--Timer Setup
   UE.TimerFunctions={
    Names={},
    Functions={},
    };
   UE.Timer=createTimer()
    UE.Timer.setInterval(3)
    local UETIMER_E,UETIMER_R=nil;
    UE.Timer.setOnTimer(function()
     for I=1,#UE.TimerFunctions.Functions,1 do
      if UE.TimerFunctions.Functions[I] then
       UETIMER_E,UETIMER_R=pcall(UE.TimerFunctions.Functions[I]);
       if not UETIMER_E then
        pcall(UE.TimerFunctions.Remove,UE.TimerFunctions.Names[I]);
        print("Timer Function ["..I.."] "..UE.TimerFunctions.Names[I].." Error:\n"..UETIMER_R);
       end
      end
     end
    end);FNR("UE.Timer");
    UE.Timer.setEnabled(true);

   UE.TimerFunctions.Add=function(Name,Func);
    for I=1,#UE.TimerFunctions.Names,1 do
     if UE.TimerFunctions.Names[I] and UE.TimerFunctions.Names[I]== Name then
      return;
     end
    end
    table.insert(UE.TimerFunctions.Names, Name);
    table.insert(UE.TimerFunctions.Functions, Func);
    end;FNR("UE.TimerFunctions.Add");
  
   UE.TimerFunctions.Remove=function(Name);
    for I=1,#UE.TimerFunctions.Names,1 do
     if UE.TimerFunctions.Names[I] and UE.TimerFunctions.Names[I]== Name then
      table.remove(UE.TimerFunctions.Names, I);
      table.remove(UE.TimerFunctions.Functions, I);
      return;
     end
    end;
    end;FNR("UE.TimerFunctions.Remove");
  end
  do;--Memory Record List Setup
   UE.AddressList,UE.TTreeviewWithScroll=getAddressList(),nil;
   for i = 0, AddressList.ControlCount - 1 do
    local c = AddressList.Control[i]
    if c.ClassName == 'TTreeviewWithScroll' then
     UE.TTreeviewWithScroll = c
     break
    end
   end
   
   UE.AddressListBeginUpdate=function();
    if UE.TTreeviewWithScroll and UE.TTreeviewWithScroll~=nil then
     UE.TTreeviewWithScroll.beginUpdate()
    end
   end
   
   if not UE.AddressListEndUpdate then
    UE.AddressListEndUpdate=function();
     if UE.TTreeviewWithScroll and UE.TTreeviewWithScroll~=nil then
      UE.TTreeviewWithScroll.Selected=nil;
      UE.TTreeviewWithScroll.ItemIndex=-1;
      UE.TTreeviewWithScroll.endUpdate()
     end
     UE.AddressList.refresh();
    end
   end
  
   UE.MemoryRecordList=function(memrec,HeaderText,BaseAddress,ArrayOffset,CountOffset,DISTANCEOFFSET,Func);
    local A=getAddressSafe(BaseAddress);
    if not A or A == 0 then;error("Invalid base address: " .. tostring(BaseAddress));end
    if not getAddressSafe(A + CountOffset) then;error("Invalid count offset address");end
    UE.AddressListBeginUpdate();
    local CreateHeader=function(top,txt,O,C,B)
     local e1 = UE.AddressList.createMemoryRecord()
     e1.isGroupHeader = true
     e1.IsAddressGroupHeader=true;
     e1.Description = txt.." Count: "..C
     e1.Address="["..B..string.format("+0x%X]",O);
     --createdHeader.appendToEntry(memrec)
     e1.Parent=top;
     return e1;
    end
    local Populate=function(Header,i,OFFSET,DO);
     local createEntry=function(group, desc, offset,type,size)
      local e = UE.AddressList.createMemoryRecord()
      e.Description = desc
      e.Address =(not offset or offset ==0) and "+0" or  string.format("+0x%X",offset);
      e.Type = type
      e.Parent=group;
      --e.appendToEntry(group)
      if type==vtCustom then
       e.CustomTypeName=size.Name;
       e.VarType = "vtCustom"
       e.CustomType=size;
      else;e.ShowAsSigned = false;end
      if type==vtString or type==vtUnicodeString then;e.String.Size=size;end
      return e;
     end
     DO(Header,i,OFFSET,createEntry);
    end
    local Count=readInteger(A+CountOffset)-1;
    local S,result=pcall(CreateHeader,memrec,HeaderText,ArrayOffset,Count,BaseAddress);
    if S then
     local Hdr = result;
     local i=0;
     for i=0,Count, 1 do
     local success, errorMsg = pcall(Populate,Hdr,i,DISTANCEOFFSET,Func);
     if not success then
      print("Error in Populate at index " .. i .. ": " .. tostring(errorMsg));
      break;
     end
     end
    else
     print("Error creating header: " .. tostring(result));
    end
    UE.AddressListEndUpdate();
    return S and result or nil;
   end;FNR("UE.MemoryRecordList");
  end
  if not UE.CustomTypes then;--Setup Custom Types
   UE.CustomTypes={Names={}};FNR("UE.CustomTypes");FNR("UE.CustomTypes.Names");
   UE.CustomTypes.Remove=function(TypeName)
    if not TypeName or TypeName=="" then;return false;end;
    if not UE.CustomTypes[TypeName] then;return false;end;
    if UE.CustomTypes[TypeName].CustomTypeLua then;
     UE.CustomTypes[TypeName].CustomTypeLua.destroy();
     UE.CustomTypes[TypeName].CustomTypeLua=nil;
    end
    UE.CustomTypes[TypeName]=nil;
    return true;
   end;FNR("UE.CustomTypes.Remove");
  
   UE.CustomTypes.Add=function(TypeName,Size,ReadFunction,WriteFunction)
    if not TypeName or TypeName=="" or not Size or Size<1 or not ReadFunction or type(ReadFunction)~="function" then;return false;end;
    if WriteFunction and type(WriteFunction)~="function" then;return false;end;
    if UE.CustomTypes[TypeName] then;if not UE.CustomTypes.Remove(TypeName) then;return false;end;end;
    UE.CustomTypes.Names[#UE.CustomTypes.Names+1]=TypeName;
    UE.CustomTypes[TypeName]={Size=Size,Read=ReadFunction,Write=WriteFunction,CustomTypeLua=registerCustomTypeLua(TypeName, Size,ReadFunction,WriteFunction)};
    UE.CustomTypes[TypeName].CustomTypeLua.scriptUsesString = true
    return true;
   end;FNR("UE.CustomTypes.Add");
  
   UE.CustomTypes.Add("FName", 4, 
    function(...)
     local b = {...}
     local id = (b[4] << 24) + (b[3] << 16) + (b[2] << 8) + b[1]
     local pool = ReadPointer(UE.FNamePool)
     if not pool then return "No FNamePool Symbol" end
     local ok, val = pcall(UE.GetName, id)
     return (ok and val and #val>0) and val or "Invalid FName"
    end, 
    function() 
    end
   );
  
   UE.FlagFunctions={
    ConstructFlagTable=function( FlagTable )
     local Num = 0
     local FlagStringTable = {}
     for Mask, Name in pairs( FlagTable ) do
      FlagStringTable[Name] = Mask
      Num = Num + 1
     end
     local __index__ = {
      ['string'] = function( FlagTable, Key )
       if not Key then return nil end
       return FlagStringTable[Key]
      end,
      ['number'] = function( FlagTable, Key )
       if not Key then return nil end
       return rawget( FlagTable, Key )
      end,
     }
     __index__=setmetatable(__index__,{
      __index = function( __index__, Key)
       if not Key then return nil end
       if not rawget( __index__, Key ) then return function()end end
      end
     })
     return setmetatable(FlagTable,{
      __len = function( FlagTable )
       return Num
      end,
      __index = function( FlagTable, Key )
       if not Key then return nil end
       return __index__[type(Key)]( FlagTable, Key )
      end,
     })
    end,
    Parse =function( _Flags, FlagsTable)
     if _Flags==nil or FlagsTable==nil then return false, 0 end
     if type(_Flags) ~= 'string' then return false, 0 end
     local Value, Valid = 0, false
     for Flag in _Flags:gmatch "[_%w]+" do
      local FlagValue = FlagsTable[Flag]
      if not FlagValue then
       return false
      end
      Value = Value | FlagValue
      Valid = true
     end
     
     if not Valid then;
      return nil;
     end
     local ByteTable = {}
     while Value > 0 do
      ByteTable[#ByteTable + 1] = Value % 256
      Value = math.floor(Value / 256)
     end
     while #ByteTable < Size do
      ByteTable[#ByteTable + 1] = 0
     end
  
     return ByteTable
    end,
    Resolve=function( _Flags, FlagsTable )
     if _Flags==nil or FlagsTable==nil then return nil end
     _Flags = type( _Flags ) == 'string' and tonumber( _Flags, 16 ) or _Flags
     if _Flags == 0 then
      return FlagsTable[0]
     end
     local Flags = {}
     for i = 0, 31 do
      local Mask = 1 << i
      Flags[#Flags+1] = (_Flags & Mask) ~= 0 and FlagsTable[Mask] or nil
     end
     return ( #Flags == ( #FlagsTable - 2 ) ) and FlagsTable[0xFFFFFFFF] or table.concat( Flags, " | " )
    end,
    Contains=function( _Flags, FlagsTable, checkFlags )
     if _Flags==nil or FlagsTable==nil or checkFlags==nil then return false end
     local flagsValue = type(_Flags) == 'string' and tonumber(_Flags, 16) or _Flags
     if type(flagsValue) == 'table' then
      flagsValue = 0
      for i = 1, #_Flags do
       flagsValue = flagsValue | (_Flags[i] << ((i-1) * 8))
      end
     end
     if not flagsValue or flagsValue == 0 then return false end
     if type(checkFlags) == 'string' then
      local flagMask = FlagsTable[checkFlags]
      if not flagMask then return false end
      return (flagsValue & flagMask) ~= 0
     end
     if type(checkFlags) == 'table' then
      local results = {}
      for i, flagName in ipairs(checkFlags) do
       local flagMask = FlagsTable[flagName]
       if flagMask then
        results[flagName] = (flagsValue & flagMask) ~= 0
       else
        results[flagName] = false
       end
      end
      return results
     end
     
     return false
    end,
   };
  
   UE.EPropertyFlags = UE.FlagFunctions.ConstructFlagTable {
    [0x0000000000000000] = 'CPF_None'							,-- None
    [0x0000000000000001] = 'CPF_Edit'							,-- Property is user-settable in the editor.
    [0x0000000000000002] = 'CPF_ConstParm'						,-- This is a constant function parameter
    [0x0000000000000004] = 'CPF_BlueprintVisible'				,-- This property is visible in the editor
    [0x0000000000000008] = 'CPF_ExportObject'					,-- Object can be exported with actor.
    [0x0000000000000010] = 'CPF_BlueprintReadOnly'				,-- This property cannot be modified by blueprints
    [0x0000000000000020] = 'CPF_Net'								,-- Property is relevant to network replication.
    [0x0000000000000040] = 'CPF_EditFixedSize'					,-- Indicates that elements of an array can be modified, but its size cannot be changed.
    [0x0000000000000080] = 'CPF_Parm'							,-- Function/When call parameter.
    [0x0000000000000100] = 'CPF_OutParm'							,-- Value is copied out after function call.
    [0x0000000000000200] = 'CPF_ZeroConstructor'					,-- memset is fine for construction
    [0x0000000000000400] = 'CPF_ReturnParm'						,-- Return value.
    [0x0000000000000800] = 'CPF_DisableEditOnTemplate'			,-- Disable editing of this property on an archetype/sub-blueprint
    [0x0000000000002000] = 'CPF_Transient'						,-- Property is transient: shouldn't be saved or loaded, except for Blueprint CDOs.
    [0x0000000000004000] = 'CPF_Config'							,-- Property should be loaded/saved as permanent profile.
    [0x0000000000010000] = 'CPF_DisableEditOnInstance'			,-- Disable editing on an instance of this class
    [0x0000000000020000] = 'CPF_EditConst'						,-- Property is uneditable in the editor.
    [0x0000000000040000] = 'CPF_GlobalConfig'					,-- Load config from base class, not subclass.
    [0x0000000000080000] = 'CPF_InstancedReference'				,-- Property is a component references.
    [0x0000000000200000] = 'CPF_DuplicateTransient'				,-- Property should always be reset to the default value during any type of duplication (copy/paste, binary duplication, etc.)
    [0x0000000000400000] = 'CPF_SubobjectReference'				,-- Property contains subobject references (TSubobjectPtr)
    [0x0000000001000000] = 'CPF_SaveGame'						,-- Property should be serialized for save games, this is only checked for game-specific archives with ArIsSaveGame
    [0x0000000002000000] = 'CPF_NoClear'							,-- Hide clear (and browse) button.
    [0x0000000008000000] = 'CPF_ReferenceParm'					,-- Value is passed by reference; CPF_OutParam and CPF_Param should also be set.
    [0x0000000010000000] = 'CPF_BlueprintAssignable'				,-- MC Delegates only.  Property should be exposed for assigning in blueprint code
    [0x0000000020000000] = 'CPF_Deprecated'						,-- Property is deprecated.  Read it from an archive, but don't save it.
    [0x0000000040000000] = 'CPF_IsPlainOldData'					,-- If this is set, then the property can be memcopied instead of CopyCompleteValue / CopySingleValue
    [0x0000000080000000] = 'CPF_RepSkip'							,-- Not replicated. For non replicated properties in replicated structs 
    [0x0000000100000000] = 'CPF_RepNotify'						,-- Notify actors when a property is replicated
    [0x0000000200000000] = 'CPF_Interp'							,-- interpolatable property for use with matinee
    [0x0000000400000000] = 'CPF_NonTransactional'				,-- Property isn't transacted
    [0x0000000800000000] = 'CPF_EditorOnly'						,-- Property should only be loaded in the editor
    [0x0000001000000000] = 'CPF_NoDestructor'					,-- No destructor
    [0x0000004000000000] = 'CPF_AutoWeak'						,-- Only used for weak pointers, means the export type is autoweak
    [0x0000008000000000] = 'CPF_ContainsInstancedReference'		,-- Property contains component references.
    [0x0000010000000000] = 'CPF_AssetRegistrySearchable'		,-- asset instances will add properties with this flag to the asset registry automatically
    [0x0000020000000000] = 'CPF_SimpleDisplay'					,-- The property is visible by default in the editor details view
    [0x0000040000000000] = 'CPF_AdvancedDisplay'					,-- The property is advanced and not visible by default in the editor details view
    [0x0000080000000000] = 'CPF_Protected'						,-- property is protected from the perspective of script
    [0x0000100000000000] = 'CPF_BlueprintCallable'				,-- MC Delegates only.  Property should be exposed for calling in blueprint code
    [0x0000200000000000] = 'CPF_BlueprintAuthorityOnly'			,-- MC Delegates only.  This delegate accepts (only in blueprint) only events with BlueprintAuthorityOnly.
    [0x0000400000000000] = 'CPF_TextExportTransient'				,-- Property shouldn't be exported to text format (e.g. copy/paste)
    [0x0000800000000000] = 'CPF_NonPIEDuplicateTransient'		,-- Property should only be copied in PIE
    [0x0001000000000000] = 'CPF_ExposeOnSpawn'					,-- Property is exposed on spawn
    [0x0002000000000000] = 'CPF_PersistentInstance'				,-- A object referenced by the property is duplicated like a component. (Each actor should have an own instance.)
    [0x0004000000000000] = 'CPF_UObjectWrapper'					,-- Property was parsed as a wrapper class like TSubclassOf<T>, FScriptInterface etc., rather than a USomething*
    [0x0008000000000000] = 'CPF_HasGetValueTypeHash'			,-- This property can generate a meaningful hash value.
    [0x0010000000000000] = 'CPF_NativeAccessSpecifierPublic'		,-- Public native access specifier
    [0x0020000000000000] = 'CPF_NativeAccessSpecifierProtected'	,-- Protected native access specifier
    [0x0040000000000000] = 'CPF_NativeAccessSpecifierPrivate'	,-- Private native access specifier
    [0x0080000000000000] = 'CPF_SkipSerialization'				,-- Property shouldn't be serialized, can still be exported to text
    [0xFFFFFFFFFFFFFFFF] = 'CPF_AllFlags'						,-- All flags
   }
   UE.CustomTypes.Add("EPropertyFlags", 8, 
    function(...)
     local b = {...}
     local id = 0
     for i = 1, 8 do
      id = id | ((b[i] or 0) << ((i-1) * 8))
     end
     local ok, val = pcall(UE.FlagFunctions.Resolve, id, UE.EPropertyFlags)
     return (ok and val and #val>0) and val or "Invalid EPropertyFlags"
    end, 
    function(Flags, Address)
     local Ok, ByteTable = pcall(UE.FlagFunctions.Parse, Flags:match "%[(.*)%]" or Flags, UE.EPropertyFlags)
     if Ok and ByteTable then
      while #ByteTable < 8 do
       ByteTable[#ByteTable + 1] = 0
      end
      return ByteTable
     end
     return readBytes(Address, 8, true)
    end
   );
  
   UE.EFunctionFlags = UE.FlagFunctions.ConstructFlagTable {
    [0x00000000] = 'FUNC_None'						,-- None
    [0x00000001] = 'FUNC_Final'				    	,-- Function is final (prebindable, non-overridable function).
    [0x00000002] = 'FUNC_RequiredAPI'		    	,-- Indicates this function is DLL exported/imported.
    [0x00000004] = 'FUNC_BlueprintAuthorityOnly'   	,-- Function will only run if the object has network authority
    [0x00000008] = 'FUNC_BlueprintCosmetic'		   	,-- Function is cosmetic in nature and should not be invoked on dedicated servers
    [0x00000040] = 'FUNC_Net'					   	,-- Function is network-replicated.
    [0x00000080] = 'FUNC_NetReliable'			   	,-- Function should be sent reliably on the network.
    [0x00000100] = 'FUNC_NetRequest'				    ,-- Function is sent to a net service
    [0x00000200] = 'FUNC_Exec'						,-- Executable from command line.
    [0x00000400] = 'FUNC_Native'					    ,-- Native function.
    [0x00000800] = 'FUNC_Event'					   	,-- Event function.
    [0x00001000] = 'FUNC_NetResponse'			   	,-- Function response from a net service
    [0x00002000] = 'FUNC_Static'					    ,-- Static function.
    [0x00004000] = 'FUNC_NetMulticast'				,-- Function is networked multicast Server -> All Clients
    [0x00008000] = 'FUNC_UbergraphFunction'		   	,-- Function is used as the merge 'ubergraph' for a blueprint, only assigned when using the persistent 'ubergraph' frame
    [0x00010000] = 'FUNC_MulticastDelegate'			,-- Function is a multi-cast delegate signature (also requires FUNC_Delegate to be set!)
    [0x00020000] = 'FUNC_Public'					    ,-- Function is accessible in all classes (if overridden, parameters must remain unchanged).
    [0x00040000] = 'FUNC_Private'					,-- Function is accessible only in the class it is defined in (cannot be overridden, but function name may be reused in subclasses.  IOW: if overridden, parameters don't need to match, and Super.Func() cannot be accessed since it's private.)
    [0x00080000] = 'FUNC_Protected'					,-- Function is accessible only in the class it is defined in and subclasses (if overridden, parameters much remain unchanged).
    [0x00100000] = 'FUNC_Delegate'					,-- Function is delegate signature (either single-cast or multi-cast, depending on whether FUNC_MulticastDelegate is set.)
    [0x00200000] = 'FUNC_NetServer'					,-- Function is executed on servers (set by replication code if passes check)
    [0x00400000] = 'FUNC_HasOutParms'				,-- function has out (pass by reference) parameters
    [0x00800000] = 'FUNC_HasDefaults'				,-- function has structs that contain defaults
    [0x01000000] = 'FUNC_NetClient'					,-- function is executed on clients
    [0x02000000] = 'FUNC_DLLImport'					,-- function is imported from a DLL
    [0x04000000] = 'FUNC_BlueprintCallable'			,-- function can be called from blueprint code
    [0x08000000] = 'FUNC_BlueprintEvent'			    ,-- function can be overridden/implemented from a blueprint
    [0x10000000] = 'FUNC_BlueprintPure'				,-- function can be called from blueprint code, and is also pure (produces no side effects). If you set this, you should set FUNC_BlueprintCallable as well.
    [0x20000000] = 'FUNC_EditorOnly'				    ,-- function can only be called from an editor scrippt.
    [0x40000000] = 'FUNC_Const'						,-- function can be called from blueprint code, and only reads state (never writes state)
    [0x80000000] = 'FUNC_NetValidate'				,-- function must supply a _Validate implementation
    [0xFFFFFFFF] = 'FUNC_AllFlags'					,-- All flags
   }
   UE.CustomTypes.Add("EFunctionFlags", 4, 
    function(...)
     local b = {...}
     local id = (b[4] << 24) + (b[3] << 16) + (b[2] << 8) + b[1]
     local ok, val = pcall(UE.FlagFunctions.Resolve, id,UE.EFunctionFlags)
     return (ok and val and #val>0) and val or "Invalid EFunctionFlags"
    end, 
    function( Flags, Address )
     local Ok,ByteTable=pcall(UE.FlagFunctions.Parse, Flags:match "%[(.*)%]" or Flags, UE.EFunctionFlags );
     return (Ok) and ByteTable or readBytes( Address, 4, true )
    end
   );
  
   UE.EObjectFlags = UE.FlagFunctions.ConstructFlagTable {
    [0x00000000] = 'RF_NoFlags'					    ,-- No flags, used to avoid a cast
    [0x00000001] = 'RF_Public'					    ,-- Object is visible outside its package.
    [0x00000002] = 'RF_Standalone'				    ,-- Keep object around for editing even if unreferenced.
    [0x00000004] = 'RF_MarkAsNative'		    		,-- Object (UField) will be marked as native on construction (DO NOT USE THIS FLAG in HasAnyFlags() etc)
    [0x00000008] = 'RF_Transactional'			    ,-- Object is transactional.
    [0x00000010] = 'RF_ClassDefaultObject'		    ,-- This object is used as the default template for all instances of a class. One object is created for each class
    [0x00000020] = 'RF_ArchetypeObject'			    ,-- This object can be used as a template for instancing objects. This is set on all types of object templates
    [0x00000040] = 'RF_Transient'				    ,-- Don't save object.
    [0x00000080] = 'RF_MarkAsRootSet'			    ,-- Object will be marked as root set on construction and not be garbage collected, even if unreferenced (DO NOT USE THIS FLAG in HasAnyFlags() etc)
    [0x00000100] = 'RF_TagGarbageTemp'			    ,-- This is a temp user flag for various utilities that need to use the garbage collector. The garbage collector itself does not interpret it.
    [0x00000200] = 'RF_NeedInitialization'		    ,-- This object has not completed its initialization process. Cleared when ~FObjectInitializer completes
    [0x00000400] = 'RF_NeedLoad'					    ,-- During load, indicates object needs loading.
    [0x00000800] = 'RF_KeepForCooker'			    ,-- Keep this object during garbage collection because it's still being used by the cooker
    [0x00001000] = 'RF_NeedPostLoad'			        ,-- Object needs to be postloaded.
    [0x00002000] = 'RF_NeedPostLoadSubobjects'	    ,-- During load, indicates that the object still needs to instance subobjects and fixup serialized component references
    [0x00004000] = 'RF_NewerVersionExists'		    ,-- Object has been consigned to oblivion due to its owner package being reloaded, and a newer version currently exists
    [0x00008000] = 'RF_BeginDestroyed'			    ,-- BeginDestroy has been called on the object.
    [0x00010000] = 'RF_FinishDestroyed'			    ,-- FinishDestroy has been called on the object.
    [0x00020000] = 'RF_BeingRegenerated'		        ,-- Flagged on UObjects that are used to create UClasses (e.g. Blueprints) while they are regenerating their UClass on load (See FLinkerLoad::CreateExport()), as well as UClass objects in the midst of being created
    [0x00040000] = 'RF_DefaultSubObject'			    ,-- Flagged on subobject templates that were created in a class constructor, and all instances created from those templates
    [0x00080000] = 'RF_WasLoaded'				    ,-- Flagged on UObjects that were loaded
    [0x00100000] = 'RF_TextExportTransient'		    ,-- Do not export object to text form (e.g. copy/paste). Generally used for sub-objects that can be regenerated from data in their parent object.
    [0x00200000] = 'RF_LoadCompleted'			    ,-- Object has been completely serialized by linkerload at least once. DO NOT USE THIS FLAG, It should be replaced with RF_WasLoaded.
    [0x00400000] = 'RF_InheritableComponentTemplate' ,-- Flagged on subobject templates stored inside a class instead of the class default object, they are instanced after default subobjects
    [0x00800000] = 'RF_DuplicateTransient'		    ,-- Object should not be included in any type of duplication (copy/paste, binary duplication, etc.)
    [0x01000000] = 'RF_StrongRefOnFrame'			    ,-- References to this object from persistent function frame are handled as strong ones.
    [0x02000000] = 'RF_NonPIEDuplicateTransient'	    ,-- Object should not be included for duplication unless it's being duplicated for a PIE session
    [0x04000000] = 'RF_Dynamic'				        ,-- Was removed along with bp nativization
    [0x08000000] = 'RF_WillBeLoaded'				    ,-- This object was constructed during load and will be loaded shortly
    [0x10000000] = 'RF_HasExternalPackage'		    ,-- This object has an external package assigned and should look it up when getting the outermost package
    [0x20000000] = 'RF_HasPlaceholderType'		    ,-- This object was instanced from a placeholder type (e.g. on load). References to it are serialized but externally resolve to NULL from a logical point of view (for type safety).
    [0x40000000] = 'RF_MirroredGarbage'			    ,-- Garbage from logical point of view and should not be referenced. This flag is mirrored in EInternalObjectFlags as Garbage for performance
    [0x80000000] = 'RF_AllocatedInSharedPage'	    ,-- Allocated from a ref-counted page shared with other UObjects
    [0xFFFFFFFF] = 'RF_AllFlags'					    ,-- All flags
   }
   UE.CustomTypes.Add("EObjectFlags", 4, 
    function(...)
     local b = {...}
     local id = (b[4] << 24) + (b[3] << 16) + (b[2] << 8) + b[1]
     local ok, val = pcall(UE.FlagFunctions.Resolve, id,UE.EObjectFlags)
     return (ok and val and #val>0) and val or "Invalid EObjectFlags"
    end, 
    function( Flags, Address )
     local Ok,ByteTable=pcall(UE.FlagFunctions.Parse, Flags:match "%[(.*)%]" or Flags, UE.EObjectFlags );
     return (Ok) and ByteTable or readBytes( Address, 4, true )
    end
   );
   
   GetObjectAddress=function( Object )
    return readQwordLocal( tostring( Object ):match "0%x*" )
   end
   GetSelectedStructureElementAddress=function ( Form )
    local Memory = createMemoryStream()
    Memory.Size = 8
    local _miBrowseAddressClick_Address = readQwordLocal( GetObjectAddress( Form.miBrowseAddress ) + 0xD8 )
    _miBrowseAddressClick_Address = _miBrowseAddressClick_Address + 0x34
    local _getAddressFromNode_Address = _miBrowseAddressClick_Address + readIntegerLocal( _miBrowseAddressClick_Address + 1, true ) + 5;
    local Result = executeCodeLocalEx(
     _getAddressFromNode_Address,
     GetObjectAddress(Form),
     GetObjectAddress(Form.tvStructureView.Selected),
     GetObjectAddress(Form.Column[0]),
     Memory.memory)
    Memory.destroy()
    return Result
   end
   GetSelectedStructureElement=function(Form);
    local Address=GetObjectAddress(  Form.Definenewstructure1)
    Address=ReadPointerLocal(Address+0xD8);
    while readByteLocal(Address)~=0xC3 do
     Address=Address+1;
    end
    Address=UE.AlignOffset(Address,16);
    Address=ExecuteCodeLocalEx(Address,
     GetObjectAddress(  Form ),
     GetObjectAddress(  Form.tvStructureView.Selected )
    );
    if not StructElementTypeOffset then;
     local F=ReadPointerLocal(Address);
     local OFS=ReadPointerLocal(F+0x38);
     local I=0;
     for I=0,0x1000,1 do
  
      if not StructElementTypeOffset and ReadByteLocal(OFS+I)==0x4E and ReadByteLocal(OFS+I+1)==0x61 and ReadByteLocal(OFS+I+2)==0x6D and ReadByteLocal(OFS+I+3)==0x65 then; --Name
       StructElementTypeOffset=ReadByteLocal(ReadPointerLocal(OFS+I+4+0x8)+0x3);
       --printf("StructElementTypeOffset: %X",StructElementTypeOffset);
      end
      if not StructElementCustomTypeOffset and ReadByteLocal(OFS+I)==0x56 and ReadByteLocal(OFS+I+1)==0x61 and ReadByteLocal(OFS+I+2)==0x72 and ReadByteLocal(OFS+I+3)==0x54 and ReadByteLocal(OFS+I+4)==0x79 and ReadByteLocal(OFS+I+5)==0x70 and ReadByteLocal(OFS+I+6)==0x65 then;--VarType
       StructElementCustomTypeOffset=ReadByteLocal(ReadPointerLocal(OFS+I+7+0x8)+0x3);
       --printf("StructElementCustomTypeOffset: %X",StructElementCustomTypeOffset);
      end
      if StructElementCustomTypeOffset and StructElementTypeOffset then;break;end
     end
    end
    return Address;
   end
   
   if not StructureFormsHandled then;StructureFormsHandled={Array={},OldOnClick={}};end
   TypeSystemID = ( (TypeSystemID and unregisterFormAddNotification( TypeSystemID ) ) or true ) and registerFormAddNotification( function( Form )
    if Form.ClassName:find "TfrmStructures2" then
     createTimer(10,function()
      if Form.pmStructureView then
       if StructureFormsHandled[Form.Handle] then;return;end
       StructureFormsHandled[Form.Handle]=Form;
       StructureFormsHandled.Array[#StructureFormsHandled.Array+1]=Form.Handle;
       local UESeperator = createMenuItem(Form.miChangeType);
        UESeperator.Caption = "-";
        UESeperator.Name = "UESeperator"
        Form.miChangeType.add( UESeperator )
       local X=1;
       local VisibleCustomTypes={};
       for X=1,#UE.CustomTypes.Names do
        local Name=UE.CustomTypes.Names[X]
        local MenuItem = createMenuItem( Form.miChangeType )
        MenuItem.Caption = Name
        MenuItem.Name = "mi"..Name
        MenuItem.CustomTypeName=Name;
        MenuItem.CustomType=UE.CustomTypes[MenuItem.CustomTypeName];
        MenuItem.UpdateCaption=function(Element);
         local O,Var=pcall(function(Address);return MenuItem.CustomType.CustomTypeLua.byteTableToValue(readBytes(Address,MenuItem.CustomType.Size,true));end,Element);
         if O and Var then;MenuItem.Caption=MenuItem.CustomTypeName..": "..Var;end
        end
        MenuItem.OnClick = function();
         local Element=GetSelectedStructureElement(Form);
         writeByteLocal(Element+StructElementTypeOffset,13);
         writeQwordLocal(Element+StructElementCustomTypeOffset,GetObjectAddress(  MenuItem.CustomType.CustomTypeLua ));
        end
        Form.miChangeType.add( MenuItem )
        VisibleCustomTypes[#VisibleCustomTypes+1]= MenuItem;
       end
       local ONCLICKINDEX=#StructureFormsHandled.OldOnClick+1;
       StructureFormsHandled.OldOnClick[ONCLICKINDEX]=Form.tvStructureView.OnContextPopup;
       Form.tvStructureView.OnContextPopup=function(...)
        if StructureFormsHandled.OldOnClick[ONCLICKINDEX] then;
         StructureFormsHandled.OldOnClick[ONCLICKINDEX](...);
        end
        local OK,Element=pcall(GetSelectedStructureElementAddress,Form);
        if not OK then;
         print("Failure Calling GetSelectedStructureElementAddress:\n"..Element);
        else
         for X=1,#VisibleCustomTypes do
          VisibleCustomTypes[X].UpdateCaption(Element);
         end
        end
       end
      end
     end)
    end
   end)
  end  
  do--Custom Object Functions
   UE.AddCustomObject = function(objectData)
    if not objectData or not objectData.Name then
     print("Error: objectData must contain at least a Name field")
     return false
    end
    local existingObject = UE.GetObjectByName(objectData.Name)
    if existingObject then
     print(string.format("Found existing object '%s', updating with new data...", objectData.Name))
     if objectData.Type then existingObject.Type = objectData.Type end
     if objectData.ScriptName then existingObject.ScriptName = objectData.ScriptName end
     if objectData.Parent then existingObject.Parent = objectData.Parent end
     if objectData.Address then existingObject.Address = objectData.Address end
     if objectData.IsStructType ~= nil then existingObject.IsStructType = objectData.IsStructType end
     if objectData.IsEnumType ~= nil then existingObject.IsEnumType = objectData.IsEnumType end
     if objectData.PropTypeClass then existingObject.PropTypeClass = objectData.PropTypeClass end
    
     if objectData.Members and type(objectData.Members) == "table" then
      local customMembers = {}
      local memberIndex = 0
      local startCount = 0
      local endCount = 0
      for _, memberData in pairs(objectData.Members) do
       if type(memberData) == "table" and memberData.Name then
        customMembers[memberIndex] = {
         Address = memberData.Address or 0,
         PropType = memberData.PropType or "ByteProperty",
         Name = memberData.Name,
         Offset = memberData.Offset or 0,
         ByteSize = memberData.ByteSize or 1,
         Inner = memberData.Inner or memberData.PropType or "ByteProperty",
         PropTypeClass = memberData.PropTypeClass or ""
        }
        if memberIndex == 0 then;startCount = customMembers[memberIndex].Offset;end
        local memberEnd = customMembers[memberIndex].Offset + customMembers[memberIndex].ByteSize
        if memberEnd > endCount then;endCount = memberEnd;end
        memberIndex = memberIndex + 1
       end
      end
      if memberIndex > 0 then
       existingObject.Members = {
        Members = customMembers,
        StartCount = startCount,
        EndCount = endCount,
        CountOffset = endCount - startCount
       }
       existingObject.IsStructType = true
       print(string.format("Updated existing object '%s' with %d new members", objectData.Name, memberIndex))
      end
     end
     return true
    end
    local customObject = {
     Name = objectData.Name,
     Type = objectData.Type or "CustomObject",
     ScriptName = objectData.ScriptName or "",
     Parent = objectData.Parent or "",
     Address = objectData.Address or 0,
     Members = nil,
     IsStructType = objectData.IsStructType or false,
     IsEnumType = objectData.IsEnumType or false,
     PropTypeClass = objectData.PropTypeClass or ""
    }
    if objectData.Members and type(objectData.Members) == "table" then
     local customMembers = {}
     local memberIndex = 0
     local startCount = 0
     local endCount = 0
     for _, memberData in pairs(objectData.Members) do
      if type(memberData) == "table" and memberData.Name then
       customMembers[memberIndex] = {
        Address = memberData.Address or 0,
        PropType = memberData.PropType or "ByteProperty",
        Name = memberData.Name,
        Offset = memberData.Offset or 0,
        ByteSize = memberData.ByteSize or 1,
        Inner = memberData.Inner or memberData.PropType or "ByteProperty",
        PropTypeClass = memberData.PropTypeClass or ""
       }
       if memberIndex == 0 then
        startCount = customMembers[memberIndex].Offset
       end
       local memberEnd = customMembers[memberIndex].Offset + customMembers[memberIndex].ByteSize
       if memberEnd > endCount then
        endCount = memberEnd
       end
       memberIndex = memberIndex + 1
      end
     end
     if memberIndex > 0 then
      customObject.Members = {
       Members = customMembers,
       StartCount = startCount,
       EndCount = endCount,
       CountOffset = endCount - startCount
      }
      customObject.IsStructType = true -- Objects with members should be struct types
     end
    end
    local targetChunkIndex = UE.ObjectChunksCount
    local targetObjectIndex = 0
    if UE.ObjectChunksArray[targetChunkIndex] and UE.ObjectChunksArray[targetChunkIndex].Count < 65535 then
     targetObjectIndex = UE.ObjectChunksArray[targetChunkIndex].Count + 1
    else
     targetChunkIndex = targetChunkIndex + 1
     UE.ObjectChunksArray[targetChunkIndex] = {
      Address = 0,
      Array = {},
      Count = 0,
      Index = targetChunkIndex
     }
     targetObjectIndex = 0
    end
    UE.ObjectChunksArray[targetChunkIndex].Array[targetObjectIndex] = customObject
    UE.ObjectChunksArray[targetChunkIndex].Count = targetObjectIndex
    if targetChunkIndex > UE.ObjectChunksCount then
     UE.ObjectChunksCount = targetChunkIndex
    end
    UE.ObjectsCount = UE.ObjectsCount + 1
    print(string.format("Added new custom object '%s' (Type: %s) to chunk %d, object %d",customObject.Name, customObject.Type, targetChunkIndex, targetObjectIndex))
    return true
   end;FNR("UE.AddCustomObject")
  
   UE.CreateCustomObjectData = function(name, objectType, members)
    local objectData = {
     Name = name,
     Type = objectType or "CustomStruct",
     IsStructType = true,
     Members = members or {}
     }
    return objectData
   end;FNR("UE.CreateCustomObjectData")
  
   UE.CreateMemberData = function(name, propType, offset, byteSize, propTypeClass)
    return {
     Name = name,
     PropType = propType or "ByteProperty",
     Offset = offset or 0,
     ByteSize = byteSize or 1,
     PropTypeClass = propTypeClass or ""}
   end;FNR("UE.CreateMemberData")
  
   UE.RemoveCustomObject = function(objectName)
    local found = false
    for i = 0, UE.ObjectChunksCount do
     if UE.ObjectChunksArray[i] then
      for j = 0, UE.ObjectChunksArray[i].Count do
       if UE.ObjectChunksArray[i].Array[j] and UE.ObjectChunksArray[i].Array[j].Name == objectName then
        UE.ObjectChunksArray[i].Array[j] = nil
        UE.ObjectsCount = UE.ObjectsCount - 1
        found = true
        print(string.format("Removed custom object '%s' from chunk %d, object %d", objectName, i, j))
        break
       end
      end
     if found then break end
     end
    end
    if not found then
     print("Custom object '" .. objectName .. "' not found")
     return false
    end
    return true
   end;FNR("UE.RemoveCustomObject")
  end
  do--Utility Functions
   UE.GetVirtualFunction=function(index)
    if not UE.CoreUObjectVFTable then;return nil;end
    return ReadPointer(UE.CoreUObjectVFTable +(index*0x8));
    end;FNR("UE.GetVirtualFunction");
 
   UE.ReadX64R=function(A,O)
    local I=readInteger(A+O);
    if I==nil then;return nil;end
    return (A+I)+(O+0x4);
    end;FNR("UE.ReadX64R");
 
   UE.GetName=function( idx)
    if idx==nil or idx < 0 then;return nil end;
    if UE.GlobalNameCache[idx] then return UE.GlobalNameCache[idx] end
    local block_idx = idx >> 16
    local name_idx = idx & 0xFFFF
    local block_ptr_addy = UE.FNamePool + ((block_idx+2) * 8)
    local block_ptr = readPointer(block_ptr_addy)
    if block_ptr==nil then return nil;end
    local str_idx = block_ptr+(2*name_idx)
    local str_header = readSmallInteger(str_idx)
    local is_wide = false
    if str_header==nil then return nil end
    if str_header & 1 == 1 then is_wide = true end
    local str_len = str_header >> 6
    local D= readString(str_idx+2, str_len-1, is_wide)
    if D==nil then return nil;end
    UE.GlobalNameCache[idx] = D;
    return D;
    end;FNR("UE.GetName");
 
   UE.GetNameFromObject=function(objAddress)
    local Indx=readInteger(objAddress+UE.Constant.oClassName);
    return Indx and UE.GetName(Indx) or nil;
    end;FNR("UE.GetNameFromObject");

   UE.IsPlayerType=function(A);
    local Class=readInteger(A+UE.Constant.oClassName);
    if UE.PlayerClassTypes[Class] then;return UE.PlayerClassTypes[Class].State;end
    local ClassInner=ReadPointer(A+UE.Constant.oClass);
    if not ClassInner then;return false;end;
    local ClassNameId,ClassName=nil,nil;
    local Attempt=0;
    for Attempt=0,10,1 do
     if not ClassInner then;break;end
     ClassNameId=readInteger(ClassInner+UE.Constant.oClassName);
     ClassName=UE.GetName(ClassNameId);
     if ClassName and ClassName=="Pawn" then
      UE.PlayerClassTypes[Class]={State=true};
      return true;
     end
     ClassInner=readPointer(ClassInner+UE.Constant.oSuper);
    end
    UE.PlayerClassTypes[Class]={State=false};
    return false;
    end;FNR("UE.IsPlayerType");
 
   UE.IsValidString = function(str)
    if not str or str == "" then;return false;end
    for i = 1, #str do
     local byte = string.byte(str, i)
     if byte < 32 or byte > 126 then
      if byte ~= 9 and byte ~= 10 and byte ~= 13 then;return false;end -- Tab, LF, CR
     end
    end
    if string.find(str, "[\x00-\x1F\x7F-\xFF]") then;return false;end
    if #str > 255 then;return false;end
    return true;
    end;FNR("UE.IsValidString")
  
   UE.AlignOffset=function(offset, alignment)
    alignment = alignment or 8
    if alignment <= 0 then alignment = 1 end
    return ((offset + alignment - 1) // alignment) * alignment
    end;FNR("UE.AlignOffset")

   UE.DetectValueType = function(address, size)
    if not address or address == 0 or not size or size == 0 then
     return vtByte
    end
    local value = nil
    if size == 1 then
     value = readByte(address)
     return vtByte
     elseif size == 2 then
     value = readSmallInteger(address)
     if value and (value == 0 or (value > 0 and value < 65535)) then
      return vtWord
     end
    elseif size == 4 then
     value = readInteger(address)
     local floatValue = readFloat(address)
     if floatValue and floatValue > -1000000 and floatValue < 1000000 then
      local intValue = math.floor(floatValue)
      if math.abs(floatValue - intValue) > 0.0001 then
       return vtSingle
      end
     end
     return vtDword
    elseif size == 8 then
     value = readQword(address)
     if value and value > 0x10000 and value < 0x7FFFFFFFFFFF then
      return vtPointer
     end
     local doubleValue = readDouble(address)
     if doubleValue and doubleValue > -1000000 and doubleValue < 1000000 then
      return vtDouble
     end
     return vtQword
    end
    return vtBinary
    end;FNR("UE.DetectValueType")
   
   UE.GetBitfieldInfo = function(value, size)
    if not value then return nil end
    local bits = {}
    local maxBits = size * 8
    for i = 0, maxBits - 1 do
     local mask = 1 << i
     if (value & mask) ~= 0 then
      table.insert(bits, i)
     end
    end
    return bits
    end;FNR("UE.GetBitfieldInfo")
  end
  do--UObjectArray Functions
   UE.GetOffsetBySymbol=function(symbol)
    local parts = {}
    for part in string.gmatch(symbol, "[^%.]+") do;table.insert(parts, part);end
     if #parts == 2 then
      local className = parts[1]
      local memberName = parts[2]
      local classObj = UE.GetObjectByName(className)
      if classObj and classObj.Members and classObj.Members.Members then
       for i = 0, #classObj.Members.Members do
        if classObj.Members.Members[i] and classObj.Members.Members[i].Name == memberName then
         local memberOffset = classObj.Members.Members[i].Offset
         UE.SymbolLookupCallbackCache[symbol] = memberOffset
         return memberOffset
        end
       end
      end
     end
     return nil;
    end

   UE.GetObjectByType=function(name)
    local i=0;local j=0;
    for i=0,UE.ObjectChunksCount,1 do for j=0,UE.ObjectChunksArray[i].Count,1 do
    if UE.ObjectChunksArray[i].Array[j].Type==name then;return UE.ObjectChunksArray[i].Array[j];end
    end;end
    return nil;
    end;FNR("UE.GetObjectByType");
   
   UE.GetObjectByName=function(name)
    local i=0;local j=0;
    if not UE.ObjectChunksCount or UE.ObjectChunksCount<=0 then;return nil;end
    for i=0,UE.ObjectChunksCount,1 do 
     for j=0,UE.ObjectChunksArray[i].Count,1 do
      if UE.ObjectChunksArray[i].Array[j] and UE.ObjectChunksArray[i].Array[j].Name==name then;
       return UE.ObjectChunksArray[i].Array[j];
      end
     end;
    end
    return nil;
    end;FNR("UE.GetObjectByName");
   
   UE.GetObjectByNameAndScript=function(name,script)
    local i=0;local j=0;
    if not UE.ObjectChunksCount or UE.ObjectChunksCount<=0 then;return nil;end
    for i=0,UE.ObjectChunksCount,1 do for j=0,UE.ObjectChunksArray[i].Count,1 do
    if UE.ObjectChunksArray[i].Array[j].Name==name and UE.ObjectChunksArray[i].Array[j].ScriptName==script then;return UE.ObjectChunksArray[i].Array[j];end
    end;end
    return nil;
    end;FNR("UE.GetObjectByNameAndScript");
   
   UE.GetObjectByFullName=function(name)
    local i=0;local j=0;
    if not UE.ObjectChunksCount or UE.ObjectChunksCount<=0 then;return nil;end
    for i=0,UE.ObjectChunksCount,1 do for j=0,UE.ObjectChunksArray[i].Count,1 do
    if UE.ObjectChunksArray[i].Array[j].Namespace.."."..UE.ObjectChunksArray[i].Array[j].Name==name then;return UE.ObjectChunksArray[i].Array[j];end
    end;end
    return nil;
    end;FNR("UE.GetObjectByFullName");
   
   UE.GetObjectByScriptName=function(Name)
    local i=0;local j=0;
    if not UE.ObjectChunksCount or UE.ObjectChunksCount<=0 then;return nil;end
    for i=0,UE.ObjectChunksCount,1 do for j=0,UE.ObjectChunksArray[i].Count,1 do
    if UE.ObjectChunksArray[i].Array[j].ScriptName==ScriptName then;return UE.ObjectChunksArray[i].Array[j];end
    end;end
    return nil;
    end;FNR("UE.GetObjectByScriptName");
  
   UE.FindHighestParent=function(className)
    if not className or className=="" then;return nil;end
    local highestParent=nil
    local maxDepth=0
    if UE.ObjectChunksCount==0 then
     print("No objects loaded. Run UE.Find() first.")
     return nil
    end
    for i=0,UE.ObjectChunksCount do
     if UE.ObjectChunksArray[i] then
      for j=0,UE.ObjectChunksArray[i].Count do
       local obj=UE.ObjectChunksArray[i].Array[j]
        if obj and obj.Type=="Class" then
         local inheritanceChain={}
         local currentAddress=obj.Address
         local depth=0
         while currentAddress and currentAddress~=0 do
          local currentName=UE.GetNameFromObject(currentAddress)
          if not currentName then;break;end
          table.insert(inheritanceChain,currentName)
          local parentAddress=readPointer(currentAddress+UE.Constant.oSuper)
          if not parentAddress or parentAddress==0 then;break;end
          currentAddress=parentAddress
          depth=depth+1
          if depth>50 then;break;end
         end
         for k,inheritedClass in ipairs(inheritanceChain) do
          if inheritedClass==className then
           if depth>maxDepth then
            maxDepth=depth
            highestParent=obj.Name
           end
           break
          end
         end
        end
      end
     end
    end
    if not highestParent then
     local directMatch=UE.GetObjectByName(className)
     if directMatch and directMatch.Type=="Class" then;return className;end
    end
    return highestParent
    end;FNR("UE.FindHighestParent")
   
   UE.GetInheritanceChain=function(className)
    if not className or className == "" then;return {};end
    local obj = UE.GetObjectByName(className)
    if not obj or not obj.IsStructType then;return {};end
    local inheritanceChain = {}
    local currentObj = obj
    local depth = 0
    local currentAddress = obj.Address
    while currentAddress and currentAddress ~= 0 do
      local currentName = UE.GetNameFromObject(currentAddress)
      if not currentName then break end
      table.insert(inheritanceChain, currentName)
      local parentAddress = readPointer(currentAddress + UE.Constant.oSuper)
      if not parentAddress or parentAddress == 0 then break end
      currentAddress = parentAddress
      depth = depth + 1
      if depth > 50 then break end
     end
    return inheritanceChain;
    end;FNR("UE.GetInheritanceChain")
  
   UE.GetStructureSizeWithInheritance = function(structureName)
    if not structureName or structureName == "" then;return 0;end
    local structObj = UE.GetObjectByName(structureName)
    if not structObj then
     print("Structure not found: " .. structureName)
     return 0
    end
    if not structObj.IsStructType then
     print(structureName .. " is not a structure type")
     return 0
    end
    local function calculateInheritedSize(className, visitedClasses, totalSize)
     visitedClasses = visitedClasses or {}
     totalSize = totalSize or 0
     if visitedClasses[className] then
      return totalSize
     end
     visitedClasses[className] = true
   
     local currentClassObj = nil
     for i = 0, UE.ObjectChunksCount do
      if UE.ObjectChunksArray[i] then
       for j = 0, UE.ObjectChunksArray[i].Count do
        local obj = UE.ObjectChunksArray[i].Array[j]
         if obj and obj.Name == className and obj.IsStructType then
          currentClassObj = obj
          break
         end
        end
       end
       if currentClassObj then break end
      end
      if not currentClassObj then
       return totalSize
      end
   
      local currentSize = 0
      if currentClassObj.Members and currentClassObj.Members.CountOffset then
       currentSize = currentClassObj.Members.CountOffset
      elseif currentClassObj.Members and currentClassObj.Members.EndCount and currentClassObj.Members.StartCount then
       currentSize = currentClassObj.Members.EndCount - currentClassObj.Members.StartCount
      end
   
      if currentClassObj.Parent and currentClassObj.Parent ~= "" then
       totalSize = calculateInheritedSize(currentClassObj.Parent, visitedClasses, totalSize)
      end
   
      local maxMemberOffset = 0
      local maxMemberSize = 0
      if currentClassObj.Members and currentClassObj.Members.Members then
       for i = 0, #currentClassObj.Members.Members do
        if currentClassObj.Members.Members[i] then
         local member = currentClassObj.Members.Members[i]
         local memberEnd = member.Offset + member.ByteSize
         if memberEnd > maxMemberOffset + maxMemberSize then
          maxMemberOffset = member.Offset
          maxMemberSize = member.ByteSize
         end
        end
       end
      end
     local thisClassSize = maxMemberOffset + maxMemberSize
     if thisClassSize > totalSize then
      totalSize = thisClassSize
     end
     return totalSize
     end
    local totalSize = calculateInheritedSize(structureName)
    --print(string.format("Total structure size for %s (including inheritance): 0x%X (%d bytes)",structureName, totalSize, totalSize))
    return totalSize
    end;FNR("UE.GetStructureSizeWithInheritance")
   
   UE.GetStructureSizeWithInheritanceCached = function(structureName)
    if UE.StructureSizeCache[structureName] then;return UE.StructureSizeCache[structureName];end
    local size = UE.GetStructureSizeWithInheritance(structureName)
    UE.StructureSizeCache[structureName] = size
    return size
    end;FNR("UE.GetStructureSizeWithInheritanceCached")
  end
  do--Finder Functions
   UE.GetObjectMembers=function(address)
    local Member=readPointer(address+UE.Constant.oChildren) or 0;--FirstOffset;
    if Member==nil or Member==0 then return nil end
    local MemberName,MemberPropType,MemberPropTypeClass=nil;
    local MemberOffset,MemberByteSize,iPropType,iPropTypeT,iPropTypeAReal=0;
    local EndCount=readInteger(address+UE.Constant.oEndCount) or 0;
    local StartCount=readInteger(Member+UE.Constant.oStartCount) or 0;
    local CountOffset=EndCount-StartCount;
    local Members={};local MembersC=0;
    while true do
     if not Member or Member == 0 then break end
     local CHQ = readPointer(Member+0x10);
     if not CHQ or --CHQ == 0 or CHQ < 0x10000 or CHQ > 0x7FFFFFFFFFFF or
     CHQ-0x1 ~= address then break end
     iPropType=readInteger(ReadPointer(Member+0x8));
     MemberPropType=UE.GetName(iPropType);
     MemberName=UE.GetName(readInteger(Member+0x20));
     MemberOffset=readInteger(Member+0x44);
     MemberByteSize=readInteger(Member+0x34);
     iPropTypeAReal=nil;
     if MemberPropType=="ArrayProperty" or MemberPropType=="MapProperty" or MemberPropType=="StructProperty" or MemberPropType=="GbxDefPtrProperty" then
      iPropTypeAReal=ReadPointer(Member+0x78);
      if iPropTypeAReal then
       iPropTypeAReal=ReadPointer(iPropTypeAReal+0x70)
       if iPropTypeAReal then
        iPropTypeAReal=readInteger(iPropTypeAReal+UE.Constant.oClassName);
       end
      end
      if not iPropTypeAReal then
       iPropTypeAReal=ReadPointer(Member+0x70);
       if iPropTypeAReal then
        iPropTypeAReal=readInteger(iPropTypeAReal+UE.Constant.oClassName);
       end
      end
     end
     iPropTypeT=readInteger(ReadPointer(Member+0x88));
     if MemberPropType=="EnumProperty" then;iPropTypeAReal=iPropTypeT;end
     MemberPropTypeInner=(iPropTypeT==iPropType) and MemberPropType or UE.GetName(iPropTypeT);
     MemberPropTypeClass= iPropTypeAReal and UE.GetName(iPropTypeAReal) or "";
     Members[MembersC]={Address=Member,PropType=MemberPropType,Name=MemberName,Offset=MemberOffset,ByteSize=MemberByteSize,Inner=MemberPropTypeInner,PropTypeClass=MemberPropTypeClass};
     local nextMember = readPointer(Member+UE.Constant.oNext);
     if not nextMember or nextMember == 0 then;nextMember = readPointer(Member+UE.Constant.oNext2);end
     Member = nextMember;
     MembersC=MembersC+1;
    end
    if MembersC==0 then;return nil;end
    return Members,StartCount,EndCount,CountOffset;
    end;FNR("UE.GetObjectMembers")
     
   UE.GetEnumMembers=function(address)
    local MemberAddress=readPointer(address+0x40) or 0;
    if MemberAddress==nil or MemberAddress==0 then return nil end
    local MemberName=nil;
    local MemberOffset=0;
    local CountOffset=readInteger(address+UE.Constant.oEnumEndCount) or 0;
    local Members={};local MembersC=0;
    local _C=0;
    local Member=0;
    local MemberPropType="ByteProperty";
    for _C=0,CountOffset-1,1 do
     Member=MemberAddress+(_C*0x10);
     MemberName=UE.GetName(readInteger(Member));
     MemberOffset=readInteger(Member+0x8);
     Members[_C]={Address=Member,PropType=MemberPropType,Name=MemberName,Offset=MemberOffset,ByteSize=MemberPropType,Inner=nil,PropTypeClass=""};
    end
    return Members,CountOffset;
    end;FNR("UE.GetEnumMembers")
  
   UE.FillUObjectArray=function()
    UE.ObjectChunks=readPointer(UE.UObjectArray);
    if UE.ObjectChunks==nil and true or UE.ObjectChunks==0 then
    print("Failed To Read UObject Array Chunks");
    return;
    end
    UE.ObjectsCount=0;
    UE.ObjectChunksCount=0;
    UE.ObjectChunksArray={};
    local Chunk,A,R,_Address=0;
    local Members,StartCount,EndCount,CountOffset,_Name,_ScriptName,_Parent,_Type,_Super,_SuperA,_EndCount=nil;
    local SuperB=0;
    local _IsStructType=0;local _IsEnumType=0;
    
    for A=0,0xFF,1 do
     Chunk=readPointer(UE.ObjectChunks+(UE.ObjectChunksCount*0x8));
     if not Chunk or Chunk==0 then;break;end
     UE.ObjectChunksArray[UE.ObjectChunksCount]={Address=Chunk,Array={},Count=0,Index=UE.ObjectChunksCount};
     UE.ObjectChunksCount=UE.ObjectChunksCount+1;
    end;
    UE.ObjectChunksCount=UE.ObjectChunksCount-1;
    
    local threadResults = {}
    local threadHandles = {}
    local totalObjectsProcessed = 0
    
    local function chunkProcessor(chunkIndex, chunkData, threadId, sharedResults)
     return function()
      local objects = {}
      local objectCount = 0
      local R,J = 0,0
      local _Address,hasPublic,_Name,TA,_Type,_IsEnumType,_IsStructType,_ScriptName, _Parent, _Super,SuperB,Members,StartCount,EndCount,CountOffset=nil;
      while true do
       _Address=readPointer(chunkData.Address+(R*0x18));
       if not _Address then
        J=0;
        for J=0,25,1 do
        R=R+1;
         _Address=readPointer(chunkData.Address+(R*0x18));
         if _Address then;break;end
        end
        if not _Address then
         break
        end
       end
       _Name=UE.GetName(readInteger(_Address+UE.Constant.oClassName));
       if not _Name then break end
       TA=ReadPointer(_Address+UE.Constant.oClass);
       _Type=UE.GetNameFromObject(TA) or "";
       _IsEnumType,_IsStructType,_ScriptName, _Parent, _Super =(_Type and _Type=="Enum"),false, "", "", ""
       
       if _IsEnumType then
        _ScriptName=UE.GetNameFromObject(ReadPointer(_Address+0x20)) or "";
        _Parent,_Super="","";
       else
        _ScriptName=UE.GetNameFromObject(ReadPointer(_Address+0x20)) or "";
        _Parent=ReadPointer(_Address+UE.Constant.oSuper);
        if _Parent then;
         _Parent=UE.GetNameFromObject(_Parent) or "";
        else
         _Parent="";
        end
        hasPublic = UE.FlagFunctions.Contains(readInteger(_Address+0x8), UE.EObjectFlags, "RF_Public")
        _IsStructType=hasPublic;
       end
       
       local _EndCount=_IsEnumType and ReadInteger(_Address+UE.Constant.oEnumEndCount) or ReadInteger(_Address+UE.Constant.oEndCount);
       Members,StartCount,EndCount,CountOffset=_IsStructType and UE.GetObjectMembers(_Address) or (_IsEnumType and UE.GetEnumMembers(_Address) or nil);
       objects[R]={
        Name=_Name,
        Type=_Type,
        ScriptName=_ScriptName,
        Parent=_Parent,
        Address=_Address,
        Members=Members and ({Members=Members,StartCount=StartCount,EndCount=EndCount,CountOffset=CountOffset}) or nil;
        IsStructType=_IsStructType,
        IsEnumType=_IsEnumType,
        EndCount=_EndCount
       };
       objectCount = objectCount + 1
       R = R + 1;
      end
      sharedResults[threadId] = {
       chunkIndex = chunkIndex,
       objects = objects,
       objectCount = objectCount
      }
     end
    end
    
    for A=0,UE.ObjectChunksCount,1 do
     threadResults[A] = {}
     threadHandles[A] = createThread(chunkProcessor(A, UE.ObjectChunksArray[A], A, threadResults))
    end
    
    for A=0,UE.ObjectChunksCount,1 do
     threadHandles[A].waitfor()
     local result = threadResults[A]
     if result and result.objects then
       UE.ObjectChunksArray[result.chunkIndex].Array = result.objects
       UE.ObjectChunksArray[result.chunkIndex].Count = result.objectCount - 1
       totalObjectsProcessed = totalObjectsProcessed + result.objectCount
     end
    end
    
    UE.ObjectsCount = totalObjectsProcessed
    if UE.FillCustomObjects then
     UE.FillCustomObjects()
    end
    UE.CoreUObjectVFTable = ReadPointer(ReadPointer(UE.ObjectChunksArray[0].Address));
    end


   UE.Find=function();
    UE.FoundFinished=false;
    UE.MainUpdateEnabled=false;
    --OpenedProcessModules=nil;
    local NewModules=enumModules(getOpenedProcessID() )
    local _MainModule=NewModules[1].Address
    local time=os.clock();
    if _MainModule==nil or readInteger(_MainModule)==nil then;
     print("Please Open The Game Process First");
     return false;
    end
    local PeMetaData=NHA_CE.GetPEMetaData(_MainModule);
    if not OpenedProcessModules then;
     CodebaseStart=nil;
     StaticPointerBag=nil;
    elseif OpenedProcessModules and _MainModule~=OpenedProcessModules[1].Address then
     CodebaseStart=nil;
     StaticPointerBag=nil;
    end
    OpenedProcessModules=enumModules(getOpenedProcessID() )
    if CodebaseStart==nil or CodebaseStart==0 then
     CodebaseStart=_MainModule+PeMetaData.OptHeader.BaseOfCode;CodebaseStop=0;
     local n=0;
     for n = 0, PeMetaData.ImageFileHeader.NumberOfSections, 1 do
      if _MainModule+PeMetaData.ImageFileHeader.Sections[n].VirtualAddress==CodebaseStart then
       CodebaseStop=CodebaseStart+PeMetaData.ImageFileHeader.Sections[n].VirtualSize;
       print("Codebase: "..PeMetaData.ImageFileHeader.Sections[n].NameChars..", 0x"..string.format('%X', CodebaseStart).." -> 0x"..string.format('%X', CodebaseStop));
       break;
      end
     end
    if CodebaseStop==0 then;print("Failed To Find Correct Codebase!");return;end
    PointerbaseStart=0;PointerbaseStop=0;
    for n=0,PeMetaData.ImageFileHeader.NumberOfSections,1 do
     PointerbaseStart=_MainModule+PeMetaData.ImageFileHeader.Sections[n].VirtualAddress;
     local byteCheck=readByte(PointerbaseStart);
     if CodebaseStart~=PointerbaseStart and (byteCheck and byteCheck>0 and byteCheck<0x20) then
      PointerbaseStop=PointerbaseStart+PeMetaData.ImageFileHeader.Sections[n].VirtualSize;
      print("Pointerbase: "..PeMetaData.ImageFileHeader.Sections[n].NameChars..", 0x"..string.format('%X', PointerbaseStart).." -> 0x"..string.format('%X', PointerbaseStop));
      break;
     end;
    end
    if PointerbaseStop==0 then;print("Failed To Find Correct Pointerbase!");return;end
    end
    --UE.CodeBaseCopy={Start=CodebaseStart,Stop=CodebaseStop,Copy=copyMemory(CodebaseStart, CodebaseStop-CodebaseStart, nil, 1) };
   --UE.CodeBaseCopy.CopyStop=UE.CodeBaseCopy.Copy+(CodebaseStop-CodebaseStart);

    --Clear Caches
    UE.GlobalNameCache={};
    UE.PlayerClassTypes={};
    UE.StructureSizeCache={};
    UE.ClearPlayerCache();
    
    local stime=os.clock();
    if StaticPointerBag == nil or #StaticPointerBag > 0 then;--Aob Scan For Static Pointers
     local BagCount = 1
     StaticPointerBag = {}
     local threadResults = {}
     local threadHandles = {}
     local scanPatterns ={
      --If Known Patterns Fail, Run This:
      --{pattern = "48 8B 0D", name = "MOV RCX"},
      --{pattern = "48 8B 05", name = "MOV RAX"},
      --{pattern = "48 8D 0D", name = "LEA RCX"},
      --UObjectArray
      {pattern = "48 8B 0D ?? ?? ?? ?? 4? 89 ?2", name = "MOV RCX - mov ??,??"},
      --FNamePool:
      --{pattern = "48 8D 0D ?? ?? ?? ?? 48 8B 44 C1 10", name = "LEA RCX - mov rax,[rcx+rax*8+10]"},
      {pattern = "48 8D 0D ?? ?? ?? ?? E8 ?? ?? ?? ?? C6 05 ?? ?? ?? ?? 01", name = "LEA RCX - call - mov byte ptr[],1"}
      --{pattern = "48 8D 0D ?? ?? ?? ?? E8 ?? ?? ?? ?? C6 05 ?? ?? ?? ?? 01 8B ?? ?? ?? ?? ?? 48", name = "LEA RCX - call - mov byte ptr[],1 - mov ??,??, ??"}
      }
     
     local function threadWorker(pattern, patternName, threadId, sharedResults)
      return function()
       local results = {}
       local SCAN = NHA_CE.MultiScan(pattern, CodebaseStart+(0x1000), CodebaseStop-(0x1000))
       --print(string.format("%s: %d results found", patternName, #SCAN))
       local i,R,A = 0;
       for i = 1, #SCAN do
        A=tonumber(SCAN[i],16);
        R = UE.ReadX64R(A, 3)
        if R and (R >= PointerbaseStart and R <= PointerbaseStop) then
         results[#results+1]= {Instruction = A, Address = R};
        end
       end
       SCAN = nil
       --print(string.format("%s: %d valid pointers found", patternName, #results))
       sharedResults[threadId] = results
      end
     end
     
     for i, scanInfo in ipairs(scanPatterns) do
      threadResults[i] = {};
      threadHandles[i] = createThread(threadWorker(scanInfo.pattern, scanInfo.name, i, threadResults))
     end
     
     for i = 1, #threadHandles do;
      threadHandles[i].waitfor();
      for j = 1, #threadResults[i] do
       StaticPointerBag[BagCount] = threadResults[i][j];
       BagCount = BagCount + 1;
      end
     end
     threadResults=nil;
     BagCount = BagCount - 1
     print("Found Static Pointers: " .. BagCount)
     threadHandles=nil;
     printf("Finished ThreadedStaticPointerScan In: %f Seconds",os.clock()-stime);
    end

    local PTR=0;local CNT=0;local TST=0;
    do;--FName Finding Logic
     stime=os.clock();
     for i=1,#StaticPointerBag,1 do
      if readQword(StaticPointerBag[i].Address)==0 then;
       CNT=readInteger(StaticPointerBag[i].Address+0x8);
       if readQword(StaticPointerBag[i].Address+0x10+((CNT+1)*0x8))==0 then
        PTR=readQword(StaticPointerBag[i].Address+0x10);
        if PTR then;
         TST=readString(PTR,10);
         if TST and string.find(TST,"None") then
          PTR=StaticPointerBag[i].Instruction;
          break;
         end
        end
       end 
      end
      PTR=0;
     end
     if PTR~=0 then;
      UE.FNamePool=UE.ReadX64R(PTR,3,1);
      printf("FNamePool Ptr Found: 0x%s -> 0x%X, In: %f Seconds",PTR,UE.FNamePool,os.clock()-stime);
     else
      print("FNamePool Ptr Not Found!");
      return false;
     end
    end
   
    do;--UObject Array Finding Logic
     stime=os.clock();
     PTR=0;
     for i=1,#StaticPointerBag,1 do
      PTR=readQword(StaticPointerBag[i].Address);
      if PTR and PTR~=0 then;
       CNT=readQword(PTR);
       if CNT and CNT~=0 then;
        TST=readQword(CNT);
        if TST and TST~=0 then;
         TST=UE.GetNameFromObject(TST);
         if TST and TST=="/Script/CoreUObject" then
          --printf("%X, %s",StaticPointerBag[i].Address,None);
          TST=readQword(CNT+UE.Constant.oClassName);
          if TST and TST~=0 then;
           TST=UE.GetNameFromObject(TST);
           if TST and TST=="Object" then
            PTR=StaticPointerBag[i].Instruction;
            break;
           end
          end
         end
        end
       end
      end
      PTR=0;
     end
     if PTR~=0 then;
      UE.UObjectArray=UE.ReadX64R(PTR,3,1);
      printf("UObjectArray Ptr Found: 0x%s -> 0x%X, In: %f Seconds",PTR,UE.UObjectArray,os.clock()-stime);
      stime=os.clock();
      UE.FillUObjectArray();
      printf("UObjectArray Filled: Chunks: %i, Objects Found: %i, In: %f Seconds",UE.ObjectChunksCount,UE.ObjectsCount,os.clock()-stime);
     else
      print("UObjectArray Ptr Not Found!");
     end
    end
   
    do;--GEngine Finding Logic
     stime=os.clock();
     UE.GEngine=0;
     local Highest=UE.FindHighestParent("GameEngine");
     if not Highest then;
      print("UE.GameEngineObject Not Found!");
      return false;
     end
     print("GameEngine Class: "..Highest);
     UE.GameEngineObject=UE.GetObjectByNameAndScript(Highest,"/Engine/Transient");
     if UE.GameEngineObject~=nil then;
      UE.GEngine=UE.GameEngineObject.Address;
      printf("GameEngineObject Found: 0x%X, In: %f Seconds",UE.GEngine,os.clock()-stime);
     end
     if UE.GEngine==0 then;--Old GEngine Finding Logic
      PTR=0;
      for i=1,#StaticPointerBag,1 do
       PTR=readQword(StaticPointerBag[i].Address);
       if PTR and PTR~=0 then;
        TST=readInteger(PTR+UE.Constant.oClassName);
        if TST and TST>10 and TST<0xFFFFFFF and UE.GetName(TST)=="Engine.GameEngine" then
         PTR=StaticPointerBag[i].Instruction;
         break;
        end
        PTR=readQword(PTR+UE.Constant.oClass);--ReadClass
        if PTR and PTR~=0 then;
         TST=readInteger(PTR+UE.Constant.oClassName);
         if TST and TST>10 and TST<0xFFFFFFF and UE.GetName(TST)=="Engine.GameEngine" then
          PTR=StaticPointerBag[i].Instruction;
          break;
         end
        end
       end
      PTR=0;
      end
      if PTR~=0 then;
       UE.GEngine=ReadPointer(UE.ReadX64R(PTR,3,1));
       print("GEngine Ptr Found: "..PTR.." -> "..string.format('%X',UE.GEngine));
      else
       print("GEngine Ptr Not Found!");
      return false;
      end
     end
    end
   
    --Clear Symbol Caches
    UE.SymbolLookupCallbackCache={};
    UE.FoundFinished=true;
    UE.Offset={
     GameInstance=UE.GetOffsetBySymbol("GameEngine.GameInstance"),
     LocalPlayers=UE.GetOffsetBySymbol("GameInstance.LocalPlayers"),
     PlayerController=UE.GetOffsetBySymbol("player.PlayerController"),
     IsLocalPlayerController=UE.GetOffsetBySymbol("PlayerController.bIsLocalPlayerController"),
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
     Pawn=UE.GetOffsetBySymbol("Controller.Pawn"),
     Movement=UE.GetOffsetBySymbol("Character.CharacterMovement"),
     JumpCurrentCount=UE.GetOffsetBySymbol("Character.JumpCurrentCount"),
     GravityScale=UE.GetOffsetBySymbol("CharacterMovementComponent.GravityScale"),
     WalkableFloorAngle=UE.GetOffsetBySymbol("CharacterMovementComponent.WalkableFloorAngle"),
     WalkableFloorZ=UE.GetOffsetBySymbol("CharacterMovementComponent.WalkableFloorZ"),
     MaxStepHeight=UE.GetOffsetBySymbol("CharacterMovementComponent.MaxStepHeight"),
     AirControl=UE.GetOffsetBySymbol("CharacterMovementComponent.AirControl"),
     AirControlBoostMultiplier=UE.GetOffsetBySymbol("CharacterMovementComponent.AirControlBoostMultiplier"),
     AirControlBoostVelocityThreshold=UE.GetOffsetBySymbol("CharacterMovementComponent.AirControlBoostVelocityThreshold"),
     MaxWalkSpeed=UE.GetOffsetBySymbol("CharacterMovementComponent.MaxWalkSpeed"),
     MaxWalkSpeedCrouched=UE.GetOffsetBySymbol("CharacterMovementComponent.MaxWalkSpeedCrouched"),
     MaxSwimSpeed=UE.GetOffsetBySymbol("CharacterMovementComponent.MaxSwimSpeed"),
     MaxAcceleration=UE.GetOffsetBySymbol("CharacterMovementComponent.MaxAcceleration"),
     RootComponent=UE.GetOffsetBySymbol("Actor.RootComponent"),
    };
    if UE.InitOffsets then;UE.InitOffsets();end
    UE.MainUpdateEnabled=true;
    printf("Time For Completion: %f",os.clock()-time);
    return true;
    end;FNR("UE.Find");
  end
  do--Structure dissection
   UE.AddPaddingWithDetection = function(Struct, lastOffset, currentOffset, Instance, namePrefix)
    namePrefix = namePrefix or ""
    if currentOffset <= lastOffset then
     return lastOffset
    end
    local paddingSize = currentOffset - lastOffset
    local paddingStart = lastOffset
    local offset = paddingStart
    while offset < currentOffset do
     local remainingSize = currentOffset - offset
     local chunkSize = 0
     local detectedType = vtByte
     local handled = false
     if remainingSize >= 0x10 and (offset % 0x10 == 0) then
      local paddingElement1 = Struct.addElement()
      paddingElement1.Offset = offset
      paddingElement1.Size = 8
      paddingElement1.VarType = vtPointer
      paddingElement1.Name = string.format("%sPadding_0x%04X_Pointer1", namePrefix, offset)
      local paddingElement2 = Struct.addElement()
      paddingElement2.Offset = offset + 8
      paddingElement2.Size = 8
      paddingElement2.VarType = vtPointer
      paddingElement2.Name = string.format("%sPadding_0x%04X_Pointer2", namePrefix, offset + 8)
      offset = offset + 0x10
      handled = true
     end
     if not handled then
      if remainingSize >= 8 and (offset % 8 == 0) then
       chunkSize = 8
       detectedType = UE.DetectValueType(Instance + offset, 8)
      elseif remainingSize >= 4 and (offset % 4 == 0) then
       chunkSize = 4
       detectedType = UE.DetectValueType(Instance + offset, 4)
      elseif remainingSize >= 2 and (offset % 2 == 0) then
       chunkSize = 2
       detectedType = UE.DetectValueType(Instance + offset, 2)
      else
       chunkSize = 1
       detectedType = vtByte
      end
      if chunkSize > remainingSize then
       chunkSize = remainingSize
       detectedType = vtByte
      end
      local paddingElement = Struct.addElement()
      paddingElement.Offset = offset
      paddingElement.Size = chunkSize
      paddingElement.VarType = detectedType
      local typeName = "Unknown"
      local shouldSetNameAndContinue = false
      if detectedType == vtByte then 
          typeName = "Byte"
      elseif detectedType == vtWord then 
          typeName = "Short"
      elseif detectedType == vtDword then 
       local value = readInteger(Instance + offset)
       if value and value > 0 then
        local bits = {}
        for i = 0, 31 do
         if (value & (1 << i)) ~= 0 then
          table.insert(bits, i)
         end
        end
        if #bits > 1 and #bits < 16 then
         typeName = "Flags"
         paddingElement.Name = string.format("%sPadding_0x%04X_%s (Value: 0x%08X, Bits: [%s])", namePrefix, offset, typeName, value, table.concat(bits, ","))
         shouldSetNameAndContinue = true
        end
       end
       if not shouldSetNameAndContinue then
        typeName = "Int"
       end
      elseif detectedType == vtQword then 
       typeName = "Long"
      elseif detectedType == vtPointer then 
       typeName = "Pointer"
      elseif detectedType == vtSingle then 
       typeName = "Float"
      elseif detectedType == vtDouble then 
       typeName = "Double"
      end
      if not shouldSetNameAndContinue then
       paddingElement.Name = string.format("%sPadding_0x%04X_%s", namePrefix, offset, typeName)
      end
      offset = offset + chunkSize
     end
    end
    return currentOffset
    end;FNR("UE.AddPaddingWithDetection")
   
   UE.DetectStructureMembersFromMemory = function(instanceAddress, structName)
    if not instanceAddress or instanceAddress == 0 then return nil end
    if structName then
     local cachedObj = UE.GetObjectByName(structName)
     if cachedObj and cachedObj.IsStructType and cachedObj.Type == "DetectedClass" then
      print("Using cached detected structure for: " .. structName)
      return cachedObj.Members
     end
    end
    local Members, StartCount, EndCount, CountOffset = UE.GetObjectMembers(instanceAddress)
       
    if Members and structName then
     local detectedMembers = {
      Members = Members,
      StartCount = StartCount,
      EndCount = EndCount,
      CountOffset = CountOffset
     }
     local success = UE.CacheDetectedStructure(structName, instanceAddress, detectedMembers)
     if success then
      print(string.format("Cached detected structure '%s' with %d members to UObjectArray", structName, #Members + 1))
     end
     return detectedMembers
    elseif Members then
     return {
      Members = Members,
      StartCount = StartCount,
      EndCount = EndCount,
      CountOffset = CountOffset
     }
     elseif structName then
     print("No Members For: "..structName)
    end
    
    return nil
    end
   
   UE.CacheDetectedStructure = function(structName, instanceAddress, detectedMembers)
    if not structName or structName == "" then
     return false
    end
    local existing = UE.GetObjectByName(structName)
    if existing and existing.Type == "DetectedClass" then
     existing.Members = detectedMembers
     existing.EndCount = detectedMembers.EndCount
     existing.Address = instanceAddress
     print(string.format("Updated existing detected structure cache for: %s", structName))
     return true
    end
    local customObject = {
     Name = structName,
     Type = "DetectedClass",
     ScriptName = "",
     Parent = "",
     Address = instanceAddress,
     Members = detectedMembers,
     IsStructType = true,
     IsEnumType = false,
     PropTypeClass = "",
     EndCount = detectedMembers.EndCount
    }
    local targetChunkIndex = UE.ObjectChunksCount
    local targetObjectIndex = 0
    if UE.ObjectChunksArray[targetChunkIndex] and UE.ObjectChunksArray[targetChunkIndex].Count < 65535 then
     targetObjectIndex = UE.ObjectChunksArray[targetChunkIndex].Count + 1
    else
     targetChunkIndex = targetChunkIndex + 1
     UE.ObjectChunksArray[targetChunkIndex] = {
      Address = 0,
      Array = {},
      Count = 0,
      Index = targetChunkIndex
     }
     targetObjectIndex = 0
    end
    
    UE.ObjectChunksArray[targetChunkIndex].Array[targetObjectIndex] = customObject
    UE.ObjectChunksArray[targetChunkIndex].Count = targetObjectIndex
    
    if targetChunkIndex > UE.ObjectChunksCount then
     UE.ObjectChunksCount = targetChunkIndex
    end
    UE.ObjectsCount = UE.ObjectsCount + 1
    
    return true
    end
 
   UE.DissectOverrideKnownStaticPointer=function(Struct, Instance)
    local Ptd=nil;
    if Instance==UE.FNamePool then
    Ptd="FNamePool";
    elseif Instance==UE.UObjectArray then
    Ptd="UObjectArray";
    else
    return false;
    end
    Struct.Name = "Static Pointer To "..Ptd;
    Struct.Size = 8
    
    local VFT = Struct.addElement()
    VFT.Name ="-> "..Ptd;
    VFT.Offset = 0
    VFT.Size = 0x8
    VFT.VarType = vtPointer
    
    if Instance==UE.UObjectArray  then
    Struct.Size = 0x1C
    
    local MaxObj = Struct.addElement()
    MaxObj.Name ="Int MaxObjects";
    MaxObj.Offset = 0x10
    MaxObj.Size = 0x4
    MaxObj.VarType = vtDword
    
    local CurObj = Struct.addElement()
    CurObj.Name ="Int CurrentObjects";
    CurObj.Offset = 0x14
    CurObj.Size = 0x4
    CurObj.VarType = vtDword
    
    local MaxChunks = Struct.addElement()
    MaxChunks.Name ="Int MaxChunks";
    MaxChunks.Offset = 0x18
    MaxChunks.Size = 0x4
    MaxChunks.VarType = vtDword
    
    local CurChunks = Struct.addElement()
    CurChunks.Name ="Int CurrentChunks";
    CurChunks.Offset = 0x1C
    CurChunks.Size = 0x4
    CurChunks.VarType = vtDword
    end
    return true;
    end;FNR("UE.DissectOverrideKnownStaticPointer");
 
   UE.DissectOverrideClassDefinition=function(className,structName,Struct, Instance)
    Struct.Name = className.."Definition: "..structName;
    Struct.Size = 0x50
    
    local VFT = Struct.addElement()
    VFT.Name ="-> "..structName.."_VFT";
    VFT.Offset = 0
    VFT.Size = 0x8
    VFT.VarType = vtPointer
   
    local Unk = Struct.addElement()
    Unk.Name = "Int ObjectFlags";
    Unk.Offset = 0x8
    Unk.Size = 0x4
    Unk.VarType = vtCustom
    Unk.CustomType = UE.CustomTypes.EObjectFlags.CustomTypeLua
    
    local VFT = Struct.addElement()
    VFT.Name ="FName Name";
    VFT.Offset = UE.Constant.oClassName
    VFT.Size = 0x4
    VFT.VarType = vtCustom
    VFT.CustomType = UE.CustomTypes.FName.CustomTypeLua
    
    local Super_ = Struct.addElement()
    Super_.Name ="-> Super";
    Super_.Offset = UE.Constant.oSuper
    Super_.Size = 0x8
    Super_.VarType = vtPointer
    
    local ChildData=nil;local ChildData2=nil;
    local Member=nil;
    local MemberName="Member";
    Member = Struct.addElement()
    Member.Name ="-> "..MemberName;
    Member.Offset = UE.Constant.oChildren
    Member.Size = 0x8
    Member.VarType = vtPointer
    local C=0;
    local MemberAddress=ReadPointer(Instance+UE.Constant.oChildren);local CHQ=0;
    CHQ=readPointer(MemberAddress+0x10);
    if not (CHQ==nil or CHQ-0x1~=Instance) then;
     Member.ChildStruct = createStructure(Struct.Name .. ": "..MemberName)
     while true do
      ChildData = Member.ChildStruct.addElement()
      ChildData.Name ="-> Unknown";
      ChildData.Offset = 0x0
      ChildData.Size = 0x8
      ChildData.VarType = vtPointer
    
      ChildData = Member.ChildStruct.addElement()
      ChildData.Name ="-> PropertyType";
      ChildData.Offset = 0x8
      ChildData.Size = 0x8
      ChildData.VarType = vtPointer
   
      ChildData.ChildStruct = createStructure(Struct.Name .. ": "..MemberName..": PropertyType")
      ChildData2 = ChildData.ChildStruct.addElement();
      ChildData2.Name ="FName PropertyType";
      ChildData2.Offset = 0x0
      ChildData2.Size = 0x4
      ChildData2.VarType = vtCustom
      ChildData2.CustomType = UE.CustomTypes.FName.CustomTypeLua
    
      ChildData = Member.ChildStruct.addElement()
      ChildData.Name ="FName Name";
      ChildData.Offset = 0x20
      ChildData.Size = 0x4
      ChildData.VarType = vtCustom
      ChildData.CustomType = UE.CustomTypes.FName.CustomTypeLua
    
      ChildData = Member.ChildStruct.addElement()
      ChildData.Name ="ByteSize";
      ChildData.Offset = 0x34
      ChildData.Size = 0x4
      ChildData.VarType = vtDword
      ChildData.DisplayMethod='dtHexadecimal';
    
      ChildData = Member.ChildStruct.addElement()
      ChildData.Name ="Offset";
      ChildData.Offset = 0x44
      ChildData.Size = 0x4
      ChildData.VarType = vtDword
      ChildData.DisplayMethod='dtHexadecimal';
    
      ChildData = Member.ChildStruct.addElement()
      ChildData.Name ="-> PropertyTypeClass";
      ChildData.Offset = 0x70
      ChildData.Size = 0x8
      ChildData.VarType = vtPointer
   
      ChildData = Member.ChildStruct.addElement()
      ChildData.Name ="-> Inner (PropertyType)";
      ChildData.Offset = 0x88
      ChildData.Size = 0x8
      ChildData.VarType = vtPointer
      ChildData.ChildStruct = createStructure(Struct.Name .. ": "..MemberName..": PropertyType.Inner")
      ChildData2 = ChildData.ChildStruct.addElement();
      ChildData2.Name ="FName PropertyType";
      ChildData2.Offset = 0x0
      ChildData2.Size = 0x4
      ChildData2.VarType = vtCustom
      ChildData2.CustomType = UE.CustomTypes.FName.CustomTypeLua
      MemberAddress=ReadPointer(MemberAddress+UE.Constant.oNext2);
      CHQ=readPointer(MemberAddress+0x10);
      C=C+1;
      if CHQ==nil or CHQ-0x1~=Instance then;break;end
      ChildData = Member.ChildStruct.addElement()
      ChildData.Name ="-> "..MemberName;
      ChildData.Offset = UE.Constant.oNext2
      ChildData.Size = 0x8
      ChildData.VarType = vtPointer
      ChildData.DisplayMethod='dtHexadecimal';
      ChildData.ChildStruct = createStructure(Struct.Name .. ": "..MemberName..": PropertyType");
      Member=ChildData;
     end
     print(C.." Members Found!");
    else
     Member.Name ="No Members Found";
    end
    
    local EndCount = Struct.addElement()
    EndCount.Name ="Int EndCount";
    EndCount.Offset = UE.Constant.oEndCount
    EndCount.Size = 0x8
    EndCount.VarType = vtDword
    return true;
    end;FNR("UE.DissectOverrideClassDefinition");
   
   UE.StructureDissectOverrideCallback = function(Struct, Instance)
    if not UE.FoundFinished or UE.FoundFinished==false then
     return false;
    end
    Struct.beginUpdate();
    if UE.DissectOverrideKnownStaticPointer(Struct, Instance) then
     Struct.endUpdate();
     return true;
    end
    local structName = nil;
    local _IsStructType=false;
    local ClassNameInstance=readQword(Instance+UE.Constant.oClass);
    local TST=ClassNameInstance and readInteger(ClassNameInstance+UE.Constant.oClassName) or nil;
    if not ClassNameInstance or ClassNameInstance==0 or not TST or TST==0 or TST>0xFFFFFFF then;Struct.endUpdate();return nil;end
    local className=UE.GetName(TST);
    local structName =UE.GetNameFromObject(Instance);
    _IsStructType=className and (className=="Class" or className=="Struct" or className=="ScriptStruct") or false;
    local _Super=nil;
    if not _IsStructType then;
     local SuperB=ReadPointer(ClassNameInstance+UE.Constant.oSuper);
     local SuperA=0;
     for SuperA=0,5,1 do
      SuperB=ReadPointer(SuperB+UE.Constant.oSuper);
      if not SuperB then;break;end
      _Super=UE.GetNameFromObject(SuperB) or "";
      if not _Super then;break;end
      if _Super and (_Super=="Class" or _Super=="Struct" or _Super=="ScriptStruct") then;_IsStructType=true;break;end
     end
    end
   
    if _IsStructType then;
     UE.DissectOverrideClassDefinition(className,structName,Struct,Instance);
     Struct.endUpdate();
     return true;
    end
    className=structName;
    if not structName then;
     Struct.endUpdate();
     return nil;
    end
    local classObject = nil
    if not classObject then
     local classAddress = readPointer(Instance + UE.Constant.oClass)
     if classAddress then
      local classNameId = readInteger(classAddress + UE.Constant.oClassName)
      if classNameId then
       local className = UE.GetName(classNameId)
       if className then
        for i = 0, UE.ObjectChunksCount do
         if UE.ObjectChunksArray[i] then
          for j = 0, UE.ObjectChunksArray[i].Count do
           local obj = UE.ObjectChunksArray[i].Array[j]
           if obj and obj.Name == className then
            classObject = obj
            structName = className
            break
           end
          end
         end
         if classObject then break end
        end
       end
      end
     end
    end
   
    if not classObject then
     print("Class definition not found in UObjectArray for: " .. structName .. ", attempting runtime detection...")
     local detectedMembers = UE.DetectStructureMembersFromMemory(ReadPointer(Instance+UE.Constant.oClass), structName)
     
     if detectedMembers then
      print("Successfully detected " .. (#detectedMembers.Members + 1) .. " members from memory for " .. structName)
      classObject = UE.GetObjectByName(structName)
      if not classObject then
       classObject = {
        Name = structName,
        Type = "DetectedClass",
        IsStructType = true,
        Members = detectedMembers,
        EndCount = detectedMembers.EndCount
       }
      end
     else
      print("Failed to detect members from memory for: " .. structName)
      Struct.endUpdate()
      return nil
     end
    end
   
    local function collectInheritedMembers(className, visitedClasses)
     visitedClasses = visitedClasses or {}
     local allMembers = {}
     if visitedClasses[className] then
      return allMembers
     end
     visitedClasses[className] = true
     local currentClassObj = nil
     for i = 0, UE.ObjectChunksCount do
      if UE.ObjectChunksArray[i] then
       for j = 0, UE.ObjectChunksArray[i].Count do
        local obj = UE.ObjectChunksArray[i].Array[j]
        if obj and obj.Name == className and obj.IsStructType then
         currentClassObj = obj
         break
        end
       end
      end
      if currentClassObj then break end
     end
     if not currentClassObj then
      return allMembers
     end
     if currentClassObj.Parent and currentClassObj.Parent ~= "" then
      local parentMembers = collectInheritedMembers(currentClassObj.Parent, visitedClasses)
      for _, member in ipairs(parentMembers) do
       table.insert(allMembers, member)
      end
     end
     if currentClassObj.Members and currentClassObj.Members.Members then
      for i = 0, #currentClassObj.Members.Members do
       if currentClassObj.Members.Members[i] then
        local member = currentClassObj.Members.Members[i]
        local memberCopy = {
         Name = member.Name,
         PropType = member.PropType,
         PropTypeClass = member.PropTypeClass,
         Offset = member.Offset,
         ByteSize = member.ByteSize,
         Address = member.Address,
         SourceClass = className
        }
        table.insert(allMembers, memberCopy)
       end
      end
     end
     return allMembers
    end
   
    local allMembers = collectInheritedMembers(structName)
   
    local totalSize = 0
    if #allMembers > 0 then
     table.sort(allMembers, function(a, b) return a.Offset < b.Offset end)
     local lastMember = allMembers[#allMembers]
     totalSize = lastMember.Offset + lastMember.ByteSize
    else
     totalSize = classObject.Members and classObject.Members.CountOffset or 0x1000
    end
    Struct.Name = structName
    Struct.Size = totalSize
    if classObject.Parent and classObject.Parent ~= "" then
     local inheritanceChain = UE.GetInheritanceChain(structName)
     if #inheritanceChain > 1 then
      local chainStr = table.concat(inheritanceChain, " -> ")
      Struct.Name = structName .. " (Inheritance: " .. chainStr .. ")"
     end
    end
   
    local VFT = Struct.addElement()
    VFT.Name = "-> " .. structName .. "_VFTABLE";
    VFT.Offset = 0
    VFT.Size = 0x8
    VFT.VarType = vtPointer
   
    local Unk = Struct.addElement()
    Unk.Name = "Int ObjectFlags";
    Unk.Offset = 0x8
    Unk.Size = 0x4
    Unk.VarType = vtCustom
    Unk.CustomType = UE.CustomTypes.EObjectFlags.CustomTypeLua
   
    local ObjectID = Struct.addElement()
    ObjectID.Name = "Int ObjectIndex";
    ObjectID.Offset = 0xC
    ObjectID.Size = 0x4
    ObjectID.VarType = vtDword
   
    local Class = Struct.addElement()
    Class.Name = "-> Class";
    Class.Offset = UE.Constant.oClass
    Class.Size = 0x8
    Class.VarType = vtPointer
   
    local FNameId = Struct.addElement()
    FNameId.Name = "FName";
    FNameId.Offset = UE.Constant.oClassName
    FNameId.Size = 0x8
    FNameId.CustomType=UE.CustomTypes.FName.CustomTypeLua
    FNameId.VarType=vtCustom 
   
    local Outer = Struct.addElement()
    Outer.Name = "-> Outer";
    Outer.Offset = 0x20
    Outer.Size = 0x8
    Outer.VarType = vtPointer
   
    local function getUEVariableTypeInfo(propType, byteSize)
     local varTypeStr = "Byte"
     local varType = vtByte -- default
     local CustomType=nil;
     if propType == "ByteProperty" or propType == "UInt8Property" then
      varType = vtByte
      varTypeStr = "Byte"
     elseif propType == "UInt16Property" or propType == "ShortProperty" then
      varType = vtWord
      varTypeStr = "Short"
     elseif propType == "UInt32Property" or propType == "IntProperty" then
      varType = vtDword
      varTypeStr = "Int"
     elseif propType == "UInt64Property" or propType == "Int64Property" then
      varType = vtQword
      varTypeStr = "Long"
     elseif propType == "FloatProperty" then
      varType = vtSingle
      varTypeStr = "Float"
     elseif propType == "DoubleProperty" then
      varType = vtDouble
      varTypeStr = "Double"
     elseif propType == "BoolProperty" then
      varType = vtByte
      varTypeStr = "Bool"
     elseif propType == "NameProperty" then
      varType = vtCustom
      varTypeStr = "FName"
      CustomType=UE.CustomTypes.FName.CustomTypeLua
     elseif propType == "StrProperty" or propType == "StringProperty" then
      varType = vtPointer
      varTypeStr = "FString"
     elseif propType == "StructProperty" or propType=="GbxDefPtrProperty" then
      varType = vtBinary
      varTypeStr = "Struct"
     elseif propType == "EnumProperty" then
      varType = vtDword
      varTypeStr = "Enum"
     elseif propType == "ObjectProperty" or propType == "WeakObjectProperty" or propType == "LazyObjectProperty" or propType == "SoftObjectProperty" or string.find(propType, "Property") then
      varType = vtPointer
      varTypeStr = "->"
     elseif propType == "ArrayProperty" then
      varType = vtPointer
      varTypeStr = "TArray"
     elseif byteSize == 1 then
      varType = vtByte
      varTypeStr = "Byte"
     elseif byteSize == 2 then
      varType = vtWord
      varTypeStr = "Short"
     elseif byteSize == 4 then
      varType = vtDword
      varTypeStr = "Int"
     elseif byteSize == 8 then
      varType = vtQword
      varTypeStr = "Long"
     else
      varType = vtBinary
      varTypeStr = propType or "Unknown"
     end
     return varTypeStr, varType,CustomType
    end
    
    local function getMemberAlignment(propType, byteSize)
     if propType == "BoolProperty" then
      return 1
     elseif propType == "ByteProperty" or propType == "UInt8Property" then
      return 1
     elseif propType == "UInt16Property" or propType == "ShortProperty" then
      return 2
     elseif propType == "UInt32Property" or propType == "IntProperty" or
            propType == "FloatProperty" or propType == "EnumProperty" then
      return 4
     elseif propType == "UInt64Property" or propType == "Int64Property" or
            propType == "DoubleProperty" or propType == "NameProperty" or
            propType == "StrProperty" or propType == "StringProperty" or
            propType == "ArrayProperty" or string.find(propType, "Property") then
      return 8
     else
      return math.min(byteSize, 8)
     end
    end
   
    local function createFStringElement(Struct, member, namePrefix, actualInstance)
     local element = Struct.addElement()
     element.Offset = member.Offset
     element.Size = 8
     element.VarType = vtPointer
     element.Name = namePrefix .. "FString " .. member.Name
   
     element.ChildStruct = createStructure(string.format("%X", actualInstance) .. "_" .. member.Name .. "_FStringData")
     local ChildData = element.ChildStruct.addElement()
     ChildData.Offset = 0
   
     local CSize = readInteger(actualInstance + member.Offset + 0xC)
     if CSize and CSize > 0 then
      ChildData.Bytesize = (CSize * 2) + 1
     else
      ChildData.Bytesize = 0
     end
     ChildData.VarType = vtUnicodeString
     ChildData.Name = "String"
     element.ChildStructStart = 0
   
     local Countelement = Struct.addElement()
     Countelement.Offset = member.Offset + 0x8
     Countelement.Size = 4
     Countelement.VarType = vtDword
     Countelement.Name = namePrefix .. "Int " .. member.Name .. ".Count"
   
     local Maxelement = Struct.addElement()
     Maxelement.Offset = member.Offset + 0xC
     Maxelement.Size = 4
     Maxelement.VarType = vtDword
     Maxelement.Name = namePrefix .. "Int " .. member.Name .. ".Max"
    end
   
    local function createTArrayElement(Struct, member, namePrefix, actualInstance)
     local dataPointer = readPointer(actualInstance + member.Offset)
     local count = readInteger(actualInstance + member.Offset + 0x8) or 0
     local max = readInteger(actualInstance + member.Offset + 0xC) or 0
     local TypeName = member.PropTypeClass
     if not TypeName then TypeName = member.PropType or "Object" end
     if not TypeName or #TypeName <= 0 then TypeName = "Object" end
     local structObj = UE.GetObjectByName(TypeName)
     local isClassType = structObj and structObj.Type == "Class"
     local isEnumType = structObj and structObj.Type == "Enum"
     local elementSize = 0x8
     if not isClassType and structObj then
      if structObj.EndCount and structObj.EndCount > 0 then
       elementSize = structObj.EndCount
      elseif structObj.Members and structObj.Members.EndCount and structObj.Members.EndCount > 0 then
       elementSize = structObj.Members.EndCount
      elseif structObj.StructureSize and structObj.StructureSize > 0 then
       elementSize = structObj.StructureSize
      else
       if structObj.Members and structObj.Members.Members then
        local maxOffset = 0
        local maxSize = 0
        for i = 0, #structObj.Members.Members do
         if structObj.Members.Members[i] then
          local member = structObj.Members.Members[i]
          local memberEnd = member.Offset + member.ByteSize
          if memberEnd > maxOffset + maxSize then
           maxOffset = member.Offset
           maxSize = member.ByteSize
          end
         end
        end
        elementSize = maxOffset + maxSize
       else
        elementSize = 0x8
       end
      end
      local structAlignment = 8
      if elementSize <= 4 then
       structAlignment = 4
      elseif elementSize <= 8 then
       structAlignment = 8
      else
       structAlignment = 8
      end
      elementSize = UE.AlignOffset(elementSize, structAlignment)
     elseif isEnumType then
      elementSize = 4
     end
     local dataElement = Struct.addElement()
     dataElement.Name = namePrefix .. "-> " .. member.Name .. ".Data (TArray<" .. TypeName .. "> Count:" .. count .. " Max:" .. max .. " ElementSize:0x" .. string.format("%X", elementSize) .. ")"
     dataElement.Offset = member.Offset
     dataElement.Size = 0x8
     dataElement.VarType = vtPointer
     dataElement.ChildStruct = createStructure(dataElement.Name)
     if dataPointer and dataPointer ~= 0 and count > 0 then
      local elementsToShow = math.min(count, 165)
      for arrayIndex = 0, elementsToShow - 1 do
       local elementBaseOffset = arrayIndex * elementSize
       if isClassType then
        local arrayElement = dataElement.ChildStruct.addElement()
        arrayElement.Name = namePrefix .. string.format("[%d] -> %s", arrayIndex, TypeName)
        arrayElement.Offset = elementBaseOffset
        arrayElement.Size = 0x8
        arrayElement.VarType = vtPointer
       elseif isEnumType then
        local arrayElement = dataElement.ChildStruct.addElement()
        arrayElement.Name = namePrefix .. string.format("[%d] %s %s", arrayIndex, TypeName, "Value")
        arrayElement.Offset = elementBaseOffset
        arrayElement.Size = 4
        arrayElement.VarType = vtDword
       else
        local function collectTArrayElementMembersWithEndCount(className, visitedClasses, baseOffset, depth)
        visitedClasses = visitedClasses or {}
        baseOffset = baseOffset or 0
        depth = depth or 0
        local allMembers = {}
   
        if visitedClasses[className] or depth > 5 then
         return allMembers
        end
        visitedClasses[className] = true
   
        local currentClassObj = nil
        for i = 0, UE.ObjectChunksCount do
         if UE.ObjectChunksArray[i] then
          for j = 0, UE.ObjectChunksArray[i].Count do
           local obj = UE.ObjectChunksArray[i].Array[j]
           if obj and obj.Name == className and obj.IsStructType then
            currentClassObj = obj
            break
           end
          end
         end
         if currentClassObj then break end
        end
   
        if not currentClassObj then
         return allMembers
        end
   
        if currentClassObj.Parent and currentClassObj.Parent ~= "" then
         local parentMembers = collectTArrayElementMembersWithEndCount(currentClassObj.Parent, visitedClasses, baseOffset, depth + 1)
         for _, parentMember in ipairs(parentMembers) do
          table.insert(allMembers, parentMember)
         end
        end
   
        if currentClassObj.Members and currentClassObj.Members.Members then
         local structEndCount = currentClassObj.EndCount or (currentClassObj.Members and currentClassObj.Members.EndCount) or 0
         for i = 0, #currentClassObj.Members.Members do
          if currentClassObj.Members.Members[i] then
           local structMember = currentClassObj.Members.Members[i]
           if structEndCount == 0 or structMember.Offset < structEndCount then
            local memberAlignment = getMemberAlignment(structMember.PropType, structMember.ByteSize)
            local finalOffset = baseOffset + structMember.Offset
            local arrayMemberCopy = {
             Name = structMember.Name,
             PropType = structMember.PropType,
             PropTypeClass = structMember.PropTypeClass,
             Inner = structMember.Inner,
             Offset = finalOffset,
             ByteSize = structMember.ByteSize,
             Address = structMember.Address,
             SourceClass = className,
             ArrayIndex = arrayIndex,
             ElementTypeName = TypeName,
             Depth = depth,
             MemberAlignment = memberAlignment,
             OriginalOffset = structMember.Offset,
             StructEndCount = structEndCount
            }
            table.insert(allMembers, arrayMemberCopy)
           end
          end
         end
        end
       return allMembers
      end
   
                  local function processTArrayElementWithEndCount(elementMember, elementPrefix, depth)
                   depth = depth or 0
                   if depth > 4 then
                    local element = dataElement.ChildStruct.addElement()
                    element.Name = elementPrefix .. "..." .. elementMember.Name .. " (max depth reached)"
                    element.Offset = elementMember.Offset
                    element.Size = elementMember.ByteSize
                    element.VarType = vtBinary
                    return
                   end
   
                   if elementMember.PropType == "StrProperty" or elementMember.PropType == "StringProperty" then
                    local element = dataElement.ChildStruct.addElement()
                    element.Name = elementPrefix .. "FString " .. elementMember.Name
                    element.Offset = elementMember.Offset
                    element.Size = 0x8
                    element.VarType = vtPointer
   
                    local countElement = dataElement.ChildStruct.addElement()
                    countElement.Name = elementPrefix .. "Int " .. elementMember.Name .. ".Count"
                    countElement.Offset = elementMember.Offset + 0x8
                    countElement.Size = 0x4
                    countElement.VarType = vtDword
   
                    local maxElement = dataElement.ChildStruct.addElement()
                    maxElement.Name = elementPrefix .. "Int " .. elementMember.Name .. ".Max"
                    maxElement.Offset = elementMember.Offset + 0xC
                    maxElement.Size = 0x4
                    maxElement.VarType = vtDword
   
                   elseif elementMember.PropType == "ArrayProperty" then
                    local nestedArrayTypeName = elementMember.PropTypeClass or "Object"
                    local nestedArrayElement = dataElement.ChildStruct.addElement()
                    nestedArrayElement.Name = elementPrefix .. "TArray<" .. nestedArrayTypeName .. "> " .. elementMember.Name
                    nestedArrayElement.Offset = elementMember.Offset
                    nestedArrayElement.Size = 0x8
                    nestedArrayElement.VarType = vtPointer
   
                    local countElement = dataElement.ChildStruct.addElement()
                    countElement.Name = elementPrefix .. "Int " .. elementMember.Name .. ".Count"
                    countElement.Offset = elementMember.Offset + 0x8
                    countElement.Size = 0x4
                    countElement.VarType = vtDword
   
                    local maxElement = dataElement.ChildStruct.addElement()
                    maxElement.Name = elementPrefix .. "Int " .. elementMember.Name .. ".Max"
                    maxElement.Offset = elementMember.Offset + 0xC
                    maxElement.Size = 0x4
                    maxElement.VarType = vtDword
                   
                   elseif elementMember.PropType == "StructProperty" or elementMember.PropType=="GbxDefPtrProperty" then
                          local nestedStructTypeName = elementMember.PropTypeClass
                          if nestedStructTypeName and nestedStructTypeName ~= "" then
                              local nestedStructObj = UE.GetObjectByName(nestedStructTypeName)
                              if nestedStructObj and nestedStructObj.IsStructType then
                                  local nestedStructSize = nestedStructObj.EndCount or
                                                         (nestedStructObj.Members and nestedStructObj.Members.EndCount) or
                                                         elementMember.ByteSize
   
                                  local nestedStructMembers = collectTArrayElementMembersWithEndCount(nestedStructTypeName, {}, elementMember.Offset, depth + 1)
   
                                  if #nestedStructMembers > 0 then
                                      table.sort(nestedStructMembers, function(a, b) return a.Offset < b.Offset end)
   
                                      for _, nestedMember in ipairs(nestedStructMembers) do
                                          local nestedPrefix = elementPrefix .. elementMember.Name .. "."
                                          processTArrayElementWithEndCount(nestedMember, nestedPrefix, depth + 1)
                                      end
   
                                      if #nestedStructMembers > 0 then
                                          local lastMember = nestedStructMembers[#nestedStructMembers]
                                          local naturalEnd = lastMember.Offset + lastMember.ByteSize - elementMember.Offset
                                          if naturalEnd < nestedStructSize then
                                              local paddingElement = dataElement.ChildStruct.addElement()
                                              paddingElement.Name = elementPrefix .. elementMember.Name .. ".Padding (EndCount-based)"
                                              paddingElement.Offset = elementMember.Offset + naturalEnd
                                              paddingElement.Size = nestedStructSize - naturalEnd
                                              paddingElement.VarType = vtBinary
                                          end
                                      end
                                  else
                                      local element = dataElement.ChildStruct.addElement()
                                      element.Name = elementPrefix .. "Struct " .. elementMember.Name .. " (" .. nestedStructTypeName .. ", EndCount: 0x" .. string.format("%X", nestedStructSize) .. ")"
                                      element.Offset = elementMember.Offset
                                      element.Size = nestedStructSize
                                      element.VarType = vtBinary
                                  end
                              else
                                  local element = dataElement.ChildStruct.addElement()
                                  element.Name = elementPrefix .. "Struct " .. elementMember.Name .. " (unknown type)"
                                  element.Offset = elementMember.Offset
                                  element.Size = elementMember.ByteSize
                                  element.VarType = vtBinary
                              end
                          else
                              local element = dataElement.ChildStruct.addElement()
                              element.Name = elementPrefix .. "Struct " .. elementMember.Name .. " (no type info)"
                              element.Offset = elementMember.Offset
                              element.Size = elementMember.ByteSize
                              element.VarType = vtBinary
                          end
   
                      elseif elementMember.PropType == "EnumProperty" then
                          local enumTypeName = elementMember.PropTypeClass or "UnknownEnum"
                          local element = dataElement.ChildStruct.addElement()
                          element.Name = elementPrefix .. enumTypeName .. " " .. elementMember.Name
                          element.Offset = elementMember.Offset
                          element.Size = elementMember.ByteSize
                          element.VarType = vtDword
   
                      else
                          local nestedElement = dataElement.ChildStruct.addElement()
                          local varTypeStr, varType, customType = getUEVariableTypeInfo(elementMember.PropType, elementMember.ByteSize)
                          nestedElement.Name = elementPrefix .. varTypeStr .. " " .. elementMember.Name
                          nestedElement.Offset = elementMember.Offset
                          nestedElement.Size = elementMember.ByteSize
                          nestedElement.VarType = varType
   
                          if customType then
                              nestedElement.CustomType = customType
                          elseif elementMember.PropType == "NameProperty" then
                              nestedElement.VarType = vtCustom
                              nestedElement.CustomType = UE.CustomTypes.FName.CustomTypeLua
                              nestedElement.Name = elementPrefix .. "FName " .. elementMember.Name
                          end
                      end
                  end
   
                  if structObj and structObj.Members and structObj.Members.Members then
                      local elementMembers = collectTArrayElementMembersWithEndCount(TypeName, {}, elementBaseOffset, 0)
   
                      if #elementMembers > 0 then
                          table.sort(elementMembers, function(a, b) return a.Offset < b.Offset end)
   
                          for _, elementMember in ipairs(elementMembers) do
                              local elementPrefix = namePrefix .. string.format("[%d].", arrayIndex)
                              processTArrayElementWithEndCount(elementMember, elementPrefix, 0)
                          end
   
                          if #elementMembers > 0 then
                              local lastMember = elementMembers[#elementMembers]
                              local naturalStructEnd = lastMember.Offset + lastMember.ByteSize - elementBaseOffset
                              local endCountSize = structObj.EndCount or (structObj.Members and structObj.Members.EndCount) or elementSize
   
                              if naturalStructEnd < endCountSize then
                                  local paddingElement = dataElement.ChildStruct.addElement()
                                  paddingElement.Name = namePrefix .. string.format("[%d] EndCount Padding (0x%X bytes)", arrayIndex, endCountSize - naturalStructEnd)
                                  paddingElement.Offset = elementBaseOffset + naturalStructEnd
                                  paddingElement.Size = endCountSize - naturalStructEnd
                                  paddingElement.VarType = vtBinary
                              end
                          end
                      else
                          local structSize = structObj.EndCount or (structObj.Members and structObj.Members.EndCount) or elementSize
                          local arrayElement = dataElement.ChildStruct.addElement()
                          arrayElement.Name = namePrefix .. string.format("[%d] %s (no member info, EndCount: 0x%X)", arrayIndex, TypeName, structSize)
                          arrayElement.Offset = elementBaseOffset
                          arrayElement.Size = structSize
                          arrayElement.VarType = vtBinary
                      end
                  else
                      local arrayElement = dataElement.ChildStruct.addElement()
                      arrayElement.Name = namePrefix .. string.format("[%d] %s (no member info)", arrayIndex, TypeName)
                      arrayElement.Offset = elementBaseOffset
                      arrayElement.Size = elementSize
                      arrayElement.VarType = vtBinary
                  end
              end
          end
   
          if count > elementsToShow then
              local noteElement = dataElement.ChildStruct.addElement()
              noteElement.Name = namePrefix .. string.format("... +%d more %s elements (truncated)", count - elementsToShow, TypeName)
              noteElement.Offset = (elementsToShow * elementSize)
              noteElement.Size = 4
              noteElement.VarType = vtBinary
          end
      end
   
      local countElement = Struct.addElement()
      countElement.Name = namePrefix .. "Int " .. member.Name .. ".Count"
      countElement.Offset = member.Offset + 0x8
      countElement.Size = 0x4
      countElement.VarType = vtDword

      local maxElement = Struct.addElement()
      maxElement.Name = namePrefix .. "Int " .. member.Name .. ".Max"
      maxElement.Offset = member.Offset + 0xC
      maxElement.Size = 0x4
      maxElement.VarType = vtDword
    end
   
    local function createStructPropertyElement(Struct, member, namePrefix, actualInstance, depth)
     depth = depth or 0
     if depth > 4 then 
      local element = Struct.addElement()
      element.Offset = member.Offset
      element.Size = member.ByteSize
      element.VarType = vtBinary
      element.Name = namePrefix .. "Struct " .. member.Name .. " (depth limit reached)"
      return
     end
   
     local structTypeName = member.PropTypeClass
     if not structTypeName or structTypeName == "" then
      structTypeName = member.Inner
     end
     if not structTypeName or structTypeName == "" then
      if member.PropType and (member.PropType ~= "StructProperty" and member.PropType~="GbxDefPtrProperty") then
       structTypeName = member.PropType:gsub("Property", "")
       end
     end
     if not structTypeName or structTypeName == "" then
      print("Warning: StructProperty " .. (member.Name or "unknown") .. " has no type information")
      local element = Struct.addElement()
      element.Offset = member.Offset
      element.Size = member.ByteSize
      element.VarType = vtBinary
      element.Name = namePrefix .. "Struct " .. (member.Name or "unknown") .. " (no type info)"
      return
     end
   
     local structObj = UE.GetObjectByName(structTypeName)
     if not structObj or not structObj.IsStructType then
      if not structObj then
       local altNames = {
        "F" .. structTypeName,
        "U" .. structTypeName,
        "A" .. structTypeName,
        structTypeName .. "Struct"
       }
       for _, altName in ipairs(altNames) do
        structObj = UE.GetObjectByName(altName)
        if structObj and structObj.IsStructType then
         structTypeName = altName
         break
        end
       end
      end
      if not structObj or not structObj.IsStructType then
       local element = Struct.addElement()
       element.Offset = member.Offset
       element.Size = member.ByteSize
       element.VarType = vtBinary
       element.Name = namePrefix .. "Struct " .. member.Name .. " (" .. structTypeName .. " - no definition)"
       return
      end
     end
   
     local function collectNestedStructMembersRecursive(className, visitedClasses, baseOffset, nestedDepth)
       visitedClasses = visitedClasses or {}
       baseOffset = baseOffset or 0
       nestedDepth = nestedDepth or 0
       local allMembers = {}
       if visitedClasses[className] or nestedDepth > 6 then
        return allMembers
       end
       visitedClasses[className] = true
       local currentClassObj = nil
       for i = 0, UE.ObjectChunksCount do
        if UE.ObjectChunksArray[i] then
         for j = 0, UE.ObjectChunksArray[i].Count do
          local obj = UE.ObjectChunksArray[i].Array[j]
          if obj and obj.Name == className and obj.IsStructType then
           currentClassObj = obj
           break
          end
         end
        end
        if currentClassObj then break end
       end
       if not currentClassObj then
        return allMembers
       end
       if currentClassObj.Parent and currentClassObj.Parent ~= "" then
        local parentMembers = collectNestedStructMembersRecursive(currentClassObj.Parent, visitedClasses, baseOffset, nestedDepth + 1)
        for _, nestedMember in ipairs(parentMembers) do
         table.insert(allMembers, nestedMember)
        end
       end
       if currentClassObj.Members and currentClassObj.Members.Members then
        for i = 0, #currentClassObj.Members.Members do
         if currentClassObj.Members.Members[i] then
          local structMember = currentClassObj.Members.Members[i]
          local memberAlignment = math.min(structMember.ByteSize, 8)
          local alignedOffset = UE.AlignOffset(structMember.Offset, memberAlignment)
          local nestedMemberCopy = {
           Name = structMember.Name,
           PropType = structMember.PropType,
           PropTypeClass = structMember.PropTypeClass,
           Inner = structMember.Inner,
           Offset = baseOffset + alignedOffset,
           ByteSize = structMember.ByteSize,
           Address = structMember.Address,
           SourceClass = className,
           ParentStructName = structTypeName,
           Depth = nestedDepth
          }
          table.insert(allMembers, nestedMemberCopy)
         end
        end
       end
       return allMembers
     end
   
     local nestedMembers = collectNestedStructMembersRecursive(structTypeName, {}, member.Offset, 0)
     if #nestedMembers > 0 then
      table.sort(nestedMembers, function(a, b) return a.Offset < b.Offset end)
      for _, nestedMember in ipairs(nestedMembers) do
       local nestedPrefix = namePrefix .. member.Name .. "."
       if nestedMember.PropType == "StrProperty" or nestedMember.PropType == "StringProperty" then
        createFStringElement(Struct, nestedMember, nestedPrefix, actualInstance)
       elseif nestedMember.PropType == "ArrayProperty" then
        createTArrayElement(Struct, nestedMember, nestedPrefix, actualInstance)
       elseif nestedMember.PropType == "StructProperty" or member.PropType=="GbxDefPtrProperty" then
        createStructPropertyElement(Struct, nestedMember, nestedPrefix, actualInstance, depth + 1)
       elseif nestedMember.PropType == "EnumProperty" then
        local enumTypeName = nestedMember.PropTypeClass or "UnknownEnum"
        local element = Struct.addElement()
        element.Offset = nestedMember.Offset
        element.Size = nestedMember.ByteSize
        local varTypeStr, varType, customType = getUEVariableTypeInfo(nestedMember.PropType, nestedMember.ByteSize)
        element.Name = nestedPrefix .. enumTypeName .. " " .. nestedMember.Name
        element.VarType = varType
        if customType then
         element.CustomType = customType
        end
       else
        local element = Struct.addElement()
        element.Offset = nestedMember.Offset
        element.Size = nestedMember.ByteSize
        local varTypeStr, varType, customType = getUEVariableTypeInfo(nestedMember.PropType, nestedMember.ByteSize)
        element.Name = nestedPrefix .. varTypeStr .. " " .. nestedMember.Name
        element.VarType = varType
        if customType then
         element.CustomType = customType
        end
       end
      end
      --print(string.format("Expanded StructProperty %s (%s) with %d nested members (depth: %d)", member.Name, structTypeName, #nestedMembers, depth))
     else
      local element = Struct.addElement()
      element.Offset = member.Offset
      element.Size = member.ByteSize
      element.VarType = vtBinary
      element.Name = namePrefix .. "Struct " .. member.Name .. " (" .. structTypeName .. " - no members)"
      print(string.format("StructProperty %s (%s) has no members, added as Binary", member.Name, structTypeName))
     end
    end
   
    if #allMembers > 0 then
     table.sort(allMembers, function(a, b) return a.Offset < b.Offset end)
     
     local lastOffset = 0x28
     for _, member in ipairs(allMembers) do
      if member.Offset >= 0x28 then
       if member.Offset > lastOffset then
        lastOffset = UE.AddPaddingWithDetection(Struct, lastOffset, member.Offset, Instance, namePrefix)
       end
       
       local namePrefix = ""
       
       if member.PropType == "StrProperty" or member.PropType == "StringProperty" then
        createFStringElement(Struct, member, namePrefix, Instance)
        lastOffset = member.Offset + 0x10
       elseif member.PropType == "ArrayProperty" then
        createTArrayElement(Struct, member, namePrefix, Instance)
        lastOffset = member.Offset + 0x10
       elseif member.PropType == "StructProperty" or member.PropType=="GbxDefPtrProperty" then
        createStructPropertyElement(Struct, member, namePrefix, Instance, 0)
        lastOffset = member.Offset + member.ByteSize
       elseif member.PropType == "EnumProperty" or member.PropType == "BoolProperty" then
        local element = Struct.addElement()
        element.Offset = member.Offset
        element.Size = member.ByteSize
        local varTypeStr, varType, customType = getUEVariableTypeInfo(member.PropTypeClass or member.PropType, member.ByteSize)
        element.Name = namePrefix .. varTypeStr .. " " .. member.Name
        element.VarType = varType
        -- bool/enum flags
        if member.PropType == "BoolProperty" and member.ByteSize == 1 then
   
        end
        
        if customType then
         element.CustomType = customType
        end
        lastOffset = member.Offset + member.ByteSize
       else
        local element = Struct.addElement()
        element.Offset = member.Offset
        element.Size = member.ByteSize
        
        local varTypeStr, varType, customType = getUEVariableTypeInfo(member.PropType, member.ByteSize)
        element.Name = namePrefix .. varTypeStr .. " " .. member.Name
        element.VarType = varType
        if customType then
         element.CustomType = customType
        end
        lastOffset = member.Offset + member.ByteSize
       end
      end
     end
     
     if totalSize > lastOffset then
      UE.AddPaddingWithDetection(Struct, lastOffset, totalSize, Instance, "Final_")
     end
     
     print("Added " .. #allMembers .. " members (including inherited) for " .. structName)
    else
     local noteElement = Struct.addElement()
     noteElement.Name = "No member information available for " .. structName
     noteElement.Offset = 0x28
     noteElement.Size = 4
     noteElement.VarType = vtBinary
     print("No members found for " .. structName .. ". Check if class has Members data in UObjectArray.")
    end
    Struct.endUpdate();
    return true
    end
   --REGISTER:
   UE.StructureDissectOverrideCallbackID = ( (UE.StructureDissectOverrideCallbackID and unregisterStructureDissectOverride( UE.StructureDissectOverrideCallbackID ) ) or true ) and registerStructureDissectOverride(UE.StructureDissectOverrideCallback)
  end
  do--Structure Name Lookup And Symbol Lookup
   ue_structureNameLookupCallback=function(address)
     if not UE.FoundFinished or UE.FoundFinished==false then
      return nil;
     end
     if address==UE.FNamePool then
      return "Static Pointer To FNamePool";
     elseif address==UE.UObjectArray then
      return "Static Pointer To UObjectArray";
     end
     local IsClass=false;
     local ClassNameInstance=readQword(address+UE.Constant.oClass);
     local TST=ClassNameInstance and readInteger(ClassNameInstance+UE.Constant.oClassName) or nil;
     local className=nil
     if not (not ClassNameInstance or ClassNameInstance==0 or not TST or TST==0 or TST>0xFFFFFFF) then;
      className=UE.GetName(TST);
      IsClass=className and className =="Class" or false;
     end
     local Idx=readInteger(address+UE.Constant.oClassName)
     if not Idx or Idx<0 or Idx>0xFFFFFF then return nil end
     local N=UE.GetName(Idx);
     if N==nil then;return N;end
     if IsClass and className then;N=className.."Definition: "..N;end
     return N;
     end
   ue_structureNameLookupCallbackID = ( (ue_structureNameLookupCallbackID and unregisterStructureNameLookup( ue_structureNameLookupCallbackID ) ) or true ) and registerStructureNameLookup(ue_structureNameLookupCallback)
   UE.SymbolLookupCallbackCache={};
   UE.CaseSymbolLookupCallbackCache={};
   local X__=1;for X__=1,4,1 do
    local ThisX=X__;
    UE.CaseSymbolLookupCallbackCache[string.format("Player%iPawn",ThisX)]=function();local D=#UE.PlayerCache>ThisX-1 and UE.PlayerCache[ThisX] or nil;return D and D.Pawn or nil;end;
    UE.CaseSymbolLookupCallbackCache[string.format("Player%iState",ThisX)]=function();local D=#UE.PlayerCache>ThisX-1 and UE.PlayerCache[ThisX] or nil;return D and D.State or nil;end;
    UE.CaseSymbolLookupCallbackCache[string.format("Player%iController",ThisX)]=function();local D=#UE.PlayerCache>ThisX-1 and UE.PlayerCache[ThisX] or nil;return D and D.Controller or nil;end;
   end
   UE.CaseSymbolLookupCallbackCache["LocalPlayerController"]=function();return UE.LocalPlayer and UE.LocalPlayer.Controller;end;
   UE.CaseSymbolLookupCallbackCache["LocalPlayerPawn"]=function();return UE.LocalPlayer and UE.LocalPlayer.Pawn;end;
   UE.CaseSymbolLookupCallbackCache["LocalPlayerState"]=function();return UE.LocalPlayer and UE.LocalPlayer.State;end;
   UE.CaseSymbolLookupCallbackCache["GEngine"]=function();return UE.GEngine;end;
   UE.CaseSymbolLookupCallbackCache["UObjectArray"]=function();return UE.UObjectArray;end;
   UE.CaseSymbolLookupCallbackCache["FNamePool"]=function();return UE.FNamePool;end;
   UE.CaseSymbolLookupCallbackCache["GameInstance"]=function();return UE.GameInstance;end;
   UE.CaseSymbolLookupCallbackCache["GameViewport"]=function();return UE.GameViewport;end;
   UE.CaseSymbolLookupCallbackCache["World"]=function();return UE.World;end;
   UE.CaseSymbolLookupCallbackCache["GameState"]=function();return UE.GameState;end;
   UE.SymbolLookupCallback=function(symbol)
    if not UE.FoundFinished or UE.FoundFinished==false then;
     return nil;
    elseif UE.SymbolLookupCallbackCache[symbol] then;
     return UE.SymbolLookupCallbackCache[symbol];
    elseif UE.CaseSymbolLookupCallbackCache[symbol] then;
     return UE.CaseSymbolLookupCallbackCache[symbol]();
    elseif string.find(symbol, "%.") then
     return UE.GetOffsetBySymbol(symbol);
    end
    UE.SymbolLookupCallbackCache[symbol] = nil
    return nil
    end
   UE.SymbolLookupCallbackID =( (UE.SymbolLookupCallbackID and unregisterSymbolLookupCallback( UE.SymbolLookupCallbackID ) ) or true ) and registerSymbolLookupCallback(UE.SymbolLookupCallback,slNotUserdefinedSymbol)--slFailure)
  end
  do--SDK Generation
   UE.DumpFNames = function(filename)
    filename = filename or "fnamedump.txt"
    if not UE.FNamePool or UE.FNamePool == 0 then
     print("Error: FNamePool not found. Run UE.Find() first.")
     return false
    end
    print("Starting FName dump using provided logic...")
    local startTime = os.clock()
    local file = io.open(filename, "w")
    if not file then
     print("Error: Could not create " .. filename)
     return false
    end
    file:write("FName Dump - Generated: " .. os.date() .. "\n")
    file:write("Format: [Index] = \"FName String\"\n")
    file:write("========================================\n\n")
    local totalNames = 0
    local validNames = 0
    local Len = 0
    local Str = nil
    local Index = 0
    local I = 0
    local J=0;
    for I = 0, 199900000, 1 do
     Str = UE.GetName(Index)
     if not UE.IsValidString(Str) then
      for J=0,250,1 do
       Index=Index+1;
       Str = UE.GetName(Index)
       if UE.IsValidString(Str) then;break;end
     end;end
     
     if UE.IsValidString(Str) then
      Len = string.len(Str)
      if Len % 2 == 1 then;Len = Len + 1;end
      Index = Index + (Len / 2) + 1
      file:write(string.format("[%d] = \"%s\"\n", Index - ((Len / 2) + 1), Str))
      validNames = validNames + 1
      if validNames % 1000 == 0 then;print(string.format("Processed %d valid FNames...", validNames));end
     else;
      break;
     end
      totalNames = totalNames + 1
    end
    file:write("\n========================================\n")
    file:write(string.format("Total iterations: %d\n", totalNames))
    file:write(string.format("Valid FNames found: %d\n", validNames))
    file:write(string.format("Last valid index: %d\n", Index - ((Len / 2) + 1)))
    file:write(string.format("Dump completed in: %.3f seconds\n", os.clock() - startTime))
    file:close()
    print(string.format("FName dump completed! Found %d valid names out of %d iterations", validNames, totalNames))
    print(string.format("Results saved to: %s", filename))
    print(string.format("Time taken: %.3f seconds", os.clock() - startTime))
    return true
    end;FNR("UE.DumpFNames")
   UE.DumpObjects=function()
    local Location="objectdump.txt";
    local Out="";
    file = io.open(Location, "w");
    file:write(Out);
    file:close()
    file = io.open(Location, "a");
    local i=0;local j=0;local k=0;
    for i=0,UE.ObjectChunksCount,1 do
     for j=0,UE.ObjectChunksArray[i].Count,1 do
      local OFS=UE.ObjectChunksArray[i].Array[j].Address;
      --OFS=OFS-OpenedProcessModules[1].Address;
      if string.len(UE.ObjectChunksArray[i].Array[j].Parent)>0 then
       Out=--"["..i.."/"..j.."] "..
       "Type:"..UE.ObjectChunksArray[i].Array[j].Type..", "..UE.ObjectChunksArray[i].Array[j].Name.." : "..UE.ObjectChunksArray[i].Array[j].Parent..", "..UE.ObjectChunksArray[i].Array[j].ScriptName..string.format(", Address: 0x%X",OFS);
      else
       Out=--"["..i.."/"..j.."] "..
       "Type:"..UE.ObjectChunksArray[i].Array[j].Type..", "..UE.ObjectChunksArray[i].Array[j].Name..", "..UE.ObjectChunksArray[i].Array[j].ScriptName..string.format(", Address: 0x%X",OFS);
      end
      if UE.ObjectChunksArray[i].Array[j].PropTypeClass and string.len(UE.ObjectChunksArray[i].Array[j].PropTypeClass)>0 then
       Out=Out..", InternalClass: "..UE.ObjectChunksArray[i].Array[j].PropTypeClass;
      end
      if UE.ObjectChunksArray[i].Array[j].Members and UE.ObjectChunksArray[i].Array[j].Members.Members then
       Out=Out..", Members "..(#UE.ObjectChunksArray[i].Array[j].Members.Members+1)..
       --string.format(", Size: 0x%X (0x%X - 0x%X)",UE.ObjectChunksArray[i].Array[j].Members.CountOffset,UE.ObjectChunksArray[i].Array[j].Members.EndCount,UE.ObjectChunksArray[i].Array[j].Members.StartCount)..
       " {\n";
       if UE.ObjectChunksArray[i].Array[j].IsEnumType then;
        for k=0,#UE.ObjectChunksArray[i].Array[j].Members.Members,1 do;
         Out=Out..UE.ObjectChunksArray[i].Array[j].Members.Members[k].Name..string.format(", Offset: 0x%X",UE.ObjectChunksArray[i].Array[j].Members.Members[k].Offset)
         Out=Out.."\n";
        end;
       else
        for k=0,#UE.ObjectChunksArray[i].Array[j].Members.Members,1 do;
         Out=Out..UE.ObjectChunksArray[i].Array[j].Members.Members[k].Name..string.format(", Offset: 0x%X",UE.ObjectChunksArray[i].Array[j].Members.Members[k].Offset)..string.format(", ByteSize: 0x%X",UE.ObjectChunksArray[i].Array[j].Members.Members[k].ByteSize)..
         ", PropertyType: "..UE.ObjectChunksArray[i].Array[j].Members.Members[k].PropType..string.format(", Address: 0x%X",UE.ObjectChunksArray[i].Array[j].Members.Members[k].Address);
         if UE.ObjectChunksArray[i].Array[j].Members.Members[k].PropTypeClass and string.len(UE.ObjectChunksArray[i].Array[j].Members.Members[k].PropTypeClass)>0 then
          Out=Out..", InternalClass: "..UE.ObjectChunksArray[i].Array[j].Members.Members[k].PropTypeClass;
         end
         Out=Out.."\n";
        end;
       end
       Out=Out.."}\n";
      else;
       Out=Out.."\n";
      end
      file:write(Out);
     end
    end
    file:close()
    file=nil;
    print("Objects Dumped To: "..Location);
    return nil;
    end;FNR("UE.DumpObjects");
   
   UE.DumpObjectsToCPPSdk = function(outputDir, options)
    outputDir = outputDir or "SDK"
    options = options or {}
    local opts = {
     separateFiles = true,           -- Generate separate files for classes, structs, functions, parameters, enums
     useBasicInclude = true,         -- Include Basic.hpp 
     generateParameters = true,      -- Generate parameter files for functions
     addAssertMacros = true,         -- Add _ASSERTS macros
     includeComments = true,         -- Include descriptive comments
     maxArrayElements = 25,          -- Max array elements to show in dissection
     separateEnums = true,           -- Generate separate _enums.hpp files
     skipEmptyFiles = true           -- Don't generate empty files
    }
      
    for k, v in pairs(options) do
     opts[k] = v
    end
      
    if not UE.FoundFinished or UE.FoundFinished == false then
     print("Error: UE engine not found. Run UE.Find() first.")
     return false
    end
      
    if UE.ObjectChunksCount == 0 then
     print("Error: No objects loaded. Run UE.Find() first.")
     return false
    end
      
    print("Starting C++ SDK dump to directory: " .. outputDir)
    local startTime = os.clock()
    local success = pcall(function();os.execute('mkdir "' .. outputDir .. '" 2>nul');end)
      
    local function getCppType(propType, propTypeClass, byteSize)
     if propType == "ByteProperty" or propType == "UInt8Property" then
      return "uint8"
     elseif propType == "UInt16Property" or propType == "ShortProperty" then
      return "uint16"
     elseif propType == "UInt32Property" or propType == "IntProperty" then
      return "int32"
     elseif propType == "UInt64Property" or propType == "Int64Property" then
      return "int64"
     elseif propType == "FloatProperty" then
      return "float"
     elseif propType == "DoubleProperty" then
      return "double"
     elseif propType == "BoolProperty" then
      if byteSize == 1 then
       return "bool"
      else
       return "uint8" -- Bitfield bool
      end
     elseif propType == "NameProperty" then
      return "class FName"
     elseif propType == "StrProperty" or propType == "StringProperty" then
      return "class FString"
     elseif propType == "ArrayProperty" then
      local innerType = propTypeClass and propTypeClass or "UObject*"
      return string.format("TArray<%s>", innerType)
     elseif propType == "ObjectProperty" or propType == "WeakObjectProperty" or 
      propType == "LazyObjectProperty" or propType == "SoftObjectProperty" then
      local objectType = propTypeClass and ("class " .. propTypeClass .. "*") or "class UObject*"
      return objectType
     elseif propType == "StructProperty" or propType=="GbxDefPtrProperty" then
      local structType = propTypeClass and ("struct " .. propTypeClass) or "uint8"
      return structType
     elseif propType == "EnumProperty" then
      local enumType = propTypeClass and ("enum class " .. propTypeClass) or "uint8"
      return enumType
     elseif byteSize == 1 then
      return "uint8"
     elseif byteSize == 2 then
      return "uint16"
     elseif byteSize == 4 then
      return "uint32"
     elseif byteSize == 8 then
      return "uint64"
     else
      return string.format("uint8[%d]", byteSize)
     end
    end
      
    local function sanitizeName(name)
     if not name then return "Unknown" end
     name = string.gsub(name, "[^%w_]", "_")
     if string.match(name, "^%d") then
      name = "_" .. name;
     end
     return name
    end
      
    local function generateDumperSDKHeader(scriptName, fileType, extraIncludes)
     extraIncludes = extraIncludes or {}
     local guard = string.upper(sanitizeName(scriptName)) .. "_" .. string.upper(fileType) .. "_HPP"
     local header = string.format("#pragma once\n\n/*\n* SDK generated by NHA UE\n*/\n\n// Package: %s\n\n#include \"Basic.hpp\"\n\n", scriptName)
     for _, include in ipairs(extraIncludes) do
      header = header .. string.format('#include "%s"\n', include)
     end
     header = header .. "\n\nnamespace SDK\n{\n\n"
     return header
    end
      
    local function generateDumperSDKFooter()
     return "} // namespace SDK\n\n"
    end
      
    local function generateParameterStruct(functionObj, paramMembers)
     if not paramMembers or #paramMembers == 0 then
      return ""
     end
     local structName = sanitizeName(functionObj.Name)
     local output = string.format("// Function %s\n", functionObj.Name)
     local totalSize = 0
     for _, member in ipairs(paramMembers) do
      local memberEnd = member.Offset + member.ByteSize
      if memberEnd > totalSize then
       totalSize = memberEnd
      end
     end
     output = output .. string.format("// 0x%04X (0x%04X - 0x0000)\n", totalSize, totalSize)
     output = output .. string.format("struct %s final\n{\npublic:\n", structName)
     table.sort(paramMembers, function(a, b) return a.Offset < b.Offset end)
     local lastOffset = 0
     for _, member in ipairs(paramMembers) do
      local memberName = sanitizeName(member.Name)
      local cppType = getCppType(member.PropType, member.PropTypeClass, member.ByteSize)
      if member.Offset > lastOffset then
       local paddingSize = member.Offset - lastOffset
       output = output .. string.format("\tuint8                                         Pad_%04X[0x%X];%s// 0x%04X(0x%04X) MISSED OFFSET\n", lastOffset, paddingSize, string.rep(" ", math.max(1, 50 - #tostring(paddingSize))), lastOffset, paddingSize)
      end
      output = output .. string.format("\t%-45s %s;%s// 0x%04X(0x%04X)\n", cppType, memberName, string.rep(" ", math.max(1, 50 - #memberName)), member.Offset, member.ByteSize)
      lastOffset = member.Offset + member.ByteSize
     end
     if totalSize > lastOffset then
      local paddingSize = totalSize - lastOffset
      output = output .. string.format("\tuint8                                         Pad_%04X[0x%X];%s// 0x%04X(0x%04X) MISSED OFFSET\n", 
      lastOffset, paddingSize, string.rep(" ", math.max(1, 50 - #tostring(paddingSize))), lastOffset, paddingSize)
     end
     output = output .. "};\n"
     if opts.addAssertMacros then
      output = output .. string.format("NHAUE_ASSERTS_%s;\n\n", structName)
     end
     return output
    end
      
    local scriptGroups = {}
    local totalObjects = 0
    
    for i = 0, UE.ObjectChunksCount do
     if UE.ObjectChunksArray[i] then
      for j = 0, UE.ObjectChunksArray[i].Count do
       local obj = UE.ObjectChunksArray[i].Array[j]
       if obj and obj.Name and obj.ScriptName and #obj.ScriptName > 0 then
        local scriptName = obj.ScriptName
        scriptName = string.gsub(scriptName, "^/Script/", "")
        scriptName = string.gsub(scriptName, "/", "_")
        if not scriptGroups[scriptName] then
         scriptGroups[scriptName] = {
          classes = {},
          structs = {},
          enums = {},
          functions = {},
          parameters = {}
         }
        end
        
        if obj.Type == "Class" then
         table.insert(scriptGroups[scriptName].classes, obj)
        elseif obj.Type == "Struct" or obj.Type == "ScriptStruct" then
         table.insert(scriptGroups[scriptName].structs, obj)
        elseif obj.Type == "Enum" then
         table.insert(scriptGroups[scriptName].enums, obj)
        elseif obj.Type == "Function" then
         table.insert(scriptGroups[scriptName].functions, obj)
            
        if obj.Members and obj.Members.Members then
         local params = {}
         for k = 0, #obj.Members.Members do
          if obj.Members.Members[k] then
           table.insert(params, obj.Members.Members[k])
          end
         end
         if #params > 0 then
          scriptGroups[scriptName].parameters[obj.Name] = params
         end
        end
       end
       totalObjects = totalObjects + 1
      end
     end
    end
    end
      
    print(string.format("Found %d objects across %d script modules", totalObjects, #({next, scriptGroups, nil})))
      
    local filesGenerated = 0
    for scriptName, group in pairs(scriptGroups) do
     local baseFileName = sanitizeName(scriptName)
     if opts.separateEnums and #group.enums > 0 then
      local enumsFileName = outputDir .. "/" .. baseFileName .. "_enums.hpp"
      local enumsFile = io.open(enumsFileName, "w")
      if enumsFile then
       enumsFile:write(generateDumperSDKHeader(scriptName, "enums"))
       for _, enumObj in ipairs(group.enums) do
        local enumName = sanitizeName(enumObj.Name)
        enumsFile:write(string.format("// Enum %s\n", enumObj.Name))
        enumsFile:write(string.format("enum class %s : uint8\n{\n", enumName))
        
        if enumObj.Members and enumObj.Members.Members then
         for k = 0, #enumObj.Members.Members do
          if enumObj.Members.Members[k] then
           local member = enumObj.Members.Members[k]
           local memberName = sanitizeName(member.Name)
           enumsFile:write(string.format("\t%s = %d,\n", memberName, member.Offset))
          end
         end
        end            
        enumsFile:write("};\n\n")
       end
       enumsFile:write(generateDumperSDKFooter())
       enumsFile:close()
       filesGenerated = filesGenerated + 1
       print(string.format("Generated: %s (%d enums)",enumsFileName, #group.enums))
      end
     end   
     if #group.structs > 0 then
      local structsFileName = outputDir .. "/" .. baseFileName .. "_structs.hpp"
      local structsFile = io.open(structsFileName, "w")
      if structsFile then
       local includes = {}
       if opts.separateEnums and #group.enums > 0 then
        table.insert(includes, baseFileName .. "_enums.hpp")
       end
        structsFile:write(generateDumperSDKHeader(scriptName, "structs", includes))
        for _, structObj in ipairs(group.structs) do
         local structName = sanitizeName(structObj.Name)
         local structSize = structObj.EndCount or 0
         
         structsFile:write(string.format("// %s %s\n", structObj.Type, structObj.Name))
         structsFile:write(string.format("// 0x%04X (0x%04X - 0x0000)\n", structSize, structSize))
         
         local parentClass = ""
         if structObj.Parent and #structObj.Parent > 0 then
          parentClass = " : public " .. sanitizeName(structObj.Parent)
         end
                      
         structsFile:write(string.format("struct %s final%s\n{\npublic:\n", structName, parentClass))
         
         if structObj.Members and structObj.Members.Members then
          local lastOffset = 0
          local sortedMembers = {}
          for k = 0, #structObj.Members.Members do
           if structObj.Members.Members[k] then
            table.insert(sortedMembers, structObj.Members.Members[k])
           end
          end
          table.sort(sortedMembers, function(a, b) return a.Offset < b.Offset end)
          
          for _, member in ipairs(sortedMembers) do
           local memberName = sanitizeName(member.Name)
           local cppType = getCppType(member.PropType, member.PropTypeClass, member.ByteSize)
           
           if member.Offset > lastOffset then
            local paddingSize = member.Offset - lastOffset
            structsFile:write(string.format("\tuint8                                         Pad_%04X[0x%X];%s// 0x%04X(0x%04X) Fixing Size After Last Property [ Dumper-7 ]\n", 
            lastOffset, paddingSize, string.rep(" ", math.max(1, 25 - #tostring(paddingSize))), lastOffset, paddingSize))
           end
           
           local propertyFlags = "(Edit, BlueprintVisible, ZeroConstructor, IsPlainOldData, NoDestructor, HasGetValueTypeHash, NativeAccessSpecifierPublic)"
           structsFile:write(string.format("\t%-45s %s;%s// 0x%04X(0x%04X)%s\n", 
           cppType, memberName, string.rep(" ", math.max(1, 25 - #memberName)), member.Offset, member.ByteSize, propertyFlags))
           lastOffset = member.Offset + member.ByteSize
          end
          
          -- Add final padding to reach struct size
          if structSize > lastOffset then
              local paddingSize = structSize - lastOffset
              structsFile:write(string.format("\tuint8                                         Pad_%04X[0x%X];%s// 0x%04X(0x%04X) Fixing Struct Size After Last Property [ Dumper-7 ]\n", 
                  lastOffset, paddingSize, string.rep(" ", math.max(1, 25 - #tostring(paddingSize))), lastOffset, paddingSize))
          end
         end         
         structsFile:write("};\n")
                      
         if opts.addAssertMacros then
          structsFile:write(string.format("NHAUE_ASSERTS_%s;\n\n", structName))
         end
        end
        structsFile:write(generateDumperSDKFooter())
        structsFile:close()
        filesGenerated = filesGenerated + 1
        print(string.format("Generated: %s (%d structs)",structsFileName, #group.structs))
       end
      end
          
      if #group.classes > 0 then
       local classesFileName = outputDir .. "/" .. baseFileName .. "_classes.hpp"
       local classesFile = io.open(classesFileName, "w")
       if classesFile then
        local includes = {}
        if opts.separateEnums and #group.enums > 0 then
         table.insert(includes, baseFileName .. "_enums.hpp")
        end
        if #group.structs > 0 then
         table.insert(includes, baseFileName .. "_structs.hpp")
        end
        
        classesFile:write(generateDumperSDKHeader(scriptName, "classes", includes))
        for _, classObj in ipairs(group.classes) do
         local className = sanitizeName(classObj.Name)
         local classSize = classObj.EndCount or 0
         local parentSize = 0
         
         classesFile:write(string.format("// Class %s\n", classObj.Name))
         classesFile:write(string.format("// 0x%04X (0x%04X - 0x%04X)\n", classSize - parentSize, classSize, parentSize))
         
         local parentClass = ""
         if classObj.Parent and #classObj.Parent > 0 then
          parentClass = " : public " .. sanitizeName(classObj.Parent)
         end
         
         classesFile:write(string.format("class %s final%s\n{\npublic:\n", className, parentClass))
         
         if classObj.Members and classObj.Members.Members then
          local lastOffset = parentSize
          local sortedMembers = {}
          for k = 0, #classObj.Members.Members do
           if classObj.Members.Members[k] then
            table.insert(sortedMembers, classObj.Members.Members[k])
           end
          end
          table.sort(sortedMembers, function(a, b) return a.Offset < b.Offset end)
          for _, member in ipairs(sortedMembers) do
           if member.Offset >= parentSize then -- Only show members not inherited
            local memberName = sanitizeName(member.Name)
            local cppType = getCppType(member.PropType, member.PropTypeClass, member.ByteSize)       
            if member.Offset > lastOffset then
             local paddingSize = member.Offset - lastOffset
             classesFile:write(string.format("\tuint8                                         Pad_%04X[0x%X];%s// 0x%04X(0x%04X) Fixing Size After Last Property [ Dumper-7 ]\n", 
             lastOffset, paddingSize, string.rep(" ", math.max(1, 25 - #tostring(paddingSize))), lastOffset, paddingSize))
            end
            local propertyFlags = "(Edit, BlueprintVisible, ZeroConstructor, IsPlainOldData, NoDestructor, HasGetValueTypeHash, NativeAccessSpecifierPublic)"
            classesFile:write(string.format("\t%-45s %s;%s// 0x%04X(0x%04X)%s\n", 
            cppType, memberName, string.rep(" ", math.max(1, 25 - #memberName)), member.Offset, member.ByteSize, propertyFlags))
            lastOffset = member.Offset + member.ByteSize
           end
          end
          if classSize > lastOffset then
           local paddingSize = classSize - lastOffset
           classesFile:write(string.format("\tuint8                                         Pad_%04X[0x%X];%s// 0x%04X(0x%04X) Fixing Struct Size After Last Property [ Dumper-7 ]\n", 
           lastOffset, paddingSize, string.rep(" ", math.max(1, 25 - #tostring(paddingSize))), lastOffset, paddingSize))
          end
         end
         
         classesFile:write("\npublic:\n")
         classesFile:write("\tstatic class UClass* StaticClass()\n\t{\n")
         classesFile:write(string.format("\t\tSTATIC_CLASS_IMPL(\"%s\")\n", classObj.Name))
         classesFile:write("\t}\n")
         
         classesFile:write("\tstatic const class FName& StaticName()\n\t{\n")
         classesFile:write(string.format("\t\tSTATIC_NAME_IMPL(L\"%s\")\n", classObj.Name))
         classesFile:write("\t}\n")
         
         classesFile:write(string.format("\tstatic class %s* GetDefaultObj()\n\t{\n", className))
         classesFile:write(string.format("\t\treturn GetDefaultObjImpl<%s>();\n", className))
         classesFile:write("\t}\n")
         
         classesFile:write("};\n")
         
         if opts.addAssertMacros then
          classesFile:write(string.format("NHAUE_ASSERTS_%s;\n\n", className))
         end
        end
        
        classesFile:write(generateDumperSDKFooter())
        classesFile:close()
        filesGenerated = filesGenerated + 1
        
        print(string.format("Generated: %s (%d classes)", classesFileName, #group.classes))
       end
      end
          
      if not opts.skipEmptyFiles or #group.functions > 0 then
       if #group.functions > 0 then
        local functionsFileName = outputDir .. "/" .. baseFileName .. "_functions.cpp"
        local functionsFile = io.open(functionsFileName, "w")
        if functionsFile then
         functionsFile:write(string.format("/*\n* SDK generated by NHA UE\n*/\n\n// Package: %s\n\n#include \"Basic.hpp\"\n\n", scriptName))
         if opts.separateEnums and #group.enums > 0 then
          functionsFile:write(string.format('#include "%s_enums.hpp"\n', baseFileName))
         end
         if #group.structs > 0 then
          functionsFile:write(string.format('#include "%s_structs.hpp"\n', baseFileName))
         end
         if #group.classes > 0 then
          functionsFile:write(string.format('#include "%s_classes.hpp"\n', baseFileName))
         end
         if opts.generateParameters and next(group.parameters) then
          functionsFile:write(string.format('#include "%s_parameters.hpp"\n', baseFileName))
         end
                      
         functionsFile:write("\nnamespace SDK\n{\n\n")
         for _, funcObj in ipairs(group.functions) do
          local functionName = sanitizeName(funcObj.Name)
          functionsFile:write(string.format("// Function %s\n", funcObj.Name))
          functionsFile:write(string.format("// (Final | Native | Public | BlueprintCallable)\n"))
          functionsFile:write(string.format("// Parameters:\n"))
          
          if funcObj.Members and funcObj.Members.Members then
           for k = 0, #funcObj.Members.Members do
            if funcObj.Members.Members[k] then
             local param = funcObj.Members.Members[k]
             local paramType = getCppType(param.PropType, param.PropTypeClass, param.ByteSize)
             functionsFile:write(string.format("// %-45s %s\n", paramType, param.Name))
            end
           end
          end
          
          functionsFile:write("\nvoid UFunction::" .. functionName .. "()\n{\n")
          functionsFile:write("\tstatic class UFunction* Func = nullptr;\n\n")
          functionsFile:write("\tif (!Func)\n")
          functionsFile:write(string.format("\t\tFunc = Class->GetFunction(\"%s\");\n\n", funcObj.Name))
          functionsFile:write("\tUObject::ProcessEvent(Func, nullptr);\n")
          functionsFile:write("}\n\n")
         end
         
         functionsFile:write("} // namespace SDK\n\n")
         functionsFile:close()
         filesGenerated = filesGenerated + 1
         print(string.format("Generated: %s (%d functions)", functionsFileName, #group.functions))
        end
       end
      end
          
      if opts.generateParameters and next(group.parameters) and (not opts.skipEmptyFiles or next(group.parameters)) then
       local parametersFileName = outputDir .. "/" .. baseFileName .. "_parameters.hpp"
       local parametersFile = io.open(parametersFileName, "w")
      
       if parametersFile then
        local includes = {}
        -- Include dependencies
        if opts.separateEnums and #group.enums > 0 then
         table.insert(includes, baseFileName .. "_enums.hpp")
        end
        if #group.structs > 0 then
         table.insert(includes, baseFileName .. "_structs.hpp")
        end
        
        parametersFile:write(generateDumperSDKHeader(scriptName, "parameters", includes))
        
        parametersFile:write("namespace SDK::Params\n{\n\n")
        
        for funcName, paramMembers in pairs(group.parameters) do
         local paramStruct = generateParameterStruct({Name = funcName}, paramMembers)
         parametersFile:write(paramStruct)
        end
        
        parametersFile:write("} // namespace SDK::Params\n")
        parametersFile:write(generateDumperSDKFooter())
        parametersFile:close()
        filesGenerated = filesGenerated + 1
        
        print(string.format("Generated: %s (%d parameter structs)", 
        parametersFileName, #({next, group.parameters, nil})))
       end
      end
     end
     local basicFileName = outputDir .. "/Basic.hpp"
     local basicFile = io.open(basicFileName, "w")
     if basicFile then
      basicFile:write("#pragma once\n\n/*\n* SDK generated by NHA UE\n*/\n\n#ifdef _MSC_VER\n	#pragma pack(push, 0x01)\n#endif\n\n#include <locale>\n#include <cstdint>\n\nnamespace SDK\n{\n//---------------------------------------------------------------------------\n// Basic types\n//---------------------------------------------------------------------------\n\nusing int8 = std::int8_t;\nusing int16 = std::int16_t;\nusing int32 = std::int32_t;\nusing int64 = std::int64_t;\nusing uint8 = std::uint8_t;\nusing uint16 = std::uint16_t;\nusing uint32 = std::uint32_t;\nusing uint64 = std::uint64_t;\n\ntemplate<typename T> class TArray;\ntemplate<typename T> class TMap;\n\nclass FString;\nclass FName;\nclass UObject;\nclass UClass;\n\n//---------------------------------------------------------------------------\n// Constants\n//---------------------------------------------------------------------------\n\nconstexpr auto NONE = 0;\n\n//---------------------------------------------------------------------------\n// Macros\n//---------------------------------------------------------------------------\n\n#define STATIC_CLASS_IMPL(ClassName) \\\n	static class UClass* cls = nullptr; \\\n	if (!cls) \\		cls = UObject::FindClassFast(ClassName); \\\n	return cls;\n\n#define STATIC_NAME_IMPL(Name) \\\n	static const class FName name(Name); \\\n	return name;\n\ntemplate<typename T>\nT* GetDefaultObjImpl()\n{\n	return static_cast<T*>(T::StaticClass()->DefaultObject);\n}\n\n")
      basicFile:write("// Assert macros\n")
      for scriptName, group in pairs(scriptGroups) do
       for _, structObj in ipairs(group.structs) do
        local structName = sanitizeName(structObj.Name)
        basicFile:write(string.format("#define NHAUE_ASSERTS_%s static_assert(sizeof(%s) == 0x%04X, \"Wrong size for %s\");\n", 
        structName, structName, structObj.EndCount or 0, structName))
       end
       for _, classObj in ipairs(group.classes) do
        local className = sanitizeName(classObj.Name)
        basicFile:write(string.format("#define NHAUE_ASSERTS_%s static_assert(sizeof(%s) == 0x%04X, \"Wrong size for %s\");\n", 
        className, className, classObj.EndCount or 0, className))
       end
      end
      basicFile:write("\n} // namespace SDK\n\n")
      basicFile:write("#ifdef _MSC_VER\n\t#pragma pack(pop)\n#endif\n")
      basicFile:close()
      filesGenerated = filesGenerated + 1
      print("Generated Basic.hpp")
     end
     local masterIncludeFile = io.open(outputDir .. "/SDK.hpp", "w")
     if masterIncludeFile then
      masterIncludeFile:write(string.format("#pragma once\n\n/*\n* Master SDK Include File\n* Generated by NHA UE SDK Generator\n*\n* Generated: %s\n*/\n\n#include \"Basic.hpp\"\n\n", os.date()))  
      for scriptName, group in pairs(scriptGroups) do
       local baseFileName = sanitizeName(scriptName)
       if opts.separateEnums and #group.enums > 0 then
        masterIncludeFile:write(string.format('#include "%s_enums.hpp"\n', baseFileName))
       end
       if #group.structs > 0 then
        masterIncludeFile:write(string.format('#include "%s_structs.hpp"\n', baseFileName))
       end
       if #group.classes > 0 then
        masterIncludeFile:write(string.format('#include "%s_classes.hpp"\n', baseFileName))
       end
       if opts.generateParameters and next(group.parameters) then
        masterIncludeFile:write(string.format('#include "%s_parameters.hpp"\n', baseFileName))
       end
      end 
      masterIncludeFile:close()
      filesGenerated = filesGenerated + 1
      print("Generated master include file: SDK.hpp")
     end
     local endTime = os.clock()
     print(string.format("Generated %d files in %.3f seconds", filesGenerated, endTime - startTime))
     print(string.format("Output directory: %s", outputDir))
     return true
    end;FNR("UE.DumpObjectsToCPPSdk")
  end
  do;--Initializer And Timer Base Functions
   local IPTR,StrN,CachePlayer,Index,Count,PTR=nil,nil,0,0,0,0,0,0,0,0;
   local MainUpdateTick,MainUpdateTickFinal,MainUpdateTickFail=0,5,20;
   UE.CurPlayerHash="";
   UE.MainUpdateEnabled=false;
   UE.TimerFunctions.Add("MainUpdate",function()
    if MainUpdateTick~=0 then;
     MainUpdateTick=MainUpdateTick-1;
     return;
    end
    MainUpdateTick=MainUpdateTickFail;
    if not UE.GEngine or UE.GEngine==0 or not UE.MainUpdateEnabled then;
     if UE.GameInstance and UE.GameInstance~=0 then
      UE.GameInstance=0;
      return UE.ClearPlayerCache();
     end
     return;
    end;
    UE.GameInstance=readPointer(UE.GEngine+UE.Offset.GameInstance);
    if not UE.GameInstance then;
     UE.MainUpdateEnabled=false;
     return UE.ClearPlayerCache();
    end;
    --Update Player Array
    UE.GameViewport=readPointer(UE.GEngine+UE.Offset.GameViewport);
    UE.World= UE.GameViewport and readPointer(UE.GameViewport+UE.Offset.World) or 0;
    UE.Level= UE.World and readPointer(UE.World+UE.Offset.PersistentLevel) or 0;
    UE.GameState=UE.World and readPointer(UE.World+UE.Offset.GameState) or 0;
    if not UE.GameState then;return UE.ClearPlayerCache();end;
    PTR= UE.GameState;
    Count=not PTR and 0 or readInteger(PTR+UE.Offset.PlayerArray+0x8);
    if Count and Count>0 and Count<1000 then
    MainUpdateTick=MainUpdateTickFinal;
     PTR=readPointer(PTR+UE.Offset.PlayerArray);
     UE.CurPlayerHash,I="",0;
     for I=0,Count-1,1 do
      IPTR=readPointer(PTR+(0x8*I))
      StrN=readString(readPointer(IPTR+UE.Offset.PlayerNamePrivate),(readInteger(IPTR+UE.Offset.PlayerNamePrivate+8)*2)+1,true);
      if StrN==nil or StrN=="" then;break;end;
      UE.CurPlayerHash=UE.CurPlayerHash..string.format(" %s\n",StrN);
      CachePlayer,Index= UE.GetPlayerFromCache(StrN,IPTR);
      UE.PlayerCache[Index].State=IPTR;
      IPTR=readPointer(IPTR+UE.Offset.Owner);
      UE.PlayerCache[Index].Controller=IPTR;
      IPTR=readPointer(IPTR+UE.Offset.Pawn);
      UE.PlayerCache[Index].Pawn=IPTR;
      UE.PlayerCache[Index].RootComponent=readPointer(IPTR+UE.Offset.RootComponent);
      UE.PlayerCache[Index].Movement=readPointer(IPTR+UE.Offset.Movement);
      if readByte(UE.PlayerCache[Index].Controller+ UE.Offset.IsLocalPlayerController) then;
       UE.LocalPlayer.Index=Index;
       UE.LocalPlayer.State=UE.PlayerCache[Index].State;
       UE.LocalPlayer.Controller=UE.PlayerCache[Index].Controller;
       UE.LocalPlayer.Pawn=UE.PlayerCache[Index].Pawn;
       UE.LocalPlayer.RootComponent=UE.PlayerCache[Index].RootComponent;
       UE.LocalPlayer.Movement=UE.PlayerCache[Index].Movement;
      end
     end
    end
   end);
  end
 end