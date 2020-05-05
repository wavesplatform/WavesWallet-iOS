files=$(find ./api-specs/grpc/gateways -type f -name "*.proto")

swift_out="Sources/Model"
grpc_swift_out="Sources/Services"

rm -rf "Sources"
mkdir -p $swift_out
mkdir -p $grpc_swift_out

protoc \
  --swift_opt=Visibility=Public \
  --swift_out=$swift_out \
  --plugin=./Bin/protoc-gen-swift \
  --plugin=./Bin/protoc-gen-grpc-swift \
  --grpc-swift_out=$grpc_swift_out \
  --grpc-swift_opt=Visibility=Public,Client=true,Server=false \
  --proto_path "./api-specs/grpc/gateways/" $files