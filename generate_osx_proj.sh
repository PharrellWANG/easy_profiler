BUILD_DIR=build.osx

if [ -z "$QCI_WORKSPACE" ]; then
  if [ -z "$CI" ]; then
    ########## define for local begin ##########
    APP_BUNDLE_SHORT_VERSION_STRING="1.0"
    APP_BUNDLE_VERSION="1"
    USE_VE_WORKSPACE=1
    ########## define for local end ##########
  else
    USE_VE_WORKSPACE=0
    ########## define for RDM begin ##########
    APP_BUNDLE_SHORT_VERSION_STRING="$MajorVersion.$MinorVersion.$FixVersion"
    APP_BUNDLE_VERSION="$BuildNo"
    ########## define for RDM end ##########
    # avoid rdm cache
    if [ -d "$BUILD_DIR" ];then
        rm -rf $BUILD_DIR
    fi

    if [ -d "$CMAKE311_HOME" ]; then
        echo $CMAKE311_HOME
        ls $CMAKE311_HOME
        ls -l $CMAKE311_HOME/bin/cmake
        which cmake
        export PATH=$CMAKE311_HOME/bin:/usr/bin:$PATH
        which cmake
    else
        echo "$CMAKE311_HOME doesn't exists."
    fi

    xcodebuild_path=$XCODE_PATH$compileEnv
    echo "xcodebuild_path $xcodebuild_path"
    $xcodebuild_path -version
  fi
fi

echo "USE_VE_WORKSPACE=$USE_VE_WORKSPACE"
PARENT_DIRECTORY=$(dirname "$PWD")
echo "PARENT_DIRECTORY=$PARENT_DIRECTORY"

git_cmd=git
if which "$git_cmd" >/dev/null 2>&1; then
  GIT_BRANCH_NAME=`git symbolic-ref --short -q HEAD`
  echo "Git branch: $GIT_BRANCH_NAME"
  BUILD_BRANCH_NAME=${GIT_BRANCH_NAME//\//-}
else
  echo "git command not found set USE_VE_WORKSPACE=0"
  set USE_VE_WORKSPACE=0
fi

if [ "$USE_VE_WORKSPACE" -eq "1" ]; then
  VE_WORKSPACE=$PARENT_DIRECTORY/easy_profiler-workspace
  echo "VE_WORKSPACE=$VE_WORKSPACE"
  if [ ! -d "$VE_WORKSPACE" ];then
    echo "mkdir $VE_WORKSPACE"
    mkdir "$VE_WORKSPACE"
  fi

  PROJECT_DIRECTORY=$VE_WORKSPACE/$BUILD_BRANCH_NAME.$BUILD_DIR
  echo "Generate project at $PROJECT_DIRECTORY"
    if [ -d "$PROJECT_DIRECTORY" ];then
    echo "rm -rf $PROJECT_DIRECTORY"
    rm -rf "$PROJECT_DIRECTORY"
  fi
else
  PROJECT_DIRECTORY=$BUILD_DIR
  VE_WORKSPACE=
fi;

if [ -z "$VE_COMPILE_ARM" ]; then
    echo 'VE_COMPILE_ARM not defined, set default TRUE'
    VE_COMPILE_ARM=TRUE
fi

echo "VE_COMPILE_ARM=$VE_COMPILE_ARM"

cmake --version
cmake -E time cmake -GXcode -H. -B"$PROJECT_DIRECTORY" -DCMAKE_TOOLCHAIN_FILE=./scripts/osx.cmake \
 -DVE_COMPILE_ARM="$VE_COMPILE_ARM"

if [ -d "$PROJECT_DIRECTORY/easy_profiler.xcodeproj" ] && [ -z "$CI" ] && [ -z "$QCI_WORKSPACE" ]; then
  open "$PROJECT_DIRECTORY"
fi
