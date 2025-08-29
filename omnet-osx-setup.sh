#!/bin/bash

# ==============================================================================
# OMNeT++ 6.2.0 Installation Script for macOS with Mamba/Conda
#
# This script automates the download, configuration, and compilation of OMNeT++.
# It creates a dedicated conda environment to manage all dependencies,
# preventing conflicts with system libraries.
# ==============================================================================

# --- Configuration ---

# Environment and Software Versions
OMNET_VERSION="6.2.0"
ENV_NAME="omnet"
PYTHON_VERSION="3.11"

# Derived names
OMNET_DIR="omnetpp-${OMNET_VERSION}"
OMNET_TARGZ="${OMNET_DIR}-macos-aarch64.tgz"
OMNET_URL="https://github.com/omnetpp/omnetpp/releases/download/${OMNET_DIR}/${OMNET_DIR}-macos-aarch64.tgz"

# --- Helper Functions for Colored Output ---
cecho() {
    local color_code=$1
    shift
    echo -e "\033[${color_code}m$@\033[0m"
}
green() { cecho "32" "$@"; }
yellow() { cecho "33" "$@"; }
red() { cecho "31" "$@"; }


# --- Main Logic ---

# Step 0: Prerequisite Check (check for mamba)
if ! command -v mamba &> /dev/null; then
    red "❌ Mamba not found. Please install Mambaforge or Micromamba."
    exit 1
fi

# Step 1: Download OMNeT++ Source if not already downloaded
yellow "➡️ Step 1: Downloading OMNeT++ source code..."
if [ ! -f "${OMNET_TARGZ}" ]; then
    green "File ${OMNET_TARGZ} not found. Downloading from ${OMNET_URL}..."
    # use aria2c to download the file if not, use curl as fallback
    if command -v aria2c &> /dev/null; then
        aria2c -x 16 -o "${OMNET_TARGZ}" "${OMNET_URL}"
    else
        curl -L -o "${OMNET_TARGZ}" "${OMNET_URL}"
    fi
else
    green "✅ Source archive ${OMNET_TARGZ} already exists."
fi

# Step 2: Set up Conda Environment
yellow "\n➡️ Step 2: Setting up the '${ENV_NAME}' mamba environment..."
if mamba env list | grep -q "^${ENV_NAME}\s"; then
    yellow "⚠️ Environment '${ENV_NAME}' already exists. Removing for a clean installation."
    mamba env remove --name "${ENV_NAME}" -y
fi

green "Creating new environment with all dependencies..."
# We install all dependencies in one go for better dependency resolution.
# This list is derived from your successful attempts and OMNeT++ docs.
MAMBA_DEPS=(
    "python=${PYTHON_VERSION}"
    "make"
    "qt>=6.2" # Qt5 is often more stable for OMNeT++'s IDE
    "libxml2"
    "zlib"
    "bison"
    "flex"
    "perl"
    "pkg-config"
    "swig"
    "numpy"
    "scipy"
    "pandas"
    "matplotlib"
    "swig"
    "openscenegraph" # For 3D visualization
)
mamba create --name "${ENV_NAME}" -c conda-forge -y "${MAMBA_DEPS[@]}"
mamba run -n "${ENV_NAME}" pip install --no-input llvm
green "✅ Mamba environment '${ENV_NAME}' created successfully."

# Step 3: Unpack and Prepare Source Directory
yellow "\n➡️ Step 3: Unpacking source code..."
# Clean up previous extraction directory if it exists
if [ -d "${OMNET_DIR}" ]; then
    yellow "Removing old directory '${OMNET_DIR}'..."
    rm -rf "${OMNET_DIR}"
fi
tar xzf "${OMNET_TARGZ}"
cd "${OMNET_DIR}"
green "✅ Unpacked and changed directory to ${OMNET_DIR}."

# Step 4: Configure the Build
yellow "\n➡️ Step 4: Configuring the build..."
yellow "This will use the compilers and libraries from the '${ENV_NAME}' environment."

# Step 4: Install Python Requirements
yellow "\n➡️ Step 4.1: Installing Python requirements..."
mamba run -n "${ENV_NAME}" pip install -r python/requirements.txt
green "✅ Python requirements installed successfully."

# Step 4.2: Source the environment script
yellow "\n➡️ Step 4.2: Sourcing the environment script..."
export PATH=$CONDA_PREFIX/bin:$PATH
export CMAKE_PREFIX_PATH=$CONDA_PREFIX
export CPPFLAGS="-I$CONDA_PREFIX/include"
export LDFLAGS="-L$CONDA_PREFIX/lib"
source setenv

green "✅ Environment script sourced successfully."


# These environment variables are critical. They instruct the configure script
# to use the compiler and libraries from our conda environment.
# - PKG_CONFIG_PATH: Points to the pkgconfig directories.
# - CPPFLAGS: Points to the include/header directories.
# - LDFLAGS: Points to the library directories and, crucially, adds a runtime
#   path (rpath) so the compiled binaries know where to find their .dylib
#   dependencies at runtime. This avoids DYLD_LIBRARY_PATH issues.
CONFIGURE_COMMAND="./configure CC=clang CXX=clang++ CPPFLAGS=\"-I\$CONDA_PREFIX/include\" LDFLAGS=\"-L\$CONDA_PREFIX/lib -Wl,-rpath,\$CONDA_PREFIX/lib\" WITH_QT_PATH=\"\$CONDA_PREFIX\" WITH_OSG_PATH=\"\$CONDA_PREFIX\" WITH_OSG=no"

# Use `mamba run` to execute the command within the context of our environment
mamba run -n ${ENV_NAME} bash -c "${CONFIGURE_COMMAND}"
green "✅ Configuration complete."

# Step 5: Patch Makefile.inc
yellow "\n➡️ Step 5: Applying required patches to Makefile.inc..."

# This is the automation of the manual edits you were performing.
# 1. Replace the hardcoded Apple toolchain prefix with the generic variable.
#    This makes the build more robust and less dependent on a specific OS version.
# replace arm64-apple-darwin20.0.0- with "$(TOOLCHAIN_BIN_DIR)" in the Makefile.inc
sed -i.bak 's/arm64-apple-darwin20.0.0-/$(TOOLCHAIN_BIN_DIR)/g' Makefile.inc

# 2. Remove the '-no_warn_duplicate_libraries' flag, as you identified.
#    This flag can sometimes cause issues with modern linkers.
sed -i.bak 's/-no_warn_duplicate_libraries//g' Makefile.inc

green "✅ Makefile.inc patched successfully. Original saved as Makefile.inc.bak."

# Step 6: Compile OMNeT++
yellow "\n➡️ Step 6: Compiling OMNeT++. This may take a while... ☕"

# Get the number of CPU cores for parallel compilation
N_CORES=$(sysctl -n hw.ncpu)
green "Using ${N_CORES} cores for compilation."

# Again, use `mamba run` to ensure the 'make' command has the correct environment
mamba run -n "${ENV_NAME}" make -j"${N_CORES}"

green "✅ OMNeT++ compiled successfully!"

# Step 7: Final Instructions
yellow "\n🎉 Installation Complete! 🎉"
echo ""
echo "To use OMNeT++, follow these steps:"
echo "1. Activate the mamba environment:"
green "   mamba activate ${ENV_NAME}"
echo ""
echo "2. Navigate to your OMNeT++ directory:"
green "   cd $(pwd)"
echo ""
echo "3. Source the environment script (do this in every new terminal session):"
green "   source setenv"
echo ""
echo "4. Verify the installation by running a sample simulation:"
green "   cd samples/aloha && ./run"
echo ""
echo "5. Launch the OMNeT++ IDE:"
green "   omnetpp"
echo ""