include $(ARCHDIR)/ldc.rules

DFLAGS_COMP=-inline -release -O2
EXCLUDEPAT_OS=*win32* *Win32* *linux *freebsd
