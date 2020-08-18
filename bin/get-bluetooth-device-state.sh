system_profiler SPBluetoothDataType 2>/dev/null | awk '$1=="Connected:" {print $2; exit}'
