
if NHA_CE==nil then;
 NHA_CE={};
  
 do;--[[Function Name Register]]
  FNR=function(Name);registerLuaFunctionHighlight(Name);end;FNR("FNR");FNR("NHA_CE");
  end;

 NHA_CE.DeleteAllStructures=function();
  while getStructureCount()>0 do;
  getStructure(0).removeFromGlobalStructureList();
  end;
  end;
  FNR("NHA_CE.DeleteAllStructures");

 do;--Scans

  --Easy Memscan Setup
  NHA_CE.MemScan=function(ValueToScan,vtValueType,Protection,OnlyOneResult,RegionBase,RegionEnd)
   if RegionBase==nil then
   RegionBase=getAddress(process);
   RegionEnd=RegionBase+getModuleSize(process);
   end
   local ms = createMemScan()
   if OnlyOneResult==nil then;OnlyOneResult=false;end;
   ms.OnlyOneResult=OnlyOneResult;
   ms.Hexadecimal=false;
   ms.firstScan(soExactValue, vtValueType, nil, ValueToScan, nil, RegionBase, RegionEnd,Protection, nil, nil ,--[[isHexadecimalInput]] true, nil, nil, nil)
   ms.waitTillDone()
   if ms.OnlyOneResult then;
   local O=ms.result;
   ms.destroy();
   return O;
   else;
   local found = createFoundList(ms)
   found.initialize()
   local Values={};
   if found.Count>0 then;
   for ind=0,found.Count-1,1 do
   Values[#Values+1]=found[ind];
   end
   end
   ms.destroy();
   found.destroy();
   return Values;
   end;
   end
   FNR("NHA_CE.MemScan");

  --Scan A Memory Region For A Unique Signature / Aob With Multiple Outputs
  NHA_CE.MultiScan=function(Signature,RegionBase,RegionEnd);
   return NHA_CE.MemScan(Signature,vtByteArray,"*X*C*W",false,RegionBase,RegionEnd);
   end;FNR("NHA_CE.MultiScan");

  end;

 do;--PE Parse

  NHA_CE.GetPEMetaData=function(ModuleBaseAddress);
   local PeMetaData={
   Valid=false;
   NtHeaderOffset = readInteger(ModuleBaseAddress + 0x3c,true);
   PE=0;
   ImageFileHeader=nil;
   OptHeaderAddress=0;
   OptHeader=nil;
   PEArch=0;
   Is32Bit=true;
   };
   PeMetaData.Pe = readInteger(ModuleBaseAddress+ PeMetaData.NtHeaderOffset,true);
   --Validate PE signature
   if PeMetaData.Pe ~= 0x4550 then;print("Invalid PE: "..NHA_CE.GetHexAddress(ModuleBaseAddress));return PeMetaData;end;
   PeMetaData.Valid=true;
   local ImageFileHeaderAddress=ModuleBaseAddress + PeMetaData.NtHeaderOffset + 0x4;
   
   PeMetaData.ImageFileHeader ={
   Sections={};
   Address=ImageFileHeaderAddress;
   Machine=readSmallInteger(ImageFileHeaderAddress);
   NumberOfSections=readSmallInteger(ImageFileHeaderAddress+0x2);
   TimeDateStamp=readSmallInteger(ImageFileHeaderAddress+0x4);
   PointerToSymbolTable=readSmallInteger(ImageFileHeaderAddress+0x8);
   NumberOfSymbols=readSmallInteger(ImageFileHeaderAddress+0xC);
   SizeOfOptionalHeader=readSmallInteger(ImageFileHeaderAddress+0x10);
   Characteristics=readSmallInteger(ImageFileHeaderAddress+0x12);
   };
   
    local READSTRUCT_IMAGE_DATA_DIRECTORY=function(Address);return{--[[8Bytes]]
     VirtualAddress=readInteger(Address,true);
     Size=readInteger(Address+4,true);
     };end;
   
   OptHeaderAddress =ModuleBaseAddress + PeMetaData.NtHeaderOffset + 0x18;
   PEArch = readSmallInteger(OptHeaderAddress);
   -- Validate PE arch
   if PEArch == 0x010b then;-- Image is x32
   PeMetaData.Is32Bit = true;
   PeMetaData.OptHeader = {
   Magic=readSmallInteger(OptHeaderAddress,true);
   MajorLinkerVersion=readSmallInteger(OptHeaderAddress+0x2,true);
   MinorLinkerVersion=readSmallInteger(OptHeaderAddress+0x3,true);
   SizeOfCode=readInteger(OptHeaderAddress+0x4,true);
   SizeOfInitializedData=readInteger(OptHeaderAddress+0x8,true);
   SizeOfUninitializedData=readInteger(OptHeaderAddress+0xC,true);
   AddressOfEntryPoint=readInteger(OptHeaderAddress+0x10,true);
   BaseOfCode=readInteger(OptHeaderAddress+0x14,true);
   ImageBase=readQword(OptHeaderAddress+0x18,true);
   SectionAlignment=readInteger(OptHeaderAddress+0x20,true);
   FileAlignment=readInteger(OptHeaderAddress+0x24,true);
   MajorOperatingSystemVersion=readSmallInteger(OptHeaderAddress+0x26,true);
   MinorOperatingSystemVersion=readSmallInteger(OptHeaderAddress+0x28,true);
   MajorImageVersion=readSmallInteger(OptHeaderAddress+0x2A,true);
   MinorImageVersion=readSmallInteger(OptHeaderAddress+0x2C,true);
   MajorSubsystemVersion=readSmallInteger(OptHeaderAddress+0x2E,true);
   MinorSubsystemVersion=readSmallInteger(OptHeaderAddress+0x30,true);
   Win32VersionValue=readInteger(OptHeaderAddress+0x34,true);
   SizeOfImage=readInteger(OptHeaderAddress+0x38,true);
   SizeOfHeaders=readInteger(OptHeaderAddress+0x3C,true);
   CheckSum=readInteger(OptHeaderAddress+0x40,true);
   Subsystem=readSmallInteger(OptHeaderAddress+0x44,true);
   DllCharacteristics=readSmallInteger(OptHeaderAddress+0x46,true);
   SizeOfStackReserve=readInteger(OptHeaderAddress+0x48,true);
   SizeOfStackCommit=readInteger(OptHeaderAddress+0x4C,true);
   SizeOfHeapReserve=readInteger(OptHeaderAddress+0x50,true);
   SizeOfHeapCommit=readInteger(OptHeaderAddress+0x54,true);
   LoaderFlags=readInteger(OptHeaderAddress+0x58,true);
   NumberOfRvaAndSizes=readInteger(OptHeaderAddress+0x5C,true);
   
   ExportTable=READSTRUCT_IMAGE_DATA_DIRECTORY(OptHeaderAddress+0x60);
   ImportTable=READSTRUCT_IMAGE_DATA_DIRECTORY(OptHeaderAddress+0x68);
   ResourceTable=READSTRUCT_IMAGE_DATA_DIRECTORY(OptHeaderAddress+0x70);
   ExceptionTable=READSTRUCT_IMAGE_DATA_DIRECTORY(OptHeaderAddress+0x78);
   CertificateTable=READSTRUCT_IMAGE_DATA_DIRECTORY(OptHeaderAddress+0x80);
   BaseRelocationTable=READSTRUCT_IMAGE_DATA_DIRECTORY(OptHeaderAddress+0x88);
   Debug=READSTRUCT_IMAGE_DATA_DIRECTORY(OptHeaderAddress+0x90);
   Architecture=READSTRUCT_IMAGE_DATA_DIRECTORY(OptHeaderAddress+0x98);
   GlobalPtr=READSTRUCT_IMAGE_DATA_DIRECTORY(OptHeaderAddress+0x100);
   TLSTable=READSTRUCT_IMAGE_DATA_DIRECTORY(OptHeaderAddress+0x108);
   LoadConfigTable=READSTRUCT_IMAGE_DATA_DIRECTORY(OptHeaderAddress+0x110);
   BoundImport=READSTRUCT_IMAGE_DATA_DIRECTORY(OptHeaderAddress+0x118);
   IAT=READSTRUCT_IMAGE_DATA_DIRECTORY(OptHeaderAddress+0x120);
   DelayImportDescriptor=READSTRUCT_IMAGE_DATA_DIRECTORY(OptHeaderAddress+0x128);
   CLRRuntimeHeader=READSTRUCT_IMAGE_DATA_DIRECTORY(OptHeaderAddress+0x130);
   Reserved=READSTRUCT_IMAGE_DATA_DIRECTORY(OptHeaderAddress+0x138);
   };
   elseif PEArch == 0x020b then;-- Image is x64
   PeMetaData.Is32Bit = false;
   PeMetaData.OptHeader = {
   Magic=readSmallInteger(OptHeaderAddress,true);
   MajorLinkerVersion=readSmallInteger(OptHeaderAddress+0x2,true);
   MinorLinkerVersion=readSmallInteger(OptHeaderAddress+0x3,true);
   SizeOfCode=readInteger(OptHeaderAddress+0x4,true);
   SizeOfInitializedData=readInteger(OptHeaderAddress+0x8,true);
   SizeOfUninitializedData=readInteger(OptHeaderAddress+0xC,true);
   AddressOfEntryPoint=readInteger(OptHeaderAddress+0x10,true);
   BaseOfCode=readInteger(OptHeaderAddress+0x14,true);
   ImageBase=readQword(OptHeaderAddress+0x18,true);
   SectionAlignment=readInteger(OptHeaderAddress+0x20,true);
   FileAlignment=readInteger(OptHeaderAddress+0x24,true);
   MajorOperatingSystemVersion=readSmallInteger(OptHeaderAddress+0x28,true);
   MinorOperatingSystemVersion=readSmallInteger(OptHeaderAddress+0x2A,true);
   MajorImageVersion=readSmallInteger(OptHeaderAddress+0x2C,true);
   MinorImageVersion=readSmallInteger(OptHeaderAddress+0x2E,true);
   MajorSubsystemVersion=readSmallInteger(OptHeaderAddress+0x30,true);
   MinorSubsystemVersion=readSmallInteger(OptHeaderAddress+0x32,true);
   Win32VersionValue=readInteger(OptHeaderAddress+0x34,true);
   SizeOfImage=readInteger(OptHeaderAddress+0x38,true);
   SizeOfHeaders=readInteger(OptHeaderAddress+0x3C,true);
   CheckSum=readInteger(OptHeaderAddress+0x40,true);
   Subsystem=readSmallInteger(OptHeaderAddress+0x42,true);
   DllCharacteristics=readSmallInteger(OptHeaderAddress+0x44,true);
   SizeOfStackReserve=readQword(OptHeaderAddress+0x48,true);
   SizeOfStackCommit=readQword(OptHeaderAddress+0x50,true);
   SizeOfHeapReserve=readQword(OptHeaderAddress+0x58,true);
   SizeOfHeapCommit=readQword(OptHeaderAddress+0x60,true);
   LoaderFlags=readInteger(OptHeaderAddress+0x68,true);
   NumberOfRvaAndSizes=readInteger(OptHeaderAddress+0x6C,true);
   
   ExportTable=READSTRUCT_IMAGE_DATA_DIRECTORY(OptHeaderAddress+0x70);
   ImportTable=READSTRUCT_IMAGE_DATA_DIRECTORY(OptHeaderAddress+0x78);
   ResourceTable=READSTRUCT_IMAGE_DATA_DIRECTORY(OptHeaderAddress+0x80);
   ExceptionTable=READSTRUCT_IMAGE_DATA_DIRECTORY(OptHeaderAddress+0x88);
   CertificateTable=READSTRUCT_IMAGE_DATA_DIRECTORY(OptHeaderAddress+0x90);
   BaseRelocationTable=READSTRUCT_IMAGE_DATA_DIRECTORY(OptHeaderAddress+0x98);
   Debug=READSTRUCT_IMAGE_DATA_DIRECTORY(OptHeaderAddress+0x100);
   Architecture=READSTRUCT_IMAGE_DATA_DIRECTORY(OptHeaderAddress+0x108);
   GlobalPtr=READSTRUCT_IMAGE_DATA_DIRECTORY(OptHeaderAddress+0x110);
   TLSTable=READSTRUCT_IMAGE_DATA_DIRECTORY(OptHeaderAddress+0x118);
   LoadConfigTable=READSTRUCT_IMAGE_DATA_DIRECTORY(OptHeaderAddress+0x120);
   BoundImport=READSTRUCT_IMAGE_DATA_DIRECTORY(OptHeaderAddress+0x128);
   IAT=READSTRUCT_IMAGE_DATA_DIRECTORY(OptHeaderAddress+0x130);
   DelayImportDescriptor=READSTRUCT_IMAGE_DATA_DIRECTORY(OptHeaderAddress+0x138);
   CLRRuntimeHeader=READSTRUCT_IMAGE_DATA_DIRECTORY(OptHeaderAddress+0x140);
   Reserved=READSTRUCT_IMAGE_DATA_DIRECTORY(OptHeaderAddress+0x148);
   };
   else
   print("Invalid PEArch: "..NHA_CE.GetHexAddress(ModuleBaseAddress));
   return PeMetaData;
   end;
   
   
     local READSTRUCT_IMAGE_SECTION_HEADER=function(Address);return{--[[28Bytes]]
      NameChars=readString(Address,8);
      VirtualSize=readInteger(Address+0x8,true);
      VirtualAddress=readInteger(Address+0xC,true);
      SizeOfRawData=readInteger(Address+0x10,true);
      PointerToRawData=readInteger(Address+0x14,true);
      PointerToRelocations=readInteger(Address+0x18,true);
      PointerToLinenumbers=readInteger(Address+0x1C,true);
      NumberOfRelocations=readSmallInteger(Address+0x20,true);
      NumberOfLinenumbers=readSmallInteger(Address+0x22,true);
      Characteristics=readInteger(Address+0x24,true);
      };end;
   
   PeMetaData.ImageFileHeader.Sections={};
   local n=0;
   for n = 0, PeMetaData.ImageFileHeader.NumberOfSections, 1 do
   PeMetaData.ImageFileHeader.Sections[n]=
   READSTRUCT_IMAGE_SECTION_HEADER(OptHeaderAddress+PeMetaData.ImageFileHeader.SizeOfOptionalHeader+n*0x28);
   end;
   
   return PeMetaData;
   end;FNR("NHA_CE.GetPEMetaData");

  end;

end;
