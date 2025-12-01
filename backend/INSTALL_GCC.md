# Quick GCC Installation Guide for Windows

Since you don't have GCC installed, here's the fastest way to get it:

## Option 1: MSYS2 (Recommended - 5 minutes)

1. **Download MSYS2**: https://www.msys2.org/
   - Download the installer (msys2-x86_64-*.exe)
   - Run installer (default location: `C:\msys64`)

2. **Install GCC with OpenMP**:
   ```bash
   # Open "MSYS2 MINGW64" from Start Menu
   pacman -Syu
   pacman -S mingw-w64-x86_64-gcc
   ```

3. **Add to Windows PATH**:
   - Open "Edit system environment variables"
   - Click "Environment Variables"
   - Edit "Path" variable
   - Add: `C:\msys64\mingw64\bin`
   - Click OK and restart terminals

4. **Verify Installation**:
   ```powershell
   gcc --version
   # Should show: gcc (Rev...) 13.x.x or similar
   ```

5. **Compile Backend**:
   ```powershell
   cd backend
   .\compile.bat
   # OR if make works:
   make all
   ```

## Option 2: Pre-compiled Binaries (If you can't install GCC)

If you can't install GCC right now, I can provide you with pre-compiled `.exe` files. However, you won't be able to modify the C code without recompiling.

Would you like me to:
1. Create temporary placeholder executables for testing the UI? (Won't do real computation)
2. Wait for you to install GCC?

## After Installation

Once GCC is installed:
```powershell
# Navigate to backend
cd "d:\Vs Code Flutter\UniProjs\CA_proj\parallelmuch2\backend"

# Compile all algorithms
.\compile.bat

# Test executables
.\compile.bat test

# Verify files exist
dir bin
# Should show: matrix_mult.exe, merge_sort.exe, etc.
```

Then the Flutter app will be fully functional!
