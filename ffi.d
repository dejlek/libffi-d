module ffi;

private
{
    enum ffi_status
    {
        FFI_OK,
        FFI_BAD_TYPEDEF,
        FFI_BAD_ABI,
    }

    version (X86)
    {
        enum ffi_abi
        {
            FFI_DEFAULT_ABI = 1, // FFI_SYSV
        }
    }
    else version (X86_64)
    {
        version (Windows)
        {
            enum ffi_abi
            {
                FFI_DEFAULT_ABI = 1, // FFI_WIN64
            }
        }
        else
        {
            enum ffi_abi
            {
                FFI_DEFAULT_ABI = 2, // FFI_UNIX64
            }
        }
    }
    else version (ARM)
    {
        enum ffi_abi
        {
            // TODO: Check for VFP (FFI_VFP).
            FFI_DEFAULT_ABI = 1, // FFI_SYSV
        }
    }
    else version (PPC)
    {
        version (AIX)
        {
            enum ffi_abi
            {
                FFI_DEFAULT_ABI = 1, // FFI_AIX
            }
        }
        else version (OSX)
        {
            enum ffi_abi
            {
                FFI_DEFAULT_ABI = 1, // FFI_DARWIN
            }
        }
        else version (FreeBSD)
        {
            enum ffi_abi
            {
                FFI_DEFAULT_ABI = 1, // FFI_SYSV
            }
        }
        else
        {
            enum ffi_abi
            {
                // TODO: Detect soft float (FFI_LINUX_SOFT_FLOAT) and FFI_LINUX.
                FFI_DEFAULT_ABI = 2, // FFI_GCC_SYSV
            }
        }
    }
    else version (PPC64)
    {
        enum ffi_abi
        {
            FFI_DEFAULT_ABI = 3, // FFI_LINUX64
        }
    }
    else version (IA64)
    {
        enum ffi_abi
        {
            FFI_DEFAULT_ABI = 1, // FFI_UNIX
        }
    }
    else version (MIPS)
    {
        enum ffi_abi
        {
            // TODO: Detect soft float (FFI_*_SOFT_FLOAT).
            // TODO: Detect O32 vs N32.
            FFI_DEFAULT_ABI = 1, // FFI_O32
        }
    }
    else version (MIPS64)
    {
        enum ffi_abi
        {
            FFI_DEFAULT_ABI = 3, // FFI_N64
        }
    }
    else version (SPARC)
    {
        enum ffi_abi
        {
            FFI_DEFAULT_ABI = 1, // FFI_V8
        }
    }
    else version (SPARC64)
    {
        enum ffi_abi
        {
            FFI_DEFAULT_ABI = 3, // FFI_V9
        }
    }
    else version (S390)
    {
        enum ffi_abi
        {
            FFI_DEFAULT_ABI = 1, // FFI_SYSV
        }
    }
    else version (S390X)
    {
        enum ffi_abi
        {
            FFI_DEFAULT_ABI = 1, // FFI_SYSV
        }
    }
    else version (HPPA)
    {
        enum ffi_abi
        {
            FFI_DEFAULT_ABI = 1, // FFI_PA32
        }
    }
    else version (HPPA64)
    {
        enum ffi_abi
        {
            FFI_DEFAULT_ABI = 1, // FFI_PA64
        }
    }
    else version (SH)
    {
        enum ffi_abi
        {
            FFI_DEFAULT_ABI = 1, // FFI_SYSV
        }
    }
    else version (SH64)
    {
        enum ffi_abi
        {
            FFI_DEFAULT_ABI = 1, // FFI_SYSV
        }
    }
    else version (Alpha)
    {
        enum ffi_abi
        {
            FFI_DEFAULT_ABI = 1, // FFI_OSF
        }
    }
    else
        static assert(false, "Unsupported architecture/platform.");

    struct ffi_type
    {
        size_t size;
        ushort alignment;
        ushort type;
        ffi_type** elements;
    }

    struct ffi_cif
    {
        int abi;
        uint nargs;
        ffi_type** arg_types;
        ffi_type* rtype;
        uint bytes;
        uint flags;
    }

    extern (C)
    {
        extern __gshared
        {
            ffi_type ffi_type_void;
            ffi_type ffi_type_uint8;
            ffi_type ffi_type_sint8;
            ffi_type ffi_type_uint16;
            ffi_type ffi_type_sint16;
            ffi_type ffi_type_uint32;
            ffi_type ffi_type_sint32;
            ffi_type ffi_type_uint64;
            ffi_type ffi_type_sint64;
            ffi_type ffi_type_float;
            ffi_type ffi_type_double;
            ffi_type ffi_type_pointer;
        }

        ffi_status ffi_prep_cif(ffi_cif* cif,
                                ffi_abi abi,
                                uint nargs,
                                ffi_type* rtype,
                                ffi_type** atypes);

        void ffi_call(ffi_cif* cif,
                      void* fn,
                      void* rvalue,
                      void** avalue);
    }

    ffi_status initializeCIF(ffi_cif* cif,
                             ffi_type*[] argTypes,
                             ffi_type* returnType,
                             int abi)
    {
        return ffi_prep_cif(cif,
                            cast(ffi_abi)abi,
                            cast(uint)argTypes.length,
                            returnType,
                            argTypes.ptr);
    }
}

struct FFIType
{
    private ffi_type* _type;

    private this(ffi_type* type)
    {
        _type = type;
    }

    this(FFIType*[] fields)
    {
        _type = new ffi_type();
        _type.type = 13; // FFI_TYPE_STRUCT

        ffi_type*[] f;

        foreach (fld; fields)
            f ~= fld._type;

        _type.elements = f.ptr;
    }

    static this()
    {
        _ffiVoid = FFIType(&ffi_type_void);
        _ffiByte = FFIType(&ffi_type_sint8);
        _ffiUByte = FFIType(&ffi_type_uint8);
        _ffiShort = FFIType(&ffi_type_sint16);
        _ffiUShort = FFIType(&ffi_type_uint16);
        _ffiInt = FFIType(&ffi_type_sint32);
        _ffiUInt = FFIType(&ffi_type_uint32);
        _ffiLong = FFIType(&ffi_type_sint64);
        _ffiULong = FFIType(&ffi_type_uint64);
        _ffiFloat = FFIType(&ffi_type_float);
        _ffiDouble = FFIType(&ffi_type_double);
        _ffiPointer = FFIType(&ffi_type_pointer);
    }

    private static FFIType _ffiVoid;
    private static FFIType _ffiByte;
    private static FFIType _ffiUByte;
    private static FFIType _ffiShort;
    private static FFIType _ffiUShort;
    private static FFIType _ffiInt;
    private static FFIType _ffiUInt;
    private static FFIType _ffiLong;
    private static FFIType _ffiULong;
    private static FFIType _ffiFloat;
    private static FFIType _ffiDouble;
    private static FFIType _ffiPointer;

    @property static FFIType* ffiVoid()
    {
        return &_ffiVoid;
    }

    @property static FFIType* ffiByte()
    {
        return &_ffiByte;
    }

    @property static FFIType* ffiUByte()
    {
        return &_ffiUByte;
    }

    @property static FFIType* ffiShort()
    {
        return &_ffiShort;
    }

    @property static FFIType* ffiUShort()
    {
        return &_ffiUShort;
    }

    @property static FFIType* ffiInt()
    {
        return &_ffiInt;
    }

    @property static FFIType* ffiUInt()
    {
        return &_ffiUInt;
    }

    @property static FFIType* ffiLong()
    {
        return &_ffiLong;
    }

    @property static FFIType* ffiULong()
    {
        return &_ffiULong;
    }

    @property static FFIType* ffiFloat()
    {
        return &_ffiFloat;
    }

    @property static FFIType* ffiDouble()
    {
        return &_ffiDouble;
    }

    @property static FFIType* ffiPointer()
    {
        return &_ffiPointer;
    }
}

enum FFIStatus
{
    success,
    badType,
    badABI,
}

version (Win32)
{
    enum FFIInterface
    {
        platform,
        stdCall,
    }
}
else
{
    enum FFIInterface
    {
        platform,
    }
}

alias void function() FFIFunction;

FFIStatus ffiCall(FFIFunction func,
                  FFIType* returnType,
                  FFIType*[] parameterTypes,
                  void* returnValue,
                  void*[] argumentValues,
                  FFIInterface abi = FFIInterface.platform)
in
{
    assert(func);
    assert(returnType);

    foreach (param; parameterTypes)
        assert(param);

    if (returnType._type != FFIType.ffiVoid._type)
        assert(returnValue);

    foreach (arg; argumentValues)
        assert(arg);

    assert(argumentValues.length == parameterTypes.length);
}
body
{
    ffi_type*[] argTypes;

    foreach (param; parameterTypes)
        argTypes ~= param._type;

    int selectedABI = ffi_abi.FFI_DEFAULT_ABI;

    version (Win32)
    {
        if (abi == FFIInterface.stdCall)
            selectedABI = 2; // FFI_STDCALL
    }

    ffi_cif cif;

    auto status = initializeCIF(&cif, argTypes, returnType._type, selectedABI);

    if (status != ffi_status.FFI_OK)
        return cast(FFIStatus)status;

    ffi_call(&cif, cast(void*)func, returnValue, argumentValues.ptr);

    return FFIStatus.success;
}
