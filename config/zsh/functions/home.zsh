homecheck() {
  ls -A ~ | grep -vxE '\.(aspnet|dotnet|cache|config|local|ssh|zshenv)|docs'
}
