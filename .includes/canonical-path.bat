:: Get the canonical path of %1, and return it by CANONICAL_PATH environment variable
pushd %1
set CANONICAL_PATH=%cd%
popd
