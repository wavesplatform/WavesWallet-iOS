files=$(find . -type f -name "*.proto")
echo $files
for file in $files
do
filename="${file##*/}"
file_path=${file%/*}/
swift_out="Sources/${file_path#./}"
echo $file
echo $filename
echo $file_path
mkdir -p $swift_out
protoc  --swift_opt=Visibility=Public --swift_out=$swift_out --proto_path $file_path $filename
done
