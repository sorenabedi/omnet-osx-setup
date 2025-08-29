# OMNeT++ Installer

A comprehensive, automated installation script for OMNeT++ 6.2.0 on macOS systems using Mamba/Conda for dependency management. **Optimized for macOS with M-series processors (Apple Silicon).**

## 🚀 Features

- **Automated Installation**: One-command installation of OMNeT++ with all dependencies
- **Dependency Management**: Uses Mamba/Conda for isolated, conflict-free dependency management
- **Apple Silicon Optimized**: Specifically designed for macOS with M-series processors (M1, M2, M3) with proper ARM64 library linking
- **Parallel Compilation**: Utilizes all available CPU cores for faster builds
- **Automatic Patching**: Applies necessary patches to Makefile.inc for compatibility
- **Environment Isolation**: Creates dedicated conda environment to prevent system conflicts

## 📋 Prerequisites

### System Requirements

- **Operating System**: macOS (tested on macOS 12+)
- **Architecture**: **Primary**: Apple Silicon (ARM64) - M1, M2, M3 processors
  - **Secondary**: Intel (x86_64) - Intel Macs supported but not optimized
- **Memory**: Minimum 8GB RAM (16GB+ recommended)
- **Storage**: At least 10GB free space
- **Shell**: Bash or Zsh

### Required Software

- **Mamba**: Must be installed before running the script
  - Install via [Mambaforge](https://github.com/conda-forge/miniforge#mambaforge) or [Micromamba](https://mamba.readthedocs.io/en/latest/installation/micromamba-installation.html)

## 🛠️ Installation

### Quick Start

```bash
# Clone or download the installer
git clone <repository-url>
cd omnet-installer

# Make the script executable
chmod +x omnet-osx-setup.sh

# Run the installer
./omnet-osx-setup.sh
```

### What the Installer Does

The script performs the following steps automatically:

1. **Prerequisite Check**: Verifies Mamba is installed
2. **Source Download**: Downloads OMNeT++ 6.2.0 source code (if not present)
3. **Environment Setup**: Creates dedicated conda environment with all dependencies
4. **Source Preparation**: Extracts and prepares source directory
5. **Configuration**: Configures build with proper compiler and library paths
6. **Python Dependencies**: Installs required Python packages
7. **Build Patching**: Applies necessary patches to Makefile.inc
8. **Compilation**: Compiles OMNeT++ using all available CPU cores
9. **Post-Installation**: Provides usage instructions

## 🔧 Dependencies

The installer automatically installs the following dependencies in the conda environment:

### Core Build Tools

- `make` - Build automation tool
- `bison` - Parser generator
- `flex` - Lexical analyzer generator
- `pkg-config` - Package configuration tool
- `swig` - Simplified Wrapper and Interface Generator

### Libraries

- `libxml2` - XML parsing library
- `zlib` - Data compression library
- `openscenegraph` - 3D graphics toolkit

### Python Ecosystem

- `python=3.11` - Python interpreter
- `numpy` - Numerical computing
- `scipy` - Scientific computing
- `pandas` - Data manipulation
- `matplotlib` - Plotting library

### GUI Framework

- `qt>=6.2` - Cross-platform application framework

### Compiler

- `llvm` - Compiler infrastructure

## 📁 Project Structure

```
omnet-installer/
├── omnet-osx-setup.sh          # Main installation script
├── README.md               # This file
└── omnetpp-6.2.0/         # OMNeT++ source directory (created during installation)
    ├── samples/            # Sample simulations
    ├── src/                # Source code
    ├── setenv              # Environment setup script
    └── Makefile.inc        # Build configuration
```

## 🚀 Usage

### First Time Setup

After installation, follow these steps to start using OMNeT++:

1. **Activate the environment**:

   ```bash
   mamba activate omnet
   ```

2. **Navigate to OMNeT++ directory**:

   ```bash
   cd omnetpp-6.2.0
   ```

3. **Source the environment** (required for each new terminal session):

   ```bash
   source setenv
   ```

4. **Verify installation**:

   ```bash
   cd samples/aloha
   ./run
   ```

5. **Launch the IDE**:
   ```bash
   omnetpp
   ```

### Daily Usage

For each new terminal session where you want to use OMNeT++:

```bash
mamba activate omnet
cd /path/to/omnetpp-6.2.0
source setenv
# Now you can use OMNeT++ commands
```

## 🔍 Troubleshooting

### Common Issues

#### Mamba Not Found

```bash
❌ Mamba not found. Please install Mambaforge or Micromamba.
```

**Solution**: Install Mamba using one of these methods:

- [Mambaforge](https://github.com/conda-forge/miniforge#mambaforge)
- [Micromamba](https://mamba.readthedocs.io/en/latest/installation/micromamba-installation.html)

#### Build Failures

If compilation fails, try these steps:

1. **Clean and retry**:

   ```bash
   cd omnetpp-6.2.0
   make clean
   ./configure  # Re-run configuration
   make -j$(sysctl -n hw.ncpu)
   ```

2. **Check environment**:

   ```bash
   mamba activate omnet
   which gcc g++ make
   echo $CONDA_PREFIX
   ```

3. **Verify dependencies**:
   ```bash
   mamba list | grep -E "(qt|libxml2|zlib|bison|flex)"
   ```

#### Runtime Library Issues

If you encounter library loading errors:

1. **Check library paths**:

   ```bash
   otool -L /path/to/omnetpp/binary
   ```

2. **Verify rpath**:
   ```bash
   otool -l /path/to/omnetpp/binary | grep -A2 LC_RPATH
   ```

### Performance Optimization

- **Parallel Compilation**: The script automatically uses all CPU cores
- **Memory**: Ensure sufficient RAM (16GB+ recommended for large projects)
- **Storage**: Use SSD for faster compilation times

## 📚 Additional Resources

- [OMNeT++ Official Documentation](https://doc.omnetpp.org/)
- [OMNeT++ User Manual](https://doc.omnetpp.org/omnetpp/manual/)
- [OMNeT++ API Reference](https://doc.omnetpp.org/omnetpp/api/)
- [OMNeT++ Community](https://groups.google.com/g/omnetpp)

## 🤝 Contributing

Contributions are welcome! Please feel free to submit issues, feature requests, or pull requests.

### Development Setup

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- OMNeT++ development team for the excellent simulation framework
- Conda-forge community for maintaining the package ecosystem
- macOS development community for platform-specific insights

## 📞 Support

If you encounter issues or have questions:

1. Check the [troubleshooting section](#troubleshooting) above
2. Search existing [issues](../../issues)
3. Create a new issue with detailed information about your problem
4. Include your system information and error messages

---

**Note**: This installer is specifically designed and optimized for macOS systems with M-series processors (Apple Silicon). While it may work on Intel Macs, it's primarily tested and optimized for ARM64 architecture. For other operating systems, please refer to the [official OMNeT++ installation guide](https://doc.omnetpp.org/omnetpp/InstallGuide.pdf).
