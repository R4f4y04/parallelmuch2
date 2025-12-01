# Quick Start Guide

Get the Parallel Architecture Workbench running in 5 minutes!

## ⚡ Fast Setup (Windows)

### Step 1: Install Prerequisites (10 min)

**Flutter SDK:**
```powershell
# Download from: https://flutter.dev/docs/get-started/install/windows
# Extract to C:\flutter
# Add to PATH: C:\flutter\bin
```

**GCC with OpenMP (MSYS2):**
```powershell
# Download MSYS2: https://www.msys2.org/
# Run installer (default location: C:\msys64)

# After install, open MSYS2 terminal:
pacman -Syu
pacman -S mingw-w64-x86_64-gcc mingw-w64-x86_64-make

# Add to PATH: C:\msys64\mingw64\bin
```

### Step 2: Verify Installation
```powershell
# Check Flutter
flutter --version
# Expected: Flutter 3.x.x

# Check GCC
gcc --version
# Expected: gcc (GCC) 13.x.x or similar

# Check OpenMP
gcc -fopenmp --version
# Should not error
```

### Step 3: Setup Project (2 min)
```powershell
# Navigate to project
cd "d:\Vs Code Flutter\UniProjs\CA_proj\parallelmuch2"

# Install Flutter dependencies
flutter pub get

# Compile C backend
cd backend
make all
cd ..

# Verify executables exist
dir backend\bin
# Should show: matrix_mult.exe, merge_sort.exe, etc.
```

### Step 4: Run Application (1 min)
```powershell
# Launch on Windows
flutter run -d windows
```

🎉 **Done!** The app should open showing the dashboard with 5 algorithm cards.

---

## 🧪 Quick Test

### Test Backend Only
```powershell
cd backend

# Test matrix multiplication (256x256, 2 threads)
.\bin\matrix_mult.exe 256 2

# Expected output:
# {"algo": "matrix_mult", "threads": 2, "size": 256, "time": 0.XXX}
```

### Test Flutter App
1. Click any algorithm card
2. Adjust problem size slider
3. Set thread range (e.g., 1 to 8)
4. Click "EXECUTE BENCHMARK"
5. Watch speedup chart populate in real-time

---

## 🚨 Common Issues

### "flutter: command not found"
**Solution**: Add Flutter to PATH and restart terminal
```powershell
$env:Path += ";C:\flutter\bin"
```

### "gcc: command not found"
**Solution**: Add MSYS2 MinGW to PATH
```powershell
$env:Path += ";C:\msys64\mingw64\bin"
```

### "make: command not found"
**Solution**: Use mingw32-make instead
```powershell
mingw32-make all
```

### "Backend executable not found"
**Cause**: C code not compiled yet
**Solution**:
```powershell
cd backend
make all
```

### App opens but no data in charts
**Cause**: Backend binaries not working
**Solution**: Test backend manually
```powershell
.\backend\bin\matrix_mult.exe 128 1
```

If this errors, check GCC installation.

---

## 📋 Checklist

Before running the app:
- [ ] Flutter SDK installed and in PATH
- [ ] GCC with OpenMP installed (MSYS2)
- [ ] `flutter pub get` completed successfully
- [ ] Backend compiled: `backend/bin/*.exe` exist
- [ ] Test backend: `.\backend\bin\matrix_mult.exe 128 1` works

---

## 🎓 First Run Tutorial

1. **Dashboard**: See 5 algorithm cards with complexity tags
2. **Click "Matrix Multiplication"**: Opens execution screen
3. **Set size to 512** and **threads 1 to 8**
4. **Click "EXECUTE BENCHMARK"**
5. **Watch**:
   - Progress bar updates
   - Terminal shows JSON output
   - Speedup chart renders
   - Data table populates
6. **Switch tabs**: View Efficiency and Raw Data
7. **Check Theory Corner**: Read about false sharing

---

## 🔄 Development Workflow

### After Modifying C Code
```powershell
cd backend
make clean
make all
cd ..
flutter run -d windows
```

### After Modifying Dart Code
```powershell
# Hot reload: Press 'r' in terminal
# OR
flutter run -d windows
```

---

## 📞 Support

**Issues?** Check:
1. `README.md` - Full documentation
2. `backend/README.md` - Backend-specific help
3. Terminal output for error messages

**Debug mode:**
```powershell
flutter run -d windows --verbose
```

---

**Ready to explore parallel performance? Let's go!** 🚀
